part of arm7_tdmi.src.arm.condition;

class _ArmCondition$VC extends ArmCondition {
  const _ArmCondition$VC()
      : super._(
          opcode: 0x7 /*0111b*/,
          suffix: 'VC',
          flags: 'V clear',
          meaning: 'no overflow',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.VS.pass(flags);
}
