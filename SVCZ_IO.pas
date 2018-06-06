unit SVCZ_IO;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common, SVCZ_Memory, SVCZ_Interrupts;

type
  // there is 16 ports
  TSVCZPortIndex = 0..15;

  TSVCZPortCall = procedure(var Data: TSVCZNative) of object;

  TSVCZPort = record
    Data:       TSVCZNative;
    InHandler:  TSVCZPortCall;
    OutHandler: TSVCZPortCall;
  end;

  TSVCZPorts = array[TSVCZPortIndex] of TSVCZPort;

  TSVCZIODeviceType =(iodtSystem,iodtTimer,iodtOther);  // later add more

  TSVCZIRQCall = Function(IRQIndex: TSVCZInterruptIndex): Boolean of object;

  TSVCZIODevice = class(TObject)
  protected
    fMemory:          TSVCZMemory;
    fDeviceType:      TSVCZIODeviceType;
    fPortData:        TSVCZNative;
    fPortIndex:       TSVCZPortIndex;
    fIRQPendingCall:  TSVCZIRQCall;
    fIRQMakeCall:     TSVCZIRQCall;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure InHandler(var Data: TSVCZNative); virtual; abstract;
    procedure OutHandler(var Data: TSVCZNative); virtual; abstract;
    Function IRQPending: Boolean; virtual;
    Function IRQMake: Boolean; virtual;
  public
    constructor Create(Memory: TSVCZMemory);
    destructor Destroy; override;
    procedure ConnectToPort(PortIndex: TSVCZPortIndex; var Port: TSVCZPort); virtual;
    procedure DisconnectFromPort(var Port: TSVCZPort); virtual;
    procedure Restart; virtual; abstract;
    procedure Reset; virtual; abstract;
    procedure Cycle; virtual; abstract;
    property DeviceType: TSVCZIODeviceType read fDeviceType;
    property PortData: TSVCZNative read fPortData;
    property PortIndex: TSVCZPortIndex read fPortIndex;
    property IRQPendingCall: TSVCZIRQCall read fIRQPendingCall write fIRQPendingCall;
    property IRQMakeCall: TSVCZIRQCall read fIRQMakeCall write fIRQMakeCall;
  end;

  TSVCZIODeviceClass = class of TSVCZIODevice;

Function SVCZ_IRQToPort(InterruptIndex: TSVCZInterruptIndex): TSVCZPortIndex;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_PortToIRQ(PortIndex: TSVCZPortIndex): TSVCZInterruptIndex;{$IFDEF CanInline} inline;{$ENDIF}

implementation

uses
  SysUtils;

Function SVCZ_IRQToPort(InterruptIndex: TSVCZInterruptIndex): TSVCZPortIndex;
begin
Result := (InterruptIndex and $3F) - SVCZ_INT_IDX_MINIRQ;
end;

//------------------------------------------------------------------------------

Function SVCZ_PortToIRQ(PortIndex: TSVCZPortIndex): TSVCZInterruptIndex;
begin
Result := SVCZ_INT_IDX_MINIRQ + (PortIndex and $F);
end;

//==============================================================================
//==============================================================================

procedure TSVCZIODevice.Initialize;
begin
fDeviceType := iodtOther;
fPortData := 0;
end;

//------------------------------------------------------------------------------

procedure TSVCZIODevice.Finalize;
begin
// nothing to do here
end;

//------------------------------------------------------------------------------

Function TSVCZIODevice.IRQPending: Boolean;
begin
If Assigned(fIRQPendingCall) then
  Result := fIRQPendingCall(SVCZ_PortToIRQ(fPortIndex))
else
  raise Exception.Create('TSVCZIODevice.IRQPending: Method not assigned,');
end;

//------------------------------------------------------------------------------

Function TSVCZIODevice.IRQMake: Boolean;
begin
If Assigned(fIRQMakeCall) then
  Result := fIRQMakeCall(SVCZ_PortToIRQ(fPortIndex))
else
  raise Exception.Create('TSVCZIODevice.IRQMake: Method not assigned,');
end;

//==============================================================================

constructor TSVCZIODevice.Create(Memory: TSVCZMemory);
begin
inherited Create;
fMemory := Memory;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TSVCZIODevice.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TSVCZIODevice.ConnectToPort(PortIndex: TSVCZPortIndex; var Port: TSVCZPort);
begin
fPortIndex := PortIndex and $F;
Port.Data := fPortData;
Port.InHandler := InHandler;
Port.OutHandler := OutHandler;
end;

//------------------------------------------------------------------------------

procedure TSVCZIODevice.DisconnectFromPort(var Port: TSVCZPort);
begin
fPortIndex := 0;
Port.Data := 0;
Port.InHandler := nil;
Port.OutHandler := nil;
end;

end.
