unit SVCZ_Memory;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  AuxTypes,
  SVCZ_Common;

type
  TSVCZMemoryAccessEvent = procedure(Sender: TObject; Address: TSVCZNative) of object;

  TSVCZMemory = class(TObject)
  private
    fMemory:  Pointer;
    fSize:    TMemSize;
  public
    constructor Create;
    destructor Destroy; override;
    Function AddrPtr(Address: TSVCZNative): Pointer; virtual;
    Function IsValidArea(Address,Size: TSVCZNative): Boolean; virtual;
    procedure GetMemory(Address,Size: TSVCZNative; out Buffer); virtual;
    Function FetchMemory(Address,Size: TSVCZNative; out Buffer): TSVCZNative; virtual;
    property Memory: Pointer read fMemory;
    property Size: TMemSize read fSize;
  end;

implementation

uses
  SysUtils;

constructor TSVCZMemory.Create;
begin
inherited;
fSize := $10000;  {addresses 0x0000 - 0xFFFF}
fMemory := AllocMem(fSize);
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

end.
