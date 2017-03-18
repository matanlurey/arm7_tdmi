part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BL extends Instruction {
  // A constant value comprising the low 24-bits of the instruction.
  final int immediate;

  const _ArmInstruction$BL({
    @required ArmCondition condition,
    @required this.immediate,
  })
      : super._(condition: condition, name: 'B');

  @override
  int execute(Cpu cpu) {
    // Store next instruction address in link register.
    cpu.gprs.lr = cpu.gprs.pc + 4;
    cpu.gprs.pc += signExtend(immediate, 24, 30) << 2;
    return 1;
  }
}
