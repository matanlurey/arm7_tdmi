part of arm7_tdmi.src.arm.condition;

class _ArmCondition$CS extends ArmCondition {
  const _ArmCondition$CS()
      : super._(
          opcode: 0x2 /*0010b*/,
          suffix: 'CS',
          flags: 'C set',
          meaning: 'unsigned higher or same',
        );

  @override
  bool pass(Psr flags) => flags.c;
}
