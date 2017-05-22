part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Add with Carry Instruction'.
class _ArmInstruction$ADC extends Instruction {
  /// First operand of the instruction.
  final int op1;

  /// Second operand of the instruction.
  final int op2;

  /// Destination register.
  final int rd;

  /// Whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$ADC({
    @required ArmCondition condition,
    @required this.op1,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'ADC');

  @override
  int execute(Cpu cpu) {
    final opResult =
        (op1.toUnsigned(32) + op2.toSigned(32) + (cpu.cpsr.c ? 1 : 0));
    final result = gprsWrite(
      cpu.gprs,
      rd,
      opResult,
    );
    if (s) {
      computePsr(cpu, rd, opResult, result, op1, op2);
    }
    return 1; // FIXME
  }
}
