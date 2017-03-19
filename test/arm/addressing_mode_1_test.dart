import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';
import 'package:test/test.dart';

void main() {
  group('$AddressingMode1', () {
    Cpu cpu;

    setUp(() {
      // Set shifter values just in case the defaults change.
      cpu = new Cpu.noExecution()
        ..shifterCarryOut = false
        ..shifterOperand = 0;
    });

    group('immediate should correctly set shifter_operand', () {
      const immediate = 13;
      const carryFlag = true;

      test('when the rotation is 0', () {
        cpu.cpsr.c = carryFlag;

        AddressingMode1.immediate(cpu, rotate: 0, immediate: immediate);
        expect(cpu.shifterOperand, immediate);
        expect(cpu.shifterCarryOut, carryFlag);
      });

      test('when the rotation is greater than 0', () {
        const rotate = 7;
        cpu.cpsr.c = carryFlag;

        AddressingMode1.immediate(cpu, rotate: rotate, immediate: immediate);
        expect(cpu.shifterOperand, rotateRight(immediate, rotate * 2));
        expect(cpu.shifterCarryOut, int32.isNegative(cpu.shifterOperand));
      });
    });
  });
}
