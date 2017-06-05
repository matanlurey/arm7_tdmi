part of arm7_tdmi.src.arm.compiler;

/// Implements the 'LDR' Instruction.
class _ArmInstruction$LDR extends Instruction {
  /// The destination register.
  final int rd;

  /// Computes the address to load data from.
  final AddressComputation address;

  /// True iff this instruction loads a byte (bit 22 is set). Otherwise it loads
  /// a 32-bit word.
  final bool isByte;

  const _ArmInstruction$LDR({
    @required ArmCondition condition,
    @required this.rd,
    @required this.address,
    @required this.isByte,
  })
      : super._(condition: condition, name: isByte ? 'LDRB' : 'LDR');

  @override
  int execute(Cpu cpu) {
    final cycleCount = rd == Registers.PC ? 5 : 3;

    try {
      cpu.gprs[rd] = isByte
          ? throw new UnimplementedError(name)
          : cpu.read32(address(cpu));
    } on MemoryException catch (_) {
      cpu.raise(ArmException.dataAbort);
    } 

    return cycleCount;
  }
}
