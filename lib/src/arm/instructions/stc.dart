part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$STC extends Instruction {
  const _ArmInstruction$STC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'STC');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
