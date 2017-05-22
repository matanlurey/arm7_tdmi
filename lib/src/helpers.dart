import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';

import 'cpu.dart' show Cpu;
import 'registers.dart' show Registers;

/// A helper function for writing [value] to [register] in [gprs].
///
/// Returns the result after being stored.
int gprsWrite(Registers gprs, int register, int value) {
  gprs[register] = value.toUnsigned(32);
  return gprs[register];
}

/// A helper function that computes the PSR in [cpu] based on inputs.
void computePsr(Cpu cpu, int register, int value, [int op1, int op2]) {
  cpu.cpsr
    ..n = uint32.isNegative(value)
    ..z = isZero(value)
    ..c = uint32.hasCarryBit(value);
  if (op1 != null) {
    cpu.cpsr.v = uint32.doesAddOverflow(op1, op2, value);
  }
}

void computePsrShifter(
  Cpu cpu,
  int register,
  int value,
  ShifterValues shifter,
) {
  cpu.cpsr
    ..n = uint32.isNegative(value)
    ..z = isZero(value)
    ..c = shifter.carryOut;
}
