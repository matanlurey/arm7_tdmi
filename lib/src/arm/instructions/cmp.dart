part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$CMP extends Instruction {
  /// First operand register.
  final int rn;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$CMP({
    @required ArmCondition condition,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'CMP');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final opResult = op1.toUnsigned(32) - op2.toUnsigned(32);

    cpu.cpsr
      ..n = int32.isNegative(opResult)
      ..z = isZero(opResult)
      ..c = opResult <= op1
      ..v = int32.doesSubOverflow(op1, op2, opResult);
    return 1;
  }
}
