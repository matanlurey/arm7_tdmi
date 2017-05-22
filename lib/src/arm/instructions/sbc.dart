part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SBC extends Instruction {
  /// First operand of the operation.
  final int op1;

  /// Second operand of the operation.
  final int op2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$SBC({
    @required ArmCondition condition,
    @required this.op1,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'SBC');

  @override
  int execute(Cpu cpu) {
    final opResult = op1 - op2 - (cpu.cpsr.c ? 1 : 0);
    final result = gprsWrite(cpu.gprs, rd, opResult);
    if (s) {
      computePsr(cpu, rd, opResult, result, op1, op2);
    }
    return 1;
  }
}
