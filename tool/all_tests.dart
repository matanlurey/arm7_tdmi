import '../test/arm/addressing_mode_1_test.dart' as addressing_mode_1;
import '../test/arm/addressing_mode_2_test.dart' as addressing_mode_2;
import '../test/arm/condition_test.dart' as condition;
import '../test/arm/decoder_test.dart' as decoder;
import '../test/arm/execute_test.dart' as execute;
import '../test/cpu_test.dart' as cpu;
import '../test/memory_test.dart' as memory;
import '../test/registers_test.dart' as registers;

void main() {
  addressing_mode_1.main();
  addressing_mode_2.main();
  condition.main();
  decoder.main();
  execute.main();
  cpu.main();
  memory.main();
  registers.main();
}
