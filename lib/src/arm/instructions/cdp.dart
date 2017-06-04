part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$CDP extends Instruction {
  const _ArmInstruction$CDP({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'CDP');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
