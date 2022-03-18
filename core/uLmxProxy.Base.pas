unit uLmxProxy.Base;

interface

uses
  System.Classes, System.SysUtils, uLmxProxy, uLmxHttpRest, uLmxCore;

type


  TTipoServidor = (tsProducao, tsLocal, tsUser, tsCustom);

  TLmxProxyHttpRestConfig = class
  private
    class var FInstancia : TLmxProxyHttpRestConfig;
  private
    FServerUrl: string;
    FToken: string;
    FUserId: Integer;
    FSelUserId: Integer;
    FTipoServidor: TTipoServidor;
  public
    property ServerUrl : string read FServerUrl write FServerUrl;
    property Token : string read FToken write FToken;
    property UserId : Integer read FUserId write FUserId;
    property SelUserId : Integer read FSelUserId write FSelUserId;
    property TipoServidor : TTipoServidor read FTipoServidor write FTipoServidor;

    class constructor Create;
    class destructor Destroy;
    class function Default : TLmxProxyHttpRestConfig;
  end;


  TLmxProxyHttpRest = class(TLmxHttpRest)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TLmxProxyBaseRest = class(TLmxProxyBase)
  protected
    function CriarProxyHttpRest: ILmxProxyHttpRest; override;
  end;

  TLmxProxyBaseDefault<T : TBaseTabelaPadrao, constructor> = class(TLmxProxyBase)
  public
    function Buscar(const pFiltro : string): string; overload; virtual;
    function Listar: TBaseList<T>; overload; virtual;
    function Carregar(const pId : Integer) : T; overload; virtual;
    procedure Carregar(const pId : Integer; pObjeto : T); overload; virtual;
    function Incluir(pObjeto : T; out AId : Integer) : Boolean; virtual;
    function Salvar(pObjeto : T) : Boolean; overload; virtual;
    function Excluir(pObjeto : T) : Boolean; overload; virtual;
  end;


implementation

{ TLmxProxyBaseRest }

function TLmxProxyBaseRest.CriarProxyHttpRest: ILmxProxyHttpRest;
begin
  Result := TLmxProxyHttpRest.Create(TLmxProxyHttpRest);
end;


{ TLmxProxyHttpRest }

constructor TLmxProxyHttpRest.Create(AOwner: TComponent);
begin
  inherited;
  Self.ServerUrl := TLmxProxyHttpRestConfig.Default.ServerUrl; // 'http://localhost:8500';
  Self.Token := TLmxProxyHttpRestConfig.Default.Token; // 'http://localhost:8500';
  Self.UserId := TLmxProxyHttpRestConfig.Default.SelUserId; // 'http://localhost:8500';
end;

{ TLmxProxyBaseDefault<T> }

function TLmxProxyBaseDefault<T>.Buscar(const pFiltro: string): string;
begin
  Result := NewHttpRest
    .AddParametro('pFiltro', pFiltro)
    .Get('Buscar')
    .AsString;
end;

function TLmxProxyBaseDefault<T>.Carregar(const pId: Integer): T;
begin
  Result := NewHttpRest
    .Get(pId.ToString)
    .AsObject<T>;
end;

procedure TLmxProxyBaseDefault<T>.Carregar(const pId: Integer;
  pObjeto: T);
begin
  NewHttpRest
    .Get(pId.ToString)
    .ToObject<T>(pObjeto);
end;

function TLmxProxyBaseDefault<T>.Excluir(pObjeto: T) : Boolean;
begin
  Result := NewHttpRest
    .Delete(pObjeto.Id.ToString)
    .Response
    .ResponseCode = 200;
end;

function TLmxProxyBaseDefault<T>.Incluir(pObjeto: T;
  out AId: Integer): Boolean;
var
  lResponse: TLmxResponseValue;
begin
  AId := 0;
  lResponse := NewHttpRest
    .SetObject(pObjeto)
    .Post;
  Result := lResponse.Response.ResponseCode = 200;
  if Result then
  begin
    lResponse.ToObject<T>(pObjeto);
    AId := pObjeto.Id;
  end;
end;

function TLmxProxyBaseDefault<T>.Listar: TBaseList<T>;
begin
  Result := NewHttpRest
    .Get
    .AsObject<TBaseList<T>>;
end;

function TLmxProxyBaseDefault<T>.Salvar(pObjeto: T): Boolean;
begin
  Result := NewHttpRest
    .SetObject(pObjeto)
    .Put
    .Response
    .ResponseCode = 200;
end;

{ TLmxProxyHttpRestConfig }

class constructor TLmxProxyHttpRestConfig.Create;
begin
  TLmxProxyHttpRestConfig.FInstancia := TLmxProxyHttpRestConfig.Create;
end;

class function TLmxProxyHttpRestConfig.Default: TLmxProxyHttpRestConfig;
begin
  Result := FInstancia;
end;

class destructor TLmxProxyHttpRestConfig.Destroy;
begin
  TLmxProxyHttpRestConfig.FInstancia.Free;
end;

end.

