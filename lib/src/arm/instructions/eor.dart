part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$EOR extends Instruction {
  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$EOR({
    @required ArmCondition condition,
    @required this.s,
    @required this.rd,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'EOR');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final opResult = op1.toUnsigned(32) ^ op2.toUnsigned(32);
    final storedResult = gprsWrite(cpu.gprs, rd, opResult);

    if (s) {
      computePsrShifter(cpu, rd, storedResult, shiftValues);
    }
    return 1;
  }
}
