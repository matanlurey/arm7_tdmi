/// Exception that occurred while processing instructions.
class ArmException {
  static const reset = const ArmException._(
    0x00000000,
    'Reset',
  );

  static const undefinedInstruction = const ArmException._(
    0x00000004,
    'Undefined Instruction',
  );

  static const softwareInterrupt = const ArmException._(
    0x00000008,
    'Software Interrupt',
  );

  static const prefetchAbort = const ArmException._(
    0x0000000C,
    'Prefetch Abort',
  );

  static const dataAbort = const ArmException._(
    0x00000010,
    'Data Abort',
  );

  static const reserved = const ArmException._(
    0x00000014,
    'Reserved',
  );

  static const irq = const ArmException._(
    0x00000018,
    'IRQ',
  );

  static const fiq = const ArmException._(
    0x0000001C,
    'FIQ',
  );

  /// Used to identify an exception.
  final int code;

  /// Human-readable exception type.
  final String type;

  const ArmException._(this.code, this.type);
}
