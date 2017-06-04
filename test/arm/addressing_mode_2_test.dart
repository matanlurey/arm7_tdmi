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
      // No-indexing, Imm offset
      new TestCase(
        asm: "ldrb  r2, [pc, #56]",
        iw: 0xe5df2038,
        initRegisters: (gprs) {},
        rn: 15,
        expectedAddress: 56,
        expectedRnValue: 0,
      ),
      // No-indexing, Reg offset, offset=12
      new TestCase(
        asm: "ldr  r2, [pc, r8]",
        iw: 0xe79f2008,
        initRegisters: (Registers gprs) {
          gprs[15] = 25; // Initial base-register value.
          gprs[8] = 12; // Offset register value.
        },
        rn: 15,
        expectedAddress: 37,
        expectedRnValue: 25,
      ),
      // Post-indexing, Imm offset
      new TestCase(
        asm: "ldrb  r3, [r1], #15",
        iw: 0xe4d1300f,
        initRegisters: (gprs) {
          gprs[1] = 15; // Initial base-register value.
        },
        rn: 1,
        expectedAddress: 15,
        expectedRnValue: 30,
      ),
      // Post-indexing, Reg offset, offset=17
      new TestCase(
        asm: "ldrb	r1, [r0], r6",
        iw: 0xe6d01006,
        initRegisters: (gprs) {
          gprs[0] = 3; // Initial base-register value.
          gprs[6] = 17; // Offset register value.
        },
        rn: 0,
        expectedAddress: 3,
        expectedRnValue: 20,
      ),
      // new TestCase(
      //   iw: 0xe5cc001f,
      //   asm: "strb  r0, [r12, #31]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
      // new TestCase(
      //   iw: 0xe5ca0000,
      //   asm: "strb  r0, [r10]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
      // new TestCase(
      //   iw: 0xe5901000,
      //   asm: "ldr  r1, [r0]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
      // new TestCase(
      //   iw: 0xe590200c,
      //   asm: "ldr  r2, [r0, #12]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
      // new TestCase(
      //   iw: 0xe5801000,
      //   asm: "str  r1, [r0]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
      // new TestCase(
      //   iw: 0xe5831000,
      //   asm: "str  r1, [r3]",
      //   initRegisters: (gprs) => null,
      //   rn: null,
      //   expectedAddress: null,
      //   expectedRnValue: null,
      // ),
    ].forEach((testCase) {
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
