import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('$AddressingMode1', () {
    Cpu cpu;

    /// Returns an instruction with [n] as the register containing the shift.
    int selectRsRegister(int n) {
      assert(0 <= n && n <= 0xF);
      return n << 8;
    }

    /// Returns an instruction with [n] as the register containing the value to
    /// shift.
    int selectRmRegister(int n) {
      assert(0 <= n && n <= 0xF);
      return n;
    }

    /// Returns an instruction with [shiftType] as the shift type.
    int buildInstruction({
      @required shiftType,
      @required rs,
      @required rm,
    }) {
      return AddressingMode1.LOGICAL_SHIFT_LEFT |
          selectRsRegister(rs) |
          selectRmRegister(rm);
    }

    /// Initializes the rs and rm registers to contain [shiftValue] and
    /// [valueToShift] respectively.
    void setShiftRegisters({
      @required rs,
      @required rm,
      @required shiftValue,
      @required valueToShift,
    }) {
      cpu.gprs[rs] = shiftValue;
      cpu.gprs[rm] = valueToShift;
    }

    /// Tests [AddressingMode1.generateValues] with the provided arguments.
    void testAddressingMode1({
      @required int rs,
      @required int rm,
      @required int shiftValue,
      @required int valueToShift,
      @required int shiftType,
      @required int expectedShifterOperand,
      @required bool expectedShifterCarryOut,
    }) {
      setShiftRegisters(
        shiftValue: shiftValue,
        valueToShift: valueToShift,
        rs: rs,
        rm: rm,
      );

      int instruction = buildInstruction(
        rs: rs,
        rm: rm,
        shiftType: shiftType,
      );

      final reason = [
        'rs=$rs',
        'rm=$rm',
        'shiftValue=$shiftValue',
        'valueToShift=$valueToShift',
        'shiftType=$shiftType'
      ].join(',');

      AddressingMode1.generateValues(cpu, instruction);
      expect(cpu.shifterOperand, expectedShifterOperand, reason: reason);
      expect(cpu.shifterCarryOut, expectedShifterCarryOut, reason: reason);
    }

    setUp(() {
      cpu = new Cpu.noExecution();
    });

    group('generateValues', () {
      group('LSL should generate correct operands', () {
        // Unsure if there's a reason for these registers to vary between test
        // cases, so keeping them as consts for now.
        const rs = 1;
        const rm = 2;

        [true, false].forEach((carryValue) {
          test('when the shift value is 0', () {
            const shiftValue = 0;
            const valueToShift = 0x40000004;

            cpu.cpsr.c = carryValue;
            testAddressingMode1(
              rs: rs,
              rm: rm,
              shiftValue: shiftValue,
              valueToShift: valueToShift,
              shiftType: AddressingMode1.LOGICAL_SHIFT_LEFT,
              expectedShifterOperand: valueToShift,
              expectedShifterCarryOut: carryValue,
            );
          });
        });

        test('when the shift value is less than 32', () {
          const shiftValue = 2;
          const valueToShift = 0x40000004;

          testAddressingMode1(
            rs: rs,
            rm: rm,
            shiftValue: shiftValue,
            valueToShift: valueToShift,
            shiftType: AddressingMode1.LOGICAL_SHIFT_LEFT,
            expectedShifterOperand: valueToShift << shiftValue,
            expectedShifterCarryOut: true,
          );
        });

        test('when the shift value is 32', () {
          const shiftValue = 32;
          const valueToShift = 0x40000004;

          testAddressingMode1(
            rs: rs,
            rm: rm,
            shiftValue: shiftValue,
            valueToShift: valueToShift,
            shiftType: AddressingMode1.LOGICAL_SHIFT_LEFT,
            expectedShifterOperand: 0,
            expectedShifterCarryOut: false,
          );
        });

        test('when the shift value is greater than 32', () {
          // TODO
        });
      });
    });
  });
}
