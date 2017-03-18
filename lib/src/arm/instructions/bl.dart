part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BL extends Instruction {
  final bool updateLinkRegister;
  // A constant value comprising the low 24-bits of the instruction.
  final int immediate;

  const _ArmInstruction$BL({
    @required ArmCondition condition,
    @required this.updateLinkRegister,
    @required this.immediate,
  })
      : super._(condition: condition, name: 'B');

  @override
  int execute(Cpu cpu) {
    if (updateLinkRegister) {
      cpu.gprs.lr = cpu.gprs.pc + 4; // next instruction address.
    }
    cpu.gprs.pc += signExtend(immediate, 24, 30) << 2;
    return 1;
  }
}
