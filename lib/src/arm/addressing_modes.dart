import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// Helpers for generating one or more values to be used by CPU instructions.
///
/// For example, addressing mode 1 generates shifter operand and shift carry out
/// values used directly by the AND instruction.  The generated values may be
/// stored directly on the CPU, as is the case for addressing mode 1.

/// ARM Addressing mode 1.
///
/// Addressing mode 1 generates values for data-processing instructions. these
/// values are stored directly on the CPU.
abstract class AddressingMode1 {
  @visibleForTesting
  static const LOGICAL_SHIFT_LEFT = 0x00000000;

  @visibleForTesting
  static const LOGICAL_SHIFT_RIGHT = 0x00000020;

  @visibleForTesting
  static const ARITHMETIC_SHIFT_RIGHT = 0x00000040;

  @visibleForTesting
  static const ROTATE_RIGHT = 0x00000060;

  static void generateValues(Cpu cpu, int instruction) {
    // Register containing the value of the shift.
    int rs = bitRange(instruction, 11, 8);
    // Register whose value is to be shifted.
    int rm = bitRange(instruction, 3, 0);
    int shiftType = instruction & 0x60;

    // TODO: Assign constants to these magic numbers.
    switch (shiftType) {
      case LOGICAL_SHIFT_LEFT:
        _generateLSL(cpu, rs, rm);
        return;
      case LOGICAL_SHIFT_RIGHT:
        _generateLSR(cpu, rs, rm);
        return;
      case ARITHMETIC_SHIFT_RIGHT:
        _generateArithmeticShiftRightOperands();
        return;
      case ROTATE_RIGHT:
        _generateRotateRightOperands();
        return;
    }
    throw new UnimplementedError();
  }

  /// Sets the shifter operand and shifter carry-out for a logical shift left.
  ///
  /// [rs] is the register containing the value of the shift. [rm] is the
  /// register whose value is to be shifted.
  ///
  /// CPU cycles: 1.
  static void _generateLSL(Cpu cpu, int rs, int rm) {
    var gprs = cpu.gprs;
    int shift = gprs[rs];
    int valueToShift = gprs[rm];

    // TODO: consume 1 cpu cycle.

    if (rs == Registers.PC) {
      shift += 4;
    }
    shift = bitRange(shift, 7, 0);
    if (rm == Registers.PC) {
      valueToShift += 4;
    }

    if (shift == 0) {
      cpu.shifterOperand = valueToShift;
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = valueToShift << shift;
      cpu.shifterCarryOut = isSet(valueToShift, 32 - shift);
    } else if (shift == 32) {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = isSet(valueToShift, 0);
    } else {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = false;
    }
  }

  /// Sets the shifter operand and shifter carry-out for a logical shift right.
  ///
  /// [rs] is the register containing the value of the shift. [rm] is the
  /// register whose value is to be shifted.
  ///
  /// CPU cycles: 1.
  static void _generateLSR(Cpu cpu, int rs, int rm) {
    var gprs = cpu.gprs;
    int shift = gprs[rs];
    int valueToShift = gprs[rm];

    // TODO: consume 1 cpu cycle.

    if (rs == Registers.PC) {
      shift += 4;
    }
    shift = bitRange(shift, 7, 0);
    if (rm == Registers.PC) {
      valueToShift += 4;
    }

    if (shift == 0) {
      cpu.shifterOperand = valueToShift;
      cpu.shifterCarryOut = cpu.cpsr.c;
    } else if (shift < 32) {
      cpu.shifterOperand = valueToShift >> shift;
      cpu.shifterCarryOut = valueToShift & (1 << (shift - 1)) == 1;
    } else if (shift == 32) {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = isSet(valueToShift, 31);
    } else {
      cpu.shifterOperand = 0;
      cpu.shifterCarryOut = false;
    }
  }

  static void _generateArithmeticShiftRightOperands() {}

  static void _generateRotateRightOperands() {}
}
