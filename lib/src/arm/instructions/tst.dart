part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$TST extends Instruction {
  const _ArmInstruction$TST({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'TST');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
