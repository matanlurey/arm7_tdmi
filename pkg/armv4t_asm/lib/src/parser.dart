import 'package:meta/meta.dart';

/// Operation codes implemented by the ARMv4T Architecture.
///
/// _See ARM7TDMI-S Data Sheet, Chapter 4 (ARM Instruction Set)._
const List<String> mnemonics = const [
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
const List<String> conditions = const [
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

class Suffix {
  /// A standard 'S' suffix.
  static const Suffix $S = const Suffix._(suffixes: const ['S']);

  final List<String> suffixes;
  final bool isMode;
  final bool isRequired;

  const Suffix._({
    @required this.suffixes,
    this.isMode: false,
    this.isRequired: false,
  });
}

/// Suffix each mnemonic can or must have.
///
/// Any mnemonic not listed doesn't have supported suffixes.
const Map<String, Suffix> suffixes = const {
  'AND': Suffix.$S,
  'EOR': Suffix.$S,
  'SUB': Suffix.$S,
  'RSB': Suffix.$S,
  'ADD': Suffix.$S,
  'ADC': Suffix.$S,
  'SBC': Suffix.$S,
  'RSC': Suffix.$S,
  'ORR': Suffix.$S,
  'BIC': Suffix.$S,
  'MUL': Suffix.$S,
  'MLA': Suffix.$S,
  'MOV': Suffix.$S,
  'MVN': Suffix.$S,
  'ASR': Suffix.$S,
  'ROR': Suffix.$S,
  'RRX': Suffix.$S,
  'SWP': const Suffix._(suffixes: const ['B']),
  'LDC': const Suffix._(suffixes: const ['L']),
  'STC': const Suffix._(suffixes: const ['L']),
  'LDR': const Suffix._(suffixes: const [
    'FD',
    'ED',
    'FA',
    'EA',
    'IA',
    'IB',
    'DA',
    'DB',
  ], isMode: true, isRequired: true),
  'STM': const Suffix._(suffixes: const [
    'FD',
    'ED',
    'FA',
    'EA',
    'IA',
    'IB',
    'DA',
    'DB',
  ], isMode: true, isRequired: true),
  'UMULL': Suffix.$S,
  'UMLAL': Suffix.$S,
  'SMULL': Suffix.$S,
  'SMLAL': Suffix.$S,
  'LSL': Suffix.$S,
  'LSR': Suffix.$S,
};
