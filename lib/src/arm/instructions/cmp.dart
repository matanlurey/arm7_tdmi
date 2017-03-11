part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$CMP extends Instruction {
  const _ArmInstruction$CMP({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'CMP');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
