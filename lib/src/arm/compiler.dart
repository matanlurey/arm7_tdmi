library arm7_tdmi.src.arm.compiler;

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
    @required int oprnd2,
  }) =>
      const _ArmInstruction$MOV();

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
    @required int oprnd2,
  }) =>
      const _ArmInstruction$MVN();

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
    bool spsr: false,
    @required int rd,
  }) =>
      const _ArmInstruction$MRS();

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
      const _ArmInstruction$MSR();

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
      const _ArmInstruction$MSR();

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
    @required int rn,
    @required int oprnd2,
  }) =>
      const _ArmInstruction$ADD();

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
      const _ArmInstruction$ADC();

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
    @required int rn,
    @required int oprnd2,
  }) =>
      const _ArmInstruction$SUB();

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
    @required int rn,
    @required int oprnd2,
  }) =>
      const _ArmInstruction$SBC();

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
    @required int rn,
    @required int oprnd2,
  }) =>
      const _ArmInstruction$RSB();

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
      const _ArmInstruction$RSC();

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
      const _ArmInstruction$MUL();

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
      const _ArmInstruction$MLA();

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
      const _ArmInstruction$UMULL();

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
      const _ArmInstruction$UMLAL();

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
      const _ArmInstruction$SMULL();

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
      const _ArmInstruction$SMLAL();

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
      const _ArmInstruction$CMP();

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
      const _ArmInstruction$CMN();

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
      const _ArmInstruction$TST();

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
      const _ArmInstruction$TEQ();

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
      const _ArmInstruction$AND();

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
      const _ArmInstruction$EOR();

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
      const _ArmInstruction$ORR();

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
      const _ArmInstruction$BIC();

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
      const _ArmInstruction$B();

  /// Creates a _BL_ (branch with link) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// BL{cond} label
  /// ```
  Instruction createBL({
    ArmCondition cond: ArmCondition.AL,
    @required int label,
  }) =>
      const _ArmInstruction$BL();

  /// Creates a _BX_ (branch and exchange) instruction.
  ///
  /// Assembly syntax:
  /// ```
  /// BX{cond} Rn
  /// ```
  Instruction createBX({
    ArmCondition cond: ArmCondition.AL,
    @required int rn,
  }) =>
      const _ArmInstruction$BX();

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
      const _ArmInstruction$LDR();

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
      const _ArmInstruction$LDR();

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
      const _ArmInstruction$LDR();

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
      const _ArmInstruction$LDM();

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
      const _ArmInstruction$STR();

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
      const _ArmInstruction$STR();

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
      const _ArmInstruction$STR();

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
      const _ArmInstruction$STM();

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
      const _ArmInstruction$SWP();

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
      const _ArmInstruction$SWP();

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
      const _ArmInstruction$CDP();

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
      const _ArmInstruction$MRC();

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
      const _ArmInstruction$MCR();

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
      const _ArmInstruction$LDC();

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
      const _ArmInstruction$STC();

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
      const _ArmInstruction$SWI();
}

abstract class Instruction {
  /// Syntax name of the instruction.
  final String name;

  const Instruction._({@required this.name});

  /// Condition for the instruction to execute.
  ArmCondition get condition;

  /// How many cycles the instruction takes to execute.
  int get cycles;
}
