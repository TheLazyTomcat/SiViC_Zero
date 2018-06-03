unit SVCZ_Processor_0000_G2;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Processor_0000_G1;

type
  TSVCZProcessor_0000_G2 = class(TSVCZProcessor_0000_G1)
  protected
    // instruction select (group 2)
    procedure InstructionSelect_G2; override;
    // implementation of individual instructions
    procedure Instruction_2_001; virtual;   // LOAD       reg,      [reg]
    procedure Instruction_2_002; virtual;   // LOAD       *reg,     [imm16]
    procedure Instruction_2_003; virtual;   // LOADB      reg(8),   [reg]
    procedure Instruction_2_004; virtual;   // LOADB      *reg(8),  [imm16]
    procedure Instruction_2_005; virtual;   // STORE      [reg],    reg
    procedure Instruction_2_006; virtual;   // STORE      [imm16],  *reg
    procedure Instruction_2_007; virtual;   // STOREB     [reg],    reg(8)
    procedure Instruction_2_008; virtual;   // STOREB     [imm16],  *reg(8)
    procedure Instruction_2_009; virtual;   // MOV        *reg,     imm16
    procedure Instruction_2_010; virtual;   // MOV        reg,      reg
    procedure Instruction_2_011; virtual;   // XCHG       reg,      reg
    procedure Instruction_2_012; virtual;   // BSWAP      *reg
    procedure Instruction_2_013; virtual;   // CVTSX      *reg
    procedure Instruction_2_014; virtual;   // MOVZX      reg,      imm8
    procedure Instruction_2_015; virtual;   // MOVZX      reg,      reg(8)
    procedure Instruction_2_016; virtual;   // MOVSX      reg,      imm8
    procedure Instruction_2_017; virtual;   // MOVSX      reg,      reg(8)
    procedure Instruction_2_018; virtual;   // MCOPY      [reg],    [reg],    reg
    procedure Instruction_2_019; virtual;   // MFILL      [reg],    reg,      imm8
    procedure Instruction_2_020; virtual;   // MFILL      [reg],    reg,      reg(8)
    procedure Instruction_2_021; virtual;   // SETDMA     imm4(2),  [reg],    reg
    procedure Instruction_2_022; virtual;   // SETDMA     reg,      [reg],    reg
  end;

implementation

uses
  SVCZ_Common, SVCZ_Instructions, SVCZ_Interrupts;

procedure TSVCZProcessor_0000_G2.InstructionSelect_G2;
begin
case fCurrentInstruction.DecInfo.Index of
   000: fCurrentInstruction.Handler := Instruction_0_000;   // HALT
   001: fCurrentInstruction.Handler := Instruction_2_001;   // LOAD       reg,      [reg]
   002: fCurrentInstruction.Handler := Instruction_2_002;   // LOAD       *reg,     [imm16]
   003: fCurrentInstruction.Handler := Instruction_2_003;   // LOADB      reg(8),   [reg]
   004: fCurrentInstruction.Handler := Instruction_2_004;   // LOADB      *reg(8),  [imm16]
   005: fCurrentInstruction.Handler := Instruction_2_005;   // STORE      [reg],    reg
   006: fCurrentInstruction.Handler := Instruction_2_006;   // STORE      [imm16],  *reg
   007: fCurrentInstruction.Handler := Instruction_2_007;   // STOREB     [reg],    reg(8)
   008: fCurrentInstruction.Handler := Instruction_2_008;   // STOREB     [imm16],  *reg(8)
   009: fCurrentInstruction.Handler := Instruction_2_009;   // MOV        *reg,     imm16
   010: fCurrentInstruction.Handler := Instruction_2_010;   // MOV        reg,      reg
   011: fCurrentInstruction.Handler := Instruction_2_011;   // XCHG       reg,      reg
   012: fCurrentInstruction.Handler := Instruction_2_012;   // BSWAP      *reg
   013: fCurrentInstruction.Handler := Instruction_2_013;   // CVTSX      *reg
   014: fCurrentInstruction.Handler := Instruction_2_014;   // MOVZX      reg,      imm8
   015: fCurrentInstruction.Handler := Instruction_2_015;   // MOVZX      reg,      reg(8)
   016: fCurrentInstruction.Handler := Instruction_2_016;   // MOVSX      reg,      imm8
   017: fCurrentInstruction.Handler := Instruction_2_017;   // MOVSX      reg,      reg(8)
   018: fCurrentInstruction.Handler := Instruction_2_018;   // MCOPY      [reg],    [reg],    reg
   019: fCurrentInstruction.Handler := Instruction_2_019;   // MFILL      [reg],    reg,      imm8
   020: fCurrentInstruction.Handler := Instruction_2_020;   // MFILL      [reg],    reg,      reg(8)
   021: fCurrentInstruction.Handler := Instruction_2_021;   // SETDMA     imm4(2),  [reg],    reg
   022: fCurrentInstruction.Handler := Instruction_2_022;   // SETDMA     reg,      [reg],    reg
else
  inherited InstructionSelect_G2;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_001;   // LOAD       reg,      [reg]
begin
ArgumentsDecode([iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(1),SVCZ_SZ_NATIVE) then
  begin
    TSVCZNative(GetArgPtr(0)^) := TSVCZNative(fMemory.AddrPtr(GetArgVal(1))^);
  {$IFDEF SVC_Debug}
    DoMemoryReadEvent(GetArgVal(1));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_002;   // LOAD       *reg,     [imm16]
begin
ArgumentsDecode(iatREG,[iatIMM16]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_NATIVE) then
  begin
    TSVCZNative(GetArgPtr(-1)^) := TSVCZNative(fMemory.AddrPtr(GetArgVal(0))^);
  {$IFDEF SVC_Debug}
    DoMemoryReadEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_003;   // LOADB      reg(8),   [reg]
begin
ArgumentsDecode([iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(1),SVCZ_SZ_BYTE) then
  begin
    TSVCZNative(GetArgPtr(0)^) := TSVCZNative(TSVCZByte(fMemory.AddrPtr(GetArgVal(1))^));
  {$IFDEF SVC_Debug}
    DoMemoryReadEvent(GetArgVal(1));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_004;   // LOADB      *reg(8),  [imm16]
begin
ArgumentsDecode(iatREG,[iatIMM16]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_BYTE) then
  begin
    TSVCZNative(GetArgPtr(-1)^) := TSVCZNative(TSVCZByte(fMemory.AddrPtr(GetArgVal(0))^));
  {$IFDEF SVC_Debug}
    DoMemoryReadEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_005;   // STORE      [reg],    reg
begin
ArgumentsDecode([iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_NATIVE) then
  begin
    TSVCZNative(fMemory.AddrPtr(GetArgVal(0))^) := GetArgVal(1);
  {$IFDEF SVC_Debug}
    DoMemoryWriteEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_006;   // STORE      [imm16],  *reg
begin
ArgumentsDecode(iatREG,[iatIMM16]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_NATIVE) then
  begin
    TSVCZNative(fMemory.AddrPtr(GetArgVal(0))^) := GetArgVal(-1);
  {$IFDEF SVC_Debug}
    DoMemoryWriteEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_007;   // STOREB     [reg],    reg(8)
begin
ArgumentsDecode([iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_BYTE) then
  begin
    TSVCZByte(fMemory.AddrPtr(GetArgVal(0))^) := TSVCZByte(GetArgVal(1));
  {$IFDEF SVC_Debug}
    DoMemoryWriteEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_008;   // STOREB     [imm16],  *reg(8)
begin
ArgumentsDecode(iatREG,[iatIMM16]);
If fMemory.IsValidArea(GetArgVal(0),SVCZ_SZ_BYTE) then
  begin
    TSVCZByte(fMemory.AddrPtr(GetArgVal(0))^) := TSVCZByte(GetArgVal(-1));
  {$IFDEF SVC_Debug}
    DoMemoryWriteEvent(GetArgVal(0));
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_009;   // MOV        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
TSVCZNative(GetArgPtr(-1)^) := GetArgVal(0);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_010;   // MOV        reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := GetArgVal(1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_011;   // XCHG       reg,      reg
var
  Temp: TSVCZNative;
begin
ArgumentsDecode([iatREG,iatREG]);
Temp := GetArgVal(0);
TSVCZNative(GetArgPtr(0)^) := GetArgVal(1);
TSVCZNative(GetArgPtr(1)^) := Temp;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_012;   // BSWAP      *reg
var
  Temp: TSVCZNative;
begin
ArgumentsDecode(iatREG);
Temp := GetArgVal(-1);
TSVCZNative(GetArgPtr(-1)^) := TSVCZNative(((Temp and $FF) shl 8) or ((Temp shr 8) and $FF));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_013;   // CVTSX      *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := TSVCZNative(TSVCZSNative(TSVCZSByte(GetArgVal(-1))));  // sign extension
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_014;   // MOVZX      reg,      imm8
begin
ArgumentsDecode([iatREG,iatIMM8]);
TSVCZNative(GetArgPtr(0)^) := GetArgVal(0); // zero extension was already done in args decoding
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_015;   // MOVZX      reg,      reg(8)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(TSVCZByte(GetArgVal(0)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_016;   // MOVSX      reg,      imm8
begin
ArgumentsDecode([iatREG,iatIMM8]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(TSVCZSNative(TSVCZSByte(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_017;   // MOVSX      reg,      reg(8)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := TSVCZNative(TSVCZSNative(TSVCZSByte(GetArgVal(1))));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_018;   // MCOPY      [reg],    [reg],    reg
var
  DstPtr: Pointer;
  SrcPtr: Pointer;
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(0),GetArgVal(2)) then
  begin
    DstPtr := fMemory.AddrPtr(GetArgVal(0));
    If fMemory.IsValidArea(GetArgVal(1),GetArgVal(2)) then
      begin
        SrcPtr := fMemory.AddrPtr(GetArgVal(1));
        System.Move(SrcPtr^,DstPtr^,GetArgVal(2));
      end
    else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(1));
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_019;   // MFILL      [reg],    reg,      imm8
var
  MemPtr: Pointer;
begin
ArgumentsDecode([iatREG,iatREG,iatIMM8]);
If fMemory.IsValidArea(GetArgVal(0),GetArgVal(1)) then
  begin
    MemPtr := fMemory.AddrPtr(GetArgVal(0));
    FillChar(MemPtr^,GetArgVal(1),GetArgVal(2));
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_020;   // MFILL      [reg],    reg,      reg(8)
var
  MemPtr: Pointer;
begin
ArgumentsDecode([iatREG,iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(0),GetArgVal(1)) then
  begin
    MemPtr := fMemory.AddrPtr(GetArgVal(0));
    FillChar(MemPtr^,GetArgVal(1),GetArgVal(2) and $FF);
  end
else raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_021;   // SETDMA     imm4(2),  [reg],    reg
begin
ArgumentsDecode([iatIMM4,iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(1),GetArgVal(2)) then
  fMemory.SetDMAChannel(GetArgVal(0) and $3,GetArgVal(1),GetArgVal(2))
else
  raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G2.Instruction_2_022;   // SETDMA     reg,      [reg],    reg
begin
ArgumentsDecode([iatIMM4,iatREG,iatREG]);
If fMemory.IsValidArea(GetArgVal(1),GetArgVal(2)) then
  fMemory.SetDMAChannel(GetArgVal(0) and $3,GetArgVal(1),GetArgVal(2))
else
  raise ESVCZInterruptException.Create(SVCZ_INT_IDX_MEMORYACCESSEXCEPTION,GetArgVal(1));
end;

end.
