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
    var shiftValues = shifter(cpu);

    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final r = op1.toUnsigned(32) + op2.toUnsigned(32);
    cpu.gprs[rd] = r.toUnsigned(32);

    if (s) {
      cpu.cpsr
        ..n = uint32.isNegative(r)
        ..z = isZero(cpu.gprs[rd])
        ..c = uint32.hasCarryBit(r)
        ..v = uint32.doesAddOverflow(rn, op2, r);
    }
    return 1;
  }
}
