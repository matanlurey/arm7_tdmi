library arm7_tdmi.src.arm.condition;

import 'package:meta/meta.dart';

import '../registers.dart';

part 'conditions/eq.dart';
part 'conditions/ne.dart';
part 'conditions/cs.dart';
part 'conditions/cc.dart';
part 'conditions/mi.dart';
part 'conditions/pl.dart';
part 'conditions/vs.dart';
part 'conditions/vc.dart';
part 'conditions/hi.dart';
part 'conditions/ls.dart';
part 'conditions/ge.dart';
part 'conditions/lt.dart';
part 'conditions/gt.dart';
part 'conditions/le.dart';
part 'conditions/al.dart';
part 'conditions/nv.dart';

abstract class ArmCondition {
  /// Mapping of [ArmCondition.opcode] to the corresponding [ArmCondition].
  ///
  /// **INTERNAL ONLY**: Not meant to be used by end-users.
  @visibleForTesting
  static const all = const <int, ArmCondition>{
    0x0: EQ,
    0x1: NE,
    0x2: CS,
    0x3: CC,
    0x4: MI,
    0x5: PL,
    0x6: VS,
    0x7: VC,
    0x8: HI,
    0x9: LS,
    0xA: GE,
    0xB: LT,
    0xC: GT,
    0xD: LE,
    0xE: AL,
    0xF: NV,
  };

  /// Equal (Z set).
  static const ArmCondition EQ = const _ArmCondition$EQ();

  /// Not equal (Z cleared).
  static const ArmCondition NE = const _ArmCondition$NE();

  /// Unsigned higher, or same (C set).
  static const ArmCondition CS = const _ArmCondition$CS();

  /// Unsigned lower (C cleared).
  static const ArmCondition CC = const _ArmCondition$CC();

  /// Negative (N set).
  static const ArmCondition MI = const _ArmCondition$MI();

  /// Positive, or zero (N clear).
  static const ArmCondition PL = const _ArmCondition$PL();

  /// Overflow (V set).
  static const ArmCondition VS = const _ArmCondition$VS();

  /// No overflow (V cleared).
  static const ArmCondition VC = const _ArmCondition$VC();

  /// Unsigned higher (C set, Z clear).
  static const ArmCondition HI = const _ArmCondition$HI();

  /// Unsigned lower, or same (C clear, Z set).
  static const ArmCondition LS = const _ArmCondition$LS();

  /// Greater, or equal (N=V; N V set or N and V clear).
  static const ArmCondition GE = const _ArmCondition$GE();

  /// Less than (N<>V; N set V clear or N clear V set).
  static const ArmCondition LT = const _ArmCondition$LT();

  /// Greater than (Z clear, N=V; N V set or N V clear).
  static const ArmCondition GT = const _ArmCondition$GT();

  /// Less than, or equal (Z set or N<>V; N set V clear or N clear V set).
  static const ArmCondition LE = const _ArmCondition$LE();

  /// Always (flag ignored).
  static const ArmCondition AL = const _ArmCondition$AL();

  /// Undefined (instruction ignored).
  static const ArmCondition NV = const _ArmCondition$NV();

  /// Returns an [ArmCondition] instance for the provided [opcode].
  factory ArmCondition.fromOpcode(int opcode) {
    final condition = all[opcode];
    assert(condition != null, 'No condition for 0x${opcode.toRadixString(16)}');
    return condition;
  }

  /// 4-bit code that identifies this condition in an ARM instruction.
  final int opcode;

  /// 2-character assembler representation of this condition.
  final String suffix;

  /// What flags are necessary on the register to pass this flag.
  final String flags;

  /// Textual representation of the flag state required.
  final String meaning;

  const ArmCondition._({
    @required this.opcode,
    @required this.suffix,
    @required this.flags,
    @required this.meaning,
  });

  /// Returns whether the current state of the [flags] pass this condition.
  bool pass(Psr flags);

  @override
  String toString() => suffix;
}
