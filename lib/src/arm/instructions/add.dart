part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Add' Instruction.
class _ArmInstruction$ADD extends Instruction {
  /// First operand of the instruction is stored here.
  final int rn;

  /// Second operand of the instruction.
  final int rop2;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$ADD({
    @required ArmCondition condition,
    @required this.rn,
    @required this.rop2,
    @required this.rd,
    @required this.s,
  })
      : super._(condition: condition, name: 'ADD');

  @override
  int execute(Cpu cpu) {
    final op1 = cpu.gprs[rn];
    final op2 = cpu.gprs[rop2];
    final r = op1.toUnsigned(32) + op2.toUnsigned(32);
    cpu.gprs[rd] = r.toUnsigned(32);
    if (s) {
      cpu.cpsr
        ..c = uint32.hasCarryBit(r)
        ..v = uint32.doesAddOverflow(op1, op2, r)
        ..n = uint32.isNegative(r)
        ..z = isZero(r);
    }
    return 1;
  }
}
