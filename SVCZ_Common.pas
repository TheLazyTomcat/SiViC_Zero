unit SVCZ_Common;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  AuxTypes;

type
  TSVCZIntSize = (vsUndefined,vsByte,vsWord,vsLong,vsQuad,vsNative);

  TSVCZSByte = Int8;        TSVCZUByte = UInt8;
  TSVCZByte  = TSVCZUByte;
  TSVCZSWord = Int16;       TSVCZUWord = UInt16;
  TSVCZWord  = TSVCZUWord;
  TSVCZSLong = Int32;       TSVCZULong = UInt32;
  TSVCZLong  = TSVCZULong;
  TSVCZSQuad = Int64;       TSVCZUQuad = UInt64;
  TSVCZQuad  = TSVCZUQuad;

  // native integers (width of a register)
  TSVCZSNative = TSVCZSWord;    TSVCZUNative = TSVCZUWord;
  TSVCZNative  = TSVCZUNative;

  // smallest signed integer larger than TSVCZNative
  TSVCZComp   = TSVCZSLong;

  // integer used for general number passing
  TSVCZNumber = TSVCZSLong;

  // relative offset types
  TSVCZRel8  = TSVCZSByte;
  TSVCZRel16 = TSVCZSWord;

const
  // integer sizes as constants
  SVCZ_SZ_BYTE   = SizeOf(TSVCZByte);
  SVCZ_SZ_WORD   = SizeOf(TSVCZWord);
  SVCZ_SZ_LONG   = SizeOf(TSVCZLong);
  SVCZ_SZ_QUAD   = SizeOf(TSVCZQuad);
  SVCZ_SZ_NATIVE = SizeOf(TSVCZNative);

  SVCZ_SIGN_MASK_NATIVE = TSVCZNative($8000); 

Function SVCZ_MinNum(A,B: TSVCZNumber): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}

Function SVCZ_Parity(Value: TSVCZNative): Boolean;

Function SVCZ_BoolToNum(Val: Boolean): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_NumToBool(Val: TSVCZNumber): Boolean;{$IFDEF CanInline} inline;{$ENDIF}

Function SVCZ_ValueBytes(IntSize: TSVCZIntSize): TSVCZNumber;

implementation

Function SVCZ_MinNum(A,B: TSVCZNumber): TSVCZNumber;
begin
If A > B then Result := B
  else Result := A;
end;

//------------------------------------------------------------------------------

Function SVCZ_Parity(Value: TSVCZNative): Boolean;
begin
Value := Value xor (Value shr 8);
Value := Value xor (Value shr 4);
Value := Value xor (Value shr 2);
Value := Value xor (Value shr 1);
Result := (Value and 1) = 0;
end;

//------------------------------------------------------------------------------

Function SVCZ_BoolToNum(Val: Boolean): TSVCZNumber;
begin
If Val then Result := 1
  else Result := 0;
end;

//------------------------------------------------------------------------------

Function SVCZ_NumToBool(Val: TSVCZNumber): Boolean;
begin
Result := Val <> 0;
end;

//------------------------------------------------------------------------------

Function SVCZ_ValueBytes(IntSize: TSVCZIntSize): TSVCZNumber;
begin
case IntSize of
  vsByte:   Result := SVCZ_SZ_BYTE;
  vsWord:   Result := SVCZ_SZ_WORD;
  vsLong:   Result := SVCZ_SZ_LONG;
  vsQuad:   Result := SVCZ_SZ_QUAD;
  vsNative: Result := SVCZ_SZ_NATIVE;   
else
  Result := 0;
end;
end;

end.
