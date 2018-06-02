unit SVCZ_IO;

{$INCLUDE '.\SVCZ_defs.inc'}

interface

uses
  SVCZ_Common;

type
  // there is 16 ports
  TSVCZPortIndex = 0..15;

  TSVCZPortEvent = procedure(Sender: TObject; Port: TSVCZPortIndex; var Data: TSVCZNative) of object;

  TSVCZPort = record
    Data:       TSVCZNative;
    InHandler:  TSVCZPortEvent;
    OutHandler: TSVCZPortEvent;
    Connected:  Boolean;  
  end;

  TSVCZPorts = array[TSVCZPortIndex] of TSVCZPort;

  TSVCZDevice = class(TObject);


implementation

end.
