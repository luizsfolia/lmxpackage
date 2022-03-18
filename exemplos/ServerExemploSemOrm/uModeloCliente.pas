unit uModeloCliente;

interface

uses
  uLmxCore, uLmxAttributes, System.Math, Generics.Collections, System.Classes;

type

  [TLmxAttributeMetadata]
  TCliente = class(TBaseTabelaPadrao)
  private
    FNome: string;
  public
    [TLmxAttributeMetadata(80)]
    property Nome : string read FNome write FNome;
  end;

  TClientes = class(TBaseList<TCliente>)
  end;

implementation

end.
