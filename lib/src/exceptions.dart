import 'package:arm7_tdmi/arm7_tdmi.dart';

/// Exception that occurred while processing instructions.
class ArmException {
  static const reset = const ArmException._(
    0x00000000,
    'Reset',
    Mode.svc,
  );

  static const undefinedInstruction = const ArmException._(
    0x00000004,
    'Undefined Instruction',
    Mode.und,
  );

  static const softwareInterrupt = const ArmException._(
    0x00000008,
    'Software Interrupt',
    Mode.svc,
  );

  static const prefetchAbort = const ArmException._(
    0x0000000C,
    'Prefetch Abort',
    Mode.abt,
  );

  static const dataAbort = const ArmException._(
    0x00000010,
    'Data Abort',
    Mode.abt,
  );

  static const reserved = const ArmException._(
    0x00000014,
    'Reserved',
    null,
  );

  static const irq = const ArmException._(
    0x00000018,
    'IRQ',
    Mode.irq,
  );

  static const fiq = const ArmException._(
    0x0000001C,
    'FIQ',
    Mode.fiq,
  );

  /// Used to identify an exception.
  final int code;

  /// Human-readable exception type.
  final String type;

  /// Operating mode.
  final Mode mode;

  const ArmException._(this.code, this.type, this.mode);
}

class MemoryException implements Exception {
  static const badAddress = const MemoryException._('Bad Address');

  /// Human-reabable exception message.
  final String message;

  const MemoryException._(this.message);
}
