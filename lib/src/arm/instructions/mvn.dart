part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MVN extends Instruction {
  const _ArmInstruction$MVN({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MVN');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
