part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SWP extends Instruction {
  const _ArmInstruction$SWP({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SWP');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
