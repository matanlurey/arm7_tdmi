import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:test/test.dart';

void main() {
  _testPsr();
  _testRegisters();
}

// Run tests that verify the `Psr` class.
void _testPsr() {
  Psr psr;

  group('should decode Mode of', () {
    int bits;

    Mode.modes.forEach((b, mode) {
      test('0x${b.toRadixString(16).toUpperCase()} (${mode.identifier})', () {
        bits = 0 | b;
        psr = new Psr.bits(bits);
        expect(psr.value & b, b);
        expect(psr.mode, mode);
      });
    });
  });

  test('should decode ARM state', () {
    psr = new Psr.bits(uint32.clear(0 | Mode.usr.bits, Psr.thumbState));
    expect(psr.isArmState, isTrue);
    expect(psr.isThumbState, isFalse);
  });

  test('should decode THUMB state', () {
    psr = new Psr.bits(uint32.set(0 | Mode.usr.bits, Psr.thumbState));
    expect(psr.isArmState, isFalse);
    expect(psr.isThumbState, isTrue);
  });

  test('should decode V', () {
    psr = new Psr.bits(uint32.clear(0 | Mode.usr.bits, Psr.V));
    expect(psr.v, isFalse);
    psr = new Psr.bits(uint32.set(0 | Mode.usr.bits, Psr.V));
    expect(psr.v, isTrue);
  });

  test('should decode C', () {
    psr = new Psr.bits(uint32.clear(0 | Mode.usr.bits, Psr.C));
    expect(psr.c, isFalse);
    psr = new Psr.bits(uint32.set(0 | Mode.usr.bits, Psr.C));
    expect(psr.c, isTrue);
  });

  test('should decode Z', () {
    psr = new Psr.bits(uint32.clear(0 | Mode.usr.bits, Psr.Z));
    expect(psr.z, isFalse);
    psr = new Psr.bits(uint32.set(0 | Mode.usr.bits, Psr.Z));
    expect(psr.z, isTrue);
  });

  test('should decode N', () {
    psr = new Psr.bits(uint32.clear(0 | Mode.usr.bits, Psr.N));
    expect(psr.n, isFalse);
    psr = new Psr.bits(uint32.set(0 | Mode.usr.bits, Psr.N));
    expect(psr.n, isTrue);
  });
}

void _testRegisters() {
  Registers registers;

  setUp(() => registers = new Registers());

  test('should read/write to R0->R7 for every operating mode', () {
    Mode.modes.values.forEach((mode) {
      for (var i = 0; i < 8; i++) {
        expect(
          () => registers[i] = 1,
          returnsNormally,
          reason: '$mode should be able to write to register R$i',
        );
        expect(
          registers[i],
          1,
          reason: '$mode should be able to read from register R$i',
        );
      }
    });
    final data = registers.toFixedList();
    expect(
      data.getRange(0, 7),
      everyElement(1),
      reason: 'Should have written a value of "1" to registers R0-R7',
    );
  });
}
