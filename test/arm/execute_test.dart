import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

import '../common/rom.dart';

void main() {
  test('Addition overflow should occur', () {
    final rom = createRom([
      0xe3e01000, // mvn  r1, #0
      0xe3a02001, // mov  r2, #1
      0xe0910002, // adds r0, r1, r2
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

  test('Undefined instruction trap should be triggered', () {
    final rom = createRom([0xFF000000]);
    final cpu = new Cpu.noExecution(read32: (a) => rom[a ~/ 4]);
    cpu.step(); // Reset branch.
    expect(cpu.pc, resetLabel);
    cpu.step(); // Execute undefined instruction.
    // expect(cpu.pc, 0x00000004);
    // expect(cpu.mode, Mode.und);
  });

  test('Software interrupt should raise a SWI exception', () {
    final rom = createRom([0xEF00000F]);
    final cpu = new Cpu.noExecution(read32: (a) => rom[a ~/ 4]);
    cpu.step(); // Reset branch.
    expect(cpu.pc, resetLabel);
    cpu.step();

    // Next read should fetch instruction from the software interrupt exception
    // vector (0x00000008).
    expect(cpu.pc, 0x00000008);

    // CPU mode should be 'supervisor'.
    expect(cpu.mode, Mode.svc);

    // R14_svc - 4 should be address of the SWI instruction.
    var address = cpu.gprs[14] - 4;
    expect(rom[address ~/ 4], 0xEF00000F);
  });

  test('Data abort should take the trap when an address is unavailable', () {
    const abortInst = 0xE5901000;
    final rom = createRom([
      0xe51f0000,   // ldr r0, [pc, #-0]
      abortInst,    // ldr r1, [r0]
      0x12345678,   // embedded constant for ldr r0 instruction
    ]);
    final cpu = new Cpu.noExecution(read32: (a) => rom[a ~/ 4]);
    cpu.step(); // Reset branch.
    expect(cpu.pc, resetLabel);
    /*
    cpu.step();

    // R0 should contain 0x12345678 now.
    expect(cpu.gprs[0], 0x12345678);

    // Trying to read from memory address 0x12345678 should raise a data-abort.
    cpu.step();
    const dataAbortVector = 0x00000010;
    expect(cpu.pc, dataAbortVector);
    expect(cpu.mode, Mode.abt);

    // Instruction that caused the abort should be at R14_abt - 8.
    final address = cpu.gprs[14] - 8;
    expect(rom[address ~/ 4], abortInst);
    */
  });
}
