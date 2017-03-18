import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';

import 'format.dart';
import 'compiler.dart';

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
    switch (iw >> 25 & 0x07) {
      case 0:
        if (iw >> 4 & 0x1FFFFF ^ 0x12FFF1 == 0) {
          return _decodeBX(iw);
        }
        final b74 = iw >> 4 & 0xF;
        if (b74 == 9) {
          return iw >> 24 & 0x01 != 0
              ? _decodeSWI(iw)
              : iw >> 23 ^ 0x01 != 0
                  ? _decodeMULL$MLAL(iw)
                  : _decodeMUL$MLA(iw);
        }
        if (b74 == 0xB || b74 == 0xD || b74 == 0xF) {
          return _decodeLDRH$STRH$LDRSB$LDRSH(iw);
        }
        if (iw >> 23 & 0x03 == 2 && iw >> 20 & 0x01 == 0) {
          return (iw >> 21) & 0x01 != 0 ? _decodeMSR(iw) : _decodeMRS(iw);
        }
        return _decodeData(iw);
      case 1:
        if (iw >> 23 & 0x03 == 2 && iw >> 20 & 0x01 == 0) {
          return iw >> 21 & 0x01 != 0 ? _decodeMSR(iw) : _decodeMRS(iw);
        }
        return _decodeData(iw);
      case 2:
        return _decodeLDR$STR(iw);
      case 3:
        return iw >> 4 & 0x01 != 0 ? _undefined(iw) : _decodeLDR$STR(iw);
      case 4:
        return _decodeLDM$STM(iw);
      case 5:
        return _decodeB$BL(iw);
      case 6:
        return _decodeLDC$STC(iw);
      case 7:
        if (iw >> 24 & 0x01 != 0) {
          return _decodeSWI(iw);
        }
        return iw >> 4 & 0x01 != 0 ? _decodeMRC$MCR(iw) : _decodeCDP(iw);
      default:
        return _undefined(iw);
    }
  }

  Instruction _decodeBX(int iw) {
    final format = new BranchAndExchangeFormat(iw);
    return _compiler.createBX(cond: format.cond, rn: format.rn);
  }

  Instruction _decodeSWI(int iw) {
    final format = new SoftwareInterruptFormat(iw);
    return _compiler.createSWI(cond: format.cond, routine: format.routine);
  }

  Instruction _decodeMULL$MLAL(int iw) {
    final format = new MultiplyLongFormat(iw);
    if (format.a) {
      if (format.u) {
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
      if (format.u) {
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

  Instruction _decodeMUL$MLA(int iw) {
    final format = new MultiplyFormat(iw);
    if (format.a) {
      return _compiler.createMLA(
        cond: format.cond,
        s: format.s,
        rd: format.rd,
        rm: format.rm,
        rs: format.rs,
        rn: format.rn,
      );
    } else {
      return _compiler.createMUL(
        cond: format.cond,
        s: format.s,
        rd: format.rd,
        rs: format.rs,
        rn: format.rn,
      );
    }
  }

  Instruction _decodeLDRH$STRH$LDRSB$LDRSH(int iw) {
    final format = new HalfWordTransferRegisterFormat(iw);
    if (format.l) {
      // Load
      if (format.h) {
        // Halfword
        return _compiler.createLDRHalfWord(
          cond: format.cond,
          signed: format.s,
          rd: format.rd,
          aMode: null,
        );
      } else {
        // Byte
        return _compiler.createLDRByte(
          cond: format.cond,
          signed: format.s,
          rd: format.rd,
          aMode: null,
        );
      }
    } else {
      // Store
      if (format.s) {
        if (format.h) {
          // Signed Halfword
          return _compiler.createSTRHalfWord(
            cond: format.cond,
            rd: format.rd,
            aMode: null,
          );
        } else {
          // Signed Byte
          return _compiler.createSTRByte(
            cond: format.cond,
            rd: format.rd,
            aMode: null,
          );
        }
      } else {
        if (format.h) {
          // Unsigned Halfword
          return _compiler.createSTRHalfWord(
            cond: format.cond,
            rd: format.rd,
            aMode: null,
          );
        } else {
          // SWP (???)
          return _compiler.createSWPByte(
            cond: format.cond,
            rd: format.rd,
            rm: format.rm,
            rn: format.rn,
          );
        }
      }
    }
  }

  // Returns a 'Move to Status Register from ARM register' instruction.
  Instruction _decodeMSR(int iw) {
    // TODO: Complete.
    return _compiler.createMSR(
      spsr: null,
      field: null,
      rm: null,
    );
  }

  // Returns a 'Move PSR to General-purpose Register' instruction.
  Instruction _decodeMRS(int iw) {
    // TODO: Move and use within a format.
    return _compiler.createMRS(
      cond: new ArmCondition.fromOpcode(uint32.range(iw, 31, 28)),
      spsr: iw >> 22 & 0x1 != 0,
      rd: iw >> 12 & 0xF,
    );
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
          // ???
          op1: format.rn,
          op2: format.operand2,
        );
      // RSB
      case 0x3:
        return _compiler.createRSB(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          op1: format.rn,
          op2: format.operand2,
        );
      // ADD
      case 0x4:
        return _compiler.createADD(
          cond: format.cond,
          s: format.s,
          rd: format.rd,
          // ???
          op1: format.rn,
          op2: format.operand2,
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
          op1: format.rn,
          op2: format.operand2,
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
          op2: format.operand2,
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
          op2: format.operand2,
        );
    }
    final hexOp = format.opcode.toRadixString(16).toUpperCase();
    throw new ArgumentError('Could not decode opcode 0x${hexOp}');
  }

  Instruction _undefined(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeLDR$STR(int iw) {
    final format = new SingleDataTransferFormat(iw);
    if (format.l) {
      if (format.b) {
        return _compiler.createLDRByte(
          cond: format.cond,
          user: format.u,
          rd: format.rd,
          aMode: format.offset,
        );
      } else {
        return _compiler.createLDRWord(
          cond: format.cond,
          user: format.u,
          rd: format.rd,
          aMode: format.offset,
        );
      }
    } else {
      if (format.b) {
        return _compiler.createSTRByte(
          cond: format.cond,
          user: format.u,
          rd: format.rd,
          aMode: format.offset,
        );
      } else {
        return _compiler.createSTRWord(
          cond: format.cond,
          user: format.u,
          rd: format.rd,
          aMode: format.offset,
        );
      }
    }
  }

  Instruction _decodeLDM$STM(int iw) {
    final format = new BlockDataTransferFormat(iw);
    if (format.l) {
      return _compiler.createLDM(
        cond: format.cond,
        before: format.p,
        add: format.u,
        psr: format.s,
        writeBack: format.w,
        rn: format.rn,
        rd: format.rd,
      );
    } else {
      return _compiler.createSTM(
        cond: format.cond,
        before: format.p,
        add: format.u,
        psr: format.s,
        writeBack: format.w,
        rn: format.rn,
        rd: format.rd,
      );
    }
  }

  Instruction _decodeB$BL(int iw) {
    final format = new BranchFormat(iw);
    return format.l
        ? _compiler.createBL(cond: format.cond, label: format.offset)
        : _compiler.createB(cond: format.cond, label: format.offset);
  }

  Instruction _decodeLDC$STC(int iw) {
    final format = new CoprocessorTransferFormat(iw);
    if (format.l) {
      return _compiler.createLDC(
        cond: format.cond,
        cpnum: format.cpnum,
        crd: format.crd,
        offset: format.offset,
      );
    } else {
      return _compiler.createSTC(
        cond: format.cond,
        cpnum: format.cpnum,
        crd: format.crd,
        offset: format.offset,
      );
    }
  }

  Instruction _decodeMRC$MCR(int iw) {
    final format = new CoprocessorRegisterFormat(iw);
    if (format.l) {
      // Load to register from coprocessor.
      return _compiler.createMRC(
        cond: format.cond,
        cpnum: format.cphash,
        op1: format.cpopc,
        rd: format.rd,
        crn: format.crn,
        crm: format.crm,
        op2: format.cp,
      );
    } else {
      // Store to coprocessor from register.
      return _compiler.createMCR(
        cond: format.cond,
        cpnum: format.cphash,
        op1: format.cpopc,
        rd: format.rd,
        crn: format.crn,
        crm: format.crm,
        op2: format.cp,
      );
    }
  }

  // Returns a 'Coprocessor Data Processing' instruction.
  Instruction _decodeCDP(int iw) {
    throw new UnimplementedError();
  }
}
