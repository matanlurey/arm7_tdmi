part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Add' Instruction.
class _ArmInstruction$ADD extends Instruction {
  /// The register containing the first operand of the instruction.
  final int rn;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$ADD({
    @required ArmCondition condition,
    @required this.rn,
    @required this.shifter,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'ADD');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final result = gprsWrite(
      cpu.gprs,
      rd,
      op1.toUnsigned(32) + op2.toUnsigned(32),
    );
    if (s) {
      computePsr(cpu, rd, result, op1, op2);
    }
    return 1;
  }
}
