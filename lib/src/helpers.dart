import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';

import 'cpu.dart' show Cpu;
import 'registers.dart' show Registers;

/// TODO: Move to package:binary
int btoi(bool value) => value ? 1 : 0;

/// A helper function for writing [value] to [register] in [gprs].
///
/// Returns the result after being stored.
int gprsWrite(Registers gprs, int register, int value) {
  gprs[register] = value.toUnsigned(32);
  return gprs[register];
}

/// A helper function that computes the PSR in [cpu] based on inputs.
void computePsr(
  Cpu cpu,
  int register,
  int opOnlyValue,
  int value, [
  int op1,
  int op2,
]) {
  cpu.cpsr
    ..n = int32.isNegative(value)
    ..z = isZero(value)
    ..c = uint32.hasCarryBit(opOnlyValue);
  if (op1 != null) {
    cpu.cpsr.v = int32.doesAddOverflow(op1, op2, value);
  }
}

/// A helper function that computes the PSR in [cpu] based on inputs.
void computePsrShifter(
  Cpu cpu,
  int register,
  int value,
  ShifterValues shifter,
) {
  cpu.cpsr
    ..n = int32.isNegative(value)
    ..z = isZero(value)
    ..c = shifter.carryOut;
}
