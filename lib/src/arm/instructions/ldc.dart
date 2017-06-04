part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$LDC extends Instruction {
  const _ArmInstruction$LDC({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'LDC');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
