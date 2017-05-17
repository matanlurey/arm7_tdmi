import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/format.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// Lazily computes a data-processing instruction's shifter operand.
///
/// The avoid the ambiguity contained in the ARM documentation, this library
/// refers to the callback that computes a shifter operand as a "shifter".  The
/// phrase "shifter operand" refers to the auxiliary value stored on a [Cpu] as
/// the result of executing a shifter.
typedef void LazyShifter();

/// A shifter that executes an immediate shift.
@visibleForTesting
typedef void ImmediateShifter(Cpu cpu, {int shift, int rm});

/// A shifter that executes a register shift.
@visibleForTesting
typedef void RegisterShifter(Cpu cpu, {int rs, int rm});

/// A shifter that rotates the 8-bit value [immediate] by twice the
/// value of [rotate].
@visibleForTesting
typedef void Immediate32Shifter(Cpu cpu, {int rotate, int immediate});

/// An encoding for a data-processing instruction's shifter operand.
abstract class ShifterEncoding {
  final int _shifterOperand;

  ShifterEncoding(this._shifterOperand);

  int _bitRange(int start, int end) => bitRange(_shifterOperand, start, end);
}

/// A [ShifterEncoding] for an immediate value with an optional rotation.
class Immediate32ShifterEncoding extends ShifterEncoding {
  @literal
  Immediate32ShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The amount to rotate [immediate] by.
  int get rotate => _bitRange(11, 8);

  /// The value to rotate.
  int get immediate => _bitRange(7, 0);
}

/// A [ShifterEncoding] for an immediate value with an optional shift.
class ImmediateShifterEncoding extends ShifterEncoding {
  @literal
  ImmediateShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The shift value, referred to as 'shift_imm' in the official arm docs.
  int get shift => _bitRange(11, 7);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}

/// A [ShifterEncoding] for a register value with an optional shift.
class RegisterShifterEncoding extends ShifterEncoding {
  @literal
  RegisterShifterEncoding(int shifterOperand) : super(shifterOperand);

  /// The address of the register containing the shift amount.
  int get rs => _bitRange(11, 8);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}

/// ARM Addressing mode 1.
///
/// This mode generates the shifter values for a data-processing instruction.
/// These auxiliary values are stored directly on the [Cpu]. Shifters can be
/// called directly or lazily after being decoded from an ARM instruction.
abstract class AddressingMode1 {
  static const REGISTER_OR_LSL_IMM = 0x00;
  static const LSL_REG = 0x1;
  static const LSR_IMM = 0x2;
  static const LSR_REG = 0x3;
  static const ASR_IMM = 0x4;
  static const ASR_REG = 0x5;
  static const ROR_IMM = 0x6;
  static const ROR_REG = 0x7;
  static const RRX = 0x06;

  /// Decodes the [LazyShifter] for [instruction].
  static LazyShifter decodeShifterOperand(Cpu cpu, int instruction) {
    var format = new DataProcessingFormat(instruction);
    if (format.i) {
      var encoding = new Immediate32ShifterEncoding(format.operand2);
      return () => immediate(cpu,
          rotate: encoding.rotate, immediate: encoding.immediate);
    }

    int shiftType = bitRange(format.operand2, 3, 0);
    switch (shiftType) {
      case REGISTER_OR_LSL_IMM:
        return _lazyImmediateShifter(cpu, LSLImmediate, format.operand2);
      case LSL_REG:
        return _lazyRegisterShifter(cpu, LSLRegister, format.operand2);
      case LSR_IMM:
        return _lazyImmediateShifter(cpu, LSRImmediate, format.operand2);
      case LSR_REG:
        return _lazyRegisterShifter(cpu, LSRRegister, format.operand2);
      case ASR_IMM:
        return _lazyImmediateShifter(cpu, ASRImmediate, format.operand2);
      case ASR_REG:
        return _lazyRegisterShifter(cpu, ASRRegister, format.operand2);
      case ROR_IMM:
        return _lazyImmediateShifter(cpu, RORImmediate, format.operand2);
      case ROR_REG:
        return _lazyRegisterShifter(cpu, RORRegister, format.operand2);
    }
    throw new UnsupportedError('$instruction');
  }

  /// Provides an [immediate] value to a data-processing instruction, optionally
  /// rotated using [rotate].
  static void immediate(
    Cpu cpu, {
    @required int rotate,
    @required int immediate,
  }) {
    // TODO: consume 1 cycle
    cpu.shifterOperand = rotateRight(immediate, rotate * 2);
    if (rotate == 0) {
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else {
      // rotate > 0
      cpu.shifterCarryOut = int32.isNegative(cpu.shifterOperand);
    }
  }

  /// Logical shift left by immediate.
  ///
  /// See [ImmediateShifterEncoding] for parameter documentation.
  static void LSLImmediate(Cpu cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else {
      // shift > 0
      cpu.shifterOperand = gprs[rm] << shift;
      cpu.shifterCarryOut = isSet(gprs[rm], 32 - shift);
    }
  }

  /// Logical shift left by register.
  ///
  /// See [RegisterShifterEncoding] for parameter documentation.
  static void LSLRegister(Cpu cpu, {@required int rs, @required int rm}) {
    // TODO: consume 1 cpu cycle.
    var gprs = cpu.gprs;
    int shift = bitRange(gprs[rs], 7, 0);

    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = gprs[rm] << shift;
      cpu.shifterCarryOut = isSet(gprs[rm], 32 - shift);
    } else if (shift == 32) {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = isSet(gprs[rm], 0);
    } else {
      // shift > 32
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = false;
    }
  }

  /// Logical shift right by immediate.
  ///
  /// See [ImmediateShifterEncoding] for parameter documentation.
  static void LSRImmediate(Cpu cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = isSet(gprs[rm], 31);
    } else {
      cpu.shifterOperand = gprs[rm] >> shift;
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
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
  /// See [RegisterShifterEncoding] for parameter documentation.
  static void LSRRegister(Cpu cpu, {@required int rs, @required int rm}) {
    // TODO: consume 1 cpu cycle.
    var gprs = cpu.gprs;

    int shift = bitRange(gprs[rs], 7, 0);
    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = gprs[rm] >> shift;
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    } else if (shift == 32) {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = isSet(gprs[rm], 31);
    } else {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = false;
    }
  }

  /// Arithmetic shift right by immediate.
  ///
  /// See [ImmediateShifterEncoding] for parameter documentation.
  static void ASRImmediate(Cpu cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      if (isClear(gprs[rm], 31)) {
        cpu.shifterOperand = 0;
      } else {
        cpu.shifterOperand = uint32.max;
      }
      cpu.shifterCarryOut = int32.isNegative(gprs[rm]);
    } else {
      // shift > 0
      cpu.shifterOperand = uint32.arithmeticShiftRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
  }

  /// Arithmetic shift right by register.
  ///
  /// See [RegisterShifterEncoding] for parameter documentation.
  static void ASRRegister(Cpu cpu, {@required int rs, @required int rm}) {
    // TODO: consume 1 cpu cycle.
    var gprs = cpu.gprs;
    int shift = bitRange(gprs[rs], 7, 0);

    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = uint32.arithmeticShiftRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    } else {
      // shift >= 32
      cpu.shifterOperand = int32.isNegative(gprs[rm]) ? uint32.max : 0;
      cpu.shifterCarryOut = int32.isNegative(gprs[rm]);
    }
  }

  /// Rotate right by immediate.
  ///
  /// See [ImmediateShifterEncoding] for parameter documentation.
  static void RORImmediate(Cpu cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      // RRX
      int c = cpu.cpsr.c ? 1 : 0;
      cpu.shifterOperand = (c << 31) | (gprs[rm] >> 1);
      cpu.shifterCarryOut = isClear(gprs[rm], 0);
    } else {
      // shift > 0
      cpu.shifterOperand = rotateRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
  }

  /// Rotate right by register.
  ///
  /// See [RegisterShifterEncoding] for parameter documentation.
  static void RORRegister(Cpu cpu, {@required int rs, @required int rm}) {
    // TODO: consume 1 cpu cycle.
    var gprs = cpu.gprs;

    int shift = bitRange(gprs[rs], 7, 0);
    int shiftLSB = bitRange(gprs[rs], 4, 0); // + 1 bit.

    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shiftLSB == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = int32.isNegative(gprs[rm]);
    } else {
      cpu.shifterOperand = rotateRight(gprs[rm], shiftLSB);
      cpu.shifterCarryOut = isSet(gprs[rm], shiftLSB - 1);
    }
  }
}

/// Returns a [LazyShifter] that performs an immediate shift.
LazyShifter _lazyImmediateShifter(
  Cpu cpu,
  ImmediateShifter callback,
  int shifterOperand,
) {
  var encoding = new ImmediateShifterEncoding(shifterOperand);
  return () => callback(
        cpu,
        shift: encoding.shift,
        rm: encoding.rm,
      );
}

/// Returns a [LazyShifter] that performs a register shift.
LazyShifter _lazyRegisterShifter(
  Cpu cpu,
  RegisterShifter callback,
  int shifterOperand,
) {
  var encoding = new RegisterShifterEncoding(shifterOperand);
  return () => callback(
        cpu,
        rs: encoding.rs,
        rm: encoding.rm,
      );
}
