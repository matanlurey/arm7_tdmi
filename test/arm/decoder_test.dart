import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

void main() {
  const decoder = const ArmDecoder();

  const {
    0xe0904002: 'ADD' /*S*/,
  }.forEach((bits, name) {
    test('0x${bits.toRadixString(16).toUpperCase()} should be $name', () {
      expect(
        decoder.decode(bits).name,
        name,
      );
    });
  });
}
