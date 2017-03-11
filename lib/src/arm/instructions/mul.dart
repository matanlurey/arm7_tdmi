part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MUL extends Instruction {
  const _ArmInstruction$MUL({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MUL');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
