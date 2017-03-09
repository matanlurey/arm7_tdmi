part of arm7_tdmi.src.arm.condition;

class _ArmCondition$GE extends ArmCondition {
  const _ArmCondition$GE()
      : super._(
          opcode: 0xA /*1010b*/,
          suffix: 'GE',
          flags: 'N equals V',
          meaning: 'greater or equal',
        );

  @override
  bool pass(Psr flags) => flags.n == flags.v;
}
