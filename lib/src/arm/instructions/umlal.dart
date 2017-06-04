part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$UMLAL extends Instruction {
  const _ArmInstruction$UMLAL({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'UMLAL');

  @override
  dynamic noSuchMethod(_) => super.noSuchMethod(_);
}
