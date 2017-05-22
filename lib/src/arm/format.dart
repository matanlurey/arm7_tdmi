import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

import 'condition.dart';

/// Boxes an encoded 32-bit ARM instruction based on the format type.
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
abstract class ArmInstructionFormat {
  final int _instruction;

  const ArmInstructionFormat._(this._instruction);

  int _range(int left, int right) => uint32.range(_instruction, left, right);

  int _bit(int bit) => uint32.get(_instruction, bit);

  bool _set(int bit) => uint32.isSet(_instruction, bit);

  /// Decoded condition.
  ArmCondition get cond {
    return new ArmCondition.fromOpcode(_range(31, 28));
  }
}

/// Instruction format for Data Processing/PSR transformer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 1 Opcode* S Rn***** Rd***** Operand2***************
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class DataProcessingFormat extends ArmInstructionFormat {
  @literal
  const DataProcessingFormat(int instruction) : super._(instruction);

  bool get i => _set(25);

  int get opcode => _range(24, 21);

  bool get s => _set(20);

  int get rn => _range(19, 16);

  int get rd => _range(15, 12);

  int get operand2 => _range(11, 0);
}

/// Instruction format for Multiply.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 0 0 0 A S Rd***** Rn***** Rs***** 1 0 0 1 Rm*****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class MultiplyFormat extends ArmInstructionFormat {
  @literal
  const MultiplyFormat(int instruction) : super._(instruction);

  bool get a => _set(21);

  bool get s => _set(20);

  int get rd => _range(19, 16);

  int get rn => _range(15, 12);

  int get rs => _range(11, 8);

  int get rm => _range(3, 0);
}

/// Instruction format for Multiply Long.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 0 1 U A S RdHi*** RdLo*** Rs***** 1 0 0 1 Rm*****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class MultiplyLongFormat extends ArmInstructionFormat {
  @literal
  const MultiplyLongFormat(int instruction) : super._(instruction);

  bool get u => _set(22);

  bool get a => _set(21);

  bool get s => _set(20);

  int get rdHi => _range(19, 16);

  int get rdLo => _range(15, 12);

  int get rs => _range(11, 8);

  int get rm => _range(3, 0);
}

/// Instruction format for Single Data Swap.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 1 0 B 0 0 Rn***** Rd***** 0 0 0 0 1 0 0 1 Rm*****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class SingleDataSwapFormat extends ArmInstructionFormat {
  @literal
  const SingleDataSwapFormat(int instruction) : super._(instruction);

  int get b => _bit(22);

  int get rn => _range(19, 16);

  int get rd => _range(15, 12);

  int get rm => _range(3, 0);
}

/// Instruction format for Branch and Exchange.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn*****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class BranchAndExchangeFormat extends ArmInstructionFormat {
  static const mask = 0x121;

  @literal
  const BranchAndExchangeFormat(int instruction) : super._(instruction);

  int get rn => _range(3, 0);
}

/// Instruction format for Half-word Data Transfer: Register offset.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 P U 0 W L Rn***** Rd***** 0 0 0 0 1 S H 1 Rm*****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class HalfWordTransferRegisterFormat extends ArmInstructionFormat {
  @literal
  const HalfWordTransferRegisterFormat(int instruction) : super._(instruction);

  bool get p => _set(24);

  bool get u => _set(23);

  bool get w => _set(21);

  bool get l => _set(20);

  int get rn => _range(19, 16);

  int get rd => _range(15, 12);

  bool get s => _set(6);

  bool get h => _set(5);

  int get rm => _range(3, 0);
}

/// Instruction format for Half-word Data Transfer: Immediate offset.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 P U 1 W L Rn***** Rd***** Offset* 1 S H 1 Offset*
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class TransferImmediateFormat extends ArmInstructionFormat {
  @literal
  const TransferImmediateFormat(int instruction) : super._(instruction);

  int get p => _bit(24);

  int get u => _bit(23);

  int get w => _bit(21);

  int get l => _bit(20);

  int get rn => _range(19, 16);

  int get rd => _range(15, 12);

  // 11 -> 8 and 3 -> 0.
  int get offset => throw new UnimplementedError();

  bool get s => _set(6);

  int get h => _bit(5);
}

/// Instruction format for Single Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 1 I P U B W L Rn***** Rd***** Offset*****************
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class SingleDataTransferFormat extends ArmInstructionFormat {
  @literal
  const SingleDataTransferFormat(int instruction) : super._(instruction);

  int get i => _bit(25);

  int get p => _bit(24);

  bool get u => _set(23);

  bool get b => _set(22);

  int get w => _bit(21);

  bool get l => _set(20);

  int get rn => _range(19, 16);

  int get rd => _range(15, 12);

  int get offset => _range(11, 0);
}

/// Instruction format for Undefined.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 1 1 - - - - - - - - - - - - - - - - - - - - 1 - - - -
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class UndefinedFormat extends ArmInstructionFormat {
  @literal
  const UndefinedFormat(int instruction) : super._(instruction);
}

/// Instruction format for Block Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 0 0 P U S W L Rn***** Register_List******************
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class BlockDataTransferFormat extends ArmInstructionFormat {
  @literal
  const BlockDataTransferFormat(int instruction) : super._(instruction);

  /// Pre/Post-indexing bit.
  ///
  /// 0 = Post; add offset after transfer.
  /// 1 = Pre; add offset before transfer
  bool get p => _set(24);

  /// Up/Down bit.
  ///
  /// 0 = Down; subtract offset from base.
  /// 1 = Up; add offset to base.
  bool get u => _set(23);

  /// PSR and force user bit.
  ///
  /// 0 = Don't load PSR or force user mode.
  /// 1 = Load PSR or force user mode.
  bool get s => _set(22);

  /// Write-back bit.
  ///
  /// 0 = No write-back.
  /// 1 = Write address into base.
  bool get w => _set(21);

  /// Load/Store bit.
  ///
  /// 0 = Store to memory.
  /// 1 = Load from memory.
  bool get l => _set(20);

  /// Base register.
  int get rn => _range(19, 16);

  /// Register list.
  ///
  /// Each bit corresponds to particular register. For example:
  /// * Bit 0 set causes r0 to be transferred.
  /// * Bit 0 unset causes r0 not to be transferred.
  ///
  /// At least one register must be transferred as the list cannot be empty.
  int get rd => _range(15, 0);
}

/// Instruction format for Branch.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 0 1 L Offset*****************************************
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class BranchFormat extends ArmInstructionFormat {
  @literal
  const BranchFormat(int instruction) : super._(instruction);

  /// Whether to store the instruction of the next address in the link register.
  bool get l => _set(24);

  int get immediate => _range(23, 0);
}

/// Instruction format for Coprocessor Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 0 P U N W L Rn***** CRd**** CP#**** Offset*********
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class CoprocessorTransferFormat extends ArmInstructionFormat {
  @literal
  const CoprocessorTransferFormat(int instruction) : super._(instruction);

  /// Pre/Post increment.
  bool get p => _set(24);

  /// Add/Subtract offset.
  bool get u => _set(23);

  /// Transfer length.
  int get n => _bit(22);

  /// Base register write-back.
  bool get w => _set(21);

  /// Load/store.
  bool get l => _set(20);

  /// Base register.
  int get rn => _range(19, 16);

  /// Source/destination register.
  int get crd => _range(15, 12);

  int get cpnum => _range(11, 8);

  /// Address offset.
  int get offset => _range(7, 0);
}

/// Instruction format for Coprocessor Data Operation.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 0 CP_Opc* CRn**** CRd**** CP#**** CP*** 0 CRm****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class CoprocessorDataOperationFormat extends ArmInstructionFormat {
  @literal
  const CoprocessorDataOperationFormat(int instruction) : super._(instruction);

  int get cpopc => _range(23, 20);

  int get crn => _range(19, 16);

  int get crd => _range(15, 12);

  int get cphash => _range(11, 8);

  int get cp => _range(7, 5);

  int get crm => _range(3, 0);
}

/// Instruction format for Coprocessor Register Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 0 CPOpc L CRn**** Rd***** CP#**** CP*** 1 CRm****
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class CoprocessorRegisterFormat extends ArmInstructionFormat {
  @literal
  const CoprocessorRegisterFormat(int instruction) : super._(instruction);

  int get cpopc => _range(23, 21);

  bool get l => _set(20);

  int get crn => _range(19, 16);

  int get rd => _range(15, 12);

  int get cphash => _range(11, 8);

  int get cp => _range(7, 5);

  int get crm => _range(3, 0);
}

/// Instruction format for Software Interrupt.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 1 (Ignored by processor*************************)
/// ```
///
/// **INTERNAL ONLY**: Used for decoding.
@visibleForTesting
class SoftwareInterruptFormat extends ArmInstructionFormat {
  @literal
  const SoftwareInterruptFormat(int instruction) : super._(instruction);

  int get routine => _range(23, 0);
}
