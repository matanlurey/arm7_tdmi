import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

void main() {
  _testReadAndWrite();
}

void _testReadAndWrite() {
  List<int> backing;
  Memory memory;

  setUp(() {
    backing = new Uint8List(32);
    memory = new Memory.view((backing as TypedData).buffer);
  });

  test('should read 8 bits', () {
    backing[0] = 255;
    expect(memory.read8(0), 255);
  });

  test('should read 16 bits', () {
    backing[0] = 255;
    expect(memory.read16(0), 255);
  });

  test('should read 32 bits', () {
    backing[0] = 255;
    expect(memory.read32(0), 255);
  });

  test('should write 8 bits', () {
    memory.write8(0, 255);
    expect(backing[0], 255);
  });

  test('should write 16 bits', () {
    memory.write16(0, 255);
    expect(backing[0], 255);
  });

  test('should write 32 bits', () {
    memory.write32(0, 255);
    expect(backing[0], 255);
  });

  test('should return as a buffer', () {
    memory.write8(0, 255);
    expect(backing, memory.toBuffer().asUint8List());
  });
}
