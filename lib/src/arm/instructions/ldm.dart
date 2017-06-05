part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$LDM extends Instruction {
  const _ArmInstruction$LDM({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'LDM');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
