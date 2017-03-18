part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move Negative' Instruction.
class _ArmInstruction$MVN extends Instruction {
  /// Second operand of the instruction.
  final int op2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$MVN({
    @required ArmCondition condition,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'MVN');

  @override
  int execute(Cpu cpu) {
    if (condition.pass(cpu.cpsr)) {
      final r = cpu.gprs[rd] = (~op2).toUnsigned(32);
      if (s) {
        cpu.cpsr
          ..n = r > 0x7FFFFFFF
          ..z = r == 0;
      }
    }
    return 1;
  }
}
