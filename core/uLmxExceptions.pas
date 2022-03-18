unit uLmxExceptions;

interface

uses
  SysUtils;

type

  EPDVException = class(Exception)

  end;

  EPDVExceptionImpressora = class(EPDVException)

  end;

  EPDVExceptionMetadata = class(EPDVException)

  end;

implementation

end.
