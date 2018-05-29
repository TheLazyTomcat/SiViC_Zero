unit SVCZ_Registers;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common;

type
  TSVCZRegisterIndex = 0..15;

  TSVCZRegister = TSVCZNative;

  TSVCZGPRegisters = array[TSVCZRegisterIndex] of TSVCZRegister;

  TSVCZRegisters = record
    GP:     TSVCZGPRegisters;
    IP:     TSVCZRegister;
    FLAGS:  TSVCZRegister;
  end;

const
  SVCZ_REG_GP_COUNT = High(TSVCZRegisterIndex) + 1;

  // general purpose registers indices
  SVCZ_REG_GP_IDX_R0  = 0;      REG_R0  = SVCZ_REG_GP_IDX_R0;
  SVCZ_REG_GP_IDX_R1  = 1;      REG_R1  = SVCZ_REG_GP_IDX_R1;
  SVCZ_REG_GP_IDX_R2  = 2;      REG_R2  = SVCZ_REG_GP_IDX_R2;
  SVCZ_REG_GP_IDX_R3  = 3;      REG_R3  = SVCZ_REG_GP_IDX_R3;
  SVCZ_REG_GP_IDX_R4  = 4;      REG_R4  = SVCZ_REG_GP_IDX_R4;
  SVCZ_REG_GP_IDX_R5  = 5;      REG_R5  = SVCZ_REG_GP_IDX_R5;
  SVCZ_REG_GP_IDX_R6  = 6;      REG_R6  = SVCZ_REG_GP_IDX_R6;
  SVCZ_REG_GP_IDX_R7  = 7;      REG_R7  = SVCZ_REG_GP_IDX_R7;
  SVCZ_REG_GP_IDX_R8  = 8;      REG_R8  = SVCZ_REG_GP_IDX_R8;
  SVCZ_REG_GP_IDX_R9  = 9;      REG_R9  = SVCZ_REG_GP_IDX_R9;
  SVCZ_REG_GP_IDX_R10 = 10;     REG_R10 = SVCZ_REG_GP_IDX_R10;
  SVCZ_REG_GP_IDX_R11 = 11;     REG_R11 = SVCZ_REG_GP_IDX_R11;
  SVCZ_REG_GP_IDX_R12 = 12;     REG_R12 = SVCZ_REG_GP_IDX_R12;
  SVCZ_REG_GP_IDX_R13 = 13;     REG_R13 = SVCZ_REG_GP_IDX_R13;
  SVCZ_REG_GP_IDX_R14 = 14;     REG_R14 = SVCZ_REG_GP_IDX_R14;
  SVCZ_REG_GP_IDX_R15 = 15;     REG_R15 = SVCZ_REG_GP_IDX_R15;

  // special-use register indices
  SVCZ_REG_GP_IDX_SB = SVCZ_REG_GP_IDX_R14;   REG_SB = SVCZ_REG_GP_IDX_SB;
  SVCZ_REG_GP_IDX_SP = SVCZ_REG_GP_IDX_R15;   REG_SP = SVCZ_REG_GP_IDX_SP;

  // indices of implicit (hidden) registers
  SVCZ_REG_IMPL_IDX_IP    = 255;
  SVCZ_REG_IMPL_IDX_FLAGS = 254;

  // implemented bits in FLAGS register
  SVCZ_REG_FLAGS_CARRY      = TSVCZNative($0001);   // bit 0
  SVCZ_REG_FLAGS_PARITY     = TSVCZNative($0002);   // bit 1
  SVCZ_REG_FLAGS_ZERO       = TSVCZNative($0004);   // bit 2
  SVCZ_REG_FLAGS_SIGN       = TSVCZNative($0008);   // bit 3
  SVCZ_REG_FLAGS_OVERFLOW   = TSVCZNative($0010);   // bit 4
  SVCZ_REG_FLAGS_INTERRUPTS = TSVCZNative($0020);   // bit 5


Function SVCZ_ExtractRegIndex(Value: TSVCZByte): TSVCZRegisterIndex;{$IFDEF CanInline} inline;{$ENDIF}

Function SVCZ_PutIntIdx(FLAGS: TSVCZRegister; InterruptIndex: TSVCZNumber): TSVCZRegister;{$IFDEF CanInline} inline;{$ENDIF}

implementation

Function SVCZ_ExtractRegIndex(Value: TSVCZByte): TSVCZRegisterIndex;
begin
Result := Value and $F;
end;

// -----------------------------------------------------------------------------

Function SVCZ_PutIntIdx(FLAGS: TSVCZRegister; InterruptIndex: TSVCZNumber): TSVCZRegister;
begin
Result := (FLAGS and $C0FF) or ((InterruptIndex and $3F) shl 8);
end;

end.
