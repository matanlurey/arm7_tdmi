import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';

/// Creates a wrapped version of [Cpu] that stores traces of execution.
class TracedCpu extends Cpu {
  final List<Trace> traces = <Trace>[];

  bool _ranTrace = false;

  TracedCpu({
    ArmDecoder decoder: const ArmDecoder(),
    @required int read16(int address),
    @required int read32(int address),
  })
      : super.private(
          decoder,
          new Registers(),
          new Psr(),
          read16,
          read32,
        );

  Iterable<Trace> getTraces() => traces;

  @override
  int execute(Instruction instruction) {
    final result = super.execute(instruction);
    if (_ranTrace) {
      _ranTrace = false;
      traces.clear();
    }
    traces.add(new Trace._(this, instruction));
    return result;
  }
}

class Trace {
  final int pc;
  final Instruction instruction;
  final Psr cpsr;

  Trace._(Cpu cpu, this.instruction)
      : pc = cpu.pc,
        cpsr = cpu.cpsr;

  @override
  String toString() =>
      '0x${pc.toRadixString(16)}: ${instruction.toDebugString()}';
}
