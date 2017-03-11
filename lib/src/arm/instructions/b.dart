part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$B extends Instruction {
  const _ArmInstruction$B({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'B');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
