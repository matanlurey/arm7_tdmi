part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$CMN extends Instruction {
  const _ArmInstruction$CMN({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'CMN');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
