import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// Lazily computes a data-processing instruction's shifter operand.
///
/// The avoid the ambiguity contained in the ARM documentation, this library
/// refers to the callback that computes a shifter operand as a "shifter".  The
/// phrase "shifter operand" refers to the auxiliary value stored on a [Cpu] as
/// the result of executing a shifter.
typedef ShifterValues Shifter(Cpu cpu);

/// The auxiliary values produced by an [AddressingMode1] shifter.
class ShifterValues {
  /// The second operand to an instruction that uses [AddressingMode1].
  ///
  /// This is written as 'shifter_operand' in instruction pseudo-code.  The
  /// operand takes one of three formats:
  ///
  /// 1. Immediate operand - formed by rotating an 8-bit constant in a 32-bit
  ///    word by an even number of bits (in the range 0-30).  Therefore, each
  ///    instruction contains an 8-bit constant and a 4-bit rotate to be applied
  ///    to that constant.
  /// 2. A register operand value is simply the value of a register. The value
  ///    of the register is used directly as the operand to the data-processing
  ///    instruction.
  /// 3. A shifted register operand value is the value of a register, shifted
  ///    (or rotated) before it is used as the data-processing operand. There
  ///    are five types of shift:
  ///    - ASR Arithmetic shift right.
  ///    - LSL Logical shift left.
  ///    - LSR Logical shift right.
  ///    - ROR Rotate right.
  ///    - RRX Rotate right with extend.
  final int operand;

  // FIXME: Add docs
  final bool carryOut;

  @literal
  const ShifterValues(this.operand, this.carryOut);
}

/// A shifter that executes an immediate shift.
@visibleForTesting
typedef ShifterValues ImmediateShifter(Cpu cpu, {int shift, int rm});

/// A shifter that executes a register shift.
@visibleForTesting
typedef ShifterValues RegisterShifter(Cpu cpu, {int rs, int rm});

/// A shifter that rotates the 8-bit value [immediate] by twice the
/// value of [rotate].
@visibleForTesting
typedef ShifterValues Immediate32Shifter(Cpu cpu, {int rotate, int immediate});

/// ARM Addressing mode 1.
///
/// This mode generates the shifter values for a data-processing instruction.
/// These auxiliary values are stored directly on the [Cpu]. Shifters can be
/// called directly or lazily after being decoded from an ARM instruction.
abstract class AddressingMode1 {
  // ignore: constant_identifier_names
  static const LSL_IMM = 0x0;
  // ignore: constant_identifier_names
  static const REGISTER = 0x0;
  // ignore: constant_identifier_names
  static const LSL_REG = 0x1;
  // ignore: constant_identifier_names
  static const LSR_IMM = 0x2;
  // ignore: constant_identifier_names
  static const LSR_REG = 0x3;
  // ignore: constant_identifier_names
  static const ASR_IMM = 0x4;
  // ignore: constant_identifier_names
  static const ASR_REG = 0x5;
  // Rotate-right with extend (RRX) is also identified by 0x6.  There is no
  // collision because these share the same implementation.
  // ignore: constant_identifier_names
  static const ROR_IMM = 0x6;
  // ignore: constant_identifier_names
  static const ROR_REG = 0x7;
  // ignore: constant_identifier_names
  static const RRX = 0x06;

  static const _registerShifters = const <int, Function>{
    REGISTER: register,
    LSL_REG: logicalShiftLeftByRegister,
    LSR_REG: logicalShiftRightByRegister,
    ASR_REG: shiftRightByRegister,
    ROR_REG: rotateRightByRegister,
  };

  static const _immediateShifters = const <int, Function>{
    LSL_IMM: logicalShiftLeftByImmediate,
    LSR_IMM: logicalShiftRightByImmediate,
    ASR_IMM: shiftRightByImmediate,
    ROR_IMM: rotateRightByImmediate,
  };

  /// Decodes the [Shifter] encoded by [shifterBits].
  ///
  /// [isImmediate32] denotes whether [shifterBits] is an immediate value to be
  /// rotated.
  static Shifter decodeShifter(int shifterBits, bool isImmediate32) {
    if (isImmediate32) {
      final encoding = new _Immediate32ShifterEncoding(shifterBits);
      return (Cpu cpu) => immediate(cpu,
          rotate: encoding.rotate, immediate: encoding.immediate);
    }

    final shifterCode = bitRange(shifterBits, 6, 4);

    /// Whether [shifterBits] is an [_ImmediateShifterEncoding].
    final isImmediate = isClear(shifterBits, 4);

    /// Whether [shifterBits] is an [_RegisterShifterEncoding].
    final isRegister = isClear(shifterBits, 7) && isSet(shifterBits, 4);

    if (isImmediate) {
      final shifter = _immediateShifters[shifterCode];
      if (shifter == null) {
        throw new UnsupportedError('$shifterBits');
      }
      final encoding = new _ImmediateShifterEncoding(shifterBits);
      return (Cpu cpu) => shifter(
            cpu,
            shift: encoding.shift,
            rm: encoding.rm,
          ) as ShifterValues;
    } else {
      assert(isRegister);
      final shifter = _registerShifters[shifterCode];
      if (shifter == null) {
        throw new UnsupportedError('$shifterBits');
      }
      final encoding = new _RegisterShifterEncoding(shifterBits);
      return (Cpu cpu) => shifter(
            cpu,
            rs: encoding.rs,
            rm: encoding.rm,
          ) as ShifterValues;
    }
  }

  /// Provides an [immediate] value to a data-processing instruction, optionally
  /// rotated using [rotate].
  static ShifterValues immediate(
    Cpu cpu, {
    @required int rotate,
    @required int immediate,
  }) {
    bool carryOut;
    final operand = rotateRight(immediate, rotate * 2);

    if (rotate == 0) {
      carryOut = cpu.cpsr.c;
    } else {
      // rotate > 0
      carryOut = int32.isNegative(operand);
    }
    return new ShifterValues(operand, carryOut);
  }

  /// Provides the value of register [rm] directly.
  ///
  /// Despite the name, this is actually an immediate shift.
  static ShifterValues register(Cpu cpu, {@required int rm}) =>
      new ShifterValues(cpu.gprs[rm], cpu.gprs.cpsr.c);

  /// Logical shift left by immediate.
  ///
  /// See [_ImmediateShifterEncoding] for parameter documentation.
  static ShifterValues logicalShiftLeftByImmediate(
    Cpu cpu, {
    @required int shift,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    if (shift == 0) {
      operand = gprs[rm];
      carryOut = cpu.cpsr.c;
    } else {
      // shift > 0
      operand = gprs[rm] << shift;
      carryOut = isSet(gprs[rm], 32 - shift);
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Logical shift left by register.
  ///
  /// See [_RegisterShifterEncoding] for parameter documentation.
  static ShifterValues logicalShiftLeftByRegister(
    Cpu cpu, {
    @required int rs,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    final shift = bitRange(gprs[rs], 7, 0);
    if (shift == 0) {
      operand = gprs[rm];
      carryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      operand = gprs[rm] << shift;
      carryOut = isSet(gprs[rm], 32 - shift);
    } else if (shift == 32) {
      operand = 0;
      carryOut = isSet(gprs[rm], 0);
    } else {
      // shift > 32
      operand = 0;
      carryOut = false;
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Logical shift right by immediate.
  ///
  /// See [_ImmediateShifterEncoding] for parameter documentation.
  static ShifterValues logicalShiftRightByImmediate(
    Cpu cpu, {
    @required int shift,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    if (shift == 0) {
      operand = 0;
      carryOut = isSet(gprs[rm], 31);
    } else {
      operand = gprs[rm] >> shift;
      carryOut = isSet(gprs[rm], shift - 1);
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Logical shift right by register.
  ///
  /// Provides the unsigned value fo a register shifted right (divided by a
  /// variable power of two). It is produced by the value of register [rm],
  /// logically shifted right by the value in the least significant byte of
  /// register [rs]. Zeros are inserted into the vacated bit positions. The
  /// carry-out from the shifter is the last bit shifted out, which is zero if
  /// the shift amount is more than 32, or the C flag if the shift amount is
  /// zero.
  ///
  /// See [_RegisterShifterEncoding] for parameter documentation.
  static ShifterValues logicalShiftRightByRegister(
    Cpu cpu, {
    @required int rs,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    final shift = bitRange(gprs[rs], 7, 0);
    if (shift == 0) {
      operand = gprs[rm];
      carryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      operand = gprs[rm] >> shift;
      carryOut = isSet(gprs[rm], shift - 1);
    } else if (shift == 32) {
      operand = 0;
      carryOut = isSet(gprs[rm], 31);
    } else {
      operand = 0;
      carryOut = false;
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Arithmetic shift right by immediate.
  ///
  /// See [_ImmediateShifterEncoding] for parameter documentation.
  static ShifterValues shiftRightByImmediate(
    Cpu cpu, {
    @required int shift,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    if (shift == 0) {
      if (isClear(gprs[rm], 31)) {
        operand = 0;
      } else {
        operand = uint32.max;
      }
      carryOut = int32.isNegative(gprs[rm]);
    } else {
      // shift > 0
      operand = uint32.arithmeticShiftRight(gprs[rm], shift);
      carryOut = isSet(gprs[rm], shift - 1);
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Arithmetic shift right by register.
  ///
  /// See [_RegisterShifterEncoding] for parameter documentation.
  static ShifterValues shiftRightByRegister(
    Cpu cpu, {
    @required int rs,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    final shift = bitRange(gprs[rs], 7, 0);
    if (shift == 0) {
      operand = gprs[rm];
      carryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      operand = uint32.arithmeticShiftRight(gprs[rm], shift);
      carryOut = isSet(gprs[rm], shift - 1);
    } else {
      // shift >= 32
      operand = int32.isNegative(gprs[rm]) ? uint32.max : 0;
      carryOut = int32.isNegative(gprs[rm]);
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Rotate right by immediate.
  ///
  /// See [_ImmediateShifterEncoding] for parameter documentation.
  static ShifterValues rotateRightByImmediate(
    Cpu cpu, {
    @required int shift,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    if (shift == 0) {
      // RRX
      final c = cpu.cpsr.c ? 1 : 0;
      operand = (c << 31) | (gprs[rm] >> 1);
      carryOut = isClear(gprs[rm], 0);
    } else {
      // shift > 0
      operand = rotateRight(gprs[rm], shift);
      carryOut = isSet(gprs[rm], shift - 1);
    }

    return new ShifterValues(operand, carryOut);
  }

  /// Rotate right by register.
  ///
  /// See [_RegisterShifterEncoding] for parameter documentation.
  static ShifterValues rotateRightByRegister(
    Cpu cpu, {
    @required int rs,
    @required int rm,
  }) {
    final gprs = cpu.gprs;
    int operand;
    bool carryOut;

    final shift = bitRange(gprs[rs], 7, 0);
    final shiftLSB = bitRange(gprs[rs], 4, 0); // + 1 bit.

    if (shift == 0) {
      operand = gprs[rm];
      carryOut = cpu.cpsr.c;
    } else if (shiftLSB == 0) {
      operand = gprs[rm];
      carryOut = int32.isNegative(gprs[rm]);
    } else {
      operand = rotateRight(gprs[rm], shiftLSB);
      carryOut = isSet(gprs[rm], shiftLSB - 1);
    }

    return new ShifterValues(operand, carryOut);
  }
}

/// An encoding for a data-processing instruction's shifter operand.
abstract class _ShifterEncoding {
  /// Bits 11-0 of some [AddressingMode1] instruction.
  final int _shifterBits;

  _ShifterEncoding(this._shifterBits);

  int _bitRange(int start, int end) => bitRange(_shifterBits, start, end);
}

/// A [_ShifterEncoding] for an immediate value with an optional rotation.
class _Immediate32ShifterEncoding extends _ShifterEncoding {
  @literal
  _Immediate32ShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The amount to rotate [immediate] by.
  int get rotate => _bitRange(11, 8);

  /// The value to rotate.
  int get immediate => _bitRange(7, 0);
}

/// A [_ShifterEncoding] for an immediate value with an optional shift.
class _ImmediateShifterEncoding extends _ShifterEncoding {
  @literal
  _ImmediateShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The shift value, referred to as 'shift_imm' in the official arm docs.
  int get shift => _bitRange(11, 7);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}

/// A [_ShifterEncoding] for a register value with an optional shift.
class _RegisterShifterEncoding extends _ShifterEncoding {
  @literal
  _RegisterShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The address of the register containing the shift amount.
  int get rs => _bitRange(11, 8);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}
