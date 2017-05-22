part of arm7_tdmi.src.arm.compiler;

/// Implements the 'Branch' instructions.
class _ArmInstruction$B extends Instruction {
  final int immediate;

  const _ArmInstruction$B({
    @required ArmCondition condition,
    @required this.immediate,
  })
      : super._(condition: condition, name: 'B');

  @override
  int execute(Cpu cpu) {
    cpu.gprs.pc += signExtend(immediate, 24, 30) << 2;
    return 3;
  }

  @override
  String toDebugString() {
    final buffer = new StringBuffer('B');
    if (condition != ArmCondition.AL) {
      buffer.write('{$condition}');
    }
    buffer.write(' 0x${immediate.toRadixString(16)}');
    return buffer.toString();
  }
}
