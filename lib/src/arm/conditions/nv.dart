part of arm7_tdmi.src.arm.condition;

class _ArmCondition$NV extends ArmCondition {
  const _ArmCondition$NV()
      : super._(
          opcode: 0xF /*1111b*/,
          suffix: 'NV',
          flags: '(undefined)',
          meaning: 'never',
        );

  @override
  bool pass(Psr flags) => !ArmCondition.AL.pass(flags);
}
