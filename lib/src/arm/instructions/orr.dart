part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$ORR extends Instruction {
  const _ArmInstruction$ORR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'ORR');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
