part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$AND extends Instruction {
  /// The register containing the first operand of the instruction.
  final int rn;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$AND({
    @required ArmCondition condition,
    @required this.rn,
    @required this.shifter,
    @required this.rd,
    @required this.s,
  })
      : super._(
          condition: condition,
          name: 'AND',
        );

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final opResult = cpu.gprs[rn] & shiftValues.operand;
    final storedResult = gprsWrite(
      cpu.gprs,
      rd,
      opResult,
    );
    if (s) {
      computePsrShifter(cpu, rd, storedResult, shiftValues);
    }
    return 1;
  }
}
