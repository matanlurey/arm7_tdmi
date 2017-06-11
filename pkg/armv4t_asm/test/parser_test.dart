import 'package:armv4t_asm/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Arm4TParser', () {
    final parser = const Armv4tParser();

    group('parseMnemonic', () {
      test('should parse a simple mnemonic', () {
        final result = parser.parseMnemonic('mov');
        expect(result.mnemonic, 'MOV');
        expect(result.suffix, isNull);
        expect(result.condition, isNull);
      });

      test('should parse a mnemonic with a suffix', () {
        final result = parser.parseMnemonic('adds');
        expect(result.mnemonic, 'ADD');
        expect(result.suffix, 'S');
        expect(result.condition, isNull);
      });

      test('should parse a mnemonic with a condition', () {
        final result = parser.parseMnemonic('subgt');
        expect(result.mnemonic, 'SUB');
        expect(result.suffix, isNull);
        expect(result.condition, 'GT');
      });
      
      test('should parse a mnemomic with a suffix and condition', () {
        final result = parser.parseMnemonic('sublts');
        expect(result.mnemonic, 'SUB');
        expect(result.suffix, 'S');
        expect(result.condition, 'LT');
      });
    });
  });
}
