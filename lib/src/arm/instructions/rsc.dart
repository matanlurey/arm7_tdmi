part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$RSC extends Instruction {
  const _ArmInstruction$RSC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'RSC');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
