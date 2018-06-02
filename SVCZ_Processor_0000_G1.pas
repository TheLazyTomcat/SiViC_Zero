unit SVCZ_Processor_0000_G1;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Processor_0000_G0;

type
  TSVCZProcessor_0000_G1 = class(TSVCZProcessor_0000_G0)
  protected
    // instruction select (group 1)
    procedure InstructionSelect_G1; override;
    // implementation of individual instructions
    procedure Instruction_1_001; virtual;   // CMP        *reg,     imm16
    procedure Instruction_1_002; virtual;   // CMP        reg,      reg
    procedure Instruction_1_003; virtual;   // TEST       *reg,     imm16
    procedure Instruction_1_004; virtual;   // TEST       reg,      reg
    procedure Instruction_1_005; virtual;   // JMP        rel16
    procedure Instruction_1_006; virtual;   // JMP        *reg
    procedure Instruction_1_007; virtual;   // Jcc        rel16
    procedure Instruction_1_008; virtual;   // Jcc        reg
    procedure Instruction_1_009; virtual;   // LOOP       *reg,     rel16
    procedure Instruction_1_010; virtual;   // LOOPcc     reg,      rel8
    procedure Instruction_1_011; virtual;   // SETcc      reg
    procedure Instruction_1_012; virtual;   // CMOVcc     reg,      reg
  end;

implementation

uses
  SVCZ_Common, SVCZ_Instructions;

procedure TSVCZProcessor_0000_G1.InstructionSelect_G1;
begin
case fCurrentInstruction.DecInfo.Index of
   000: fCurrentInstruction.Handler := Instruction_0_000;   // HALT
   001: fCurrentInstruction.Handler := Instruction_1_001;   // CMP        *reg,     imm16
   002: fCurrentInstruction.Handler := Instruction_1_002;   // CMP        reg,      reg
   003: fCurrentInstruction.Handler := Instruction_1_003;   // TEST       *reg,     imm16
   004: fCurrentInstruction.Handler := Instruction_1_004;   // TEST       reg,      reg
   005: fCurrentInstruction.Handler := Instruction_1_005;   // JMP        rel16
   006: fCurrentInstruction.Handler := Instruction_1_006;   // JMP        *reg
   007: fCurrentInstruction.Handler := Instruction_1_007;   // Jcc        rel16
   008: fCurrentInstruction.Handler := Instruction_1_008;   // Jcc        reg
   009: fCurrentInstruction.Handler := Instruction_1_009;   // LOOP       *reg,     rel16
   010: fCurrentInstruction.Handler := Instruction_1_010;   // LOOPcc     reg,      rel8
   011: fCurrentInstruction.Handler := Instruction_1_011;   // SETcc      reg
   012: fCurrentInstruction.Handler := Instruction_1_012;   // CMOVcc     reg,      reg
else
  inherited InstructionSelect_G1;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_001;   // CMP        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
FlaggedSUB(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_002;   // CMP        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
FlaggedSUB(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_003;   // TEST       *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
FlaggedAND(GetArgVal(-1),GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_004;   // TEST       reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
FlaggedAND(GetArgVal(0),GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_005;   // JMP        rel16
begin
ArgumentsDecode([iatREL16]);
AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_006;   // JMP        *reg
begin
ArgumentsDecode(iatREG);
AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_007;   // Jcc        rel16
begin
ArgumentsDecode([iatREL16]);
If EvaluateCondition(fCurrentInstruction.DecInfo.Param) then
  AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_008;   // Jcc        reg
begin
ArgumentsDecode([iatREG]);
If EvaluateCondition(fCurrentInstruction.DecInfo.Param) then
  AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_009;   // LOOP       *reg,     rel16
begin
ArgumentsDecode(iatREG,[iatREL16]);
Dec(TSVCZNative(GetArgPtr(-1)^));
If TSVCZNative(GetArgPtr(-1)^) > 0 then
  AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_010;   // LOOPcc     reg,      rel8
begin
ArgumentsDecode([iatREG,iatREL8]);
Dec(TSVCZNative(GetArgPtr(-1)^));
If (TSVCZNative(GetArgPtr(-1)^) > 0) and EvaluateCondition(fCurrentInstruction.DecInfo.Param) then
  AdvanceIP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_011;   // SETcc      reg
begin
ArgumentsDecode([iatREG]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(SVCZ_BoolToNum(EvaluateCondition(fCurrentInstruction.DecInfo.Param)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G1.Instruction_1_012;   // CMOVcc     reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
If EvaluateCondition(fCurrentInstruction.DecInfo.Param) then
  TSVCZNative(GetArgPtr(0)^) := GetArgVal(1);
end;

end.
