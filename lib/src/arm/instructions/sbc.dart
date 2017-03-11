part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SBC extends Instruction {
  const _ArmInstruction$SBC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SBC');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
