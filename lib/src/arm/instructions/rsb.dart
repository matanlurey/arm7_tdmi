part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$RSB extends Instruction {
  /// First operand of the operation.
  final int op1;

  /// Second operand of the operation.
  final int op2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$RSB({
    @required ArmCondition condition,
    @required this.op1,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'RSB');

  @override
  int execute(Cpu cpu) {
    // TODO: Optimize.
    return new _ArmInstruction$SUB(
      condition: condition,
      op1: op2,
      op2: op1,
      rd: rd,
      s: s,
    )
        .execute(cpu);
  }
}
