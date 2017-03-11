part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$TEQ extends Instruction {
  const _ArmInstruction$TEQ({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'TEQ');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
