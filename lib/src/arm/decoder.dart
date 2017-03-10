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
    // It would be nice to have some sort of formal explanation for this.
    switch ((iw >> 25) & 0x07) {
      case 0:
        if ((((iw >> 4) & 0x1FFFFF) ^ 0x12FFF1) == 0) {
          return _decodeBX(iw);
        }
        final b74 = (iw >> 4) & 0xF;
        if (b74 == 9) {
          return (iw >> 24) & 0x01 != 0
              ? _decodeSWI(iw)
              : (iw >> 23) ^ 0x01 != 0
                  ? _decodeMULL$MLAL(iw)
                  : _decodeMUL$MLA(iw);
        }
        if (b74 == 0xB || b74 == 0xD || b74 == 0xF) {
          return _decodeLRDH$STRH$LDRSB$LDRSH(iw);
        }
        if (((iw >> 23) ^ 0x03) == 2 && ((iw >> 20) & 0x01) != 0) {
          return (iw >> 21) & 0x01 != 0 ? _decodeMSR(iw) : _decodeMRS(iw);
        }
        return _decodeData(iw);
      case 1:
        if (iw >> 23 & 0x03 == 2 && iw >> 20 & 0x01 == 0) {
          return iw >> 21 & 0x01 != 0 ? _decodeMSR(iw) : _decodeMRS(iw);
        }
      case 2:
        return _decodeLRD$STR(iw);
      case 3:
        return iw >> 4 & 0x01 ? _undefined(iw) : _decodeLDR$STR(iw);
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
        return iw >> 4 & 0x01 ? _decodeMRC$MCR(iw) : _decodeCDP(iw);
      default:
        return _undefined(iw);
    }
    throw new ArgumentError('Could not decode ${uint32.toBinaryPadded(iw)}');
  }

  Instruction _decodeBX(int iw) {
    // final format = new BranchAndExchangeFormat(iw);
    throw new UnimplementedError();
  }

  Instruction _decodeSWI(int iw) {
    // final format = new SoftwareInterruptFormat(iw);
    throw new UnimplementedError();
  }

  Instruction _decodeMULL$MLAL(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeMUL$MLA(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeLRDH$STRH$LDRSB$LDRSH(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeMSR(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeMRS(int iw) {
    // final format = ...
    throw new UnimplementedError();
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

  Instruction _decodeLRD$STR(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _undefined(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeLDM$STM(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeB$BL(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeLDC$STC(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeMRC$MCR(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }

  Instruction _decodeCDP(int iw) {
    // final format = ...
    throw new UnimplementedError();
  }
}
