import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// A 32-bit CPU Emulator for the ARM7/TDMI Processor.
///
/// ## Fast execution
///
/// Depending on the CPU state, all opcodes are sized either 32-bit or 16-bit
/// (that's counting both the opcode bits and its parameters bits) providing
/// fast decoding and execution.
///
/// ## Data formats
///
/// The CPU manages to deal with 8bit, 16bit, and 32bit data, that are called:
///
/// * 8-bit - `Byte`
/// * 16-bit - `Half-word`
/// * 32-bit - `Word`
///
/// ## Two CPU states
///
/// As mentioned above, two CPU states exist:
///
/// * `ARM` state: Uses the full 32-bit instruction set (32-bit opcodes)
/// * `THUMB` state: Uses a cutdown 16-bit instruction set (16-bit opcodes)
///
/// Regardless of the opcode-width, both states are using 32-bit registers,
/// allowing 32-bit memory addressing as well as 32-bit arithmetic/logic.
///
/// ### When to use `ARM` State
///
/// Two advantages to using `ARM`:
///
/// * Each single opcode provides more functionality, resulting in faster
///   execution when using a 32-bit bus memory system (such like opcodes stored
///   in GBA Work RAM).
/// * All registers R0-R15 can be accessed directly.
///
/// The downsides are:
///
/// * Not so fast when using 16-bit memory system (but it still works).
/// * Program code occupies more memory space.
///
/// ### When to use `THUMB` state
///
/// Two advantages to using `THUMB`:
///
/// * Faster execution up to approximately 160% when using 16-bit bus memory
///   system (such like opcodes stored in GBA GamePak ROM).
/// * Reduces code size, decreases memory overload down to approximately 65%.
///
/// The downsides are:
///
/// * Not as mulit-functional opcodes as in `ARM` state, so it will be sometimes
///   required to use more than one opcode to gain a similar result as for a
///   single opcode in `ARM` state.
/// * Most opcodes only allow registers R0-R7 to used directly.
///
/// ## Combining both `ARM` and `THUMB` state
///
/// Switching between `ARM` and `THUMB` state is done by a normal branch (`BX`)
/// instruction which takes only a handful of cycles to execute (allowing to
/// change states as often as desired - with almost no overload).
///
/// Also, as both `ARM` and `THUMB` are using the same register set, it is
/// possible to pass data between `ARM` and `THUMB` mode very easily.
///
/// The best memory and execution performance can be gained by combining both
/// states: `THUMB` for normal program code, and `ARM` code for timing critical
/// subroutines (such like interrupt handlers, or complicated algorithms).
///
/// **Note**: `ARM` and `THUMB` code cannot be executed simultaneously.
///
/// ## Automatic state changes
///
/// Beside for the above manual state switching by using `BX` instructions, th
/// following situations involve automatic state changes:
///
/// * CPU switches to ARM state when executing an exception
/// * User switches back to old state when leaving an exception
class Cpu {
  final ArmDecoder _decoder;
  final Registers _registers;
  final Func1<int, int> _read16;
  final Func1<int, int> _read32;

  factory Cpu({
    ArmDecoder decoder: const ArmDecoder(),
    @required int read16(int address),
    @required int read32(int address),
  }) =>
      new Cpu._(
        decoder,
        new Registers(),
        read16,
        read32,
      );

  @visibleForTesting
  factory Cpu.noExecution({
    ArmDecoder decoder: const ArmDecoder(),
  }) =>
      new Cpu(
        decoder: decoder,
        read16: (_) => throw new UnsupportedError('No execution supported'),
        read32: (_) => throw new UnsupportedError('No execution supported'),
      );

  Cpu._(
    this._decoder,
    this._registers,
    this._read16,
    this._read32,
  );

  /// An auxiliary literal for data-processing in addressing mode 1.  The
  /// shifter operand takes one of three formats:
  /// 1. Immediate operand - formed by rotating an 8-bit constant in a 32-bit
  ///    word by an even number of bits (in the range 0-30).  Therefore, each
  ///    instruction contains an 8-bit constant and a 4-bit rotate to be applied
  ///    to that constant.
  /// 2. A register operand value is simply the value of a register. The value
  ///    of the register is used directly as the operand to the data-processing
  ///    instruction.
  /// 3. A shifted register operand value is the value of a register, shifted
  ///    (or rotated) before it is used as the data-processing operand. There
  ///    are five types of shift:
  ///    - ASR Arithmetic shift right.
  ///    - LSL Logical shift left.
  ///    - LSR Logical shift right.
  ///    - ROR Rotate right.
  ///    - RRX Rotate right with extend.
  int shifterOperand;

  /// Jesus fuck so much docs.
  bool shifterCarryOut;

  /// GPRS.
  Registers get gprs => _registers;

  /// CPSR.
  Psr get cpsr => _registers.cpsr;

  /// SPSR.
  Psr get spsr => _registers.spsr;

  /// Whether the CPU is currently executing as ARM.
  bool get isArm => _registers.cpsr.isArmState;

  /// Whether the CPU is currently executing as THUMB.
  bool get isThumb => _registers.cpsr.isThumbState;

  /// Whether FIQ is disabled.
  bool get isFiqDisabled => _registers.cpsr.f;

  /// Whether IRQ is disabled.
  bool get isIrqDisabled => _registers.cpsr.i;

  /// Operating mode.
  Mode get mode => _registers.cpsr.mode;

  /// Program counter for the CPU.
  int get pc => _registers.pc;

  /// Raise a CPU-level [exception].
  void raise(ArmException exception) {
    throw new UnimplementedError();
  }

  /// Single-steps the CPU, that is, fetches and executes a single instruction.
  ///
  /// Returns the number of clock cycles needed to execute the instruction.
  int step() => -1 * (run(1) - 1);

  /// Runs the CPU for specified clock [cycles].
  ///
  /// Returns the difference between the number of requested clock cycles and
  /// the actual number of clock cycles performed. This may be `0` or a negative
  /// value.
  int run(int cycles) {
    while (cycles > 0) {
      // Fetch instruction word (iw).
      // FIXME: Handle prefetch aborts.
      final i = _decoder.decode(read32(gprs.pc));
      if (i.condition.pass(cpsr)) {
        // The PC value used in an executing instruction is always two
        // instructions ahead of the actual instruction address because of
        // pipe-lining.
        gprs.pc += 8;

        // Dispatch instruction.
        final before = gprs.pc;
        final executed = i.execute(this);
        cycles -= executed;

        // Move on to next instruction, unless executed instruction was a branch
        // which means a pipeline flush, or the instruction raised an exception
        // and altered the PC.
        if (gprs.pc == before &&
            // TODO: Make this first-class instead.
            i.name != 'BX' &&
            i.name != 'B' &&
            i.name != 'BL') {
          gprs.pc -= 4;
        }
      } else {
        // Skip over the instruction.
        gprs.pc += 4;
        cycles--;
      }
      // Check for FIQ and IRQ exceptions.
      if (!isFiqDisabled && !cpsr.f) {
        raise(ArmException.fiq);
      } else if (!isIrqDisabled && !cpsr.i) {
        raise(ArmException.irq);
      }
    }
    return cycles;
  }

  /// Read a half-word from the program at [pc].
  int read16(int pc) => _read16(pc);

  /// Read a word from the program at [pc].
  int read32(int pc) => _read32(pc);
}
