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
  // Index for banked register spsr.
  static const _bankedSpsr = -1;

  // ignore: strong_mode_implicit_dynamic_parameter
  static int _unsupportedRead(_) {
    throw new UnsupportedError('No execution supported');
  }

  final ArmDecoder _decoder;
  final Registers _registers;
  final Func1<int, int> _read16;
  final Func1<int, int> _read32;

  /// The current program status registers.
  ///
  /// These are accessible from any processor mode.
  Psr _cpsr;

  /// The FIQ input.
  ///
  /// An FIQ is generated externally by taking the [inputFIQ] LOW (false).
  bool inputFIQ = true;

  /// The IRQ input.
  ///
  /// An IRQ is generated externally by taking [inputIRQ] LOW (false).
  bool inputIRQ = true;

  /// The banked registers of the different operating modes.
  ///
  /// Banked registers are discrete physical registers in the core that are
  /// mapped to the available registers depending on the current processor
  /// operating mode.
  ///
  /// Registers R8 to R12 have two banked physical registers each. One is used
  /// in all processor modes other than FIQ mode, and the other is used in FIQ
  /// mode.  Registers R13 and R14 have six banked physical registers each. One
  /// is used in User and System modes, and each of the remaining five is used
  /// in one of the five exception modes.
  /// There's a total of 37 registers (32bit), 31 general registers (`Rxx`) and
  ///
  /// Comparing these registers to the psuedocode in the official ARM docs:
  ///
  /// 6 status registers (`xPSR`). Note that only some resisters are "banked",
  /// for example each mode has it's own `R14` register: called `R14`, `R14_fiq`,
  /// `R14_svc1, etc. for each mode respectively
  ///
  /// However, other registers are not banked, for example, each mode is using the
  /// same `R0` register, so writing to `R0` will always affect the content of
  /// `R0` in other modes also.
  ///
  /// ```txt
  /// System/User     FIQ         Supervisor     Abort     IRQ      Undefined
  /// -----------------------------------------------------------------------
  /// R0              R0          R0             R0        R0       R0
  /// R1              R1          R1             R1        R1       R1
  /// R2              R2          R2             R2        R2       R2
  /// R3              R3          R3             R3        R3       R3
  /// R4              R4          R4             R4        R4       R4
  /// R5              R5          R5             R5        R5       R5
  /// R6              R6          R6             R6        R6       R6
  /// R7              R7          R7             R7        R7       R7
  /// -----------------------------------------------------------------------
  /// R8              R8_fiq      R8             R8        R8       R8
  /// R9              R9_fiq      R9             R9        R9       R9
  /// R10             R10_fiq     R10            R10       R10      R10
  /// R11             R11_fiq     R11            R11       R11      R11
  /// R12             R12_fiq     R12            R12       R12      R12
  /// R13 (SP)        R13_fiq     R13_svc        R13_abt   R13_irq  R13_und
  /// R14 (LR)        R14_fiq     R14_svc        R14_abt   R14_irq  R14_und
  /// R15 (PC)        R15         R15            R15       R15      R15
  /// -----------------------------------------------------------------------
  /// CPSR            CPSR        CPSR           CPSR      CPSR     CPSR
  /// --              SPSR_fiq    SPSR_svc       SPSR_abt  SPSR_irq SPSR_und
  /// -----------------------------------------------------------------------
  /// ```
  final _bankedRegisters = <Mode, Map<int, int>>{
    Mode.usr: {
      8: 0,
      9: 0,
      10: 0,
      11: 0,
      12: 0,
      13: 0,
      14: 0,
    },
    Mode.fiq: {
      8: 0,
      9: 0,
      10: 0,
      11: 0,
      12: 0,
      13: 0,
      14: 0,
      _bankedSpsr: 0,
    },
    Mode.irq: {
      13: 0,
      14: 0,
      _bankedSpsr: 0,
    },
    Mode.svc: {
      13: 0,
      14: 0,
      _bankedSpsr: 0,
    },
    Mode.abt: {
      13: 0,
      14: 0,
      _bankedSpsr: 0,
    },
    Mode.und: {
      13: 0,
      14: 0,
      _bankedSpsr: 0,
    }
  };

  factory Cpu({
    ArmDecoder decoder: const ArmDecoder(),
    @required int read16(int address),
    @required int read32(int address),
  }) =>
      new Cpu.private(
        decoder,
        new Registers(),
        new Psr(),
        read16,
        read32,
      );

  @visibleForTesting
  factory Cpu.noExecution({
    ArmDecoder decoder: const ArmDecoder(),
    int read16(int address): _unsupportedRead,
    int read32(int address): _unsupportedRead,
  }) =>
      new Cpu(
        decoder: decoder,
        read16: read16,
        read32: read32,
      );

  @protected
  Cpu.private(
    this._decoder,
    this._registers,
    this._cpsr,
    this._read16,
    this._read32,
  );

  /// GPRS.
  Registers get gprs => _registers;

  /// CPSR.
  Psr get cpsr => _cpsr;

  /// The SPSR bits for the current [mode].
  int get spsr => _bankedRegisters[mode][_bankedSpsr];
  set spsr(int value) {
    if (this.mode == Mode.usr || this.mode == Mode.sys) {
      return; // Unpredictable as per spec.
    }
    _bankedRegisters[mode][_bankedSpsr] = value;
  }

  /// Whether the CPU is currently executing as ARM.
  bool get isArm => cpsr.isArmState;

  /// Whether the CPU is currently executing as THUMB.
  bool get isThumb => cpsr.isThumbState;

  /// Whether FIQ is disabled.
  bool get isFiqDisabled => cpsr.f;

  /// Whether IRQ is disabled.
  bool get isIrqDisabled => cpsr.i;

  /// Operating mode.
  Mode get mode => cpsr.mode;

  /// Program counter for the CPU.
  int get pc => _registers.pc;

  /// Raise a CPU-level [exception].
  void raise(ArmException exception) {
    final newCpsr = new Psr.bits(cpsr.value)
      ..mode = exception.mode
      // Disable interrupts.
      ..i = true;

    // FIQ is only disabled on power-up and for FIQ interrupts.
    //
    // Otherwise it remains unchanged.
    if (exception == ArmException.reset || exception == ArmException.fiq) {
      newCpsr.f = true;
    }

    // Exceptions are only executed in ARM state.
    newCpsr.isArmState = true;

    // Switch CPU to respective mode and save the old CPSR to SPSR of new mode.
    loadCpsr(newCpsr.value);

    // Preserve the address of the next instruction in the appropriate LR.
    // The current PC value is 8 bytes ahead of the instruction currently being
    // executed (unless IRQ/FIQ).
    var pc = this.pc;
    if (exception != ArmException.irq && exception != ArmException.fiq) {
      pc -= 8;
    }
    if (exception != ArmException.reset) {
      gprs.lr = exception == ArmException.dataAbort ? pc + 8 : pc + 4;
    }

    // Force the PC to fetch the next instruction from the relevant vector.
    gprs.pc = exception.code;
  }

  /// Returns the next instruction based on the program counter.
  @visibleForOverriding
  Instruction fetch() => _decoder.decode(read32(gprs.pc));

  /// Executes [instruction] against this CPU.
  @visibleForOverriding
  int execute(Instruction instruction) => instruction.execute(this);

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
      final i = fetch();
      if (i.condition.pass(cpsr)) {
        // The PC value used in an executing instruction is always two
        // instructions ahead of the actual instruction address because of
        // pipe-lining.
        gprs.pc += 8;

        // Dispatch instruction.
        final before = gprs.pc;
        final executed = execute(i);
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
      if (!inputFIQ && !cpsr.f) {
        raise(ArmException.fiq);
      } else if (!inputIRQ && !cpsr.i) {
        raise(ArmException.irq);
      }
    }
    return cycles;
  }

  /// Read a half-word from the program at [pc].
  int read16(int pc) => _read16(pc);

  /// Read a word from the program at [pc].
  int read32(int pc) => _read32(pc);

  /// Loads the [cpsr] from [bits].
  ///
  /// Current [gprs] values are written to the current [mode]'s banked
  /// registers.  If the new mode has access to [spsr], the current [cpsr] is
  /// saved to the new mode's banked SPSR register.
  void loadCpsr(int bits) {
    final newCpsr = new Psr.bits(bits);
    if (newCpsr.isThumbState) {
      throw new UnsupportedError('THUMB mode');
    }
    // System mode shares the same registers as User mode.
    final oldMode = mode == Mode.sys ? Mode.usr : mode;
    final newMode = newCpsr.mode == Mode.sys ? Mode.usr : newCpsr.mode;

    // Bank current registers and load banked registers of new mode.
    if (oldMode != newMode) {
      final oldRegs = _bankedRegisters[oldMode];
      final newRegs = _bankedRegisters[newMode];

      for (var reg in newRegs.keys) {
        if (reg == _bankedSpsr) {
          newRegs[reg] = cpsr.value;
          continue;
        }
        if (oldRegs.containsKey(reg)) {
          oldRegs[reg] = gprs[reg];
        }
        gprs[reg] = newRegs[reg];
      }
    }

    _cpsr = newCpsr;
  }
}
