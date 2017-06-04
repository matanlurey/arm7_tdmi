part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$STR extends Instruction {
  const _ArmInstruction$STR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'STR');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
