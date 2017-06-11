part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$STM extends Instruction {
  const _ArmInstruction$STM({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'STM');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
