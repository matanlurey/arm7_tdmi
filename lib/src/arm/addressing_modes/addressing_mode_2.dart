import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// Computes the address for a load and store word or unsigned byte instruction.
typedef int AddressComputation(Cpu cpu);

/// Creates functions that compute load/store word/unsigned byte instruction
/// addresses.
///
/// There are nine formats used to calculate the address for these instructions.
/// The general instruction syntax is:
///
/// LDR|STR{<cond>}{B}{T} <Rd>, <addressing_mode>
///
/// All nine of the encodings are available for the LDR, LDRB, STR and STRB
/// instructions.  Only "post indexed" encodings are available for LDRBT, LDRT
/// and STRBT instructions.  For the PLD instruction, only the offset options
/// (the first three in the list) are available.
abstract class AddressingMode2 {
  // The addressing mode 2 encodings.  These are lazily instantiated and should
  // only be initialized once.
  static _Encoding __encoding;
  static _ImmediateEncoding _immediateEncoding;
  static _RegisterEncoding _registerEncoding;
  static _ScaledRegisterEncoding _scaledEncoding;

  /// Returns the [AddressComputation] for [iw].
  static AddressComputation decodeAddress(int iw) {
    AddressComputation address;

    final int rn = _encoding.rn(iw);
    if (_isImmediateOffset(iw)) {
      _immediateEncoding ??= new _ImmediateEncoding();
      address = (Cpu cpu) => _immediateAddress(
            cpu,
            rn: rn,
            offset: _immediateEncoding.offset(iw),
            isAdd: _immediateEncoding.u(iw),
          );
    } else if (_isRegisterOffset(iw)) {
      _registerEncoding ??= new _RegisterEncoding();
      address = (Cpu cpu) => _registerAddress(
            cpu,
            rn: rn,
            rm: _registerEncoding.rm(iw),
            isAdd: _registerEncoding.u(iw),
          );
    } else {
      assert(_isScaledOffset(iw));
      _scaledEncoding = new _ScaledRegisterEncoding();
      address = (Cpu cpu) => _scaledRegisterAddress(
            cpu,
            rn: rn,
            rm: _scaledEncoding.rm(iw),
            shiftImmediate: _scaledEncoding.shiftImmediate(iw),
            shift: _scaledEncoding.shift(iw),
            isAdd: _scaledEncoding.u(iw),
          );
    }

    if (_isPostIndexed(iw)) {
      return (Cpu cpu) => _postIndexedAddress(cpu, address: address, rn: rn);
    } else if (_isPreIndexed(iw)) {
      return (Cpu cpu) => _preIndexedAddress(cpu, address: address, rn: rn);
    } else {
      assert(_isNotIndexed(iw));
      return (Cpu cpu) => _nonIndexedAddress(cpu, address: address);
    }
  }

  /// Returns an address from [offset] applied to register [rn].
  ///
  /// if [isAdd], [offset] is added to register [rn], otherwise it is
  /// subtracted.
  static int _immediateAddress(
    Cpu cpu, {
    @required int rn,
    @required int offset,
    @required bool isAdd,
  }) =>
      isAdd ? cpu.gprs[rn] + offset : cpu.gprs[rn] - offset;

  /// Returns an address from register [rm] applied to register [rn].
  ///
  /// if [isAdd], register [rm] is added to register [rn], otherwise it is
  /// subtracted.
  static int _registerAddress(
    Cpu cpu, {
    @required int rn,
    @required int rm,
    @required bool isAdd,
  }) =>
      isAdd ? cpu.gprs[rn] + cpu.gprs[rm] : cpu.gprs[rn] - cpu.gprs[rm];

  // TODO(kharland): Add documentation.
  static int _scaledRegisterAddress(
    Cpu cpu, {
    @required int rn,
    @required int rm,
    @required int shiftImmediate,
    @required int shift,
    @required bool isAdd,
  }) {
    final gprs = cpu.gprs;
    int offset;

    switch (shift) {
      case 0: // LSL
        offset = gprs[rm] << shiftImmediate;
        break;
      case 1: // LSR
        offset = shiftImmediate == 0 ? 0 : gprs[rm] >> shiftImmediate;
        break;
      case 2: // ASR
        offset = shiftImmediate == 0
            ? int32.isNegative(gprs[rm]) ? uint32.max : 0
            : uint32.arithmeticShiftRight(gprs[rm], shiftImmediate);
        break;
      case 3: // ROR or RRX
        offset = shiftImmediate == 0
            ? ((cpu.cpsr.c ? 1 : 0) << 32) | (gprs[rm] >> 1)
            : rotateRight(gprs[rm], shiftImmediate);
        break;
      default:
        throw new Exception('shift is not a 2-bit number: $shift');
    }

    return isAdd ? cpu.gprs[rn] + offset : cpu.gprs[rn] - offset;
  }

  /// Returns [address] as the address.
  ///
  /// No registers are updated.
  static int _nonIndexedAddress(Cpu cpu,
          {@required AddressComputation address}) =>
      address(cpu);

  /// Returns [address] as the address.
  ///
  /// The value of [address] is written to register [rn].
  static int _preIndexedAddress(
    Cpu cpu, {
    @required AddressComputation address,
    @required int rn,
  }) {
    cpu.gprs[rn] = address(cpu);
    return cpu.gprs[rn];
  }

  /// Returns the value of register [rn] as the address.
  ///
  /// The returned value is the initial value of register [rn].  [address] is
  /// written to register [rn].
  static int _postIndexedAddress(
    Cpu cpu, {
    @required AddressComputation address,
    @required int rn,
  }) {
    final addr = cpu.gprs[rn];
    cpu.gprs[rn] = address(cpu);
    return addr;
  }

  /// Returns true iff the base register is not modified.
  static bool _isNotIndexed(int iw) => _encoding.p(iw) && !_encoding.w(iw);

  /// Returns true iff the base register value is used as the address.
  ///
  /// The offset is added/subtracted against the base register value and written
  /// back to the base register.
  static bool _isPostIndexed(int iw) => !_encoding.p(iw);

  /// Returns true iff the calculated address is written back to the base
  /// register.
  static bool _isPreIndexed(int iw) => _encoding.p(iw) && _encoding.w(iw);

  /// Returns true iff the address offset is an immediate value
  static bool _isImmediateOffset(int iw) => !_encoding.i(iw);

  /// Returns true iff the address offset comes from a register.
  static bool _isRegisterOffset(int iw) =>
      isSet(iw, 25) && bitRange(iw, 11, 4) == 0;

  /// Returns true iff the address offset comes from a rotated register value.
  static bool _isScaledOffset(int iw) =>
      !(_isImmediateOffset(iw) || _isRegisterOffset(iw)) && isClear(iw, 4);

  /// Helper for instantiating [_encoding] in other methods.
  static _Encoding get _encoding {
    __encoding ??= new _Encoding();
    return __encoding;
  }
}

/// A stateless object for reading the unique parts of an [AddressingMode2]
/// instruction.
///
/// This class is non-abstract to allow inheritance.  [AddressingMode2] should
/// only hold a single instance of each [_Encoding] at any given time.  This is
/// done to reduce the number of objects created by the emulator when decoding
/// instructions.
class _Encoding {
  /// Whether this is not an immediate-encoded instruction.
  bool i(int iw) => isSet(iw, 25);

  /// Combined with [w], determines the indexing type of this instruction.
  bool p(int iw) => isSet(iw, 24);

  /// Whether the address is computed as an addition or subtraction.
  bool u(int iw) => isSet(iw, 23);

  /// See docs for [p].
  bool w(int iw) => isSet(iw, 21);

  /// The base register used to computed the address for [iw].
  int rn(int iw) => bitRange(iw, 19, 16);
}

/// Reads an immediate-encoded [AddressingMode2] instruction.
class _ImmediateEncoding extends _Encoding {
  int offset(int iw) => bitRange(iw, 11, 0);
}

/// Reads a register-encoded [AddressingMode2] instruction.
class _RegisterEncoding extends _Encoding {
  int rm(int iw) => bitRange(iw, 3, 0);
}

/// Reads a scaled-register-encoded [AddressingMode2] instruction.
class _ScaledRegisterEncoding extends _RegisterEncoding {
  int shiftImmediate(int iw) => bitRange(iw, 11, 7);

  int shift(int iw) => bitRange(iw, 6, 5);
}
