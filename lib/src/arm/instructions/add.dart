part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$ADD extends Instruction {
  const _ArmInstruction$ADD({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'ADD');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
