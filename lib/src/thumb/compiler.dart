import 'package:meta/meta.dart';

import '../arm/compiler.dart';

/// Creates standalone ARM instructions that can be executed on the ARM7/TDMI.
class ThumbCompiler {
  // None of the instructions are yet implemented.
  //
  // ignore: unused_field
  final ArmCompiler _arm;

  /// Creates a new THUMB instruction compiler.
  ///
  /// May optionally specify an [arm] instruction strategy.
  const ThumbCompiler({ArmCompiler arm: const ArmCompiler()}) : _arm = arm;

  // Move ======================================================================

  /// Creates a _MOV_ (move immediate) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MOV Rd, #8bit_Imm
  /// ```
  Instruction createMOVImmediate({
    @required int rd,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  /// Creates a _MOV_ (move high to low) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MOV Rd, Hs
  /// ```
  Instruction createMOVHighToLow({
    @required int rd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  /// Creates a _MOV_ (move low to high) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MOV Rd, Rs
  /// ```
  Instruction createMOVLowToHigh({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  /// Creates a _MOV_ (move high to high) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MOV Hd, Hs
  /// ```
  Instruction createMOVHighToHigh({
    @required int hd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  // Arithmetic ================================================================

  Instruction createADD({
    @required int rd,
    @required int rs,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createADDLowAndLow({
    @required int rd,
    @required int rs,
    @required int rn,
  }) =>
      throw new UnimplementedError();

  Instruction createADDHighToLow({
    @required int rd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  Instruction createADDLowToHigh({
    @required int hd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createADDHighToHigh({
    @required int hd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  Instruction createADDImmediate({
    @required int rd,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createADDValueToSP({
    @required int sp,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createADC({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createSUB({
    @required int rd,
    @required int rs,
    @required int rn,
  }) =>
      throw new UnimplementedError();

  Instruction createSUBImmediate({
    @required int rd,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createSBC({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createNEG({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createMUL({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPLowAndLow({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPLowAndHigh({
    @required int rd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPHighAndLow({
    @required int hd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPHighAndHigh({
    @required int hd,
    @required int hs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPNegative({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createCMPImmediate({
    @required int rd,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  // Logical ===================================================================

  Instruction createAND({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createEOR({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createORR({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createBIC({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createMVN({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createTST({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  // Shift/Rotate ==============================================================

  Instruction createLSL({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createLSR({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createASR({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createROR({
    @required int rd,
    @required int rs,
  }) =>
      throw new UnimplementedError();

  // Branch ====================================================================

  Instruction createBEQ({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBNE({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBCS({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBCC({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBMI({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBPL({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBVS({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBVC({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBHI({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBLS({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBGE({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBLT({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBGT({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBLE({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createB({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBL({
    @required int label,
  }) =>
      throw new UnimplementedError();

  Instruction createBXToLow({
    @required int rs,
  }) =>
      throw new UnimplementedError();

  Instruction createBXToHigh({
    @required int hs,
  }) =>
      throw new UnimplementedError();

  // Load ======================================================================

  Instruction createLDRImmediate({
    @required int rd,
    @required int rb,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRHImmediate({
    @required int rd,
    @required int rb,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRBImmediate({
    @required int rd,
    @required int rb,
    @required int immediate,
  }) =>
      throw new UnimplementedError();

  Instruction createLDROffset({
    @required int rd,
    @required int rb,
    @required int ro,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRHOffset({
    @required int rd,
    @required int rb,
    @required int ro,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRSHOffset({
    @required int rd,
    @required int rb,
    @required int ro,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRBOffset({
    @required int rd,
    @required int rb,
    @required int ro,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRSBOffset({
    @required int rd,
    @required int rb,
    @required int ro,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRPC({
    @required int rd,
    @required int pc,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createLDRSP({
    @required int rd,
    @required int sp,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createADDPC({
    @required int rd,
    @required int pc,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createADDSP({
    @required int rd,
    @required int sp,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createLDMIA({
    @required int rd,
    @required List<int> registers,
  }) =>
      throw new UnimplementedError();

  // Store =====================================================================

  Instruction createSTRImmediate({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTRHImmediate({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTRBImmediate({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTROffset({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTRHOffset({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTRBOffset({
    @required int rd,
    @required int rb,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTRSP({
    @required int rd,
    @required int sp,
    @required int offset,
  }) =>
      throw new UnimplementedError();

  Instruction createSTMIA({
    @required int rd,
    @required List<int> registers,
  }) =>
      throw new UnimplementedError();

  // Push/Pop ==================================================================

  Instruction createPUSH({
    @required List<int> registers,
  }) =>
      throw new UnimplementedError();

  Instruction createPUSHLR({
    @required List<int> registers,
    @required int lr,
  }) =>
      throw new UnimplementedError();

  Instruction createPOP({
    @required List<int> registers,
  }) =>
      throw new UnimplementedError();

  Instruction createPOPPC({
    @required List<int> registers,
    @required int pc,
  }) =>
      throw new UnimplementedError();

  // Software Interrupt ========================================================

  Instruction createSWI({
    @required int immediate,
  }) =>
      throw new UnimplementedError();
}
