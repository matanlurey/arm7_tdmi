part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SMLAL extends Instruction {
  const _ArmInstruction$SMLAL({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SMLAL');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
