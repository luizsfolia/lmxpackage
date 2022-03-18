unit uLmxHttpDownload;

interface
uses
  System.Classes, {$IFDEF MSWINDOWS} Winapi.Windows, {$ENDIF} uLmxHttp, IdHttp, {$IFDEF VER270}IdBaseComponent, IdAntiFreezeBase, Vcl.IdAntiFreeze{$ELSE}
  IdAntiFreezeBase, Vcl.IdAntiFreeze{$ENDIF},IdSSLOpenSSL, IdCookieManager,
  IdComponent, System.IOUtils, IdGlobal, System.SysUtils;

type

  TLmxHttpOnStatusDownloadEvent = procedure(const AMaximo, AAtual, APercentual, AKb : Double) of object;
  TLmxHttpOnInitDownloadEvent = procedure(const AMaximo : Double) of object;

  TlmxHttpRetorno = class

  end;

  TlmxHttpRetornoArquivo = class(TlmxHttpRetorno)
  private
    FNomeArquivo: string;
    FNovaVersao: string;
  public
    property NomeArquivo : string read FNomeArquivo write FNomeArquivo;
    property NovaVersao : string read FNovaVersao write FNovaVersao;
  end;

  TlmxHttpDownload = class(TlmxHttp)
  private
    FLocalDownloads: string;
    FIdHttp : TIdHttp;
    FIdAntifreeze : TIdAntiFreezeBase;
    FIOHandler : TIdSSLIOHandlerSocketOpenSSL;
    FCookieManager : TIdCookieManager;
    FMaximo : Double;
    FAtual : Double;
    FOnStatus: TLmxHttpOnStatusDownloadEvent;
    FOnIniciarAtualizacao: TLmxHttpOnInitDownloadEvent;
    function GetNomeArquivo(const ACaminhoDownload : string) : string;
    function SalvarArquivo(const AArquivoTmp, ANomeArquivo : string) : Boolean;
    procedure OnIniciarAtualizacaco;
    procedure AtualizarStatus;
    procedure OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure OnWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure OnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    function CalcularPercentual : Double;
    function CalcularParaKilobytes : Double;
//    procedure CancelarDownload;
  public
    constructor Create(AOwner: TComponent); override;

    property LocalDownloads : string read FLocalDownloads write FLocalDownloads;
    function Download(const ACaminho : string) : TlmxHttpRetornoArquivo;
    property OnStatus : TLmxHttpOnStatusDownloadEvent read FOnStatus write FOnStatus;
    property OnIniciarAtualizacao : TLmxHttpOnInitDownloadEvent read FOnIniciarAtualizacao write FOnIniciarAtualizacao;

    class function ObterArquivo(const ACaminho : string; const AOnStatus : TLmxHttpOnStatusDownloadEvent = nil) : TlmxHttpRetornoArquivo;
  end;


implementation

{ TlmxHttpDownload }

procedure TlmxHttpDownload.AtualizarStatus;
begin
  if Assigned(FOnStatus) then
    FOnStatus(FMaximo, FAtual, CalcularPercentual, CalcularParaKilobytes);
end;

function TlmxHttpDownload.CalcularParaKilobytes: Double;
begin
  Result := ((FAtual / 1024) / 1024);
end;

function TlmxHttpDownload.CalcularPercentual : Double;
begin
  Result := 0;
  if FMaximo > 0 then
    Result := ((FAtual * 100) / FMaximo);
end;

//procedure TlmxHttpDownload.CancelarDownload;
//begin
//  FIdHttp.Disconnect;
//end;

constructor TlmxHttpDownload.Create(AOwner: TComponent);
begin
  inherited;
  FLocalDownloads := TPath.GetTempPath;
  FIdHttp := TIdHttp.Create(Self);
  FIdHttp.AllowCookies := True;
  FIdHttp.OnWorkBegin := OnWorkBegin;
  FIdHttp.OnWork := OnWork;
  FIdHttp.OnWorkEnd := OnWorkEnd;
  FIdAntifreeze := TIDAntiFreeze.Create(Self);
  FIdHttp.HTTPOptions := [hoForceEncodeParams];
  FIdHttp.ProxyParams.BasicAuthentication := False;
  FIdHttp.ProxyParams.ProxyPort := 0;
  FIdHttp.Request.ContentLength := -1;
  FIdHttp.Request.ContentRangeEnd := -1;
  FIdHttp.Request.ContentRangeStart := -1;
  FIdHttp.Request.ContentRangeInstanceLength := -1;
  FIdHttp.Request.Accept := 'text/html, */*';
  FIdHttp.Request.BasicAuthentication := False;
  FIdHttp.Request.UserAgent := 'Mozilla/3.0 (compatible; Indy Library)';
  FIdHttp.Request.Ranges.Units := 'bytes';
//  FIdHttp.Request.Ranges = <>

  FIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  FIOHandler.MaxLineAction := maException;
  FIOHandler.SSLOptions.Method := sslvTLSv1;
  FIOHandler.SSLOptions.Mode := sslmUnassigned;
  FIOHandler.SSLOptions.VerifyDepth := 0;
  FIOHandler.SSLOptions.VerifyMode := [];

  FCookieManager := TIdCookieManager.Create(Self);

  FIdHttp.IOHandler := FIOHandler;
  FIdHttp.CookieManager := FCookieManager;
end;

function TlmxHttpDownload.Download(
  const ACaminho: string): TlmxHttpRetornoArquivo;
var
  lArquivo : TFileStream;
  lNomeArquivo: string;
  lNomeArquivoSalvo: string;
begin
  try
    lNomeArquivo := TPath.GetTempFileName;
    lArquivo := TFileStream.Create(lNomeArquivo, fmCreate);
    try
      try
        Result := TlmxHttpRetornoArquivo.Create;
        FIdHttp.Get(ACaminho, lArquivo);
      except
        begin
          FreeAndNil(Result);
          raise;
        end;
      end;
    finally
      FreeAndNil(lArquivo);
    end;
    if Result <> nil then
    begin
      lNomeArquivoSalvo := GetNomeArquivo(ACaminho);
      if SalvarArquivo(lNomeArquivo, lNomeArquivoSalvo) then
        Result.NomeArquivo := lNomeArquivoSalvo;
    end;
  finally
    TFile.Delete(lNomeArquivo);
  end;
end;

function TlmxHttpDownload.GetNomeArquivo(
  const ACaminhoDownload: string): string;
var
  lPosicao: Integer;
  lLocalDownloads: string;
begin
  lLocalDownloads := FLocalDownloads;
  if lLocalDownloads = '' then
    lLocalDownloads :=  TDirectory.GetCurrentDirectory;
  lLocalDownloads := IncludeTrailingPathDelimiter(lLocalDownloads);
  lPosicao := LastDelimiter('/', ACaminhoDownload);
  Result := Copy(ACaminhoDownload, lPosicao + 1, MaxInt);
  Result := lLocalDownloads + Result;
end;

class function TlmxHttpDownload.ObterArquivo(
  const ACaminho: string; const AOnStatus : TLmxHttpOnStatusDownloadEvent): TlmxHttpRetornoArquivo;
var
  lHttpDownload: TlmxHttpDownload;
begin
  lHttpDownload := Self.Create(nil);
  try
    lHttpDownload.OnStatus := AOnStatus;
    Result := lHttpDownload.Download(ACaminho);
  finally
    FreeAndNil(lHttpDownload);
  end;
end;

procedure TlmxHttpDownload.OnIniciarAtualizacaco;
begin
  if Assigned(FOnIniciarAtualizacao) then
    FOnIniciarAtualizacao(FMaximo);
end;

procedure TlmxHttpDownload.OnWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  FAtual := AWorkCount;
  AtualizarStatus;
end;

procedure TlmxHttpDownload.OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  FMaximo := AWorkCountMax;
  OnIniciarAtualizacaco;
  AtualizarStatus;
end;

procedure TlmxHttpDownload.OnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  FAtual := 0;
  FMaximo := 0;
  AtualizarStatus;
end;

function TlmxHttpDownload.SalvarArquivo(const AArquivoTmp, ANomeArquivo : string) : Boolean;
begin
  TFile.Copy(AArquivoTmp, ANomeArquivo, True);
  Result := True;
end;

end.
