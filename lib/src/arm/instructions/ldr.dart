part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$LDR extends Instruction {
  const _ArmInstruction$LDR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'LDR');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
