unit uLmxRequisicaoCliente;

interface

uses
  Generics.Collections, uLmxInterfaces, SysUtils;

type

  TLmxRequisicaoCliente = class(TInterfacedObject, ILmxRequisicaoCliente)
  private
    FUSerId : Integer;
    FUSerIsAdmin : Boolean;
    FLimit : Integer;
    FResponseBuscarComoJson : Boolean;
  public
    function GetUSerId : Integer;
    function SetUSerId(const pValue : Integer) : ILmxRequisicaoCliente;
    function GetUSerIsAdmin : Boolean;
    function SetUSerIsAdmin(const pValue : Boolean) : ILmxRequisicaoCliente;

    function GetLimit : Integer;
    function SetLimit(const pValue : Integer) : ILmxRequisicaoCliente;

    function GetResponseBuscarComoJson : Boolean;
    function SetResponseBuscarComoJson(const pValue : Boolean) : ILmxRequisicaoCliente;
  end;

implementation

{ TLmxRequisicaoCliente }

function TLmxRequisicaoCliente.GetLimit: Integer;
begin
  Result := FLimit;
end;

function TLmxRequisicaoCliente.GetResponseBuscarComoJson: Boolean;
begin
  Result := FResponseBuscarComoJson;
end;

function TLmxRequisicaoCliente.GetUSerId: Integer;
begin
  Result := FUSerId;
end;

function TLmxRequisicaoCliente.GetUSerIsAdmin: Boolean;
begin
  REsult := FUSerIsAdmin;
end;

function TLmxRequisicaoCliente.SetLimit(
  const pValue: Integer): ILmxRequisicaoCliente;
begin
  FLimit := pValue;
end;

function TLmxRequisicaoCliente.SetResponseBuscarComoJson(
  const pValue: Boolean): ILmxRequisicaoCliente;
begin
  FResponseBuscarComoJson := pValue;
  Result := Self;
end;

function TLmxRequisicaoCliente.SetUSerId(
  const pValue: Integer): ILmxRequisicaoCliente;
begin
  FUSerId := pValue;
  Result := Self;
end;

function TLmxRequisicaoCliente.SetUSerIsAdmin(
  const pValue: Boolean): ILmxRequisicaoCliente;
begin
  FUSerIsAdmin := pValue;
  REsult := Self;
end;

end.
