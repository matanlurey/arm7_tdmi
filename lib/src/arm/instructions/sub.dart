part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Subtract' Instruction.
class _ArmInstruction$SUB extends Instruction {
  /// Destination register.
  final int rd;

  /// First operand register.
  final int rn;

  /// Determines whether the instruction updates the CPSR.
  final bool s;

  /// Provides this instruction's second operand.
  final Shifter shifter;

  const _ArmInstruction$SUB({
    @required ArmCondition condition,
    @required this.s,
    @required this.rd,
    @required this.rn,
    @required this.shifter,
  })
      : super._(condition: condition, name: 'SUB');

  @override
  int execute(Cpu cpu) {
    final shiftValues = shifter(cpu);
    final op1 = cpu.gprs[rn];
    final op2 = shiftValues.operand;
    final opResult = op1.toUnsigned(32) - op2.toUnsigned(32);
    final storedResult = gprsWrite(cpu.gprs, rd, opResult);

    if (s) {
      cpu.cpsr
        ..n = int32.isNegative(storedResult)
        ..z = isZero(storedResult)
        // TODO: Investigate why `NOT BorrowFrom` function in arm docs is
        // implemented this way in https://github.com/smiley22/ARM.JS/blob/\
        // gh-pages/Simulator/Cpu.ts#L802
        ..c = storedResult <= opResult
        ..v = int32.doesSubOverflow(op1, op2, opResult);
    }
    return 1;
  }
}
