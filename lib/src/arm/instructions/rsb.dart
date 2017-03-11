part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$RSB extends Instruction {
  const _ArmInstruction$RSB({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'RSB');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
