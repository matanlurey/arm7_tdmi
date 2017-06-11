import 'package:armv4t_asm/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Arm4TParser', () {
    final parser = const Armv4tParser();

    int nullLookup(String varName) {
      fail('No variable ($varName) expected to be looekd up!');
      return null;
    }

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

    group('parseRegister', () {
      test('should parse a register < 10', () {
        expect(parser.parseRegister('R1'), 'R1');
      });

      test('should parse a register >= 10', () {
        expect(parser.parseRegister('R12'), 'R12');
      });

      test('should parse an aliased register', () {
        expect(parser.parseRegister('PC'), 'R15');
      });
    });

    group('parseCpRegister', () {
      test('should parse a register < 10', () {
        expect(parser.parseCpRegister('C1'), 'C1');
      });

      test('should parse a register >= 10', () {
        expect(parser.parseCpRegister('C12'), 'C12');
      });
    });

    group('parseExpression', () {
      test('should parse an immediate value', () {
        expect(parser.parseExpression('#101', nullLookup), 101);
      });

      test('should parse an expression', () {
        expect(parser.parseExpression('1 + 1', nullLookup), 2);
      });

      test('should parse an expression with variables', () {
        expect(
          parser.parseExpression('A + B', (v) {
            if (v == 'A') {
              return 1;
            }
            if (v == 'B') {
              return 2;
            }
          }),
          3,
        );
      });
    });

    group('parseAddress', () {});
  });
}
