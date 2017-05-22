part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BX extends Instruction {
  /// The low 4 bits of the instruction.
  ///
  /// This value represents the branch target address.  If bit 0 is 0, we select
  /// a thumb instruction, else we select an arm instruction.
  final int operand;

  const _ArmInstruction$BX({
    @required ArmCondition condition,
    @required this.operand,
  })
      : super._(condition: condition, name: 'BX');

  @override
  int execute(Cpu cpu) {
    cpu.cpsr.isThumbState = isSet(operand, 0);
    // Get next instruction address by masking without operand[0].
    cpu.gprs.pc = operand & 0xFFFFFFFE;
    return 1;
  }
}
