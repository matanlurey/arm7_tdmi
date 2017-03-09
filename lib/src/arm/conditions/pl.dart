part of arm7_tdmi.src.arm.condition;

class _ArmCondition$PL extends ArmCondition {
  const _ArmCondition$PL()
      : super._(
          opcode: 0x5 /*0101b*/,
          suffix: 'PL',
          flags: 'N clear',
          meaning: 'positive or zero',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.MI.pass(flags);
}
