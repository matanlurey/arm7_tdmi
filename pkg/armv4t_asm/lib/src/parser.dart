import 'package:meta/meta.dart';

/// Operation codes implemented by the ARMv4T Architecture.
///
/// _See ARM7TDMI-S Data Sheet, Chapter 4 (ARM Instruction Set)._
const List<String> _mnemonics = const <String>[
  'ADC',
  'ADD',
  'AND',
  'B',
  'BIC',
  'BL',
  'BX',
  'CDP',
  'CMN',
  'CMN',
  'CMP',
  'EOR',
  'LDC',
  'LDM',
  'LDR',
  'MCR',
  'MLA',
  'MOV',
  'MRC',
  'MRS',
  'MSR',
  'MUL',
  'MVN',
  'ORR',
  'RSB',
  'RSC',
  'SBC',
  'STC',
  'STM',
  'STR',
  'SUB',
  'SWI',
  'SWP',
  'TEQ',
  'TST',
  'NOP',
  'PUSH',
  'POP',
  'UMULL',
  'UMLAL',
  'SMULL',
  'SMLAL',
  'LSL',
  'LSR',
  'ASR',
  'ROR',
  'RRX',
];

/// Condition codes implemented by the ARMv4T Architecture.
///
/// _See ARM7TDMI-S Data Sheet, 4.2 Condition Fields._
const List<String> _conditions = const <String>[
  'EQ',
  'NE',
  'CS',
  'CC',
  'MI',
  'PL',
  'VS',
  'VC',
  'HI',
  'LS',
  'GE',
  'LT',
  'GT',
  'LE',
  'AL',
];

class _Suffix {
  /// A standard 'S' suffix.
  static const _Suffix $S = const _Suffix(suffixes: const ['S']);

  final List<String> suffixes;
  final bool isMode;
  final bool isRequired;

  const _Suffix({
    @required this.suffixes,
    this.isMode: false,
    this.isRequired: false,
  });
}

/// Suffix each mnemonic can or must have.
///
/// Any mnemonic not listed doesn't have supported suffixes.
const Map<String, _Suffix> _suffixes = const <String, _Suffix>{
  'AND': _Suffix.$S,
  'EOR': _Suffix.$S,
  'SUB': _Suffix.$S,
  'RSB': _Suffix.$S,
  'ADD': _Suffix.$S,
  'ADC': _Suffix.$S,
  'SBC': _Suffix.$S,
  'RSC': _Suffix.$S,
  'ORR': _Suffix.$S,
  'BIC': _Suffix.$S,
  'MUL': _Suffix.$S,
  'MLA': _Suffix.$S,
  'MOV': _Suffix.$S,
  'MVN': _Suffix.$S,
  'ASR': _Suffix.$S,
  'ROR': _Suffix.$S,
  'RRX': _Suffix.$S,
  'SWP': const _Suffix(suffixes: const ['B']),
  'LDC': const _Suffix(suffixes: const ['L']),
  'STC': const _Suffix(suffixes: const ['L']),
  'LDR': const _Suffix(suffixes: const [
    'FD',
    'ED',
    'FA',
    'EA',
    'IA',
    'IB',
    'DA',
    'DB',
  ], isMode: true, isRequired: true),
  'STM': const _Suffix(suffixes: const [
    'FD',
    'ED',
    'FA',
    'EA',
    'IA',
    'IB',
    'DA',
    'DB',
  ], isMode: true, isRequired: true),
  'UMULL': _Suffix.$S,
  'UMLAL': _Suffix.$S,
  'SMULL': _Suffix.$S,
  'SMLAL': _Suffix.$S,
  'LSL': _Suffix.$S,
  'LSR': _Suffix.$S,
};

List<String> _sortedByLength(Iterable<String> strings) =>
    strings.toList()..sort((a, b) => a.length.compareTo(b.length));

/// Implements parsing expressions, assembler directives, operands, mnemonics.
class Armv4tParser {
  static List<String> _sortedMnemonics;

  const Armv4tParser();

  /// Parses the mnemonic and condition field from the [input] string.
  ParsedMnemonic parseMnemonic(String input) {
    final line = input.replaceAll('\t', ' ').trim().split(' ');
    final mnemonic = _parseMnemonic(line[0]);
    final condition = _parseCondition(line[0], mnemonic);
    final suffix = _parseSuffix(line[0], mnemonic, condition);
    return new ParsedMnemonic(mnemonic, suffix, condition);
  }

  // Returns the mnemonic of the instruction to be assembled.
  static String _parseMnemonic(String input) {
    input = input.toUpperCase();
    _sortedMnemonics ??= _sortedByLength(_mnemonics);
    return _sortedMnemonics.firstWhere((m) => input.startsWith(m),
        orElse: () => throw new StateError('Invalid mnemonic: $input'));
  }

  // Returns the suffix, if any, of a mnemonic of an instruction.
  static String _parseSuffix(String input, String mnemonic, String condition) {
    condition ??= '';
    final info = _suffixes[mnemonic];
    if (info == null) {
      return null;
    }
    final look =
        input.substring(mnemonic.length + condition.length).toUpperCase();
    for (final suffix in info.suffixes) {
      if (look.startsWith(suffix)) {
        return suffix;
      }
    }
    if (info.isRequired) {
      throw new StateError('Expected suffix: $input');
    } else {
      return null;
    }
  }

  // Returns the condition, if any, of a mnemonic of an instruction.
  static String _parseCondition(String input, String mnemonic) {
    final look = input.substring(mnemonic.length).toUpperCase();
    for (final condition in _conditions) {
      if (look.startsWith(condition)) {
        return condition;
      }
    }
    return null;
  }
}

class ParsedMnemonic {
  final String mnemonic;
  final String suffix;
  final String condition;

  const ParsedMnemonic(this.mnemonic, [this.suffix, this.condition]);

  @override
  int get hashCode => mnemonic.hashCode ^ suffix.hashCode ^ condition.hashCode;

  @override
  bool operator ==(Object o) =>
      o is ParsedMnemonic &&
      o.mnemonic == mnemonic &&
      o.suffix == suffix &&
      o.condition == condition;

  @override
  String toString() =>
      condition != null ? '$mnemonic${suffix ?? ''}: $condition' : mnemonic;
}
