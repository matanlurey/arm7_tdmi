part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MCR extends Instruction {
  const _ArmInstruction$MCR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MCR');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
