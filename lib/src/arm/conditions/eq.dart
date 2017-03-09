part of arm7_tdmi.src.arm.condition;

class _ArmCondition$EQ extends ArmCondition {
  const _ArmCondition$EQ()
      : super._(
          opcode: 0x0 /*0000b*/,
          suffix: 'EQ',
          flags: 'Z set',
          meaning: 'equal',
        );

  @override
  bool pass(Psr flags) => flags.z;
}
