part of arm7_tdmi.src.arm.compiler;

abstract class _ArmInstruction$AbstractMSR extends Instruction {
  // Bit mask constants defined in Table A4-1, under MSR instruction docs.
  static const _unallocMask = 0x0FFFFF00;
  static const _userMask = 0xF0000000;
  static const _privMask = 0x0000000F;
  static const _stateMask = 0x00000020;

  /// True iff the SPSR is to be written.  Otherwise the CPSR is to be written.
  final bool spsr;

  /// First operand register.
  final int fieldMask;

  const _ArmInstruction$AbstractMSR({
    @required ArmCondition condition,
    @required this.spsr,
    @required this.fieldMask,
  })
      : super._(condition: condition, name: 'MSR');

  int abstractExecute(Cpu cpu, int operand, int cycleCount) {
    String printWordB(int i) => i.toRadixString(2).padLeft(32, '0');
    String printWordH(int i) => i.toRadixString(16).padLeft(8, '0');

    int a = fieldMask & 0x1;
    if (!cpu.mode.isPrivileged) {
      a = 0;
    }
    if (spsr && cpu.mode.hasSpsr) {
      if (a == 0) {
        int t = cpu.spsr;
        t &= ~0xF0000000;
        t |= (operand & 0xF0000000);
        operand = t;
      }
      cpu.loadSpsr(operand);
    } else {
      if (a == 0) {
        int z = cpu.cpsr.value;
        z &= ~0xF0000000;
        z |= (operand & 0xF0000000);
        operand = z;
      }
      cpu.loadCpsr(operand);
    }

//    final byteMask = 0 |
//        (isSet(fieldMask, 0) ? 0x000000FF : 0) |
//        (isSet(fieldMask, 1) ? 0x0000FF00 : 0) |
//        (isSet(fieldMask, 2) ? 0x00FF0000 : 0) |
//        (isSet(fieldMask, 3) ? 0xFF000000 : 0);
//    int mask;
//    if (!spsr) {
//      if (cpu.mode.isPrivileged) {
//        if (!isZero(operand & _stateMask)) {
//          /* unpredictable */
//          return cycleCount;
//        } else {
//          mask = byteMask & (_userMask | _privMask);
//        }
//      } else {
//        mask = byteMask & _userMask;
//      }
//      cpu.loadCpsr((cpu.cpsr.value & ~mask) | (operand & mask));
//    } else {
//      // spsr == true
//      if (cpu.mode.hasSpsr) {
//        mask = byteMask & (_userMask | _privMask | _stateMask);
//        cpu.spsr.value = (cpu.spsr.value & ~mask) | (operand & mask);
//      } else {
//        /* Unpredictable */
//      }
//    }
    return cycleCount;
  }
}

/// Implements the 'Move to Status Register from ARM Register' Instruction.
///
/// The operand is a rotated immediate value.
class _ArmInstruction$MSRImmediate extends _ArmInstruction$AbstractMSR {
  final int rotation;
  final int immediate;

  const _ArmInstruction$MSRImmediate({
    @required ArmCondition condition,
    @required bool spsr,
    @required int fieldMask,
    @required this.rotation,
    @required this.immediate,
  })
      : super(condition: condition, spsr: spsr, fieldMask: fieldMask);

  // TODO: Delete unpredictable blocks once tests passing.
  @override
  int execute(Cpu cpu) {
    final operand = rotateRight(immediate, rotation * 2);
    return super.abstractExecute(cpu, operand, 2);
  }

  @override
  String toDebugString() {
    throw new UnimplementedError();
  }
}

/// Implements the 'Move to Status Register from ARM Register' Instruction.
///
/// The operand comes from a register.
class _ArmInstruction$MSRRegister extends _ArmInstruction$AbstractMSR {
  final int rm;

  const _ArmInstruction$MSRRegister({
    @required ArmCondition condition,
    @required bool spsr,
    @required int fieldMask,
    @required this.rm,
  })
      : super(condition: condition, spsr: spsr, fieldMask: fieldMask);

  // TODO: Delete unpredictable blocks once tests passing.
  @override
  int execute(Cpu cpu) {
    final operand = cpu.gprs[rm];
    return super.abstractExecute(cpu, operand, 1);
  }

  @override
  String toDebugString() {
    throw new UnimplementedError();
  }
}
