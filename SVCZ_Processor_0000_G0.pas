unit SVCZ_Processor_0000_G0;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Processor_0000;

type
  TSVCZProcessor_0000_G0 = class(TSVCZProcessor_0000)
  protected
    // instruction select (group 0)
    procedure InstructionSelect_G0; override;
    // implementation of individual instructions
    procedure Instruction_0_000; virtual;   // HALT
    procedure Instruction_0_001; virtual;   // RELEASE
    procedure Instruction_0_002; virtual;   // WAIT
    procedure Instruction_0_003; virtual;   // SYNC
    procedure Instruction_0_004; virtual;   // NOP
    procedure Instruction_0_005; virtual;   // INVINS
    procedure Instruction_0_006; virtual;   // INFO       *reg,     imm16
    procedure Instruction_0_007; virtual;   // INFO       reg,      reg
    procedure Instruction_0_008; virtual;   // INTCALL    imm8(6)
    procedure Instruction_0_009; virtual;   // INTRET
    procedure Instruction_0_010; virtual;   // INTCALLO
    procedure Instruction_0_011; virtual;   // INTCALLT
    procedure Instruction_0_012; virtual;   // INTGET     reg,      imm8(6)
    procedure Instruction_0_013; virtual;   // INTGET     reg,      reg(6)
    procedure Instruction_0_014; virtual;   // INTSET     imm8(6),  reg
    procedure Instruction_0_015; virtual;   // INTSET     reg(6),   reg
    procedure Instruction_0_016; virtual;   // INTDEF     *reg
    procedure Instruction_0_017; virtual;   // INTCLR     imm8(6)
    procedure Instruction_0_018; virtual;   // INTCLR     *reg(6)
    procedure Instruction_0_019; virtual;   // CALL       imm16
    procedure Instruction_0_020; virtual;   // CALL       *reg
    procedure Instruction_0_021; virtual;   // RET
    procedure Instruction_0_022; virtual;   // RET        imm16
    procedure Instruction_0_023; virtual;   // PUSH       imm16
    procedure Instruction_0_024; virtual;   // PUSH       *reg
    procedure Instruction_0_025; virtual;   // POP        *reg
    procedure Instruction_0_026; virtual;   // PUSHF
    procedure Instruction_0_027; virtual;   // POPF
    procedure Instruction_0_028; virtual;   // PUSHA
    procedure Instruction_0_029; virtual;   // POPA
    procedure Instruction_0_030; virtual;   // STcc
    procedure Instruction_0_031; virtual;   // CLcc
    procedure Instruction_0_032; virtual;   // CMcc
    procedure Instruction_0_033; virtual;   // IN         reg,      imm4
    procedure Instruction_0_034; virtual;   // IN         reg,      reg(4)
    procedure Instruction_0_035; virtual;   // OUT        *imm4,    imm16
    procedure Instruction_0_036; virtual;   // OUT        *reg,     imm16
    procedure Instruction_0_037; virtual;   // OUT        imm4,     reg
    procedure Instruction_0_038; virtual;   // OUT        reg(4),   reg
    procedure Instruction_0_039; virtual;   // MOV        *reg,     FLAGS
    procedure Instruction_0_040; virtual;   // MOV        FLAGS,    *reg
  end;

implementation

uses
  SVCZ_Common, SVCZ_Registers, SVCZ_Instructions, SVCZ_Interrupts, SVCZ_IO,
  SVCZ_Processor;


procedure TSVCZProcessor_0000_G0.InstructionSelect_G0;
begin
case fCurrentInstruction.DecInfo.Index of
   000: fCurrentInstruction.Handler := Instruction_0_000;   // HALT
   001: fCurrentInstruction.Handler := Instruction_0_001;   // RELEASE
   002: fCurrentInstruction.Handler := Instruction_0_002;   // WAIT
   003: fCurrentInstruction.Handler := Instruction_0_003;   // SYNC
   004: fCurrentInstruction.Handler := Instruction_0_004;   // NOP
   005: fCurrentInstruction.Handler := Instruction_0_005;   // INVINS
   006: fCurrentInstruction.Handler := Instruction_0_006;   // INFO       *reg,     imm16
   007: fCurrentInstruction.Handler := Instruction_0_007;   // INFO       reg,      reg
   008: fCurrentInstruction.Handler := Instruction_0_008;   // INTCALL    imm8(6)
   009: fCurrentInstruction.Handler := Instruction_0_009;   // INTRET
   010: fCurrentInstruction.Handler := Instruction_0_010;   // INTCALLO
   011: fCurrentInstruction.Handler := Instruction_0_011;   // INTCALLT
   012: fCurrentInstruction.Handler := Instruction_0_012;   // INTGET     reg,      imm8(6)
   013: fCurrentInstruction.Handler := Instruction_0_013;   // INTGET     reg,      reg(6)
   014: fCurrentInstruction.Handler := Instruction_0_014;   // INTSET     imm8(6),  reg
   015: fCurrentInstruction.Handler := Instruction_0_015;   // INTSET     reg(6),   reg
   016: fCurrentInstruction.Handler := Instruction_0_016;   // INTDEF     *reg
   017: fCurrentInstruction.Handler := Instruction_0_017;   // INTCLR     imm8(6)
   018: fCurrentInstruction.Handler := Instruction_0_018;   // INTCLR     *reg(6)
   019: fCurrentInstruction.Handler := Instruction_0_019;   // CALL       imm16
   020: fCurrentInstruction.Handler := Instruction_0_020;   // CALL       *reg
   021: fCurrentInstruction.Handler := Instruction_0_021;   // RET
   022: fCurrentInstruction.Handler := Instruction_0_022;   // RET        imm16
   023: fCurrentInstruction.Handler := Instruction_0_023;   // PUSH       imm16
   024: fCurrentInstruction.Handler := Instruction_0_024;   // PUSH       *reg
   025: fCurrentInstruction.Handler := Instruction_0_025;   // POP        *reg
   026: fCurrentInstruction.Handler := Instruction_0_026;   // PUSHF
   027: fCurrentInstruction.Handler := Instruction_0_027;   // POPF
   028: fCurrentInstruction.Handler := Instruction_0_028;   // PUSHA
   029: fCurrentInstruction.Handler := Instruction_0_029;   // POPA
   030: fCurrentInstruction.Handler := Instruction_0_030;   // STcc
   031: fCurrentInstruction.Handler := Instruction_0_031;   // CLcc
   032: fCurrentInstruction.Handler := Instruction_0_032;   // CMcc
   033: fCurrentInstruction.Handler := Instruction_0_033;   // IN         reg,      imm4
   034: fCurrentInstruction.Handler := Instruction_0_034;   // IN         reg,      reg(4)
   035: fCurrentInstruction.Handler := Instruction_0_035;   // OUT        *imm4,    imm16
   036: fCurrentInstruction.Handler := Instruction_0_036;   // OUT        *reg,     imm16
   037: fCurrentInstruction.Handler := Instruction_0_037;   // OUT        imm4,     reg
   038: fCurrentInstruction.Handler := Instruction_0_038;   // OUT        reg(4),   reg
   039: fCurrentInstruction.Handler := Instruction_0_039;   // MOV        *reg,     FLAGS
   040: fCurrentInstruction.Handler := Instruction_0_040;   // MOV        FLAGS,    *reg
else
  inherited InstructionSelect_G0;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_000;   // HALT
begin
ArgumentsDecode;
fState := psHalted;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_001;   // RELEASE
begin
ArgumentsDecode;
fState := psReleased;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_002;   // WAIT
begin
ArgumentsDecode;
fState := psWaiting;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_003;   // SYNC
begin
ArgumentsDecode;
fState := psSynchronizing;
If Assigned(fOnSynchronization) then
  fOnSynchronization(Self);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_004;   // NOP
begin
ArgumentsDecode;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_005;   // INVINS
begin
ArgumentsDecode;
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,
        fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_006;   // INFO       *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
ClearFlag(SVCZ_REG_FLAGS_ZERO);
TSVCZProcessorInfoData(GetArgPtr(-1)^) :=
  GetInfoPage(TSVCZProcessorInfoPage(GetArgVal(0)),TSVCZProcessorInfoData(GetArgVal(-1)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_007;   // INFO       reg,      reg
begin
ArgumentsDecode([iatREG,iatREG]);
ClearFlag(SVCZ_REG_FLAGS_ZERO);
TSVCZProcessorInfoData(GetArgPtr(0)^) :=
  GetInfoPage(TSVCZProcessorInfoPage(GetArgVal(1)),TSVCZProcessorInfoData(GetArgVal(0)));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_008;   // INTCALL    imm8(6)
begin
ArgumentsDecode([iatIMM8]);
DispatchInterrupt(TSVCZInterruptIndex(GetArgVal(0) and $3F));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_009;   // INTRET
begin
ArgumentsDecode;
Dec(fInterrupts[SVCZ_FLAGSGetIntIdx(fRegisters.FLAGS)].Counter);
fRegisters.IP := StackPOP;
StackPOP; // discard data
fRegisters.FLAGS := StackPOP;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_010;   // INTCALLO
begin
ArgumentsDecode;
If GetFlag(SVCZ_REG_FLAGS_OVERFLOW) then
  DispatchInterrupt(SVCZ_EXCEPTION_ARITHMETICOVERFLOW);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_011;   // INTCALLT
begin
ArgumentsDecode;
DispatchInterrupt(SVCZ_INT_IDX_TRAP);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_012;   // INTGET     reg,      imm8(6)
begin
ArgumentsDecode([iatREG,iatIMM8]);
TSVCZNative(GetArgPtr(0)^) := fInterrupts[TSVCZInterruptIndex(GetArgVal(1) and $3F)].HandlerAddr;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_013;   // INTGET     reg,      reg(6)
begin
ArgumentsDecode([iatREG,iatREG]);
TSVCZNative(GetArgPtr(0)^) := fInterrupts[TSVCZInterruptIndex(GetArgVal(1) and $3F)].HandlerAddr;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_014;   // INTSET     imm8(6),  reg
begin
ArgumentsDecode([iatIMM8,iatREG]);
fInterrupts[TSVCZInterruptIndex(GetArgVal(0) and $3F)].HandlerAddr := GetArgVal(1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_015;   // INTSET     reg(6),   reg
begin
ArgumentsDecode([iatREG,iatREG]);
fInterrupts[TSVCZInterruptIndex(GetArgVal(0) and $3F)].HandlerAddr := GetArgVal(1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_016;   // INTDEF     *reg
var
  i:  TSVCZInterruptIndex;
begin
ArgumentsDecode(iatREG);
For i := Low(fInterrupts) to High(fInterrupts) do
  fInterrupts[i].HandlerAddr := GetArgVal(-1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_017;   // INTCLR     imm8(6)
begin
ArgumentsDecode([iatIMM8]);
fInterrupts[TSVCZInterruptIndex(GetArgVal(0) and $3F)].HandlerAddr := 0;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_018;   // INTCLR     *reg(6)
begin
ArgumentsDecode(iatREG);
fInterrupts[TSVCZInterruptIndex(GetArgVal(-1) and $3F)].HandlerAddr := 0;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_019;   // CALL       imm16
begin
ArgumentsDecode([iatIMM16]);
StackPUSH(fRegisters.IP);
fRegisters.IP := GetArgVal(0);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_020;   // CALL       *reg
begin
ArgumentsDecode(iatReg);
StackPUSH(fRegisters.IP);
fRegisters.IP := GetArgVal(-1);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_021;   // RET
begin
ArgumentsDecode;
fRegisters.IP := StackPOP;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_022;   // RET        imm16
begin
ArgumentsDecode([iatIMM8]);
fRegisters.IP := StackPOP;
AdvanceSP(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_023;   // PUSH       imm16
begin
ArgumentsDecode([iatIMM16]);
StackPUSH(GetArgVal(0));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_024;   // PUSH       *reg
begin
ArgumentsDecode(iatREG);
StackPUSH(GetArgVal(-1));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_025;   // POP        *reg
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := StackPOP;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_026;   // PUSHF
begin
ArgumentsDecode;
StackPUSH(fRegisters.FLAGS);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_027;   // POPF
begin
ArgumentsDecode;
fRegisters.FLAGS := StackPOP;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_028;   // PUSHA
var
  i:  TSVCZRegisterIndex;
begin
ArgumentsDecode;
For i := Low(fRegisters.GP) to High(fRegisters.GP) do
  StackPUSH(fRegisters.GP[i]);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_029;   // POPA
var
  i:  TSVCZRegisterIndex;
begin
ArgumentsDecode;
For i := High(fRegisters.GP) downto Low(fRegisters.GP) do
  fRegisters.GP[i] := StackPOP;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_030;   // STcc
begin
ArgumentsDecode;
case fCurrentInstruction.DecInfo.Param of
  0:  SetFlag(SVCZ_REG_FLAGS_CARRY);
  1:  SetFlag(SVCZ_REG_FLAGS_PARITY);
  2:  SetFlag(SVCZ_REG_FLAGS_ZERO);
  3:  SetFlag(SVCZ_REG_FLAGS_SIGN);
  4:  SetFlag(SVCZ_REG_FLAGS_OVERFLOW);
  5:  SetFlag(SVCZ_REG_FLAGS_INTERRUPTS);
else
  raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDARGUMENT,GetArgVal(-1));
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_031;   // CLcc
begin
ArgumentsDecode;
case fCurrentInstruction.DecInfo.Param of
  0:  ClearFlag(SVCZ_REG_FLAGS_CARRY);
  1:  ClearFlag(SVCZ_REG_FLAGS_PARITY);
  2:  ClearFlag(SVCZ_REG_FLAGS_ZERO);
  3:  ClearFlag(SVCZ_REG_FLAGS_SIGN);
  4:  ClearFlag(SVCZ_REG_FLAGS_OVERFLOW);
  5:  ClearFlag(SVCZ_REG_FLAGS_INTERRUPTS);
else
  raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDARGUMENT,GetArgVal(-1));
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_032;   // CMcc
begin
ArgumentsDecode;
case fCurrentInstruction.DecInfo.Param of
  0:  ComplementFlag(SVCZ_REG_FLAGS_CARRY);
  1:  ComplementFlag(SVCZ_REG_FLAGS_PARITY);
  2:  ComplementFlag(SVCZ_REG_FLAGS_ZERO);
  3:  ComplementFlag(SVCZ_REG_FLAGS_SIGN);
  4:  ComplementFlag(SVCZ_REG_FLAGS_OVERFLOW);
  5:  ComplementFlag(SVCZ_REG_FLAGS_INTERRUPTS);
else
  raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDARGUMENT,GetArgVal(-1));
end;
end;
//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_033;   // IN         reg,      imm4
begin
ArgumentsDecode([iatREG,iatIMM4]);
PortRequested(TSVCZPortIndex(GetArgVal(1) and $F));
TSVCZNative(GetArgPtr(0)^) := fPorts[TSVCZPortIndex(GetArgVal(1) and $F)].Data;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_034;   // IN         reg,      reg(4)
begin
ArgumentsDecode([iatREG,iatREG]);
PortRequested(TSVCZPortIndex(GetArgVal(1) and $F));
TSVCZNative(GetArgPtr(0)^) := fPorts[TSVCZPortIndex(GetArgVal(1) and $F)].Data;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_035;   // OUT        *imm4,    imm16
begin
ArgumentsDecode(iatIMM4,[iatIMM16]);
fPorts[TSVCZPortIndex(GetArgVal(-1) and $F)].Data := GetArgVal(0);
PortUpdated(TSVCZPortIndex(GetArgVal(-1) and $F));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_036;   // OUT        *reg,     imm16
begin
ArgumentsDecode(iatREG,[iatIMM16]);
fPorts[TSVCZPortIndex(GetArgVal(-1) and $F)].Data := GetArgVal(0);
PortUpdated(TSVCZPortIndex(GetArgVal(-1) and $F));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_037;   // OUT        imm4,     reg
begin
ArgumentsDecode([iatIMM4,iatREG]);
fPorts[TSVCZPortIndex(GetArgVal(0) and $F)].Data := GetArgVal(1);
PortUpdated(TSVCZPortIndex(GetArgVal(0) and $F));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_038;   // OUT        reg(4),   reg
begin
ArgumentsDecode([iatREG,iatREG]);
fPorts[TSVCZPortIndex(GetArgVal(0) and $F)].Data := GetArgVal(1);
PortUpdated(TSVCZPortIndex(GetArgVal(0) and $F));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_039;   // MOV        *reg,     FLAGS
begin
ArgumentsDecode(iatREG);
TSVCZNative(GetArgPtr(-1)^) := fRegisters.FLAGS;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor_0000_G0.Instruction_0_040;   // MOV        FLAGS,    *reg
begin
ArgumentsDecode(iatREG);
fRegisters.FLAGS := GetArgVal(-1);
end;

end.
