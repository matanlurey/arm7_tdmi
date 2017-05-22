part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move' Instruction.
class _ArmInstruction$MOV extends Instruction {
  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$MOV({
    @required ArmCondition condition,
    @required this.shifter,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'MOV');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op2 = shiftValues.operand;
    final result = gprsWrite(cpu.gprs, rd, op2);
    if (s) {
      computePsrShifter(cpu, rd, result, shiftValues);
    }
    return 1;
  }
}
