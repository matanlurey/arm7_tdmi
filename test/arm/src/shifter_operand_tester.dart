import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/arm/addressing_modes/addressing_mode_1.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;
import 'package:test/test.dart';

/// Computes a [Cpu] shifter operand.
///
/// [op1] and [op2] are the first and second operands of the shifter,
/// respectively. [carryFlag] is the initial value of the program status
/// register carry flag.
typedef int OperandComputation(int op1, int op2, bool carryFlag);

/// Computes a [Cpu] carry out.
///
/// See [OperandComputation] for parameter documentation.
typedef bool CarryOutComputation(int op1, int op2, bool carryFlag);

/// A tester for [ImmediateShifter], [RegisterShifter] and [Immediate32Shifter].
///
/// The tester verifies that the shifter correctly computes the auxiliary values
/// shifterOperand and shifterCarryOut for some [Cpu] using different
/// combinations of input data.
class ShifterOperandTester {
  static const _carryFlags = const <bool>[true, false];

  /// Shift register index.
  static const _rs = 1;

  /// Operand register index.
  static const _rm = 2;

  /// The shifter to test.
  final shifter;

  /// Creates a [Cpu] for testing.
  ///
  /// [op1] is the first operand, usually an immediate value. [op2] is the
  /// second operand, usually an immediate shift value. [carryFlag] is the
  /// initial value of the [Cpu] CPSR carry flag.
  static Cpu _cpu(int op1, int op2, bool carryFlag) => new Cpu.noExecution()
    ..gprs[_rs] = op2
    ..gprs[_rm] = op1
    ..cpsr.c = carryFlag;

  /// Returns the description of a test run of shifter using [op1], [op2] and
  /// [carryFlag] as inputs.
  static String _reason(int op1, int op2, bool carryFlag) =>
      '{op1=$op1, op2=$op2, carry=$carryFlag}';

  ShifterOperandTester(this.shifter);

  /// Tests [shifter].
  ///
  /// [firstOperands] and [secondOperands] are lists of shifter inputs whose
  /// ranges are determined by the type of [shifter] being tested.  Invalid
  /// values will raise an [AssertionError].  [expectedOperand] is the expected
  /// shifter operand computation. [expectedCarryOut] is the expected shifter
  /// carry out computation.
  void test({
    @required Iterable<int> firstOperands,
    @required Iterable<int> secondOperands,
    @required OperandComputation expectedOperand,
    @required CarryOutComputation expectedCarryOut,
  }) {
    final shifterRunner = new _ShifterRunner(shifter, _rm, _rs);

    _carryFlags.forEach((carryFlag) {
      firstOperands.forEach((op1) {
        secondOperands.forEach((op2) {
          final cpu = _cpu(op1, op2, carryFlag);
          final reason = _reason(op1, op2, carryFlag);

          var shiftValues = shifterRunner.run(cpu, op1, op2, reason);

          expect(shiftValues.operand, expectedOperand(op1, op2, carryFlag),
              reason: reason);
          expect(shiftValues.carryOut, expectedCarryOut(op1, op2, carryFlag),
              reason: reason);
        });
      });
    });
  }
}

/// Executes a shifter.
abstract class _ShifterRunner {
  factory _ShifterRunner(shifter, int rm, int rs) {
    if (shifter is Immediate32Shifter) {
      return new _Immediate32ShifterRunner(shifter);
    } else if (shifter is ImmediateShifter) {
      return new _ImmediateShifterRunner(shifter, rm);
    } else if (shifter is RegisterShifter) {
      return new _RegisterShifterRunner(shifter, rm, rs);
    } else {
      throw new TypeError();
    }
  }

  /// Executes this runner's shifter.
  ///
  /// [Cpu] is the cpu to execute on. [op1] and [op2] are the first and second
  /// operands to the shifter, respectively.  Reason is a string describing this
  /// test run.
  ShifterValues run(Cpu cpu, int op1, int op2, String reason);
}

class _Immediate32ShifterRunner implements _ShifterRunner {
  final Immediate32Shifter _shifter;

  _Immediate32ShifterRunner(this._shifter);

  @override
  ShifterValues run(Cpu cpu, int immediate, int rotate, String reason) {
    assert(uint4.inRange(rotate), reason);
    assert(uint8.inRange(immediate), reason);

    return _shifter(cpu, rotate: rotate, immediate: immediate);
  }
}

class _ImmediateShifterRunner implements _ShifterRunner {
  final ImmediateShifter _shifter;
  final int _rm;

  _ImmediateShifterRunner(this._shifter, this._rm);

  @override
  ShifterValues run(Cpu cpu, int op1, int shift, String reason) {
    assert(uint32.inRange(op1), reason);
    assert(0 <= shift && shift <= math.pow(2, 6) - 1, reason);

    return _shifter(cpu, shift: shift, rm: _rm);
  }
}

class _RegisterShifterRunner implements _ShifterRunner {
  final RegisterShifter _shifter;
  final int _rm;
  final int _rs;

  _RegisterShifterRunner(this._shifter, this._rm, this._rs);

  @override
  ShifterValues run(Cpu cpu, int op1, int shift, String reason) {
    assert(uint32.inRange(op1), reason);
    assert(uint8.inRange(shift), reason);

    return _shifter(cpu, rs: _rs, rm: _rm);
  }
}
