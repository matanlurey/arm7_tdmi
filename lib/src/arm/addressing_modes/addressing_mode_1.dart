import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/format.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// A data-processing instruction's shifter operand.
/// TODO(kharland): Document when this should be executed.
typedef void ShifterOperand();

/// An encoding for a data-processing instruction's [ShifterOperand].
abstract class ShifterOperandEncoding {
  final int _shifterOperand;

  ShifterOperandEncoding(this._shifterOperand);

  int _bitRange(int start, int end) => bitRange(_shifterOperand, start, end);
}

/// A [ShifterOperandEncoding] for an immediate value with an optional rotation.
class Immediate32 extends ShifterOperandEncoding {
  @literal
  Immediate32(int shifterOperand) : super(shifterOperand);

  /// The amount to rotate [immediate] by.
  int get rotate => _bitRange(11, 8);

  /// The value to rotate.
  int get immediate => _bitRange(7, 0);
}

/// A [ShifterOperandEncoding] for an immediate value with an optional shift.
class ImmediateShiftEncoding extends ShifterOperandEncoding {
  @literal
  ImmediateShiftEncoding(int shifterOperand) : super(shifterOperand);

  /// Referred to as 'shift_imm' in the official arm docs.
  int get shift => _bitRange(11, 7);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}

/// A [ShifterOperandEncoding] for a register value with an optional shift.
class RegisterShiftEncoding extends ShifterOperandEncoding {
  @literal
  RegisterShiftEncoding(int shifterOperand) : super(shifterOperand);

  /// The address of the register containing the shift amount.
  int get rs => _bitRange(11, 8);

  /// The address of the register containing the value to be shifted.
  int get rm => _bitRange(3, 0);
}

/// ARM Addressing mode 1.
///
/// This mode generates the shifter operand values for a data-processing
/// instruction.  These auxiliary values are stored directly on the [Cpu].
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

  /// Decodes the [ShifterOperand] for [instruction].
  ///
  /// The returned operand will execute on [cpu].
  static ShifterOperand decodeShifterOperand(Cpu cpu, int instruction) {
    var format = new DataProcessingFormat(instruction);
    if (format.i) {
      var encoding = new Immediate32(format.operand2);
      return () => immediateValue(cpu,
          rotate: encoding.rotate, immediate: encoding.immediate);
    }

    int shiftType = bitRange(format.operand2, 3, 0);
    switch (shiftType) {
      case REGISTER_OR_LSL_IMM:
        return _createImmediateShifter(cpu, shiftLSLImm, format.operand2);
      case LSL_REG:
        return _createRegisterShifter(cpu, shiftLSLReg, format.operand2);
      case LSR_IMM:
        return _createImmediateShifter(cpu, shiftLSRImm, format.operand2);
      case LSR_REG:
        return _createRegisterShifter(cpu, shiftLSRReg, format.operand2);
      case ASR_IMM:
        return _createImmediateShifter(cpu, shiftASRImm, format.operand2);
      case ASR_REG:
        return _createRegisterShifter(cpu, shiftASRReg, format.operand2);
      case ROR_IMM:
        return _createImmediateShifter(cpu, shiftRORImm, format.operand2);
      case ROR_REG:
        return _createRegisterShifter(cpu, shiftRORReg, format.operand2);
    }
    throw new UnsupportedError('$instruction');
  }

  /// Provides an [immediate] operand to a data-processing instruction,
  /// optionally rotated by [rotate].
  static void immediateValue(
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
  static void shiftLSLImm(cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      // Register operand
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else {
      // shift > 0
      cpu.shifterOperand = gprs[rm] << shift;
      cpu.shifterCarryOut = isSet(gprs[rm], 32 - shift);
    }
  }

  /// Logical shift left by register.
  static void shiftLSLReg(cpu, {@required int rs, @required int rm}) {
    var gprs = cpu.gprs;

    // TODO: consume 1 cpu cycle.
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
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = false;
    }
  }

  /// Logical shift right by immediate.
  static void shiftLSRImm(cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = isSet(gprs[rm], 31);
    } else {
      cpu.shifterOperand = gprs[rm] >> shift;
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
  }

  /// Logical shift right by register.
  static void shiftLSRReg(cpu, {@required int rs, @required int rm}) {
    var gprs = cpu.gprs;

    // TODO: consume 1 cpu cycle.
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
  static void shiftASRImm(cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      if (isClear(gprs[rm], 31)) {
        cpu.shifterOperand = 0;
        cpu.shifterCarryOut = false;
      } else {
        cpu.shifterOperand = 0xFFFFFFFF;
        cpu.shifterCarryOut = true;
      }
    } else {
      cpu.shifterOperand = arithmeticShiftRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
  }

  /// Arithmetic shift right by register.
  static void shiftASRReg(cpu, {@required int rs, @required int rm}) {
    var gprs = cpu.gprs;

    // TODO: consume 1 cpu cycle.
    int shift = bitRange(gprs[rs], 7, 0);
    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = arithmeticShiftRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    } else {
      if (isClear(gprs[rm], 31)) {
        cpu.shifterOperand = 0;
        cpu.shifterCarryOut = false;
      } else {
        cpu.shifterOperand = 0xFFFFFFFF;
        cpu.shifterCarryOut = true;
      }
    }
  }

  /// Rotate right by immediate.
  static void shiftRORImm(cpu, {@required int shift, @required int rm}) {
    // TODO: consume 1 cycle
    var gprs = cpu.gprs;

    if (shift == 0) {
      // RRX
      int c = cpu.cpsr.c ? 1 : 0;
      cpu.shifterOperand = (c << 31) | (gprs[rm] >> 1);
      cpu.shifterCarryOut = isClear(gprs[rm], 0);
    } else {
      cpu.shifterOperand = rotateRight(gprs[rm], shift);
      cpu.shifterCarryOut = isSet(gprs[rm], shift - 1);
    }
  }

  /// Rotate right by register.
  static void shiftRORReg(cpu, {@required int rs, @required int rm}) {
    var gprs = cpu.gprs;

    // TODO: consume 1 cpu cycle.
    int shift = bitRange(gprs[rs], 7, 0);
    int rsLeastSignificantByte = bitRange(gprs[rs], 4, 0); // + 1 bit.
    if (shift == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (rsLeastSignificantByte == 0) {
      cpu.shifterOperand = gprs[rm];
      cpu.shifterCarryOut = isSet(gprs[rm], 31);
    } else {
      cpu.shifterOperand = rotateRight(gprs[rm], rsLeastSignificantByte);
      cpu.shifterCarryOut = isSet(gprs[rm], rsLeastSignificantByte - 1);
    }
  }
}

/// A shifter operand that executes an immediate shift.
@visibleForTesting
typedef void ImmediateShift(Cpu cpu, {int shift, int rm});

/// A shifter operand that executes a Register shift.
@visibleForTesting
typedef void RegisterShift(Cpu cpu, {int rs, int rm});

/// Returns a [ShifterOperand] that performs an [ImmediateShift].
ShifterOperand _createImmediateShifter(
  Cpu cpu,
  ImmediateShift callback,
  int shifterOperand,
) {
  var encoding = new ImmediateShiftEncoding(shifterOperand);
  return () => callback(
        cpu,
        shift: encoding.shift,
        rm: encoding.rm,
      );
}

/// Returns a [ShifterOperand] that performs a [RegisterShift].
ShifterOperand _createRegisterShifter(
  Cpu cpu,
  RegisterShift callback,
  int shifterOperand,
) {
  var encoding = new RegisterShiftEncoding(shifterOperand);
  return () => callback(
        cpu,
        rs: encoding.rs,
        rm: encoding.rm,
      );
}
