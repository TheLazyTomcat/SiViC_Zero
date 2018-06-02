unit SVCZ_System;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Memory, SVCZ_IO, SVCZ_Processor;

type
  TSVCZSystem = class(TObject)
  private
    fMemory:        TSVCZMemory;
    fProcessor:     TSVCZProcessor;
    fDevices:       array of TSVCZDevice;
    fProcCycleMult: Integer;
    Function GetDevice(Index: Integer): TSVCZDevice;
    Function GetDeviceCount: Integer;
  protected
    procedure Initialize; virtual;
    procedure Finalize; virtual; 
  public
    constructor Create;
    destructor Destroy; override;
    //procedure Restart; virtual;
    //procedure Reset; virtual;
    procedure Cycle; virtual;
    // device list management...
    //{$message 'implement'}
    property Memory: TSVCZMemory read fMemory;
    property Processor: TSVCZProcessor read fProcessor;
    property Devices[Index: Integer]: TSVCZDevice read GetDevice;
    property DeviceCount: Integer read GetDeviceCount;
    property ProcessorCycleMultiplier: Integer read fProcCycleMult write fProcCycleMult;
  end;

implementation

uses
  SysUtils,
  SVCZ_Processor_Curr;

Function TSVCZSystem.GetDevice(Index: Integer): TSVCZDevice;
begin
If (Index >= Low(fDevices)) and (Index <= High(fDevices)) then
  Result := fDevices[Index]
else
  raise Exception.CreateFmt('TSVCZSystem.GetDevice: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TSVCZSystem.GetDeviceCount: Integer;
begin
Result := Length(fDevices);
end;

//==============================================================================

procedure TSVCZSystem.Initialize;
begin
fMemory := TSVCZMemory.Create;
fProcessor := TSVCZProcessor_Curr.Create(fMemory);
fProcCycleMult := 1;
end;

//------------------------------------------------------------------------------

procedure TSVCZSystem.Finalize;
begin
fProcessor.Free;
fMemory.Free;
end;

//==============================================================================

constructor TSVCZSystem.Create;
begin
inherited Create;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TSVCZSystem.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TSVCZSystem.Cycle;
begin
// cycle processor
fProcessor.Run(fProcCycleMult);
// cycle devices
end;

end.
