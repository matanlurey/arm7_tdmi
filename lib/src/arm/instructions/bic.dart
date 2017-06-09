part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BIC extends Instruction {
  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Determines whether the instruction updates the CPSR.
  final bool cpsr;

  const _ArmInstruction$BIC({
    @required ArmCondition condition,
    @required this.shifter,
    @required this.rd,
    @required this.rn,
    @required this.cpsr,
  })
      : super._(condition: condition, name: 'BIC');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final result = gprsWrite(cpu.gprs, rd, cpu.gprs[rn] & ~shiftValues.operand);

    if (cpsr) {
      computePsrShifter(cpu, rd, result, shiftValues);
    }
    return 1;
  }
}
