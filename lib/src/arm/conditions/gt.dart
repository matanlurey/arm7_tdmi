part of arm7_tdmi.src.arm.condition;

class _ArmCondition$GT extends ArmCondition {
  const _ArmCondition$GT()
      : super._(
          opcode: 0xC /*1100b*/,
          suffix: 'GT',
          flags: 'Z clear AND (N equals V)',
          meaning: 'greater than',
        );

  @override
  bool pass(Psr flags) => !flags.z && (flags.n == flags.v);
}
