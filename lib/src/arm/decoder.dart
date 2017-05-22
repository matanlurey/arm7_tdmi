import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';

import 'format.dart';
import 'compiler.dart';

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

    if (_isUndefined(iw)) {
      return _undefined(iw);
    } else if (_isSoftwareInterrupt(iw)) {
      return _decodeSWI(iw);
    } else if (_isMiscellaneous(iw)) {
      return _decodeMiscellaneous(iw);
    } else if (_isCoprocessorRegisterTransfer(iw)) {
      return _decodeCoprocessorRegisterTransfer(iw);
    } else if (_isDataProcessing(iw)) {
      return _decodeData(iw);
    } else if (_isBranch(iw)) {
      return _decodeBranches(iw);
    } else {
      return _undefined(iw);
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

  /// Returns true iff [iw] is encoded as a software interrupt.
  bool _isSoftwareInterrupt(int iw) => bitRange(iw, 27, 24) == 0xF;

  /// Returns true iff [iw] is encoded as a coprocessor register transfer.
  bool _isCoprocessorRegisterTransfer(int iw) =>
      bitRange(iw, 27, 24) == 0xE && isSet(iw, 4);

  /// Returns true iff [iw] is encoded as a coprocessor data operation.
  // ignore: unused_element
  bool _isCoprocessorDataProcessing(int iw) =>
      bitRange(iw, 27, 24) == 0xE && isClear(iw, 4);

  /// Returns true iff [iw] is encoded as a coprocessor data transfer.
  ///
  /// This is also called a "Double register transfer".
  ///
  /// This is the only instruction with high bits 110
  // FIXME: Add bit pattern
  // ignore: unused_element
  bool _isCoprocessorLoadStore(int iw) =>
      bitRange(iw, 27, 25) == 0x6 && isSet(iw, 4);

  // ignore: unused_element
  bool _isLoadStoreMultiple(int iw) => bitRange(iw, 27, 24) == 0x4;

  // ignore: unused_element
  bool _isLoadStoreRegisterOffset(int iw) =>
      bitRange(iw, 27, 24) == 0x3 && isClear(iw, 4);

  // ignore: unused_element
  bool _isLoadStoreImmediateOffset(int iw) => bitRange(iw, 27, 24) == 0x2;

  bool _isMoveImmediateToStatusRegister(int iw) =>
      bitRange(iw, 27, 23) == 0x5 && bitRange(iw, 21, 20) == 0x2;

  /// Returns true iff [iw] is encoded as a branch instruction.
  ///
  /// This is also called a "Double register transfer".
  bool _isBranch(int iw) => bitRange(iw, 27, 25) == 0x5;

  bool _isMiscellaneous(int iw) =>
      bitRange(iw, 27, 23) == 0x2 &&
      isClear(iw, 20) &&
      (isClear(iw, 4) || (isClear(iw, 7) && isSet(iw, 4)));

  /// Returns true iff [iw] is encoded as an undefined instruction.
  ///
  /// It's worth nothing that in general, an instruction with an unrecognized
  /// bit pattern can also be undefined, even if `_isUndefined(x) == false`.
  bool _isUndefined(int iw) =>
      bitRange(iw, 27, 25) == 0x1 &&
      bitRange(iw, 24, 23) == 0x2 &&
      bitRange(iw, 21, 20) == 0;

  // ignore: unused_element
  bool _isArchUndefined(int iw) => bitRange(iw, 27, 20) == 0xEF;

  // ignore: unused_element
  bool _isMediaInstruction(int iw) =>
      bitRange(iw, 27, 24) == 0x3 && isSet(iw, 4);

  /// Returns true iff [iw] is encoded as a single data transfer instruction.
  // ignore: unused_element
  bool _isSingleDataTransfer(int iw) =>
      bitRange(iw, 27, 25) == 0x3 && isClear(iw, 4);

  /// Returns true iff [iw] is encoded as a halfword data transfer instruction.
  ///
  /// This is also known as an immediate offset instruction.
  // FIXME: Add bit pattern
  // ignore: unused_element
  bool _isHalfwordDataTransferImmediateOffset(int iw) =>
      bitRange(iw, 27, 25) == 0 && [22, 7, 4].every((int n) => isSet(iw, n));

  /// Returns true iff [iw] is encoded as a halfword data transfer instruction.
  // FIXME: Add bit pattern
  // ignore: unused_element
  bool _isHalfwordDataTransferRegisterOffset(int iw) =>
      bitRange(iw, 27, 25) == 0 &&
      isClear(iw, 22) &&
      bitRange(iw, 11, 8) == 0 &&
      [7, 4].every((int n) => isSet(iw, n));

  /// Returns true iff [iw] is encoded as a single data swap instruction.
  // ignore: unused_element
  bool _isSingleDataSwap(int iw) =>
      bitRange(iw, 27, 23) == 0x2 &&
      bitRange(iw, 21, 20) == 0 &&
      bitRange(iw, 11, 4) == 0x9;

  /// Returns true iff [iw] is encoded as a multiply instruction.
  ///
  /// Extra loads/stores instructions match this filter.
  // FIXME: Add bit pattern
  // ignore: unused_element
  bool _isMultiply(int iw) =>
      bitRange(iw, 27, 25) == 0 && isSet(iw, 7) && isSet(iw, 4);

  /// Returns true iff [iw] is encoded as a data processing instruction.
  ///
  /// This includes register and immediate shifts.
  // FIXME: Add bit pattern
  bool _isDataProcessing(int iw) =>
      (bitRange(iw, 27, 25) == 0 && isClear(iw, 4)) ||
      (bitRange(iw, 27, 25) == 0 && isClear(iw, 7) && isSet(iw, 4)) ||
      (bitRange(iw, 27, 25) == 0x1 &&
          !_isUndefined(iw) &&
          !_isMoveImmediateToStatusRegister(iw));

  // FIXME: Decode miscellaneous instructions.
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
