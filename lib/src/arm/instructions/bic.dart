part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BIC extends Instruction {
  const _ArmInstruction$BIC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'BIC');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
