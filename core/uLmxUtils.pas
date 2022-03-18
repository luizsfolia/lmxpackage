unit uLmxUtils;

interface

uses
  SysUtils, {$IFDEF MSWINDOWS}{CAPICOM_TLB,} System.Win.Registry, Winapi.Windows,{$ENDIF} XMLIntf, RTTI, XMLDoc, IOUtils, TypInfo, Classes, uLmxInterfaces,
  Generics.Collections{$IFDEF NOGUI},uLmxBaseViewNoGui{$ELSE},
  {$IFDEF HAS_FMX}
  uLmx.Fmx.View.Base
  {$ELSE}
  uLmxBaseView
  {$ENDIF}
  {$ENDIF}, uLmxValidate, DateUtils;

type

  TLmxTextUtils = class
  private
    FQuantidadeColunasImpressora: Integer;
  public
    constructor Create;
    property QuantidadeColunasImpressora : Integer read FQuantidadeColunasImpressora;
    procedure RegistrarQuantidadeColunasImpressora(const AQuantidade : Integer);
  public
    function PreencherCom(const ATextoPreenchimento: char; const ATexto : string;
      const ATamanhoTotal: Integer): string; overload;
    function PreencherCom(const ATextoPreenchimento: char; const ANumero,
      ATamanhoTotal: Integer): string; overload;
    function PreencherComZeros(const ANumero, ATamanhoTotal: Integer): string;

    function SomenteXDigitos(const ATexto: string; const ATamanho : Integer): string;

    function TextoAlinhadoEsquerda(const ATexto: string; const ATotalColunas : Integer = 48): string;
    function TextoCentralizado(const ATexto: string; const ATotalColunas : Integer = 48): string;
    function NovaLinhaValor(const ADescricao: string; const AValor: string; const ATotalColunas : Integer = 48) : string; overload;
    function NovaLinhaValor(const ADescricao: string; const AValor: Double; const ATotalColunas : Integer = 48) : string; overload;
    function NovaLinhaValor(const ADescricao: string; const AValor: Integer; const ATotalColunas : Integer = 48) : string; overload;
    function NovaLinhaValor(const ADescricao: string; const AValor: TDateTime; const ATotalColunas : Integer = 48) : string; overload;
  end;

  TLmxSystemUtils = class
  public
    function CarregarBibliotecaDinamica(const ANomeBiblioteca : string; var AHandle : Cardinal) : Boolean;
    function DescarregarBibliotecaDinamica(var AHandle : Cardinal) : Boolean;
    procedure CarregarListaPortasDisponiveis(const ALista : TStrings);
  end;

  TLmxRegisterDictionary = class(TDictionary<TGUID, {$IFDEF HAS_FMX}TLmxFmxViewBaseClass{$ELSE} TLmxBaseViewClass{$ENDIF}>);

  TLmxInterfacesUtils = class
  private
    FPDVClasses : TLmxRegisterDictionary;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterInterface(const AInterface : TGUID; const AView : {$IFDEF HAS_FMX}TLmxFmxViewBaseClass{$ELSE} TLmxBaseViewClass{$ENDIF});
    function New(const AInterface : TGUID; const AOwner : TComponent = nil) : ILmxBaseView;
    function Exists(const AInterface : TGUID) : Boolean;
  end;

  TLmxPrinterUtils = class
  public
    function ConvertStringToDate(const AStringDate : string) : TDateTime;
  end;

  TLmxDadosCertificado = class
  private
    FValidoAte: TDateTime;
    FValidoAPartirDe: TDateTime;
    FDados: string;
    FValoresCertificado: TStringList;

    function ObterValor(const ANome : string) : string;
    procedure SetDados(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    property Dados : string read FDados write SetDados;
    property ValidoAte : TDateTime read FValidoAte write FValidoAte;
    property ValidoAPartirDe : TDateTime read FValidoAPartirDe write FValidoAPartirDe;

    function Cnpj : string;
    function Nome : string;
    function UF : string;
  end;

  TLmxCetificadoUtils = class
  public
    {$IFDEF MSWINDOWS}
    function SelecionarCertificado : string;
    function ValidarCertificado(const ANumeroSerie : string; const ACnpj : string;
      out AValidacoes : string) : Boolean;
    function ObterDadosCertificado(const ANumeroSerie : string; out ADadosCertificado : TLmxDadosCertificado) : Boolean;
    {$ENDIF}
  end;

  TLmxLogUtils = class
  public
    procedure NovoLog(const ALog : string; const AArquivo : string = ''; const AIncluirDataHora : Boolean = True);
  end;

  TLmxValidadorUtils = class
  public
    function CPFValido(const ACPF : string) : Boolean;
    function CNPJValido(const ACnpj : string) : Boolean;
  end;

  TLmxFinanceiroUtils = class
  public
    function CalcularJuros(const AValorBase : Double; const APercentualJuros : Double;
      const ADataReferencia : TDateTime; const ADiasSemJuros : Integer) : Double;
  end;

  TLmxArquivos = class
  public
    function CaminhoBase : string;
    function ArquivoExiste(const ANomeArquivo : string) : Boolean;
    function CaminhoCompletoArquivo(const ANomeArquivo : string) : string;
  end;

  TLmxUtils = class
  private
    FPDVTextUtils: TLmxTextUtils;
    FPDVSystemUtils: TLmxSystemUtils;
    FPDVInterfacesUtils: TLmxInterfacesUtils;
    FPrinterUtils: TLmxPrinterUtils;
    FCetificadoUtils: TLmxCetificadoUtils;
    FLogUtils: TLmxLogUtils;
    FValidadorUtils : TLmxValidadorUtils;
    FFinanceiroUtils: TLmxFinanceiroUtils;
    FArquivos: TLmxArquivos;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property TextUtils : TLmxTextUtils read FPDVTextUtils;
    property SystemUtils : TLmxSystemUtils read FPDVSystemUtils;
    property InterfaceUtils : TLmxInterfacesUtils read FPDVInterfacesUtils;
    property PrinterUtils : TLmxPrinterUtils read FPrinterUtils;
    property CertificadoUtils : TLmxCetificadoUtils read FCetificadoUtils;
    property LogUtils : TLmxLogUtils read FLogUtils;
    property ValidadorUtils : TLmxValidadorUtils read FValidadorUtils;
    property FinanceiroUtils : TLmxFinanceiroUtils read FFinanceiroUtils;
    property Arquivos : TLmxArquivos read FArquivos;
  end;

function LmxUtils: TLmxUtils;

implementation

var
  FLmxUtils: TLmxUtils;

function LmxUtils: TLmxUtils;
begin
  Result := FLmxUtils;
end;


{ TLmxUtils }

constructor TLmxUtils.Create;
begin
  FPDVTextUtils := TLmxTextUtils.Create;
  FPDVSystemUtils := TLmxSystemUtils.Create;
  FPDVInterfacesUtils := TLmxInterfacesUtils.Create;
  FPrinterUtils := TLmxPrinterUtils.Create;
  FCetificadoUtils := TLmxCetificadoUtils.Create;
  FLogUtils := TLmxLogUtils.Create;
  FValidadorUtils := TLmxValidadorUtils.Create;
  FFinanceiroUtils := TLmxFinanceiroUtils.Create;
  FArquivos := TLmxArquivos.Create;
end;

destructor TLmxUtils.Destroy;
begin
  FreeAndNil(FArquivos);
  FreeAndNil(FFinanceiroUtils);
  FreeAndNil(FValidadorUtils);
  FreeAndNil(FLogUtils);
  FreeAndNil(FCetificadoUtils);
  FreeAndNil(FPrinterUtils);
  FreeAndNil(FPDVInterfacesUtils);
  FreeAndNil(FPDVSystemUtils);
  FreeAndNil(FPDVTextUtils);
  inherited;
end;

{ TLmxTextUtils }

function TLmxTextUtils.NovaLinhaValor(const ADescricao, AValor: string; const ATotalColunas : Integer): string;
var
  lTamanhoDescricao: Integer;
  lTamanhoValor: Integer;
  lDiferencaTamanho: Integer;
  I: Integer;
  lTexto: string;
  lDescricao: string;
  lValor: string;
  lTotalColunas: Integer;
begin
  lTamanhoValor := Length(AValor);
  lTamanhoDescricao := Length(ADescricao);
  lTotalColunas := ATotalColunas -1;
  if lTamanhoValor > lTamanhoDescricao then
  begin
    lDescricao := ADescricao;
    lValor     := Copy(AValor, 1, (lTotalColunas - (lTamanhoDescricao + 1)));
  end else begin
    lDescricao := Copy(ADescricao, 1, (lTotalColunas - (lTamanhoValor + 1)));
    lValor     := AValor;
  end;
  lTamanhoDescricao := Length(lDescricao);
  lTamanhoValor     := Length(lValor);
  lDiferencaTamanho := lTotalColunas - lTamanhoDescricao - lTamanhoValor;
  lTexto := '';
  for I := 1 to lDiferencaTamanho do
    lTexto := lTexto + ' ';
  lTexto := lDescricao + lTexto + lValor;
  Result := lTexto;
end;

function TLmxTextUtils.NovaLinhaValor(const ADescricao: string; const AValor: Double; const ATotalColunas : Integer): string;
begin
  Result := NovaLinhaValor(ADescricao, FormatFloat('.,00', AValor), ATotalColunas);
end;

function TLmxTextUtils.NovaLinhaValor(const ADescricao: string; const AValor: Integer; const ATotalColunas : Integer): string;
begin
  Result := NovaLinhaValor(ADescricao, IntToStr(AValor), ATotalColunas);
end;

constructor TLmxTextUtils.Create;
begin
  FQuantidadeColunasImpressora := 48;
end;

function TLmxTextUtils.NovaLinhaValor(const ADescricao: string; const AValor: TDateTime; const ATotalColunas : Integer): string;
begin
  Result := NovaLinhaValor(ADescricao, FormatDateTime('dd.mm.yyyy', AValor), ATotalColunas);
end;

function TLmxTextUtils.PreencherCom(const ATextoPreenchimento: char;
  const ATexto: string; const ATamanhoTotal: Integer): string;
var
  I: Integer;
  lDiferenca: Integer;
begin
  lDiferenca := ATamanhoTotal - Length(ATexto);
  Result := '';
  for I := 1 to lDiferenca do
    Result := Result + ATextoPreenchimento;
  Result := Result + ATexto;
end;

function TLmxTextUtils.PreencherCom(const ATextoPreenchimento: char;
  const ANumero, ATamanhoTotal: Integer): string;
begin
  Result := PreencherCom(ATextoPreenchimento, IntToStr(ANumero), ATamanhoTotal);
end;

function TLmxTextUtils.PreencherComZeros(const ANumero,
  ATamanhoTotal: Integer): string;
begin
  Result := PreencherCom('0', ANumero, ATamanhoTotal);
end;

procedure TLmxTextUtils.RegistrarQuantidadeColunasImpressora(const AQuantidade: Integer);
begin
  FQuantidadeColunasImpressora := AQuantidade;
end;

function TLmxTextUtils.SomenteXDigitos(const ATexto: string;
  const ATamanho: Integer): string;
begin
  Result := Copy(ATexto, 1, ATamanho);
end;

function TLmxTextUtils.TextoAlinhadoEsquerda(const ATexto: string; const ATotalColunas : Integer): string;
var
  I: Integer;
  lTexto: string;
  lDiferenca: Integer;
  lIndex: Integer;
  lEspacosInicio: string;
  lChar : string;
  lTotalColunas: Integer;
begin
  lTotalColunas := ATotalColunas;
  lIndex := 1;
  lEspacosInicio := '';
  lChar := Copy(ATexto, lIndex, 1);
  while (lChar = ' ') or (lChar = #10) or (lChar = #13) do
  begin
    lChar := Copy(ATexto, lIndex, 1);
    if (lChar = ' ') then
      lEspacosInicio := lEspacosInicio + ' ';
    Inc(lIndex);
  end;

  lTexto := lEspacosInicio + Copy(Trim(ATexto), 1, Length(ATexto));
  lDiferenca := lTotalColunas - Length(lTexto);
  Result := '';
  for I := 1 to lDiferenca do
    Result := Result + ' ';
  Result := lTexto + Result;
end;

function TLmxTextUtils.TextoCentralizado(const ATexto: string; const ATotalColunas : Integer): string;
var
  I: Integer;
  lTexto: string;
  lDiferenca: Integer;
  lMeioDiferenca: Integer;
  lTotalColunas: Integer;
begin
  lTotalColunas := ATotalColunas - 1;
  lTexto := Copy(Trim(ATexto), 1, Length(ATexto));
  lDiferenca := lTotalColunas - Length(lTexto);
  lMeioDiferenca := Trunc(lDiferenca / 2);
  Result := '';
  for I := 1 to lMeioDiferenca do
    Result := Result + ' ';
  Result := Result + lTexto;
  for I := 1 to (lDiferenca - lMeioDiferenca) do
    Result := Result + ' ';
end;

{ TLmxSystemUtils }
function TLmxSystemUtils.CarregarBibliotecaDinamica(
  const ANomeBiblioteca: string; var AHandle: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  lFolder: string;
  ph: PChar;
{$ENDIF}
begin
  Result := False;
{$IFDEF MSWINDOWS}
  lFolder := '.\lib\';
  if TFile.Exists(lFolder + ANomeBiblioteca) then
  begin
    AHandle := SafeLoadLibrary(lFolder + ANomeBiblioteca);
    Result := (AHandle > 0);
  end else begin
    GetMem(ph, 255);
    GetSystemDirectory(ph, 254);
    lFolder := Strpas(ph);
    Freemem(ph);
    if TFile.Exists(lFolder + '\' + ANomeBiblioteca) then
    begin
      AHandle := SafeLoadLibrary(ANomeBiblioteca);
      Result := (AHandle > 0);
    end;
  end;
{$ENDIF}
end;

procedure TLmxSystemUtils.CarregarListaPortasDisponiveis(
  const ALista: TStrings);
{$IFDEF MSWINDOWS}
var
  Registro: TRegistry;  //Para trabalhar com os Registros do windows.
  Lista: Tstrings;
  indice: Integer;      //Para incrementar.
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ALista.Clear;
  Registro := TRegistry.Create; //Cria e aloca espaço na memória para o objeto.
  try
    Registro.RootKey := HKEY_LOCAL_MACHINE;  //Define chave raiz.
    Registro.OpenKey('hardware\devicemap\serialcomm', False); //Abre a chave.
    Lista := TstringList.Create;
    try
      //Obtém uma string contendo todos os nomes de valores associados com a chave atual.
      Registro.GetValueNames(Lista);
      //Pega nos nomes das portas.
      for indice := 0 to Lista.Count - 1 do //Count é a quantidade de portas existentes.
        ALista.Add(Registro.ReadString( Lista.Strings[indice] ));
    finally
      Lista.Free;
    end;
    Registro.CloseKey;

    ALista.Add('USB');

  finally
    Registro.Free;
  end;
{$ENDIF}
end;

function TLmxSystemUtils.DescarregarBibliotecaDinamica(var AHandle: Cardinal): Boolean;
begin
{$IFDEF MSWINDOWS}
  if AHandle > 0 then
  begin
    FreeLibrary(AHandle);
    AHandle := 0;
  end;
  Result := (AHandle = 0);
{$ENDIF}
end;

{ TLmxInterfacesUtils }

constructor TLmxInterfacesUtils.Create;
begin
  FPDVClasses := TLmxRegisterDictionary.Create;
end;

destructor TLmxInterfacesUtils.Destroy;
begin
  FreeAndNil(FPDVClasses);
  inherited;
end;

function TLmxInterfacesUtils.Exists(const AInterface: TGUID): Boolean;
var
  lClasse: {$IFDEF HAS_FMX}TLmxFmxViewBaseClass{$ELSE} TLmxBaseViewClass{$ENDIF};
begin
  Result := FPDVClasses.TryGetValue(AInterface, lClasse) and Supports(lClasse, AInterface);
end;

procedure TLmxInterfacesUtils.RegisterInterface(const AInterface: TGUID;
  const AView: {$IFDEF HAS_FMX}TLmxFmxViewBaseClass{$ELSE} TLmxBaseViewClass{$ENDIF});
begin
  FPDVClasses.Add(AInterface, AView);
end;

function TLmxInterfacesUtils.New(const AInterface: TGUID;
  const AOwner: TComponent): ILmxBaseView;
var
  lClasse: {$IFDEF HAS_FMX}TLmxFmxViewBaseClass{$ELSE} TLmxBaseViewClass{$ENDIF};
begin
  Result := nil;
  if FPDVClasses.TryGetValue(AInterface, lClasse) then
  begin
    if Supports(lClasse, AInterface) then
      Result := lClasse.Create(AOwner) as ILmxBaseView;
  end;
end;

{ TLmxPrinterUtils }

function TLmxPrinterUtils.ConvertStringToDate(
  const AStringDate: string): TDateTime;
var
  lDataTemporaria: string;
begin
  Result := Now;

  lDataTemporaria := AStringDate;

  if Length(lDataTemporaria) = 6 then
    lDataTemporaria := lDataTemporaria + '000000';

  if Length(lDataTemporaria) = 12 then
    Insert('20', lDataTemporaria, 5);

  if (Length(Trim(lDataTemporaria)) = 14) then
  begin
    lDataTemporaria := Copy(lDataTemporaria, 1, 2) + '/' +
      Copy(lDataTemporaria, 3, 2) + '/' +
      Copy(lDataTemporaria, 5, 4) + ' ' +
      Copy(lDataTemporaria, 9, 2) + ':' +
      Copy(lDataTemporaria, 11, 2) + ':' +
      Copy(lDataTemporaria, 13, 2);

    TryStrToDateTime(lDataTemporaria, result);
  end;
end;

{ TLmxCetificadoUtils }

{$IFDEF MSWINDOWS}
function TLmxCetificadoUtils.ObterDadosCertificado(const ANumeroSerie: string;
  out ADadosCertificado: TLmxDadosCertificado): Boolean;
{var
  Store : IStore3;
  CertsLista : ICertificates2;
  CertDados : ICertificate;
  i: Integer;     }
begin
  Result := False;
{  if ANumeroSerie <> '' then
  begin
    Store := CoStore.Create;
    Store.Open(CAPICOM_CURRENT_USER_STORE, 'My', CAPICOM_STORE_OPEN_READ_ONLY);
    try
      CertsLista := Store.Certificates as ICertificates2;
      for i := 1 to CertsLista.Count do
      begin
        CertDados := IInterface(CertsLista.Item[I]) as ICertificate2;
        if CertDados.SerialNumber = ANumeroSerie then
        begin
          ADadosCertificado := TLmxDadosCertificado.Create;
          ADadosCertificado.ValidoAte := CertDados.ValidToDate;
          ADadosCertificado.ValidoAPartirDe := CertDados.ValidFromDate;
          ADadosCertificado.Dados := CertDados.SubjectName;
          Result := True;
        end;
      end;
    finally
      Store.Close;
    end;
  end; }
end;

function TLmxCetificadoUtils.SelecionarCertificado : string;
{var
  Store : IStore3;
  CertsLista, CertsSelecionado : ICertificates2;
  CertDados : ICertificate;  }
begin
{  Result := '';
  Store := CoStore.Create;
  Store.Open(CAPICOM_CURRENT_USER_STORE, 'My', CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED);
  try
    CertsLista := Store.Certificates as ICertificates2;
    CertsSelecionado := CertsLista.Select('Certificado(s) Digital(is) disponível(is)', 'Selecione o Certificado Digital para uso no aplicativo', false);
    if not(CertsSelecionado.Count = 0) then
    begin
      CertDados := IInterface(CertsSelecionado.Item[1]) as ICertificate2;
      Result := CertDados.SerialNumber;
    end;
  finally
    Store.Close;
  end;    }
end;

function TLmxCetificadoUtils.ValidarCertificado( const ANumeroSerie : string;
  const ACnpj : string; out AValidacoes: string): Boolean;
var
  lDadosCertificado: TLmxDadosCertificado;

  procedure AddValidacao(const AValidacao : string);
  begin
    if AValidacoes <> '' then
      AValidacoes := AValidacoes + sLineBreak;
    AValidacoes := AValidacoes + AValidacao;
    Result := False;
  end;

begin
  Result := True;
  AValidacoes := '';
  if ObterDadosCertificado(ANumeroSerie, lDadosCertificado) then
  begin
    try
      if lDadosCertificado.ValidoAte < Now then
        AddValidacao('Certificado Expirado em ' + DateToStr(lDadosCertificado.ValidoAte));
      if lDadosCertificado.ValidoAPartirDe > Now then
        AddValidacao('Certificado não liberado. aguardar até ' + DateToStr(lDadosCertificado.ValidoAPartirDe));
      if ACnpj <> lDadosCertificado.Cnpj then
        AddValidacao('Certificado pertencente a outra empresa / pessoa' + sLineBreak +
          'Cnpj Certificado : ' + lDadosCertificado.Cnpj + sLineBreak +
          'Cnpj Cnsfigurações : ' + ACnpj);
    finally
      FreeAndNil(lDadosCertificado);
    end;
  end;
end;
{$ENDIF}

{ TLmxLogUtils }

procedure TLmxLogUtils.NovoLog(const ALog, AArquivo: string;
  const AIncluirDataHora: Boolean);
var
  llog: string;
  lDiretorio: string;
  lArquivo: string;
begin
  llog := ALog;
  lArquivo := AArquivo;
  if llog <> '' then
  begin
    if AIncluirDataHora then
      llog := FormatDateTime('dd.mm.yyyy hh:nn:ss - ', Now) + llog;
    if lArquivo = '' then
    begin
      lDiretorio := TDirectory.GetCurrentDirectory + '\Logs\';
      if not TDirectory.Exists(lDiretorio) then
        TDirectory.CreateDirectory(lDiretorio);
      lArquivo := lDiretorio + TPath.GetFileNameWithoutExtension(ParamStr(0)) + '.log';
    end;
    TFile.AppendAllText(lArquivo, lLog + sLineBreak, TEncoding.Unicode);
  end;
end;

{ TLmxDadosCertificado }

function TLmxDadosCertificado.Cnpj: string;
var
  lPosicaoCnpj: Integer;
begin
  Result := ObterValor('CN');
  lPosicaoCnpj := Pos(':', Result);
  if lPosicaoCnpj > 0 then
    Result := Copy(Result, lPosicaoCnpj + 1, Length(Result));
end;

constructor TLmxDadosCertificado.Create;
begin
  FValoresCertificado := TStringList.Create;
end;

destructor TLmxDadosCertificado.Destroy;
begin
  FreeAndNil(FValoresCertificado);
  inherited;
end;

function TLmxDadosCertificado.Nome: string;
begin
  Result := ObterValor('NOME');
end;

function TLmxDadosCertificado.ObterValor(const ANome: string): string;
begin
  Result := FValoresCertificado.Values[ANome];
end;

procedure TLmxDadosCertificado.SetDados(const Value: string);
begin
  FDados := Value;
  FValoresCertificado.Delimiter := ',';
  FValoresCertificado.LineBreak := ',';
  FValoresCertificado.Text := Value;
end;

function TLmxDadosCertificado.UF: string;
begin
  Result := ObterValor('UF');
end;

{ TLmxValidadorUtils }

function TLmxValidadorUtils.CNPJValido(const ACnpj: string): Boolean;
begin
  Result := uLmxValidate.TLmxCheckCNPJ.Execute(ACnpj);
end;

function TLmxValidadorUtils.CPFValido(const ACPF: string): Boolean;
begin
  Result := uLmxValidate.TLmxCheckCPF.Execute(ACPF);
end;

{ TLmxFinaceiroUtils }

function TLmxFinanceiroUtils.CalcularJuros(const AValorBase,
  APercentualJuros: Double; const ADataReferencia : TDateTime; const ADiasSemJuros: Integer): Double;
var
  lJurosDia: Double;
  lTotalDias: Integer;
begin
  Result := 0;
  if (Now > (ADataReferencia + ADiasSemJuros)) then
  begin
    lJurosDia := (APercentualJuros / 30);
    lTotalDias := DaysBetween(Now, ADataReferencia) - ADiasSemJuros;
    if lTotalDias > 0 then
      Result := ((lTotalDias * lJurosDia) * AValorBase) / 100;
  end;
end;

{ TLmxArquivos }

function TLmxArquivos.ArquivoExiste(const ANomeArquivo: string): Boolean;
begin
  Result := TFile.Exists(CaminhoCompletoArquivo(ANomeArquivo));
end;

function TLmxArquivos.CaminhoBase: string;
begin
  Result := TDirectory.GetCurrentDirectory + '\Arquivos\';
end;

function TLmxArquivos.CaminhoCompletoArquivo(
  const ANomeArquivo: string): string;
begin
  Result := CaminhoBase + ANomeArquivo;
end;

initialization
  FLmxUtils := TLmxUtils.Create;

finalization

FreeAndNil(FLmxUtils);

end.
