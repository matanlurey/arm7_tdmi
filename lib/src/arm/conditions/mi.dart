part of arm7_tdmi.src.arm.condition;

class _ArmCondition$MI extends ArmCondition {
  const _ArmCondition$MI()
      : super._(
          opcode: 0x4 /*0100b*/,
          suffix: 'MI',
          flags: 'N set',
          meaning: 'negative',
        );

  @override
  bool pass(Psr flags) => flags.n;
}
