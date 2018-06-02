unit SVCZ_Processor_0000_G3;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Processor_0000_G2;

type
  TSVCZProcessor_0000_G3 = class(TSVCZProcessor_0000_G2)
  protected
    // instruction select (group 3)
    procedure InstructionSelect_G3; override;
    // implementation of individual instructions
    procedure Instruction_3_001; virtual;   // INC        *reg
    procedure Instruction_3_002; virtual;   // DEC        *reg
    procedure Instruction_3_003; virtual;   // NEG        *reg
    procedure Instruction_3_004; virtual;   // ADD        *reg,     imm16
    procedure Instruction_3_005; virtual;   // ADD        reg,      reg
    procedure Instruction_3_006; virtual;   // SUB        *reg,     imm16
    procedure Instruction_3_007; virtual;   // SUB        reg,      reg
    procedure Instruction_3_008; virtual;   // ADC        *reg,     imm16
    procedure Instruction_3_009; virtual;   // ADC        reg,      reg
    procedure Instruction_3_010; virtual;   // SBB        *reg,     imm16
    procedure Instruction_3_011; virtual;   // SBB        reg,      reg
    procedure Instruction_3_012; virtual;   // MUL        *reg,     imm16
    procedure Instruction_3_013; virtual;   // MUL        reg,      reg
    procedure Instruction_3_014; virtual;   // MUL        reg,      reg,      reg
    procedure Instruction_3_015; virtual;   // IMUL       *reg,     imm16
    procedure Instruction_3_016; virtual;   // IMUL       reg,      reg
    procedure Instruction_3_017; virtual;   // IMUL       reg,      reg,      reg
    procedure Instruction_3_018; virtual;   // DIV        *reg,     imm16
    procedure Instruction_3_019; virtual;   // DIV        reg,      reg
    procedure Instruction_3_020; virtual;   // DIV        reg,      reg,      reg
    procedure Instruction_3_021; virtual;   // IDIV       *reg,     imm16
    procedure Instruction_3_022; virtual;   // IDIV       reg,      reg
    procedure Instruction_3_023; virtual;   // IDIV       reg,      reg,      reg
    procedure Instruction_3_024; virtual;   // MOD        *reg,     imm16
    procedure Instruction_3_025; virtual;   // MOD        reg,      reg
    procedure Instruction_3_026; virtual;   // MOD        reg,      reg,      reg
  end;

implementation

uses
  SVCZ_Common, SVCZ_Instructions, SVCZ_Interrupts;

procedure TSVCZProcessor_0000_G3.InstructionSelect_G3;
begin
case fCurrentInstruction.DecInfo.Index of
   000: fCurrentInstruction.Handler := Instruction_0_000;   // HALT
   001: fCurrentInstruction.Handler := Instruction_3_001;   // INC        *reg
   002: fCurrentInstruction.Handler := Instruction_3_002;   // DEC        *reg
   003: fCurrentInstruction.Handler := Instruction_3_003;   // NEG        *reg
   004: fCurrentInstruction.Handler := Instruction_3_004;   // ADD        *reg,     imm16
   005: fCurrentInstruction.Handler := Instruction_3_005;   // ADD        reg,      reg
   006: fCurrentInstruction.Handler := Instruction_3_006;   // SUB        *reg,     imm16
   007: fCurrentInstruction.Handler := Instruction_3_007;   // SUB        reg,      reg
   008: fCurrentInstruction.Handler := Instruction_3_008;   // ADC        *reg,     imm16
   009: fCurrentInstruction.Handler := Instruction_3_009;   // ADC        reg,      reg
   010: fCurrentInstruction.Handler := Instruction_3_010;   // SBB        *reg,     imm16
   011: fCurrentInstruction.Handler := Instruction_3_011;   // SBB        reg,      reg
   012: fCurrentInstruction.Handler := Instruction_3_012;   // MUL        *reg,     imm16
   013: fCurrentInstruction.Handler := Instruction_3_013;   // MUL        reg,      reg
   014: fCurrentInstruction.Handler := Instruction_3_014;   // MUL        reg,      reg,      reg
   015: fCurrentInstruction.Handler := Instruction_3_015;   // IMUL       *reg,     imm16
   016: fCurrentInstruction.Handler := Instruction_3_016;   // IMUL       reg,      reg
   017: fCurrentInstruction.Handler := Instruction_3_017;   // IMUL       reg,      reg,      reg
   018: fCurrentInstruction.Handler := Instruction_3_018;   // DIV        *reg,     imm16
   019: fCurrentInstruction.Handler := Instruction_3_019;   // DIV        reg,      reg
   020: fCurrentInstruction.Handler := Instruction_3_020;   // DIV        reg,      reg,      reg
   021: fCurrentInstruction.Handler := Instruction_3_021;   // IDIV       *reg,     imm16
   022: fCurrentInstruction.Handler := Instruction_3_022;   // IDIV       reg,      reg
   023: fCurrentInstruction.Handler := Instruction_3_023;   // IDIV       reg,      reg,      reg
   024: fCurrentInstruction.Handler := Instruction_3_024;   // MOD        *reg,     imm16
   025: fCurrentInstruction.Handler := Instruction_3_025;   // MOD        reg,      reg
   026: fCurrentInstruction.Handler := Instruction_3_026;   // MOD        reg,      reg,      reg
else
  inherited InstructionSelect_G3;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_001;   // INC        *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedADD(GetArgVal(-1),1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_002;   // DEC        *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSUB(GetArgVal(-1),1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_003;   // NEG        *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := TSVCZNative(-TSVCZNative(GetArgVal(-1)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_004;   // ADD        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedADD(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_005;   // ADD        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedADD(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_006;   // SUB        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSUB(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_007;   // SUB        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSUB(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_008;   // ADC        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedADC(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_009;   // ADC        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedADC(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_010;   // SBB        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedSBB(GetArgVal(-1),GetArgVal(0));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_011;   // SBB        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedSBB(GetArgVal(0),GetArgVal(1));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_012;   // MUL        *reg,     imm16
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedMUL(GetArgVal(-1),GetArgVal(0),Dummy);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_013;   // MUL        reg,      reg
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedMUL(GetArgVal(0),GetArgVal(1),Dummy);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_014;   // MUL        reg,      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedMUL(GetArgVal(1),GetArgVal(2),TSVCZNative(GetArgPtr(0)^));
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_015;   // IMUL       *reg,     imm16
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedIMUL(GetArgVal(-1),GetArgVal(0),Dummy);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_016;   // IMUL       reg,      reg  
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedIMUL(GetArgVal(0),GetArgVal(1),Dummy);
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_017;   // IMUL       reg,      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedIMUL(GetArgVal(1),GetArgVal(2),TSVCZNative(GetArgPtr(0)^));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_018;   // DIV        *reg,     imm16
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedDIV(GetArgVal(-1),0,GetArgVal(0),Dummy);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_019;   // DIV        reg,      reg
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedDIV(GetArgVal(0),0,GetArgVal(1),Dummy);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_020;   // DIV        reg,      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedDIV(GetArgVal(1),GetArgVal(0),GetArgVal(2),TSVCZNative(GetArgPtr(0)^));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_021;   // IDIV       *reg,     imm16
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedIDIV(GetArgVal(-1),0,GetArgVal(0),Dummy);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_022;   // IDIV       reg,      reg
var
  Dummy:  TSVCZNative;
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedIDIV(GetArgVal(0),0,GetArgVal(1),Dummy);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_023;   // IDIV       reg,      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedIDIV(GetArgVal(1),GetArgVal(0),GetArgVal(2),TSVCZNative(GetArgPtr(0)^));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_024;   // MOD        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := FlaggedMOD(GetArgVal(-1),0,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_025;   // MOD        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := FlaggedMOD(GetArgVal(0),0,GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G3.Instruction_3_026;   // MOD        reg,      reg,      reg
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
TSVCZNative(GetArgPtr(1)^) := FlaggedMOD(GetArgVal(1),GetArgVal(0),GetArgVal(2));
end;


end.
