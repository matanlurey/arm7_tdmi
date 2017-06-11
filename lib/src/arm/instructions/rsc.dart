part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$RSC extends Instruction {
  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$RSC({
    @required ArmCondition condition,
    @required this.s,
    @required this.rd,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'RSC');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final notCarryBit = ~btoi(cpu.cpsr.c);
    final opResult = op2.toUnsigned(32) - op1.toUnsigned(32) - notCarryBit;
    final storedResult = gprsWrite(cpu.gprs, rd, opResult);

    if (s) {
      cpu.cpsr
        ..n = int32.isNegative(opResult)
        ..z = isZero(opResult)
        ..c = opResult <= op1
        ..v = int32.doesSubOverflow(op1, op2 - notCarryBit, opResult);
    }
    return 1;
  }
}
