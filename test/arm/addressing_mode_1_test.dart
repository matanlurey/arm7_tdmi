import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';
import 'package:test/test.dart';

import 'src/shifter_operand_tester.dart';

void main() {
  group('$AddressingMode1', () {
    ShifterOperandTester tester;

    final firstOperands = <int>[
      uint32.min,
      (uint32.max - uint32.min) ~/ 2,
      uint32.max,
    ];

    /* Common shifts (2nd operands) */
    const shiftsLessThan32 = const <int>[0x1, 0x15, 0x1F];
    const shiftsGreaterThan32 = const <int>[0x21, 0x40, 0x80, 0xFF];
    const justZero = const <int>[0];
    const just32 = const <int>[32];

    void commonSetUp(Shifter shifter) {
      tester = new ShifterOperandTester(shifter);
    }

    tearDown(() {
      tester = null;
    });

    group('immediateValue should rotate an immediate value', () {
      // ignore: strong_mode_implicit_dynamic_parameter
      int expectedShifterOperand(int immediate, int rotate, _) =>
          rotateRight(immediate, rotate * 2);

      final immediateValues = firstOperands.map(uint8.mask);

      setUp(() {
        commonSetUp(AddressingMode1.immediate);
      });

      test('when rotation == 0', () {
        tester.test(
            firstOperands: immediateValues,
            secondOperands: justZero, // rotations
            expectedOperand: expectedShifterOperand,
            expectedCarryOut: initialCarryFlag);
      });

      test('when rotation > 0', () {
        tester.test(
            firstOperands: immediateValues,
            secondOperands: const <int>[0x1, 0x5, 0x9, 0xD, 0xF],
            expectedOperand: expectedShifterOperand,
            expectedCarryOut: (int immediate, int rotate, _) =>
                int32.isNegative(expectedShifterOperand(immediate, rotate, _)));
      });
    });

    group('LSLImmediate', () {
      setUp(() {
        commonSetUp(AddressingMode1.logicalShiftLeftByImmediate);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: unshiftedOp1,
            expectedCarryOut: initialCarryFlag);
      });

      test('shift > 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: llShift,
            expectedCarryOut: (int op1, int shift, _) =>
                isSet(op1, 32 - shift));
      });
    });

    group('LSLRegister', () {
      setUp(() {
        commonSetUp(AddressingMode1.logicalShiftLeftByRegister);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: unshiftedOp1,
            expectedCarryOut: initialCarryFlag);
      });

      test('shift < 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: llShift,
            expectedCarryOut: (int op1, int shift, _) =>
                isSet(op1, 32 - shift));
      });

      test('shift == 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: just32,
            expectedOperand: zero,
            expectedCarryOut: (int op1, int shift, _) => isSet(op1, 0));
      });

      test('shift > 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsGreaterThan32,
            expectedOperand: zero,
            expectedCarryOut: (_, __, ___) => false);
      });
    });

    group('LSRImmediate', () {
      setUp(() {
        commonSetUp(AddressingMode1.logicalShiftRightByImmediate);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: zero,
            expectedCarryOut: isOp1Negative);
      });

      test('shift > 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: lrShift,
            expectedCarryOut: isLostBitSet);
      });
    });

    group('LSRRegister', () {
      setUp(() {
        commonSetUp(AddressingMode1.logicalShiftRightByRegister);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: unshiftedOp1,
            expectedCarryOut: initialCarryFlag);
      });

      test('shift < 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: lrShift,
            expectedCarryOut: isLostBitSet);
      });

      test('shift == 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: just32,
            expectedOperand: zero,
            expectedCarryOut: (int op1, _, __) => isSet(op1, 31));
      });

      test('shift > 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsGreaterThan32,
            expectedOperand: zero,
            expectedCarryOut: (_, __, ___) => false);
      });
    });

    group('ASRImmediate', () {
      setUp(() {
        commonSetUp(AddressingMode1.shiftRightByImmediate);
      });

      group('shift == 0 and bit 31 of the operand is', () {
        const shifts = justZero;

        test('clear', () {
          tester.test(
              firstOperands: const <int>[0x7FFFFFFF, 0x01234567],
              secondOperands: shifts,
              expectedOperand: zero,
              expectedCarryOut: isOp1Negative);
        });

        test('set', () {
          tester.test(
              firstOperands: const <int>[0xFFFFFFFF, 0x80000000],
              secondOperands: shifts,
              expectedOperand: uint32Max,
              expectedCarryOut: isOp1Negative);
        });
      });

      test('shift > 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: arShift,
            expectedCarryOut: isLostBitSet);
      });
    });

    group('ASRRegister', () {
      setUp(() {
        commonSetUp(AddressingMode1.shiftRightByRegister);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: unshiftedOp1,
            expectedCarryOut: initialCarryFlag);
      });

      test('shift < 32', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: arShift,
            expectedCarryOut: isLostBitSet);
      });

      group('shift >= 32 and bit 31 of the input is', () {
        final shifts = <int>[32]..addAll(shiftsGreaterThan32);

        test('clear', () {
          tester.test(
              firstOperands: const <int>[0x7FFFFFFF, 0x01234567],
              secondOperands: shifts,
              expectedOperand: zero,
              expectedCarryOut: isOp1Negative);
        });

        test('set', () {
          tester.test(
              firstOperands: const <int>[0xFFFFFFFF, 0x80000000],
              secondOperands: shifts,
              expectedOperand: uint32Max,
              expectedCarryOut: isOp1Negative);
        });
      });
    });

    group('RORImmediate', () {
      ShifterOperandTester tester;

      setUp(() {
        tester =
            new ShifterOperandTester(AddressingMode1.rotateRightByImmediate);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: justZero,
            expectedOperand: (int op1, _, bool carryFlag) {
              final c = carryFlag ? 1 : 0;
              return (c << 31) | (op1 >> 1);
            },
            expectedCarryOut: (int op1, _, __) => isClear(op1, 0));
      });

      test('shift > 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: shiftsLessThan32,
            expectedOperand: (int op, int shift, bool _) =>
                rotateRight(op, shift),
            expectedCarryOut: isLostBitSet);
      });
    });

    group('RORRegister', () {
      ShifterOperandTester tester;

      setUp(() {
        tester =
            new ShifterOperandTester(AddressingMode1.rotateRightByRegister);
      });

      test('shift == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: const [0],
            expectedOperand: unshiftedOp1,
            expectedCarryOut: initialCarryFlag);
      });

      test('shift > 0 and bits shift[5..0] == 0', () {
        tester.test(
            firstOperands: firstOperands,
            secondOperands: const [0xE0, 0xC0],
            expectedOperand: unshiftedOp1,
            expectedCarryOut: isOp1Negative);
      });
    });
  });
}

/// Computes a shifter operand of zero
// ignore: strong_mode_implicit_dynamic_parameter
int zero(int _, int __, bool ___) => 0;

/// Computes a shifter operand of the max unsigned 32-bit integer value.
// ignore: strong_mode_implicit_dynamic_parameter
int uint32Max(_, __, ___) => uint32.max;

/// Computes a shifter operand equal to [op1].
int unshiftedOp1(int op1, int _, bool __) => op1;

/// Computes a shifter operand by logically-right shifting [op1] by [shift].
int lrShift(int op1, int shift, bool _) => op1 >> shift;

/// Computes a shifter operand by logically-left shifting [op1] by [shift].
int llShift(int op1, int shift, bool _) => op1 << shift;

/// Computes a shifter operand by arithmetically-right shifting [op1] by [shift].
// ignore: strong_mode_implicit_dynamic_parameter
int arShift(int op1, int shift, _) => uint32.arithmeticShiftRight(op1, shift);

/// Computes a shifter carry out identical to the initial CPSR carry flag.
bool initialCarryFlag(int _, int __, bool carryFlag) => carryFlag;

/// Computes a shifter carry out of true iff [op1] is a negative 32-bit integer.
bool isOp1Negative(int op1, int _, bool __) => int32.isNegative(op1);

/// Computes a shifter carry out of true iff the last bit lost off the end of a
/// right shift or rotation was set.
bool isLostBitSet(int op1, int shift, bool _) => isSet(op1, shift - 1);
