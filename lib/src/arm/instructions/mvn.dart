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
    final shifterValues = shifter(cpu);
    final op2 = shifterValues.operand;
    final result = gprsWrite(cpu.gprs, rd, ~op2);
    if (s) {
      computePsrShifter(cpu, rd, result, shifterValues);
    }
    return 1;
  }

  @override
  String toDebugString() {
    final buffer = new StringBuffer('MVN');
    if (condition != ArmCondition.AL) {
      buffer.write('{$condition}');
    }
    if (s) {
      buffer.write('{S}');
    }
    buffer.write(' Rd=$rd, Op2=<Shifter>');
    return buffer.toString();
  }
}
