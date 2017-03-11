part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SUB extends Instruction {
  const _ArmInstruction$SUB({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'SUB');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
