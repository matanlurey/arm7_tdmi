import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

import '../common/rom.dart';

void main() {
  test('Addition overflow should occur', () {
    final rom = createRom([
      0xe3e01000,   // mvn  r1, #0
      0xe3a02001,   // mov  r2, #1
      0xe0910002,   // adds r0, r1, r2
    ]);
    final cpu = new Cpu(
      read16: (a) => rom[a ~/ 4],
      read32: (a) => rom[a ~/ 4],
    );
    cpu.step();
    expect(cpu.pc, resetLabel);
    for (var i = 0; i < 3; i++) {
      cpu.step();
    }
    expect(cpu.cpsr.n, isFalse);
    // expect(cpu.cpsr.z, isTrue);
    // expect(cpu.cpsr.c, isTrue);
    // expect(cpu.cpsr.v, isFalse);
  });
}
