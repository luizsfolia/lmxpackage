unit uLmxHttpAndroid;

interface

uses
  Classes, IdHTTP, SysUtils;

type


  TRestResponse = class
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
  end;

  TlmxHttp = class(TComponent)

  end;


  TlmxHttpRest = class(TlmxHttp)
  private
    FHttp: TIdHTTP;
    FServerUrl: string;
    procedure SetServerUrl(const Value: string);
//    procedure AddHeader(const AHeader : string; const AValue : string);
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ServerUrl : string read FServerUrl write SetServerUrl;
//    function LocalizarServidor(const APorta : Integer; out ACaminhoServidor : string) : Boolean;

    function Get(const ACaminho : string) : TRestResponse; overload;
    function Post(const ACaminho : string) : TRestResponse; overload;
  end;


implementation


{ TRestResponse }

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


{ TlmxHttpRest }

constructor TlmxHttpRest.Create(AOwner: TComponent);
begin
  inherited;
  FHttp := TIDHttp.Create(nil);
  FHttp.HandleRedirects := True;
  FHttp.Request.ContentType := 'Application/JSON';
end;

destructor TlmxHttpRest.Destroy;
begin
  FreeAndNil(FHttp);
  inherited;
end;

function TlmxHttpRest.Get(const ACaminho: string): TRestResponse;
var
  lParametros: string;
begin
  Result := TRestResponse.Create;
  try
    lParametros := '';
//    {$IFDEF MSWINDOWS}
//    Result.ResponseBody := Utf8ToAnsi(RawByteString(FHttp.Get(FServerUrl + ACaminho + lParametros)));
//    {$ELSE}
    Result.ResponseBody := Utf8ToAnsi(FHttp.Get(FServerUrl + ACaminho + lParametros));
//    {$ENDIF}
    Result.ResponseCode := FHttp.ResponseCode;
    FHttp.Disconnect;
//    if ASend <> nil then
//      ASend.Free;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.ResponseError := E.Message;
         Result.ResponseCode := FHttp.ResponseCode;
      end;
  end;
end;

function TlmxHttpRest.Post(const ACaminho: string): TRestResponse;
var
  lSource : TStringList;
begin
  Result := TRestResponse.Create;
  try
    lSource := TStringList.Create;
//    if ASend <> nil then
//    begin
//      lSource.Delimiter := ';';
//      lSource.DelimitedText := ASend.GetJson;
//    end;

    try
//      {$IFDEF MSWINDOWS}
//      Result.ResponseBody := Utf8ToAnsi(RawByteString(FHttp.Post(FServerUrl + ACaminho, lSource)));
//      {$ELSE}
      Result.ResponseBody := Utf8ToAnsi(FHttp.Post(FServerUrl + ACaminho, lSource));
//      {$ENDIF}
      Result.ResponseCode := FHttp.ResponseCode;
      FHttp.Disconnect;
    finally
      FreeAndNil(lSource);
    end;
  except
    on E:EIdHTTPProtocolException do
      begin
         Result.ResponseError := E.Message;
         Result.ResponseCode := FHttp.ResponseCode;
      end;
  end;
end;

procedure TlmxHttpRest.SetServerUrl(const Value: string);
begin
  FServerUrl := Value;

  if (FServerUrl <> '') and (FServerUrl[Length(FServerUrl)] <> '/') then
    FServerUrl := FServerUrl + '/';
end;

end.
