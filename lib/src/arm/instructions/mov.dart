part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move' Instruction.
class _ArmInstruction$MOV extends Instruction {
  /// Second operand of the instruction.
  final int op2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$MOV({
    @required ArmCondition condition,
    @required this.op2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'MOV');

  @override
  int execute(Cpu cpu) {
    final r = cpu.gprs[rd] = op2.toUnsigned(32);
    if (s) {
      cpu.cpsr
        ..n = r > 0x7FFFFFFF
        ..z = r == 0;
    }
    return 1;
  }
}
