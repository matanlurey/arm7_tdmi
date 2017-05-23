import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart' hide bit;
import 'package:bit_pattern/bit_pattern.dart';

import 'format.dart';
import 'compiler.dart';
import 'package:meta/meta.dart';

@visibleForTesting
abstract class Encodings {
  /// Data processing instruction.
  static final dataProcessing = new BitPattern([
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
  static final undefined = new BitPattern([
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

  /// Software interrupt.
  static final swi = new BitPattern([
    nibble('cond'), // 31 - 28
    1, // 27
    1, // 26
    1, // 25
    1, // 24
    bits(24, 'swi_number') // 23 - 0
  ]);

  /// Miscellaneous.
  static final misc = new BitPattern([
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

  /// Coprocessor register transfer.
  static final crt = new BitPattern([
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
    1, // 4
    nibble('CRm') // 3 - 0
  ]);

  /// Branch and branch with link.
  static final branch = new BitPattern([
    nibble('cond'), // 31 - 28
    1, // 27
    0, // 26
    1, // 25
    bit('L'), // 24
    bits(24, '24_bit_offset') // 23 - 0
  ]);

  /// Multiplies and extra loads/stores
  static final multiplies = new BitPattern([
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

  /// Move immediate to status register
  static final moveImmediate = new BitPattern([
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

  static final loadsAndStores = new BitPattern([
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
    nibble('Rm'), // 3 - 0s
  ]);

  static final matcher = new BitPatternGroup([
    dataProcessing,
    undefined,
    swi,
    misc,
    crt,
    branch,
    multiplies,
    moveImmediate,
    loadsAndStores,
  ]);
}

/// Decodes encoded 32-bit ARMv4t into executable [Instruction] instances.
class ArmDecoder {
  // None of the instructions are yet implemented.
  //
  // ignore: unused_field
  final ArmCompiler _compiler;

  /// Create a new ARM decoder.
  ///
  /// Optionally specify a custom [compiler] strategy.
  const ArmDecoder({ArmCompiler compiler: const ArmCompiler()})
      : _compiler = compiler;

  /// Decodes and returns an executable instance from an ARM [iw].
  Instruction decode(int iw) {
    // The strategy is to first check whether the bit pattern of iw matches the
    // encoding of the instruction formats containing the fewest number of
    // variable bits.
    assert(uint32.inRange(iw), 'Requires a 32-bit input');

    var encoding = Encodings.matcher.match(iw);
    if (encoding == Encodings.undefined) {
      return _undefined(iw);
    } else if (encoding == Encodings.swi) {
      return _decodeSWI(iw);
    } else if (encoding == Encodings.misc) {
      return _decodeMiscellaneous(iw);
    } else if (encoding == Encodings.crt) {
      return _decodeCoprocessorRegisterTransfer(iw);
    } else if (encoding == Encodings.dataProcessing) {
      return _decodeData(iw);
    } else if (encoding == Encodings.branch) {
      return _decodeBranches(iw);
    } else if (encoding == Encodings.multiplies) {
      return _undefined(iw);
    } else if (encoding == Encodings.moveImmediate) {
      return _undefined(iw);
    } else if (encoding == Encodings.loadsAndStores) {
      return _decodeLoadStore(iw);
    } else {
      return _undefined(iw);
    }
  }

  Instruction _decodeLoadStore(int iw) {
    /*
      FIXME:
      - LDRH Load halfword
      - LDRSB Load signed byte
      - LDRSH Load signed halfword
      - LDM Load multiple
      - STRB Store byte
      - STRH Store halfword
      - STM Store multiple
     */
    var format = new LoadAndStoreFormat(iw);
    if (format.b) {
      if (format.l) {
        return _compiler.createLDRByte(user: null, rd: null, aMode: null);
      } else {
        return _compiler.createSTRByte(user: null, rd: null, aMode: null);
      }
    } else {
      if (format.l) {
        return _compiler.createLDRWord(user: null, rd: null, aMode: null);
      } else {
        return _compiler.createSTRWord(user: null, rd: null, aMode: null);
      }
    }
  }

  /// See Figure A3-4 of the official ARM docs.
  Instruction _decodeMiscellaneous(int iw) {
    if (bitRange(iw, 27, 23) == 0x6 ||
        (bitRange(iw, 27, 23) == 0x2 && bitRange(iw, 7, 4) == 0x0)) {
      return _compiler.createMSR(cond: null, spsr: null, field: null, rm: null);
    } else if (bitRange(iw, 27, 20) == 0x12) {
      return _compiler.createBX(cond: null, operand: null);
    }
    return _undefined(iw);
  }

  Instruction _decodeCoprocessorRegisterTransfer(int iw) {
    final format = new CoprocessorRegisterFormat(iw);

    // FIXME: Use the format!
    if (bitRange(iw, 27, 24) == 0xE && isClear(iw, 20) && isSet(iw, 4)) {
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
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
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
