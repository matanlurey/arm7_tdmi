import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  const decoder = const ArmDecoder();

  // ARM instructions generated with arm-none-eabi-as.
  // https://github.com/smiley22/ARM.JS/blob/gh-pages/Tests/Test.Cpu.ts.
  const [
    const Tuple2<int, String>(0xe0904002, 'ADD'), // adds r4, r0, r2
    const Tuple2<int, String>(0xe0a15003, 'ADC'), // adc  r5, r1, r3
    const Tuple2<int, String>(0xe280001a, 'ADD'), // add  r0, r0, #26
    const Tuple2<int, String>(0xe1510000, 'CMP'), // cmp  r1, r0
    const Tuple2<int, String>(0xeb000001, 'BL'), // bl   14
    const Tuple2<int, String>(0xe12fff1e, 'BX'), // bx   lr
    const Tuple2<int, String>(0xe3c99003, 'BIC'), // bic  r9, r9, #3
    const Tuple2<int, String>(
        0xee070f9a, 'MCR'), // mcr  15, 0, r0, cr7, cr10, {4}
    const Tuple2<int, String>(0xe59f2038, 'LDR'), // ldr  r2, [pc, #56]
    const Tuple2<int, String>(0xe129f000, 'MSR'), // msr  CPSR_fc, r0
    const Tuple2<int, String>(
        0xee080f17, 'MCR'), // mcr  15, 0, r0, cr8, cr7, {0}
    const Tuple2<int, String>(0xe59f2038, 'LDR'), // ldr  r2, [pc, #56]
    const Tuple2<int, String>(0xe3c33001, 'BIC'), // bic  r3, r3, #1
    const Tuple2<int, String>(
        0xee013f10, 'MCR'), // mcr  15, 0, r3, cr1, cr0, {0}
    const Tuple2<int, String>(0xe1a0f002, 'MOV'), // mov  pc, r2
    const Tuple2<int, String>(0xe59fc02c, 'LDR'), // ldr  ip, [pc, #44]
    const Tuple2<int, String>(0xe3a000f3, 'MOV'), // mov  r0, #243
    const Tuple2<int, String>(0xe58c001f, 'STR'), // str  r0, [ip, #31]
    const Tuple2<int, String>(0xebfffffe, 'BL'), // bl   0 <main>
    const Tuple2<int, String>(0xeafffffe, 'B'), // b    58 <.text + 0x58>
    const Tuple2<int, String>(0xe5901000, 'LDR'), // ldr  r1, [r0]
    const Tuple2<int, String>(0xe3510000, 'CMP'), // cmp  r1, #0
    const Tuple2<int, String>(0x1a000000, 'B'), // bne  6c <.text + 0x6c>
    const Tuple2<int, String>(0xe5801000, 'STR'), // str  r1, [r0]
    const Tuple2<int, String>(0xe5901008, 'LDR'), // ldr  r1, [r0, #8]
    const Tuple2<int, String>(0xe590200c, 'LDR'), // ldr  r2, [r0, #12]
    const Tuple2<int, String>(0xe4d13001, 'LDR'), // ldrb r3, [r1], #1
    const Tuple2<int, String>(0x00000058, 'AND'), // andeq r0, r0, r8, asr r0
    const Tuple2<int, String>(0x00001341, 'AND'), // andeq r1, r0, r1, asr #6
    const Tuple2<int, String>(0x61750100, 'CMN'), // cmnvs r5, r0, lsl #2
    const Tuple2<int, String>(0x01100962, 'TST'), // cmnvs r5, r0, lsl #2
    const Tuple2<int, String>(0x00000009, 'AND'), // andeq r0, r0, r9
    const Tuple2<int, String>(0x01180306, 'TST'), // tsteq r8, r6, lsl #6
  ].forEach((tuple) {
    final bits = tuple.item1;
    final name = tuple.item2;
    test('0x${bits.toRadixString(16).toUpperCase()} should be $name', () {
      expect(
        decoder.decode(bits).name,
        name,
      );
    });
  });
}
