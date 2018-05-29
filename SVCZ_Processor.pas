unit SVCZ_Processor;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SysUtils,
  AuxClasses, // for TNotifyEvent
  SVCZ_Common,
  SVCZ_Memory,
  SVCZ_Registers,
  SVCZ_Instructions,
  SVCZ_Interrupts,
  SVCZ_IO;

type
  TSVCZProcessorState = (psUninitialized,psInitialized,psRunning,psHalted,
                         psReleased,psWaiting,psSynchronizing,psFailed);

  // processor (system) information
  TSVCZProcessorInfoPage = TSVCZNative;
  TSVCZProcessorInfoData = TSVCZNative;

  TSVCZProcessor = class(TObject)
  private
    fFaultClass:          String;
    fFaultMessage:        String;
  {$IFDEF SVC_Debug}
    fOnBeforeInstruction: TNotifyEvent;
    fOnAfterInstruction:  TNotifyEvent;
    fOnMemoryRead:        TSVCZMemoryAccessEvent;
    fOnMemoryWrite:       TSVCZMemoryAccessEvent;
  {$ENDIF SVC_Debug}
  protected
    fExecutionCount:      UInt64;
    // internal processor state
    fState:               TSVCZProcessorState;
    fMemory:              TSVCZMemory;
    fRegisters:           TSVCZRegisters;
    fInterruptHandlers:   TSVCZInterruptHandlers;
    fPorts:               TSVCZPorts;
    // currently processed instruction
    fCurrentInstruction:  TSVCZInstructionInfo;
    // synchronization stuff
    fOnSynchronization:   TNotifyEvent;
    // processor state setup and clearing
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    // processor info engine
    Function GetInfoPage(Page: TSVCZProcessorInfoPage; Param: TSVCZProcessorInfoData): TSVCZProcessorInfoData; virtual;
    // memory access
  {$IFDEF SVC_Debug}
    procedure DoMemoryReadEvent(Address: TSVCZNative); virtual;
    procedure DoMemoryWriteEvent(Address: TSVCZNative); virtual;
  {$ENDIF SVC_Debug}
    // stack access and manipulation
    procedure StackPUSH(Value: TSVCZNative); virtual;
    Function StackPOP: TSVCZNative; virtual;
    // general purpose registers access
    Function GetGPRPtr(RegisterIndex: TSVCZRegisterIndex): Pointer; virtual;
    Function GetGPRVal(RegisterIndex: TSVCZRegisterIndex): TSVCZNative; virtual;
    procedure SetGPRVal(RegisterIndex: TSVCZRegisterIndex; NewValue: TSVCZNative); virtual;
    // FLAGS register access and evaluation
    Function GetFlag(FlagMask: TSVCZNative): Boolean; virtual;
    procedure SetFlag(FlagMask: TSVCZNative); virtual;
    procedure ClearFlag(FlagMask: TSVCZNative); virtual;
    procedure ComplementFlag(FlagMask: TSVCZNative); virtual;
    procedure SetFlagValue(FlagMask: TSVCZNative; NewValue: Boolean); virtual;
    Function EvaluateCondition(ConditionCode: TSVCZInstructionConditionCode): Boolean; virtual;
    // registers advance macros
    procedure AdvanceIP(Shift: TSVCZNative); virtual;
    procedure AdvanceSP(Shift: TSVCZNative); virtual;
    // interrupt access and handling
    procedure HandleException(E: Exception); virtual;
    procedure DispatchInterrupt(InterruptIndex: TSVCZInterruptIndex; Data: TSVCZNative = 0); virtual;
    // IO, hardware
    procedure PortUpdated(PortIndex: TSVCZPortIndex); virtual;
    procedure PortRequested(PortIndex: TSVCZPortIndex); virtual;
    // current instruction arguments access
    Function GetArgVal(ArgIndex: Integer): TSVCZNative; virtual;
    Function GetArgPtr(ArgIndex: Integer): Pointer; virtual;
    // execution engine
    procedure InvalidateInstructionData; virtual;
    procedure ExecuteNextInstruction; virtual;
    procedure InstructionFetch; virtual;
    procedure InstructionIssue; virtual;
    procedure InstructionDecode; virtual;
    procedure InstructionExecute; virtual;
    // instruction decoding
    procedure ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType; ArgumentList: array of TSVCZInstructionArgumentType); overload; virtual;
    procedure ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType = iatNone); overload; virtual;
    procedure InstructionSelectGroup; virtual;
    // select instruction in group
    procedure InstructionSelect_G0; virtual;
    procedure InstructionSelect_G1; virtual;
    procedure InstructionSelect_G2; virtual;
    procedure InstructionSelect_G3; virtual;
    procedure InstructionSelect_G4; virtual;
    procedure InstructionSelect_G5; virtual;
    procedure InstructionSelect_G6; virtual;
    procedure InstructionSelect_G7; virtual;
  public
    constructor Create(Memory: TSVCZMemory);
    destructor Destroy; override; 
    //procedure ExecuteInstruction(OPCode: TSVCZInstructionOPCode; Data: TSVCZInstructionData); virtual;
    //Function Run(InstructionCount: Integer = 1): Integer; virtual;
  {$IFDEF SVC_Debug}
    // for debugging purposes...
    property Memory: TSVCZMemory read fMemory;
    property Registers: TSVCZRegisters read fRegisters;
    property InterruptHandlers: TSVCZInterruptHandlers read fInterruptHandlers;
    property Ports: TSVCZPorts read fPorts;
  {$ENDIF SVC_Debug}
    property State: TSVCZProcessorState read fState;
    property ExecutionCount: UInt64 read fExecutionCount;
    property FaultClass: String read fFaultClass;
    property FaultMessage: String read fFaultMessage;
    property OnSynchronization: TNotifyEvent read fOnSynchronization write fOnSynchronization;
  {$IFDEF SVC_Debug}
    property OnBeforeInstruction: TNotifyEvent read fOnBeforeInstruction write fOnBeforeInstruction;
    property OnAfterInstruction: TNotifyEvent read fOnAfterInstruction write fOnAfterInstruction;
    property OnMemoryRead: TSVCZMemoryAccessEvent read fOnMemoryRead write fOnMemoryRead;
    property OnMemoryWrite: TSVCZMemoryAccessEvent read fOnMemoryWrite write fOnMemoryWrite;
  {$ENDIF SVC_Debug}
  end;

implementation

Function TSVCZProcessor.GetInfoPage(Page: TSVCZProcessorInfoPage; Param: TSVCZProcessorInfoData): TSVCZProcessorInfoData;
begin
{for invalid and unimplemented pages}
Result := 0;
SetFlag(SVCZ_REG_FLAGS_ZERO);
end;

//------------------------------------------------------------------------------

{$IFDEF SVC_Debug}

procedure TSVCZProcessor.DoMemoryReadEvent(Address: TSVCZNative);
begin
If Assigned(fOnMemoryRead) then
  fOnMemoryRead(Self,Address);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.DoMemoryWriteEvent(Address: TSVCZNative);
begin
If Assigned(fOnMemoryWrite) then
  fOnMemoryWrite(Self,Address);
end;

{$ENDIF SVC_Debug}

//------------------------------------------------------------------------------

procedure TSVCZProcessor.StackPUSH(Value: TSVCZNative);
begin
If (fRegisters.GP[REG_SP] and 1) = 0 then
  begin
    AdvanceSP(TSVCZNative(-SVCZ_SZ_NATIVE));
    TSVCZNative(fMemory.AddrPtr(fRegisters.GP[REG_SP])^) := Value;
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_MEMORYALIGNMENT,fRegisters.GP[REG_SP]);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.StackPOP: TSVCZNative;
begin
If (fRegisters.GP[REG_SP] and 1) = 0 then
  begin
    Result := TSVCZNative(fMemory.AddrPtr(fRegisters.GP[REG_SP])^);
    AdvanceSP(SVCZ_SZ_NATIVE);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_MEMORYALIGNMENT,fRegisters.GP[REG_SP]);    
end;
 
//------------------------------------------------------------------------------

Function TSVCZProcessor.GetGPRPtr(RegisterIndex: TSVCZRegisterIndex): Pointer;
begin
Result := Addr(fRegisters.GP[RegisterIndex]);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetGPRVal(RegisterIndex: TSVCZRegisterIndex): TSVCZNative;
begin
Result := fRegisters.GP[RegisterIndex];
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.SetGPRVal(RegisterIndex: TSVCZRegisterIndex; NewValue: TSVCZNative);
begin
fRegisters.GP[RegisterIndex] := NewValue;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetFlag(FlagMask: TSVCZNative): Boolean;
begin
Result := (fRegisters.FLAGS and FlagMask) = FlagMask;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.SetFlag(FlagMask: TSVCZNative);
begin
fRegisters.FLAGS := fRegisters.FLAGS or FlagMask;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.ClearFlag(FlagMask: TSVCZNative);
begin
fRegisters.FLAGS := fRegisters.FLAGS and not FlagMask;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.ComplementFlag(FlagMask: TSVCZNative);
begin
fRegisters.FLAGS := fRegisters.FLAGS xor FlagMask;
end;
 
//------------------------------------------------------------------------------

procedure TSVCZProcessor.SetFlagValue(FlagMask: TSVCZNative; NewValue: Boolean);
begin
If NewValue then SetFlag(FlagMask)
  else ClearFlag(FlagMask);
end;
 
//------------------------------------------------------------------------------

Function TSVCZProcessor.EvaluateCondition(ConditionCode: TSVCZInstructionConditionCode): Boolean;
begin
case ConditionCode of
   0: Result := GetFlag(SVCZ_REG_FLAGS_CARRY);
   1: Result := GetFlag(SVCZ_REG_FLAGS_PARITY);
   2: Result := GetFlag(SVCZ_REG_FLAGS_ZERO);
   3: Result := GetFlag(SVCZ_REG_FLAGS_SIGN);
   4: Result := GetFlag(SVCZ_REG_FLAGS_OVERFLOW); 
   5: Result := GetFlag(SVCZ_REG_FLAGS_INTERRUPTS);
   6: Result := not GetFlag(SVCZ_REG_FLAGS_CARRY);
   7: Result := not GetFlag(SVCZ_REG_FLAGS_PARITY);
   8: Result := not GetFlag(SVCZ_REG_FLAGS_ZERO);
   9: Result := not GetFlag(SVCZ_REG_FLAGS_SIGN);
  10: Result := not GetFlag(SVCZ_REG_FLAGS_OVERFLOW);
  11: Result := not GetFlag(SVCZ_REG_FLAGS_INTERRUPTS);
  12: Result := GetFlag(SVCZ_REG_FLAGS_CARRY) or GetFlag(SVCZ_REG_FLAGS_ZERO);
  13: Result := not(GetFlag(SVCZ_REG_FLAGS_CARRY) or GetFlag(SVCZ_REG_FLAGS_ZERO));
  14: Result := GetFlag(SVCZ_REG_FLAGS_SIGN) xor GetFlag(SVCZ_REG_FLAGS_OVERFLOW);
  15: Result := not(GetFlag(SVCZ_REG_FLAGS_SIGN) xor GetFlag(SVCZ_REG_FLAGS_OVERFLOW));
  16: Result := (GetFlag(SVCZ_REG_FLAGS_SIGN) xor GetFlag(SVCZ_REG_FLAGS_OVERFLOW)) or
                GetFlag(SVCZ_REG_FLAGS_ZERO);
  17: Result := not((GetFlag(SVCZ_REG_FLAGS_SIGN) xor GetFlag(SVCZ_REG_FLAGS_OVERFLOW)) or
                GetFlag(SVCZ_REG_FLAGS_ZERO));
else
  raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDARGUMENT,ConditionCode);
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.AdvanceIP(Shift: TSVCZNative);
begin
fRegisters.IP := TSVCZNative(TSVCZComp(fRegisters.IP) + TSVCZComp(Shift));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.AdvanceSP(Shift: TSVCZNative);
begin
fRegisters.GP[REG_SP] := TSVCZNative(TSVCZComp(fRegisters.GP[REG_SP]) + TSVCZComp(Shift));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.HandleException(E: Exception);
begin
If E is ESVCZInterruptException then
  with ESVCZInterruptException(E) do
    DispatchInterrupt(InterruptIndex,InterruptData)
else If E is ESVCZQuietInternalException then
  {nothing, continue}
else If E is ESVCZFatalInternalException then
  begin
    fFaultClass := E.ClassName;
    fFaultMessage := ESVCZFatalInternalException(E).Message;
    fState := psFailed;
  end
else
  begin
    fState := psFailed;
    raise E;
  end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.DispatchInterrupt(InterruptIndex: TSVCZInterruptIndex; Data: TSVCZNative = 0);
begin
try
  {$message 'implement'}
except
  on E: Exception do
    begin
      fFaultClass := E.ClassName;
      fFaultMessage := E.Message;
      fState := psFailed;
    end;  
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.PortUpdated(PortIndex: TSVCZPortIndex);
begin
If fPorts[PortIndex].Connected then
  begin
    If Assigned(fPorts[PortIndex].OutHandler) then
      fPorts[PortIndex].OutHandler(Self,PortIndex,fPorts[PortIndex].Data);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DEVICENOTAVAILABLE,TSVCZNative(PortIndex));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.PortRequested(PortIndex: TSVCZPortIndex);
begin
If fPorts[PortIndex].Connected then
  begin
    If Assigned(fPorts[PortIndex].OutHandler) then
      fPorts[PortIndex].InHandler(Self,PortIndex,fPorts[PortIndex].Data);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DEVICENOTAVAILABLE,TSVCZNative(PortIndex));
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetArgVal(ArgIndex: Integer): TSVCZNative;
begin
If ArgIndex < fCurrentInstruction.ArgCount then
  Result := fCurrentInstruction.Args[ArgIndex].ArgumentValue
else
  raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.GetArgVal: Argument index (%d) out of bounds.',[ArgIndex]);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetArgPtr(ArgIndex: Integer): Pointer;
begin
If ArgIndex < fCurrentInstruction.ArgCount then
  Result := fCurrentInstruction.Args[ArgIndex].ArgumentPtr
else
  raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.GetArgVal: Argument index (%d) out of bounds.',[ArgIndex]);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InvalidateInstructionData;
begin
FillChar(fCurrentInstruction,SizeOf(TSVCZInstructionInfo),0);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.ExecuteNextInstruction;
begin
try
  try
    InstructionFetch;
    InstructionIssue;
  except
    on E: Exception do HandleException(E);
  end;
finally
  InvalidateInstructionData;
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionFetch;
begin
fCurrentInstruction.StartAddr := fRegisters.IP;
If (fRegisters.IP and 1) = 0 then
  begin
    fMemory.FetchMemory(fRegisters.IP,SVCZ_SZ_NATIVE,fCurrentInstruction.OPCode);
    AdvanceIP(SVCZ_SZ_NATIVE);
    If SVCZ_GetInstrLoadHint(fCurrentInstruction.OPCode) then
      begin
        // date are marked to be present, load them
        fMemory.FetchMemory(fRegisters.IP,SVCZ_SZ_NATIVE,fCurrentInstruction.Data);
        AdvanceIP(SVCZ_SZ_NATIVE);
      end;
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_CODEALIGNMENT);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionIssue;
begin
{$IFDEF SVC_Debug}
If Assigned(fOnBeforeInstruction) then
  fOnBeforeInstruction(Self);
{$ENDIF SVC_Debug}
InstructionDecode;
try
  If Assigned(fCurrentInstruction.Handler) then
    InstructionExecute
  else
    raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
finally
  Inc(fExecutionCount);
end;
{$IFDEF SVC_Debug}
If Assigned(fOnAfterInstruction) then
  fOnAfterInstruction(Self);
{$ENDIF SVC_Debug}
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionDecode;
begin
SVCZ_InstrDecode(fCurrentInstruction.OPCode,fCurrentInstruction.DecInfo);
InstructionSelectGroup;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionExecute;
begin
fCurrentInstruction.Handler;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType; ArgumentList: array of TSVCZInstructionArgumentType);
var
  i:        Integer;
  ArgsSize: TSVCZNumber;
  DataTemp: TSVCZNative;
begin
fCurrentInstruction.ArgCount := Low(fCurrentInstruction.Args);
// resolve argument from opcode param
If OPCodeParam <> iatNone then
  with fCurrentInstruction do
    begin
      Args[ArgCount].ArgumentType := OPCodeParam;
      case OPCodeParam of
        iatIP,
        iatFLAGS:;  // do nothing
        iatIMM4:  begin
                    Args[ArgCount].ArgumentValue := DecInfo.Param and $F;
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue)
                  end;
        iatREG:   begin
                    Args[ArgCount].ArgumentValue := fRegisters.GP[DecInfo.Param and $F];
                    Args[ArgCount].ArgumentPtr := Addr(fRegisters.GP[DecInfo.Param and $F])
                  end;
      else
        raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.ArgumentsDecode: Invalid OC param argument type (%d).',[Ord(OPCodeParam)]);
      end;
      Inc(fCurrentInstruction.ArgCount);
    end;
// check whether other arguments can actually fit into instruction data
ArgsSize := 0;
For i := Low(ArgumentList) to High(ArgumentList) do
  case ArgumentList[i] of
    iatNone,
    iatIP,
    iatFLAGS:;
    iatIMM4:  Inc(ArgsSize,4);
    iatIMM8:  Inc(ArgsSize,8);
    iatIMM16: Inc(ArgsSize,16);
    iatREL8:  Inc(ArgsSize,8);
    iatREL16: Inc(ArgsSize,16);
    iatREG:   Inc(ArgsSize,4);
  else
    raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.ArgumentsDecode: Invalid argument type (%d).',[Ord(ArgumentList[i])]);
  end;
If ArgsSize > (SVCZ_SZ_NATIVE * 8) then
  raise ESVCZFatalInternalException.Create('TSVCZProcessor.ArgumentsDecode: Arguments cannot fit into instruction data.');
// the number will be shifted in processing, make copy so original stays unchanged
DataTemp := fCurrentInstruction.Data;
// resolve argument list
For i := fCurrentInstruction.ArgCount to SVCZ_MinNum(High(ArgumentList),SVCZ_INS_MAXDATAARGUMENTS) do
  with fCurrentInstruction do
    begin
      Args[ArgCount].ArgumentType := ArgumentList[i];
      case ArgumentList[i] of
        iatNone,
        iatIP,
        iatFLAGS:;  // nothing to do
        iatIMM4:  begin
                    Args[ArgCount].ArgumentValue := DataTemp and $F;
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue);
                    DataTemp := DataTemp shr 4;
                  end;
        iatIMM8:  begin
                    Args[ArgCount].ArgumentValue := DataTemp and $FF;
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue);
                    DataTemp := DataTemp shr 8;
                  end;
        iatIMM16: begin
                    Args[ArgCount].ArgumentValue := DataTemp;
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue);
                    DataTemp := DataTemp shr 16;
                  end;
        iatREL8:  begin
                    Args[ArgCount].ArgumentValue := TSVCZNative(TSVCZSNative(TSVCZRel8(DataTemp and $FF))); // sign extension
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue);
                    DataTemp := DataTemp shr 8;
                  end;
        iatREL16: begin
                    Args[ArgCount].ArgumentValue := DataTemp; 
                    Args[ArgCount].ArgumentPtr := Addr(Args[ArgCount].ArgumentValue);
                    DataTemp := DataTemp shr 16;
                  end;
        iatREG:   begin
                    Args[ArgCount].ArgumentValue := fRegisters.GP[DataTemp and $F];
                    Args[ArgCount].ArgumentPtr := Addr(fRegisters.GP[DataTemp and $F]);
                    DataTemp := DataTemp shr 4;
                  end;
      else
        // this error should have been already raised in counting, but better be safe
        raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.ArgumentsDecode: Invalid argument type (%d).',[Ord(ArgumentList[i])]);
      end;
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSVCZProcessor.ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType = iatNone);
begin
ArgumentsDecode(OPCodeParam,[]);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelectGroup;
begin
case fCurrentInstruction.DecInfo.Group of
  0:  InstructionSelect_G0;
  1:  InstructionSelect_G1;
  2:  InstructionSelect_G2;
  3:  InstructionSelect_G3;
  4:  InstructionSelect_G4;
  5:  InstructionSelect_G5;
  6:  InstructionSelect_G6;
  7:  InstructionSelect_G7;
else
  raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G0;
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G1;
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G2;
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G3;
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G4; 
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G5; 
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G6;  
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InstructionSelect_G7;
begin
raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_INVALIDINSTRUCTION,fCurrentInstruction.StartAddr);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.Initialize;
begin
fExecutionCount := 0;
fState := psUninitialized;
FillChar(fMemory.Memory^,fMemory.Size,0);
FillChar(fRegisters,SizeOf(TSVCZRegisters),0);
FillChar(fInterruptHandlers,SizeOf(TSVCZInterruptHandlers),0);
FillChar(fPorts,SizeOf(TSVCZPorts),0);
InvalidateInstructionData;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.Finalize;
begin
// nothing to do atm
end;

//==============================================================================

constructor TSVCZProcessor.Create(Memory: TSVCZMemory);
begin
inherited Create;
fMemory := Memory;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TSVCZProcessor.Destroy;
begin
inherited;
Finalize;
end;

end.
