part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$SBC extends Instruction {
  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$SBC({
    @required ArmCondition condition,
    @required this.s,
    @required this.rd,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'SBC');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final notCarryBit = ~(cpu.cpsr.c ? 1 : 0);
    final opResult = op1.toUnsigned(32) - op2.toUnsigned(32) - notCarryBit;
    final storedResult = gprsWrite(cpu.gprs, rd, opResult);

    if (s) {
      computePsr(cpu, rd, opResult, storedResult, op1, op2);
    }
    return 1;
  }
}
