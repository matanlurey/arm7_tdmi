import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_2.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group("$AddressingMode2", () {
    Cpu cpu;

    setUp(() {
      cpu = new Cpu.noExecution();
    });

    // Instructions generated with arm-none-eabi-as (as).
    //
    // Arm4vt only supports the LDR, LDRB, STR and STRB Addressing mode 2
    // instructions, so some instructions from the full ARM spec are missing
    // from this list.  Every armv4t addressing mode 2 instruction computes the
    // offset as an addition (bit U/23 is set).
    [
      // No indexing, immediate offset.
      new TestCase(
        asm: "ldrb  r2, [pc, #56]",
        iw: 0xe5df2038,
        initRegisters: (gprs) {},
        rn: 15,
        expectedAddress: 56,
        expectedRnValue: 0,
      ),
      // No indexing, register offset.
      new TestCase(
        asm: "ldr  r2, [pc, r8]",
        iw: 0xe79f2008,
        initRegisters: (Registers gprs) {
          gprs[15] = 25; // Initial base register value.
          gprs[8] = 12; // Offset register value.
        },
        rn: 15,
        expectedAddress: 25 + 12,
        expectedRnValue: 25,
      ),
      // No indexing, scaled register offset.
      new TestCase(
        iw: 0xe7910102,
        asm: "ldr  r0, [r1, r2, lsl #2]",
        initRegisters: (gprs) {
          gprs[1] = 3; // Initial base register value.
          gprs[2] = 4; // Shift register value.
        },
        rn: 1,
        expectedAddress: 3 + (4 << 2),
        expectedRnValue: 3,
      ),
      // Post-indexing, immediate offset.
      new TestCase(
        asm: "ldrb  r3, [r1], #15",
        iw: 0xe4d1300f,
        initRegisters: (gprs) {
          gprs[1] = 15; // Initial base register value.
        },
        rn: 1,
        expectedAddress: 15,
        expectedRnValue: 15 + 15,
      ),
      // Post-indexing, register offset.
      new TestCase(
        asm: "ldrb  r1, [r0], r6",
        iw: 0xe6d01006,
        initRegisters: (gprs) {
          gprs[0] = 3; // Initial base register value.
          gprs[6] = 17; // Offset register value.
        },
        rn: 0,
        expectedAddress: 3,
        expectedRnValue: 3 + 17,
      ),
      // Post indexing, scaled register offset.
      new TestCase(
        iw: 0xe6910122,
        asm: "ldr  r0, [r1], r2, lsr #2",
        initRegisters: (gprs) {
          gprs[1] = 3; // Initial base register value.
          gprs[2] = 4; // Shift register value.
        },
        rn: 1,
        expectedAddress: 3,
        expectedRnValue: 3 + (4 >> 2),
      ),
      // Pre-indexing, immediate offset.
      new TestCase(
        asm: "str  r0, [r12, #31]!",
        iw: 0xe5ac001f,
        initRegisters: (gprs) {
          gprs[12] = 2; // Initial base register value.
        },
        rn: 12,
        expectedAddress: 2 + 31,
        expectedRnValue: 2 + 31,
      ),
      // Pre-indexing, register offset.
      new TestCase(
        iw: 0xe7ea0001,
        asm: "strb  r0, [r10, r1]!",
        initRegisters: (gprs) {
          gprs[10] = 5; // Initial base register value.
          gprs[1] = 11; // Offset register value.
        },
        rn: 10,
        expectedAddress: 5 + 11,
        expectedRnValue: 5 + 11,
      ),
    ].forEach((testCase) {
      // ignore: non_constant_identifier_names
      final PUBWL =
          bitRange(testCase.iw, 24, 20).toRadixString(2).padLeft(5, '0');
      test('${testCase.asm} (PUBWL=$PUBWL)', () {
        testCase.initRegisters(cpu.gprs);
        final address = AddressingMode2.decodeAddress(testCase.iw)(cpu);
        expect(address, testCase.expectedAddress);
        expect(cpu.gprs[testCase.rn], testCase.expectedRnValue);
      });
    });
  });
}

typedef void RegisterInit(Registers gprs);

class TestCase {
  final String asm;
  final int iw;
  final RegisterInit initRegisters;
  final int rn;
  final int expectedAddress;
  final int expectedRnValue;

  TestCase({
    @required this.asm,
    @required this.iw,
    @required this.initRegisters,
    @required this.rn,
    @required this.expectedAddress,
    @required this.expectedRnValue,
  });
}
