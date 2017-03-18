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
    if (condition.pass(cpu.cpsr)) {
      final r = cpu.gprs[rd] = (op1 - op2).toUnsigned(32);
      if (s) {
        cpu.cpsr
          ..c = r > 0xFFFFFFFF
          ..v = (~(op1 ^ op2) & (op1 ^ r)) > 0x7FFFFFFF
          ..n = r > 0x7FFFFFFF
          ..z = r == 0;
      }
    }
    return 1;
  }
}
