part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$TST extends Instruction {
  /// First operand register.
  final int rn;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$TST({
    @required ArmCondition condition,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'TST');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final opResult = op1.toUnsigned(32) & op2.toUnsigned(32);

    // Can't use `computePsr` because there's no destination register.
    cpu.cpsr
      ..n = int32.isNegative(opResult)
      ..z = isZero(op1)
      ..c = shiftValues.carryOut;

    return 1;
  }
}
