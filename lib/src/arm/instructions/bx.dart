part of arm7_tdmi.src.arm.compiler;

class _ArmInstruction$BX extends Instruction {
  final int offset;

  const _ArmInstruction$BX({
    @required ArmCondition condition,
    @required this.offset,
  })
      : super._(condition: condition, name: 'BX');

  @override
  int execute(Cpu cpu) {
    cpu.gprs.lr = cpu.gprs.pc - 4;
    cpu.gprs.pc += offset;
    return 3;
  }
}
