part of arm7_tdmi.src.arm.condition;

class _ArmCondition$VS extends ArmCondition {
  const _ArmCondition$VS()
      : super._(
          opcode: 0x6 /*0110b*/,
          suffix: 'VS',
          flags: 'V set',
          meaning: 'overflow',
        );

  @override
  bool pass(Psr flags) => flags.v;
}
