part of arm7_tdmi.src.arm.compiler;

abstract class _ArmInstruction$AbstractMSR extends Instruction {
  /// True iff the SPSR is to be written.  Otherwise the CPSR is to be written.
  final bool spsr;

  /// First operand register.
  final int fieldMask;

  const _ArmInstruction$AbstractMSR({
    @required ArmCondition condition,
    @required this.spsr,
    @required this.fieldMask,
  })
      : super._(condition: condition, name: 'MSR');

  int abstractExecute(Cpu cpu, int operand, int cycleCount) {
    int mask = getBit(fieldMask, 0);
    if (!cpu.mode.isPrivileged) {
      mask = 0;
    }
    if (spsr && cpu.mode.hasSpsr) {
      if (mask == 0) {
        int t = cpu.spsr;
        t &= ~0xF0000000;
        t |= (operand & 0xF0000000);
        operand = t;
      }
      cpu.spsr = operand;
    } else {
      if (mask == 0) {
        int z = cpu.cpsr.value;
        z &= ~0xF0000000;
        z |= (operand & 0xF0000000);
        operand = z;
      }
      cpu.loadCpsr(operand);
    }

    return cycleCount;
  }
}

/// Implements the 'Move to Status Register from ARM Register' Instruction.
///
/// The operand is a rotated immediate value.
class _ArmInstruction$MSRImmediate extends _ArmInstruction$AbstractMSR {
  final int rotation;
  final int immediate;

  const _ArmInstruction$MSRImmediate({
    @required ArmCondition condition,
    @required bool spsr,
    @required int fieldMask,
    @required this.rotation,
    @required this.immediate,
  })
      : super(condition: condition, spsr: spsr, fieldMask: fieldMask);

  // TODO: Delete unpredictable blocks once tests passing.
  @override
  int execute(Cpu cpu) {
    final operand = rotateRight(immediate, rotation * 2);
    return super.abstractExecute(cpu, operand, 2);
  }

  @override
  String toDebugString() {
    throw new UnimplementedError();
  }
}

/// Implements the 'Move to Status Register from ARM Register' Instruction.
///
/// The operand comes from a register.
class _ArmInstruction$MSRRegister extends _ArmInstruction$AbstractMSR {
  final int rm;

  const _ArmInstruction$MSRRegister({
    @required ArmCondition condition,
    @required bool spsr,
    @required int fieldMask,
    @required this.rm,
  })
      : super(condition: condition, spsr: spsr, fieldMask: fieldMask);

  // TODO: Delete unpredictable blocks once tests passing.
  @override
  int execute(Cpu cpu) {
    final operand = cpu.gprs[rm];
    return super.abstractExecute(cpu, operand, 1);
  }

  @override
  String toDebugString() {
    throw new UnimplementedError();
  }
}
