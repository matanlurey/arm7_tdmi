part of arm7_tdmi.src.arm.condition;

class _ArmCondition$LT extends ArmCondition {
  const _ArmCondition$LT()
      : super._(
          opcode: 0xB /*1011b*/,
          suffix: 'LT',
          flags: 'N not equal to V',
          meaning: 'less than',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.GE.pass(flags);
}
