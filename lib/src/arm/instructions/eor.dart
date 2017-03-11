part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$EOR extends Instruction {
  const _ArmInstruction$EOR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'EOR');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
