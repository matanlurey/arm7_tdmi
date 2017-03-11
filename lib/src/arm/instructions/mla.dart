part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MLA extends Instruction {
  const _ArmInstruction$MLA({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MLA');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
