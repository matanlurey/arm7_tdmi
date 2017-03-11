part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$MSR extends Instruction {
  const _ArmInstruction$MSR({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'MSR');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
