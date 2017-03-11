part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MOV extends Instruction {
  const _ArmInstruction$MOV({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MOV');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
