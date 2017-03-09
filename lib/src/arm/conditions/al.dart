part of arm7_tdmi.src.arm.condition;

class _ArmCondition$AL extends ArmCondition {
  const _ArmCondition$AL()
      : super._(
          opcode: 0xE /*1110b*/,
          suffix: 'AL',
          flags: '(ignored)',
          meaning: 'always',
        );

  @override
  bool pass(_) => true;
}
