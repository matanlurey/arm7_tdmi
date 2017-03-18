import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

void main() {
  group('$Cpu', () {
    Cpu cpu;

    setUp(() {
      cpu = new Cpu.noExecution();
    });

    group('reset values', () {
      // CPU Manual:
      //
      // Registers R0 - R14 (including banked registers) and SPSR (in all modes)
      // are undefined after reset. The Program Counter (PC/R15) will be set to
      // 0x00000000. The Current Program Status Register (CPSR) will indicate
      // that the ARM core has started in ARM state, Supervisor mode with both
      // FIQ and IRQ mask bits set. The condition code flags will be undefined.
      test('PC/R15 should be 0x00000000', () {
        expect(cpu.pc, 0x00000000);
      });

      test('ARM core should be in the ARM state', () {
        expect(cpu.isArm, isTrue);
      });

      test('should be in the supervisor mode', () {
        expect(cpu.mode, Mode.svc);
      });

      test('FIQ (F) should be set/disabled', () {
        expect(cpu.isFiqDisabled, isTrue);
      });

      test('IRQ (I) should be set/disabled', () {
        expect(cpu.isIrqDisabled, isTrue);
      });
    });

    test('reset instruction should initially be fetched', () {
      cpu = new Cpu.noExecution(
        read32: expectAsync1((address) {
          expect(address, 0x0);
          return 0;
        }
      ));
      cpu.step();
    });
  });
}
