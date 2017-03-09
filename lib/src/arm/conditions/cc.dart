part of arm7_tdmi.src.arm.condition;

class _ArmCondition$CC extends ArmCondition {
  const _ArmCondition$CC()
      : super._(
          opcode: 0x3 /*0011b*/,
          suffix: 'CC',
          flags: 'C clear',
          meaning: 'unsigned lower',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.CS.pass(flags);
}
