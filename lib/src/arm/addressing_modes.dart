import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';

/// An object that generates one or more values to be used by CPU instructions.
///
/// For example, addressing mode 1 generates shifterOperand and shifterCarryOut
/// values used directly by the AND instruction.  These auxiliary values may be
/// stored directly on the CPU, as is the case for addressing mode 1.
abstract class AddressingMode {
  /// Generates auxiliary values to be used directly by CPU instructions.
  void generateValues(Cpu cpu, int instruction);
}

/// ARM Addressing mode 1.
///
/// Addressing mode 1 generates values for data-processing instructions. these
/// values are stored directly on the CPU.
abstract class AddressingMode1 implements AddressingMode {
  @override
  void generateValues(Cpu cpu, int instruction) {
    // Register containing the value of the shift.
    int rs = bitRange(instruction, 11, 8);
    // Register whose value is to be shifted.
    int rm = bitRange(instruction, 3, 0);
    int shiftType = bitRange(instruction, 8, 7);

    // TODO: Assign constants to these magic numbers.
    switch (shiftType) {
      case 0x00000000:
        // LSL
        _setLogicalShiftLeftOperand(cpu, rs, rm);
        break;
      case 0x00000020:
        // LSR
        // shiftOp = this.armCompiler.constructAddressingMode1LSR(rs, rm);
        break;
      case 0x00000040:
        // ASR
        // shiftOp = this.armCompiler.constructAddressingMode1ASR(rs, rm);
        break;
      case 0x00000060:
        // ROR
        // shiftOp = this.armCompiler.constructAddressingMode1ROR(rs, rm);
        break;
    }
    throw new UnimplementedError();
  }

  /// Sets the shifter operand (and possibly the shifter carry-out) on [cpu] for
  /// a logical shift left.
  /// [rs] is the register containing the value of the shift.
  /// [rm] is the register whose value is to be shifted.
  ///
  /// CPU cycles: 1.
  void _setLogicalShiftLeftOperand(Cpu cpu, int rs, int rm) {
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
}
