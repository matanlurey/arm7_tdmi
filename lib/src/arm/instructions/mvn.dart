part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move Negative' Instruction.
class _ArmInstruction$MVN extends Instruction {
  /// Provides this instruction's second operand.
  final Shifter shifter;

  /// Destination register.
  final int rd;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  const _ArmInstruction$MVN({
    @required ArmCondition condition,
    @required this.shifter,
    @required this.rd,
    @required this.s,
  })
      : super._(
          condition: condition,
          name: 'MVN',
        );

  @override
  int execute(Cpu cpu) {
    var shifterValues = shifter(cpu);
    final op2 = shifterValues.operand;
    final r = cpu.gprs[rd] = (~op2).toUnsigned(32);

    if (s) {
      cpu.cpsr
        ..n = int32.isNegative(r)
        ..z = isZero(r)
        ..c = shifterValues.carryOut;
    }
    return 1;
  }
}
