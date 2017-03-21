import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('$AddressingMode1', () {
    Cpu cpu;

    /// Tests that [shifterOperand] sets [expectedShifterOperand] and
    /// [expectedShifterCarryOut] on a [Cpu].
    ///
    /// [shift] is the amount to shift [valueToShift].  Both values are stored
    /// in registers before [shifterOperand] is decoded.
    ///
    /// [cpsrC] is optional, and can be used to set the carry flag on the [Cpu]
    /// before [shifterOperand] is decoded.
    void testShifterOperand({
      @required shifterOperand,
      bool cpsrC: false,
      @required int shift,
      @required int valueToShift,
      @required int expectedShifterOperand,
      @required bool expectedShifterCarryOut,
    }) {
      var cpu = new Cpu.noExecution()
        ..gprs[1] = shift // rs
        ..gprs[2] = valueToShift // rm
        ..cpsr.c = cpsrC;

      if (shifterOperand is ImmediateShift) {
        shifterOperand(cpu, shift: shift, rm: 2);
      } else {
        assert(shifterOperand is RegisterShift);
        shifterOperand(cpu, rs: 1, rm: 2);
      }

      expect(cpu.shifterOperand, expectedShifterOperand);
      expect(cpu.shifterCarryOut, expectedShifterCarryOut);
    }

    group('immediateValue should rotate an immediate value', () {
      void testImmediateValue({
        @required bool cpsrC,
        @required int rotate,
        @required int immediate,
        @required int expectedShifterOperand,
        @required bool expectedShifterCarryOut,
      }) {
        AddressingMode1.immediateValue(
          cpu = new Cpu.noExecution()..cpsr.c = cpsrC,
          rotate: rotate,
          immediate: immediate,
        );
        expect(cpu.shifterOperand, expectedShifterOperand);
        expect(cpu.shifterCarryOut, expectedShifterCarryOut);
      }

      test('when rotation == 0', () {
        testImmediateValue(
            cpsrC: true,
            rotate: 0,
            immediate: 13,
            expectedShifterOperand: 13,
            expectedShifterCarryOut: true);
        testImmediateValue(
            cpsrC: false,
            rotate: 0,
            immediate: 13,
            expectedShifterOperand: 13,
            expectedShifterCarryOut: false);
      });

      test('when rotation > 0', () {
        int expectedShifterOperand = rotateRight(13, 4 * 2);
        testImmediateValue(
            cpsrC: true,
            rotate: 4,
            immediate: 13,
            expectedShifterOperand: expectedShifterOperand,
            expectedShifterCarryOut: int32.isNegative(expectedShifterOperand));
      });
    });

    group('shiftLSLImm should logically shift-left an immediate value', () {
      test('when shift == 0', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLImm,
            cpsrC: false,
            shift: 0,
            valueToShift: 7,
            expectedShifterOperand: 7,
            expectedShifterCarryOut: false);
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLImm,
            cpsrC: true,
            shift: 0,
            valueToShift: 7,
            expectedShifterOperand: 7,
            expectedShifterCarryOut: true);
      });

      test('when shift > 0', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLImm,
            shift: 8,
            valueToShift: 7,
            expectedShifterOperand: 7 << 8,
            expectedShifterCarryOut: isSet(7, 32 - 8));
      });
    });

    group('shiftLSLReg should logically shift-left a register value', () {
      test('when shift == 0', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            cpsrC: true,
            shift: 0,
            valueToShift: 7,
            expectedShifterOperand: 7,
            expectedShifterCarryOut: true);
      });

      test('when shift < 32', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            shift: 15,
            valueToShift: 7,
            expectedShifterOperand: 7 << 15,
            expectedShifterCarryOut: isSet(7, 32 - 15));
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            shift: 1,
            valueToShift: 3,
            expectedShifterOperand: 3 << 1,
            expectedShifterCarryOut: isSet(1, 32 - 3));
      });

      test('when shift == 32', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            cpsrC: false, // shifter carry out starts out false.
            shift: 32,
            valueToShift: 1,
            expectedShifterOperand: 0,
            expectedShifterCarryOut: isSet(1, 0));
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            cpsrC: false,
            shift: 32,
            valueToShift: 25,
            expectedShifterOperand: 0,
            expectedShifterCarryOut: isSet(25, 0));
      });

      test('when shift > 32', () {
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            cpsrC: true,
            shift: 33,
            valueToShift: 25,
            expectedShifterOperand: 0,
            expectedShifterCarryOut: false);
        testShifterOperand(
            shifterOperand: AddressingMode1.shiftLSLReg,
            cpsrC: false,
            shift: 100,
            valueToShift: 1,
            expectedShifterOperand: 0,
            expectedShifterCarryOut: false);
      });
    });

    group('shiftLSRImm', () {});
    group('shiftLSRReg', () {});
    group('shiftLSRImm', () {});
    group('shiftASRImm', () {});
    group('shiftASRReg', () {});
    group('shiftRORImm', () {});
    group('shiftRORReg', () {});
  });
}
