unit uLmxHttp.Comandos;

interface

uses
  Classes, SysUtils,
  uLmxCore, uLmxComandoManutencao, uLmxComandoDefault, uLmxInterfacesRegister, uLmxHttp,
  uLmxHelper, uLmxAttributes;


type

  TLmxHttpComandos = class
  private
    FServidor: string;

    function GetCaminho(const AObjeto : TBase) : string;

  public
    property Caminho : string read FServidor write FServidor;

    function TentarObterCaminhoServidor(const APorta : Integer; out ACaminhoServidor : string) : Boolean;

    function GetHttp<T : TBaseList, constructor> : T; overload;
    function GetHttp<T : TBaseTabelaPadrao, constructor>(const AId : Integer; const AItem : T) : Boolean; overload;
    function Importar<T : TBaseList, constructor; TItem : TBaseTabelaPadrao, constructor> : Boolean; overload;
    function Importar<T : TBaseTabelaPadrao, constructor>(const AId : Integer; const AItem : T) : Boolean; overload;
  end;

  function LmxHttpComandos : TLmxHttpComandos;


implementation

var
  FLmxHttpComandos : TLmxHttpComandos;

function LmxHttpComandos : TLmxHttpComandos;
begin
  Result := FLmxHttpComandos;
end;


{ TLmxHttpComandos }

function TLmxHttpComandos.GetCaminho(const AObjeto: TBase): string;
var
  lCaminho: string;
begin
  lCaminho := AObjeto.GetCaminhoRest;

  if FServidor = '' then
    raise Exception.Create('Um caminho do servidor deve ser passado !');

  if lCaminho = '' then
    raise Exception.Create('A CLasse ' + AObjeto.ClassName + ' não possui nenhum atributo caminho configurado.');

  Result := FServidor + lCaminho;
  if pos('http://', Result) = 0 then
    Result := 'http://' + Result;
end;

function TLmxHttpComandos.GetHttp<T>(const AId: Integer;
  const AItem: T): Boolean;
var
  lCliente: TlmxHttpRest;
  lResponse: TRestResponse;
  lCaminho: string;
  lItem: T;
begin
  lCliente := TlmxHttpRest.Create(nil);
  try
    lCaminho := GetCaminho(AItem);
    lResponse := lCliente.Get(lCaminho + '/' + IntToStr(AId));
    try
      Result := lResponse.TentarCarregar<T>(lItem);
      try
        AItem.DeOutro(lItem);
      finally
        FreeAndNil(lItem);
      end;
    finally
      FreeAndNil(lResponse);
    end;
  finally
    FreeAndNil(lCliente);
  end;
end;

function TLmxHttpComandos.GetHttp<T>: T;
var
  lCliente: TlmxHttpRest;
  lResponse: TRestResponse;
  Id: Integer;
  lPacientesStr: string;
  lCaminho: string; // ILmxEnumerable;
  lResultado : TBaseList;
begin
  lResultado := T.Create;
  lCliente := TlmxHttpRest.Create(nil);
  try
    lCaminho := GetCaminho(lResultado);
    lResponse := lCliente.Get(lCaminho);
    try
      lResponse.TentarCarregar<T>(lREsultado as ILmxEnumerable);
      REsult := T(lREsultado);
    finally
      FreeAndNil(lResponse);
    end;
  finally
    FreeAndNil(lCliente);
  end;
end;

function TLmxHttpComandos.Importar<T, TItem>: Boolean;
var
  lLista: T;
  Id: Integer;
  lItem : TItem;
begin
  lLista := GetHttp<T>;
  try
    for Id := 0 to lLista.Count - 1 do
    begin
      lItem := TItem(lLista.Item[Id]);
      TLmxComandoBaseManutencao<TItem>.CriarEExecutar(lItem.Id, lItem);
    end;
  finally
    FreeAndNil(lLista);
  end;
end;

function TLmxHttpComandos.Importar<T>(const AId: Integer;
  const AItem: T): Boolean;
begin
  Result := False;
  if GetHttp<T>(AId, AItem) then
    Result := TLmxComandoBaseManutencao<T>.CriarEExecutar(AId, AItem);
end;

function TLmxHttpComandos.TentarObterCaminhoServidor(const APorta: Integer; out ACaminhoServidor : string) : Boolean;
var
  lCliente: TlmxHttpRest;
begin
  lCliente := TlmxHttpRest.Create(nil);
  try
    Result := lCliente.LocalizarServidor(APorta, ACaminhoServidor);
  finally
    FreeAndNil(lCliente);
  end;

end;

initialization
  FLmxHttpComandos := TLmxHttpComandos.Create;

finalization
  FreeAndNil(FLmxHttpComandos);



end.
