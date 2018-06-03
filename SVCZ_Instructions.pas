unit SVCZ_Instructions;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common;

{
  Instruction groups:

      0 - system, stack, IO
      1 - branching, conditional instructions (eg. CMOV)
      2 - memory access, data movement, data conversion
      3 - arithmetics
      4 - logical and bit operations
   6..8 - reserved
}

const
  SVCZ_INS_MAXDATAARGUMENTS = 4;
  SVCZ_INS_MAXARGUMENTS     = 5;  // 4 in data, 1 in opcode (usually cc or reg)

type
  TSVCZInstructionOPCode = TSVCZWord; // do not use native
  TSVCZInstructionData   = TSVCZWord;

  TSVCZInstructionConditionCode = 0..31; // 5 bit number

  // possible types of instruction arguments
  TSVCZInstructionArgumentType  = (iatNone,iatIP,iatFLAGS,iatIMM4,iatIMM8,
                                   iatIMM16,iatREL8,iatREL16,iatREG);

  TSVCZInstructionArgumentTypes = set of TSVCZInstructionArgumentType;

const
  SVCZ_INS_ARGUMENTTYPES_STRINGS: array[TSVCZInstructionArgumentType] of String =
    ('','IP','FLAGS','IMM4','IMM8','IMM16','REL8','REL16','REG');

type
  TSVCZInstructionDecodedInfo = record
    Index:    TSVCZNumber;
    Group:    TSVCZNumber;
    Param:    TSVCZNumber;
    LoadHint: Boolean;
  end;

  // instruction handler prototype
  TSVCZInstructionHandler = procedure of object;

  TSVCZInstructionArgument = record
    ArgumentType:   TSVCZInstructionArgumentType;
    ArgumentValue:  TSVCZNative;
    ArgumentPtr:    Pointer;
  end;

  TSVCZInstructionArguments = array[0..(SVCZ_INS_MAXARGUMENTS - 1)] of TSVCZInstructionArgument;

  // structure used when executing an instruction
  TSVCZInstructionInfo = record
    StartAddr:  TSVCZNative;
    OPCode:     TSVCZInstructionOPCode;
    DecInfo:    TSVCZInstructionDecodedInfo;
    Handler:    TSVCZInstructionHandler;
    Data:       TSVCZInstructionData;
    ParamArg:   TSVCZInstructionArgument;
    ArgCount:   TSVCZNumber;
    Args:       TSVCZInstructionArguments;
  end;


Function SVCZ_GetInstrIndex(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrGroup(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrParam(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrLoadHint(OPCode: TSVCZInstructionOPCode): Boolean;{$IFDEF CanInline} inline;{$ENDIF}

procedure SVCZ_InstrDecode(OPCode: TSVCZInstructionOPCode; var DecInfo: TSVCZInstructionDecodedInfo);

Function SVCZ_InstrEncode(Index,Group,Param: TSVCZNumber; LoadHint: Boolean): TSVCZNative;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_ArgsEncode(ArgTypes: array of TSVCZInstructionArgumentType; ArgValues: array of TSVCZNumber): TSVCZNative;

implementation

uses
  SysUtils;

Function SVCZ_GetInstrIndex(OPCode: TSVCZInstructionOPCode): TSVCZNumber;
begin
Result := OpCode and $7F;
end;

//------------------------------------------------------------------------------

Function SVCZ_GetInstrGroup(OPCode: TSVCZInstructionOPCode): TSVCZNumber;
begin
Result := (OpCode shr 7) and $7;
end;

//------------------------------------------------------------------------------

Function SVCZ_GetInstrParam(OPCode: TSVCZInstructionOPCode): TSVCZNumber;
begin
Result := (OpCode shr 10) and $1F;
end;

//------------------------------------------------------------------------------

Function SVCZ_GetInstrLoadHint(OPCode: TSVCZInstructionOPCode): Boolean;
begin
Result := (OpCode and $8000) <> 0;
end;

//------------------------------------------------------------------------------

procedure SVCZ_InstrDecode(OPCode: TSVCZInstructionOPCode; var DecInfo: TSVCZInstructionDecodedInfo);{$IFDEF CanInline} inline;{$ENDIF}
begin
DecInfo.Index := SVCZ_GetInstrIndex(OpCode);
DecInfo.Group := SVCZ_GetInstrGroup(OpCode);
DecInfo.Param := SVCZ_GetInstrParam(OpCode);
DecInfo.LoadHint := SVCZ_GetInstrLoadHint(OpCode);
end;

//------------------------------------------------------------------------------

Function SVCZ_InstrEncode(Index,Group,Param: TSVCZNumber; LoadHint: Boolean): TSVCZNative;
begin
Result := TSVCZNative((SVCZ_BoolToNum(LoadHint) shr 15) or
  ((Param and $1F) shl 10) or ((Group and $7) shl 7) or (Index and $7F));
end;

//------------------------------------------------------------------------------

Function SVCZ_ArgsEncode(ArgTypes: array of TSVCZInstructionArgumentType; ArgValues: array of TSVCZNumber): TSVCZNative;
var
  i:  Integer;
begin
Result := 0;
For i := SVCZ_MinNum(SVCZ_MinNum(High(ArgTypes),High(ArgValues)),Pred(SVCZ_INS_MAXDATAARGUMENTS)) downto Low(ArgTypes) do
  case ArgTypes[i] of
    iatNone,
    iatIP,
    iatFLAGS:;// do nothing
    iatREG,
    iatIMM4:  Result := TSVCZNative((Result shl 4) or (ArgValues[i] and $F));
    iatIMM8,
    iatREL8:  Result := TSVCZNative((Result shl 8) or (ArgValues[i] and $FF));
    iatIMM16,
    iatREL16: Result := TSVCZNative((Result shl 8) or (ArgValues[i] and $FFFF));
  else
    raise Exception.CreateFmt('SVCZ_ParamEncode: Invalid argument type (%d).',[Ord(ArgTypes[i])]);
  end;
end;

end.
