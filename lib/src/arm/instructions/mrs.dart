part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MRS extends Instruction {
  const _ArmInstruction$MRS({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MRS');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
