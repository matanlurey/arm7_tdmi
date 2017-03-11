part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BX extends Instruction {
  const _ArmInstruction$BX({
    @required ArmCondition condition,
  })
      : super._(condition: condition, name: 'BX');

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
