const _initialRom = const [
  0xea00000c, // b 38 <ResetException>
  0xea000005, // b 20 <UndefinedException>
  0xea000005, // b 24 <SoftwareException>
  0xea000005, // b 28 <PrefetchException>
  0xea000005, // b 2c <DataException>
  0xe1a00000, // nop ; (mov r0, r0)
  0xea000004, // b 30 <IRQException>
  0xea000004, // b 34 <FIQException>

  0xeafffffe, // b 20 <UndefinedException>
  0xeafffffe, // b 24 <SoftwareException>
  0xeafffffe, // b 28 <PrefetchException>
  0xeafffffe, // b 2c <DataException>
  0xeafffffe, // b 30 <IRQException>
  0xeafffffe, // b 34 <FIQException>
];

/// Reset exception?
const resetLabel = 0x38;

/// Create a sample ROM by appending [instructions].
List<int> createRom(Iterable<int> instructions) {
  return new List<int>.from(_initialRom)..addAll(instructions);
}
