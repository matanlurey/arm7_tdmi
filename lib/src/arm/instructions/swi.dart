part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SWI extends Instruction {
  const _ArmInstruction$SWI({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SWI');

  @override
  int execute(Cpu cpu) {
    cpu.raise(ArmException.softwareInterrupt);
    return 3;
  }
}
