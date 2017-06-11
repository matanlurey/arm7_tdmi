part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Add with Carry Instruction'.
class _ArmInstruction$ADC extends Instruction {
  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Whether the instruction updates the CPSR.
  final bool s;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$ADC({
    @required ArmCondition condition,
    @required this.s,
    @required this.rd,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'ADC');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final opResult =
        op1.toUnsigned(32) + op2.toSigned(32) + (cpu.cpsr.c ? 1 : 0);
    final storedResult = gprsWrite(cpu.gprs, rd, opResult);

    if (s) {
      computePsrShifter(cpu, rd, storedResult, shiftValues);
    }
    return 1;
  }
}
