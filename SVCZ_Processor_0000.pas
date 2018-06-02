unit SVCZ_Processor_0000;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common,
  SVCZ_Processor;

const
  // common info
  SVCZ_PCS_INFOPAGE_INVALID          = 0;
  // CPU info
  SVCZ_PCS_INFOPAGE_CPU_ARCHITECTURE = $0001;
  SVCZ_PCS_INFOPAGE_CPU_REVISION     = $0002;
  // Counters, timers, clocks
  SVCZ_PCS_INFOPAGE_CNTR_EXEC        = $1000;

type
  TSVCZProcessor_0000 = class(TSVCZProcessor)
  protected
    // processor info engine
    Function GetInfoPage(Page: TSVCZProcessorInfoPage; Param: TSVCZProcessorInfoData): TSVCZProcessorInfoData; override;
    // implementation helpers
    Function FlaggedADD(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedSUB(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedADC(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedSBB(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedMUL(A,B: TSVCZNative; out High: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedIMUL(A,B: TSVCZNative; out High: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedDIV(AL,AH,B: TSVCZNative; out High: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedIDIV(AL,AH,B: TSVCZNative; out High: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedMOD(AL,AH,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedAND(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedOR(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedXOR(A,B: TSVCZNative): TSVCZNative; virtual;
    Function FlaggedSHR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedSHL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedSAR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedSAL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedROR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedROL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedRCR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedRCL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedSHRD(AL,AH: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
    Function FlaggedSHLD(AL,AH: TSVCZNative; Count: TSVCZNumber): TSVCZNative; virtual;
  public
    class Function GetRevision: TSVCZProcessorInfoData; override;
  end;

implementation

uses
  AuxTypes, BitOps,
  SVCZ_Registers, SVCZ_Interrupts;

Function TSVCZProcessor_0000.GetInfoPage(Page: TSVCZProcessorInfoPage; Param: TSVCZProcessorInfoData): TSVCZProcessorInfoData;
begin
case Page of
  // CPU info
  SVCZ_PCS_INFOPAGE_CPU_ARCHITECTURE: Result := GetArchitecture;
  SVCZ_PCS_INFOPAGE_CPU_REVISION:     Result := GetRevision;
  // Counters, timers, clocks
  SVCZ_PCS_INFOPAGE_CNTR_EXEC:        Result := PutIntoMemory(TSVCZNative(Param),UInt64(fExecutionCount));
else
  Result := inherited GetInfoPage(Page,Param);
end;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedADD(A,B: TSVCZNative): TSVCZNative;
var
  S1,S2,SR: Boolean;
begin
S1 := (A and SVCZ_SIGN_MASK_NATIVE) <> 0;
S2 := (B and SVCZ_SIGN_MASK_NATIVE) <> 0;
Result := TSVCZNative(TSVCZComp(A) + TSVCZComp(B));
SR := (Result and SVCZ_SIGN_MASK_NATIVE) <> 0;
SetFlagValue(SVCZ_REG_FLAGS_CARRY,Result < A);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,SR);
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,not(S1 xor S2) and (S2 xor SR));
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSUB(A,B: TSVCZNative): TSVCZNative;
var
  S1,S2,SR: Boolean;
begin
S1 := (A and SVCZ_SIGN_MASK_NATIVE) <> 0;
S2 := (B and SVCZ_SIGN_MASK_NATIVE) <> 0;
Result := TSVCZNative(TSVCZComp(A) - TSVCZComp(B));
SR := (Result and SVCZ_SIGN_MASK_NATIVE) <> 0;
SetFlagValue(SVCZ_REG_FLAGS_CARRY,A < B);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,SR);
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,(S1 xor S2) and not(S2 xor SR));
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedADC(A,B: TSVCZNative): TSVCZNative;
var
  S1,S2,SR: Boolean;
begin
S1 := (A and SVCZ_SIGN_MASK_NATIVE) <> 0;
S2 := (B and SVCZ_SIGN_MASK_NATIVE) <> 0;
Result := TSVCZNative(TSVCZComp(A) + TSVCZComp(B) +
          TSVCZComp(SVCZ_BoolToNum(GetFlag(SVCZ_REG_FLAGS_CARRY))));
SR := (Result and SVCZ_SIGN_MASK_NATIVE) <> 0;
SetFlagValue(SVCZ_REG_FLAGS_CARRY,Result < A);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,SR);
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,not(S1 xor S2) and (S2 xor SR));
end;


//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSBB(A,B: TSVCZNative): TSVCZNative;
var
  S1,S2,SR: Boolean;
begin
S1 := (A and SVCZ_SIGN_MASK_NATIVE) <> 0;
S2 := (B and SVCZ_SIGN_MASK_NATIVE) <> 0;
Result := TSVCZNative(TSVCZComp(A) - (TSVCZComp(B) +
          TSVCZComp(SVCZ_BoolToNum(GetFlag(SVCZ_REG_FLAGS_CARRY)))));
SR := (Result and SVCZ_SIGN_MASK_NATIVE) <> 0;
SetFlagValue(SVCZ_REG_FLAGS_CARRY,A < B);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,SR);
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,(S1 xor S2) and not(S2 xor SR));
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedMUL(A,B: TSVCZNative; out High: TSVCZNative): TSVCZNative;
var
  FullResult: TSVCZLong;
begin
FullResult := TSVCZLong(A) * TSVCZLong(B);
Result := TSVCZNative(FullResult);
High := TSVCZNative(FullResult shr 16);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,High <> 0);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,(Result = 0) and (High = 0));
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,High <> 0);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedIMUL(A,B: TSVCZNative; out High: TSVCZNative): TSVCZNative;
var
  FullResult: TSVCZSLong;
begin
FullResult := TSVCZSLong(TSVCZSNative(A)) * TSVCZSLong(TSVCZSNative(B));
Result := TSVCZNative(FullResult);
High := TSVCZNative(FullResult shr 16);
SetFlagValue(SVCZ_REG_FLAGS_CARRY,High <> 0);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,(Result = 0) and (High = 0));
SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,High <> 0);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedDIV(AL,AH,B: TSVCZNative; out High: TSVCZNative): TSVCZNative;
var
  FullResult: TSVCZLong;
begin
If B <> 0 then
  begin
    FullResult := ((TSVCZLong(AH) shl 16) or TSVCZLong(AL)) div TSVCZLong(B);
    Result := TSVCZNative(FullResult);
    High := TSVCZNative(FullResult shr 16);
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,High <> 0);
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,(Result = 0) and (High = 0));
    SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,High <> 0);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DIVISIONBYZERO);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedIDIV(AL,AH,B: TSVCZNative; out High: TSVCZNative): TSVCZNative;
var
  FullResult: TSVCZSLong;
begin
If B <> 0 then
  begin
    FullResult := ((TSVCZSLong(TSVCZSNative(AH)) shl 16) or TSVCZSLong(TSVCZSNative(AL))) div TSVCZSLong(TSVCZSNative(B));
    Result := TSVCZNative(FullResult);
    High := TSVCZNative(FullResult shr 16);
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,High <> 0);
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,(Result = 0) and (High = 0));
    SetFlagValue(SVCZ_REG_FLAGS_OVERFLOW,High <> 0);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DIVISIONBYZERO);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedMOD(AL,AH,B: TSVCZNative): TSVCZNative;
var
  FullResult: TSVCZLong;
begin
If B <> 0 then
  begin
    FullResult := ((TSVCZLong(AH) shl 16) or TSVCZLong(AL)) mod TSVCZLong(B);
    Result := TSVCZNative(FullResult);
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
  end
else raise ESVCZInterruptException.Create(SVCZ_EXCEPTION_DIVISIONBYZERO);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedAND(A,B: TSVCZNative): TSVCZNative;
begin
Result := A and B;
ClearFlag(SVCZ_REG_FLAGS_CARRY);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
ClearFlag(SVCZ_REG_FLAGS_OVERFLOW);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedOR(A,B: TSVCZNative): TSVCZNative;
begin
Result := A or B;
ClearFlag(SVCZ_REG_FLAGS_CARRY);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
ClearFlag(SVCZ_REG_FLAGS_OVERFLOW);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedXOR(A,B: TSVCZNative): TSVCZNative;
begin
Result := A xor B;
ClearFlag(SVCZ_REG_FLAGS_CARRY);
SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
ClearFlag(SVCZ_REG_FLAGS_OVERFLOW);
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSHR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := TSVCZNative(A shr (Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(Pred(Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := A;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSHL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := TSVCZNative(A shl (Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(16 - (Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := A;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSAR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := SAR(A,UInt8(Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(Pred(Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := A;
end;
 
//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSAL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := SAL(A,UInt8(Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(16 - (Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := A;
end;
 
//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedROR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := ROR(A,UInt8(Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(Pred(Count and $F))));
  end
else Result := A;
end;
 
//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedROL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := ROL(A,UInt8(Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(A,UInt8(16 - (Count and $F))));
  end
else Result := A;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedRCR(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
var
  Carry:  ByteBool;
begin
If (Count and $F) <> 0 then
  begin
    Carry := GetFlag(SVCZ_REG_FLAGS_CARRY);
    Result := RCRCarry(A,UInt8(Count and $F),Carry);
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,Carry);
  end
else Result := A;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedRCL(A: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
var
  Carry:  ByteBool;
begin
If (Count and $F) <> 0 then
  begin
    Carry := GetFlag(SVCZ_REG_FLAGS_CARRY);
    Result := RCLCarry(A,UInt8(Count and $F),Carry);
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,Carry);
  end
else Result := A;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSHRD(AL,AH: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := TSVCZNative(TSVCZLong((TSVCZLong(AH) shl 16) or TSVCZLong(AL)) shr (Count and $F));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(AL,UInt8(Pred(Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := AL;
end;

//------------------------------------------------------------------------------

Function TSVCZProcessor_0000.FlaggedSHLD(AL,AH: TSVCZNative; Count: TSVCZNumber): TSVCZNative;
begin
If (Count and $F) <> 0 then
  begin
    Result := TSVCZNative(TSVCZLong((TSVCZLong(AH) shl 16) or TSVCZLong(AL)) shr (16 - (Count and $F)));
    SetFlagValue(SVCZ_REG_FLAGS_CARRY,BT(AH,UInt8(16 - (Count and $F))));
    SetFlagValue(SVCZ_REG_FLAGS_PARITY,SVCZ_Parity(Result));
    SetFlagValue(SVCZ_REG_FLAGS_ZERO,Result = 0);
    SetFlagValue(SVCZ_REG_FLAGS_SIGN,(Result and SVCZ_SIGN_MASK_NATIVE) <> 0);
  end
else Result := AL;
end;

//==============================================================================

class Function TSVCZProcessor_0000.GetRevision: TSVCZProcessorInfoData;
begin
Result := 0;
end;

end.
