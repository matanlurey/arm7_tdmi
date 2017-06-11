part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Move PSR to General-Purpose Register' Instruction.
class _ArmInstruction$MRS extends Instruction {
  /// Whether to move the SPSR, otherwise the CPSR is used.
  final bool spsr;

  /// Destination register.
  final int rd;

  const _ArmInstruction$MRS({
    @required ArmCondition condition,
    @required this.spsr,
    @required this.rd,
  })
      : super._(condition: condition, name: 'MRS');

  @override
  int execute(Cpu cpu) {
    if (spsr) {
      if (cpu.mode.hasSpsr) {
        gprsWrite(cpu.gprs, rd, cpu.spsr);
      }
      // else unpredictable.
    } else {
      gprsWrite(cpu.gprs, rd, cpu.cpsr.value);
    }
    return 1;
  }
}
