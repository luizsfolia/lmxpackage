unit uLmxImpressora;

interface

uses
  SysUtils, Generics.Collections, uLmxExceptions, uLmxtypes, uLmxAttributes,
  uLmxHelper, uLmxControleImpressora, uLmxUtils, uLmxInterfacesPrinter, Classes
  {$IFDEF MSWINDOWS},Winapi.Windows{$ENDIF}; //IOUtils,

type

  TLmxImpressora = class;

  TLmxOnAlterarStatusImpressoraEvent = procedure(Sender : TLmxImpressora;
    const AStatusAnterior, ANovoStatus : TLmxStatusImpressora) of object;
  TLmxOnPrintExecute = procedure (Sender : TLmxImpressora; const ATipo : TTipoExecucaoImpressora;
    const ATexto : string) of object;

  [TLmxAttributeSerializable('DadosImpressoraEmpresaEmissao')]
  TLmxDadosImpressoraEmpresaEmissao = class
  private
    FCodigo: Integer;
    FNome: string;
    FCNPJ: string;
    FEndereco: string;
    FIE: string;
  public
    [TLmxAttributeSerializable('Codigo')]
    property Codigo : Integer read FCodigo write FCodigo;
    [TLmxAttributeSerializable('Nome')]
    property Nome : string read FNome write FNome;
    [TLmxAttributeSerializable('CNPJ')]
    property CNPJ : string read FCNPJ write FCNPJ;
    [TLmxAttributeSerializable('Endereco')]
    property Endereco : string read FEndereco write FEndereco;
    [TLmxAttributeSerializable('IE')]
    property IE : string read FIE write FIE;
  end;

  [TLmxAttributeSerializable('DadosImpressoraContadores')]
  TLmxDadosImpressoraContadores = class
  private
    FCOO: Integer;
    FCRZ: Integer;
    FGT: Double;
    FCCF: Integer;
    FUltimoCancelamento: Integer;
    FCOOUltimoCancelamento: Integer;
    FTotalUltimaVenda: Double;
  public
    [TLmxAttributeSerializable('CCF')]
    property CCF : Integer read FCCF write FCCF;
    [TLmxAttributeSerializable('COO')]
    property COO : Integer read FCOO write FCOO;
    [TLmxAttributeSerializable('CRZ')]
    property CRZ : Integer read FCRZ write FCRZ;
    [TLmxAttributeSerializable('GT')]
    property GT : Double read FGT write FGT;
    [TLmxAttributeSerializable('UltimoCancelamento')]
    property UltimoCancelamento : Integer read FUltimoCancelamento write FUltimoCancelamento;
    [TLmxAttributeSerializable('COOUltimoCancelamento')]
    property COOUltimoCancelamento : Integer read FCOOUltimoCancelamento write FCOOUltimoCancelamento;
    [TLmxAttributeSerializable('TotalUltimaVenda')]
    property TotalUltimaVenda : Double read FTotalUltimaVenda write FTotalUltimaVenda;
  end;

  [TLmxAttributeSerializable('DadosImpressoraIdentificacao')]
  TLmxDadosImpressoraIdentificacao = class
  private
    FNumeroSerie: string;
  public
    [TLmxAttributeSerializable('NumeroSerie')]
    property NumeroSerie : string read FNumeroSerie write FNumeroSerie;
  end;

  TLmxDadosReducaoZFormasPagamento = class(TObjectDictionary<string,Double>)
  public
    procedure AdicionarValor(const AFormaPagamento : string; const AValor : Double);
  end;

  [TLmxAttributeSerializable('DadosReducaoZ')]
  TLmxDadosVenda = class
  private
    FNumero: Integer;
    FSerie: string;
    FChaveAcesso: string;
    FDataEmissao: TDateTime;
  public
    [TLmxAttributeSerializable('Numero')]
    property Numero : Integer read FNumero write FNumero;
    [TLmxAttributeSerializable('Serie')]
    property Serie : string read FSerie write FSerie;
    [TLmxAttributeSerializable('DataEmissao')]
    property DataEmissao : TDateTime read FDataEmissao write FDataEmissao;
    [TLmxAttributeSerializable('ChaveAcesso')]
    property ChaveAcesso : string read FChaveAcesso write FChaveAcesso;
  end;

  [TLmxAttributeSerializable('DadosReducaoZ')]
  TLmxDadosReducaoZ = class
  private
    FDataMovimento: TDateTime;
    FPrimeiroCOO: Integer;
//    FFormasPagamento: TLmxDadosReducaoZFormasPagamento;
    FTotalVendas: Double;
    FNumero: Integer;
    FCRO: Integer;
    FGTFinal: Double;
    FDataReducao: TDateTime;
//    function GetTotaisFormasPagamento: string;
  public
    [TLmxAttributeSerializable('Numero')]
    property Numero: Integer read FNumero write FNumero;
    [TLmxAttributeSerializable('DataReducao')]
    property DataReducao: TDateTime read FDataReducao write FDataReducao;
    [TLmxAttributeSerializable('DataMovimento')]
    property DataMovimento: TDateTime read FDataMovimento write FDataMovimento;
    [TLmxAttributeSerializable('PrimeiroCOO')]
    property PrimeiroCOO : Integer read FPrimeiroCOO write FPrimeiroCOO;
    [TLmxAttributeSerializable('TotalVendas')]
    property TotalVendas : Double read FTotalVendas write FTotalVendas;
    [TLmxAttributeSerializable('CRO')]
    property CRO : Integer read FCRO write FCRO;
    [TLmxAttributeSerializable('GTFinal')]
    property GTFinal : Double read FGTFinal write FGTFinal;
//    [TLmxAttributeSerializable('TotaisFormasPagamento')]
//    property TotaisFormasPagamento : string read GetTotaisFormasPagamento;

//    property FormasPagamento : TLmxDadosReducaoZFormasPagamento read FFormasPagamento;
  end;

  [TLmxAttributeSerializable('DadosImpressora')]
  TLmxDadosImpressora = class
  private
    FEmpresaEmissao : TLmxDadosImpressoraEmpresaEmissao;
    FContadores: TLmxDadosImpressoraContadores;
    FIdentificacao: TLmxDadosImpressoraIdentificacao;
    FUltimaReducaoZ: TLmxDadosReducaoZ;
    FUltimaVenda: TLmxDadosVenda;

    function GetNomeDocumentoDadosImpressora : string;
  public
    constructor Create;
    destructor Destroy; override;

    property EmpresaEmissao : TLmxDadosImpressoraEmpresaEmissao read FEmpresaEmissao;
    property Contadores     : TLmxDadosImpressoraContadores read FContadores;
    property Identificacao  : TLmxDadosImpressoraIdentificacao read FIdentificacao;
    property UltimaReducaoZ : TLmxDadosReducaoZ read FUltimaReducaoZ;
    property UltimaVenda    : TLmxDadosVenda read FUltimaVenda;

    procedure Salvar;
    procedure Carregar;
  end;

  TLmxImpressora = class(TInterfacedPersistent, ILmxInterfacesPrinter)
  private
    FDLLHandle : Cardinal;
    FOnAlterarStatusImpressoraEvent : TLmxOnAlterarStatusImpressoraEvent;
    FOnPrintExecuteEvent : TLmxOnPrintExecute;
    FStatusImpressora : TLmxStatusImpressora;
    FDadosImpressora : TLmxDadosImpressora;
    FConfiguracoesImpressora : TLmxControleImpressora;
    FModoTeste: Boolean;
    procedure SetConfiguracoesImpressora(const Value: TLmxControleImpressora);
  protected
    function GetHandle : Cardinal;
    function GetDllCarregada : Boolean; virtual;
    function GetNomeDll : string; virtual;
    function GetProcedimento(const Nome: string): Pointer; virtual;
    function CarregarDLL : Boolean; virtual;
    function DescarregarDLL : Boolean; virtual;
    procedure DoCarregarMetodos; virtual;

    function GetRetornosInErro : TLmxRetornosImpressora; virtual;
    function GetQuantidadeColunas : Integer; virtual;
    function DoLog(const ALog : string) : Boolean; virtual;
    function DoAlterarStatusImpressora(const AStatus : TLmxStatusImpressora) : Boolean; virtual;
    function DoValidarStatusImpressora(const ARetornoInpressora : TLmxRetornoImpressora; const AStatusImpressora : TLmxStatusImpressora) : Boolean; virtual;
    function DoInicializarImpressora : Boolean; virtual; abstract;
    function DoFinalizarImpressora: Boolean; virtual; abstract;
    function DoIniciarVenda(const ACPF : string) : Boolean; virtual; abstract;
    function DoVenderItem(const ASequencia, ACodigo : Integer; const ANomeProduto : string;
      const AValorUnitario : Double; const AUnidade : string; const ATipoAliquota : string; const AQuantidade : Double;
      const ADesconto : Double) : Boolean; virtual; abstract;
    function DoConcluirVenda(const AFormaPagamento: TLmxTipoFormaPagamento;
      const AValorDesconto, AValorAcrescimo, AValorTotalVenda, AValorPago: Double;
      const AMensagem : string) : Boolean; virtual; abstract;
    function DoAdicionarPagamento(const AFormaPagamento: TLmxTipoFormaPagamento;
      const AValorPago: Double) : Boolean; virtual; abstract;
    function DoDadosConsumidor(const AIdentificador, ANome, AEnderecoCompleto : string) : Boolean; virtual; abstract;
    function DoValorTributos(const AValorTributosFederais, AValorTributosEstaduais, AValorTributosMunicipais : Double) : Boolean; virtual; abstract;
    function DoDadosVendaEletronica(const ANumero, ASerie, AEnderecoChave, AChaveAcesso : string; const ADataEmissao : TDateTime) : Boolean; virtual; abstract;
    function DoDadosAutorizacaoEletronica(const AQRCode, AProtocolo : string; const ADataProtocolo : TDateTime;
      const AFormaEmissao : TNotaFormaEmissao; const AAmbiente : TNotaAmbiente) : Boolean; virtual; abstract;
    function DoEmitirRelatorioGerencial(const ARelatorio : string) : Boolean; virtual; abstract;
    function DoFecharRelatorioGerencial : Boolean; virtual; abstract;
    function DoAcrescimoItem(const AITem : Integer; const AAcrescimo : Double) : Boolean; virtual; abstract;
    function DoDescontoItem(const AITem : Integer; const ADesconto : Double) : Boolean; virtual; abstract;
    function DoCancelarItem(const AITem : Integer) : Boolean; virtual; abstract;
    function DoGetNumeroCupomAtual : Integer; virtual; abstract;
    function DoCancelarVenda : Boolean; virtual; abstract;
    function DoCancelarUltimoDocumento : Boolean; virtual; abstract;
    function DoCancelarVendaEspecifica(const ANumero : Integer): Boolean; virtual; abstract;
    function DoRetornoImpressora : TLmxRetornosImpressora; virtual; abstract;
    function DoEmitirReducaoZ : Boolean; virtual; abstract;
    function DoEmitirLeituraX : Boolean; virtual; abstract;
    function DoImpressoraLigada : Boolean; virtual; abstract;
    function DoGetAliquotasImpressora : Boolean; virtual; abstract;
    function DoCarregarDadosImpressora : Boolean; virtual; abstract;
    function DoCarregarDadosUltimaReducaoZ(out ADadosReducaoZ : TLmxDadosReducaoZ) : Boolean; virtual; abstract;
    function DoCortarPapel : Boolean; virtual; abstract;
    function DoEmitirQRCode(const AValorQrCode : string) : Boolean; virtual; abstract;
    function DoEmitirCodigoBarras(const AValorCodigoBarras : string; const ATipoImpressaoCodigoBarras : TLmxTipoImpressaoCodigoBarras) : Boolean; virtual; abstract;
    function DoAutenticar(const AAutenticacao : string) : Boolean; virtual;
    function DoMensagensSistema(const AMensagens : string) : Boolean; virtual; abstract;
    function DoAutoTeste : Boolean; virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property DadosImpressora : TLmxDadosImpressora read FDadosImpressora;
    property QuantidadeColunas : Integer read GetQuantidadeColunas;
    function CarregarDadosImpressora : Boolean; virtual;
    function CarregarDadosUltimaReducaoZ(out ADadosReducaoZ : TLmxDadosReducaoZ) : Boolean; virtual;
    function InicializarImpressora : Boolean; virtual;
    function FinalizarImpressora : Boolean; virtual;
    function IniciarVenda(const ACPF : string; out ACupomIniciado : Integer) : Boolean; virtual;
    function VenderItem(const ASequencia, ACodigo : Integer; const ANomeProduto : string;
      const AValorUnitario : Double; const AUnidade : string; const ATipoAliquota : string; const AQuantidade : Double;
      const ADesconto : Double) : Boolean; virtual;
    function ConcluirVenda(const AFormaPagamento: TLmxTipoFormaPagamento;
      const AValorDesconto, AValorAcrescimo, AValorTotalVenda, AValorPago: Double;
      const AMensagem : string) : Boolean; virtual;
    function MensagensSistema(const AMensagens : string) : Boolean; virtual;
    procedure AdicionarPagamento(const AFormaPagamento: TLmxTipoFormaPagamento;
      const AValorPago: Double); virtual;
    function DescontoItem(const AITem : Integer; const ADesconto : Double) : Boolean;
    function AcrescimoItem(const AITem : Integer; const AAcrescimo : Double) : Boolean;
    function EmitirRelatorioGerencial(const ARelatorio : string;
      const AFecharAoConcluir : Boolean = True) : Boolean; virtual;
    function CancelarItem(const AITem : Integer) : Boolean; virtual;
    function GetNumeroCupomAtual : Integer; virtual;
    function StatusImpressora : TLmxStatusImpressora; virtual;
    function CancelarVenda : Boolean; virtual;
    function CancelarUltimoDocumento : Boolean; virtual;
    function CancelarVendaEspecifica(const ANumero : Integer) : Boolean; virtual;
    function RetornosImpressora : TLmxRetornosImpressora; virtual;
    function EmitirReducaoZ : Boolean; virtual;
    function EmitirLeituraX : Boolean; virtual;
    function RetornoImpressoraToString(const ARetorno : TLmxRetornoImpressora) : string; virtual;
    function RetornosImpressoraToString : string; virtual;
    function StatusImpressoraToString : string; virtual;
    function ImpressoraLigada : Boolean; virtual;
    function CortarPapel : Boolean; virtual;
    function EmitirQRCode(const AValorQrCode : string) : Boolean; virtual;
    function EmitirBarCode(const AValorQrCode : string; const ATipoImpressaoCodigoBarras : TLmxTipoImpressaoCodigoBarras) : Boolean; virtual;
    function Autenticar(const AAutenticacao : string) : Boolean; virtual;

    function AutoTeste : Boolean; virtual;

    function IdentificarConsumidor(const AIdentificador, ANome, AEnderecoCompleto : string) : Boolean; virtual;
    function LancarValorTributos(const AValorTributosFederais, AValorTributosEstaduais, AValorTributosMunicipais  : Double) : Boolean; virtual;
    function DadosVendaEletronica(const ANumero, ASerie, AEnderecoChave, AChaveAcesso : string; const ADataEmissao : TDateTime) : Boolean; virtual;
    function DadosAutorizacaoEletronica(const AQRCode, AProtocolo : string; const ADataProtocolo : TDateTime;
      const AFormaEmissao : TNotaFormaEmissao; const AAmbiente : TNotaAmbiente) : Boolean; virtual;

    property ModoTeste : Boolean read FModoTeste write FModoTeste;
    property ConfiguracoesImpressora : TLmxControleImpressora read FConfiguracoesImpressora write SetConfiguracoesImpressora;

    property OnAlterarStatusImpressoraEvent : TLmxOnAlterarStatusImpressoraEvent read FOnAlterarStatusImpressoraEvent
      write FOnAlterarStatusImpressoraEvent;
    property OnPrintExecuteEvent : TLmxOnPrintExecute read FOnPrintExecuteEvent write FOnPrintExecuteEvent;
  end;

  TLmxImpressoraClass = class of TLmxImpressora;

  TLmxImpressoraInfo = class
  private
    FDescricao: string;
    FClasse: TLmxImpressoraClass;
  public
    property Descricao : string read FDescricao write FDescricao;
    property Classe : TLmxImpressoraClass read FClasse write FClasse;
  end;

  TLmxImpressoraList = class(TObjectDictionary<TLmxImpressoraClass,TLmxImpressoraInfo>);


implementation

{ TImpressora }


function TLmxImpressora.AcrescimoItem(const AITem: Integer;
  const AAcrescimo: Double): Boolean;
begin
  DoLog(Format('Acréscimo Item %d;Acresc=%f', [AITem, AAcrescimo]));
  Result := DoAcrescimoItem(AITem, AAcrescimo);
end;

procedure TLmxImpressora.AdicionarPagamento(const AFormaPagamento: TLmxTipoFormaPagamento;
  const AValorPago: Double);
begin
  DoAdicionarPagamento(AFormaPagamento, AValorPago);
end;

function TLmxImpressora.Autenticar(const AAutenticacao: string): Boolean;
begin
  Result := DoAutenticar(AAutenticacao);
end;

function TLmxImpressora.AutoTeste: Boolean;
begin
  Result := DoAutoTeste;
end;

function TLmxImpressora.CancelarItem(const AITem: Integer): Boolean;
begin
  Result := DoCancelarItem(AITem);
  if Result then
  begin
    DoLog(Format('Item Cancelado Item=%d', [AITem]));
    DoAlterarStatusImpressora(tsiItemCancelado);
  end;
end;

function TLmxImpressora.CancelarUltimoDocumento: Boolean;
begin
  Result := DoCancelarUltimoDocumento;
  if Result then
  begin
    DoLog('Ultima Venda Cancelada');
    DoAlterarStatusImpressora(tsiCupomCancelado);
  end;
  DoAlterarStatusImpressora(tsiAguardando);
end;

function TLmxImpressora.CancelarVenda: Boolean;
begin
  Result := DoCancelarVenda;
  if Result then
  begin
    DoLog('Venda Cancelada');
    DoAlterarStatusImpressora(tsiCupomCancelado);
  end;
  DoAlterarStatusImpressora(tsiAguardando);
end;

function TLmxImpressora.CancelarVendaEspecifica(
  const ANumero: Integer): Boolean;
begin
  Result := DoCancelarVendaEspecifica(ANumero);
  if Result then
  begin
    DoLog(Format('Venda %d Cancelada', [ANumero]));
    DoAlterarStatusImpressora(tsiCupomCancelado);
  end;
  DoAlterarStatusImpressora(tsiAguardando);
end;

function TLmxImpressora.CarregarDadosImpressora: Boolean;
begin
  Result := DoCarregarDadosImpressora;
  DoLog('Carregando Dados da Impressora...');
end;

function TLmxImpressora.CarregarDadosUltimaReducaoZ(out ADadosReducaoZ : TLmxDadosReducaoZ): Boolean;
begin
  Result := DoCarregarDadosUltimaReducaoZ(ADadosReducaoZ);
  DoLog('Carregando Dados da Ultima Reducao Z...');
end;

function TLmxImpressora.CarregarDLL: Boolean;
begin
  if FDLLHandle = 0 then
    LmxUtils.SystemUtils.CarregarBibliotecaDinamica(GetNomeDll, FDLLHandle);
  Result := GetDllCarregada;
end;

procedure TLmxImpressora.DoCarregarMetodos;
begin


end;

function TLmxImpressora.ConcluirVenda(const AFormaPagamento: TLmxTipoFormaPagamento;
  const AValorDesconto, AValorAcrescimo, AValorTotalVenda, AValorPago: Double;
  const AMensagem : string) : Boolean;
begin
  Result := False;
  if FStatusImpressora in [tsiVendaIniciada, tsiItemVendido, tsiItemCancelado] then
  begin
    DoAlterarStatusImpressora(tsiFechando);
    Result := DoConcluirVenda(AFormaPagamento, AValorDesconto, AValorAcrescimo, AValorTotalVenda, AValorPago, AMensagem);
    if Result then
    begin
      DoAlterarStatusImpressora(tsiAguardando);
      DoLog(Format('Venda Concluída Forma=%d;Desc=%f;Total=%f;Pago=%f;Msg=%s', [Integer(AFormaPagamento),
        AValorDesconto, AValorTotalVenda, AValorPago, AMensagem]));
      Result := True;
    end else begin
      DoAlterarStatusImpressora(tsiErro);
    end;
  end;
end;

function TLmxImpressora.CortarPapel: Boolean;
begin
  Result := DoCortarPapel;
  if Result then
    DoLog('Papel Cortado');
end;

constructor TLmxImpressora.Create;
begin
  DoAlterarStatusImpressora(tsiAguardando);
  FDadosImpressora := TLmxDadosImpressora.Create;
  FConfiguracoesImpressora := TLmxControleImpressora.Create;
end;

function TLmxImpressora.DadosAutorizacaoEletronica(const AQRCode,
  AProtocolo: string; const ADataProtocolo: TDateTime;
      const AFormaEmissao : TNotaFormaEmissao; const AAmbiente : TNotaAmbiente): Boolean;
var
  lQrCode: string;
begin
  if FModoTeste then
  begin
    lQrCode := 'chNFe=99999999999999999999999999999999999999999999&nVersao=100&tpAmb=2 ' +
      '&dhEmi=99999999999999999999999999999999999999999999999999&vNF=407.38&vICMS=0.00' +
      '&digVal=9999999999999999999999999999999999999999999999999999999D&cIdToken=000001' +
      '&cHashQRCode=99999999999999999999999999999999999999999';
    Result := DoDadosAutorizacaoEletronica(lQRCode, '9999999999999999', StrToDateTime('01/01/2000 00:00:00') , AFormaEmissao,
      AAmbiente);
  end else
    Result := DoDadosAutorizacaoEletronica(AQRCode, AProtocolo, ADataProtocolo, AFormaEmissao,
      AAmbiente);
end;

function TLmxImpressora.DadosVendaEletronica(const ANumero, ASerie,
  AEnderecoChave, AChaveAcesso: string; const ADataEmissao: TDateTime): Boolean;
begin
  DadosImpressora.UltimaVenda.Numero := StrToInt(ANumero);
  DadosImpressora.UltimaVenda.Serie := ASerie;
  DadosImpressora.UltimaVenda.ChaveAcesso := AChaveAcesso;
  DadosImpressora.UltimaVenda.DataEmissao := ADataEmissao;

  if FModoTeste then
    Result := DoDadosVendaEletronica(ANumero, ASerie, AEnderecoChave, '99999999999999999999999999999999999999999999', StrToDateTime('01/01/2000 00:00:00'))
  else
    Result := DoDadosVendaEletronica(ANumero, ASerie, AEnderecoChave, AChaveAcesso, ADataEmissao);
end;

function TLmxImpressora.DescarregarDLL: Boolean;
begin
  Result := LmxUtils.SystemUtils.DescarregarBibliotecaDinamica(FDLLHandle);
end;

function TLmxImpressora.DescontoItem(const AITem: Integer;
  const ADesconto: Double): Boolean;
begin
  DoLog(Format('Desconto Item %d;Desc=%f', [AITem, ADesconto]));
  Result := DoDescontoItem(AITem, ADesconto);
end;

destructor TLmxImpressora.Destroy;
begin
  FreeAndNil(FConfiguracoesImpressora);
  FreeAndNil(FDadosImpressora);
  if FDLLHandle <> 0 then
  begin
  {$IFDEF MSWINDOWS}
    FreeLibrary(FDLLHandle);
    FDLLHandle := 0;
  {$ENDIF}
  end;
  inherited;
end;

function TLmxImpressora.DoAlterarStatusImpressora(const AStatus: TLmxStatusImpressora): Boolean;
begin
  FStatusImpressora := AStatus;
  if Assigned(FOnAlterarStatusImpressoraEvent) then
    FOnAlterarStatusImpressoraEvent(Self, FStatusImpressora, AStatus);
  Result := True;
end;

function TLmxImpressora.DoAutenticar(const AAutenticacao: string): Boolean;
begin
  Result := True;
end;

function TLmxImpressora.DoLog(const ALog: string): Boolean;
begin
  if Assigned(FOnPrintExecuteEvent) then
    FOnPrintExecuteEvent(Self, teiLog, ALog);
  Result := True;
end;

function TLmxImpressora.DoValidarStatusImpressora(
  const ARetornoInpressora: TLmxRetornoImpressora;
  const AStatusImpressora: TLmxStatusImpressora): Boolean;
begin
  Result := True;
end;

function TLmxImpressora.EmitirBarCode(const AValorQrCode: string; const ATipoImpressaoCodigoBarras : TLmxTipoImpressaoCodigoBarras): Boolean;
begin
  Result := DoEmitirCodigoBarras(AValorQrCode, ATipoImpressaoCodigoBarras);
end;

function TLmxImpressora.EmitirLeituraX: Boolean;
begin
  Result := DoEmitirLeituraX;
  if Result then
    DoLog('Leitura X Emitida');
end;

function TLmxImpressora.EmitirQRCode(const AValorQrCode: string): Boolean;
begin
  Result := DoEmitirQrCode(AValorQrCode);
end;

function TLmxImpressora.EmitirReducaoZ: Boolean;
begin
  Result := DoEmitirReducaoZ;
  if Result then
    DoLog('Redução Z Emitida');
end;

function TLmxImpressora.EmitirRelatorioGerencial(const ARelatorio: string;
  const AFecharAoConcluir: Boolean) : Boolean;
begin
  Result := False;
  if FStatusImpressora in [tsiAguardando, tsiEmitindoGerencial] then
  begin
    DoAlterarStatusImpressora(tsiEmitindoGerencial);
    Result := DoEmitirRelatorioGerencial(ARelatorio);
    if Result then
    begin
      DoLog('Relatorio Gerencial Gerado');
      if AFecharAoConcluir then
      begin
        DoAlterarStatusImpressora(tsiFechando);
        DoLog('Relatorio Gerencial Fechado');
        Result := DoFecharRelatorioGerencial;
        if Result then
          DoAlterarStatusImpressora(tsiAguardando);
      end;
    end else begin
      DoAlterarStatusImpressora(tsiErro);
    end;
  end;
end;

function TLmxImpressora.FinalizarImpressora: Boolean;
begin
  DoLog('Finalizando Impressora');
  Result := DoFinalizarImpressora;
end;

function TLmxImpressora.GetDllCarregada: Boolean;
begin
  Result := (FDLLHandle <> 0);
end;

function TLmxImpressora.GetHandle: Cardinal;
begin
  Result := FDLLHandle;
end;

function TLmxImpressora.GetNomeDll: string;
begin
  Result := '';
end;

function TLmxImpressora.GetNumeroCupomAtual: Integer;
begin
  Result := DoGetNumeroCupomAtual;
  DoLog(Format('Obter Numero Cupom Atual', [Result]));
end;

function TLmxImpressora.GetProcedimento(const Nome: string): Pointer;
begin
  {$IFDEF MSWINDOWS}

  if FDLLHandle = 0 then
    if not CarregarDll then
      raise Exception.Create('Não foi possível carregar a DLL de comunicação' + sLineBreak +
        'DLL : ' + GetNomeDll + sLineBreak +
        'Ela pode estar na pasta do sistema (Windows), ou em uma pasta .\lib !' );
  Result := GetProcAddress(FDLLHandle, PAnsiChar(AnsiString(Nome)));
  {$ENDIF}
end;

function TLmxImpressora.GetQuantidadeColunas: Integer;
begin
  if FConfiguracoesImpressora.QuantidadeColunas = 0 then
    Result := 48
  else
    Result := FConfiguracoesImpressora.QuantidadeColunas;
end;

function TLmxImpressora.GetRetornosInErro: TLmxRetornosImpressora;
begin
  Result :=  [riErro, riFimPapel, riErroRelogio, riImpressoraEmErro, riCMDNaoIniciado,
    riNumParametrosInvalidos, riTipoParametroInvalido, riMemoriaLotada,
    riCMOSNaoVolatil, riAliquotaNaoProgramada, riAliquotasLotadas, riCancelamentoNaoPermitido,
    riComandoNaoExecutado, riReduzaoZPendente, riDiaFechado, riIntervencaoTecnica];
end;

function TLmxImpressora.IniciarVenda(const ACPF: string; out ACupomIniciado : Integer): Boolean;
begin
  Result := False;
  ACupomIniciado := 0;
  if FStatusImpressora in [tsiAguardando] then
  begin
    Result := DoIniciarVenda(ACPF);
    if Result then
    begin
      DoAlterarStatusImpressora(tsiVendaIniciada);
      ACupomIniciado := DoGetNumeroCupomAtual;
      DoLog(Format('Venda Iniciada COO=%d', [ACupomIniciado]));
    end else begin
      DoAlterarStatusImpressora(tsiErro);
    end;  
  end;
end;

function TLmxImpressora.LancarValorTributos(
  const AValorTributosFederais, AValorTributosEstaduais, AValorTributosMunicipais: Double): Boolean;
begin
  Result := DoValorTributos(AValorTributosFederais, AValorTributosEstaduais, AValorTributosMunicipais);
end;

function TLmxImpressora.MensagensSistema(const AMensagens: string): Boolean;
begin
  Result := DoMensagensSistema(AMensagens);
end;

function TLmxImpressora.RetornosImpressora: TLmxRetornosImpressora;
var
  lErro: Boolean;
  lRetorno: TLmxRetornoImpressora;
begin
  Result := DoRetornoImpressora;
  DoLog('Obtem retornos Impressora solicitado');

  if riCupomAberto in Result then
    DoAlterarStatusImpressora(tsiVendaIniciada)
  else begin
    lErro := False;
    for lRetorno in Result do
      if not lErro then
        lErro := lRetorno in GetRetornosInErro;
    if lErro then
      DoAlterarStatusImpressora(tsiErro);
  end;
end;

function TLmxImpressora.RetornoImpressoraToString(
  const ARetorno: TLmxRetornoImpressora): string;
begin
  Result := '';
  case ARetorno of
    riErro                    : Result := 'Erro na Impressora';
    riFimPapel                : Result := 'Fim de Papel';
    riPoucoPapel              : Result := 'Pouco Papel';
    riErroRelogio             : Result := 'Erro de Relógio';
    riImpressoraEmErro        : Result := 'Impressora em Erro';
    riCMDNaoIniciado          : Result := 'Comando não Iniciado';
    riComandoInexistente      : Result := 'Comando Inexistente';
    riNumParametrosInvalidos  : Result := 'Numero de Parâmetros Inválidos';
    riTipoParametroInvalido   : Result := 'Tipo de Parâmetro Inválido';
    riCupomAberto             : Result := 'Cupom fiscal já aberto';
    riMemoriaLotada           : Result := 'Memória Lotada';
    riCMOSNaoVolatil          : Result := 'CMOS não Volátil';
    riAliquotaNaoProgramada   : Result := 'Alíquota não programada';
    riAliquotasLotadas        : Result := 'Alíquotas Lotadas';
    riCancelamentoNaoPermitido: Result := 'Cancelamento não permitido';
    riCGCNaoProgramado        : Result := 'CGC não Programado';
    riComandoNaoExecutado     : Result := 'Comando não Executado';
    riDiaAberto               : Result := 'Dia Aberto';
    riDiaFechado              : Result := 'Dia Fechado';
    riIntervencaoTecnica      : Result := 'Intercenção Técnica';
  end;
  DoLog('Retorno Impressora : ' + Result);
end;

function TLmxImpressora.RetornosImpressoraToString: string;
var
  I : TLmxRetornoImpressora;
  lRetorno : TLmxRetornosImpressora;
begin
  Result := '';
  lRetorno := RetornosImpressora;
  for I := Low(TLmxRetornoImpressora) to High(TLmxRetornoImpressora) do
  begin
    if I in lRetorno then
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + RetornoImpressoraToString(I);
    end;  
  end;
end;

procedure TLmxImpressora.SetConfiguracoesImpressora(
  const Value: TLmxControleImpressora);
begin
  if Value <> nil then
    FConfiguracoesImpressora.ClonarDeOutro(Value);
end;

function TLmxImpressora.StatusImpressora: TLmxStatusImpressora;
begin
  Result := FStatusImpressora; // tsiNaoConfigurada;
end;

function TLmxImpressora.StatusImpressoraToString: string;
begin
  Result := 'Status não tratado ' + IntToStr(Integer(FStatusImpressora));
  case FStatusImpressora of
    tsiNaoConfigurada   : Result := 'Não Configurada';
    tsiErro             : Result := 'Erro';
    tsiAguardando       : Result := 'Aguardando';
    tsiVendaIniciada    : Result := 'Venda Iniciada';
    tsiItemVendido      : Result := 'Item Vendido';
    tsiItemCancelado    : Result := 'ITem Cancelado';
    tsiEmitindoGerencial: Result := 'Emitindo Gerencial';
    tsiFechando         : Result := 'Fechando';
    tsiCupomCancelado   : Result := 'Cupom Cancelado';
  end;
end;

function TLmxImpressora.VenderItem(const ASequencia, ACodigo: Integer;
  const ANomeProduto: string; const AValorUnitario: Double;
  const AUnidade : string; const ATipoAliquota: string; const AQuantidade, ADesconto: Double): Boolean;
begin
  Result := False;
  if FStatusImpressora in [tsiVendaIniciada, tsiItemVendido, tsiItemCancelado] then
  begin
    Result := DoVenderItem(ASequencia, ACodigo, ANomeProduto, AValorUnitario, AUnidade, ATipoAliquota, AQuantidade, ADesconto);
    if Result then
    begin
      DoLog(Format('Item Vendido : Seq=%d;Cod=%d;Prod=%s;Unit=%f;Aliq=%s;Qtd=%f;Desc=%f',
        [ASequencia, ACodigo, ANomeProduto, AValorUnitario, ATipoAliquota,AQuantidade, ADesconto]));
      DoAlterarStatusImpressora(tsiItemVendido);
    end else begin
      DoAlterarStatusImpressora(tsiErro);
    end;
  end;    
end;

function TLmxImpressora.InicializarImpressora: Boolean;
//var
//  lRetornos : TLmxRetornosImpressora;
begin
//  Result := False;
  DoLog('Carregando Métodos Impressora....');
  DoCarregarMetodos;
  DoLog('Inicializando Impressora');
  Result := (DoInicializarImpressora and ImpressoraLigada);
  if Result then
  begin
    DoLog('Carregando Configurações da Impressora');
    if not DoCarregarDadosImpressora then
    begin
      FinalizarImpressora;
      raise EPDVExceptionImpressora.Create('Error Message');
    end;
    DoLog('Impressora : ' + ConfiguracoesImpressora.ClasseImpressora);
    DoLog('Porta      : ' + ConfiguracoesImpressora.PortaComunicacao);
    DoLog('Velocidade : ' + IntToStr(ConfiguracoesImpressora.Velocidade));
    if ConfiguracoesImpressora.Concomitante then
      DoLog('Impressão Concomitante')
    else
      DoLog('Impressão não Concomitante');
  end else begin
    FinalizarImpressora;
  end;
end;

function TLmxImpressora.IdentificarConsumidor(const AIdentificador, ANome,
  AEnderecoCompleto: string): Boolean;
begin
  Result := DoDadosConsumidor(AIdentificador, ANome, AEnderecoCompleto);
end;

function TLmxImpressora.ImpressoraLigada: Boolean;
begin
  Result := DoImpressoraLigada;
end;

{ TLmxDadosImpressora }

procedure TLmxDadosImpressora.Carregar;
begin
  CarregarDeArquivo(GetNomeDocumentoDadosImpressora);
end;

constructor TLmxDadosImpressora.Create;
begin
  FEmpresaEmissao := TLmxDadosImpressoraEmpresaEmissao.Create;
  FContadores     := TLmxDadosImpressoraContadores.Create;
  FIdentificacao  := TLmxDadosImpressoraIdentificacao.Create;
  FUltimaReducaoZ := TLmxDadosReducaoZ.Create;
  FUltimaVenda    := TLmxDadosVenda.Create;
end;

destructor TLmxDadosImpressora.Destroy;
begin
  FreeAndNil(FUltimaVenda);
  FreeAndNil(FUltimaReducaoZ);
  FreeAndNil(FIdentificacao);
  FreeAndNil(FEmpresaEmissao);
  FreeAndNil(FContadores);
  inherited;
end;


function TLmxDadosImpressora.GetNomeDocumentoDadosImpressora: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'DadosImpressora.xml';
end;

procedure TLmxDadosImpressora.Salvar;
begin
  SalvarEmArquivo(GetNomeDocumentoDadosImpressora);
end;


{ TLmxDadosReducaoZFormasPagamento }

procedure TLmxDadosReducaoZFormasPagamento.AdicionarValor(
  const AFormaPagamento: string; const AValor: Double);
var
  lValor: Double;
begin
  if not TryGetValue(AFormaPagamento, lValor) then
    lValor := 0;
  AddOrSetValue(AFormaPagamento, lValor + AValor);
end;

{ TLmxDadosReducaoZ }

//function TLmxDadosReducaoZ.GetTotaisFormasPagamento: string;
//begin
//
//end;

end.

