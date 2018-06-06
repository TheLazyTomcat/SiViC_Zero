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
  TSVCZProcessorState = (psRunning,psHalted,psReleased,psWaiting,psSynchronizing,psFailed);

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
    fInterrupts:          TSVCZInterrupts;
    fPorts:               TSVCZPorts;
    // currently processed instruction
    fCurrentInstruction:  TSVCZInstructionInfo;
    // synchronization stuff
    fOnSynchronization:   TNotifyEvent;
    // processor state setup and clearing
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    // processor info engine
    Function PutIntoMemory(Address: TSVCZNative; Value: UInt64): TSVCZProcessorInfoData; virtual;
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
    procedure InvalidateInstructionInfo; virtual;
    procedure ExecuteNextInstruction; virtual;
    procedure InstructionFetch; virtual;
    procedure InstructionIssue; virtual;
    procedure InstructionDecode; virtual;
    procedure InstructionExecute; virtual;
    // instruction decoding
    procedure ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType; ArgumentList: array of TSVCZInstructionArgumentType); overload; virtual;
    procedure ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType = iatNone); overload; virtual;
    procedure ArgumentsDecode(ArgumentList: array of TSVCZInstructionArgumentType); overload; virtual;
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
    class Function GetArchitecture: TSVCZProcessorInfoData; virtual;
    class Function GetRevision: TSVCZProcessorInfoData; virtual;
    constructor Create(Memory: TSVCZMemory);
    destructor Destroy; override;
  {$IFDEF SVC_Debug}
    procedure ExecuteInstruction(OPCode: TSVCZInstructionOPCode; Data: TSVCZInstructionData; AffectIP: Boolean = False); virtual;
  {$ENDIF SVC_Debug}
    procedure EndSynchronization(Sender: TObject); virtual;
    Function DeviceConnected(PortIndex: TSVCZPortIndex): Boolean; virtual;
    Function IRQPending(IRQIndex: TSVCZInterruptIndex): Boolean; virtual;
    Function IRQMake(IRQIndex: TSVCZInterruptIndex): Boolean; virtual;
    procedure Restart; virtual;
    procedure Reset; virtual;
    Function Run(InstructionCount: Integer = 1): Integer; virtual;    
    property State: TSVCZProcessorState read fState;
    property ExecutionCount: UInt64 read fExecutionCount;
    property FaultClass: String read fFaultClass;
    property FaultMessage: String read fFaultMessage;
    property OnSynchronization: TNotifyEvent read fOnSynchronization write fOnSynchronization;
  {$IFDEF SVC_Debug}
    // for debugging purposes...
    property Memory: TSVCZMemory read fMemory;
    property Registers: TSVCZRegisters read fRegisters;
    property Interrupts: TSVCZInterrupts read fInterrupts;
    property Ports: TSVCZPorts read fPorts;
    property OnBeforeInstruction: TNotifyEvent read fOnBeforeInstruction write fOnBeforeInstruction;
    property OnAfterInstruction: TNotifyEvent read fOnAfterInstruction write fOnAfterInstruction;
    property OnMemoryRead: TSVCZMemoryAccessEvent read fOnMemoryRead write fOnMemoryRead;
    property OnMemoryWrite: TSVCZMemoryAccessEvent read fOnMemoryWrite write fOnMemoryWrite;
  {$ENDIF SVC_Debug}
  end;

implementation

Function TSVCZProcessor.PutIntoMemory(Address: TSVCZNative; Value: UInt64): TSVCZProcessorInfoData;
begin
Result := SizeOf(UInt64);
If fMemory.IsValidArea(Address,SizeOf(UInt64)) then
  begin
    UInt64(fMemory.AddrPtr(Address)^) := UInt64(Value);
  {$IFDEF SVC_Debug}
    DoMemoryWriteEvent(Address);
  {$ENDIF SVC_Debug}
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_MEMORYACCESS,Address);
end;

//------------------------------------------------------------------------------

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
  If GetFlag(SVCZ_REG_FLAGS_INTERRUPTS) or (InterruptIndex <= SVCZ_INT_IDX_MAXEXC) and
    (fInterrupts[InterruptIndex].HandlerAddr <> 0) then
    begin
      // interrupt enabled or exception, interrupt handler assigned (not 0)
      If (fInterrupts[InterruptIndex].HandlerAddr and 1) = 0 then
        begin
          // handler is valid, check whether it can be called
          If (fInterrupts[InterruptIndex].Counter <= 0) or not SVCZ_IsIRQ(InterruptIndex) then
            begin
              // check stack pointer alignment
              If (fRegisters.GP[REG_SP] and 1) = 0 then
                begin
                  // stack is aligned, good to go...
                  StackPUSH(fRegisters.FLAGS);
                  StackPUSH(Data);
                  StackPUSH(fRegisters.IP);
                  Inc(fInterrupts[InterruptIndex].Counter);
                  ClearFlag(SVCZ_REG_FLAGS_INTERRUPTS);
                  SVCZ_FLAGSPutIntIdx(fRegisters.FLAGS,InterruptIndex);
                  fRegisters.IP := fInterrupts[InterruptIndex].HandlerAddr;
                end
              {
                dispatching an interrupt with unaligned stack would result
                in infinite exception chain (memory alignment exception),
                so a tripple fault is raised instead
              }
              else raise ESVCZFatalInternalException.Create('TSVCZProcessor.DispatchInterrupt: Triple fault (stack not aligned).');
            end;
        end
      else
        begin
          // handler is at invalid address
          If InterruptIndex <> SVCZ_EXCEPTION_DOUBLEFAULT then
            DispatchInterrupt(SVCZ_EXCEPTION_DOUBLEFAULT)
          else
            raise ESVCZFatalInternalException.Create('TSVCZProcessor.DispatchInterrupt: Triple fault (invalid handler address).');
        end;
    end;
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
If DeviceConnected(PortIndex) then
  begin
    If Assigned(fPorts[PortIndex].OutHandler) then
      fPorts[PortIndex].OutHandler(fPorts[PortIndex].Data);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DEVICENOTAVAILABLE,TSVCZNative(PortIndex));
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.PortRequested(PortIndex: TSVCZPortIndex);
begin
If DeviceConnected(PortIndex) then
  begin
    If Assigned(fPorts[PortIndex].OutHandler) then
      fPorts[PortIndex].InHandler(fPorts[PortIndex].Data);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DEVICENOTAVAILABLE,TSVCZNative(PortIndex));
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetArgVal(ArgIndex: Integer): TSVCZNative;
begin
If ArgIndex < fCurrentInstruction.ArgCount then
  begin
    If ArgIndex < 0 then
      Result := fCurrentInstruction.ParamArg.ArgumentValue
    else
      Result := fCurrentInstruction.Args[ArgIndex].ArgumentValue;
  end
else raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.GetArgVal: Argument index (%d) out of bounds.',[ArgIndex]);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.GetArgPtr(ArgIndex: Integer): Pointer;
begin
If ArgIndex < fCurrentInstruction.ArgCount then
  begin
    If ArgIndex < 0 then
      Result := fCurrentInstruction.ParamArg.ArgumentPtr
    else
      Result := fCurrentInstruction.Args[ArgIndex].ArgumentPtr;
  end
else raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.GetArgVal: Argument index (%d) out of bounds.',[ArgIndex]);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.InvalidateInstructionInfo;
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
  InvalidateInstructionInfo;
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
// resolve argument from opcode param
If OPCodeParam <> iatNone then
  with fCurrentInstruction do
    begin
      ParamArg.ArgumentType := OPCodeParam;
      case OPCodeParam of
        iatIP,
        iatFLAGS:;  // do nothing
        iatIMM4:  begin
                    ParamArg.ArgumentValue := DecInfo.Param and $F;
                    ParamArg.ArgumentPtr := Addr(ParamArg.ArgumentValue);
                  end;
        iatREG:   begin
                    ParamArg.ArgumentValue := fRegisters.GP[DecInfo.Param and $F];
                    ParamArg.ArgumentPtr := Addr(fRegisters.GP[DecInfo.Param and $F]);
                  end;
      else
        raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.ArgumentsDecode: Invalid OC param argument type (%d).',[Ord(OPCodeParam)]);
      end;
    end;
// check whether other arguments can actually fit into instruction data
ArgsSize := 0;
For i := Low(ArgumentList) to High(ArgumentList) do
  case ArgumentList[i] of
    iatNone,
    iatIP,
    iatFLAGS:;
    iatREG,
    iatIMM4:  Inc(ArgsSize,4);
    iatIMM8,
    iatREL8:  Inc(ArgsSize,8);
    iatIMM16,
    iatREL16: Inc(ArgsSize,16);
  else
    raise ESVCZFatalInternalException.CreateFmt('TSVCZProcessor.ArgumentsDecode: Invalid argument type (%d).',[Ord(ArgumentList[i])]);
  end;
If ArgsSize > (SVCZ_SZ_NATIVE * 8) then
  raise ESVCZFatalInternalException.Create('TSVCZProcessor.ArgumentsDecode: Arguments cannot fit into instruction data.');
// the number will be shifted in processing, make copy so original stays unchanged
DataTemp := fCurrentInstruction.Data;
fCurrentInstruction.ArgCount := 0;
// resolve argument list
For i := Low(ArgumentList) to SVCZ_MinNum(High(ArgumentList),High(fCurrentInstruction.Args)) do
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
      Inc(ArgCount);
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSVCZProcessor.ArgumentsDecode(OPCodeParam: TSVCZInstructionArgumentType = iatNone);
begin
ArgumentsDecode(OPCodeParam,[]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSVCZProcessor.ArgumentsDecode(ArgumentList: array of TSVCZInstructionArgumentType);
begin
ArgumentsDecode(iatNone,ArgumentList);
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
fState := psRunning;
FillChar(fMemory.Memory^,fMemory.Size,0);
FillChar(fRegisters,SizeOf(TSVCZRegisters),0);
FillChar(fInterrupts,SizeOf(TSVCZInterrupts),0);
FillChar(fPorts,SizeOf(TSVCZPorts),0);
InvalidateInstructionInfo;
fOnSynchronization := EndSynchronization;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.Finalize;
begin
// nothing to do atm
end;

//==============================================================================

class Function TSVCZProcessor.GetArchitecture: TSVCZProcessorInfoData;
begin
Result := $57C0;  // don't ask
end;

//------------------------------------------------------------------------------

class Function TSVCZProcessor.GetRevision: TSVCZProcessorInfoData;
begin
{$IFDEF FPC}
Result := 0; // fpc generates warning when not present, delphi generates warning when it is present, yep... 
{$ENDIF}
raise Exception.Create('TSVCProcessor.GetRevision: No revision number available');
end;

//------------------------------------------------------------------------------

constructor TSVCZProcessor.Create(Memory: TSVCZMemory);
begin
inherited Create;
fMemory := Memory;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TSVCZProcessor.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

{$IFDEF SVC_Debug}

procedure TSVCZProcessor.ExecuteInstruction(OPCode: TSVCZInstructionOPCode; Data: TSVCZInstructionData; AffectIP: Boolean = False);
var
  InstrPtr: TSVCZNative;
begin
InstrPtr := fRegisters.IP;
try
  // fetch
  fCurrentInstruction.StartAddr := fRegisters.IP;
  fCurrentInstruction.OPCode := OPCode;
  fCurrentInstruction.Data := Data;
  AdvanceIP(SVCZ_SZ_NATIVE);
  If SVCZ_GetInstrLoadHint(OPCode) then
    AdvanceIP(SVCZ_SZ_NATIVE);
  try
    InstructionIssue;
  except
    on E: Exception do HandleException(E);
  end;
finally
  InvalidateInstructionInfo;
  If not AffectIP then
    fRegisters.IP := InstrPtr;
end;
end;

{$ENDIF SVC_Debug}

//------------------------------------------------------------------------------

procedure TSVCZProcessor.EndSynchronization(Sender: TObject);
begin
If fState = psSynchronizing then
  fState := psRunning;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.DeviceConnected(PortIndex: TSVCZPortIndex): Boolean;
begin
Result := Assigned(fPorts[PortIndex and $F].InHandler) and Assigned(fPorts[PortIndex and $F].OutHandler);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.IRQPending(IRQIndex: TSVCZInterruptIndex): Boolean;
begin
If SVCZ_IsIRQ(IRQIndex and $3F) then
  Result := fInterrupts[IRQIndex and $3F].Counter > 0
else
  raise Exception.CreateFmt('TSVCZProcessor.IRQPending: Interrupt index (%d) is not an IRQ.',[IRQIndex]);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.IRQMake(IRQIndex: TSVCZInterruptIndex): Boolean;
begin
If SVCZ_IsIRQ(IRQIndex and $3F) then
  begin
    Result := not IRQPending(IRQIndex and $3F);
    If Result then
      begin
        DispatchInterrupt(IRQIndex and $3F,fPorts[SVCZ_IRQToPort(IRQIndex)].Data);
        If fState = psWaiting then
          fState := psRunning;
      end;
  end
else raise Exception.CreateFmt('TSVCZProcessor.IRQMake: Interrupt index (%d) is not an IRQ.',[IRQIndex]);
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.Restart;
var
  i:  Integer;
begin
fExecutionCount := 0;
fFaultClass := '';
fFaultMessage := '';
// init registers
FillChar(fRegisters,SizeOf(TSVCZRegisters),0);
// init port data (not handlers)
For i := Low(fPorts) to High(fPorts) do
  fPorts[i].Data := 0;
// init current instruction info  
InvalidateInstructionInfo;
// init state
fState := psRunning;
end;

//------------------------------------------------------------------------------

procedure TSVCZProcessor.Reset;
begin
// clear ports
FillChar(fPorts,SizeOf(fPorts),0);
// clear memory
FillChar(fMemory.Memory^,fMemory.Size,0);
// init interrupt handlers
FillChar(fInterrupts,SizeOf(TSVCZInterrupts),0);
// init state
Restart;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor.Run(InstructionCount: Integer = 1): Integer;
begin
Result := 0;
If InstructionCount > 0 then
  while (InstructionCount > 0) and (fState = psRunning) do
    begin
      ExecuteNextInstruction;
      Dec(InstructionCount);
      Inc(Result);
    end
else
  while fState = psRunning do
    begin
      ExecuteNextInstruction;
      Inc(Result);
    end;
If fState in [psReleased,psSynchronizing] then
  fState := psRunning;
end;

end.
