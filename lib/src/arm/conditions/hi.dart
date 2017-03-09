part of arm7_tdmi.src.arm.condition;

class _ArmCondition$HI extends ArmCondition {
  const _ArmCondition$HI()
      : super._(
          opcode: 0x8 /*1000b*/,
          suffix: 'HI',
          flags: 'C set and Z clear',
          meaning: 'unsigned higher',
        );

  @override
  bool pass(Psr flags) => flags.c && !flags.z;
}
