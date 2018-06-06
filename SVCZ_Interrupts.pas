unit SVCZ_Interrupts;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SysUtils,
  SVCZ_Common;

type
  // there is 64 interrupts
  TSVCZInterruptIndex = 0..63;

const
  // interrupt indices
  SVCZ_INT_IDX_MAXEXC = 15;
  SVCZ_INT_IDX_MINIRQ = 16;
  SVCZ_INT_IDX_MAXIRQ = 31;
  SVCZ_INT_IDX_TRAP   = 63;

  // exception indices
  SVCZ_INT_IDX_GENERALEXCEPTION            = 0;
  SVCZ_INT_IDX_INVALIDINSTRUCTIONEXCEPTION = 1;
  SVCZ_INT_IDX_DIVISIONBYZEROEXCEPTION     = 2;
  SVCZ_INT_IDX_ARITHMETICOVERFLOWEXCEPTION = 3;
  SVCZ_INT_IDX_MEMORYALIGNMENTEXCEPTION    = 4; 
  SVCZ_INT_IDX_MEMORYACCESSEXCEPTION       = 5;
  SVCZ_INT_IDX_DEVICENOTAVAILABLEEXCEPTION = 6;
  SVCZ_INT_IDX_INVALIDARGUMENTEXCEPTION    = 7;
  SVCZ_INT_IDX_CODEALIGNMENTEXCEPTION      = 8;
  SVCZ_INT_IDX_DOUBLEFAULTEXCEPTION        = SVCZ_INT_IDX_MAXEXC;

  SVCZ_EXCEPTION_GENERAL            = SVCZ_INT_IDX_GENERALEXCEPTION;
  SVCZ_EXCEPTION_INVALIDINSTRUCTION = SVCZ_INT_IDX_INVALIDINSTRUCTIONEXCEPTION;
  SVCZ_EXCEPTION_DIVISIONBYZERO     = SVCZ_INT_IDX_DIVISIONBYZEROEXCEPTION;
  SVCZ_EXCEPTION_ARITHMETICOVERFLOW = SVCZ_INT_IDX_ARITHMETICOVERFLOWEXCEPTION;
  SVCZ_EXCEPTION_MEMORYALIGNMENT    = SVCZ_INT_IDX_MEMORYALIGNMENTEXCEPTION;
  SVCZ_EXCEPTION_MEMORYACCESS       = SVCZ_INT_IDX_MEMORYACCESSEXCEPTION;
  SVCZ_EXCEPTION_DEVICENOTAVAILABLE = SVCZ_INT_IDX_DEVICENOTAVAILABLEEXCEPTION;
  SVCZ_EXCEPTION_INVALIDARGUMENT    = SVCZ_INT_IDX_INVALIDARGUMENTEXCEPTION;
  SVCZ_EXCEPTION_CODEALIGNMENT      = SVCZ_INT_IDX_CODEALIGNMENTEXCEPTION;
  SVCZ_EXCEPTION_DOUBLEFAULT        = SVCZ_INT_IDX_DOUBLEFAULTEXCEPTION;

{
  Content of interrupt data and return address (where it points) for individual
  exceptions:

    exception              |  return               |  data
  ----------------------------------------------------------------------------
    general                |  after instruction    |  0
    invalid instruction    |  after instruction    |  start of instruction
    division by zero       |  after instruction    |  0
    arithmetic overflow    |  after instruction    |  0
    memory alignment       |  after instruction    |  memory address
    memory access          |  after instruction    |  memory address
    device not available   |  after instruction    |  port index
    invalid argument       |  after instruction    |  argument value
    code alignment         |  start of instruction |  0
    double fault           |  depends on fault     |  0
  ----------------------------------------------------------------------------

  IRQ-invoked interrupts - return address points to last IP, data contains
  content of the invoking port upon the request.

  User-defined interrupts - return address points after the invoking
  instruction, data are always 0.
}

{
  space (bytes) required on the stack for interrupt handler call

  stack upon entry to interrupt handler:

    [SP + 4] - old FLAGS
    [SP + 2] - interrupt data
    [SP]     - return address
}
  SVCZ_INT_INTERRUPTSTACKSPACE = 3 * SVCZ_SZ_NATIVE;

type
  // interrupt vector
  TSVCZInterrupt = record
    HandlerAddr:  TSVCZNative;
    Counter:      Integer;
  end;

  TSVCZInterrupts = array[TSVCZInterruptIndex] of TSVCZInterrupt;

  // internal exception classes
  ESVCZFatalInternalException = class(Exception);

  ESVCZQuietInternalException = class(Exception)
  public
    constructor Create;
  end;

  ESVCZInterruptException = class(ESVCZQuietInternalException)
  protected
    fInterruptIndex:  TSVCZInterruptIndex;
    fInterruptData:   TSVCZNative;
  public
    constructor Create(InterruptIndex: TSVCZInterruptIndex; InterruptData: TSVCZNative = 0);
  published
    property InterruptIndex: TSVCZInterruptIndex read fInterruptIndex;
    property InterruptData: TSVCZNative read fInterruptData;
  end;

// functions for interrupt management
Function SVCZ_IsIRQ(InterruptIndex: TSVCZInterruptIndex): Boolean;{$IFDEF CanInline} inline;{$ENDIF}

implementation

constructor ESVCZQuietInternalException.Create;
begin
inherited Create('SiViC Zero - quiet internal exception');
end;

//==============================================================================

constructor ESVCZInterruptException.Create(InterruptIndex: TSVCZInterruptIndex; InterruptData: TSVCZNative = 0);
begin
inherited Create;
fInterruptIndex := InterruptIndex;
fInterruptData := InterruptData;
end;

//==============================================================================

Function SVCZ_IsIRQ(InterruptIndex: TSVCZInterruptIndex): Boolean;
begin
Result := (InterruptIndex >= SVCZ_INT_IDX_MINIRQ) and (InterruptIndex <= SVCZ_INT_IDX_MAXIRQ);
end;


end.
