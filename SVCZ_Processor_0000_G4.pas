unit SVCZ_Processor_0000_G4;

{$INCLUDE '.\SVCZ_defs.inc'}

interface


uses
  SVCZ_Processor_0000_G3;

type
  TSVCZProcessor_0000_G4 = class(TSVCZProcessor_0000_G3)
  protected
    // instruction select (group 4)
    procedure InstructionSelect_G4; override;
    // implementation of individual instructions
    procedure Instruction_4_001; virtual;   // NOT      *reg
    procedure Instruction_4_002; virtual;   // AND      *reg,     imm16
    procedure Instruction_4_003; virtual;   // AND      reg,      reg
    procedure Instruction_4_004; virtual;   // OR       *reg,     imm16
    procedure Instruction_4_005; virtual;   // OR       reg,      reg
    procedure Instruction_4_006; virtual;   // XOR      *reg,     imm16
    procedure Instruction_4_007; virtual;   // XOR      reg,      reg   
    procedure Instruction_4_008; virtual;   // SHR      *reg
    procedure Instruction_4_009; virtual;   // SHR      reg,      imm4
    procedure Instruction_4_010; virtual;   // SHR      reg,      reg(4)
    procedure Instruction_4_011; virtual;   // SHL      *reg
    procedure Instruction_4_012; virtual;   // SHL      reg,      imm4
    procedure Instruction_4_013; virtual;   // SHL      reg,      reg(4)
    procedure Instruction_4_014; virtual;   // SAR      *reg
    procedure Instruction_4_015; virtual;   // SAR      reg,      imm4
    procedure Instruction_4_016; virtual;   // SAR      reg,      reg(4)
    procedure Instruction_4_017; virtual;   // SAL      *reg
    procedure Instruction_4_018; virtual;   // SAL      reg,      imm4
    procedure Instruction_4_019; virtual;   // SAL      reg,      reg(4)
    procedure Instruction_4_020; virtual;   // ROR      *reg
    procedure Instruction_4_021; virtual;   // ROR      reg,      imm4
    procedure Instruction_4_022; virtual;   // ROR      reg,      reg(4)
    procedure Instruction_4_023; virtual;   // ROL      *reg
    procedure Instruction_4_024; virtual;   // ROL      reg,      imm4
    procedure Instruction_4_025; virtual;   // ROL      reg,      reg(4)
    procedure Instruction_4_026; virtual;   // RCR      *reg
    procedure Instruction_4_027; virtual;   // RCR      reg,      imm4
    procedure Instruction_4_028; virtual;   // RCR      reg,      reg(4)
    procedure Instruction_4_029; virtual;   // RCL      *reg
    procedure Instruction_4_030; virtual;   // RCL      reg,      imm4
    procedure Instruction_4_031; virtual;   // RCL      reg,      reg(4)
    procedure Instruction_4_032; virtual;   // BT       reg,      imm4
    procedure Instruction_4_033; virtual;   // BT       reg,      reg(4)
    procedure Instruction_4_034; virtual;   // BTS      reg,      imm4
    procedure Instruction_4_035; virtual;   // BTS      reg,      reg(4)
    procedure Instruction_4_036; virtual;   // BTR      reg,      imm4
    procedure Instruction_4_037; virtual;   // BTR      reg,      reg(4)
    procedure Instruction_4_038; virtual;   // BTC      reg,      imm4
    procedure Instruction_4_039; virtual;   // BTC      reg,      reg(4)
    procedure Instruction_4_040; virtual;   // BSF      reg,      reg
    procedure Instruction_4_041; virtual;   // BSR      reg,      reg
    procedure Instruction_4_042; virtual;   // SHRD     reg,      reg,      imm4
    procedure Instruction_4_043; virtual;   // SHRD     reg,      reg,      reg(4)
    procedure Instruction_4_044; virtual;   // SHLD     reg,      reg,      imm4
    procedure Instruction_4_045; virtual;   // SHLD     reg,      reg,      reg(4)
  end;

implementation

uses
  AuxTypes, BitOps,
  SVCZ_Common, SVCZ_Registers, SVCZ_Instructions;

procedure TSVCZProcessor_0000_G4.InstructionSelect_G4;
begin
case fCurrentInstruction.DecInfo.Index of
   000: fCurrentInstruction.Handler := Instruction_0_000;   // HALT
   001: fCurrentInstruction.Handler := Instruction_4_001;   // NOT      *reg
   002: fCurrentInstruction.Handler := Instruction_4_002;   // AND      *reg,     imm16
   003: fCurrentInstruction.Handler := Instruction_4_003;   // AND      reg,      reg
   004: fCurrentInstruction.Handler := Instruction_4_004;   // OR       *reg,     imm16
   005: fCurrentInstruction.Handler := Instruction_4_005;   // OR       reg,      reg
   006: fCurrentInstruction.Handler := Instruction_4_006;   // XOR      *reg,     imm16
   007: fCurrentInstruction.Handler := Instruction_4_007;   // XOR      reg,      reg
   008: fCurrentInstruction.Handler := Instruction_4_008;   // SHR      *reg
   009: fCurrentInstruction.Handler := Instruction_4_009;   // SHR      reg,      imm4
   010: fCurrentInstruction.Handler := Instruction_4_010;   // SHR      reg,      reg(4)
   011: fCurrentInstruction.Handler := Instruction_4_011;   // SHL      *reg
   012: fCurrentInstruction.Handler := Instruction_4_012;   // SHL      reg,      imm4
   013: fCurrentInstruction.Handler := Instruction_4_013;   // SHL      reg,      reg(4)
   014: fCurrentInstruction.Handler := Instruction_4_014;   // SAR      *reg
   015: fCurrentInstruction.Handler := Instruction_4_015;   // SAR      reg,      imm4
   016: fCurrentInstruction.Handler := Instruction_4_016;   // SAR      reg,      reg(4)
   017: fCurrentInstruction.Handler := Instruction_4_017;   // SAL      *reg
   018: fCurrentInstruction.Handler := Instruction_4_018;   // SAL      reg,      imm4
   019: fCurrentInstruction.Handler := Instruction_4_019;   // SAL      reg,      reg(4)
   020: fCurrentInstruction.Handler := Instruction_4_020;   // ROR      *reg
   021: fCurrentInstruction.Handler := Instruction_4_021;   // ROR      reg,      imm4
   022: fCurrentInstruction.Handler := Instruction_4_022;   // ROR      reg,      reg(4)
   023: fCurrentInstruction.Handler := Instruction_4_023;   // ROL      *reg
   024: fCurrentInstruction.Handler := Instruction_4_024;   // ROL      reg,      imm4
   025: fCurrentInstruction.Handler := Instruction_4_025;   // ROL      reg,      reg(4)
   026: fCurrentInstruction.Handler := Instruction_4_026;   // RCR      *reg
   027: fCurrentInstruction.Handler := Instruction_4_027;   // RCR      reg,      imm4
   028: fCurrentInstruction.Handler := Instruction_4_028;   // RCR      reg,      reg(4)
   029: fCurrentInstruction.Handler := Instruction_4_029;   // RCL      *reg
   030: fCurrentInstruction.Handler := Instruction_4_030;   // RCL      reg,      imm4
   031: fCurrentInstruction.Handler := Instruction_4_031;   // RCL      reg,      reg(4)
   032: fCurrentInstruction.Handler := Instruction_4_032;   // BT       reg,      imm4
   033: fCurrentInstruction.Handler := Instruction_4_033;   // BT       reg,      reg(4)
   034: fCurrentInstruction.Handler := Instruction_4_034;   // BTS      reg,      imm4
   035: fCurrentInstruction.Handler := Instruction_4_035;   // BTS      reg,      reg(4)
   036: fCurrentInstruction.Handler := Instruction_4_036;   // BTR      reg,      imm4
   037: fCurrentInstruction.Handler := Instruction_4_037;   // BTR      reg,      reg(4)
   038: fCurrentInstruction.Handler := Instruction_4_038;   // BTC      reg,      imm4
   039: fCurrentInstruction.Handler := Instruction_4_039;   // BTC      reg,      reg(4)
   040: fCurrentInstruction.Handler := Instruction_4_040;   // BSF      reg,      reg
   041: fCurrentInstruction.Handler := Instruction_4_041;   // BSR      reg,      reg
   042: fCurrentInstruction.Handler := Instruction_4_042;   // SHRD     reg,      reg,      imm4
   043: fCurrentInstruction.Handler := Instruction_4_043;   // SHRD     reg,      reg,      reg(4)
   044: fCurrentInstruction.Handler := Instruction_4_044;   // SHLD     reg,      reg,      imm4
   045: fCurrentInstruction.Handler := Instruction_4_045;   // SHLD     reg,      reg,      reg(4)
else
  inherited InstructionSelect_G4;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_001;   // NOT      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := not TSVCZNative(GetArgPtr(-1)^); 
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_002;   // AND      *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedAND(GetArgVal(-1),GetArgVal(0)); 
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_003;   // AND      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedAND(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_004;   // OR       *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedOR(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_005;   // OR       reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedOR(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_006;   // XOR      *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedXOR(GetArgVal(-1),GetArgVal(0));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_007;   // XOR      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedXOR(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_008;   // SHR      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSHR(GetArgVal(-1),1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_009;   // SHR      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHR(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_010;   // SHR      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHR(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_011;   // SHL      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSHL(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_012;   // SHL      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHL(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_013;   // SHL      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHL(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_014;   // SAR      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSAR(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_015;   // SAR      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSAR(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_016;   // SAR      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSAR(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_017;   // SAL      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSAL(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_018;   // SAL      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSAL(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_019;   // SAL      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSAL(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_020;   // ROR      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedROR(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_021;   // ROR      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedROR(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_022;   // ROR      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedROR(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_023;   // ROL      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedROL(GetArgVal(-1),1);
end;
  
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_024;   // ROL      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedROL(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_025;   // ROL      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedROL(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_026;   // RCR      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedRCR(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_027;   // RCR      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedRCR(GetArgVal(0),GetArgVal(1));
end;
  
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_028;   // RCR      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedRCR(GetArgVal(0),GetArgVal(1) and $F);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_029;   // RCL      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedRCL(GetArgVal(-1),1);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_030;   // RCL      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedRCL(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_031;   // RCL      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedRCL(GetArgVal(0),GetArgVal(1) and $F);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_032;   // BT       reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(GetArgVal(0),UInt8(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_033;   // BT       reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(GetArgVal(0),UInt8(GetArgVal(1) and $F)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_034;   // BTS      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTS(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_035;   // BTS      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTS(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1) and $F)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_036;   // BTR      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTR(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_037;   // BTR      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTR(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1) and $F)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_038;   // BTC      reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTC(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_039;   // BTC      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,BTC(TSVCZNative(GetArgPtr(0)^),UInt8(GetArgVal(1) and $F)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_040;   // BSF      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(BSF(GetArgVal(1)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_041;   // BSR      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(BSR(GetArgVal(1)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_042;   // SHRD     reg,      reg,      imm4
begin
ArgumentsDecode([iatREG,iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(1)^) := FlaggedSHRD(GetArgVal(1),GetArgVal(0),GetArgVal(2));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_043;   // SHRD     reg,      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedSHRD(GetArgVal(1),GetArgVal(0),GetArgVal(2) and $F);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_044;   // SHLD     reg,      reg,      imm4
begin
ArgumentsDecode([iatREG,iatREG,iatIMM4]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHLD(GetArgVal(1),GetArgVal(0),GetArgVal(2));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G4.Instruction_4_045;   // SHLD     reg,      reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSHLD(GetArgVal(1),GetArgVal(0),GetArgVal(2) and $F);
end;

end.
