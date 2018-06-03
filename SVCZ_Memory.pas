unit SVCZ_Memory;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  AuxTypes,
  SVCZ_Common;

type
  TSVCZDMAChannelIndex = 0..3;

  TSVCZDMAChannel = record
    Address:  TSVCZNative;
    Size:     TSVCZNative;
    Memory:   Pointer;
  end;

  TSVCZDMAChannels = array[TSVCZDMAChannelIndex] of TSVCZDMAChannel;

  TSVCZMemoryAccessEvent = procedure(Sender: TObject; Address: TSVCZNative) of object;

  TSVCZMemory = class(TObject)
  private
    fSize:        TMemSize;
    fMemory:      Pointer;
    fDMAChannels: TSVCZDMAChannels;
  public
    constructor Create;
    destructor Destroy; override;
    Function AddrPtr(Address: TSVCZNative): Pointer; virtual;
    Function IsValidArea(Address,Size: TSVCZNative): Boolean; virtual;
    procedure GetMemory(Address,Size: TSVCZNative; out Buffer); virtual;
    Function FetchMemory(Address,Size: TSVCZNative; out Buffer): TSVCZNative; virtual;
    procedure SetDMAChannel(ChannelIndex: TSVCZDMAChannelIndex; Address,Size: TSVCZNative); virtual;
    property Size: TMemSize read fSize;
    property Memory: Pointer read fMemory;
    property DMAChannels: TSVCZDMAChannels read fDMAChannels;
  end;

implementation

uses
  SysUtils;

constructor TSVCZMemory.Create;
begin
inherited;
fSize := $10000;  {addresses 0x0000 - 0xFFFF}
fMemory := AllocMem(fSize);
FillChar(fDMAChannels,SizeOf(TSVCZDMAChannel),0);
end;

//------------------------------------------------------------------------------

destructor TSVCZMemory.Destroy;
begin
FreeMem(fMemory,fSize);
inherited;
end;

//------------------------------------------------------------------------------

Function TSVCZMemory.AddrPtr(Address: TSVCZNative): Pointer;
begin
Result := Pointer(PtrUInt(fMemory) + PtrUInt(Address));
end;

//------------------------------------------------------------------------------

Function TSVCZMemory.IsValidArea(Address,Size: TSVCZNative): Boolean;
begin
Result := (TSVCZComp(Address) + TSVCZComp(Size)) <= (TSVCZComp(High(TSVCZNative)) + 1);
end;

//------------------------------------------------------------------------------

procedure TSVCZMemory.GetMemory(Address,Size: TSVCZNative; out Buffer);
begin
If IsValidArea(Address,Size) then
  Move(AddrPtr(Address)^,Buffer,Size)
else
  raise Exception.Create('TSVCZMemory.GetMemory: Out of memory bounds.');
end;

//------------------------------------------------------------------------------

Function TSVCZMemory.FetchMemory(Address,Size: TSVCZNative; out Buffer): TSVCZNative;
begin
If IsValidArea(Address,Size) then
  begin
    Result := Size;  
    Move(AddrPtr(Address)^,Buffer,Size);
  end
else
  begin
    FillChar(Buffer,Size,0);
    Result := TSVCZNative(TSVCZComp(High(TSVCZNative)) - TSVCZComp(Address) + 1);
    Move(AddrPtr(Address)^,Buffer,Result);
  end;
end;

//------------------------------------------------------------------------------

procedure TSVCZMemory.SetDMAChannel(ChannelIndex: TSVCZDMAChannelIndex; Address,Size: TSVCZNative);
begin
If IsValidArea(Address,Size) then
  begin
    fDMAChannels[ChannelIndex and $3].Address := Address;
    fDMAChannels[ChannelIndex and $3].Size := Size;
    fDMAChannels[ChannelIndex and $3].Memory := AddrPtr(Address);
  end
else raise Exception.Create('TSVCZMemory.SetDMAChannel: Out of memory bounds.');
end;

end.
