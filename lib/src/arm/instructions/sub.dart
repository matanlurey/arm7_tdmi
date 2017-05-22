part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Subtract' Instruction.
class _ArmInstruction$SUB extends Instruction {
  /// First operand of the operation.
  final int op1;

  /// Second operand of the operation.
  final int op2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$SUB({
    @required ArmCondition condition,
    @required this.op1,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'SUB');

  @override
  int execute(Cpu cpu) {
    final result = gprsWrite(cpu.gprs, rd, op1 - op2);
    if (s) {
      computePsr(cpu, rd, result, op1, op2);
    }
    return 1;
  }
}
