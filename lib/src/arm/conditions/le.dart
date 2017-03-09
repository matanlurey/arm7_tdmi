part of arm7_tdmi.src.arm.condition;

class _ArmCondition$LE extends ArmCondition {
  const _ArmCondition$LE()
      : super._(
          opcode: 0xD /*1101b*/,
          suffix: 'LE',
          flags: 'Z clear OR (N not equal to V)',
          meaning: 'less than or equal',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.GT.pass(flags);
}
