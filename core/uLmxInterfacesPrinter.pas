unit uLmxInterfacesPrinter;

interface

type

  ILmxInterfacesPrinter = interface
  ['{2C806BD7-D8C2-4F0C-BA1B-679FE3120862}']
    function EmitirRelatorioGerencial(const ARelatorio : string;
      const AFecharAoConcluir : Boolean = True) : Boolean;
    function CortarPapel : Boolean;
  end;

implementation

end.
