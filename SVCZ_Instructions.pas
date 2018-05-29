unit SVCZ_Instructions;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common;

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
    ArgCount:   TSVCZNumber;
    Args:       TSVCZInstructionArguments;
  end;


Function SVCZ_GetInstrIndex(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrGroup(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrParam(OPCode: TSVCZInstructionOPCode): TSVCZNumber;{$IFDEF CanInline} inline;{$ENDIF}
Function SVCZ_GetInstrLoadHint(OPCode: TSVCZInstructionOPCode): Boolean;{$IFDEF CanInline} inline;{$ENDIF}

procedure SVCZ_InstrDecode(OPCode: TSVCZInstructionOPCode; var DecInfo: TSVCZInstructionDecodedInfo);

implementation

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
Result := (OpCode shr 10) and $F;
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

end.
