part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BL extends Instruction {
  const _ArmInstruction$BL({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'BL');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
