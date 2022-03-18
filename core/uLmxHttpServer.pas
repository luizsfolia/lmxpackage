unit uLmxHttpServer;

interface
uses
  IOUtils, IdHttp, SysUtils, Classes, IdComponent, uLmxAttributes, uLmxInterfaces, uLmxRequisicaoCliente, //uLmxHelper,
  uLmxSerialization, IdSSL, IdSSLOpenSSL, IdCookieManager, IdGlobal, WinApi.Windows,
  {$IFDEF VER270}IdBaseComponent, IdAntiFreezeBase, Vcl.IdAntiFreeze{$ELSE}
  IdAntiFreezeBase, Vcl.IdAntiFreeze{$ENDIF}, IdHttpServer, Generics.Collections, IdContext, IdCustomHTTPServer,
  IdHeaderList, IdIPWatch, uLmxHttpTest, uLmxHttp.Test.Windows, IDCoderMime, IdAuthentication, Rtti, System.TypInfo,
  IdCustomTCPServer, IdUDPServer, IdSocketHandle, IdStack, uLmxHtml, System.Zip, IdCompressorZLib, System.NetEncoding;

type

  TLmxHttpServer = class;

  ILmxResultComandHttpBase = interface
    ['{982471B2-1422-43C1-BFE5-0C2539669615}']

    procedure SetDadosResponseInfo(const AResponseInfo : TIdHTTPResponseInfo);
  end;

//  ILmxResultComandHttp<T> = interface(ILmxResultComandHttpBase)
//    ['{4D0B66EF-B1D3-43C3-8F9B-42BAEDF483B8}']
//    function GetResultado : T;
//    procedure SetResultado(const AResultado : T);
//    function GetStrResposta : String;
//    procedure SetStrResposta(const AStrResposta : String);
//
//    property Resultado : T read GetResultado write SetResultado;
//    property StrResposta : String read GetStrResposta write SetStrResposta;
//  end;

  ILmxResultComandHttp = interface(ILmxResultComandHttpBase)
    ['{4D0B66EF-B1D3-43C3-8F9B-42BAEDF483B8}']
    function GetStrResposta : String;
    procedure SetStrResposta(const AStrResposta : String);

    property StrResposta : String read GetStrResposta write SetStrResposta;
  end;


//  TLmxResultComandHttp<T> = class(TInterfacedObject, ILmxResultComandHttp<T>)
//  private type
//    TOGetDadosResponse = reference to procedure (const ARetorno : T; const AResponseInfo : TIdHTTPResponseInfo);
//  private
//    FResultado : T;
//    FStrResposta : String;
//    FResponseInfo : TIdHTTPResponseInfo;
//    function GetResultado : T;
//    procedure SetResultado(const AResultado : T);
//    function GetStrResposta : String;
//    procedure SetStrResposta(const AStrResposta : String);
//  public
//    property Resultado : T read GetResultado write SetResultado;
//    property StrResposta : String read GetStrResposta write SetStrResposta;
//
//    procedure SetDadosResponseInfo(const AResponseInfo : TIdHTTPResponseInfo);
//    procedure SetDadosResponseInfoGet(const AOnResponse : TOGetDadosResponse);
//  end;

  TLmxResultComandHttp = class(TInterfacedObject, ILmxResultComandHttp)
  private type
    TOGetDadosResponse = reference to procedure (const AResponseInfo : TIdHTTPResponseInfo);
  private
    FStrResposta : String;
    FResponseInfo : TIdHTTPResponseInfo;
    function GetStrResposta : String;
    procedure SetStrResposta(const AStrResposta : String);
  public
    property StrResposta : String read GetStrResposta write SetStrResposta;

    procedure SetDadosResponseInfo(const AResponseInfo : TIdHTTPResponseInfo);
    procedure SetDadosResponseInfoGet(const AOnResponse : TOGetDadosResponse);
  end;

  TLmxServerComand = class;
  TLmxServerComandClass = class of TLmxServerComand;
  TLmxInfoComandoServidor = class;
  TLmxInfoComandoProcessadoNoServidor = class;

//  TLmxHttpTipoComando = (htcGet, htcPost, htcPut, htcDelete);

  ELmxCommand = class(Exception)
  public
    function GetCodigoRetornoHttp : Integer; virtual; abstract;
  end;

  ELmxCommandAuth = class(ELmxCommand)
  public
    function GetCodigoRetornoHttp : Integer; override;
  end;

  ELmxCommandRotaNaoConfigurada = class(ELmxCommand)
  public
    function GetCodigoRetornoHttp : Integer; override;
  end;

  ELmxCommandNaoExecutado = class(ELmxCommand)
  public
    function GetCodigoRetornoHttp : Integer; override;
  end;

  TLmxServerComandRegister = class(TObjectDictionary<string,TLmxServerComandClass>)
  private
    FReader : TMultiReadExclusiveWriteSynchronizer;
    FAtributosComando : TObjectDictionary<TLmxServerComandClass,TLmxServerComandAttributes>;
    function TentaCarregarComando(const ARota : string; out AComando : TLmxServerComandClass;
      out AProximaRota : string) : Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function GetComando(const ARota : string; out AComando : TLmxServerComandClass; out AProximaRota : string) : Boolean;
    function GetPropriedadesDoComando(const AComando : TLmxServerComandClass) : TLmxServerComandAttributes;
  end;

  TLmxHttpOnProcessarComandoEvent = procedure(const AComando : TLmxInfoComandoServidor;
    const AInfoComandoRodado : TLmxInfoComandoProcessadoNoServidor) of object;
  TLmxHttpOnErroComandoEvent = procedure(const AComando : TLmxInfoComandoServidor; const pErro : string; const pDataBase : string) of object;
  TLmxHttpOnValidarAutenticacaoEvent = function(const AUserName, APassword : string) : Boolean of object;
  TLmxHttpOnConectarEvent = procedure (const AContext: TIdContext) of object;
  TLmxHttpOnReceberPedidoDeConexaoEvent = procedure (const pMensagem : string) of object;

  TLmxHttpOnProcessarComandoRef = reference to procedure(const AComando : TLmxInfoComandoServidor;
    const AInfoComandoRodado : TLmxInfoComandoProcessadoNoServidor);
  TLmxHttpOnErroComandoRef = reference to procedure(const AComando : TLmxInfoComandoServidor; const pErro : string; const pDataBase : string);

  TLmxInfoComandoInfoAuth = class
  private
    FUser: string;
    FAccessToken: string;
    FCodUser: Integer;
    FIsAdmin: Boolean;
  public
    property CodUser : Integer read FCodUser write FCodUser;
    property User : string read FUser write FUser;
    property IsAdmin : Boolean read FIsAdmin write FIsAdmin;
    property AccessToken: string read FAccessToken write FAccessToken;
  end;

  TLmxInfoComandoInfoQuery = class
  private
    FLimit: Integer;
    FResponseBuscarComoJson: Boolean;
  public
    property Limit : Integer read FLimit write FLimit;
    property ResponseBuscarComoJson : Boolean read FResponseBuscarComoJson write FResponseBuscarComoJson;
  end;

  TLmxServerComand = class
  private
    FComandoProcessado : TLmxInfoComandoProcessadoNoServidor;
    FInfoAuth: TLmxInfoComandoInfoAuth;
    FInfoQuery: TLmxInfoComandoInfoQuery;
  protected
    procedure Inicializar; virtual;
    procedure Finalizar; virtual;

    function GetComandoProcessado : TLmxInfoComandoProcessadoNoServidor;

    function DoProcessarComando(const AInfoComando : TLmxInfoComandoProcessadoNoServidor) : Boolean; virtual;
    function DoProcessarComandoPost(const AInfoComando : TLmxInfoComandoProcessadoNoServidor) : Boolean; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetComandoProcessado(const AComandoProcessado : TLmxInfoComandoProcessadoNoServidor);

    property InfoAuth: TLmxInfoComandoInfoAuth read FInfoAuth;
    property InfoQuery: TLmxInfoComandoInfoQuery read FInfoQuery;

    function GetRequisicaoCliente : ILmxRequisicaoCliente;

    function ProcessarComando(const AComando : TLmxInfoComandoServidor;
      const AResponseInfo : TIdHTTPResponseInfo; out AComandoProcessado : TLmxInfoComandoProcessadoNoServidor) : Boolean; virtual;
    class function GetAttributes : TLmxServerComandAttributes;
  end;

  TLmxServerRestComand = class(TLmxServerComand)

  end;

  TlmxHttp = class(TComponent)

  end;

  IRest = interface
    function GetJson : string;
    function GetParamsGet : string;
  end;

  IRestSend = interface(IRest)

  end;

//  IRestResponse = interface(IRest)
//    function GetResponseCode: Integer;
//    procedure SetResponseCode(const Value: Integer);
//    function GetResponseBody: string;
//    procedure SetResponseBody(const Value: string);
//
//    property ResponseCode : Integer read GetResponseCode write SetResponseCode;
//    property ResponseBody : string read GetResponseBody write SetResponseBody;
//    function TentarCarregar<T>(const AObjeto : T) : Boolean;
//  end;

//  TRest = class(TInterfacedObject, IRest)
  TRest = class
  private
    FJsonString : string;
  public
    constructor Create(const AJsonString : string = '');
    function GetJson: string; virtual;
    function GetParamsGet: string; virtual;
  end;

  TRestResponse = class(TRest)
  private
    FResponseCode : Integer;
    FResponseBody : string;
    FResponseError : string;
    function GetResponseCode: Integer;
    procedure SetResponseCode(const Value: Integer);
    function GetResponseBody: string;
    procedure SetResponseBody(const Value: string);
    function GetResponseError: string;
    procedure SetResponseError(const Value: string);
  public
    property ResponseCode : Integer read GetResponseCode write SetResponseCode;
    property ResponseBody : string read GetResponseBody write SetResponseBody;
    property ResponseError : string read GetResponseError write SetResponseError;

    function Carregar<T : Class, constructor>(const AObjeto : T) : Boolean;
    function TentarCarregar<T : Class, constructor>(out AObjeto : T) : Boolean; overload;
    function TentarCarregar<T : Class, constructor>(const ALista : ILmxEnumerable; const AOnNovoITem :  TOnNewItemObjectEnumJson = nil) : Boolean; overload;
  end;

  TRestSend = class(TRest)

  end;

//object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
//  MaxLineAction = maException
//  Port = 0
//  DefaultPort = 0
//  SSLOptions.Method = sslvTLSv1_1
//  SSLOptions.SSLVersions = [sslvTLSv1_1]
//  SSLOptions.Mode = sslmUnassigned
//  SSLOptions.VerifyMode = []
//  SSLOptions.VerifyDepth = 0
//  Left = 224
//  Top = 164
//end

  TLmxInfoComandoServidor = class
  private
    FTipo: TLmxAttributeComandoMetodo;
    FPorta: Integer;
    FContext: TIdContext;
    FRequestInfo: TIdHTTPRequestInfo;
    FPosComando: string;
    FParametros: string;
    FAccessToken: string;
    FServer : TLmxHttpServer;
    FIdentificador: string;
    procedure DoCriarIdentificador;
  public
    constructor Create(const ATipo : TLmxAttributeComandoMetodo; const APorta : Integer;
      const AContext : TIdContext; const ARequestInfo: TIdHTTPRequestInfo); overload;
    constructor Create(const AInfoComandoServidor : TLmxInfoComandoServidor); overload;

    property Porta : Integer read FPorta;
    property Tipo : TLmxAttributeComandoMetodo read FTipo;
    property Context: TIdContext read FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo;
    property PosComando : string read FPosComando write FPosComando;
    property Parametros : string read FParametros write FParametros;
    property AccessToken : string read FAccessToken write FAccessToken;
    property Identificador : string read FIdentificador write FIdentificador;
    property Server : TLmxHttpServer read FServer write FServer;

    function TentarObterId(out AId : Integer) : Boolean;
    function TentarObterCondicaoConsulta(out ACondicaoConsulta : string) : Boolean;

    function TentarObterValorParametro(const AParametro : string; out AValorParametro : string) : Boolean;
    function TentarObterValorPostStream(out AValorPostStream : string) : Boolean; overload;
    function TentarObterValorPostStream(AValorPostStream : TStream) : Boolean; overload;
    function TentarObterValorHeader(const AParametro : string; out AValorHeader : string) : Boolean;

    function GetBodyAsString : string;

  end;

  TLmxInfoComandoProcessadoNoServidor = class
  private
    FExecutor: TLmxServerComand;
    FInfoComando: TLmxInfoComandoServidor;
    FResposneInfo: TIdHTTPResponseInfo;
  public
    constructor Create(const AExecutor : TLmxServerComand; const AInfoComando : TLmxInfoComandoServidor;
      const AResponseInfo : TIdHTTPResponseInfo);
    destructor Destroy; override;

    property Executor : TLmxServerComand read FExecutor;
    property InfoComando : TLmxInfoComandoServidor read FInfoComando;
    property ResposneInfo : TIdHTTPResponseInfo read FResposneInfo;
  end;

  TLmxMiddleWareEvent = reference to procedure (
    const AComando : TLmxServerComand;const AInfoComando : TLmxInfoComandoServidor; const AResponseInfo : TIdHTTPResponseInfo;
    const ARota : string; const Next : TProc);

  TLmxServicesEventClass<T : class> = reference to function : T;
//  TLmxServicesEventInterfaces<T : ILmxContext> = reference to function : T;

  TLmxMiddleWareEvents = class(TList<TLmxMiddleWareEvent>);
//  TLmxServicesEventsClass = class(TObjectDictionary<TClass, TLmxServicesEventClass<TObject>>);
//  TLmxServicesEventsInterface = class(TObjectDictionary<TGuid, TLmxServicesEventInterfaces<ILmxContext>>);

  TLmxHttpServer = class(TLmxHttp)
  private
    FHTTPServer : TIdHttpServer;
    FHTTPSServer : TIdHttpServer;
    FIPWatch: TIdIPWatch;
    FComandos : TLmxServerComandRegister;
    FPorta: Integer;
    FPortaHttps: Integer;
    FOnProcessarComando: TLmxHttpOnProcessarComandoEvent;
    FOnProcessarComandoRef : TLmxHttpOnProcessarComandoRef;
    FServerName: string;
    FEnderecos : TStrings;
    FOnValidarAutenticacao: TLmxHttpOnValidarAutenticacaoEvent;
    FOnConectar: TLmxHttpOnConectarEvent;
    FUDPServer: TIdUDPServer;
    FOnReceberPedidoDeConexao: TLmxHttpOnReceberPedidoDeConexaoEvent;
    FOnErroComando: TLmxHttpOnErroComandoEvent;
    FOnErroComandoRef: TLmxHttpOnErroComandoRef;
    FMiddleWareEvents : TLmxMiddleWareEvents;
//    FServicesEventsClass : TLmxServicesEventsClass;
    FServicesEventsInterfaces : TLmxServicesEventsInterface;
    FIOHandlerHttps : TIdServerIOHandlerSSLOpenSSL;
//    FContext : TRttiContext;
    procedure CarregarEnderecosDisponiveis;
    procedure DoExecutarMiddleWares(
      const AComando: TLmxServerComand; const AInfoComando: TLmxInfoComandoServidor;
      const AResponseInfo: TIdHTTPResponseInfo; const ARota : string);

    function GetRotaComando(const ARequestInfo: TIdHTTPRequestInfo) : string;
    function DoValidarAutenticacao(const AAutenticacao: TIdAuthentication) : Boolean;
    procedure DoValidarPropriedadesComando(ARequestInfo: TIdHTTPRequestInfo; const AComando: TLmxServerComandClass);
//    function GetPropriedadesComando(const AComando: TLmxServerComandClass; out AAtributos : TLmxServerComandAttributes) : Boolean;

    procedure DoNotificarErro(const AComando : TLmxInfoComandoServidor; const AErro : Exception; const pDataBase : string);

    function DoProcessarEventoComando(const AComando : TLmxServerComand;const AInfoComando : TLmxInfoComandoServidor;
      const AResponseInfo : TIdHTTPResponseInfo; const ARota : string;
      out AComandoProcessado : TLmxInfoComandoProcessadoNoServidor) : Boolean; virtual;

    procedure DoProcessarComando(const ATipo : TLmxAttributeComandoMetodo; AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    procedure AoReceberMensagemLocalizacao(AThread: TIdUDPListenerThread; const AData: TIdBytes;
      ABinding: TIdSocketHandle);
    procedure AoProcessarComandoGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure AoProcessarComandoPost(AContext: TIdContext; AHeaders: TIdHeaderList;
      var VPostStream: TStream);

    procedure AoConectar(AContext: TIdContext);
    procedure AoReceberAutenticacao(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String; var VHandled: Boolean);

    procedure AoDarExcecaoNaEscuta(AThread: TIdListenerThread; AException: Exception);
    procedure AoDarExcecao(AContext: TIdContext; AException: Exception);

    procedure Configurar(const APorta, APortaHttps : Integer);
    procedure DoValidarParamsHttps;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function Ativo : Boolean;
    function HttpsAtivo : Boolean;
    property Porta : Integer read FPorta;
    property PortaHttps : Integer read FPortaHttps;
    property ServerName : string read FServerName;
    property Enderecos : TStrings read FEnderecos;

    function GetCaminhoReferencia : string;

    procedure SetParamsHttps(const pCertFileName, pCertKeyFileName : string;
      const pIdSSLVersion : TIdSSLVersion = sslvSSLv23);

    procedure Ativar(const APorta : Integer; const pAtivarLocalizador : Boolean = False; const APortaHttps : Integer = 0);
    procedure Desativar;

    property OnReceberPedidoDeConexao : TLmxHttpOnReceberPedidoDeConexaoEvent read FOnReceberPedidoDeConexao
      write FOnReceberPedidoDeConexao;
    property OnProcessarComando : TLmxHttpOnProcessarComandoEvent read FOnProcessarComando
      write FOnProcessarComando;
    property OnValidarAutenticacao : TLmxHttpOnValidarAutenticacaoEvent read FOnValidarAutenticacao
      write FOnValidarAutenticacao;
    property OnConectar : TLmxHttpOnConectarEvent read FOnConectar write FOnConectar;
    property OnErroComando : TLmxHttpOnErroComandoEvent read FOnErroComando
      write FOnErroComando;

    procedure SetOnProcessarComando(const pOnProcessarComandoRef : TLmxHttpOnProcessarComandoRef);
    procedure SetOnErroComando(const pOnErroComandoRef : TLmxHttpOnErroComandoRef);

    procedure AdicionarComando(const AComando : TLmxServerComandClass; const ARota : string = '');
    procedure ObterListaComandos(out AComandos : TObjectDictionary<string,TLmxServerComandClass>);

    procedure AdicionarMiddleWare(const AMiddleWareEvent : TLmxMiddleWareEvent);
//    procedure AdicionarService<T : class>(const AServiceEvent : TLmxServicesEventClass<T>); overload;
    procedure AdicionarService<T : ILmxContext>(const AIntf : TGuid; const AServiceEvent : TLmxServicesEventInterfaces<T>); overload;
    function ObterService<T : ILmxContext>(const AComando : TLmxServerComand = nil) : T;
  end;

  TLmxComandoHttpPing = class(TLmxServerComand)
  protected
    function DoProcessarComando(const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean; override;
  end;

  TLmxComandoHttpBrowser = class(TLmxServerComand)
  protected
    function DoProcessarComando(const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean; override;
  end;

//  TBaseList<T : Class, constructor> = class(TInterfacedPersistent, ILmxEnumerable)
//  private
//    FList : TObjectList<T>;
//  protected
//    function GetItemObject(const AIndex: Integer): TObject;
//    function GetNewItemObject: TObject;
//    function GetDescription : string; virtual;
//  public
//    constructor Create;
//    destructor Destroy; override;
//
//    function GetEnumerator: TEnumerator<T>;
//    function First : T;
//    function Remove(const Value : T) : Integer;
//    procedure Clear;
//
//    function Add(const Value : T) : Integer; overload;
//    function Add : T; overload;
//    function Count: Integer;
//  end;

implementation

uses
  REST.Json;

{ TRest }

constructor TRest.Create(const AJsonString: string);
//var
//  lSerialization: TLmxSerialization;
begin
  FJsonString := AJsonString;
  if FJsonString <> '' then
    TLmxSerialization.FromJsonString(Self, FJsonString, False);
//  lSerialization := TLmxSerialization.Create(Self, False);
//  try
//    lSerialization.FromJson(AJsonString);
//  finally
//    FreeAndNil(lSerialization);
//  end;
end;

function TRest.GetJson: string;
begin
  Result := TLmxSerialization.ToJsonString(Self, False);
  if (Result = '{}') and (FJsonString <> '')  then
    Result := FJsonString;
end;

function TRest.GetParamsGet: string;
begin
  Result := TLmxSerialization.ExternalToParamsGet(Self);
end;

{ TlmxHttRest }

//procedure TlmxHttpRest.AddHeader(const AHeader, AValue: string);
//var
//  lIndex : integer;
//begin
//  FHttp.Request.CustomHeaders.FoldLines := false;
//
//  lIndex := FHttp.Request.CustomHeaders.IndexOfName(AHeader);
//  if lIndex > -1 then
//    FHttp.Request.CustomHeaders.Delete(lIndex);
//
//  FHttp.Request.CustomHeaders.Values[AHeader] := AValue;
//end;

{function TlmxHttpRest.LocalizarServidor(const APorta : Integer; out ACaminhoServidor: string): Boolean;
var
  lRede : ILmxRede;
  lMaquinasRede: TLmxMaquinasRede;
  I: Integer;
  lMaquinaRede: TLmxMaquinaRede;
  lRetorno: TRestResponse;
  lCaminho: string;
begin
  Result := False;
  ACaminhoServidor := '';
  lRede := TLmxRedeWindows.Create;
  try
    lRede.ListarMaquinasRede(lMaquinasRede);

    for I := 0 to lMaquinasRede.Count - 1 do
    begin
      lMaquinaRede := lMaquinasRede.Items[I];
      try
        lCaminho := 'http://' + lMaquinaRede.IPMaquina  + ':' + IntToStr(APorta);
        lRetorno := Get(lCaminho + '/Ping');
        if lRetorno.ResponseCode = 200 then
        begin
          ACaminhoServidor := lCaminho;
          Result := True;
          Exit;
        end;
      except
      end;
    end;

  finally
//    FreeAndnil(lRede);
  end;
end;  }

{ TRestResponse }

function TRestResponse.Carregar<T>(const AObjeto: T): Boolean;
begin
  Result := False;
  if FResponseCode = 200 then
    Result := TLmxSerialization.FromJsonString(AObjeto, FResponseBody, False);
end;

function TRestResponse.GetResponseBody: string;
begin
  Result := FResponseBody;
end;

function TRestResponse.GetResponseCode: Integer;
begin
  Result := FResponseCode;
end;

function TRestResponse.GetResponseError: string;
begin
  Result := FResponseError;
end;

procedure TRestResponse.SetResponseBody(const Value: string);
begin
  FResponseBody := Value;
end;

procedure TRestResponse.SetResponseCode(const Value: Integer);
begin
  FResponseCode := Value;
end;

procedure TRestResponse.SetResponseError(const Value: string);
begin
  FResponseError := Value;
end;

function TRestResponse.TentarCarregar<T>(const ALista: ILmxEnumerable; const AOnNovoITem :  TOnNewItemObjectEnumJson): Boolean;
var
  lObjeto : T;
begin
  Result := False;
  lObjeto := T.Create;
  try
    if FResponseCode = 200 then
//      Result := lObjeto.FromJsonArrayString(ALista, FResponseBody, T, AOnNovoITem, False);
      Result := TLmxSerialization.FromJsonArrayString(lObjeto, ALista, FResponseBody, AOnNovoITem, False);
  finally
    FreeAndNil(lObjeto);
  end;
end;

function TRestResponse.TentarCarregar<T>(out AObjeto: T): Boolean;
begin
  Result := False;
  AObjeto := T.Create;
  if FResponseCode = 200 then
    Result := TLmxSerialization.FromJsonString(AObjeto, FResponseBody, False);
end;


{ TLmxHttpServer }

procedure TLmxHttpServer.AdicionarComando(const AComando: TLmxServerComandClass;
  const ARota: string);
var
  lRota: string;
  lRotas: TLmxRotasRest;
  lEnumRotas: TLmxRotasRest.TEnumerator;
begin
  lRota := ARota;
  if lRota = '' then
  begin
    lRotas := TLmxSerialization.ObterCaminhoRest(AComando);
    try
      lEnumRotas := lRotas.GetEnumerator;
      try
        while lEnumRotas.MoveNext do
        begin
          lRota := lEnumRotas.Current.Rota;
          FComandos.Add(lRota, AComando);
        end;
      finally
        FreeAndNil(lEnumRotas);
      end;
    finally
      FreeAndNil(lRotas);
    end;
  end else
    FComandos.Add(lRota, AComando);
end;

procedure TLmxHttpServer.AdicionarMiddleWare(
  const AMiddleWareEvent: TLmxMiddleWareEvent);
begin
  FMiddleWareEvents.Add(AMiddleWareEvent);
end;

//procedure TLmxHttpServer.AdicionarService<T>(
//  const AServiceEvent: TLmxServicesEventClass<T>);
//begin
//  FServicesEventsClass.Add(T, TLmxServicesEventClass<T>(AServiceEvent));
//end;

procedure TLmxHttpServer.AdicionarService<T>(
  const AIntf : TGuid;
  const AServiceEvent: TLmxServicesEventInterfaces<T>);
begin
  FServicesEventsInterfaces.Add(AIntf, TLmxServicesEventInterfaces<ILmxContext>(AServiceEvent));
end;

procedure TLmxHttpServer.AoConectar(AContext: TIdContext);
begin
  if Assigned(FOnConectar) then
    FOnConectar(AContext);
end;

procedure TLmxHttpServer.AoDarExcecao(AContext: TIdContext; AException: Exception);
var
  lInfoComando: TLmxInfoComandoServidor;
begin
  if Assigned(FOnProcessarComando) then
  begin
    lInfoComando := TLmxInfoComandoServidor.Create;
    try
      lInfoComando.PosComando := 'Erro Context : ' +  AException.Message;
      FOnProcessarComando(lInfoComando, nil);
    finally
      lInfoComando.Free;
    end;
  end;

  if Assigned(FOnProcessarComandoRef) then
  begin
    lInfoComando := TLmxInfoComandoServidor.Create;
    try
      lInfoComando.PosComando := 'Erro Context : ' +  AException.Message;
      FOnProcessarComandoRef(lInfoComando, nil);
    finally
      lInfoComando.Free;
    end;
  end;

end;

procedure TLmxHttpServer.AoDarExcecaoNaEscuta(AThread: TIdListenerThread; AException: Exception);
var
  lInfoComando: TLmxInfoComandoServidor;
begin
  if Assigned(FOnProcessarComando) then
  begin
    lInfoComando := TLmxInfoComandoServidor.Create;
    try
      lInfoComando.PosComando := 'Erro Listener : ' +  AException.Message;
      FOnProcessarComando(lInfoComando, nil);
    finally
      lInfoComando.Free;
    end;
  end;
  if Assigned(FOnProcessarComandoRef) then
  begin
    lInfoComando := TLmxInfoComandoServidor.Create;
    try
      lInfoComando.PosComando := 'Erro Listener : ' +  AException.Message;
      FOnProcessarComandoRef(lInfoComando, nil);
    finally
      lInfoComando.Free;
    end;
  end;
end;

procedure TLmxHttpServer.AoProcessarComandoGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  try
//    AResponseInfo.ContentEncoding := 'UTF-8';
    if ARequestInfo.CommandType = hcPOST then
      DoProcessarComando(TLmxAttributeComandoMetodo.cmPost, AContext, ARequestInfo, AResponseInfo)
    else if ARequestInfo.CommandType = hcPUT  then
      DoProcessarComando(TLmxAttributeComandoMetodo.cmPut, AContext, ARequestInfo, AResponseInfo)
    else if ARequestInfo.CommandType = hcDELETE  then
      DoProcessarComando(TLmxAttributeComandoMetodo.cmDelete, AContext, ARequestInfo, AResponseInfo)
    else
      DoProcessarComando(TLmxAttributeComandoMetodo.cmGet, AContext, ARequestInfo, AResponseInfo);
  except
    raise Exception.Create('Erro');
  end;
end;

procedure TLmxHttpServer.AoProcessarComandoPost(AContext: TIdContext;
  AHeaders: TIdHeaderList; var VPostStream: TStream
  );
begin

//  DoProcessarComando(htcPost, AContext, ARequestInfo, AResponseInfo);
end;


procedure TLmxHttpServer.AoReceberAutenticacao(AContext: TIdContext;
  const AAuthType, AAuthData: String; var VUsername, VPassword: String;
  var VHandled: Boolean);
begin
  VHandled := True;
end;

procedure TLmxHttpServer.AoReceberMensagemLocalizacao(AThread: TIdUDPListenerThread; const AData: TIdBytes;
  ABinding: TIdSocketHandle);
var
  lPorta : Integer;
  lMensagem : string;
begin
  lMensagem := BytesToString(AData);
  if copy(lMensagem, 1, 2) = 'GC' then
  begin
    lPorta := StrToIntDef(copy(lMensagem, 4, 5), 0);
    if lPorta <> 0 then
      FUDPServer.Broadcast('http://' + FServerName + ':' + FPorta.ToString, lPorta, ABinding.PeerIP);

    if Assigned(FOnReceberPedidoDeConexao) then
      FOnReceberPedidoDeConexao('Pedido de Conexão :' + ABinding.IP + ' - ' + ABinding.PeerIP + ' - ' + BytesToString(AData));
  end;
end;

procedure TLmxHttpServer.Ativar(const APorta : Integer; const pAtivarLocalizador : Boolean;
  const APortaHttps : Integer);
begin
  Configurar(APorta, APortaHttps);
  try
    FHTTPServer.Active := True;
    if pAtivarLocalizador then
      FUDPServer.Active := True;
    if APortaHttps > 0 then
    begin
      DoValidarParamsHttps;
      FHTTPSServer.Active := True;
    end;
  except
    FHTTPServer.Active := False;
    FHTTPSServer.Active := False;
    raise;
  end;
end;

function TLmxHttpServer.Ativo: Boolean;
begin
  Result := FHTTPServer.Active or FHTTPSServer.Active;
end;

procedure TLmxHttpServer.Configurar(const APorta, APortaHttps : Integer);
var
  I: Integer;
begin
  FPorta := APorta;
  FPortaHttps := APortaHttps;
  FHTTPServer.DefaultPort := FPorta;
  FHTTPServer.Bindings.DefaultPort := FPorta;
  for I := 0 to FHTTPServer.Bindings.Count - 1 do
    FHTTPServer.Bindings.Items[I].Port := APorta;

  FHTTPServer.OnCommandGet := AoProcessarComandoGet;
  FHTTPServer.OnCommandOther := AoProcessarComandoGet;
  FHTTPServer.OnCreatePostStream := AoProcessarComandoPost;
  FHTTPServer.OnException := AoDarExcecao;
  FHTTPServer.OnListenException := AoDarExcecaoNaEscuta;
  FHTTPServer.OnConnect := AoConectar;
  FHTTPServer.OnParseAuthentication := AoReceberAutenticacao;
 // FHttpServer.OnCon


  FHTTPSServer.DefaultPort := FPortaHttps;
  FHTTPSServer.Bindings.DefaultPort := FPortaHttps;
  for I := 0 to FHTTPSServer.Bindings.Count - 1 do
    FHTTPSServer.Bindings.Items[I].Port := FPortaHttps;

  FHTTPSServer.OnCommandGet := AoProcessarComandoGet;
  FHTTPSServer.OnCommandOther := AoProcessarComandoGet;
  FHTTPSServer.OnCreatePostStream := AoProcessarComandoPost;
  FHTTPSServer.OnException := AoDarExcecao;
  FHTTPSServer.OnListenException := AoDarExcecaoNaEscuta;
  FHTTPSServer.OnConnect := AoConectar;
  FHTTPSServer.OnParseAuthentication := AoReceberAutenticacao;

  CarregarEnderecosDisponiveis;
  FServerName := FIPWatch.LocalIP;

  FUDPServer.DefaultPort := APorta;
  FUDPServer.Bindings.DefaultPort := APorta;
  FUDPServer.OnUDPRead := AoReceberMensagemLocalizacao;

end;

constructor TLmxHttpServer.Create;
begin
  FHTTPServer := TIdHTTPServer.Create(nil);
  FHTTPSServer := TIdHTTPServer.Create(nil);
  FComandos := TLmxServerComandRegister.Create;
  FIPWatch := TIdIPWatch.Create(nil);
  FUDPServer := TIdUDPServer.Create(nil);
  FEnderecos := TStringList.Create;
//  FContext := TRttiContext.Create;

  FMiddleWareEvents := TLmxMiddleWareEvents.Create;
//  FServicesEventsClass := TLmxServicesEventsClass.Create;
  FServicesEventsInterfaces := TLmxServicesEventsInterface.Create;

  FIOHandlerHttps := TIdServerIOHandlerSSLOpenSSL.Create;
  SetParamsHttps('cert.pem', 'key.pem');
//  FIOHandlerHttps.SSLOptions.CertFile := 'cert.pem';
//  FIOHandlerHttps.SSLOptions.KeyFile := 'key.pem';
////  FIOHandlerHttps.SSLOptions.RootCertFile := 'cacert.pem';
//  FIOHandlerHttps.SSLOptions.Method := sslvSSLv23;
//  FIOHandlerHttps.SSLOptions.Mode := sslmServer;

  FHTTPSServer.IOHandler := FIOHandlerHttps;

  AdicionarComando(TLmxComandoHttpPing, '/Ping');
end;

procedure TLmxHttpServer.Desativar;
begin
  FHTTPServer.Active := False;
  FHTTPSServer.Active := False;
end;

destructor TLmxHttpServer.Destroy;
begin
//  FContext.Free;

//  FServicesEventsClass.Free;
  FServicesEventsInterfaces.Free;
  FMiddleWareEvents.Free;

  FreeAndNil(FEnderecos);
  FreeAndNil(FUDPServer);
  FreeAndNil(FIPWatch);
  FreeAndNil(FHTTPServer);
  FreeAndNil(FHTTPSServer);
  FreeAndNil(FComandos);

  FreeAndNil(FIOHandlerHttps);
  inherited;
end;

procedure TLmxHttpServer.DoNotificarErro(const AComando : TLmxInfoComandoServidor; const AErro : Exception; const pDataBase : string);
begin
  if Assigned(FOnErroComandoRef) then
    FOnErroComandoRef(AComando, AErro.Message, pDataBase)
  else
    if Assigned(FOnErroComando) then
      FOnErroComando(AComando, AErro.Message, pDataBase);
end;

procedure TLmxHttpServer.DoExecutarMiddleWares( const AComando: TLmxServerComand; const AInfoComando: TLmxInfoComandoServidor;
  const AResponseInfo: TIdHTTPResponseInfo; const ARota : string);
var
  lMiddlewareEvent: TLmxMiddleWareEvent;
  lProximo: Boolean;
begin
  for lMiddlewareEvent in FMiddleWareEvents do
  begin
    lProximo := False;
    lMiddlewareEvent(AComando, AInfoComando, AResponseInfo, ARota, procedure begin lProximo := True end);
    if not lProximo then
      break;
  end;
end;

procedure TLmxHttpServer.DoProcessarComando(const ATipo: TLmxAttributeComandoMetodo;
  AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  lInfoComando: TLmxInfoComandoServidor;
  lRota: string;
  lClasseComando: TLmxServerComandClass;
  lComando : TLmxServerComand;
  lComandoProcessado: TLmxInfoComandoProcessadoNoServidor;
  lProximaRota: string;
  lUserName: string;
  lPassword: string;
  lProcessado: Boolean;
  lRetornoErroComoBase64 : Boolean;
begin
  lRetornoErroComoBase64 := False;
  TryStrToBool(ARequestInfo.RawHeaders.Values['RetornoErroAsBase64'], lRetornoErroComoBase64);
  // Achar o Comando
  lInfoComando := TLmxInfoComandoServidor.Create(ATipo, FHTTPServer.DefaultPort, AContext, ARequestInfo);
  try
    try
      if ARequestInfo.AuthExists then
      begin
        lUserName := ARequestInfo.AuthUsername;
        lPassword := TIdDecoderMIME.DecodeString(ARequestInfo.AuthPassword);
      end;
//      lInfoComando.AccessToken :=

      lRota := GetRotaComando(ARequestInfo);
      if FComandos.GetComando(lRota, lClasseComando, lProximaRota) then
      begin
        lInfoComando.PosComando := lProximaRota;
        lInfoComando.Parametros := TNetEncoding.URL.Decode(ARequestInfo.QueryParams);
        lInfoComando.Server := Self;

        DoValidarPropriedadesComando(ARequestInfo, lClasseComando);

        lComando := lClasseComando.Create;
        try
          lComandoProcessado := nil;
          try
            DoExecutarMiddleWares(lComando, lInfoComando, AResponseInfo, lProximaRota);
            try
              lProcessado := DoProcessarEventoComando(lComando, lInfoComando, AResponseInfo, lProximaRota, lComandoProcessado);
              if not lProcessado then
              begin
                if lComandoProcessado <> nil then
                  FreeAndNil(lComandoProcessado);
                lProcessado := lComando.ProcessarComando(lInfoComando, AResponseInfo, lComandoProcessado);
              end;
            except on E:Exception do
              begin
                DoNotificarErro(lInfoComando, E, '');
                raise;
              end;
            end;

            if lProcessado then
            begin
              if Assigned(FOnProcessarComando) then
                FOnProcessarComando(lInfoComando, lComandoProcessado);
              if Assigned(FOnProcessarComandoRef) then
                FOnProcessarComandoRef(lInfoComando, lComandoProcessado);
            end;

            AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin', '*');
            if AResponseInfo.ContentType = '' then
              AResponseInfo.ContentType := 'application/json;charset=UTF-8';

          finally
            if lComandoProcessado <> nil then
              FreeAndNil(lComandoProcessado);
          end;
        finally
          FreeAndNil(lComando);
        end;
      end else begin
        raise ELmxCommandRotaNaoConfigurada.Create('Rota não configurada [' + lRota + ']');
//        AResponseInfo.ResponseNo := 400;
//        AResponseInfo.ResponseText := 'Rota não configurada !';
//        if Assigned(FOnProcessarComando) then
//          FOnProcessarComando(lInfoComando, nil);
      end;
    except
      on E:ELmxCommand do
      begin
        AResponseInfo.ContentType := 'text/html;charset=ISO-8859-1';
        AResponseInfo.ResponseNo := E.GetCodigoRetornoHttp;
//        AResponseInfo.ResponseText := E.Message;
        if lRetornoErroComoBase64 then
        begin
          AResponseInfo.ContentEncoding := 'Base64'; //'ISO-8859-1';
          AResponseInfo.ResponseText := TIdEncoderMIME.EncodeString(E.Message);
        end else
          AResponseInfo.ResponseText := E.Message;
      end;
      on E:Exception do
      begin
        AResponseInfo.ContentType := 'text/html;charset=ISO-8859-1';
        AResponseInfo.ResponseNo := 500;
        if lRetornoErroComoBase64 then
        begin
          AResponseInfo.ContentEncoding := 'Base64'; // 'ISO-8859-1';
          AResponseInfo.ResponseText := TIdEncoderMIME.EncodeString(E.Message);
        end else
          AResponseInfo.ResponseText := E.Message;
      end;
    end;
  finally
    FreeAndNil(lInfoComando);
  end;
end;

function TLmxHttpServer.DoProcessarEventoComando(const AComando: TLmxServerComand;
  const AInfoComando: TLmxInfoComandoServidor; const AResponseInfo: TIdHTTPResponseInfo;
  const ARota : string; out AComandoProcessado: TLmxInfoComandoProcessadoNoServidor): Boolean;
var
//  lSeralization: TLmxSerialization;
//  lEvento: TRttiMethod;
//  lParametro: TRttiParameter;
  lValorDateTime : TDatetime;
  lParametro: TLmxServerComandMethodParameters;
  lValorParametro: string;
  lParametros: TList<TValue>;
  lRetorno: TValue;
  lInstancia: TObject;
  lListaInstancias : TObjectList<TObject>;
//  lPermiteGet: Boolean;
//  lPermitePost: Boolean;
  lEnumObject: ILmxEnumerable;
  lRetornoObject : ILmxRetorno;
  lInterfaceObject : IInterface;
  lClass: TClass;
  lEventoCreate: TRttiMethod;
  lPropriedades: TLmxServerComandAttributes;
  lMetodo: TLmxServerComandMethodAttributes;

  lMetodosClasse : TArray<TRttiMethod>;
  lMetodoClasse : TRttiMethod;

  lInstanciaStream: TObject;
  lTipos : TRttiType;
  lEvent: TLmxServicesEventClass<TObject>;
  lInterface: TGUID;
  lEventIntf: TLmxServicesEventInterfaces<ILmxContext>;
  lREtornoEvent: ILmxContext;
  ltmp: ILmxContext;
  lRestanteComando: string;
  lReturnFileName: string;


  lObjetoAsHtmlPage : ILmxHtmlPage;
  z: TZipFile;
  lStreamREtorno: TStringStream;
  lStreamEntrada: TStringStream;
  lComp: TIdCompressorZLib;
  lFileName: string;

begin
  lRetorno := nil;
  Result := False;
  lPropriedades := FComandos.GetPropriedadesDoComando(TLmxServerComandClass(AComando.ClassType));
  if lPropriedades.Metodos.TentaObterMetodo(ARota, AInfoComando.Tipo, lMetodo) then
  begin
    if lMetodo.Evento <> nil then
    begin
      AComandoProcessado := TLmxInfoComandoProcessadoNoServidor.Create(AComando, AInfoComando, AResponseInfo);

      lListaInstancias := TObjectList<TObject>.Create;
      lParametros := TList<TValue>.Create;
      try
    //    if lPropriedades.Metodos.TentaObterMetodo(ARota, AInfoComando.Tipo, lMetodo) then
    //    begin
          if (not lMetodo.PermiteGet) and (AInfoComando.Tipo = TLmxAttributeComandoMetodo.cmGet) then
            raise Exception.Create('Método não permite ser chamado como GET');

          if (not lMetodo.PermitePost) and (AInfoComando.Tipo = TLmxAttributeComandoMetodo.cmPost) then
            raise Exception.Create('Método não permite ser chamado como POST');

          if (not lMetodo.PermitePut) and (AInfoComando.Tipo = TLmxAttributeComandoMetodo.cmPut) then
            raise Exception.Create('Método não permite ser chamado como PUT');

          if (not lMetodo.PermiteDelete) and (AInfoComando.Tipo = TLmxAttributeComandoMetodo.cmDelete) then
            raise Exception.Create('Método não permite ser chamado como DELETE');

    //      lTipos := TLmxSerialization.FContexto.GetType(AComando.ClassType);
    //      try

    //        lMetodosClasse := lTipos.GetMethods;
    //        for lMetodoClasse in lMetodosClasse do
    //        begin
    //          if (not Result) and (lMetodoClasse.Name = lMetodo.Evento.Name) then
    //          begin
                for lParametro in lMetodo.Parametros do
    //            for lParametro in lMetodoClasse.GetParameters do
                begin
                  lValorParametro := '';
                  if lParametro.FromBody then
                    AInfoComando.TentarObterValorPostStream(lValorParametro)
                  else if lParametro.FromHeader then
                    AInfoComando.TentarObterValorHeader(lParametro.Nome, lValorParametro)
                  else if lParametro.FromParams then
                  begin
                    if not lMetodo.ParametroRotaValido(ARota, lValorParametro, lRestanteComando) then
                      lValorParametro := '';
                  end
//                    AInfoComando.TentarObterValorHeader(lParametro.Nome, lValorParametro)
                  else
                    if not AInfoComando.TentarObterValorParametro(lParametro.Nome, lValorParametro) then
      //              if not AInfoComando.TentarObterValorParametro(lParametro.Name, lValorParametro) then
                    begin
                      lValorParametro := '';
                    end;

    //              case lParametro.ParamType.TypeKind of
                  case lParametro.TypeKind of
                    tkUnknown: ;
                    tkInteger: lParametros.Add(TValue.From<Integer>(StrToIntDef(lValorParametro,0)));
                    tkChar   : lParametros.Add(TValue.From<string>(lValorParametro));
                    tkEnumeration:
                      begin
                        if lParametro.QualifiedName = 'System.Boolean' then
                          lParametros.Add(TValue.From<boolean>(StrToBoolDef(lValorParametro, False)));
                      end;
                    tkFloat  :
                      begin
                        if lParametro.QualifiedName = 'System.TDateTime' then
                        begin
                          if not TryStrToDateTime(lValorParametro, lValorDateTime) then
                            lValorDateTime := StrToFloatDef(lValorParametro,0);
                          lParametros.Add(TValue.From<TDateTime>(lValorDateTime));
                        end else
                          lParametros.Add(TValue.From<double>(StrToFloatDef(lValorParametro, 0)));
                      end;
                    tkString : lParametros.Add(TValue.From<string>(lValorParametro));
//                    tkSet: ;
                    tkClass   :
                      begin
                        lClass := GetTypeData(lParametro.Handle)^.ClassType;
                        if lParametro.FromServices then
                        begin
                          raise Exception.Create('Parâmetros [FromService] devem implementar a interface ILmxContext e serem do tipo interfaces');
                        //                          if FServicesEventsClass.TryGetValue(lClass, lEvent) then
//                            lParametros.Add(TValue.From<TObject>(lEvent))
//                          else
//                            lParametros.Add(TValue.From<TObject>(nil));
                        end
                        else
                        if lClass.ClassNameIs('TLmxInfoComandoProcessadoNoServidor') then
                          lParametros.Add(TValue.From<TLmxInfoComandoProcessadoNoServidor>(AComandoProcessado))
                        else
                        begin
                          lInstanciaStream := nil;
                          if lParametro.FromBody then // AInfoComando.Tipo = TLmxAttributeComandoMetodo.cmPost then
                          begin
                            lValorParametro := '';
                            if lClass.InheritsFrom(TStream) then
                            begin
                              lInstanciaStream := lClass.Create;
                              AInfoComando.TentarObterValorPostStream(TStream(lInstanciaStream));
                            end else
                              AInfoComando.TentarObterValorPostStream(lValorParametro);
                          end;
      //                    lClass := GetTypeData(lParametro.ParamType.Handle)^.ClassType;
                          if (lValorParametro <> '') or (lInstanciaStream <> nil) then
                          begin
                            if lInstanciaStream <> nil then
                              lInstancia := lInstanciaStream
                            else begin
                              if TLmxSerialization.ObterMetodoCreate(lClass, lEventoCreate) then
                                lInstancia := lEventoCreate.Invoke(lClass, []).AsObject
                              else
                                lInstancia := lClass.Create;
                            end;
                            lListaInstancias.Add(lInstancia);
                            if Supports(lInstancia, ILmxEnumerable, lEnumObject) then
                            begin
          //                    lInstancia.FromString(lValorParametro, False);
                              TLmxSerialization.FromJsonArrayString(lInstancia, lEnumObject, lValorParametro);
                            end else if (lInstanciaStream = nil) then begin
                              TLmxSerialization.FromJsonString(lInstancia, lValorParametro, False);
                            end;
                            lParametros.Add(TValue.From<TObject>(lInstancia));
                          end else
      //                      raise Exception.Create('Valor do parâmetro ' + lParametro.Name + ' inválido.');
                              raise Exception.Create('Valor do parâmetro ' + lParametro.Nome + ' inválido.');
                        end;
                      end;
//                    tkMethod: ;
                    tkWChar: lParametros.Add(TValue.From<string>(lValorParametro));
                    tkLString: lParametros.Add(TValue.From<string>(lValorParametro));
                    tkWString: lParametros.Add(TValue.From<string>(lValorParametro));
                    tkVariant: lParametros.Add(TValue.FromVariant(lValorParametro));
//                    tkArray: ;
//                    tkRecord: ;
                    tkInterface:
                      begin
                        lInterface := GetTypeData(lParametro.Handle)^.GUID;
                        if lParametro.FromServices then
                        begin
                          if FServicesEventsInterfaces.TryGetValue(lInterface, lEventIntf) then
                          begin
                            ltmp := lEventIntf;
                            ltmp.SetRequisicaoCliente(AComando.GetRequisicaoCliente);
                            ltmp.SetServicesEvents(FServicesEventsInterfaces);
//                            lParametros.Add(TValue.FromVariant(lEventIntf)); //.GetObject as IInterface));

                            lParametros.Add(TValue.From<TObject>(ltmp.GetObject));
//                            lParametros.Add(TValue.From<TObject>(lEventIntf(AComando.InfoAuth.CodUser).GetObject));
                          end else
                            raise Exception.Create(lParametro.Nome + ' Não registrado - Parâmetros [FromService] devem implementar a interface ILmxContext e serem do tipo interfaces');
                        end else
    //                    if (lParametro.ParamType.QualifiedName = 'uLmxHttp.ILmxResultComandHttp') then
                        if (lParametro.QualifiedName = 'uLmxHttp.ILmxResultComandHttp') then
                        begin
                          lInstancia := TLmxResultComandHttp.Create;
                          lParametros.Add(TValue.From<TObject>(lInstancia));
                        end;
        //                lClass := GetTypeData(lParametro.ParamType.Handle)^.ClassType;
        //                if Supports(lClass, ILmxResultComandHttp) then
        //                lParametros.Add(TValue.From<TObject>(lInstancia));
                      end;
//                    tkInt64: ;
//                    tkDynArray: ;
                    tkUString: lParametros.Add(TValue.From<string>(lValorParametro));
//                    tkClassRef: ;
//                    tkPointer: ;
//                    tkProcedure: ;
                    else
                      lParametros.Add(TValue.From<string>(lValorParametro));
                  end;
                end;

    //            lRetorno := lMetodoClasse.Invoke(AComando, lParametros.ToArray);
                try
                  lRetorno := lMetodo.Evento.Invoke(AComando, lParametros.ToArray);
                finally
                  if not (lRetorno.IsEmpty) then
                  begin
                    if lRetorno.IsType<IInterface> then //lInterfaceObject <> nil then
                    begin
                      lInterfaceObject := lRetorno.AsInterface;
                      if Supports(lInterfaceObject, ILmxHtmlPage, lObjetoAsHtmlPage) then
                      begin
                        AResponseInfo.ContentText := lObjetoAsHtmlPage.GetHmtlResponse;
                        AResponseInfo.ContentType := lObjetoAsHtmlPage.GetHmtlContentType;
                      end else if Supports(lInterfaceObject, ILmxRetorno) then
                      begin
                        lRetornoObject := ILmxRetorno(lInterfaceObject);
                        if Supports(lRetornoObject.RetornoAsObject, ILmxEnumerable, lEnumObject) then
                        begin
                          AResponseInfo.ContentText := TLmxSerialization.ToJsonArrayString(lEnumObject);
                        end else if Supports(lInterfaceObject, ILmxRetornoArquivo) then begin
                          lReturnFileName := ExtractFileName(ILmxRetornoArquivo(lInterfaceObject).GetReturnFileName);
                          lFileName := ILmxRetornoArquivo(lInterfaceObject).GetFileName;
                          if not TFile.Exists(lFileName) then
                            raise Exception.Create('Arquivo solicitado ' + lReturnFileName + ' não existe.');

                          AResponseInfo.ContentDisposition := IndyFormat('attachment; filename="%s";', [ExtractFileName(lReturnFileName)]);
                          AResponseInfo.ServeFile(AInfoComando.Context, lFileName);
                        end else begin
                          if lRetornoObject.RetornoAsObject.ClassParent.ClassName.Contains('TObjectList') then
                            AResponseInfo.ContentText := TJson.ObjectToJsonString(lRetornoObject.RetornoAsObject)
                          else
                            AResponseInfo.ContentText := TLmxSerialization.ToJsonString(lRetornoObject.RetornoAsObject);
                        end;
                      end;
                    end else if (lRetorno.IsObject) then
                    begin
                      if (lRetorno.AsObject <> nil) then
                      begin
                        AResponseInfo.ContentType := 'application/json';

                        if Supports(lRetorno.AsObject, ILmxEnumerable, lEnumObject) then
                        begin
                          AResponseInfo.ContentText := TLmxSerialization.ToJsonArrayString(lEnumObject);
                        end else begin
                          if lRetorno.AsObject.ClassParent.ClassName.Contains('TObjectList') then
                            AResponseInfo.ContentText := TJson.ObjectToJsonString(lRetorno.AsObject)
                          else
                            AResponseInfo.ContentText := TLmxSerialization.ToJsonString(lRetorno.AsObject);
                        end;
                        lRetorno.AsObject.Free;
                      end;
                    end else
                    begin
                      case lRetorno.Kind of
                        tkUnknown: ;
                        tkInteger: AResponseInfo.ContentText := IntToStr(lRetorno.ASInteger);
                        tkChar: AResponseInfo.ContentText := lRetorno.AsString;
                        tkEnumeration: ;
                        tkFloat: AResponseInfo.ContentText := FloatToStr(lRetorno.AsExtended);
                        tkString: AResponseInfo.ContentText := lRetorno.AsString;
                        tkSet: ;
                        tkClass: ;
                        tkMethod: ;
                        tkWChar: AResponseInfo.ContentText := lRetorno.AsString;
                        tkLString: AResponseInfo.ContentText := lRetorno.AsString;
                        tkWString: AResponseInfo.ContentText := lRetorno.AsString;
                        tkVariant: ;
                        tkArray: ;
                        tkRecord: ;
                        tkInterface: ;
                        tkInt64: AResponseInfo.ContentText := IntToStr(lRetorno.ASInteger);
                        tkDynArray: ;
                        tkUString: AResponseInfo.ContentText := lRetorno.AsString;
                        tkClassRef: ;
                        tkPointer: ;
                        tkProcedure: ;
                      end;
                    end;
                  end;

                end;


                Result := True;
    //          end;
    //        end;
    //      finally
    //        lTipos.Free;
    //      end;
        //end;
      finally
        FreeAndNil(lParametros);
        FreeAndNil(lListaInstancias);
      end;
    end;
  end;
end;

function TLmxHttpServer.DoValidarAutenticacao(
  const AAutenticacao: TIdAuthentication) : Boolean;
var
  lSessaoCritica: TMultiReadExclusiveWriteSynchronizer;
begin
  lSessaoCritica := TMultiReadExclusiveWriteSynchronizer.Create;
  try
    lSessaoCritica.BeginRead;

    if Assigned(FOnValidarAutenticacao) then
      Result := FOnValidarAutenticacao(AAutenticacao.Username, AAutenticacao.Password)
    else
      Result := True;

  finally
    lSessaoCritica.EndRead;
    lSessaoCritica.Free;
  end;
end;

procedure TLmxHttpServer.DoValidarParamsHttps;
begin
  if FIOHandlerHttps.SSLOptions.CertFile  = '' then
    raise Exception.Create('Um arquivo CertFile deve ser passado para que o Https seja utilizado');
  if FIOHandlerHttps.SSLOptions.KeyFile  = '' then
    raise Exception.Create('Um arquivo KeyFile deve ser passado para que o Https seja utilizado');
  if not TFile.Exists(FIOHandlerHttps.SSLOptions.CertFile) then
    raise Exception.Create(Format('Arquivo %s não encontrado.' , [FIOHandlerHttps.SSLOptions.CertFile]));
  if not TFile.Exists(FIOHandlerHttps.SSLOptions.KeyFile) then
    raise Exception.Create(Format('Arquivo %s não encontrado.' , [FIOHandlerHttps.SSLOptions.KeyFile]));
end;

procedure TLmxHttpServer.DoValidarPropriedadesComando(
  ARequestInfo: TIdHTTPRequestInfo;
  const AComando: TLmxServerComandClass);
var
  lAtributos: TLmxServerComandAttributes;
begin
  lAtributos := FComandos.GetPropriedadesDoComando(AComando);
  if lAtributos.AutenticacaoObrigatoria then
  begin
    if not ARequestInfo.AuthExists then
      raise ELmxCommandAuth.Create('Autenticao Obrigatoria');
    ARequestInfo.Authentication := TIdBasicAuthentication.Create;
    ARequestInfo.Authentication.Username := ARequestInfo.AuthUsername;
    ARequestInfo.Authentication.Password := ARequestInfo.AuthPassword;
    if not DoValidarAutenticacao(ARequestInfo.Authentication) then
      raise ELmxCommandAuth.Create('Login ou senha inválidos');
  end;
end;

//function TLmxHttpServer.GetPropriedadesComando(const AComando: TLmxServerComandClass; out AAtributos : TLmxServerComandAttributes) : Boolean;
//begin
//  AAtributos := FComandos.GetPropriedadesDoComando(AComando);
//  Result := True;
//end;

procedure TLmxHttpServer.CarregarEnderecosDisponiveis;
var
  lList : TIdStackLocalAddressList;
  I: Integer;
begin
  lList := TIdStackLocalAddressList.Create;
  FEnderecos.Clear;
  TIdStack.IncUsage;
  try
    FEnderecos.BeginUpdate;
    GStack.GetLocalAddressList(lList);
    for I := 0 to lList.Count - 1 do
    begin
      if lList.Addresses[I].IPVersion = Id_IPv4 then
        FEnderecos.Add(lList.Addresses[I].IPAddress)
    end;
  finally
    FEnderecos.EndUpdate;
    TIdStack.DecUsage;
    lList.Free;
  end;
end;

function TLmxHttpServer.GetCaminhoReferencia: string;
begin
  Result := 'http://' + FServerName + ':' + FPorta.ToString;
//  if FEnderecos.Count > 0 then
//    Result := 'http://' + FEnderecos[0] + ':' + FPorta.ToString;
end;

function TLmxHttpServer.GetRotaComando(
  const ARequestInfo: TIdHTTPRequestInfo): string;
begin
  Result := ARequestInfo.URI;
end;

function TLmxHttpServer.HttpsAtivo: Boolean;
begin
  Result := FHTTPSServer.Active;
end;

procedure TLmxHttpServer.ObterListaComandos(
  out AComandos: TObjectDictionary<string, TLmxServerComandClass>);
var
  lEnumComandos: TLmxServerComandRegister.TPairEnumerator;
begin
  AComandos := TObjectDictionary<string,TLmxServerComandClass>.Create;
  lEnumComandos := FComandos.GetEnumerator;
  try
    while lEnumComandos.MoveNext do
    begin
      AComandos.Add(lEnumComandos.Current.Key, lEnumComandos.Current.Value);
    end;
  finally
    lEnumComandos.Free;
  end;
end;

function TLmxHttpServer.ObterService<T>(const AComando : TLmxServerComand): T;
var
  lInterface: TGUID;
  lEventIntf: TLmxServicesEventInterfaces<ILmxContext>;
  ltmp: ILmxContext;
begin
  Result := nil;
  lInterface := GetTypeData(PTypeInfo(TypeInfo(T)))^.GUID;
  if FServicesEventsInterfaces.TryGetValue(lInterface, lEventIntf) then
  begin
    ltmp := lEventIntf;
    if AComando <> nil then
      ltmp.SetRequisicaoCliente(AComando.GetRequisicaoCliente);
    ltmp.SetServicesEvents(FServicesEventsInterfaces);
    Result := T(ltmp);
  end;

end;

procedure TLmxHttpServer.SetOnErroComando(
  const pOnErroComandoRef: TLmxHttpOnErroComandoRef);
begin
  FOnErroComandoRef := pOnErroComandoRef;
end;

procedure TLmxHttpServer.SetOnProcessarComando(
  const pOnProcessarComandoRef: TLmxHttpOnProcessarComandoRef);
begin
  FOnProcessarComandoRef := pOnProcessarComandoRef;
end;

procedure TLmxHttpServer.SetParamsHttps(const pCertFileName, pCertKeyFileName: string; const pIdSSLVersion : TIdSSLVersion);
begin
  FIOHandlerHttps.SSLOptions.CertFile := pCertFileName;
  FIOHandlerHttps.SSLOptions.KeyFile := pCertKeyFileName;
//  FIOHandlerHttps.SSLOptions.RootCertFile := 'cacert.pem';
  FIOHandlerHttps.SSLOptions.Method := pIdSSLVersion;
  FIOHandlerHttps.SSLOptions.Mode := sslmServer;
end;

{ TLmxServerComandoProc }

constructor TLmxInfoComandoServidor.Create(const ATipo: TLmxAttributeComandoMetodo;
  const APorta : Integer; const AContext : TIdContext; const ARequestInfo: TIdHTTPRequestInfo);
begin
  FContext := AContext;
  FRequestInfo := ARequestInfo;
  FTipo := ATipo;
  FPorta := APorta;
  DoCriarIdentificador;
end;

{ TLmxInfoComandoProcessadoNoServidor }


constructor TLmxInfoComandoServidor.Create(
  const AInfoComandoServidor: TLmxInfoComandoServidor);
begin
  FTipo     := AInfoComandoServidor.Tipo;
  FPorta    := AInfoComandoServidor.Porta;
  FContext  := AInfoComandoServidor.Context;
  FRequestInfo := AInfoComandoServidor.RequestInfo;
  FPosComando := AInfoComandoServidor.PosComando;
  FParametros := AInfoComandoServidor.Parametros;
  FIdentificador := AInfoComandoServidor.Identificador;
  FServer  := AInfoComandoServidor.Server;
end;

procedure TLmxInfoComandoServidor.DoCriarIdentificador;
//var
//  lGuid: TGUID;
begin
 // CreateGUID(lGuid);
  FIdentificador := ''; //GUIDToString(lGuid);
end;

function TLmxInfoComandoServidor.GetBodyAsString: string;
var
  lStringStream: TStringStream;
begin
  Result := '';
  try
    lStringStream := TStringStream.Create;
    try
      if FRequestInfo.PostStream <> nil then
      begin
        FRequestInfo.PostStream.Position := 0;
        lStringStream.Position := 0;
        lStringStream.CopyFrom(FRequestInfo.PostStream, 0);

        Result := lStringStream.DataString;
      end;
    finally
      lStringStream.Free;
    end;
  except

  end;
end;

function TLmxInfoComandoServidor.TentarObterId(
  out AId: Integer): Boolean;
begin
  AId := StrToIntDef(Copy(FPosComando, 2, length(FPosComando)), 0);
  Result := AId > 0;
end;

function TLmxInfoComandoServidor.TentarObterCondicaoConsulta(
  out ACondicaoConsulta: string): Boolean;
var
  lParametros: TStringList;
  I: Integer;
begin
  Result := False;
  ACondicaoConsulta := '';
  if FParametros <> '' then
  begin
    lParametros := TStringList.Create;
    try
      lParametros.LineBreak := '&';
      lParametros.Text := FParametros;

      for I := 0 to lParametros.Count - 1 do
      begin
        if ACondicaoConsulta <> '' then
          ACondicaoConsulta := ACondicaoConsulta + ' AND ';
        ACondicaoConsulta := ACondicaoConsulta + '(' + lParametros[I] + ')';
      end;
      Result := True;
    finally
      FreeAndNil(lParametros);
    end;
  end;
end;

function TLmxInfoComandoServidor.TentarObterValorHeader(const AParametro : string;
  out AValorHeader: string): Boolean;
begin
  AValorHeader := Self.RequestInfo.RawHeaders.Values[AParametro];
  Result := AValorHeader <> '';
end;

function TLmxInfoComandoServidor.TentarObterValorParametro(
  const AParametro: string; out AValorParametro: string): Boolean;
var
  lParametros: TStringList;
  lParametro : string;
begin
  Result := False;
  lParametro := AParametro;
  AValorParametro := '';
  if FParametros <> '' then
  begin
    lParametros := TStringList.Create;
    try
      lParametros.LineBreak := '&';
      lParametros.Text := FParametros;
      AValorParametro := lParametros.Values[lParametro];
      Result := AValorParametro <> '';
      if not Result and ((lowercase(lParametro[1]) = 'p') or (lowercase(lParametro[1]) = 'a')) then
      begin
        AValorParametro := lParametros.Values[Copy(lParametro, 2, length(lParametro))];
        Result := AValorParametro <> '';
      end;
    finally
      FreeAndNil(lParametros);
    end;
  end;
end;

function TLmxInfoComandoServidor.TentarObterValorPostStream(
  AValorPostStream: TStream): Boolean;
begin
  Result := False;
  try
    if Self.RequestInfo.PostStream <> nil then
    begin
      Self.RequestInfo.PostStream.Position := 0;
      AValorPostStream.Position := 0;
      AValorPostStream.CopyFrom(Self.RequestInfo.PostStream, 0);
      Result := True;
    end;
  except

  end;
end;

function TLmxInfoComandoServidor.TentarObterValorPostStream(out AValorPostStream: string): Boolean;
var
  lStringStream: TStringStream;
begin
  Result := False;
  AValorPostStream := '';
  try
    lStringStream := TStringStream.Create;
    try
      if Self.RequestInfo.PostStream <> nil then
      begin
        Self.RequestInfo.PostStream.Position := 0;
        lStringStream.Position := 0;
        lStringStream.CopyFrom(Self.RequestInfo.PostStream, 0);

        AValorPostStream := lStringStream.DataString;
        Result := True;
      end;
    finally
      lStringStream.Free;
    end;
  except

  end;
end;

{ TLmxInfoComandoProcessadoNoServidor }

constructor TLmxInfoComandoProcessadoNoServidor.Create(
  const AExecutor : TLmxServerComand; const AInfoComando: TLmxInfoComandoServidor;
  const AResponseInfo : TIdHTTPResponseInfo);
begin
  FExecutor := AExecutor;
  FResposneInfo := AResponseInfo;
  FInfoComando := TLmxInfoComandoServidor.Create(AInfoComando);
  FExecutor.SetComandoProcessado(Self);
end;

destructor TLmxInfoComandoProcessadoNoServidor.Destroy;
begin
  FreeAndNil(FInfoComando);
  inherited;
end;

{ TLmxServerComand }

constructor TLmxServerComand.Create;
begin
  Inicializar;
end;

destructor TLmxServerComand.Destroy;
begin
  Finalizar;
  inherited;
end;

function TLmxServerComand.DoProcessarComando(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
begin
  Result := False;
end;

function TLmxServerComand.DoProcessarComandoPost(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
begin
  Result := True;
end;

procedure TLmxServerComand.Finalizar;
begin
  FInfoAuth.Free;
  FInfoQuery.Free;
end;

class function TLmxServerComand.GetAttributes: TLmxServerComandAttributes;
begin
  Result := TLmxSerialization.GetServerCommandAttributes(Self);
end;

function TLmxServerComand.GetComandoProcessado: TLmxInfoComandoProcessadoNoServidor;
begin
  Result := FComandoProcessado;
end;

function TLmxServerComand.GetRequisicaoCliente: ILmxRequisicaoCliente;
begin
  Result := TLmxRequisicaoCliente.Create;
  Result.SetUSerId( FInfoAuth.CodUser );
  Result.SetUSerIsAdmin( FInfoAuth.IsAdmin );
  Result.SetLimit( FInfoQuery.Limit );
  Result.SetResponseBuscarComoJson( FInfoQuery.ResponseBuscarComoJson );
end;

procedure TLmxServerComand.Inicializar;
begin
  FInfoAuth := TLmxInfoComandoInfoAuth.Create;
  FInfoQuery := TLmxInfoComandoInfoQuery.Create;
end;

function TLmxServerComand.ProcessarComando(
  const AComando: TLmxInfoComandoServidor; const AResponseInfo : TIdHTTPResponseInfo;
  out AComandoProcessado : TLmxInfoComandoProcessadoNoServidor) : Boolean;
var
  lComando: string;
begin
  AComandoProcessado := TLmxInfoComandoProcessadoNoServidor.Create(Self, AComando, AResponseInfo);
  FComandoProcessado := AComandoProcessado;
  if AComando.Tipo = TLmxAttributeComandoMetodo.cmPost then
    Result := DoProcessarComandoPost(AComandoProcessado)
  else
    Result := DoProcessarComando(AComandoProcessado);
  if not Result then
  begin
    lComando := AComando.PosComando;
    if (AComando <> nil) and (AComando.RequestInfo <> nil) then
      lComando := AComando.RequestInfo.RawHttpCommand;
    raise ELmxCommandNaoExecutado.Create('Comando não executado : ' + lComando);
  end;
end;

procedure TLmxServerComand.SetComandoProcessado(
  const AComandoProcessado: TLmxInfoComandoProcessadoNoServidor);
begin
  FComandoProcessado := AComandoProcessado;
end;

{ TLmxServerComandRegister }

constructor TLmxServerComandRegister.Create;
begin
  FAtributosComando := TObjectDictionary<TLmxServerComandClass,TLmxServerComandAttributes>.Create([doOwnsValues]);
  FReader := TMultiReadExclusiveWriteSynchronizer.Create;
  inherited Create;
end;

destructor TLmxServerComandRegister.Destroy;
begin
  FreeAndNil(FReader);
  FreeAndNil(FAtributosComando);
  inherited;
end;

function TLmxServerComandRegister.GetComando(const ARota: string;
  out AComando: TLmxServerComandClass; out AProximaRota : string): Boolean;
begin
  FReader.BeginRead;

  try
    Result := TentaCarregarComando(ARota, AComando, AProximaRota);
  finally

    FReader.EndRead;

  end;
end;

function TLmxServerComandRegister.GetPropriedadesDoComando(
  const AComando: TLmxServerComandClass): TLmxServerComandAttributes;
var
  lPropriedades: TLmxServerComandAttributes;
begin

//  Result := nil;
//  try
    if FAtributosComando.TryGetValue(AComando, lPropriedades) then
      Result := lPropriedades
    else begin
  //    lPropriedades := TLmxServerComandAttributes.Create;
  //    lPropriedades.AutenticacaoObrigatoria := False;
      FReader.BeginWrite;
      try
        lPropriedades := TLmxSerialization.GetServerCommandAttributes(AComando);
        if lPropriedades <> nil then
          FAtributosComando.Add(AComando, lPropriedades);
        Result := lPropriedades;
      finally
        FReader.EndWrite;
      end;
    end;
end;

function TLmxServerComandRegister.TentaCarregarComando(
  const ARota: string; out AComando : TLmxServerComandClass; out AProximaRota : string): Boolean;
var
  lInternalComando: string;
  lIndexComando: Integer;
  lComandos: TStringList;
begin
  lComandos := TStringList.Create;
  try
    Result := False;
    lInternalComando := ARota;

    if not TryGetValue(lInternalComando, AComando) then
    begin
      if lInternalComando[1] = '/' then
        Delete(lInternalComando, 1, 1);
    end;

    lComandos.Clear;
    lComandos.Delimiter := '/';
    lComandos.DelimitedText := lInternalComando;

    lInternalComando := '';
    for lIndexComando := 0 to lComandos.Count - 1 do
    begin
      lInternalComando := lInternalComando + '/' + lComandos[lIndexComando];
//      if lInternalComando[1] = '/' then
//        Delete(lInternalComando, 1, 1);
      if not Result then
      begin
        if TryGetValue(lInternalComando, AComando) then
        begin
          Result := True;
          lInternalComando := '';
//          Break;
        end else
        begin
          if lInternalComando[1] = '/' then
            Delete(lInternalComando, 1, 1);
        end;
      end;
    end;

    if Result then
    begin
      AProximaRota := lInternalComando;
    end else
      AProximaRota := '';

  finally
    FreeAndNil(lComandos);
  end;
end;

{ TLmxComandoHttpPing }

function TLmxComandoHttpPing.DoProcessarComando(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
begin
//  AInfoComando.ResposneInfo.ContentType := 'application/text';
  AInfoComando.ResposneInfo.ContentText := 'pong';

  Result := True;
end;


{ ELmxCommandAuth }

function ELmxCommandAuth.GetCodigoRetornoHttp: Integer;
begin
  Result := 403;
end;

{ TLmxComandoHttpBrowser }

function TLmxComandoHttpBrowser.DoProcessarComando(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
var
  lNomePastaPagina: string;
  lNomeArquivoIndex: string;
begin
  lNomePastaPagina := ExtractFilePath(ParamStr(0)) + 'Paginas\' + Self.ClassName + '\' ;
  lNomeArquivoIndex := lNomePastaPagina + 'Index.html';

  if TDirectory.Exists(lNomePastaPagina) then
  begin
    if TFile.Exists(lNomeArquivoIndex) then
    begin
      AInfoComando.ResposneInfo.ContentType := 'text/html; charset=utf-8';
      AInfoComando.ResposneInfo.ContentText := TFile.ReadAllText(lNomeArquivoIndex);
    end else begin
      AInfoComando.ResposneInfo.ContentType := 'text/html; charset=utf-8';
      AInfoComando.ResposneInfo.ContentText := 'Index not found';
    end;
  end;

  Result := True;

end;

{ TLmxResultComandHttp<T> }

{
function TLmxResultComandHttp<T>.GetResultado: T;
begin
  Result := FResultado;
end;

function TLmxResultComandHttp<T>.GetStrResposta: String;
begin
  Result := FStrResposta;
end;

procedure TLmxResultComandHttp<T>.SetDadosResponseInfo(const AResponseInfo: TIdHTTPResponseInfo);
begin
  FResponseInfo := AResponseInfo;
end;

procedure TLmxResultComandHttp<T>.SetDadosResponseInfoGet(const AOnResponse: TOGetDadosResponse);
begin
  AOnResponse(FResultado, FResponseInfo);
end;

procedure TLmxResultComandHttp<T>.SetResultado(const AResultado: T);
begin
  FResultado := AResultado;
end;

procedure TLmxResultComandHttp<T>.SetStrResposta(const AStrResposta: String);
begin
  FStrResposta := AStrResposta;
end;      }


function TLmxResultComandHttp.GetStrResposta: String;
begin
  Result := FStrResposta;
end;

procedure TLmxResultComandHttp.SetDadosResponseInfo(const AResponseInfo: TIdHTTPResponseInfo);
begin
  FResponseInfo := AResponseInfo;
end;

procedure TLmxResultComandHttp.SetDadosResponseInfoGet(const AOnResponse: TOGetDadosResponse);
begin
  AOnResponse(FResponseInfo);
end;

procedure TLmxResultComandHttp.SetStrResposta(const AStrResposta: String);
begin
  FStrResposta := AStrResposta;
end;


{ ELmxCommandRotaNaoConfigurada }


function ELmxCommandRotaNaoConfigurada.GetCodigoRetornoHttp: Integer;
begin
  Result := 400;
end;

//{ TBaseList<T> }
//
//function TBaseList<T>.Add(const Value: T): Integer;
//begin
//  Result := FList.Add(Value);
//end;
//
//function TBaseList<T>.Add: T;
//begin
//  Result := T.Create;
//  FList.Add(Result);
//end;
//
//procedure TBaseList<T>.Clear;
//begin
//  FList.Clear;
//end;
//
//function TBaseList<T>.Count: Integer;
//begin
//  Result := FList.Count;
//end;
//
//
//constructor TBaseList<T>.Create;
//begin
//  FList := TObjectList<T>.Create;
//end;
//
//
//destructor TBaseList<T>.Destroy;
//begin
//  FreeAndNil(FList);
//  inherited;
//end;
//
//
//function TBaseList<T>.First: T;
//begin
//  Result := FList.First;
//end;
//
//
//function TBaseList<T>.GetDescription: string;
//begin
//  Result := Self.ClassName;
//end;
//
//
//function TBaseList<T>.GetEnumerator: TEnumerator<T>;
//begin
//  Result := FList.GetEnumerator;
//end;
//
//
//function TBaseList<T>.GetItemObject(const AIndex: Integer): TObject;
//begin
//  Result := T(FList.Items[AIndex]);
//end;
//
//
//function TBaseList<T>.GetNewItemObject: TObject;
//var
//  lResultado: TObject;
//begin
////  Result := T.Create;
//  lResultado := T.Create;
//  FList.Add(lResultado);
//  Result := lResultado;
//end;
//
//
//function TBaseList<T>.Remove(const Value: T): Integer;
//begin
//  Result := FList.Remove(Value);
//end;

{ ELmxCommandNaoExecutado }


function ELmxCommandNaoExecutado.GetCodigoRetornoHttp: Integer;
begin
  Result := 404;
end;


end.
