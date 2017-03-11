import 'package:arm7_tdmi/arm7_tdmi.dart';

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
  final Registers _registers;

  factory Cpu() => new Cpu._(new Registers());

  Cpu._(this._registers);

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
  int get programCounter => _registers.pc;

  /// Raise a CPU-level [exception].
  void raise(ArmException exception) {
    throw new UnimplementedError();
  }
}
