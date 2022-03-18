unit uModuloClientes;

interface

uses
  System.SysUtils, uLmxHttpServer, uLmxAttributes, System.Classes, uModeloCliente;

type

  TModuloCllientes = class(TLmxServerComand)
  public
    [HttpGet]
    [TLmxAttributeComando('')]
    function GetClientes : ILmxRetorno<TClientes>;

    [HttpGet]
    [TLmxAttributeComando('/{id}')]
    function GetCliente([FromParams] const id : Integer) : ILmxRetorno<TCliente>;

    [HttpPost]
    [TLmxAttributeComando('')]
    function PostCliente(const pCliente : string) : ILmxRetorno<TCliente>;
  end;

implementation

{ TModuloCllientes }

function TModuloCllientes.GetCliente(const id: Integer): ILmxRetorno<TCliente>;
begin
  Result := TLmxRetorno<TCliente>.Create;
  Result.Retorno.Nome := 'Luiz';
  Result.Retorno.Id := id;
end;

function TModuloCllientes.GetClientes : ILmxRetorno<TClientes>;
var
  lCliente: TCliente;
begin
  Result := TLmxRetorno<TClientes>.Create;

  lCliente := TCliente.Create;
  lCliente.Nome := 'Luiz';
  lCliente.Id := 1;

  Result.Retorno.Add(lCliente);

  lCliente := TCliente.Create;
  lCliente.Nome := 'Ricardo';
  lCliente.Id := 2;

  Result.Retorno.Add(lCliente);

end;

function TModuloCllientes.PostCliente(const pCliente: string): ILmxRetorno<TCliente>;
begin
  Result := GetCliente(2);
end;

end.
