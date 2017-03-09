import 'package:binary/binary.dart';

import 'format.dart';
import 'compiler.dart';
import 'package:meta/meta.dart';

final _range = uint32.range;
//bool _match(int format, int mask) => format & mask == mask;

/// Returns some bits from instruction [iw] to be masked.
///
/// **INTERNAL ONLY**.
@visibleForTesting
int compute(int iw) => (iw >> 25) & 0x07;

/// Decodes encoded 32-bit ARMv4t into executable [Instruction] instances.
class ArmDecoder {
  // None of the instructions are yet implemented.
  //
  // ignore: unused_field
  final ArmCompiler _compiler;

  /// Create a new ARM decoder.
  ///
  /// Optionally specify a custom [compiler] strategy.
  const ArmDecoder({ArmCompiler compiler: const ArmCompiler()})
      : _compiler = compiler;

  /// Decodes and returns an executable instance from an ARM [iw].
  Instruction decode(int iw) {
    assert(uint32.inRange(iw), 'Requires a 32-bit input');
    // From https://github.com/smiley22/ARM.JS/blob/gh-pages/Simulator/Cpu.ts.
    switch ((iw >> 25) & 0x07) {
      case 0:
        if ((((iw >> 4) & 0x1FFFFF) ^ 0x12FFF1) == 0) {
          return _decodeBX(iw);
        }
        var b74 = (iw >> 4) & 0xF;
        if (b74 == 9)
          return ((iw >> 24) & 0x01) != 0
              ? _decodeSWI(iw)
              : (((iw >> 23) & 0x01) != 0
                  ? /*mull_mlal*/ null
                  : /*mul_mla*/ null);
        if (b74 == 0xB || b74 == 0xD || b74 == 0xF)
          return /*ldrh_strh_ldrsb_ldrsh*/ null;
        if (((iw >> 23) & 0x03) == 2 && !((iw >> 20) & 0x01 != 0))
          return ((iw >> 21) & 0x01 != 0) ? /*msr*/ null : /*mrs*/ null;
        return _decodeData(iw);
    }
    /*
    if (_match(bits, SoftwareInterruptFormat.mask)) {
      final format = new SoftwareInterruptFormat(i);
      return _compiler.createSWI(
        cond: format.cond,
        routine: format.routine,
      );
    }
    if (_match(bits, CoprocessorRegisterFormat.mask)) {
      final format = new CoprocessorRegisterFormat(i);
      if (isZero(format.l)) {
        // MCR
        return _compiler.createMCR(
          cond: format.cond,
          cpnum: format.cphash,
          op1: format.cp,
          rd: format.rd,
          crn: format.crn,
          crm: format.crm,
          op2: format.cpopc,
        );
      } else {
        // MRC
        return _compiler.createMRC(
          cond: format.cond,
          cpnum: format.cphash,
          op1: format.cp,
          rd: format.rd,
          crn: format.crn,
          crm: format.crm,
          op2: format.cpopc,
        );
      }
    }
    if (_match(bits, CoprocessorDataOperationFormat.mask)) {
      final format = new CoprocessorDataOperationFormat(i);
      return _compiler.createCDP(
        cond: format.cond,
        cpnum: format.cphash,
        op1: format.cp,
        crd: format.crd,
        crn: format.crn,
        crm: format.crm,
        op2: format.cpopc,
      );
    }
    if (_match(bits, CoprocessorTransferFormat.mask)) {
      final format = new CoprocessorTransferFormat(i);
      if (isZero(format.l)) {
        // Store.
        return _compiler.createSTC(
          cond: format.cond,
          cpnum: format.cphash,
          crd: format.crd,
          aMode: null, // ???
        );
      } else {
        return _compiler.createLDC(
          cond: format.cond,
          cpnum: format.cphash,
          crd: format.crd,
          aMode: null, // ???
        );
      }
    }
    if (_match(bits, BranchFormat.mask)) {
      final format = new BranchFormat(i);
      if (isZero(format.l)) {
        return _compiler.createB(
          cond: format.cond,
          label: format.offset,
        );
      } else {
        return _compiler.createBL(
          cond: format.cond,
          label: format.offset,
        );
      }
    }
    if (_match(bits, BlockDataTransferFormat.mask)) {
      final format = new BlockDataTransferFormat(i);
      throw new UnimplementedError('${format.runtimeType}');
    }
    if (_match(bits, UndefinedFormat.mask)) {
      throw new UnsupportedError('Parsed an `Undefined` instruction');
    }
    if (_match(bits, SingleDataTransferFormat.mask)) {
      final format = new SingleDataTransferFormat(i);
      if (isZero(format.l)) {
        // Store to memory.
        if (isZero(format.b)) {
          // Byte
          return _compiler.createSTRByte(
            cond: format.cond,
            user: !isZero(format.u),
            rd: format.rd,
            aMode: null, // ???
          );
        } else {
          // Word
          return _compiler.createSTRWord(
            cond: format.cond,
            user: !isZero(format.u),
            rd: format.rd,
            aMode: null, // ???
          );
        }
      } else {
        // Load from memory.
        if (isZero(format.b)) {
          // Byte.
          return _compiler.createLDRByte(
            cond: format.cond,
            user: !isZero(format.u),
            rd: format.rd,
            aMode: null, // ???
          );
        } else {
          // Word.
          return _compiler.createLDRWord(
            cond: format.cond,
            user: !isZero(format.u),
            rd: format.rd,
            aMode: null, // ???
          );
        }
      }
    }
    if (_match(bits, DataProcessingFormat.mask)) {
      final format = new DataProcessingFormat(i);
      switch (format.opcode) {
        // AND
        case 0x0:
          return _compiler.createAND(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // EOR
        case 0x1:
          return _compiler.createEOR(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // SUB
        case 0x2:
          return _compiler.createSUB(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // RSB
        case 0x3:
          return _compiler.createRSB(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // ADD
        case 0x4:
          return _compiler.createADD(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // ADC
        case 0x5:
          return _compiler.createADC(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // SBC
        case 0x6:
          return _compiler.createSBC(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // RSC
        case 0x7:
          return _compiler.createRSC(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // TST
        case 0x8:
          return _compiler.createTST(
            cond: format.cond,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        // TEQ
        case 0x9:
          return _compiler.createTEQ(
            cond: format.cond,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        // CMP
        case 0xA:
          return _compiler.createCMP(
            cond: format.cond,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        // CMN
        case 0xB:
          return _compiler.createCMN(
            cond: format.cond,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        // ORR
        case 0xC:
          return _compiler.createORR(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // MOV
        case 0xD:
          return _compiler.createMOV(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        // BIC
        case 0xE:
          return _compiler.createBIC(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            rn: format.rn,
            oprnd2: format.operand2,
          );
        // MVN
        case 0xF:
          return _compiler.createMVN(
            cond: format.cond,
            s: format.s,
            rd: format.rd,
            oprnd2: format.operand2,
          );
        default:
          throw new ArgumentError(
            'Could not decode ${uint32.toBinaryPadded(format.opcode)}',
          );
      }
    }
    if (_match(bits, TransferImmediateFormat.mask)) {
      final format = new TransferImmediateFormat(i);
      throw new UnimplementedError('${format.runtimeType}');
    }
    if (_match(bits, TransferRegisterFormat.mask)) {
      final format = new TransferRegisterFormat(i);
      if (isZero(format.l)) {
        // Load.
        return _compiler.createLDRHalfWord(
          cond: format.cond,
          signed: format.s,
          rd: format.rd,
          aMode: null, // ???
        );
      } else {
        // Store.
        return _compiler.createSTRHalfWord(
          cond: format.cond,
          rd: format.rd,
          aMode: null, // ???
        );
      }
    }
    if (_match(bits, BranchAndExchangeFormat.mask)) {
      final format = new BranchAndExchangeFormat(i);
      return _compiler.createBX(
        cond: format.cond,
        rn: format.rn,
      );
    }
    if (_match(bits, SingleDataSwapFormat.mask)) {
      final format = new SingleDataSwapFormat(i);
      if (isZero(format.b)) {
        // Word.
        return _compiler.createSWPWord(
          cond: format.cond,
          rd: format.rd,
          rm: format.rm,
          rn: format.rn,
        );
      } else {
        // Byte.
        return _compiler.createSWPByte(
          cond: format.cond,
          rd: format.rd,
          rm: format.rm,
          rn: format.rn,
        );
      }
    }
    if (_match(bits, MultiplyLongFormat.mask)) {
      final format = new MultiplyLongFormat(i);
      if (isZero(format.a)) {
        if (isZero(format.u)) {
          return _compiler.createUMLAL(
            cond: format.cond,
            s: format.s,
            rdLo: format.rdLo,
            rdHi: format.rdHi,
            rm: format.rm,
            rs: format.rs,
          );
        } else {
          return _compiler.createSMLAL(
            cond: format.cond,
            s: format.s,
            rdLo: format.rdLo,
            rdHi: format.rdHi,
            rm: format.rm,
            rs: format.rs,
          );
        }
      } else {
        if (isZero(format.u)) {
          return _compiler.createUMULL(
            cond: format.cond,
            s: format.s,
            rdLo: format.rdLo,
            rdHi: format.rdHi,
            rm: format.rm,
            rs: format.rs,
          );
        } else {
          return _compiler.createSMULL(
            cond: format.cond,
            s: format.s,
            rdLo: format.rdLo,
            rdHi: format.rdHi,
            rm: format.rm,
            rs: format.rs,
          );
        }
      }
    }
    if (_match(bits, MultiplyFormat.mask)) {
      final format = new MultiplyFormat(i);
      if (isZero(format.a)) {
        return _compiler.createMUL(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          rs: format.rs,
        );
      } else {
        return _compiler.createMLA(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rm: format.rm,
          rn: format.rn,
          rs: format.rs,
        );
      }
    }
    */
    throw new ArgumentError('Could not decode ${uint32.toBinaryPadded(iw)}');
  }

  Instruction _decodeData(int iw) {
    final format = new DataProcessingFormat(iw);
    switch (format.opcode) {
      // AND
      case 0x0:
        return _compiler.createAND(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // EOR
      case 0x1:
        return _compiler.createEOR(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // SUB
      case 0x2:
        return _compiler.createSUB(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // RSB
      case 0x3:
        return _compiler.createRSB(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // ADD
      case 0x4:
        return _compiler.createADD(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // ADC
      case 0x5:
        return _compiler.createADC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // SBC
      case 0x6:
        return _compiler.createSBC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // RSC
      case 0x7:
        return _compiler.createRSC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // TST
      case 0x8:
        return _compiler.createTST(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // TEQ
      case 0x9:
        return _compiler.createTEQ(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // CMP
      case 0xA:
        return _compiler.createCMP(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // CMN
      case 0xB:
        return _compiler.createCMN(
          cond: format.cond,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // ORR
      case 0xC:
        return _compiler.createORR(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // MOV
      case 0xD:
        return _compiler.createMOV(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          oprnd2: format.operand2,
        );
      // BIC
      case 0xE:
        return _compiler.createBIC(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          rn: format.rn,
          oprnd2: format.operand2,
        );
      // MVN
      case 0xF:
        return _compiler.createMVN(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          oprnd2: format.operand2,
        );
    }
    final hexOp = format.opcode.toRadixString(16).toUpperCase();
    throw new ArgumentError('Could not decode opcode 0x${hexOp}');
  }

  Instruction _decodeBX(int iw) {
    final format = new BranchAndExchangeFormat(iw);
    return _compiler.createBX(
      cond: format.cond,
      rn: format.rn,
    );
  }

  Instruction _decodeSWI(int iw) {
    final format = new SoftwareInterruptFormat(iw);
    return _compiler.createSWI(
      cond: format.cond,
      routine: format.routine,
    );
  }
}
