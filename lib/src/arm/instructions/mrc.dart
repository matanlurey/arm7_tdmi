part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MRC extends Instruction {
  const _ArmInstruction$MRC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MRC');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
