part of arm7_tdmi.src.arm.condition;

class _ArmCondition$NE extends ArmCondition {
  const _ArmCondition$NE()
      : super._(
          opcode: 0x1 /*0001b*/,
          suffix: 'NE',
          flags: 'Z clear',
          meaning: 'not equal',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.EQ.pass(flags);
}
