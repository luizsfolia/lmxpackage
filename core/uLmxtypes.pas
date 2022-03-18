unit uLmxtypes;

interface

uses
  Classes, SysUtils;

type

  TLmxControlerStatus = (tcsAtivo, tcsAlterado, tcsMarcadoExclusao, tcsExcluido);

type

  TLmxStatusImpressora = (tsiNaoConfigurada, tsiErro, tsiAguardando, tsiVendaIniciada, tsiItemVendido,
    tsiItemCancelado, tsiEmitindoGerencial, tsiFechando, tsiCupomCancelado);
  TLmxRetornoImpressora = (riErro, riFimPapel, riPoucoPapel, riErroRelogio, riImpressoraEmErro, riCMDNaoIniciado,
    riComandoInexistente, riCupomAberto, riNumParametrosInvalidos, riTipoParametroInvalido, riMemoriaLotada,
    riCMOSNaoVolatil, riAliquotaNaoProgramada, riAliquotasLotadas, riCancelamentoNaoPermitido, riCGCNaoProgramado,
    riComandoNaoExecutado, riReduzaoZPendente, riDiaAberto, riDiaFechado, riIntervencaoTecnica);
  TLmxTipoImpressaoCodigoBarras = (ticbCodBar, ticbCode128, ticbCode39, ticbCode93, ticbEan13, ticbEan8, ticbItf, ticbUpca, ticbUpce,
    ticbPdf417);
  TLmxRetornosImpressora = set of TLmxRetornoImpressora;
  TLmxSituacaoItemVenda = (sivAtivo, sivCancelado);
  TLmxSituacaoVenda = (svIncompleta, svAtiva, svCancelada);
  TLmxNaturezaOperacaoVenda = (novVenda, novCompra, novTransferencia, novDevolucao, novImportacao,
    novConsignacao, novRemessa);
  TLmxTipoFormaPagamento = (tfpVista, tfpPrazo);
  TLmxPosicaoCentavosFatura = (pcfTodas, pcfPrimeira, pcfUltima);
  TLmxSituacaoParcela = (spAberta, spPagamentoParcial, spQuitada, spHaver);
  TLmxTipoComprovante = (tccNenhum, tcComprovantePrazo, tcValeTroco, tcParcelas, tcQuitacaoParcela);
  TLmxTipoDesconto = (tcdNenhum, tcdTodos, tcdProduto, tcdCliente, tcdFormaPagamento, tcdTipoPagamento);
  TLmxOrigemPagamento = (topParcela);
  TLmxTipoImpressora = (tiFiscal, tiNaoFiscal);
  TTipoExecucaoImpressora = (teiLog, teiConfig);
  TLmxTipoMovimentacaoEstoque = (tmeNulo, tmeEntrada, tmeSaida);
  TLmxMsgType = (mtWarning, mtError, mtInformation, mtQuestion, mtSuccess, mtWait);
  TLmxMsgBtn = (fbNone, fbYes, fbNo, fbOK, fbCancel, fbAbort, fbRetry, fbIgnore, fbClose);
  TLmxMsgButtons = set of TLmxMsgBtn;
  TLmxTipoTributo = (ttIcms, ttPis, ttCofins, ttISSQN);
//  TLmxControlerStatus = (tcsAtivo, tcsAlterado, tcsMarcadoExclusao, tcsExcluido);
  TLmxTipoCargaProduto = (tcpCodigo, tcpCodigoBarras);
  TLmxTipoComandoController = (tccMostrar, tccIncluir, tccAlterar, tccExcluir);
  TLmxTipoPessoa = (tpFisica, tpJuridica);
  TLmxEstadoCivil = (tecSolteiro, tecCasado, tecDivorciado, tecViuvo);
  TLmxTipoCodigoBarras = (tcbEan, tcbLocal);
  TLmxFormaEmissao = (feSemRetorno, feErro, feNormal, feContingencia, feSemValor, feReemitirContingencia,
    feContingenciaEmitida);
  TLmxFormatacaoTextoImpressora = (ftiNegrito, ftiItalico, ftiSublinhado, ftiCondensado);
  TLmxFormatacoesTextoImpressora = set of TLmxFormatacaoTextoImpressora;
  TLmxTipoAjusteVenda = (tavDescontoIrregular, tavNumeroInconsistente, tavNotaSemValor, tavNotaContingencia);

  TPVTipoRegimeTributario = (trtSimplesNacional, trtSimplesExcessoReceita, trtRegimeNormal);
//  TLmxCSTIcms = (cst00, cst10, cst20, cst30, cst40, cst41, cst45, cst50, cst51,
//                 cst60, cst70, cst80, cst81, cst90, cstPart10, cstPart90,
//                 cstRep41, cstVazio, cstICMSOutraUF, cstICMSSN); //80 e 81 apenas para CTe
//  TLmxCSOSNIcms = (csosnVazio,csosn101, csosn102, csosn103, csosn201, csosn202, csosn203, csosn300, csosn400, csosn500,csosn900 );

  TNotaVersaoDocumento = (nve200, nve300, nve310);
  TNotaModeloDocumento = (nmoNFe, nmoNFCe, nmoCupomFiscal);
  TNotaFormaEmissao    = (nteNormal, nteContingencia, nteSCAN, nteDPEC, nteFSDA, nteSVCAN, nteSVCRS, nteSVCSP, nteOffLine);
  TNotaAmbiente        = (ntaTeste, ntaProducao, ntaHomologacao);

  procedure TNotaVersaoDocumentoToList(const AList : TStrings);
  function  TNotaVersaoDocumentoToString(const ANotaversao : TNotaVersaoDocumento) : string;
  function  TNotaVersaoDocumentoFromString(const AVersaDocumento : string) : TNotaVersaoDocumento;

  procedure TNotaModeloDocumentoToList(const AList : TStrings);
  function  TNotaModeloDocumentoToString(const ANotaModeloDocumento : TNotaModeloDocumento) : string;
  function  TNotaModeloDocumentoFromString(const ANotaModeloDocumento : string) : TNotaModeloDocumento;

  procedure TLmxTipoFormaPagamentoToList(const AList : TStrings);
  function  TLmxTipoFormaPagamentoToString(const APDVTipoFormaPagamento : TLmxTipoFormaPagamento) : string;
  function  TLmxTipoFormaPagamentoFromString(const APDVTipoFormaPagamento : string) : TLmxTipoFormaPagamento;

  procedure TLmxTipoComprovanteToList(const AList : TStrings);
  function  TLmxTipoComprovanteToString(const ATLmxTipoComprovante : TLmxTipoComprovante) : string;
  function  TLmxTipoComprovanteFromString(const ATLmxTipoComprovante : string) : TLmxTipoComprovante;

  procedure TLmxPosicaoCentavosFaturaToList(const AList : TStrings);
  function  TLmxPosicaoCentavosFaturaToString(const ATLmxPosicaoCentavosFatura : TLmxPosicaoCentavosFatura) : string;
  function  TLmxPosicaoCentavosFaturaFromString(const ATLmxPosicaoCentavosFatura : string) : TLmxPosicaoCentavosFatura;

  procedure TNotaAmbienteToList(const AList : TStrings);
  function  TNotaAmbienteToString(const ATNotaAmbiente : TNotaAmbiente) : string;
  function  TNotaAmbienteFromString(const ATNotaAmbiente : string) : TNotaAmbiente;

  procedure TPVTipoRegimeTributarioToList(const AList : TStrings);
  function  TPVTipoRegimeTributarioToString(const ATPVTipoRegimeTributario : TPVTipoRegimeTributario) : string;
  function  TPVTipoRegimeTributarioFromString(const ATPVTipoRegimeTributario : string) : TPVTipoRegimeTributario;

  procedure TPVSituacaoTributariaToList(const AList : TStrings);
  function TPVSituacaoTributariaFromString(const ACST : string) : Integer;

  procedure TPVSituacaoTributariaSimplesToList(const AList : TStrings);
  function  TPVSituacaoTributariaSimplesFromString(const ACSOSN : string) : Integer;
//  function  TPVSituacaoTributariaSimplesToString(const ACSOSN : Integer) : string;

  function TPVNaturezaOperacaoToString(const ANaturezaOperacaoVenda : TLmxNaturezaOperacaoVenda) : string;
  function TPVNaturezaOperacaoFromString(const ANaturezaOperacaoVenda : string) : TLmxNaturezaOperacaoVenda;

{type

  TLmxListagemTipoBase = class

  end;

  TLmxListagemTipoBaseClass = class of TLmxListagemTipoBase;

  TLmxListagemTipoBase<T> = class(TLmxListagemTipoBase)
  protected
    procedure ToList(const AList : TStrings); virtual; abstract;
    function ToString(const AItem : T) : string; virtual; abstract;
    function FromString(const AItem : string) : T; virtual; abstract;
  end;

  TLmxListagemTipoNotaVersaoDocumento = class(TLmxListagemTipoBase<TNotaVersaoDocumento>)

  end;

  TLmxListagemTipoPDVRegimeTributario = class(TLmxListagemTipoBase<TPVTipoRegimeTributario>)
  protected
    procedure ToList(const AList : TStrings); override;
    function ToString(const AItem : TPVTipoRegimeTributario) : string; override;
    function FromString(const AItem : string) : TPVTipoRegimeTributario; override;
  end;

  TLmxListagens = class
  private
    FListagens : TObjectList;
    FNotaVersaoDocumento: TLmxListagemTipoNotaVersaoDocumento;
    FPDVRegimeTributario: TLmxListagemTipoPDVRegimeTributario;
    procedure AddFilho(const ATipoFilho : TLmxListagemTipoBase; out AFilho);
  public
    constructor Create;
    destructor Destroy; override;

    property NotaVersaoDocumento : TLmxListagemTipoNotaVersaoDocumento read FNotaVersaoDocumento;
    property PDVRegimeTributario : TLmxListagemTipoPDVRegimeTributario read FPDVRegimeTributario;
  end;

  function PDVListagens : TLmxListagens;
                 }
implementation

{var
  FPDVListagens : TLmxListagens;

function PDVListagens : TLmxListagens;
begin
  Result := FPDVListagens;
end; }


function TPVNaturezaOperacaoToString(const ANaturezaOperacaoVenda : TLmxNaturezaOperacaoVenda) : string;
begin
  Result := '';
  case ANaturezaOperacaoVenda of
    novVenda           : Result := 'VENDA';
    novCompra          : Result := 'COMPRA';
    novTransferencia   : Result := 'TRANSFERENCIA';
    novDevolucao       : Result := 'DEVOLUCAO';
    novImportacao      : Result := 'IMPOTACAO';
    novConsignacao     : Result := 'CONSIGNACAO';
    novRemessa         : Result := 'REMESSA';
  end;
end;

function TPVNaturezaOperacaoFromString(const ANaturezaOperacaoVenda : string) : TLmxNaturezaOperacaoVenda;
begin
  Result := novVenda;
  if ANaturezaOperacaoVenda = 'VENDA' then
    Result := novVenda
  else if ANaturezaOperacaoVenda = 'COMPRA' then
    Result := novCompra
  else if ANaturezaOperacaoVenda = 'TRANSFERENCIA' then
    Result := novTransferencia
  else if ANaturezaOperacaoVenda = 'DEVOLUCAO' then
    Result := novDevolucao
  else if ANaturezaOperacaoVenda = 'IMPOTACAO' then
    Result := novImportacao
  else if ANaturezaOperacaoVenda = 'CONSIGNACAO' then
    Result := novConsignacao
  else if ANaturezaOperacaoVenda = 'REMESSA' then
    Result := novRemessa;
end;

procedure TNotaVersaoDocumentoToList(const AList : TStrings);
var
  I: TNotaVersaoDocumento;
begin
  for I := Low(TNotaVersaoDocumento) to High(TNotaVersaoDocumento) do
    AList.Add(TNotaVersaoDocumentoToString(I));
end;

function  TNotaVersaoDocumentoToString(const ANotaversao : TNotaVersaoDocumento) : string;
begin
  Result := '';
  case ANotaversao of
    nve200: Result := '2.0';
    nve300: Result := '3.0';
    nve310: Result := '3.1';
  end;
end;

function  TNotaVersaoDocumentoFromString(const AVersaDocumento : string) : TNotaVersaoDocumento;
begin
  Result := nve310;
  if AVersaDocumento = '2.0' then
    Result := nve200
  else if AVersaDocumento = '3.0' then
    Result := nve300
  else if AVersaDocumento = '3.1' then
    Result := nve310;
end;


procedure TNotaModeloDocumentoToList(const AList : TStrings);
var
  I: TNotaModeloDocumento;
begin
  for I := Low(TNotaModeloDocumento) to High(TNotaModeloDocumento) do
    AList.Add(TNotaModeloDocumentoToString(I));
end;

function  TNotaModeloDocumentoToString(const ANotaModeloDocumento : TNotaModeloDocumento) : string;
begin
  Result := '';
  case ANotaModeloDocumento of
    nmoNFe: Result := 'NFe';
    nmoNFCe: Result := 'NFCe';
    nmoCupomFiscal: Result := 'Cupom';
  end;
end;

function  TNotaModeloDocumentoFromString(const ANotaModeloDocumento : string) : TNotaModeloDocumento;
begin
  Result := nmoNFCe;
  if ANotaModeloDocumento = 'NFe' then
    Result := nmoNFe
  else if ANotaModeloDocumento = 'NFCe' then
    Result := nmoNFCe
  else if ANotaModeloDocumento = 'Cupom' then
    Result := nmoCupomFiscal;
end;

procedure TLmxTipoFormaPagamentoToList(const AList : TStrings);
var
  I: TLmxTipoFormaPagamento;
begin
  for I := Low(TLmxTipoFormaPagamento) to High(TLmxTipoFormaPagamento) do
    AList.Add(TLmxTipoFormaPagamentoToString(I));
end;

function  TLmxTipoFormaPagamentoToString(const APDVTipoFormaPagamento : TLmxTipoFormaPagamento) : string;
begin
  Result := '';
  case APDVTipoFormaPagamento of
    tfpVista: Result := 'Vista';
    tfpPrazo: Result := 'Prazo';
  end;
end;

function  TLmxTipoFormaPagamentoFromString(const APDVTipoFormaPagamento : string) : TLmxTipoFormaPagamento;
begin
  Result := tfpVista;
  if APDVTipoFormaPagamento = 'Vista' then
    Result := tfpVista;
  if APDVTipoFormaPagamento = 'Prazo' then
    Result := tfpPrazo;
end;

procedure TLmxTipoComprovanteToList(const AList : TStrings);
var
  I: TLmxTipoComprovante;
begin
  for I := Low(TLmxTipoComprovante) to High(TLmxTipoComprovante) do
    AList.Add(TLmxTipoComprovanteToString(I));
end;

function  TLmxTipoComprovanteToString(const ATLmxTipoComprovante : TLmxTipoComprovante) : string;
begin
  case ATLmxTipoComprovante of
    tccNenhum          : Result := 'Nenhum';
    tcComprovantePrazo : Result := 'Comprovante Prazo';
    tcValeTroco        : Result := 'Vale Troco';
    tcParcelas         : Result := 'Parcelas';
    tcQuitacaoParcela         : Result := 'Quitação Parcela';
  end;
end;

function  TLmxTipoComprovanteFromString(const ATLmxTipoComprovante : string) : TLmxTipoComprovante;
begin
  Result := tccNenhum;
  if ATLmxTipoComprovante = 'Comprovante Prazo' then
    Result := tcComprovantePrazo;
  if ATLmxTipoComprovante = 'Vale Troco' then
    Result := tcValeTroco;
  if ATLmxTipoComprovante = 'Parcelas' then
    Result := tcParcelas;
  if ATLmxTipoComprovante = 'Quitação Parcela' then
    Result := tcQuitacaoParcela;
end;


procedure TLmxPosicaoCentavosFaturaToList(const AList : TStrings);
var
  I: TLmxPosicaoCentavosFatura;
begin
  for I := Low(TLmxPosicaoCentavosFatura) to High(TLmxPosicaoCentavosFatura) do
    AList.Add(TLmxPosicaoCentavosFaturaToString(I));
end;

function  TLmxPosicaoCentavosFaturaToString(const ATLmxPosicaoCentavosFatura : TLmxPosicaoCentavosFatura) : string;
begin
  case ATLmxPosicaoCentavosFatura of
    pcfTodas    : Result := 'Todas';
    pcfPrimeira : Result := 'Primeira';
    pcfUltima   : Result := 'Ultima';
  end;
end;

function  TLmxPosicaoCentavosFaturaFromString(const ATLmxPosicaoCentavosFatura : string) : TLmxPosicaoCentavosFatura;
begin
  Result := pcfTodas;
  if ATLmxPosicaoCentavosFatura = 'Todas' then
    Result := pcfTodas;
  if ATLmxPosicaoCentavosFatura = 'Primeira' then
    Result := pcfPrimeira;
  if ATLmxPosicaoCentavosFatura = 'Ultima' then
    Result := pcfUltima;
end;


procedure TNotaAmbienteToList(const AList : TStrings);
var
  I: TNotaAmbiente;
begin
  for I := Low(TNotaAmbiente) to High(TNotaAmbiente) do
    AList.Add(TNotaAmbienteToString(I));
end;

function  TNotaAmbienteToString(const ATNotaAmbiente : TNotaAmbiente) : string;
begin
  case ATNotaAmbiente of
    ntaTeste       : Result := 'Teste';
    ntaProducao    : Result := 'Produtcao';
    ntaHomologacao : Result := 'Homologacao';
  end;
end;

function  TNotaAmbienteFromString(const ATNotaAmbiente : string) : TNotaAmbiente;
begin
  Result := ntaTeste;
  if ATNotaAmbiente = 'Teste' then
    Result := ntaTeste;
  if ATNotaAmbiente = 'Produtcao' then
    Result := ntaProducao;
  if ATNotaAmbiente = 'Homologacao' then
    Result := ntaHomologacao;
end;


procedure TPVTipoRegimeTributarioToList(const AList : TStrings);
var
  I: TPVTipoRegimeTributario;
begin
  for I := Low(TPVTipoRegimeTributario) to High(TPVTipoRegimeTributario) do
    AList.Add(TPVTipoRegimeTributarioToString(I));
end;

function  TPVTipoRegimeTributarioToString(const ATPVTipoRegimeTributario : TPVTipoRegimeTributario) : string;
begin
  Result := '';
  case ATPVTipoRegimeTributario of
    trtSimplesNacional       : Result := 'Simples Nacional';
    trtSimplesExcessoReceita : Result := 'Simples Nacional (Excesso)';
    trtRegimeNormal          : Result := 'Regime Normal';
  end;
end;

function  TPVTipoRegimeTributarioFromString(const ATPVTipoRegimeTributario : string) : TPVTipoRegimeTributario;
begin
  Result := trtSimplesNacional;
  if ATPVTipoRegimeTributario = 'Simples Nacional' then
    Result := trtSimplesNacional
  else if ATPVTipoRegimeTributario = 'Simples Nacional (Excesso)' then
    Result := trtSimplesExcessoReceita
  else if ATPVTipoRegimeTributario = 'Regime Normal' then
    Result := trtRegimeNormal;
end;


procedure TPVSituacaoTributariaToList(const AList : TStrings);
begin
  AList.Clear;
  AList.Add('00 - TRIBUTAÇÃO NORMAL DO ICMS');
  AList.Add('10 - TRIBUTAÇÃO COM COBRANÇA DO ICMS POR SUBST. TRIBUTÁRIA');
  AList.Add('20 - TRIBUTAÇÃO COM REDUÇÃO DE BC DO ICMS');
  AList.Add('30 - TRIBUTAÇÃO ISENTA E COM COBRANÇA DO ICMS POR SUBST. TRIBUTÁRIA');
  AList.Add('40 - ICMS ISENÇÃO');
  AList.Add('41 - ICMS NÃO TRIBUTADO');
  AList.Add('45 - ICMS ISENTO, NÃO TRIBUTADO OU DIFERIDO');
  AList.Add('50 - ICMS SUSPENSÃO');
  AList.Add('51 - ICMS DIFERIDO');
  AList.Add('60 - ICMS COBRADO ANTERIORMENTE POR SUBSTITUIÇÃO TRIBUTÁRIA');
  AList.Add('70 - TRIBUTAÇÃO COM REDUÇÃO DE BC E COBRANÇA DO ICMS POR SUBST. TRIBUTÁRIA');
  AList.Add('80 - RESPONSABILIDADE DO RECOLHIMENTO DO ICMS ATRIBUÍDO AO TOMADOR OU 3° POR ST');
  AList.Add('81 - ICMS DEVIDO À OUTRA UF');
  AList.Add('90 - ICMS OUTROS');
//  AList.Add('90 - ICMS DEVIDO A UF DE ORIGEM DA PRESTACAO, QUANDO DIFERENTE DA UF DO EMITENTE');
//  AList.Add('SN - SIMPLES NACIONAL');
end;

function TPVSituacaoTributariaFromString(const ACST : string) : Integer;
begin
  Result := StrToIntDef(Copy(ACST, 1, 2), 90);
end;


procedure TPVSituacaoTributariaSimplesToList(const AList : TStrings);
begin
  AList.Clear;
  AList.Add('101- Tributada pelo Simples Nacional com permissão de crédito.');
  AList.Add('102- Tributada pelo Simples Nacional sem permissão de crédito.');
  AList.Add('103- Isenção do ICMS no Simples Nacional para faixa de receita bruta.');
  AList.Add('201- Tributada pelo Simples Nacional com permissão de crédito e com cobrança do ICMS por Substituição Tributária.');
  AList.Add('202- Tributada pelo Simples Nacional sem permissão de crédito e com cobrança do ICMS por Substituição Tributária.');
  AList.Add('203- Isenção do ICMS nos Simples Nacional para faixa de receita bruta e com cobrança do ICMS por Substituição Tributária.');
  AList.Add('300- Imune.');
  AList.Add('400- Não tributada pelo Simples Nacional.');
  AList.Add('500- ICMS cobrado anteriormente por substituição tributária (substituído) ou por antecipação.');
  AList.Add('900- Outros.');
end;

function  TPVSituacaoTributariaSimplesFromString(const ACSOSN : string) : Integer;
begin
  Result := StrToIntDef(Copy(ACSOSN, 1, 3), 900);
end;

(*
{ TLmxListagens }


procedure TLmxListagens.AddFilho(const ATipoFilho: TLmxListagemTipoBase; out AFilho);
begin
  TLmxListagemTipoBase(AFilho) := ATipoFilho;
  FListagens.Add(ATipoFilho);
end;

constructor TLmxListagens.Create;
begin
  FListagens := TObjectList.Create;
  AddFilho(TLmxListagemTipoNotaVersaoDocumento, FNotaVersaoDocumento);
  AddFilho(TLmxListagemTipoPDVRegimeTributario, FPDVRegimeTributario);
end;

destructor TLmxListagens.Destroy;
begin
  FreeAndNil(FListagens);
  inherited;
end;

{ TLmxListagemTipoPDVRegimeTributario }

function TLmxListagemTipoPDVRegimeTributario.FromString(
  const AItem: string): TPVTipoRegimeTributario;
begin

end;

procedure TLmxListagemTipoPDVRegimeTributario.ToList(const AList: TStrings);
begin
  inherited;

end;

function TLmxListagemTipoPDVRegimeTributario.ToString(
  const AItem: TPVTipoRegimeTributario): string;
begin

end;

initialization
  FPDVListagens := TLmxListagens.Create;
finalization
  FreeAndNil(FPDVListagens);
        *)
end.
