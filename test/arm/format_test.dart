import 'package:arm7_tdmi/src/arm/decoder.dart';
import 'package:arm7_tdmi/src/arm/format.dart';
import 'package:binary/binary.dart';
import 'package:test/test.dart';

void main() {
  group('should decode a', _testMasks);
}

void _testMasks() {
  int _normalize(String example) {
    var bits = <int>[];
    for (var i = 0; i < example.length; i += 2) {
      if (example[i] == '1') {
        bits.add(1);
      } else {
        bits.add(0);
      }
    }
    return uint32.fromBits(bits.toList());
  }

  const {
    SoftwareInterruptFormat: const [
      'Cond*** 1 1 1 1 (Ignored by processor*************************)',
      SoftwareInterruptFormat.mask,
    ],
    CoprocessorRegisterFormat: const [
      'Cond*** 1 1 1 0 CPOpc L CRn**** Rd***** CP#**** CP*** 1 CRm****',
      CoprocessorRegisterFormat.mask,
    ],
    CoprocessorDataOperationFormat: const [
      'Cond*** 1 1 1 0 CP_Opc* CRn**** CRd**** CP#**** CP*** 0 CRm****',
      CoprocessorDataOperationFormat.mask,
    ],
    CoprocessorTransferFormat: const [
      'Cond*** 1 1 0 P U N W L Rn***** CRd**** CP#**** Offset*********',
      CoprocessorTransferFormat.mask,
    ],
    BranchFormat: const [
      'Cond*** 1 0 1 L Offset*****************************************',
      BranchFormat.mask,
    ],
    BlockDataTransferFormat: const [
      'Cond*** 1 0 0 P U S W L Rn***** Register_List******************',
      BlockDataTransferFormat.mask,
    ],
    UndefinedFormat: const [
      'Cond*** 0 1 1 - - - - - - - - - - - - - - - - - - - - 1 - - - -',
      UndefinedFormat.mask,
    ],
    SingleDataTransferFormat: const [
      'Cond*** 0 1 I P U B W L Rn***** Rd***** Offset*****************',
      SingleDataTransferFormat.mask,
    ],
    TransferImmediateFormat: const [
      'Cond*** 0 0 0 P U 1 W L Rn***** Rd***** Offset* 1 S H 1 Offset*',
      TransferImmediateFormat.mask,
    ],
    TransferRegisterFormat: const [
      'Cond*** 0 0 0 P U 0 W L Rn***** Rd***** 0 0 0 0 1 S H 1 Rm*****',
      TransferRegisterFormat.mask,
    ],
    BranchAndExchangeFormat: const [
      'Cond*** 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn*****',
      BranchAndExchangeFormat.mask,
    ],
    SingleDataSwapFormat: const [
      'Cond*** 0 0 0 1 0 B 0 0 Rn***** Rd***** 0 0 0 0 1 0 0 1 Rm*****',
      SingleDataSwapFormat.mask,
    ],
    MultiplyLongFormat: const [
      'Cond*** 0 0 0 0 1 U A S RdHi*** RdLo*** Rs***** 1 0 0 1 Rm*****',
      MultiplyLongFormat.mask,
    ],
    MultiplyFormat: const [
      'Cond*** 0 0 0 0 0 0 A S Rd***** Rn***** Rs***** 1 0 0 1 Rm*****',
      MultiplyFormat.mask,
    ],
  }.forEach((type, check) {
    final example = check[0] as String;
    final mask = check[1] as int;
    final bits = compute(_normalize(example));

    test('$type', () {
      expect(
        bits & mask,
        mask,
        reason: ''
            'Expected ${uint32.toBinaryPadded(bits)} to match $type with mask '
            'of 0x${mask.toRadixString(16).toUpperCase()}, which is the bits '
            '${uint32.toBinaryPadded(mask)}.\n\n'
            'Perhaps mask should be 0x${bits.toRadixString(16).toUpperCase()}?',
      );
    });
  });
}
