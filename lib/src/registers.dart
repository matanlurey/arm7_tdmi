import 'dart:typed_data';

import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// ARM7/TDMI register set which is available in each mode.
///
/// There's a total of 37 registers (32bit), 31 general registers (`Rxx`) and
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
class Registers {
  // Total size required to represent the registers.
  static final int _totalSize = Mode.modes.values.fold(0, (l, m) => l + m.size);

  /// Stack pointer index.
  @visibleForTesting
  static const SP = 13;

  /// Link register index.
  @visibleForTesting
  static const LR = 14;

  /// Program counter index.
  @visibleForTesting
  static const PC = 15;

  /// Offset values for a given operating [Mode].
  @visibleForTesting
  static const offsets = const <Mode, int>{
    Mode.fiq: 17,
    Mode.svc: 25,
    Mode.abt: 28,
    Mode.irq: 31,
    Mode.und: 34,
  };

  final Uint32List _buffer;

  Psr _cpsr;

  /// Create a new empty register set with a pre-specified operating [mode].
  factory Registers({Mode mode: Mode.svc}) {
    final buffer = new Uint32List(_totalSize * Uint32List.BYTES_PER_ELEMENT);
    final registers = new Registers.view(buffer);
    registers.reset();
    return registers;
  }

  /// Create a register set view using an existing 37 register 32-bit buffer.
  ///
  /// The following breakdown is assumed when using the memory:
  ///
  /// ```
  /// 00 -> 15  = R00 -> R15
  /// 16        = CPSR
  /// 17 -> 23  = R08 -> R14_fiq
  /// 24        = SPSR_fiq
  /// 25 -> 26  = R13 -> R15_svc
  /// 27        = SPSR_svc
  /// 28 -> 29  = R13 -> R15_abt
  /// 30        = SPSR_abt
  /// 31 -> 32  = R13 -> R15_irq
  /// 33        = SPSR_irq
  /// 34 -> 35  = R13 -> R15_und
  /// 36        = SPSR_und
  /// ```
  Registers.view(this._buffer) {
    assert(() {
      if (_buffer == null) {
        throw new ArgumentError.notNull();
      }
      if (_buffer.length != _totalSize * Uint32List.BYTES_PER_ELEMENT) {
        throw new ArgumentError(
          'Requires a buffer of length $_totalSize, got ${_buffer.length}',
        );
      }
      return true;
    });
    _cpsr = new Psr.view(_buffer, 16);
  }

  /// Represents the CPSR.
  Psr get cpsr => _cpsr;

  /// Returns a flags register represents the SPSR for the processor.
  ///
  /// The returned instance differs depending on the [Psr.mode] in [cpsr].
  ///
  /// Some modes cannot access the SPSR, so a [StateError] is thrown.
  Psr get spsr {
    final offset = offsets[cpsr.mode];
    assert(offset != null, 'Cannot access the SPSR as ${cpsr.mode}');
    return new Psr.view(_buffer, offset + cpsr.mode.size);
  }

  /// Program counter (R15).
  ///
  /// When the processor is executing in ARM state ([Psr.isArmState]):
  /// * All instructions are 32-bit in length.
  /// * All instructions must be word aligned.
  /// * Therefore the PC value is stored in bits [31:2] with bits [1:0] equal to
  ///   zero (as instruction cannot be halfword or byte aligned).
  int get pc => this[PC];
  set pc(int pc) {
    this[PC] = pc;
  }

  /// Link register (R14).
  ///
  /// Used as the subroutine link register and stores the return address when
  /// Branch with Link operations are performed, calculated from the [pc].
  int get lr => this[LR];
  set lr(int lr) {
    this[LR] = lr;
  }

  /// Returns a [register] value.
  ///
  /// The memory location accessed is dependent on the operating mode.
  int operator [](int register) {
    assert(() {
      if (register < 0 || register > 15) {
        throw new RangeError.range(register, 0, 15);
      }
      return true;
    });

    // For R0-R7 or R15 short-circuit directly to the (shared) registers.
    if (register < 8 || register == 15) {
      return _buffer[register];
    }

    // For R8-R14, it's dependent on the operating mode.
    //
    // We apply an offset when reading from the underlying data structure.
    return _buffer[offsets[cpsr.mode] + register];
  }

  /// Sets a [register] [value].
  ///
  /// The memory location accessed is dependent on the operating mode.
  operator []=(int register, int value) {
    assert(() {
      if (register < 0 || register > 15) {
        throw new RangeError.range(register, 0, 15);
      }
      return true;
    });

    // For R0-R7 or R15 short-circuit directly to the (shared) registers.
    if (register < 8 || register == 15) {
      _buffer[register] = value;
      return;
    }

    // For R8-R14, it's dependent on the operating mode.
    _buffer[offsets[cpsr.mode] + register] = value;
  }

  /// Resets to the default value.
  void reset() {
    _cpsr.reset();
  }

  /// Returns a copy of the data backing the registers.
  Uint32List toFixedList() => new Uint32List.fromList(_buffer);
}

/// A representation of the seven ARM7/TDMI operating modes.
class Mode {
  /// All of the known operating modes by the identifying bits.
  ///
  /// INTERNAL ONLY: Not part of the supported public API.
  @visibleForTesting
  static const modes = const {
    0x10: usr,
    0x11: fiq,
    0x12: irq,
    0x13: svc,
    0x17: abt,
    0x1F: sys,
    0x1B: und,
  };

  /// The usual Cpu operating mode.
  ///
  /// Used for executing most application programs.
  static const usr = const Mode._(0x10, 'usr', 17);

  /// Supports a data transfer or channel process.
  static const fiq = const Mode._(0x11, 'fiq', 8);

  /// Used for general purpose interrupt handling.
  static const irq = const Mode._(0x12, 'irq', 3);

  /// A protected (supervisor) mode for the operating system.
  static const svc = const Mode._(0x13, 'svc', 3);

  /// Entered after a data or instruction prefetch abort.
  static const abt = const Mode._(0x17, 'abt', 3);

  /// A privileged user mode for the operating system.
  static const sys = const Mode._(0x1F, 'sys', 0);

  /// Entered when an undefined instruction is executed.
  static const und = const Mode._(0x1B, 'und', 3);

  /// Four (4) bits representing this operating mode.
  final int bits;

  /// String representation of the operating mode.
  final String identifier;

  /// How many 32-bit integers are needed to represent this mode.
  final int size;

  const Mode._(this.bits, this.identifier, this.size);

  @override
  String toString() => '$Mode {$identifier}';
}

/// Utility class around reading and writing flags to the CPSR/SPSR.
///
/// CPSR bits are as following:
/// ```
/// 0 - 4:    M0 - M4 - Mode bits.
/// 5:        T - State bit.
/// 6:        F - FIQ disable         (0=Enable, 1=Disable)
/// 7:        I - IRQ disable         (0=Enable, 1=Disable)
/// 8 - 26:   Reserved
/// 27:       Q - Sticky overflow     (1=Sticky overflow, ARMv5TE and up only)
/// 28:       V - Overflow flag       (0=No Overflow, 1=Overflow)
/// 29:       C - Carry flag          (0=Borrow/No carry, 1=Carry/No borrow)
/// 30:       Z - Zero flag           (0=Not zero, 1=Zero)
/// 31:       N - Sign flag           (0=Not signed, 1=Signed)
/// ```
///
/// ## Bit 31 -> 28: Condition Code Flags (N,Z,C,V)
///
/// These bits reflect results of logical or arithmetic instructions. In `ARM`
/// mode, it is often optionally whether an instruction should modify flags or
/// not, for example, it is possible to execute a SUB instruction that does NOT
/// modify the condition flags.
///
/// In `ARM` state, all instructions can be executed conditionally depending on
/// the settings of the flags, such like `MOVEQ` (Move if Z=1). While In `THUMB`
/// state, only Branch instructions (jumps) can be made conditionally.
///
/// ## Bit 27: Sticky Overflow Flag (Q) - ARMv5TE and ARMv5TExP and up only
///
/// Used by `QADD`, `QSUB`, `QDADD`, `QDSUB`, `SMLAxy`, and `SMLAWy` only. These
/// opcodes set the Q-flag in case of overflows, but leave it unchanged
/// otherwise. The Q-flag can be tested/reset by `MSR`/`MRS` opcodes only.
///
/// ## Bit 27 -> 8: Reserved Bits (except Bit 27 on ARMv5TE and up, see above)
///
/// These bits are reserved for possible future implementations. For best
/// forwards compatibility, the user should never change the state of these
/// bits, and should not expect these bits to be set to a specific value.
///
/// ## Bit 0 -> 7: Control Bits (I,F,T,M4-M0)
///
/// These bits may change when an exception occurs. In privileged modes
/// (non-user modes) they may be also changed manually.
///
/// The interrupt bits I and F are used to disable IRQ and FIQ interrupts
/// respectively (a setting of `1` means disabled).
///
/// The T Bit signalizes the current state of the CPU (0=`ARM`, 1=`THUMB`), this
/// bit should never be changed manually - instead, changing between `ARM` and
/// `THUMB` state must be done by `BX` instructions.
///
/// To determine the current operating mode, look at bits M4-M0 as such:
///
/// ````
/// 10000 = User
/// 10001 = FIQ
/// 10010 = IRQ
/// 10011 = Supervisor
/// 10111 = Abort
/// 11011 = Undefined
/// 11111 = System
/// ````
///
/// Writing any other values into the Mode bits is not allowed.
class Psr {
  @visibleForTesting
  static const modeStart = 0;

  @visibleForTesting
  static const modeEnd = 4;

  @visibleForTesting
  static const thumbState = 5;

  @visibleForTesting
  static const F = 6;

  @visibleForTesting
  static const I = 7;

  @visibleForTesting
  static const V = 28;

  @visibleForTesting
  static const C = 29;

  @visibleForTesting
  static const Z = 30;

  @visibleForTesting
  static const N = 31;

  // Reads from memory.
  final Func0<int> _read;

  // Writes to memory.
  final VoidFunc1<int> _write;

  /// Creates a new PSR representing a default/reset state.
  factory Psr({
    Mode mode: Mode.svc,
    bool arm: true,
    bool i: true,
    bool f: true,
    bool v: false,
    bool c: false,
    bool z: false,
    bool n: false,
  }) =>
      new Psr.bits(0 | mode.bits)
        ..isArmState = arm
        ..i = i
        ..f = f
        ..v = v
        ..c = c
        ..z = z
        ..n = n;

  /// Creates a new [Psr] that uses [bits] as the initial value.
  factory Psr.bits(int bits) {
    final psr = new Psr.bind(read: () => bits, write: (v) => bits = v);
    assert(psr.mode != null);
    return psr;
  }

  /// Creates a new [Psr] that reads/writes into [offset] in some [memory].
  factory Psr.view(Uint32List memory, int offset) {
    return new Psr.bind(
      read: () => memory[offset],
      write: (v) => memory[offset] = v,
    );
  }

  /// Creates a new [Psr] that binds to a [read] and [write] function.
  const Psr.bind({
    @required int read(),
    @required void write(int value),
  })
      : _read = read,
        _write = write;

  /// Current operating mode.
  Mode get mode {
    final m0m4 = uint32.range(_read(), modeEnd, modeStart);
    final result = Mode.modes[m0m4];
    assert(result != null, 'Unknown mode: 0x${m0m4.toRadixString(16)}');
    return result;
  }

  /// Sets the current operating mode.
  set mode(Mode mode) {
    _write(_read() | mode.bits);
    assert(mode != null);
  }

  /// IRQ disabled.
  bool get i => _isSet(I);
  set i(bool i) {
    _toggleBit(I, i);
  }

  /// FIQ disabled.
  bool get f => _isSet(F);
  set f(bool f) {
    _toggleBit(F, f);
  }

  /// Overflow (V) flag.
  ///
  /// Set when a result of an arithmetic instruction was greater than 31 bits;
  /// indicates a possible corruption of the sign bit in signed numbers.
  bool get v => _isSet(V);
  set v(bool overflow) {
    _toggleBit(V, overflow);
  }

  /// Carry (C) flag.
  ///
  /// Set when a logical instruction's shift '1' was left in the carry flag or
  /// the result of an arithmetic instruction was greater than 32 bits.
  bool get c => _isSet(C);
  set c(bool carry) {
    _toggleBit(C, carry);
  }

  /// Zero (Z) flag.
  ///
  /// Set when the result of a logical instruction was all "zeroes" or the
  /// result of an arithmetic instruction was zero.
  bool get z => _isSet(Z);
  set z(bool zero) {
    _toggleBit(Z, zero);
  }

  /// Sign (N) flag.
  ///
  /// Set when bit 31 of the result of an arithmetic instruction has been set.
  /// Indicates a negative number in signed operations.
  bool get n => _isSet(N);
  set n(bool sign) {
    _toggleBit(N, sign);
  }

  /// Whether the processor is in `ARM` state.
  bool get isArmState => !isThumbState;
  set isArmState(bool isArmState) {
    _toggleBit(thumbState, !isArmState);
  }

  /// Whether the processor is in `THUMB` state.
  bool get isThumbState => _isSet(thumbState);
  set isThumbState(bool isThumbState) {
    _toggleBit(thumbState, isThumbState);
  }

  // Returns whether a bit is "set" at index (i.e. is `1` not `0`).
  bool _isSet(int index) => _readBit(index) == 1;

  // Returns a bit by index.
  int _readBit(int index) => uint32.get(_read(), index);

  // Toggles the value of a bit.
  void _toggleBit(int index, bool value) {
    value ? _setBit(index) : _unsetBit(index);
  }

  // Sets a bit by index.
  void _setBit(int index) {
    _write(uint32.set(_read(), index));
    assert(_isSet(index), 'Did not write to B$index');
  }

  // Un-sets a bit by index.
  void _unsetBit(int index) {
    _write(uint32.clear(_read(), index));
    assert(!_isSet(index), 'Did not write to B$index');
  }

  /// Reset the CPSR to the default values.
  void reset() {
    this
      ..mode = Mode.svc
      ..isArmState = true
      ..i = true
      ..f = true
      ..v = false
      ..c = false
      ..z = false
      ..n = false;
  }

  /// Bits representing this PSR.
  int get value => _read();
  set value(int value) => _write(value);

  @override
  String toString() =>
      '$Psr ' +
      {
        'mode': mode.identifier,
        'state': isArmState ? 'ARM' : 'THUMB',
        'i': i ? 'set' : 'clear',
        'f': f ? 'set' : 'clear',
        'v': v ? 'set' : 'clear',
        'c': c ? 'set' : 'clear',
        'z': z ? 'set' : 'clear',
        'n': n ? 'set' : 'clear',
      }.toString();
}
