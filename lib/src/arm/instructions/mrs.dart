part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move PSR to General-Purpose Register' Instruction.
class _ArmInstruction$MRS extends Instruction {
  /// Destination register.
  final int rd;

  /// Whether to move the SPSR, otherwise the CPSR is used.
  final bool spsr;

  const _ArmInstruction$MRS({
    @required ArmCondition condition,
    @required this.rd,
    @required this.spsr,
  })
      : super._(condition: condition, name: 'MRS');

  @override
  int execute(Cpu cpu) {
    if (condition.pass(cpu.cpsr)) {
      cpu.gprs[rd] = spsr ? cpu.spsr.value : cpu.cpsr.value;
    }
    return 1;
  }
}
