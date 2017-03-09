part of arm7_tdmi.src.arm.condition;

class _ArmCondition$LS extends ArmCondition {
  const _ArmCondition$LS()
      : super._(
          opcode: 0x9 /*1001b*/,
          suffix: 'LS',
          flags: 'C clear or Z set',
          meaning: 'unsigned lower or same',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.HI.pass(flags);
}
