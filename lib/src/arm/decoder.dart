import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/format.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_2.dart';
import 'package:binary/binary.dart' hide bit;
import 'package:bit_pattern/bit_pattern.dart';

import 'format.dart';
import 'compiler.dart';

/// Decodes encoded 32-bit ARMv4t into executable [Instruction] instances.
class ArmDecoder {
  final ArmCompiler _compiler;

  /// Create a new ARM decoder.
  ///
  /// Optionally specify a custom [compiler] strategy.
  const ArmDecoder({ArmCompiler compiler: const ArmCompiler()})
      : _compiler = compiler;

  /// Decodes and returns an executable instance from an ARM [iw].
  Instruction decode(int iw) {
    assert(uint32.inRange(iw), 'Requires a 32-bit input');

    final encoding = _Encodings.matcher.match(iw);
    if (encoding == _Encodings.undefined) {
      return _undefined(iw);
    } else if (encoding == _Encodings.swi) {
      return _decodeSWI(iw);
    } else if (encoding == _Encodings.misc) {
      return _decodeMiscellaneous(iw);
    } else if (encoding == _Encodings.coprocessorDataRegister) {
      return _decodeCoprocessorRegisterTransfer(iw);
    } else if (encoding == _Encodings.dataProcessing) {
      return _decodeData(iw);
    } else if (encoding == _Encodings.branches) {
      return _decodeBranches(iw);
    } else if (encoding == _Encodings.multiplies) {
      return _undefined(iw);
    } else if (encoding == _Encodings.moveImmediate) {
      return _undefined(iw);
    } else if (encoding == _Encodings.loadStoreOffset) {
      return _decodeLoadStore(iw);
    } else {
      return _undefined(iw);
    }
  }

  Instruction _decodeLoadStore(int iw) {
    final format = new LoadStoreFormat(iw);
    return format.l
        ? _compiler.createLDR(
            cond: format.cond,
            isByte: format.b,
            rd: format.rd,
            address: AddressingMode2.decodeAddress(iw),
          )
        : _compiler.createSTR(
            cond: format.cond,
            user: null,
            rd: null,
            aMode: null,
          );
  }

  /// See Figure A3-4 of the official ARM docs.
  Instruction _decodeMiscellaneous(int iw) {
    final format = new MoveToStatusRegisterFormat(iw);

    if (format.i || (bitRange(iw, 21, 20) == 2 && bitRange(iw, 7, 4) == 0x0)) {
      // MSR
      if (format.i) {
        final immFormat = new ImmediateMoveToStatusRegisterFormat(iw);
        return _compiler.createMSRImmediate(
          cond: immFormat.cond,
          spsr: immFormat.spsr,
          fieldMask: immFormat.fieldMask,
          rotation: immFormat.rotation,
          immediate: immFormat.immediate,
        );
      } else {
        final regFormat = new RegisterMoveToStatusRegisterFormat(iw);
        return _compiler.createMSRRegister(
          cond: regFormat.cond,
          spsr: regFormat.spsr,
          fieldMask: regFormat.fieldMask,
          rm: regFormat.rm,
        );
      }
    } else if (bitRange(iw, 21, 20) == 0 && bitRange(iw, 7, 4) == 0) {
      return _compiler.createMRS(
        cond: format.cond,
        spsr: format.spsr,
        rd: format.rd,
      );
    } else if (bitRange(iw, 21, 20) == 0x2) {
      return _compiler.createBX(
        cond: null,
        operand: null,
      );
    }
    return _undefined(iw);
  }

  Instruction _decodeCoprocessorRegisterTransfer(int iw) {
    final format = new CoprocessorRegisterFormat(iw);

    if (!format.l && isSet(iw, 4)) {
      return _compiler.createMCR(
        cond: format.cond,
        cpnum: null,
        op1: null,
        rd: null,
        crn: null,
        crm: null,
        op2: null,
      );
    }
    return _undefined(iw);
  }

  Instruction _decodeSWI(int iw) {
    final format = new SoftwareInterruptFormat(iw);
    return _compiler.createSWI(cond: format.cond, routine: format.routine);
  }

  Instruction _decodeData(int iw) {
    final format = new DataProcessingFormat(iw);
    switch (format.opcode) {
      // AND
      case 0x0:
        return _compiler.createAND(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          shifter: AddressingMode1.decodeShifter(format.operand2, format.i),
        );
      // EOR
      case 0x1:
        return _compiler.createEOR(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // SUB
      case 0x2:
        return _compiler.createSUB(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          // ???
          op1: format.rn,
          op2: format.operand2,
        );
      // RSB
      case 0x3:
        return _compiler.createRSB(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          op1: format.rn,
          op2: format.operand2,
        );
      // ADD
      case 0x4:
        return _compiler.createADD(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          // ???
          op1: format.rn,
          shifter: AddressingMode1.decodeShifter(format.operand2, format.i),
        );
      // ADC
      case 0x5:
        return _compiler.createADC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // SBC
      case 0x6:
        return _compiler.createSBC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          op1: format.rn,
          op2: format.operand2,
        );
      // RSC
      case 0x7:
        return _compiler.createRSC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // TST
      case 0x8:
        return _compiler.createTST(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // TEQ
      case 0x9:
        return _compiler.createTEQ(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // CMP
      case 0xA:
        return _compiler.createCMP(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // CMN
      case 0xB:
        return _compiler.createCMN(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // ORR
      case 0xC:
        return _compiler.createORR(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // MOV
      case 0xD:
        return _compiler.createMOV(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          shifter: AddressingMode1.decodeShifter(format.operand2, format.i),
        );
      // BIC
      case 0xE:
        return _compiler.createBIC(
          cond: format.cond,
          cpsr: format.s,
          rd: format.rd,
          rn: format.rn,
          shifter: AddressingMode1.decodeShifter(format.operand2, format.i),
        );
      // MVN
      case 0xF:
        return _compiler.createMVN(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          shifter: AddressingMode1.decodeShifter(format.operand2, format.i),
        );
    }
    final hexOp = format.opcode.toRadixString(16).toUpperCase();
    throw new ArgumentError('Could not decode opcode 0x${hexOp}');
  }

  // ignore: strong_mode_implicit_dynamic_parameter
  Instruction _undefined(_) => const _Undefined();

  Instruction _decodeBranches(int iw) {
    final format = new BranchFormat(iw);
    return format.l
        ? _compiler.createBL(
            cond: format.cond,
            label: format.immediate,
            immediate: format.immediate,
          )
        : _compiler.createB(cond: format.cond, label: format.immediate);
  }
}

abstract class _Encodings {
  /// Data processing instruction.
  static final dataProcessing = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    0, // 26
    bit('I'), // 25
    nibble('opcode'), // 24 - 21
    bit('S'), // 20
    nibble('Rn'), // 19 - 16
    nibble('Rd'), // 15 - 12
    bits(5, 'shift_amount'), // 11 - 7
    bits(2, 'shift'), // 6 - 5
    bit('_'), // 4
    nibble('Rm') // 3 - 0
  ]);

  /// Undefined instruction.
  static final undefined = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    0, // 26
    1, // 25
    1, // 24
    0, // 23
    bit('x'), // 22
    0, // 21
    0, // 20
    bits(20, 'unused') // 19 - 0
  ]);

  /// Miscellaneous.
  static final misc = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    0, // 26
    0, // 25
    1, // 24
    0, // 23
    bits(2, 'x'), // 22 - 21
    0, // 20
    bits(12, 'x'), // 19 - 8
    bit('bit7'), // 7
    bits(2, 'x'), // 6 - 5
    bit('bit4'), // 4
    nibble('x') // 3 - 0
  ]);

  /// Multiplies and extra loads/stores
  static final multiplies = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    0, // 26
    0, // 25
    bits(17, 'x'), // 24 - 18
    1, // 7
    bits(2, 'x'), // 6 - 5
    1, // 4
    nibble('x') // 3 - 0
  ]);

  /// Move immediate to status register.
  static final moveImmediate = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    0, // 26
    1, // 25
    1, // 24
    0, // 23
    bit('R'), // 22
    1, // 21
    0, // 20
    nibble('mask'), // 19 - 16
    nibble('SBO'), // 15 - 12
    nibble('rotate'), // 11 - 8
    byte('immediate') // 7 - 0
  ]);

  /// Load/store immediate/register offset.
  static final loadStoreOffset = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    1, // 26
    bit('I'), // 25
    bit('P'), // 24
    bit('U'), // 23
    bit('B'), // 22
    bit('W'), // 21
    bit('L'), // 20
    nibble('Rn'), // 19 - 16
    nibble('Rd'), // 15 - 12
    bits(5, 'shift_amount'), // 11 - 7
    bits(2, 'shift'), // 6 - 5
    bit('_'), // 4
    nibble('Rm'), // 3 - 0
  ]);

  /// Media instructions.
  static final media = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    1, // 26
    1, // 25
    bits(20, 'x'), // 24 - 5
    1, // 4
    nibble('x') // 3 - 0
  ]);

  /// Architecturally undefined.
  static final archUndefined = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    0, // 27
    1, // 26
    1, // 25
    1, // 24
    1, // 23
    1, // 22
    1, // 21
    1, // 20
    bits(12, 'x'), // 19 - 8
    1, // 7
    1, // 6
    1, // 5
    1, // 4
    nibble('x') // 3 - 0
  ]);

  /// Load/Store multiple.
  static final loadStoreMultiple = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    1, // 27
    0, // 26
    0, // 25
    bit('P'), // 24
    bit('U'), // 23
    bit('S'), // 22
    bit('W'), // 21
    bit('L'), // 20
    nibble('Rn'), // 19 - 16
    bits(16, 'register_list'), // 15 - 0
  ]);

  /// Branch and branch with link.
  static final branches = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    1, // 27
    0, // 26
    1, // 25
    bit('L'), // 24
    bits(24, '24_bit_offset') // 23 - 0
  ]);

  /// Coprocessor load/store and double register transfers.
  static final coprocessorLoadsStores = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    1, // 27
    1, // 26
    0, // 25
    bit('P'), // 24
    bit('U'), // 23
    bit('N'), // 22
    bit('W'), // 21
    bit('L'), // 20
    nibble('Rn'), // 19 - 16
    nibble('CRd'), // 15 - 12
    nibble('cp_num'), // 11 - 8
    byte('offset') // 7 -0
  ]);

  /// Coprocessor data processing and coprocessor register transfers.
  static final coprocessorDataRegister = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    1, // 27
    1, // 26
    1, // 25
    0, // 24
    bits(3, 'opcode1'), // 23 - 21
    bit('L'), // 20
    nibble('CRn'), // 19 - 16
    nibble('Rd'), // 15 - 12
    nibble('cp_num'), // 11 - 8
    bits(3, 'opcode2'), // 7 - 5
    bit('_'), // 4
    nibble('CRm') // 3 - 0
  ]);

  /// Software interrupt.
  static final swi = new BitPattern(<dynamic>[
    nibble('cond'), // 31 - 28
    1, // 27
    1, // 26
    1, // 25
    1, // 24
    bits(24, 'swi_number') // 23 - 0
  ]);

  /// Unconditional instructions.
  static final unconditional = new BitPattern(<dynamic>[
    1, // 31
    1, // 30
    1, // 29
    1, // 28
    bits(28, 'x'), // 27 - 0
  ]);

  static final matcher = new BitPatternGroup([
    dataProcessing,
    misc,
    undefined,
    multiplies,
    moveImmediate,
    loadStoreOffset,
    media,
    archUndefined,
    loadStoreMultiple,
    branches,
    coprocessorLoadsStores,
    coprocessorDataRegister,
    swi,
    unconditional,
  ]);
}

class _Undefined implements Instruction {
  const _Undefined();

  @override
  ArmCondition get condition => ArmCondition.AL;

  @override
  int execute(Cpu cpu) {
    cpu.raise(ArmException.undefinedInstruction);
    return 3;
  }

  @override
  String get name => 'UNDEFINED';

  @override
  String toDebugString() => 'UNDEFINED';
}
