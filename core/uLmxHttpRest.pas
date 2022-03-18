unit uLmxHttpRest;

interface

uses
  Classes, IdHTTP, IdUDPServer, IdUDPClient, IdComponent, IdSocketHandle, uLmxAttributes,
  uLmxSerialization, IDGlobal, IDCoderMime, SysUtils, uLmxHttp, System.NetEncoding,
  System.Rtti, Generics.Collections, uLmxModeloBase, IdSSLOpenSSL;

type
  ILmxResponse = interface
  ['{E841FF23-2856-4164-85D1-D7665F51701C}']
    function GetResponseCode: Integer;
    procedure SetResponseCode(const Value: Integer);
    function GetResponseBody: string;
    procedure SetResponseBody(const Value: string);
    function GetResponseError: string;
    procedure SetResponseError(const Value: string);
    function GetResponseTime: TTime;
    procedure SetResponseTime(const Value: TTime);
    property ResponseCode : Integer read GetResponseCode write SetResponseCode;
    property ResponseBody : string read GetResponseBody write SetResponseBody;
    property ResponseError : string read GetResponseError write SetResponseError;
    property ResponseTime : TTime read GetResponseTime write SetResponseTime;

    function Sucess : Boolean;
  end;


  TLmxResponseValue = record
  private
    FResponse : ILmxResponse;
  public
    class operator Implicit(Value: ILmxResponse): TLmxResponseValue;
    function AsObject<T: constructor, class>: T;
    procedure ToObject<T: constructor, class>(AObject : T);
    function AsString: string;
    property Response: ILmxResponse read FResponse write FResponse;
  end;

  ELmxExceptionResponse = class(Exception)
  private
    FResponse : TLmxResponseValue;
  public
    constructor Create(const Msg: string; const pResponse : TLmxResponseValue);
  end;

  TLmxRestResponse = class(TInterfacedObject, ILmxResponse)
  private
    FResponseCode : Integer;
    FResponseBody : string;
    FResponseError : string;
    FResponseTime : TTime;
    function GetResponseCode: Integer;
    procedure SetResponseCode(const Value: Integer);
    function GetResponseBody: string;
    procedure SetResponseBody(const Value: string);
    function GetResponseError: string;
    procedure SetResponseError(const Value: string);
    function GetResponseTime: TTime;
    procedure SetResponseTime(const Value: TTime);
  public
    property ResponseCode : Integer read GetResponseCode write SetResponseCode;
    property ResponseBody : string read GetResponseBody write SetResponseBody;
    property ResponseError : string read GetResponseError write SetResponseError;
    property ResponseTime : TTime read GetResponseTime write SetResponseTime;

    function Sucess : Boolean;
  end;

  TLmxAsyncGetResponseSucessfull = reference to procedure (const AResponse : TLmxRestResponse);
  TLmxAsyncGetResponseSucessFail = reference to procedure (const AResponse : TLmxRestResponse);

  TLmxHttpRest = class(TLmxHttp)
  private
    FHttp: TIdHTTP;
    FServerUrl: string;
    FToken: string;
    FRetornoErroAsBase64: Boolean;
    FSourceConnection: String;
    FApplicationName: string;
    FWorkStationId: string;
    FUserId: Integer;
    FWorkstationName: string;
    FApplicationVersion: string;
    FEmpresaId: Integer;
    FParametros : TDictionary<string,TValue> ;
    FRota: string;
    FdSSLIOHandlerSocketOpenSSL : TIdSSLIOHandlerSocketOpenSSL;
    function GetParametro(index: string): TValue;
    procedure SetParametro(index: string; const Value: TValue);
    procedure SetServerUrl(const Value: string);
    procedure SetToken(const Value: string);
    procedure SetRetornoErroAsBase64(const Value: Boolean);
    procedure SetSourceConnection(const Value: String);
    procedure SetApplicationName(const Value: string);
    procedure SetWorkStationId(const Value: string);
    procedure SetUserId(const Value: Integer);
    procedure SetWorkstationName(const Value: string);
    procedure SetApplicationVersion(const Value: string);
    procedure SetEmpresaId(const Value: Integer);
    function PostBody(const pValor: string;
      ACaminho: string): TLmxResponseValue;
    function Upload(const pFile: TMemoryStream;
      ACaminho: string): TLmxResponseValue;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ServerUrl : string read FServerUrl write SetServerUrl;
    property Token : string read FToken write SetToken;
    property RetornoErroAsBase64 : Boolean read FRetornoErroAsBase64 write SetRetornoErroAsBase64;
    property SourceConnection : String read FSourceConnection write SetSourceConnection;
    property WorkStationId : string read FWorkStationId write SetWorkStationId;
    property EmpresaId : Integer read FEmpresaId write SetEmpresaId;
    property ApplicationName  : string read FApplicationName write SetApplicationName;
    property UserId  : Integer read FUserId write SetUserId;
    property WorkstationName  : string read FWorkstationName write SetWorkstationName;
    property ApplicationVersion  : string read FApplicationVersion write SetApplicationVersion;
//    function LocalizarServidor(const APorta : Integer; out ACaminhoServidor : string) : Boolean;

    procedure SetMethod(const pMethod : TIdSSLVersion);

    procedure Download(const pCaminho, pLocalParaSalvarOArquivo, pNomeArquivo : string);

    function Get(ACaminho : string = '') : TLmxResponseValue; overload;

    function Post(ACaminho: string = ''): TLmxResponseValue; overload;
    function Post(const pValor: TObject; ACaminho: string = ''): TLmxResponseValue; overload;

    function Put(ACaminho: string = ''): TLmxResponseValue; overload;
    function Put(const pValor: TObject; ACaminho: string = ''): TLmxResponseValue; overload;


    function Delete(ACaminho: string= '') : TLmxResponseValue; overload;

    property Parametro[index: string]: TValue read GetParametro write SetParametro; default;

    property Rota: string read FRota write FRota;
    function Comando: string;



//    procedure AsyncGet(const ACaminho: string;
//      const AOnSuccessfull: TLmxAsyncGetResponseSucessfull;
//      const AOnFail: TLmxAsyncGetResponseSucessFail; const ASend: TRest);
//
//    function AsyncPost(const ACaminho: string;
//      const AOnSuccessfull: TLmxAsyncGetResponseSucessfull;
//      const AOnFail: TLmxAsyncGetResponseSucessFail;
//      const ASend: IRest): TRestResponse;
  end;

  TLmxHttpRestClass = class of TLmxHttpRest;

//  TLmxHttpClientFactory = class
//  private
//    FHttpRestClients : TObjectList<TlmxHttpRest>;
//  public
//    constructor Create;
//    destructor Destroy; override;
//
//    function HttpClient : TlmxHttpRest;
//  end;
//
//
//  function LmxHttpClientFactory : TLmxHttpClientFactory;

implementation

//var
//  FLmxHttpClientFactory : TLmxHttpClientFactory;
//
//function LmxHttpClientFactory : TLmxHttpClientFactory;
//begin
//  Result := FLmxHttpClientFactory;
//end;


{ TLmxRestResponse }


function TLmxRestResponse.GetResponseBody: string;
begin
  Result := FResponseBody;
end;

function TLmxRestResponse.GetResponseCode: Integer;
begin
  Result := FResponseCode;
end;

function TLmxRestResponse.GetResponseError: string;
begin
  Result := FResponseError;
end;

function TLmxRestResponse.GetResponseTime: TTime;
begin
  Result := FResponseTime;
end;

procedure TLmxRestResponse.SetResponseBody(const Value: string);
begin
  FResponseBody := Value;
end;

procedure TLmxRestResponse.SetResponseCode(const Value: Integer);
begin
  FResponseCode := Value;
end;

procedure TLmxRestResponse.SetResponseError(const Value: string);
begin
  FResponseError := Value;
end;


procedure TLmxRestResponse.SetResponseTime(const Value: TTime);
begin
  FResponseTime := Value;
end;

function TLmxRestResponse.Sucess: Boolean;
begin
  Result := FResponseCode = 200;
end;

{lmxHttpRest }

constructor TLmxHttpRest.Create(AOwner: TComponent);
begin
  inherited;
  FHttp := TIDHttp.Create(Self);
  FHttp.HandleRedirects := True;
  FHttp.Request.ContentType := 'Application/JSON';
  FParametros := TDictionary<string,TValue>.Create;
  FRetornoErroAsBase64 := True;

  FdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvTLSv1_2;
  FdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1_2];

end;

function TLmxHttpRest.Delete(ACaminho : string): TLmxResponseValue;
var
  lPosicaoErro : Integer;
  lErro : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    Result.Response.ResponseBody := FHttp.Delete(FServerUrl + ACaminho);
    Result.Response.ResponseCode := FHttp.ResponseCode;
    FHttp.Disconnect;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);
end;

destructor TLmxHttpRest.Destroy;
begin
  FdSSLIOHandlerSocketOpenSSL.Free;
  FParametros.Free;
  FHttp.Free;
  inherited;
end;


procedure TLmxHttpRest.Download(const pCaminho, pLocalParaSalvarOArquivo, pNomeArquivo : string);
var
  lArquivo : TFileStream;
  lCAminhoCompleto : string;
  lPosicaoErro: Integer;
  lCodigoErro: Integer;
  lErro: string;
begin

  lCAminhoCompleto := pCaminho;
  if not lCAminhoCompleto.Contains('http') then
    lCAminhoCompleto := FServerUrl + comando;


//  Result := TLmxRestResponse.Create;

  lCodigoErro := 200;
  try
    lArquivo := TFileStream.Create(IncludeTrailingPathDelimiter(pLocalParaSalvarOArquivo) +  pNomeArquivo, fmCreate);
    try
      FHttp.Get(lCAminhoCompleto, lArquivo);
    finally
      FHttp.Disconnect;
      lArquivo.Free;
    end;
  except
    on E:EIdHTTPProtocolException do
      begin
//         Result.Response.ResponseCode := E.ErrorCode;
         lCodigoErro := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           lErro := TIdDecoderMIME.DecodeString(lErro);
         end;
//           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
//         end else begin
//           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
//         end;
      end;
  end;

  if lCodigoErro <> 200 then
    raise Exception.Create(IntToStr(lCodigoErro) + ' - ' + lErro);
//    raise ExcepLmxExceptionResponse.Create(IntToStr(lCodigoErro) + ' - ' + lErro, Result);


end;

procedure TLmxHttpRest.SetToken(const Value: string);
begin
  FToken := Value;
  if FHttp <> nil then
    FHttp.Request.CustomHeaders.AddValue('Token', FToken);
end;

procedure TLmxHttpRest.SetUserId(const Value: Integer);
begin
  FUserId := Value;
  if (FHttp <> nil) and (FUSerId <> 0) then
    FHttp.Request.CustomHeaders.AddValue('UserId', FUSerId.ToString);
end;

procedure TLmxHttpRest.SetWorkStationId(const Value: string);
begin
  FWorkStationId := Value;
  if (FHttp <> nil) and (FWorkStationId <> '') then
    FHttp.Request.CustomHeaders.AddValue('WorkStationId', FWorkStationId);
end;

procedure TLmxHttpRest.SetWorkstationName(const Value: string);
begin
  FWorkstationName := Value;
  if (FHttp <> nil) and (FWorkstationName <> '') then
    FHttp.Request.CustomHeaders.AddValue('WorkStationName', FWorkstationName);
end;

function TLmxHttpRest.Upload(const pFile: TMemoryStream; ACaminho : string): TLmxResponseValue;
var
  lPosicaoErro : Integer;
  lErro : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    pFile.Position := 0;
    Result.Response.ResponseBody := FHttp.Post(FServerUrl + ACaminho, pFile);
    Result.Response.ResponseCode := FHttp.ResponseCode;
    FHttp.Disconnect;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);
end;

procedure TLmxHttpRest.SetApplicationName(const Value: string);
begin
  FApplicationName := Value;
  if (FHttp <> nil) and (FApplicationName <> '') then
    FHttp.Request.CustomHeaders.AddValue('ApplicationName', FApplicationName);
end;

procedure TLmxHttpRest.SetApplicationVersion(const Value: string);
begin
  FApplicationVersion := Value;
  if (FHttp <> nil) and (FApplicationVersion <> '') then
    FHttp.Request.CustomHeaders.AddValue('ApplicationVersion', FApplicationVersion);
end;

procedure TLmxHttpRest.SetEmpresaId(const Value: Integer);
begin
  FEmpresaId := Value;
  if (FHttp <> nil) then
    FHttp.Request.CustomHeaders.AddValue('EmpresaId', FEmpresaId.ToString);
end;

procedure TLmxHttpRest.SetMethod(const pMethod: TIdSSLVersion);
begin
  FdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := pMethod;
  FdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [pMethod];
end;

procedure TLmxHttpRest.SetRetornoErroAsBase64(const Value: Boolean);
begin
  FRetornoErroAsBase64 := Value;
  if (FHttp <> nil) and FRetornoErroAsBase64 then
    FHttp.Request.CustomHeaders.AddValue('RetornoErroAsBase64', 'True');
end;

procedure TLmxHttpRest.SetServerUrl(const Value: string);
begin
  FServerUrl := Value;

  if (FServerUrl <> '') and (FServerUrl[Length(FServerUrl)] <> '/') then
    FServerUrl := FServerUrl + '/';

  if FServerUrl.Contains('https') then
  begin
    SetMethod(sslvTLSv1_2);
    FHttp.IOHandler := FdSSLIOHandlerSocketOpenSSL;
  end;
end;

procedure TLmxHttpRest.SetSourceConnection(const Value: String);
begin
  FSourceConnection := Value;
  if (FHttp <> nil) and (FSourceConnection <> '') then
    FHttp.Request.CustomHeaders.AddValue('SourceConnection', FSourceConnection);
end;

function TLmxHttpRest.Comando: string;
var
  lParametro: TPair<string,TValue>;
begin
  Result := '';
  for lParametro in FParametros do
  begin
    if Result <> '' then
      Result := Result+'&';
    Result :=Result + lParametro.Key +'=' +lParametro.Value.ToString;
  end;

  Result := TNetEncoding.URL.Encode(Result);

  if Result <> '' then
    Result := FRota+'?'+Result
  else
    Result := FRota;
end;

function TLmxHttpRest.Get(ACaminho: string): TLmxResponseValue;
var
  lPosicaoErro : Integer;
  lErro : string;
  lRetorno : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    lRetorno := FHttp.Get(FServerUrl + ACaminho);
    if UpperCase(FHttp.Response.CharSet) <> 'UTF-8' then
      lRetorno := Utf8ToAnsi(RawByteString(lRetorno));
    Result.Response.ResponseBody := lRetorno;
    Result.Response.ResponseCode := FHttp.ResponseCode;
    FHttp.Disconnect;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);

end;

function TLmxHttpRest.GetParametro(index: string): TValue;
begin
  Result := FParametros.Items[index];
end;

function TLmxHttpRest.Post(ACaminho: string): TLmxResponseValue;
begin
  Result := Post(nil,ACaminho);
end;

function TLmxHttpRest.Post(const pValor: TObject; ACaminho: string): TLmxResponseValue;
var
  lSource : TStringStream;
  lPosicaoErro : Integer;
  lJsonString, lErro : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    lJsonString := '';
    if Assigned(pValor)  then
      lJsonString := TLmxSerialization.ToJsonString(pValor);

    lSource := TStringStream.Create(lJsonString);

    try
      lSource.Position := 0;
      Result.Response.ResponseBody := FHttp.Post(FServerUrl + ACaminho, lSource);
      Result.Response.ResponseCode := FHttp.ResponseCode;
      FHttp.Disconnect;
    finally
      FreeAndNil(lSource);
    end;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);

end;

function TLmxHttpRest.PostBody(const pValor: string;
  ACaminho: string): TLmxResponseValue;
var
  lSource : TStringStream;
  lPosicaoErro : Integer;
  lErro : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    lSource := TStringStream.Create(pValor);
    try
      lSource.Position := 0;
      Result.Response.ResponseBody := FHttp.Post(FServerUrl + ACaminho, lSource);
      Result.Response.ResponseCode := FHttp.ResponseCode;
      FHttp.Disconnect;
    finally
      FreeAndNil(lSource);
    end;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);
end;

procedure TLmxHttpRest.SetParametro(index: string; const Value: TValue);
begin
  FParametros.AddOrSetValue(index,Value);
end;

function TLmxHttpRest.Put(ACaminho: string): TLmxResponseValue;
begin
  Result := Put(nil,ACaminho);
end;

function TLmxHttpRest.Put(const pValor: TObject; ACaminho: string): TLmxResponseValue;
var
  lSource : TStringStream;
  lPosicaoErro : Integer;
  lJsonString, lErro : string;
begin
  if ACaminho = '' then
    ACaminho := Comando;

  Result := TLmxRestResponse.Create;
  try
    lJsonString := '';
    if Assigned(pValor)  then
      lJsonString := TLmxSerialization.ToJsonString(pValor);

    lSource := TStringStream.Create(lJsonString);

    try
      lSource.Position := 0;
      Result.Response.ResponseBody := FHttp.Put(FServerUrl + ACaminho, lSource);
      Result.Response.ResponseCode := FHttp.ResponseCode;
      FHttp.Disconnect;
    finally
      FreeAndNil(lSource);
    end;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.Response.ResponseCode := E.ErrorCode;
         lPosicaoErro := Pos(E.ErrorCode.ToString, E.Message);
         if (FHttp.Response.ContentEncoding = 'Base64') and (lPosicaoErro > 0) then
         begin
           lErro := copy(E.Message, lPosicaoErro + E.ErrorCode.ToString.Length + 1, E.Message.Length);
           Result.Response.ResponseError := TIdDecoderMIME.DecodeString(lErro);
         end else begin
           Result.Response.ResponseError := Utf8ToAnsi(RawByteString(E.Message));
         end;
      end;
  end;

  if Result.Response.ResponseCode <> 200 then
    raise ELmxExceptionResponse.Create(IntToStr(Result.Response.ResponseCode) + ' - ' + Result.Response.ResponseError, Result);
end;

//procedure TlmxHttpRest.AsyncGet(const ACaminho: string;
//  const AOnSuccessfull: TLmxAsyncGetResponseSucessfull;
//  const AOnFail: TLmxAsyncGetResponseSucessFail;
//  const ASend: TRest);
//var
//  lServerUrl : string;
//begin
//  lServerUrl := Self.ServerUrl;
//  TThread.CreateAnonymousThread(
//    procedure()
//    var
//      lHttpRest: TlmxHttpRest;
//      lResponse: TRestResponse;
//    begin
//      lHttpRest := TlmxHttpRest.Create(nil);
//      try
//        lHttpRest.ServerUrl := lServerUrl;
//        try
//          try
//            lResponse := lHttpRest.Get(ACaminho, ASend);
//            if lResponse.ResponseCode = 200 then
//            begin
//              if Assigned(AOnSuccessfull) then
//                TThread.Synchronize(TThread.CurrentThread,
//                  procedure ()
//                  begin
//                    AOnSuccessfull(lResponse);
//                  end
//                );
//            end else begin
//              if Assigned(AOnFail) then
//                TThread.Synchronize(TThread.CurrentThread,
//                  procedure ()
//                  begin
//                    AOnFail(lResponse);
//                  end
//                );
//            end;
//          except on E:Exception do
//            begin
//              if Assigned(AOnFail) then
//                TThread.Synchronize(TThread.CurrentThread,
//                  procedure ()
//                  begin
//                    if lResponse = nil then
//                      lResponse := TRestResponse.Create;
//                    lResponse.ResponseCode := 9999;
//                    lResponse.ResponseError := E.Message;
//                    AOnFail(lResponse);
//                  end
//                );
//            end;
//          end;
//        finally
//          lResponse.Free;
//        end;
//      finally
//        lHttpRest.Free;
//      end;
//    end
//    ).Start;
//end;
//
//
//function TlmxHttpRest.AsyncPost(const ACaminho: string;
//  const AOnSuccessfull: TLmxAsyncGetResponseSucessfull;
//  const AOnFail: TLmxAsyncGetResponseSucessFail;
//  const ASend: IRest): TRestResponse;
//var
//  lThread : TThread;
//begin
//  lThread := TThread.CreateAnonymousThread(
//    procedure()
//    var
//      lHttpRest: TlmxHttpRest;
//      lResponse: TRestResponse;
//    begin
//      lHttpRest := TlmxHttpRest.Create(nil);
//      try
//        lHttpRest.ServerUrl := Self.ServerUrl;
//        try
//          try
//            lResponse := lHttpRest.Post(ACaminho, ASend);
//            if lResponse.ResponseCode = 200 then
//            begin
//              if Assigned(AOnSuccessfull) then
//                TThread.Synchronize(lThread,
//                  procedure ()
//                  begin
//                    AOnSuccessfull(lResponse);
//                  end
//                );
//            end else begin
//              if Assigned(AOnFail) then
//                TThread.Synchronize(lThread,
//                  procedure ()
//                  begin
//                    AOnFail(lResponse);
//                  end
//                );
//            end;
//          except on E:Exception do
//            begin
//              if Assigned(AOnFail) then
//                TThread.Synchronize(lThread,
//                  procedure ()
//                  begin
//                    if lResponse = nil then
//                      lResponse := TRestResponse.Create;
//                    lResponse.ResponseCode := 9999;
//                    lResponse.ResponseError := E.Message;
//                    AOnFail(lResponse);
//                  end
//                );
//            end;
//          end;
//        finally
//          lResponse.Free;
//        end;
//      finally
//        lHttpRest.Free;
//      end;
//    end
//    );
//  lThread.Start;
//end;

function TLmxResponseValue.AsObject<T>: T;
var
  lLmxEnumerable: ILmxEnumerable;
begin
  if Response.ResponseCode = 200 then
  begin
    Result := T.Create;
    ToObject(Result);
  end else
    raise Exception.Create(IntToStr(Response.ResponseCode) + ' - ' + Response.ResponseError);
end;

function TLmxResponseValue.AsString: string;
begin
  if Response.ResponseCode = 200 then
  begin
    Result := Response.ResponseBody;
  end else
    raise Exception.Create(IntToStr(Response.ResponseCode) + ' - ' + Response.ResponseError);
end;

class operator TLmxResponseValue.Implicit(Value: ILmxResponse): TLmxResponseValue;
begin
  Result.FResponse := Value;
end;

{ ELmxExceptionResponse }

constructor ELmxExceptionResponse.Create(const Msg: string;
  const pResponse: TLmxResponseValue);
begin
  inherited Create(Msg);
  FResponse := pResponse;
end;

procedure TLmxResponseValue.ToObject<T>(AObject: T);
var
  lLmxEnumerable: ILmxEnumerable;
begin
  if Response.ResponseCode = 200 then
  begin
    if Supports(AObject, ILmxEnumerable, lLmxEnumerable) then
    begin
      TLmxSerialization.FromJsonArrayString(AObject, lLmxEnumerable, Response.ResponseBody)
    end else if (AObject is TLmxModeloBase) then begin
      TLmxModeloBase(AObject).FromJsonString(Response.ResponseBody)
    end else if (AObject is TObject) then begin
      TLmxSerialization.FromJsonString(AObject, Response.ResponseBody);
    end;
  end else
    raise Exception.Create(IntToStr(Response.ResponseCode) + ' - ' + Response.ResponseError);
end;

{TLmxHttpClientFactory}

//function TLmxHttpClientFactory.HttpClient: TlmxHttpRest;
//begin
//  Result := TlmxHttpRest.Create(nil);
//  Self.FHttpRestClients.Add(Result);
//end;
//
//initialization
//  FLmxHttpClientFactory := TLmxHttpClientFactory.Create;
//
//finalization
//  FLmxHttpClientFactory.Free;


end.
