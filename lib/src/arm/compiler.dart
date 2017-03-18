library arm7_tdmi.src.arm.compiler;

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

import 'condition.dart';

part 'instructions/adc.dart';
part 'instructions/add.dart';
part 'instructions/and.dart';
part 'instructions/b.dart';
part 'instructions/bic.dart';
part 'instructions/bl.dart';
part 'instructions/bx.dart';
part 'instructions/cdp.dart';
part 'instructions/cmn.dart';
part 'instructions/cmp.dart';
part 'instructions/eor.dart';
part 'instructions/ldc.dart';
part 'instructions/ldm.dart';
part 'instructions/ldr.dart';
part 'instructions/mcr.dart';
part 'instructions/mla.dart';
part 'instructions/mov.dart';
part 'instructions/mrc.dart';
part 'instructions/mrs.dart';
part 'instructions/msr.dart';
part 'instructions/mul.dart';
part 'instructions/mvn.dart';
part 'instructions/orr.dart';
part 'instructions/rsb.dart';
part 'instructions/rsc.dart';
part 'instructions/sbc.dart';
part 'instructions/smlal.dart';
part 'instructions/smull.dart';
part 'instructions/stc.dart';
part 'instructions/stm.dart';
part 'instructions/str.dart';
part 'instructions/sub.dart';
part 'instructions/swi.dart';
part 'instructions/swp.dart';
part 'instructions/teq.dart';
part 'instructions/tst.dart';
part 'instructions/umlal.dart';
part 'instructions/umull.dart';

/// Creates standalone ARM instructions that can be executed on the ARM7/TDMI.
class ArmCompiler {
  const ArmCompiler();

  // Move ======================================================================

  /// Creates a _MOV_ (move) instruction:
  ///
  /// Assembly syntax:
  /// ```
  /// MOV{cond}{S} Rd, <Oprnd2>
  /// ```
  Instruction createMOV({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op2,
  }) =>
      new _ArmInstruction$MOV(
        condition: cond,
        s: s,
        rd: rd,
        op2: op2,
      );

  /// Creates a _MVN_ (move not) instruction:
  ///
  /// Assembly syntax:
  /// ```
  /// MVN{cond}{S} Rd, <Oprnd2>
  /// ```
  Instruction createMVN({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op2,
  }) =>
      new _ArmInstruction$MVN(
        condition: cond,
        s: s,
        rd: rd,
        op2: op2,
      );

  /// Creates a _MRS_ (move CPSR or SPSR to register) instruction.
  ///
  /// Assembly syntax for move SPSR to register:
  /// ```
  /// MRS{cond} Rd, SPSR
  /// ```
  ///
  /// Assembly syntax for move CPSR to register:
  /// ```
  /// MRS{cond} RD, CPSR
  /// ```
  Instruction createMRS({
    ArmCondition cond: ArmCondition.AL,
    @required bool spsr,
    @required int rd,
  }) =>
      new _ArmInstruction$MRS(
        condition: cond,
        spsr: spsr,
        rd: rd,
      );

  /// Creates a _MSR_ (move register) instruction:
  ///
  /// Assembly syntax for move register to SPSR:
  /// ```
  /// MSR{cond} SPSR{field}, Rm
  /// ```
  ///
  /// Assembly syntax for move register to CPSR:
  /// ```
  /// MSR{cond} CPSR{field}, Rm
  /// ```
  Instruction createMSR({
    ArmCondition cond: ArmCondition.AL,
    bool spsr: false,
    @required int field,
    @required int rm,
  }) =>
      new _ArmInstruction$MSR(condition: cond);

  /// Creates a _MSR_ (move immediate) instruction:
  ///
  /// Assembly syntax for move immediate to SPSR flags:
  /// ```
  /// MSR{cond} SPSR_f, #32bit_Imm
  /// ```
  ///
  /// Assembly syntax for move immediate to CPSR flags:
  /// ```
  /// MSR{cond} CPSR_f, #32bit_Imm
  /// ```
  Instruction createMSRImmediate({
    ArmCondition cond: ArmCondition.AL,
    bool spsr: false,
    @required int imm,
  }) =>
      new _ArmInstruction$MSR(condition: cond);

  // Arithmetic ================================================================

  /// Creates a _ADD_ (add) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// ADD{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createADD({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op1,
    @required int op2,
  }) =>
      new _ArmInstruction$ADD(
        condition: cond,
        s: s,
        rd: rd,
        op1: op1,
        op2: op2,
      );

  /// Creates a _ADC_ (add with carry) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// ADC{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createADC({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$ADC(
        condition: cond,
        rd: rd,
        op1: rn,
        op2: oprnd2,
        s: s,
      );

  /// Creates a _SUB_ (subtract) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SUB{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createSUB({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op1,
    @required int op2,
  }) =>
      new _ArmInstruction$SUB(
        condition: cond,
        s: s,
        rd: rd,
        op1: op1,
        op2: op2,
      );

  /// Creates a _SBC_ (subtract with carry) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SBC{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createSBC({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op1,
    @required int op2,
  }) =>
      new _ArmInstruction$SBC(
        condition: cond,
        s: s,
        rd: rd,
        op1: op1,
        op2: op2,
      );

  /// Creates a _RSB_ (subtract reverse subtract) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// RSB{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createRSB({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int op1,
    @required int op2,
  }) =>
      new _ArmInstruction$RSB(
        condition: cond,
        s: s,
        rd: rd,
        op1: op1,
        op2: op2,
      );

  /// Creates a _RSC_ (subtract reverse subtract with carry) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// RSC{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createRSC({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$RSC(condition: cond);

  /// Creates a _MUL_ (multiply) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MUL{cond}{S} Rd, Rn, Rs
  /// ```
  Instruction createMUL({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int rs,
  }) =>
      new _ArmInstruction$MUL(condition: cond);

  /// Creates a _MLA_ (multiply accumulate) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MLA{cond}{S} Rd, Rm, Rs, Rn
  /// ```
  Instruction createMLA({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rm,
    @required int rs,
    @required int rn,
  }) =>
      new _ArmInstruction$MLA(condition: cond);

  /// Creates a _UMULL_ (multiply unsigned long) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// UMULL{cond}{S} RdLo, RdHi, Rm, Rs
  /// ```
  Instruction createUMULL({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rdLo,
    @required int rdHi,
    @required int rm,
    @required int rs,
  }) =>
      new _ArmInstruction$UMULL(condition: cond);

  /// Creates a _UMLAL_ (multiply unsigned accumulate long) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// UMLAL{cond}{S} RdLo, RdHi, Rm, Rs
  /// ```
  Instruction createUMLAL({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rdLo,
    @required int rdHi,
    @required int rm,
    @required int rs,
  }) =>
      new _ArmInstruction$UMLAL(condition: cond);

  /// Creates a _SMULL_ (multiply signed long) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SMULL{cond}{S} RdLo, RdHi, Rm, Rs
  /// ```
  Instruction createSMULL({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rdLo,
    @required int rdHi,
    @required int rm,
    @required int rs,
  }) =>
      new _ArmInstruction$SMULL(condition: cond);

  /// Creates a _SMLAL_ (multiply signed accumulate long) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SMLAL{cond}{S} RdLo, RdHi, Rm, Rs
  /// ```
  Instruction createSMLAL({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rdLo,
    @required int rdHi,
    @required int rm,
    @required int rs,
  }) =>
      new _ArmInstruction$SMLAL(condition: cond);

  /// Creates a _CMP_ (compare) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// CMP{cond} Rd, <Oprnd2>
  /// ```
  Instruction createCMP({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$CMP(condition: cond);

  /// Creates a _CMN_ (compare negative) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// CMN{cond} Rd, <Oprnd2>
  /// ```
  Instruction createCMN({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$CMN(condition: cond);

  // Logical ===================================================================

  /// Creates a _TST_ (test) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// TST{cond} Rn, <Oprnd2>
  /// ```
  Instruction createTST({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$TST(condition: cond);

  /// Creates a _TEQ_ (test equivalence) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// TEQ{cond} Rn, <Oprnd2>
  /// ```
  Instruction createTEQ({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$TEQ(condition: cond);

  /// Creates a _AND_ instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// AND{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createAND({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$AND(condition: cond);

  /// Creates a _EOR_ instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// EOR{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createEOR({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$EOR(condition: cond);

  /// Creates a _ORR_ instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// ORR{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createORR({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$ORR(condition: cond);

  /// Creates a _BIC_ instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// BIC{cond}{S} Rd, Rn, <Oprnd2>
  /// ```
  Instruction createBIC({
    ArmCondition cond: ArmCondition.AL,
    bool s: false,
    @required int rd,
    @required int rn,
    @required int oprnd2,
  }) =>
      new _ArmInstruction$BIC(condition: cond);

  // Branch ====================================================================

  /// Creates a _B_ (branch) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// B{cond} label
  /// ```
  Instruction createB({
    ArmCondition cond: ArmCondition.AL,
    @required int label,
  }) =>
      new _ArmInstruction$B(condition: cond);

  /// Creates a _BL_ (branch with link) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// BL{cond} label
  /// ```
  Instruction createBL({
    ArmCondition cond: ArmCondition.AL,
    @required int label,
    @required int immediate,
  }) =>
      new _ArmInstruction$BL(
        condition: cond,
        immediate: immediate,
      );

  /// Creates a _BX_ (branch and exchange) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// BX{cond} Rn
  /// ```
  Instruction createBX({
    ArmCondition cond: ArmCondition.AL,
    @required int operand,
  }) =>
      new _ArmInstruction$BX(condition: cond, operand: operand);

  // Load ======================================================================

  /// Creates a _LDR_ (word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// LDR{cond} Rd, <a_mode2>
  /// ```
  ///
  /// Assembly syntax for user-mode privilege:
  /// ```
  /// LDR{cond}T Rd, <a_mode2P>
  /// ```
  Instruction createLDRWord({
    ArmCondition cond: ArmCondition.AL,
    bool user: false,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$LDR(condition: cond);

  /// Creates a _LDR_ (byte) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// LDR{cond}B Rd, <a_mode2>
  /// ```
  ///
  /// Assembly syntax for user-mode privilege:
  /// ```
  /// LDR{cond}BT Rd, <a_mode2P>
  /// ```
  ///
  /// Assembly syntax for signed:
  /// ```
  /// LDR{cond}SB Rd, <a_mode3>
  /// ```
  Instruction createLDRByte({
    ArmCondition cond: ArmCondition.AL,
    bool user: false,
    bool signed: false,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$LDR(condition: cond);

  /// Creates a _LDR_ (half-word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// LDR{cond}H Rd, <a_mode3>
  /// ```
  ///
  /// Assembly syntax for signed:
  /// ```
  /// LDR{cond}SH Rd, <a_mode3>
  /// ```
  Instruction createLDRHalfWord({
    ArmCondition cond: ArmCondition.AL,
    bool signed: false,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$LDR(condition: cond);

  /// Create a _LDR_ (load multiple) instruction.
  ///
  /// Allow between 1 and 16 registers to be transferred from memory.
  Instruction createLDM({
    ArmCondition cond: ArmCondition.AL,
    @required bool before,
    @required bool add,
    @required bool psr,
    @required bool writeBack,
    @required int rn,
    @required int rd,
  }) =>
      new _ArmInstruction$LDM(condition: cond);

  // Store =====================================================================

  /// Creates a _STR_ (store word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// STR{cond} Rd, <a_mode2>
  /// ```
  ///
  /// Assembly syntax for user-mode privilege:
  /// ```
  /// STR{cond}T Rd, <a_mode2P>
  /// ```
  Instruction createSTRWord({
    ArmCondition cond: ArmCondition.AL,
    bool user: false,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$STR(condition: cond);

  /// Creates a _STR_ (store byte) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// STR{cond}B Rd, <a_mode2>
  /// ```
  ///
  /// /// Assembly syntax for user-mode privilege:
  /// ```
  /// STR{cond}BT Rd, <a_mode2P>
  /// ```
  Instruction createSTRByte({
    ArmCondition cond: ArmCondition.AL,
    bool user: false,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$STR(condition: cond);

  /// Creates a _STR_ (store half-word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// STR{cond}H Rd, <a_mode3>
  /// ```
  Instruction createSTRHalfWord({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int aMode,
  }) =>
      new _ArmInstruction$STR(condition: cond);

  /// Create a _STM_ (store multiple) instruction.
  ///
  /// Allow between 1 and 16 registers to be transferred from memory.
  Instruction createSTM({
    ArmCondition cond: ArmCondition.AL,
    @required bool before,
    @required bool add,
    @required bool psr,
    @required bool writeBack,
    @required int rn,
    @required int rd,
  }) =>
      new _ArmInstruction$STM(condition: cond);

  // Swap ======================================================================

  /// Creates a _SWP_ (swap word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SWP{cond} Rd, Rm, [Rn]
  /// ```
  Instruction createSWPWord({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int rm,
    @required int rn,
  }) =>
      new _ArmInstruction$SWP(condition: cond);

  /// Creates a _SWP_ (swap word) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SWP{cond}B Rd, Rm, [Rn]
  /// ```
  Instruction createSWPByte({
    ArmCondition cond: ArmCondition.AL,
    @required int rd,
    @required int rm,
    @required int rn,
  }) =>
      new _ArmInstruction$SWP(condition: cond);

  // Coprocessors ==============================================================

  /// Creates a _CDP_ (coprocessor data operation) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// CDP{cond} p<cpnum>, <op1>, CRd, CRn, CRm, <op2>
  /// ```
  Instruction createCDP({
    ArmCondition cond: ArmCondition.AL,
    @required int cpnum,
    @required int op1,
    @required int crd,
    @required int crn,
    @required int crm,
    @required int op2,
  }) =>
      new _ArmInstruction$CDP(condition: cond);

  /// Creates a _MRC_ (move ARM register from coprocessor) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MRC{cond} p<cpnum>, <op1>, Rd, CRn, CRm, <op2>
  /// ```
  Instruction createMRC({
    ArmCondition cond: ArmCondition.AL,
    @required int cpnum,
    @required int op1,
    @required int rd,
    @required int crn,
    @required int crm,
    @required int op2,
  }) =>
      new _ArmInstruction$MRC(condition: cond);

  /// Creates a _MCR_ (move to coprocessor from ARM register) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// MCR{cond} p<cpnum>, <op1>, Rd, CRn, CRm, <op2>
  /// ```
  Instruction createMCR({
    ArmCondition cond: ArmCondition.AL,
    @required int cpnum,
    @required int op1,
    @required int rd,
    @required int crn,
    @required int crm,
    @required int op2,
  }) =>
      new _ArmInstruction$MCR(condition: cond);

  /// Creates a _LDC_ (load) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// LDC{cond} p<cpnum>, CRd, <a_mode5>
  /// ```
  Instruction createLDC({
    ArmCondition cond: ArmCondition.AL,
    @required int cpnum,
    @required int crd,
    @required int offset,
  }) =>
      new _ArmInstruction$LDC(condition: cond);

  /// Creates a _STC_ (store) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// STC{cond} p<cpnum>, CRd, <a_mode5>
  /// ```
  Instruction createSTC({
    ArmCondition cond: ArmCondition.AL,
    @required int cpnum,
    @required int crd,
    @required int offset,
  }) =>
      new _ArmInstruction$STC(condition: cond);

  // Software Interrupt ========================================================

  /// Creates a _SWI_ (software interrupt) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// SWI 24bit_Imm
  /// ```
  Instruction createSWI({
    ArmCondition cond: ArmCondition.AL,
    @required int routine,
  }) =>
      new _ArmInstruction$SWI(condition: cond);
}

abstract class Instruction {
  /// Condition for the instruction to execute.
  final ArmCondition condition;

  /// Syntax name of the instruction.
  final String name;

  const Instruction._({
    @required this.condition,
    @required this.name,
  });

  /// Runs the instruction on the provided [cpu].
  ///
  /// Returns how many cycles the instruction takes to execute.
  int execute(Cpu cpu);
}
