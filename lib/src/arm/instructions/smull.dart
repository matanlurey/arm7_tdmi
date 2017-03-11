part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SMULL extends Instruction {
  const _ArmInstruction$SMULL({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SMULL');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
