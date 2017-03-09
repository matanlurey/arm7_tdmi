import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

// Run tests that verify the `ArmCondition` class.
//
// These are mainly simple tests that will catch regressions compared to the
// technical manual for what each condition should do - our condition class
// itself is stateless and simple anyway.
void main() {
  test('ArmCondition.all should have the correct opcodes', () {
    ArmCondition.all.forEach((opcode, condition) {
      expect(condition.opcode, opcode);
    });
  });

  _testCase(
    ArmCondition.EQ,
    pass: [
      new Psr(z: true),
    ],
    fail: [
      new Psr(),
    ],
    flip: ArmCondition.NE,
  );

  _testCase(
    ArmCondition.CS,
    pass: [
      new Psr(c: true),
    ],
    fail: [
      new Psr(c: false),
    ],
    flip: ArmCondition.CC,
  );

  _testCase(
    ArmCondition.MI,
    pass: [
      new Psr(n: true),
    ],
    fail: [
      new Psr(n: false),
    ],
    flip: ArmCondition.PL,
  );

  _testCase(
    ArmCondition.VS,
    pass: [
      new Psr(v: true),
    ],
    fail: [
      new Psr(v: false),
    ],
    flip: ArmCondition.VC,
  );

  _testCase(
    ArmCondition.HI,
    pass: [
      new Psr(c: true),
    ],
    fail: [
      new Psr(n: true),
      new Psr(),
    ],
    flip: ArmCondition.LS,
  );

  _testCase(
    ArmCondition.GE,
    pass: [
      new Psr(),
      new Psr(v: true, n: true),
    ],
    fail: [
      new Psr(n: true),
      new Psr(v: true),
    ],
    flip: ArmCondition.LT,
  );

  _testCase(
    ArmCondition.GT,
    pass: [
      new Psr(),
      new Psr(v: true, n: true),
    ],
    fail: [
      new Psr(z: true),
      new Psr(z: true, v: true, n: true),
      new Psr(n: true),
      new Psr(v: true),
    ],
    flip: ArmCondition.LE,
  );

  test('AL should always pass', () {
    expect(ArmCondition.AL.pass(new Psr()), isTrue);
  });

  test('NV should always fail', () {
    expect(ArmCondition.NV.pass(new Psr()), isFalse);
  });
}

// Run a series of expectations of when the condition should pass or fail.
//
// Also defines a `flip` (or reverse) case for the opposite condition.
void _testCase(
  ArmCondition c, {
  @required Iterable<Psr> pass: const [],
  @required Iterable<Psr> fail: const [],
  ArmCondition flip,
}) {
  group('${c.suffix} should', () {
    for (final psr in pass) {
      test('pass for $psr', () {
        expect(c.pass(psr), isTrue);
      });
    }
    for (final psr in fail) {
      test('fail for $psr', () {
        expect(c.pass(psr), isFalse);
      });
    }
  });
  if (flip != null) {
    _testCase(flip, pass: fail, fail: pass);
  }
}
