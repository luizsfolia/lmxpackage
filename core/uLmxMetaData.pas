unit uLmxMetaData;

interface

uses
  Classes, RTTI, uLmxAttributes, TypInfo, {$IFDEF VER270}
  System.SysUtils, System.Generics.Collections{$ELSE}SysUtils, Generics.Collections{$ENDIF},
  uLmxConexao, uLmxExceptions, uLmxDataSet, IOUtils, uLmxCore, uLmxInterfaces, uLmxInterfacesRegister;

type

  TLmxTipoAlteracao = (taInserirTabela, taAlterarTabela, taInserirCampo, taAlterarCampo,
    taInserirChavePrimaria, taInserirChaveEstrangeira, taInserirIndice, taInserirSequenciador);
  TLmxOnAlteracaoDataBaseEvent = procedure (const ATabela : string; const AAlteracoes : string) of object;
  TLmxOnAlteracaoDataBaseRef = reference to procedure (const ATabela : string; const AAlteracoes : string);
//  TLmxOnObterEstruturaDataBaseEvent = procedure (const AClasses : Boolean; const ATipo : TLmxTipoAlteracao;
//    const ATabela : string; const AAlteracoes : string) of object;

  TLmxMetadataAlteracao = class
  private
    FDescricao: string;
    FTabela: string;
    FCampo: string;
    FTipo: TLmxTipoAlteracao;
    FScript: string;
  public
    property Tabela : string read FTabela write FTabela;
    property Campo : string read FCampo write FCampo;
    property Tipo : TLmxTipoAlteracao read FTipo write FTipo;
    property Descricao : string read FDescricao write FDescricao;
    property Script : string read FScript write FScript;

    procedure CopyFrom(const AAlteracao : TLmxMetadataAlteracao);
  end;

  TLmxMetadataAlteracoes = class(TObjectList<TLmxMetadataAlteracao>)
  private
    function GetMaiorIndiceInserirTabelaOuCampo : Integer;
  public
    function NovaAlteracao(const ATipo : TLmxTipoAlteracao; const ATabela, ACampo : string;
      const AScript : string; const ADescricao : string = '') : TLmxMetadataAlteracao;

    procedure CopyFrom(const AAlteracoes : TLmxMetadataAlteracoes);
    function ToString: string; override;

  end;

  TLmxMetadataReferencia = class
  private
    FTabela: string;
    FCampo: string;
  public
    property Tabela : string read FTabela write FTabela;
    property Campo : string read FCampo write FCampo;
  end;

  TLmxMetadataCampo = class
  private
    FNome: string;
    FNotNull: Boolean;
    FTipo: TLmxMetadataTipoCampo;
    FReferencia: TLmxMetadataReferencia;
    FPrimaryKey: Boolean;
    FDecimais: Integer;
    FTamanho: Integer;
    FPossuiReferencia: Boolean;
    FTabela: string;
    FConexao : TLmxConexao;
  public
    constructor Create(const ATabela : string);
    destructor Destroy; override;

    property Tabela : string read FTabela;
    property Nome : string read FNome write FNome;
    property Tipo : TLmxMetadataTipoCampo read FTipo write FTipo;
    property NotNull : Boolean read FNotNull write FNotNull;
    property PrimaryKey : Boolean read FPrimaryKey write FPrimaryKey;
    property PossuiReferencia : Boolean read FPossuiReferencia write FPossuiReferencia;
    property Referencia : TLmxMetadataReferencia read FReferencia write FReferencia;
    property Tamanho : Integer read FTamanho write FTamanho;
    property Decimais : Integer read FDecimais write FDecimais;

    procedure SetTipoCampoFromString(const ATipo : string; const ATamanho, ADecimais : Integer);
    function GetTipoCampoAsString : string;
    function GetScriptCriacao(const ANomeTabela : string) : string;
    function GetScriptAlteracao(const ANomeTabela : string) : string;

    procedure SetConexao(const AConexao : TLmxConexao);
    function GetConexao : TLmxConexao;

    function FromScriptCriacao(const AScript : string) : Boolean;
  end;

  TLmxMetadataCampos = class(TObjectList<TLmxMetadataCampo>)
  private
    FConexao : TLmxConexao;
  public
    procedure SetConexao(const AConexao : TLmxConexao);
    function GetConexao : TLmxConexao;

    function GetScriptCriacao : string;

    function PorNomeCampo(const ANomeCampo : string) : TLmxMetadataCampo;

    procedure FromScriptCriacao(const ATabela, AScriptCriacao : string);
  end;

  TLmxMetadataIndice = class
  private
    FAtivo: Boolean;
    FTabela: string;
    FCampos: string;
    FUnico: Boolean;
    FNome: string;
  public
    constructor Create(const ATabela : string);

    property Tabela : string read FTabela;
    property Nome : string read FNome write FNome;
    property Campos : string read FCampos write FCampos;
    property Ativo : Boolean read FAtivo write FAtivo;
    property Unico : Boolean read FUnico write FUnico;
  public
//    function GetScriptCriacao : string;
    function GetScriptAtivarIndice(const AAtivar : Boolean = True) : string;
//    function GetScriptApagar : string;
  end;

  TLmxMetadataIndices = class(TObjectList<TLmxMetadataIndice>)
  public
    function Novo(const ATabela, ANome, ACampos : string) : TLmxMetadataIndice;
//    function GetScriptCriacao : string;
    function PorNome(const ANome : string) : TLmxMetadataIndice;
  end;

  TLmxMetadataSequenciador = class
  private
    FTabela: string;
    FCampo: string;
    FNome: string;
  public
    constructor Create(const ATabela : string);

    property Tabela : string read FTabela;
    property Nome : string read FNome write FNome;
    property Campo : string read FCampo write FCampo;
  public
//    function GetScriptCriacao : string;
//    function GetScriptAtivarIndice(const AAtivar : Boolean = True) : string;
//    function GetScriptApagar : string;
  end;

  TLmxMetadataSequenciadores = class(TObjectList<TLmxMetadataSequenciador>)
  public
    function Novo(const ATabela, ANome, ACampo : string) : TLmxMetadataSequenciador;
//    function GetScriptCriacao : string;
    function PorNome(const ANome : string) : TLmxMetadataSequenciador;
  end;

  TLmxMetadataTabela = class
  private
    FConexao: TLmxConexao;
    FNome: string;
    FCampos: TLmxMetadataCampos;
    FIndices: TLmxMetadataIndices;
    FSequenciadores: TLmxMetadataSequenciadores;
  public
    constructor Create(const ANome : string);
    destructor Destroy; override;

    property Nome : string read FNome;
    property Campos : TLmxMetadataCampos read FCampos;
    property Indices : TLmxMetadataIndices read FIndices;
    property Sequenciadores : TLmxMetadataSequenciadores read FSequenciadores;

    procedure SetConexao(const AConexao : TLmxConexao);
    function GetConexao : TLmxConexao;

    function GetScriptCriacao : string;
    procedure AddScriptCriacao(const AAlteracoes : TLmxMetadataAlteracoes);
    procedure AddScriptCriacaoChavesPrimarias(const AAlteracoes : TLmxMetadataAlteracoes);
    procedure AddScriptCriacaoChavesEstrangeiras(const AAlteracoes : TLmxMetadataAlteracoes);
    procedure AddScriptCriacaoIndices(const AAlteracoes : TLmxMetadataAlteracoes);
    procedure AddScriptCriacaoSequenciadores(const AAlteracoes : TLmxMetadataAlteracoes);

    procedure FromScriptCriacao(const AScriptCriacao : string);

  end;

  TLmxMetadataTabelas  = class(TObjectDictionary<String, TLmxMetadataTabela>)
  private
    FConexao : TLmxConexao;
  public
    function GetScriptCriacao : string;

    procedure SetConexao(const AConexao : TLmxConexao);
    function GetConexao : TLmxConexao;

    function Adicionar(const ANomeTabela : string; out ATabela : TLmxMetadataTabela) : Boolean;
  end;

  TLmxMetadataContext = class
  private
    FTabelas :  TLmxMetadataTabelas;
    FConexao : TLmxConexao;
  public
    constructor Create;
    destructor Destroy; override;

    property Tabelas : TLmxMetadataTabelas read FTabelas;

    procedure SetConexao(const AConexao : TLmxConexao);
    function GetConexao : TLmxConexao;

    function GetScriptCriacao : string;
  end;

  TLmxMetadata = class
  private
    FContexto: TRttiContext;
    FExecutarNoBancoDeDados: Boolean;
    FTabelasExecutadas : TList<string>;
    FOnAlteracaoDataBaseEvent: TLmxOnAlteracaoDataBaseEvent;
    FTelaDataBase: ILmxDataBaseAtualizadorView;
    FConexao: TLmxConexao;
    FOnAlteracaoDataBaseRef: TLmxOnAlteracaoDataBaseRef;
    procedure AtualizarTela(const AMensagem : string);
    procedure FecharTela;
    procedure AlteracaoDataBaseEvent(const ATabela, AAlteracoes : string);
    function GetConexao : TLmxConexao;
    function DatabaseExiste : Boolean;
    function TabelaExiste(const ANomeTabela : string) : Boolean;
//    function CampoExiste(const ANomeTabela, ANomeCampo : string) : Boolean;
    procedure ObterDadosDaClasse(const AObjeto: TClass; out ANomeTabela : string;
     out ACampoPk : string);
    function ExecutarScript(const AScript : string) : Boolean;
    function ExecutarDirectScript(const AScript : string) : Boolean;
    procedure MetadataCriarDataBase(const ADataBase : string);
    procedure MetadataCriarTabela(const ATabela : string; const ACampos : TLmxMetadataCampos);
//    function Criar(const AObjeto: TObject) : Boolean;
    procedure AdicionarCamposCalculadosTabela(const ANomeTabela : string; const AAtributos : TArray<TCustomAttribute>;
      const ACampos : TLmxMetadataCampos);
    procedure AdicionarIndicesTabela(const ANomeTabela : string; const AAtributos : TArray<TCustomAttribute>;
      const AIndices : TLmxMetadataIndices);
    procedure CriarSequenciadoresTabela(const ANomeTabela : string; const AAtributos : TArray<TCustomAttribute>;
      const ASequenciadores : TLmxMetadataSequenciadores);

    function CarregarInformacoesChavesPrimariasDataBase(const ATabela : TLmxMetadataTabela) : Boolean;
    function CarregarInformacoesChavesEstrangeirasDataBase(const ATabela : TLmxMetadataTabela) : Boolean;
    function CarregarInformacoesTabelaDataBase(const ANomeTabela : string; const ATabela : TLmxMetadataTabela) : Boolean;
    function CarregarInformacoesIndicesDataBase(const ATabela : TLmxMetadataTabela) : Boolean;
    function CarregarInformacoesSequenciadoresDataBase(const ATabela : TLmxMetadataTabela) : Boolean;
    function CarregarInformacoesDataBase(const AEstruturaClasses : TLmxMetadataContext) : Boolean;


    procedure ObterTamanhoCampo(const ATipoCampo : TLmxMetadataTipoCampo; out ATamanho, ADecimais : Integer);
    function ObterInformacoesTabela(const ANomeTabela : string; const ANomePropriedade : string; const AAtributos : TArray<TCustomAttribute>;
      out ACampo : TLmxMetadataCampo) : Boolean;
    function ObterInformacoesCampo(const ANomeTabela : string; const AProperty : TRttiProperty; out ACampo : TLmxMetadataCampo;
      const AValidarInfoBanco : Boolean = False) : Boolean;
//    function CriarCampo(const AProperty : TRttiProperty; out ACampo : TLmxMetadataCampo) : Boolean;
    function Criar(const AObjeto: TClass) : Boolean;

    function CamposDiferentes(const ACampoOrigem, ACampoDestino : TLmxMetadataCampo) : Boolean;
    function PermiteAlterarCampo(const ACampoOrigem, ACampoDestino : TLmxMetadataCampo) : Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure IniciarCriacao;
    procedure ConcluirCriacao;

    procedure CriarDataBase(const ADataBase : string = '');
    procedure CriarTabela<T : TBase, constructor>(const AClasse: T); overload;
    procedure CriarTabela(const AClasse: TClass); overload;

    procedure CriarTabelasRegistradas;
    function AtualizarTabelasRegistradas : Boolean;
    function TemTelaRegistrada : Boolean;

    procedure SetConexao(const AConexao : TLmxConexao);

    function ObterEstruturaClasses(out AEstruturaClasses : TLmxMetadataContext) : Boolean;
    function ObterEstruturaDataBase(out AEstruturaDataBase : TLmxMetadataContext) : Boolean;
    function ObterScriptMerge(const AEstruturaOrigem, AEstruturaDestino : TLmxMetadataContext;
      const AScriptsMerge : TLmxMetadataAlteracoes) : Boolean;

//    property Conexao : TLmxConexao read FConexao write FConexao;
    property ExecutarNoBancoDeDados : Boolean read FExecutarNoBancoDeDados write FExecutarNoBancoDeDados;
    property OnAlteracaoDataBaseEvent : TLmxOnAlteracaoDataBaseEvent read FOnAlteracaoDataBaseEvent write FOnAlteracaoDataBaseEvent;
//    property OnObterEstruturaDataBaseEvent : TLmxOnObterEstruturaDataBaseEvent read FOnObterEstruturaDataBaseEvent write FOnObterEstruturaDataBaseEvent;

    procedure SetOnAlteracaoDataBaseRef(const pOnAlteracaoDataBaseRef : TLmxOnAlteracaoDataBaseRef);
  end;

  function LmxMetadata : TLmxMetadata;


implementation

var
  FLmxMetadata : TLmxMetadata;

function LmxMetadata : TLmxMetadata;
begin
  Result := FLmxMetadata;
end;

{ TLmxMetadata }

procedure TLmxMetadata.AdicionarCamposCalculadosTabela(
  const ANomeTabela : string;
  const AAtributos: TArray<TCustomAttribute>;
  const ACampos: TLmxMetadataCampos);
var
  lFieldAtribute: TCustomAttribute;
  lCampo: TLmxMetadataCampo;

  procedure SetTamanhoCampo(const ACampo : TLmxMetadataCampo);
  var
    lTamanho : Integer;
    lDecimais: Integer;
  begin
    if ACampo.Tamanho = 0 then
    begin
      ObterTamanhoCampo(ACampo.Tipo, lTamanho, lDecimais);

      ACampo.Tamanho := lTamanho;
      ACampo.Decimais := lDecimais;
    end;
  end;

begin
  for lFieldAtribute in AATributos do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataCalculado.ClassName) then
    begin
      lCampo := TLmxMetadataCampo.Create(ANomeTabela);
      lCampo.Nome := TLmxAttributeMetadata(lFieldAtribute)
        .NomeCampo;
      lCampo.Tipo := TLmxAttributeMetadata(lFieldAtribute)
        .TipoCampo;
      lCampo.NotNull := TLmxAttributeMetadata(lFieldAtribute)
        .NotNull;
      lCampo.Tamanho := TLmxAttributeMetadata(lFieldAtribute)
        .Tamanho;
      lCampo.Decimais := TLmxAttributeMetadata(lFieldAtribute)
        .Decimais;
      SetTamanhoCampo(lCampo);
      ACampos.Add(lCampo);
    end;
  end;
end;

procedure TLmxMetadata.AdicionarIndicesTabela(const ANomeTabela: string;
  const AAtributos: TArray<TCustomAttribute>;
  const AIndices: TLmxMetadataIndices);
var
  lFieldAtribute: TCustomAttribute;
  lIndice: TLmxMetadataIndice;
begin
  for lFieldAtribute in AATributos do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataIndex.ClassName) then
    begin
      lIndice := TLmxMetadataIndice.Create(ANomeTabela);
      lIndice.Nome := TLmxAttributeMetadataIndex(lFieldAtribute)
        .Nome;
      lIndice.Campos := TLmxAttributeMetadataIndex(lFieldAtribute)
        .Campos;
      lIndice.Unico := False;
      lIndice.Ativo := True;
      AIndices.Add(lIndice);
    end;
  end;
end;

procedure TLmxMetadata.AlteracaoDataBaseEvent(const ATabela,
  AAlteracoes: string);
begin
  if Assigned(FOnAlteracaoDataBaseRef) then
    FOnAlteracaoDataBaseRef(ATabela, AAlteracoes)
  else
    if Assigned(FOnAlteracaoDataBaseEvent) then
      FOnAlteracaoDataBaseEvent(ATabela, AAlteracoes);

  AtualizarTela(ATabela + ' - ' + AAlteracoes);
  if FTelaDataBase <> nil then
    FTelaDataBase.NovaAlteracao(ATabela + ' - ' + AAlteracoes);
end;

function TLmxMetadata.AtualizarTabelasRegistradas: Boolean;
var
  lContextMetadata: TLmxMetadataContext;
  lContextMetadataDataBase: TLmxMetadataContext;
  lScripts: TLmxMetadataAlteracoes;
  I: Integer;
begin
//  Result := False;
  AtualizarTela('Verificando Estrutura das classes...');
  ObterEstruturaClasses(lContextMetadata);
  AtualizarTela('Verificando Estrutura do Banco de Dados...');
  ObterEstruturaDataBase(lContextMetadataDataBase);
  lScripts := TLmxMetadataAlteracoes.Create;
  try
    if ObterScriptMerge(lContextMetadata, lContextMetadataDataBase, lScripts) then
    begin
      AtualizarTela('Executando...');
      for I := 0 to lScripts.Count - 1 do
      begin
        AlteracaoDataBaseEvent(lScripts[I].Tabela, lScripts[I].Descricao);
        if not ExecutarScript(lScripts[I].Script) then
          raise EPDVExceptionMetadata.Create(Format( 'Nao foi possivel rodar o script [%s] no banco de dados.', [lScripts[I].Descricao]));
        AtualizarTela('[Script] - ' + lScripts[I].Descricao + ' aplicado no banco de dados');
      end;
    end;
    Result := True;
    FecharTela;
  finally
    FreeAndNil(lScripts);
    FreeAndNil(lContextMetadata);
    FreeAndNil(lContextMetadataDataBase);
  end;
end;

procedure TLmxMetadata.AtualizarTela(const AMensagem: string);
begin
  if FTelaDataBase = nil then
  begin
    FTelaDataBase := uLmxInterfacesRegister.RegisterInterface.Tabelas.NewTelaDataBase;

    if FTelaDataBase <> nil then
      FTelaDataBase.Mostrar;
  end;

  if FTelaDataBase <> nil then
  begin
    FTelaDataBase.AtualizarTela(AMensagem);
  end;
end;

//function TLmxMetadata.CampoExiste(const ANomeTabela,
//  ANomeCampo: string): Boolean;
//var
//  lConexao: string;
//  lConsulta: TLmxDataSet;
//begin
//  Result := False;
//  lConexao := GetConexao.ControleConexao.DataBase;
//  if GetConexao.NovaConsulta(GetConexao.GetScriptCampoExiste( lConexao, ANomeTabela, ANomeCampo), lConsulta) then
//  begin
//    try
//      Result := lConsulta.RecordCount > 0;
//    finally
//      FreeAndNil(lConsulta);
//    end;
//  end;
//end;

function TLmxMetadata.CamposDiferentes(const ACampoOrigem,
  ACampoDestino: TLmxMetadataCampo): Boolean;
begin
  Result := (ACampoOrigem.Tipo <> ACampoDestino.Tipo) or
    (ACampoOrigem.Tamanho <> ACampoDestino.Tamanho) or
    (ACampoOrigem.Decimais <> ACampoDestino.Decimais);
end;

procedure TLmxMetadata.ConcluirCriacao;
begin
  if FTabelasExecutadas <> nil then
    FreeAndNil(FTabelasExecutadas);
end;

constructor TLmxMetadata.Create;
begin
  FExecutarNoBancoDeDados := True;
//  FContexto := TRttiContext.Create;
end;

function TLmxMetadata.Criar(const AObjeto: TClass) : Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lClassePodeCriarTabela: Boolean;
  lNomeTabela: string;
  lCampos: TLmxMetadataCampos;
  lTabelaExiste: Boolean;
  lTabelaFK: string;
  lCampo: TLmxMetadataCampo;
begin

  IniciarCriacao;

  Result := False;

  lRttiType := FContexto.GetType(AObjeto);

  lNomeCampo := '';
  lNomeTabela := '';

  lClassAttributes := lRttiType.GetAttributes;
  lClassePodeCriarTabela := False;
  lTabelaExiste := False;
  lTabelaFK := EmptyStr;
  for lFieldAtribute in lClassAttributes do
  begin
    if (not lClassePodeCriarTabela) and (lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName)) then
    begin
      lNomeTabela := TLmxAttributeMetadata(lFieldAtribute).NomeCampo;
      if lNomeTabela = EmptyStr then
        lNomeTabela := Copy(AObjeto.ClassName, 2, Length(AObjeto.ClassName));
      lTabelaExiste := TabelaExiste(lNomeTabela);
    end;
  end;

  if (FTabelasExecutadas.IndexOf(lNomeTabela) <> -1) or lTabelaExiste then
  begin
    Result := True;
    Exit;
  end;

  if lNomeTabela <> EmptyStr then
  begin
    FTabelasExecutadas.Add(lNomeTabela);
    lClassePodeCriarTabela := not lTabelaExiste;
  end;

  if lClassePodeCriarTabela then
  begin
    lCampos := TLmxMetadataCampos.Create(True);
    try

      lRttiProperties := lRttiType.GetProperties;
      for lProperty in lRttiProperties do
      begin
        if ObterInformacoesCampo(lNomeTabela, lProperty, lCampo) then
          lCampos.Add(lCampo);
      end;
      AdicionarCamposCalculadosTabela(lNomeTabela, lClassAttributes, lCampos);
//      AdicionarIndicesTabela(lNomeTabela, lClassAttributes, lTabela.Indices);
      MetadataCriarTabela(lNomeTabela, lCampos);
      Result := True;
    finally
      FreeAndNil(lCampos);
    end;
  end;
end;

procedure TLmxMetadata.CriarDataBase(const ADataBase: string);
var
  lExecutarNoBanco: Boolean;
  lDataBase: string;
begin
  lExecutarNoBanco := FExecutarNoBancoDeDados;
  try
    FExecutarNoBancoDeDados := True;
    lDataBase := ADataBase;
    if ADataBase = '' then
      lDataBase := GetConexao.ControleConexao.DataBase;
    MetadataCriarDataBase(lDataBase);
  finally
    FExecutarNoBancoDeDados := lExecutarNoBanco;
  end;
end;

procedure TLmxMetadata.CriarSequenciadoresTabela(const ANomeTabela: string;
  const AAtributos: TArray<TCustomAttribute>;
  const ASequenciadores: TLmxMetadataSequenciadores);
var
  lFieldAtribute: TCustomAttribute;
  lSequenciador: TLmxMetadataSequenciador;
begin
  for lFieldAtribute in AATributos do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataSequence.ClassName) then
    begin
      lSequenciador := TLmxMetadataSequenciador.Create(ANomeTabela);
      lSequenciador.Nome := TLmxAttributeMetadataSequence(lFieldAtribute)
        .Nome;
      if lSequenciador.Nome = '' then
        lSequenciador.Nome := 'SEQ_' + ANomeTabela;
      lSequenciador.Campo := TLmxAttributeMetadataSequence(lFieldAtribute)
        .Campo;
      ASequenciadores.Add(lSequenciador);
    end;
  end;
end;

procedure TLmxMetadata.CriarTabela(const AClasse: TClass);
begin
  IniciarCriacao;
  Criar(AClasse);
end;

procedure TLmxMetadata.CriarTabela<T>(const AClasse: T);
var
  lClasse: T;
begin
  IniciarCriacao;
  lClasse := T.Create;
  try
    Criar(lClasse);
  finally
    FreeAndNil(lClasse);
  end;
end;

procedure TLmxMetadata.CriarTabelasRegistradas;
var
  lTabelas: TObjectDictionary<TClass, TLmxRegisterInfo>;
  lEnum : TObjectDictionary<TClass, TLmxRegisterInfo>.TPairEnumerator;
//  lTabelasCriadas : TObjectDictionary<TBaseClass, Boolean>;
begin
  IniciarCriacao;
  RegisterInterface.Tabelas.Listar(lTabelas);
  lEnum := lTabelas.GetEnumerator;
  try
    while lEnum.MoveNext do
      CriarTabela(lEnum.Current.Key);

  finally
    ConcluirCriacao;
    FreeAndNil(lEnum);
  end;
end;

function TLmxMetadata.DatabaseExiste: Boolean;
var
  lConexao: string;
begin
  lConexao := GetConexao.ControleConexao.DataBase;
  Result := GetConexao.DataBaseExiste(lConexao);
end;

destructor TLmxMetadata.Destroy;
begin
  ConcluirCriacao;
//  FContexto.Free;
  inherited;
end;

function TLmxMetadata.ExecutarDirectScript(const AScript: string): Boolean;
begin
  if AScript <> '' then
  begin
    if FExecutarNoBancoDeDados then
      GetConexao.ExecuteDirect(AScript);
    if Assigned(GetConexao.OnQueryExecute) then
      GetConexao.OnQueryExecute(teqExecuteDirect, AScript, '', 0);
    Result := True;
  end else begin
    Result := True;
  end;
end;

function TLmxMetadata.ExecutarScript(const AScript: string) : Boolean;
var
  lScripts: TStringList;
  I: Integer;
begin
  if AScript <> '' then
  begin
    if FExecutarNoBancoDeDados then
    begin
      lScripts := TStringList.Create;
      try
        GetConexao.GetScripts(AScript, lScripts);
        for I := 0 to lScripts.Count - 1 do
        begin
          GetConexao.Executar(lScripts[I]);
          if Assigned(GetConexao.OnQueryExecute) then
            GetConexao.OnQueryExecute(teqMetadata, AScript, '', 0);
        end;
      finally
        FreeAndNil(lScripts);
      end;
    end;
    Result := True;
  end else begin
    Result := True;
  end;
end;

procedure TLmxMetadata.FecharTela;
begin
  if FTelaDataBase <> nil then
  begin
    FTelaDataBase.Fechar;
    FTelaDataBase := nil;
  end;
end;

function TLmxMetadata.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

procedure TLmxMetadata.IniciarCriacao;
begin
  if FTabelasExecutadas = nil then
    FTabelasExecutadas := TList<string>.Create;
end;

function TLmxMetadata.ObterScriptMerge(const AEstruturaOrigem,
  AEstruturaDestino: TLmxMetadataContext; const AScriptsMerge : TLmxMetadataAlteracoes): Boolean;
var
  lEnumTabelas: TLmxMetadataTabelas.TPairEnumerator;
  lTabelaDestino: TLmxMetadataTabela;
  lTabelaOrigem: TLmxMetadataTabela;
  lEnumCampos: TLmxMetadataCampos.TEnumerator;
  lCampo: TLmxMetadataCampo;
  lCampoDestino: TLmxMetadataCampo;
  lEnumIndices: TLmxMetadataIndices.TEnumerator;
  lIndiceDestino: TLmxMetadataIndice;
  lIndiceOrigem: TLmxMetadataIndice;
  lEnumSequenciadores: TLmxMetadataSequenciadores.TEnumerator;
  lSequenciadorOrigem: TLmxMetadataSequenciador;
  lSequenciadorDestino: TLmxMetadataSequenciador;
begin
//  Result := False;
//  AScriptsMerge := TLmxMetadataAlteracoes.Create;
  lEnumTabelas := AEstruturaOrigem.Tabelas.GetEnumerator;
  try
    while lEnumTabelas.MoveNext do
    begin
      lTabelaOrigem := lEnumTabelas.Current.Value;
      lTabelaOrigem.SetConexao(GetConexao);
      if AEstruturaDestino.Tabelas.TryGetValue(UpperCase(lTabelaOrigem.Nome), lTabelaDestino) then
      begin
        lEnumIndices := lTabelaOrigem.Indices.GetEnumerator;
        try
          AtualizarTela('[Merge] - Validando Indices da tabela ' + lTabelaOrigem.Nome);
          while lEnumIndices.MoveNext do
          begin

            lIndiceOrigem := lEnumIndices.Current;
            lIndiceDestino := lTabelaDestino.Indices.PorNome(UpperCase(lIndiceOrigem.Nome));
            if lIndiceDestino = nil then
            begin
              AScriptsMerge.NovaAlteracao(taInserirIndice, UpperCase(lTabelaOrigem.Nome),
                UpperCase(lIndiceOrigem.Nome), GetConexao.GetScriptNovoIndice(lTabelaOrigem.Nome,
                  lIndiceOrigem.Nome, lIndiceOrigem.Campos),
                  Format('Criar indice [%s] na Tabela [%s]', [UpperCase(lIndiceOrigem.Nome), UpperCase(lTabelaOrigem.Nome)]));
              AtualizarTela('[Merge] - Índice ' + lIndiceOrigem.Nome + ' deve ser adicionado.');
            end;
          end;
        finally
          FreeAndNil(lEnumIndices);
        end;

        lEnumSequenciadores := lTabelaOrigem.Sequenciadores.GetEnumerator;
        try
          AtualizarTela('[Merge] - Validando Sequenciadores da tabela ' + lTabelaOrigem.Nome);
          while lEnumSequenciadores.MoveNext do
          begin

            lSequenciadorOrigem := lEnumSequenciadores.Current;
            lSequenciadorDestino := lTabelaDestino.Sequenciadores.PorNome(UpperCase(lSequenciadorOrigem.Nome));
//            lSequenciadorDestino := lTabelaDestino.Sequenciadores.PorNome(UpperCase('SEQ_' + lTabelaOrigem.Nome));
            if lSequenciadorDestino = nil then
            begin
              AScriptsMerge.NovaAlteracao(taInserirSequenciador, UpperCase(lTabelaOrigem.Nome),
                UpperCase(lSequenciadorOrigem.Nome), GetConexao.GetScriptNovoSequence(lTabelaOrigem.Nome,
                  lSequenciadorOrigem.Nome, lSequenciadorOrigem.Campo),
                  Format('Criar Sequenciador [%s] na Tabela [%s]', [UpperCase(lSequenciadorOrigem.Nome), UpperCase(lTabelaOrigem.Nome)]));
              AtualizarTela('[Merge] - Sequenciador ' + lSequenciadorOrigem.Nome + ' deve ser adicionado.');
            end;
          end;
        finally
          FreeAndNil(lEnumSequenciadores);
        end;


        lEnumCampos := lTabelaOrigem.Campos.GetEnumerator;
        try
          AtualizarTela('[Merge] - Validando Campos da tabela ' + lTabelaOrigem.Nome);
          while lEnumCampos.MoveNext do
          begin
            lCampo := lEnumCampos.Current;
            if (lCampo.PossuiReferencia) and (lCampo.Referencia.Tabela = '') then
              raise Exception.Create(Format('Campo [%s] na Tabela [%s] possui uma referencia para uma tabela nao registrada',
                      [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome)]));
            lCampoDestino := lTabelaDestino.Campos.PorNomeCampo(UpperCase(lCampo.Nome));
            if lCampoDestino = nil then
            begin
              AScriptsMerge.NovaAlteracao(taInserirCampo, UpperCase(lTabelaOrigem.Nome),
                UpperCase(lCampo.Nome), lCampo.GetScriptCriacao(UpperCase(lTabelaOrigem.Nome)),
                Format('Adicionar Campo [%s] na Tabela [%s]', [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome)]));
              AtualizarTela('[Merge] - Campo ' + lCampo.Nome + ' deve ser adicionado.');
            end else begin
              if CamposDiferentes(lCampo, lCampoDestino) then
              begin
                if PermiteAlterarCampo(lCampo, lCampoDestino) then
                begin
                  AScriptsMerge.NovaAlteracao(taInserirCampo, UpperCase(lTabelaOrigem.Nome),
                    UpperCase(lCampo.Nome), lCampo.GetScriptAlteracao(UpperCase(lTabelaOrigem.Nome)),
                    Format('Campo [%s] na Tabela [%s] alterado do Tipo (%s) para (%s)',
                      [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome), lCampoDestino.GetTipoCampoAsString, lCampo.GetTipoCampoAsString]));
                  AtualizarTela('[Merge] - Campo ' + lCampo.Nome + ' deve ser alterado o tipo.');
                end else begin
                  raise Exception.Create(Format('Não é possível alterar o campo [%s] na Tabela [%s]. De (%s) para (%s)' ,
                      [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome), lCampoDestino.GetTipoCampoAsString, lCampo.GetTipoCampoAsString]));
                end;
              end;
              if (lCampo.PrimaryKey and (not lCampoDestino.PrimaryKey)) then
              begin
                AScriptsMerge.NovaAlteracao(taInserirChavePrimaria, UpperCase(lTabelaOrigem.Nome),
                    UpperCase(lCampo.Nome),
                    GetConexao.GetScriptAdicionarChavePrimaria(lTabelaOrigem.Nome, lCampo.Nome),
                    Format('Adicionada Chave primaria para o campo [%s] na Tabela [%s]',
                      [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome)]));
                AtualizarTela('[Merge] - Nova Chave primária para a tabela ' + lTabelaOrigem.Nome);
              end;
              if (lCampo.PossuiReferencia and (not lCampoDestino.PossuiReferencia)) then
              begin
                AScriptsMerge.NovaAlteracao(taInserirChaveEstrangeira, UpperCase(lTabelaOrigem.Nome),
                    UpperCase(lCampo.Nome),
                    GetConexao.GetScriptAdicionarChaveEstrangeira(lTabelaOrigem.Nome, lCampo.Nome, lCampo.Referencia.Tabela,
                    lCampo.Referencia.Campo),
                    Format('Adicionada referencia [%s] na Tabela [%s]',
                      [UpperCase(lCampo.Nome), UpperCase(lTabelaOrigem.Nome)]));
                AtualizarTela('[Merge] - Nova Chave estrangeira para a tabela ' + lTabelaOrigem.Nome);
              end;
            end;
          end;
        finally
          FreeAndNil(lEnumCampos);
        end;
      end else begin
        lTabelaOrigem.AddScriptCriacao(AScriptsMerge);
        AtualizarTela('[Merge] - Tabela ' + lTabelaOrigem.Nome  + ' não existe' );
//        AScriptsMerge.NovaAlteracao(taInserirTabela, UpperCase(lTabelaOrigem.Nome),
//          '', lTabelaOrigem.GetScriptCriacao,
//          Format('Adicionar Tabela [%s]', [UpperCase(lTabelaOrigem.Nome)]));
      end;
    end;
    Result := AScriptsMerge.Count > 0;
  finally
    FreeAndNil(lEnumTabelas);
  end;
end;

procedure TLmxMetadata.ObterTamanhoCampo(
  const ATipoCampo: TLmxMetadataTipoCampo; out ATamanho, ADecimais: Integer);
begin
  ATamanho := 0;
  ADecimais := 0;
  case ATipoCampo of
    mtcInteger : ATamanho := 4;
    mtcChar    : ATamanho := 1;
    mtcVarchar : ATamanho := 20;
    mtcBoolean : ATamanho := 2;
    mtcDateTime: ATamanho := 8;
    mtcBlobText: ATamanho := 80;
    mtcNumeric :
      begin
        ATamanho := 15;
        ADecimais := 2;
      end;
  end;
end;

function TLmxMetadata.PermiteAlterarCampo(const ACampoOrigem,
  ACampoDestino: TLmxMetadataCampo): Boolean;
begin
  Result := CamposDiferentes(ACampoOrigem, ACampoDestino);
  if Result and (ACampoDestino.Tamanho > ACampoOrigem.Tamanho) then
    Result := False
  else if (ACampoDestino.Tipo = mtcVarchar) and (ACampoOrigem.Tipo = mtcInteger) then
    Result := False
  else if (ACampoDestino.Tipo = mtcNumeric) and (ACampoOrigem.Tipo = mtcInteger) then
    Result := False
  else if (ACampoDestino.Tipo = mtcDateTime) and (ACampoOrigem.Tipo = mtcInteger) then
    Result := False
  else if (ACampoDestino.Tipo = mtcBlobText) and (ACampoOrigem.Tipo <> mtcBlobText) then
    Result := False;
end;

procedure TLmxMetadata.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
end;

procedure TLmxMetadata.SetOnAlteracaoDataBaseRef(
  const pOnAlteracaoDataBaseRef: TLmxOnAlteracaoDataBaseRef);
begin
  FOnAlteracaoDataBaseRef := pOnAlteracaoDataBaseRef;
end;

procedure TLmxMetadata.MetadataCriarDataBase(const ADataBase: string);
var
  lLocalDataBase: string;
begin
  if not DatabaseExiste then
  begin
    AlteracaoDataBaseEvent(ADataBase, 'Criar DataBase');
    lLocalDataBase := ExtractFilePath(ADataBase);
    {$IFDEF VER270}
    if lLocalDataBase = '' then
      lLocalDataBase := TPath.Combine(TPath.GetDocumentsPath, TPath.GetFileName(ADataBase));
    {$ELSE}
    if lLocalDataBase = '' then
      lLocalDataBase := ExtractFilePath(ParamStr(0)) + '\' + TPath.GetFileName(ADataBase);
    {$ENDIF}

    ForceDirectories(lLocalDataBase);
    if not ExecutarDirectScript(GetConexao.GetScriptCriarDataBase(ADataBase)) then
      raise EPDVExceptionMetadata.Create('Nao foi possivel criar o banco de dados.');
  end;
end;

procedure TLmxMetadata.MetadataCriarTabela(const ATabela: string;
  const ACampos: TLmxMetadataCampos);
begin
  AlteracaoDataBaseEvent(ATabela, 'Criar Tabela');
  if not ExecutarScript(GetConexao.GetScriptGerarTabela(ATabela, ACampos.GetScriptCriacao)) then
    raise EPDVExceptionMetadata.Create(Format( 'Nao foi possivel criar a tabela %s no banco de dados.', [ATabela]));
end;

procedure TLmxMetadata.ObterDadosDaClasse(const AObjeto: TClass; out ANomeTabela : string;
     out ACampoPk : string);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lPrimaryKey: Boolean;
begin
  ACampoPk := EmptyStr;
  ANomeTabela := EmptyStr;

  lNomeCampo := EmptyStr;
  lRttiType := FContexto.GetType(AObjeto);

  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
    begin
      ANomeTabela := TLmxAttributeMetadata(lFieldAtribute).NomeCampo;
      if ANomeTabela = EmptyStr then
        ANomeTabela := Copy(AObjeto.ClassName, 2, Length(AObjeto.ClassName));
    end;
  end;

  lRttiProperties := lRttiType.GetProperties;
  for lProperty in lRttiProperties do
  begin
    lPrimaryKey := False;
    lFieldAtributes := lProperty.GetAttributes;
    for lFieldAtribute in lFieldAtributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
      begin
        lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
          .NomeCampo;
        if lNomeCampo = EmptyStr then
          lNomeCampo := lProperty.Name;
      end;
      if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataPrimaryKey.ClassName) then
        lPrimaryKey := True;
    end;
    if (lNomeCampo <> EmptyStr) and lPrimaryKey then
      ACampoPk := lNomeCampo;
  end;

end;

function TLmxMetadata.ObterEstruturaClasses(
  out AEstruturaClasses: TLmxMetadataContext): Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lNomeTabela: string;
//  lCampos: TLmxMetadataCampos;
  lTabelaFK: string;
  lCampo: TLmxMetadataCampo;

  lTabelas: TObjectDictionary<TClass, TLmxRegisterInfo>;
  lEnum : TObjectDictionary<TClass, TLmxRegisterInfo>.TPairEnumerator;
  lClasse: TClass;
  lTabela: TLmxMetadataTabela;

begin

  AEstruturaClasses := TLmxMetadataContext.Create;
  AEstruturaClasses.SetConexao(GetConexao);

  RegisterInterface.Tabelas.Listar(lTabelas);
  lEnum := lTabelas.GetEnumerator;
  try
    while lEnum.MoveNext do
    begin
      lClasse := lEnum.Current.Key;

      lRttiType := FContexto.GetType(lClasse);

      lNomeCampo := '';
      lNomeTabela := '';

      lClassAttributes := lRttiType.GetAttributes;
      lTabelaFK := EmptyStr;
      for lFieldAtribute in lClassAttributes do
      begin
        if (lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName)) then
        begin
          lNomeTabela := TLmxAttributeMetadata(lFieldAtribute).NomeCampo;
          if lNomeTabela = EmptyStr then
            lNomeTabela := Copy(lClasse.ClassName, 2, Length(lClasse.ClassName));
        end;
      end;

      AtualizarTela('[Classes] - Validando Tabela ' + lNomeTabela);
      if AEstruturaClasses.Tabelas.Adicionar(lNomeTabela, lTabela) then
      begin
        lRttiProperties := lRttiType.GetProperties;
        for lProperty in lRttiProperties do
        begin
          if ObterInformacoesCampo(lNomeTabela, lProperty, lCampo) then
          begin
            lTabela.Campos.Add(lCampo);
            if lCampo.PossuiReferencia then
            begin
              lTabela.Indices.Novo(lNomeTabela, 'IDX_' + lNomeTabela + '_' +
                Copy(lCampo.Referencia.Tabela, 1, 5), lCampo.Nome);
            end;
          end;
        end;
        AdicionarCamposCalculadosTabela(lTabela.Nome, lClassAttributes, lTabela.Campos);
        AdicionarIndicesTabela(lTabela.Nome, lClassAttributes, lTabela.Indices);
        CriarSequenciadoresTabela(lTabela.Nome, lClassAttributes, lTabela.Sequenciadores);
      end;
    end;
    Result := True;
  finally
    FreeAndNil(lEnum);
  end;
end;

function TLmxMetadata.ObterEstruturaDataBase(
  out AEstruturaDataBase: TLmxMetadataContext): Boolean;
begin
  AEstruturaDataBase := TLmxMetadataContext.Create;
  AEstruturaDataBase.SetConexao(GetConexao);
  Result := CarregarInformacoesDataBase(AEstruturaDataBase);
end;

function TLmxMetadata.ObterInformacoesCampo(const ANomeTabela : string; const AProperty: TRttiProperty;
  out ACampo: TLmxMetadataCampo; const AValidarInfoBanco : Boolean): Boolean;
var
  lTipoCampo: TLmxMetadataTipoCampo;
  lClasse: TClass;
  lCampoPkReferencia: string;
  lTabelaRefencia: string;

  procedure SetTamanhoCampo(const ATipoCampo : TLmxMetadataTipoCampo);
  var
    lTamanho : Integer;
    lDecimais: Integer;
  begin
    lTamanho := ACampo.Tamanho;
    lDecimais := ACampo.Decimais;

    if lTamanho = 0 then
    begin
      ObterTamanhoCampo(ATipoCampo, lTamanho, lDecimais);

      ACampo.Tamanho := lTamanho;
      ACampo.Decimais := lDecimais;
    end;
  end;

begin
  Result := False;
  if ObterInformacoesTabela(ANomeTabela, AProperty.Name, AProperty.GetAttributes, ACampo) then
  begin
    lTipoCampo := ACampo.Tipo;
    if lTipoCampo = mtcAuto then
    begin
      case AProperty.PropertyType.TypeKind of
        tkInteger      : lTipoCampo := mtcInteger;
        tkChar         : lTipoCampo := mtcChar;
        tkEnumeration  :
          begin
            lTipoCampo := mtcInteger;
            if AProperty.PropertyType.QualifiedName = 'System.Boolean' then
              lTipoCampo := mtcBoolean;
          end;
        tkFloat        :
          begin
            lTipoCampo := mtcNumeric;
            if AProperty.PropertyType.QualifiedName = 'System.TDateTime' then
              lTipoCampo := mtcDateTime;
          end;
        tkString       : lTipoCampo := mtcVarchar;
        tkWChar        : lTipoCampo := mtcChar;
        tkUString      : lTipoCampo := mtcVarchar;
        tkLString      : lTipoCampo := mtcVarchar;
        tkWString      : lTipoCampo := mtcVarchar;
        tkVariant      : lTipoCampo := mtcVarchar;
        tkInt64        : lTipoCampo := mtcInteger;
        tkArray        : lTipoCampo := mtcVarchar;
        tkDynArray     : lTipoCampo := mtcVarchar;
      end;
    end;

//    SetTamanhoCampo(lTipoCampo);

//    lTamanho := ACampo.Tamanho;
//    lDecimais := ACampo.Decimais;
//    if lTamanho = 0 then
//    begin
//      case lTipoCampo of
//        mtcInteger : lTamanho := 4;
//        mtcChar    : lTamanho := 1;
//        mtcVarchar : lTamanho := 20;
//        mtcDateTime: lTamanho := 8;
//        mtcNumeric :
//          begin
//            lTamanho := 15;
//            lDecimais := 2;
//          end;
//      end;
//    end;
//    ACampo.Tamanho := lTamanho;
//    ACampo.Decimais := lDecimais;

    ACampo.Tipo := lTipoCampo;

    if (AProperty.PropertyType.TypeKind = tkClass) then
    begin
      if ACampo.PossuiReferencia then
      begin
        lClasse := RegisterInterface.Tabelas.GetAsClassOf(AProperty.PropertyType.Name);
        if lClasse <> nil then
        begin
          if not Criar(lClasse) then
            Exit;
          ObterDadosDaClasse(lClasse,
            lTabelaRefencia, lCampoPkReferencia);
          ACampo.Nome := ACampo.Nome + '_Id';
          ACampo.Tipo := mtcInteger;
          ACampo.NotNull := False;
          ACampo.Referencia.Tabela := lTabelaRefencia;
          ACampo.Referencia.Campo := lCampoPkReferencia;
        end;
      end else begin
        if ACampo.Tipo = mtcAuto then
          ACampo.Tipo := mtcInteger;
      end;
    end;

    SetTamanhoCampo(ACampo.Tipo);

    Result := True;
  end;
end;

function TLmxMetadata.CarregarInformacoesChavesEstrangeirasDataBase(
  const ATabela: TLmxMetadataTabela): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
  lCampo: TLmxMetadataCampo;
  lSql: string;

  procedure ValidarCampo(const ACampo : string);
  begin
    try
      lConsulta.FieldByName(ACampo);
    except on E:Exception do
      raise Exception.Create('Campo ' + ACampo + ' não encontrado na consulta de informações de Chaves Estrangeiras da Tabela ' + ATabela.Nome);
    end;
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo('TabelaRaiz');
    ValidarCampo('TabelaEstrangeira');
    ValidarCampo('CampoRaiz');
    ValidarCampo('CampoEstrangeiro');
  end;

begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  lSql := GetConexao.GetScriptObterInfoChaveEstrangeira( lConexao, ATabela.Nome);
  if (lSql <> '') and (GetConexao.NovaConsulta(GetConexao.GetScriptObterInfoChaveEstrangeira( lConexao, ATabela.Nome), lConsulta)) then
  begin
    try
      ValidarCampos;

      while not lConsulta.Eof do
      begin
        lCampo := ATabela.Campos.PorNomeCampo(Trim(lConsulta.FieldByName('CampoRaiz').AsString));
        if lCampo <> nil then
        begin
          lCampo.Referencia.Tabela := Trim(lConsulta.FieldByName('TabelaEstrangeira').AsString);
          lCampo.Referencia.Campo := Trim(lConsulta.FieldByName('CampoEstrangeiro').AsString);
          lCampo.PossuiReferencia := True;
        end;
        lConsulta.Next;
      end;
    finally
      FreeAndNil(lConsulta);
    end;
  end;
end;

function TLmxMetadata.CarregarInformacoesChavesPrimariasDataBase(
  const ATabela: TLmxMetadataTabela): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
  lCampo: TLmxMetadataCampo;
  lSql: string;

  procedure ValidarCampo(const ACampo : string);
  begin
    try
      lConsulta.FieldByName(ACampo);
    except on E:Exception do
      raise Exception.Create('Campo ' + ACampo + ' não encontrado na consulta de informações de Chaves Primarias da Tabela ' + ATabela.Nome);
    end;
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo('NomeCampo');
  end;

begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  lSql := GetConexao.GetScriptObterInfoChavePrimaria( lConexao, ATabela.Nome);
  if (lSql <> '') and (GetConexao.NovaConsulta(lSql, lConsulta)) then
  begin
    try
      ValidarCampos;

//      if (lConsulta.FindField('SchemaTabela') <> nil) then
//      begin
//        lConsulta.First;
//        while not lConsulta.Eof do
//        begin
//          lSchemaTabela := lConsulta.FieldByName('SchemaTabela').AsString;
//          ATabela.FromScriptCriacao(lSchemaTabela);
//          lConsulta.Next;
//        end;
//      end else begin
        while not lConsulta.Eof do
        begin
          lCampo := ATabela.Campos.PorNomeCampo(Trim(lConsulta.FieldByName('NomeCampo').AsString));
          if lCampo <> nil then
            lCampo.PrimaryKey := True;
          lConsulta.Next;
        end;
//      end;
    finally
      FreeAndNil(lConsulta);
    end;
  end;
end;

function TLmxMetadata.CarregarInformacoesDataBase(
  const AEstruturaClasses : TLmxMetadataContext): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
  lTabela: TLmxMetadataTabela;
  lNomeCampo: string;

  procedure ValidarCampo(const ACampo : string);
  begin
    try
      lConsulta.FieldByName(ACampo);
    except on E:Exception do
      raise Exception.Create('Campo ' + ACampo + ' não encontrado na consulta de informações do DataBase');
    end;
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo(lNomeCampo);
  end;

begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  if GetConexao.NovaConsulta(GetConexao.GetScriptObterInfoDataBase( lConexao, lNomeCampo ), lConsulta) then
  begin
    try
      ValidarCampos;

      while not lConsulta.Eof do
      begin
        if AEstruturaClasses.Tabelas.Adicionar(Trim(lConsulta.FieldByName(lNomeCampo).AsString), lTabela) then
        begin
          AtualizarTela('[DataBase] - Validando Tabela ' + lTabela.Nome);
          CarregarInformacoesTabelaDataBase(Trim(lConsulta.FieldByName(lNomeCampo).AsString), lTabela);
          CarregarInformacoesChavesPrimariasDataBase(lTabela);
          CarregarInformacoesChavesEstrangeirasDataBase(lTabela);
          CarregarInformacoesIndicesDataBase(lTabela);
          CarregarInformacoesSequenciadoresDataBase(lTabela);
        end;
        lConsulta.Next;
      end;
    finally
      FreeAndNil(lConsulta);
    end;
  end;
end;

function TLmxMetadata.CarregarInformacoesIndicesDataBase(
  const ATabela: TLmxMetadataTabela): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
  lIndice: TLmxMetadataIndice;
  lNomeIndice: string;
  lCamposIndice: string;
  lSql: string;

  procedure ValidarCampo(const ACampo : string);
  begin
    try
      lConsulta.FieldByName(ACampo);
    except on E:Exception do
      raise Exception.Create('Campo ' + ACampo + ' não encontrado na consulta de informações de indices ');
    end;
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo('Nome');
    ValidarCampo('Tabela');
    ValidarCampo('Ativo');
    ValidarCampo('Unico');
  end;

  function ObterCamposIndiceFromSchema(const AIndice : string) : string;
  begin
    Result := GetConexao.GetScriptObterInfoCamposIndice( lConexao, AIndice);
  end;

  function ObterCamposIndice(const AIndice : string) : string;
  var
    lConsultaCampos: TLmxDataSet;
    lCampos: string;
  begin
    if GetConexao.NovaConsulta(GetConexao.GetScriptObterInfoCamposIndice( lConexao, AIndice), lConsultaCampos) then
    begin
      try
        lCampos := '';
        while not lConsultaCampos.Eof do
        begin
          if lCampos <> '' then
            lCampos := lCampos + ',';
          lCampos := lCampos + Trim(lConsultaCampos.FieldByName('Nome').AsString);
          lConsultaCampos.Next;
        end;
        REsult := lCampos;
      finally
        FreeAndNil(lConsultaCampos);
      end;
    end;
  end;

begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  lSql := GetConexao.GetScriptObterInfoIndices( lConexao, ATabela.Nome);
  try
    if (lSql <> '') and (GetConexao.NovaConsulta(lSql, lConsulta)) then
    begin
      try
        ValidarCampos;

        while not lConsulta.Eof do
        begin
          lNomeIndice := Trim(lConsulta.FieldByName('Nome').AsString);

          if lConsulta.FindField('SchemaIndex') <> nil then
            lCamposIndice := ObterCamposIndiceFromSchema(lConsulta.FindField('SchemaIndex').AsString)
          else
            lCamposIndice := ObterCamposIndice(lNomeIndice);
          lIndice := ATabela.Indices.Novo(ATabela.Nome, lNomeIndice, lCamposIndice);
          lIndice.Unico := lConsulta.FieldByName('Unico').AsInteger > 0;
          lIndice.Ativo := lConsulta.FieldByName('Ativo').AsInteger = 1;

          lConsulta.Next;
        end;
      finally
        FreeAndNil(lConsulta);
      end;
    end;
  except

  end;
end;

function TLmxMetadata.CarregarInformacoesSequenciadoresDataBase(
  const ATabela: TLmxMetadataTabela): Boolean;
var
  lConexao: string;
  lSql: string;
  lConsulta: TLmxDataSet;
  lNomeSequenciador: string;
//  lSequenciador: TLmxMetadataSequenciador;

  procedure ValidarCampo(const ACampo : string);
  begin
    try
      lConsulta.FieldByName(ACampo);
    except on E:Exception do
      raise Exception.Create('Campo ' + ACampo + ' não encontrado na consulta de informações de sequenciais ');
    end;
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo('Nome');
    ValidarCampo('Tabela');
  end;

begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  lSql := GetConexao.GetScriptObterInfoSequences( lConexao, ATabela.Nome);
  if (lSql <> '') and (GetConexao.NovaConsulta(lSql, lConsulta)) then
  begin
    try
      ValidarCampos;

      while not lConsulta.Eof do
      begin
        lNomeSequenciador := Trim(lConsulta.FieldByName('Nome').AsString);

//        lSequenciador :=
        ATabela.Sequenciadores.Novo(ATabela.Nome, lNomeSequenciador, '');

//        ATabela.Sequenciadores.Add(lSequenciador);

        lConsulta.Next;
      end;
    finally
      FreeAndNil(lConsulta);
    end;
  end;


end;

function TLmxMetadata.ObterInformacoesTabela(const ANomeTabela : string; const ANomePropriedade : string;
  const AAtributos: TArray<TCustomAttribute>; out ACampo: TLmxMetadataCampo) : Boolean;
var
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lTipoCampo: TLmxMetadataTipoCampo;
  lNotNull: Boolean;
  lTamanho: Integer;
  lDecimais: Integer;
  lPrimaryKey: Boolean;
//  lTabelaFK: string;
//  lCampoFK: string;
  lCriarCampo: Boolean;
  lPossuiReferencia: Boolean;
begin
  lTamanho := 0;
  lDecimais := 0;
  lPrimaryKey := False;
  lNotNull := False;
  lTipoCampo := mtcAuto;
  lCriarCampo := False;
  ACampo := nil;
  lPossuiReferencia := False;

  for lFieldAtribute in AATributos do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
    begin
      lCriarCampo := True;
      lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
        .NomeCampo;
      lTipoCampo := TLmxAttributeMetadata(lFieldAtribute)
        .TipoCampo;
      lNotNull := TLmxAttributeMetadata(lFieldAtribute)
        .NotNull;
      lTamanho := TLmxAttributeMetadata(lFieldAtribute)
        .Tamanho;
      lDecimais := TLmxAttributeMetadata(lFieldAtribute)
        .Decimais;
    end;
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataPrimaryKey.ClassName) then
    begin
      lPrimaryKey := True;
      lNotNull := True;
    end;
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
    begin
      lCriarCampo := True;
      lPossuiReferencia := True;
    end;
  end;

  if lCriarCampo then
  begin
    if lNomeCampo = EmptyStr then
      lNomeCampo := ANomePropriedade;

    ACampo := TLmxMetadataCampo.Create(ANomeTabela);
    ACampo.Nome := lNomeCampo;
    ACampo.Tipo := lTipoCampo;
    ACampo.NotNull := lNotNull;
    ACampo.PrimaryKey := lPrimaryKey;
    ACampo.Tamanho := lTamanho;
    ACampo.Decimais := lDecimais;
    ACampo.PossuiReferencia := lPossuiReferencia;
//    ACampo.Referencia.Tabela := lTabelaFK;
//    ACampo.Referencia.Campo := lCampoFK;
  end;

  Result := (ACampo <> nil);

end;

function TLmxMetadata.CarregarInformacoesTabelaDataBase(const ANomeTabela : string; const ATabela : TLmxMetadataTabela): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
  lCampo: TLmxMetadataCampo;
  lScriptExecutado: Boolean;
  lSchemaTabela: string;

  procedure ValidarCampo(const ACampo : string);
  begin
    Assert(lConsulta.FindField(ACampo) <> nil, 'Campo ' + ACampo + ' não encontrado na consulta de informações da Tabela ' + ANomeTabela);
  end;

  procedure ValidarCampos;
  begin
    ValidarCampo('Nome');
    ValidarCampo('Tipo');
    ValidarCampo('NotNull');
    ValidarCampo('Tamanho');
    ValidarCampo('Decimais');
  end;

begin
  Result := False;

  lScriptExecutado := GetConexao.GetDataSetInfoTabela(ANomeTabela, lConsulta);

  if not lScriptExecutado then
  begin
    lConexao := GetConexao.ControleConexao.DataBase;
    try
      lScriptExecutado := GetConexao.NovaConsulta(GetConexao.GetScriptObterInfoTabela( lConexao, ANomeTabela), lConsulta);
    except
      lScriptExecutado := False;
    end;
  end;

  if lScriptExecutado then
  begin
    try
      ValidarCampos;

      if (lConsulta.FindField('SchemaTabela') <> nil) then
      begin
        lConsulta.First;
        while not lConsulta.Eof do
        begin
          lSchemaTabela := lConsulta.FieldByName('SchemaTabela').AsString;
          ATabela.FromScriptCriacao(lSchemaTabela);
          lConsulta.Next;
        end;
      end else begin
        while not lConsulta.Eof do
        begin
          lCampo := TLmxMetadataCampo.Create(ANomeTabela);
          lCampo.Nome := Trim(lConsulta.FieldByName('Nome').AsString);
          lCampo.Tipo := TLmxMetadataTipoCampo(lConsulta.FieldByName('Tipo').AsInteger);
          lCampo.NotNull := (lConsulta.FieldByName('NotNull').AsInteger = 1);
          lCampo.Tamanho := lConsulta.FieldByName('Tamanho').AsInteger;
          lCampo.Decimais := lConsulta.FieldByName('Decimais').AsInteger;

  //        lCampo.PrimaryKey := lConsulta.FieldByName('PrimaryKey').AsBoolean;
  //        lCampo.PossuiReferencia := lConsulta.FieldByName('PrimaryKey').AsInteger;

          ATabela.Campos.Add(lCampo);
          lConsulta.Next;
        end;
      end;

    finally
      FreeAndNil(lConsulta);
    end;
  end;
end;

function TLmxMetadata.TabelaExiste(const ANomeTabela: string): Boolean;
var
  lConexao: string;
  lConsulta: TLmxDataSet;
begin
  Result := False;
  lConexao := GetConexao.ControleConexao.DataBase;
  if GetConexao.NovaConsulta(GetConexao.GetScriptTabelaExiste( lConexao, ANomeTabela), lConsulta) then
  begin
    try
      Result := lConsulta.RecordCount > 0;
    finally
      FreeAndNil(lConsulta);
    end;
  end;
end;

function TLmxMetadata.TemTelaRegistrada: Boolean;
begin
  Result := (uLmxInterfacesRegister.RegisterInterface.Tabelas.TemRegistroParaTelaDataBase);
end;

{ TLmxMetadataCampos }

procedure TLmxMetadataCampos.FromScriptCriacao(const ATabela, AScriptCriacao: string);
var
  lCamposStr: TStringList;
  I: Integer;
  lCampoStr: string;
  lCampo: TLmxMetadataCampo;
begin
  lCamposStr := TStringList.Create;
  try
    lCamposStr.LineBreak := ',';
    lCamposStr.Text := AScriptCriacao;

    for I := 0 to lCamposStr.Count - 1 do
    begin
      lCampoStr := lCamposStr[I];
      lCampo := TLmxMetadataCampo.Create(ATabela);
      if lCampo.FromScriptCriacao(lCampoStr) then
      begin
        if Self.PorNomeCampo(lCampo.Nome) <> nil then
        begin
          Self.PorNomeCampo(lCampo.Nome).PrimaryKey := lCampo.PrimaryKey;
        end else begin
          Add(lCampo);
        end;
      end;
    end;

  finally
    FreeAndNil(lCamposStr);
  end;
end;

function TLmxMetadataCampos.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

function TLmxMetadataCampos.GetScriptCriacao: string;
var
  I: Integer;
  lCampo: string;
begin
  Result := '';
  for I := 0 to Count - 1 do
  begin
    Items[I].SetConexao(GetConexao);
    lCampo := GetConexao.GetScriptCriarCampo( Items[I].Nome, Items[I].GetTipoCampoAsString,
      Items[I].NotNull, Items[I].PrimaryKey);

    if I < Count - 1 then
      lCampo := lCampo + ',';

    Result := Result + lCampo;
  end;
end;

function TLmxMetadataCampos.PorNomeCampo(
  const ANomeCampo: string): TLmxMetadataCampo;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if UpperCase(Items[I].Nome) = UpperCase(ANomeCampo) then
      Result := Items[I];
    if Result <> nil then
      Exit;
  end;

end;

procedure TLmxMetadataCampos.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
end;

{ TLmxMetadataCampo }

constructor TLmxMetadataCampo.Create(const ATabela : string);
begin
  FTabela := ATabela;
  FReferencia := TLmxMetadataReferencia.Create;
end;

destructor TLmxMetadataCampo.Destroy;
begin
  FreeAndNil(FReferencia);
  inherited;
end;

function TLmxMetadataCampo.FromScriptCriacao(const AScript: string) : Boolean;
var
  lTipo: string;
  lDecimais: Integer;
  lTamanho: Integer;
begin
  GetConexao.GetInfoCampoFromScript(AScript, FNome, lTipo, lTamanho, lDecimais, FNotNull, FPrimaryKey);
  SetTipoCampoFromString(lTipo, lTamanho, lDecimais);
  Result := True;
end;

function TLmxMetadataCampo.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

function TLmxMetadataCampo.GetScriptAlteracao(
  const ANomeTabela: string): string;
begin
  Result := GetConexao.GetScriptAlterarCampo(ANomeTabela, FNome, GetTipoCampoAsString, FNotNull);
end;

function TLmxMetadataCampo.GetScriptCriacao(const ANomeTabela : string): string;
begin
  Result := GetConexao.GetScriptAdicionarCampo(ANomeTabela, FNome, GetTipoCampoAsString, FNotNull);
end;

function TLmxMetadataCampo.GetTipoCampoAsString: string;
var
  lTamanho: Integer;
  lDecimais: Integer;
begin
  lTamanho := FTamanho;
  lDecimais := FDecimais;

  Result := EmptyStr;
  case FTipo of
    mtcInteger : Result := GetConexao.GetCampoInteger;
    mtcChar    : Result := GetConexao.GetCampoChar(lTamanho);
    mtcVarchar : Result := GetConexao.GetCampoString(lTamanho);
    mtcBoolean : Result := GetConexao.GetCampoBoolean;
    mtcNumeric : Result := GetConexao.GetCampoNumerico(lTamanho, lDecimais);
    mtcDateTime: Result := GetConexao.GetCampoDateTime;
    mtcBlobText: Result := GetConexao.GetCampoBlob(False, FTamanho);
  end;
end;

procedure TLmxMetadataCampo.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
end;

procedure TLmxMetadataCampo.SetTipoCampoFromString(const ATipo: string; const ATamanho, ADecimais : Integer);
begin
  FTamanho := ATamanho;
  FDecimais := ADecimais;

  if ATipo <> '' then
  begin
    if (ATipo = GetConexao.GetCampoInteger) then
      FTipo := mtcInteger
    else if (ATipo = GetConexao.GetCampoChar(FTamanho)) then
      FTipo := mtcChar
    else if (ATipo = GetConexao.GetCampoString(FTamanho)) then
      FTipo := mtcVarchar
    else if (ATipo = GetConexao.GetCampoBoolean) then
      FTipo := mtcBoolean
    else if (ATipo = GetConexao.GetCampoNumerico(FTamanho, FDecimais)) then
      FTipo := mtcNumeric
    else if (ATipo = GetConexao.GetCampoDateTime) then
      FTipo := mtcDateTime
    else if (ATipo = GetConexao.GetCampoBlob(False, FTamanho)) then
      FTipo := mtcBlobText;
  end;
end;

{ TLmxMetadataContext }

constructor TLmxMetadataTabela.Create(const ANome : string);
begin
  FNome := ANome;
  FCampos := TLmxMetadataCampos.Create;
  FIndices := TLmxMetadataIndices.Create;
  FSequenciadores:= TLmxMetadataSequenciadores.Create;
end;

destructor TLmxMetadataTabela.Destroy;
begin
  FreeAndNil(FSequenciadores);
  FreeAndNil(FIndices);
  FreeAndNil(FCampos);
  inherited;
end;

procedure TLmxMetadataTabela.FromScriptCriacao(const AScriptCriacao: string);
var
  lPosicaoNomeTabela: Integer;
  lPosicaoFinalTabela: Integer;
  lNomeTabela: string;
  lCampos: string;
  lScriptCriacao: string;

begin
  lNomeTabela := '';

  lScriptCriacao := AScriptCriacao;
  lScriptCriacao := StringReplace(lScriptCriacao, '`', '', [rfReplaceAll]);
  lScriptCriacao := StringReplace(lScriptCriacao, #9, ' ', [rfReplaceAll]);
  lScriptCriacao := StringReplace(lScriptCriacao, #$A, '', [rfReplaceAll]);
  lPosicaoNomeTabela := Pos('CREATE TABLE', lScriptCriacao);
  lPosicaoFinalTabela := 0;
  if lPosicaoNomeTabela > 0 then
  begin
    lPosicaoNomeTabela := lPosicaoNomeTabela + Length('CREATE TABLE') + 1;
    lPosicaoFinalTabela := Pos('(', lScriptCriacao{$IFDEF VER270}, lPosicaoNomeTabela{$ENDIF});
    lNomeTabela := copy(lScriptCriacao, lPosicaoNomeTabela, ((lPosicaoFinalTabela - 1) - lPosicaoNomeTabela));
    lNomeTabela := StringReplace(lNomeTabela, '"', '', [rfReplaceAll]);
  end;

  FNome := lNomeTabela;

  //Campos
  if lPosicaoFinalTabela > 0 then
  begin
    lCampos := copy(lScriptCriacao, lPosicaoFinalTabela + 1, length(lScriptCriacao) -  lPosicaoFinalTabela - 1);
    FCampos.FromScriptCriacao(FNome, lCampos);
  end;

end;

procedure TLmxMetadataTabela.AddScriptCriacao(const AAlteracoes : TLmxMetadataAlteracoes);
begin
  AAlteracoes.NovaAlteracao(taInserirTabela, FNome, '',
    GetScriptCriacao,
    Format('Adicionando Tabela %s',
    [FNome]));

  AddScriptCriacaoChavesPrimarias(AAlteracoes);
  AddScriptCriacaoChavesEstrangeiras(AAlteracoes);
  AddScriptCriacaoIndices(AAlteracoes);
  AddScriptCriacaoSequenciadores(AAlteracoes);
end;

function TLmxMetadataTabela.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

function TLmxMetadataTabela.GetScriptCriacao: string;
begin
  Result := GetConexao.GetScriptGerarTabela(FNome, FCampos.GetScriptCriacao)
end;


procedure TLmxMetadataTabela.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
  FCampos.SetConexao(FConexao);
end;

procedure TLmxMetadataTabela.AddScriptCriacaoChavesEstrangeiras(const AAlteracoes : TLmxMetadataAlteracoes);
var
  I: Integer;
begin
  for I := 0 to  FCampos.Count - 1 do
  begin
    if FCampos.Items[I].Referencia.Tabela <> EmptyStr then
    begin
      AAlteracoes.NovaAlteracao(taInserirChaveEstrangeira, FNome, FCampos.Items[I].Nome,
        GetConexao.GetScriptAdicionarChaveEstrangeira(FNome, FCampos.Items[I].Nome, FCampos.Items[I].Referencia.Tabela, FCampos.Items[I].Referencia.Campo),
        Format('Adicionando Referencia na tabela %s para a Tabela %s, com os campos %s',
        [FNome, FCampos.Items[I].Referencia.Tabela, FCampos.Items[I].Referencia.Campo]));
    end;
  end;
end;

procedure TLmxMetadataTabela.AddScriptCriacaoChavesPrimarias(const AAlteracoes : TLmxMetadataAlteracoes);
var
  I: Integer;
  lCampos: string;
begin
  lCampos := '';
  for I := 0 to  FCampos.Count - 1 do
  begin
    if FCampos.Items[I].PrimaryKey then
    begin
      if lCampos <> EmptyStr then
        lCampos := lCampos + ',';
      lCampos := lCampos + FCampos.Items[I].Nome;
    end;
  end;
  if lCampos <> '' then
    AAlteracoes.NovaAlteracao(taInserirChavePrimaria, FNome, lCampos,
      GetConexao.GetScriptAdicionarChavePrimaria(FNome, lCampos),
      Format('Adicionando Chave Primaria na tabela %s para os campos %s',
      [FNome, lCampos]));
end;

procedure TLmxMetadataTabela.AddScriptCriacaoIndices(
  const AAlteracoes: TLmxMetadataAlteracoes);
var
  I: Integer;
begin
  for I := 0 to  FIndices.Count - 1 do
  begin
    if FIndices.Items[I].Nome <> EmptyStr then
    begin
      AAlteracoes.NovaAlteracao(taInserirIndice, FNome, FIndices.Items[I].Campos,
        GetConexao.GetScriptNovoIndice(FNome, FIndices.Items[I].Nome, FIndices.Items[I].Campos),
        Format('Adicionando Indice %s na tabela %s com os campos %s',
        [FIndices.Items[I].Nome, FNome, FIndices.Items[I].Campos]));
    end;
  end;
end;

procedure TLmxMetadataTabela.AddScriptCriacaoSequenciadores(
  const AAlteracoes: TLmxMetadataAlteracoes);
var
  I: Integer;
begin
  for I := 0 to  FSequenciadores.Count - 1 do
  begin
    if FSequenciadores.Items[I].Nome <> EmptyStr then
    begin
      AAlteracoes.NovaAlteracao(taInserirSequenciador, FNome, FSequenciadores.Items[I].Campo,
        GetConexao.GetScriptNovoSequence(FNome, FSequenciadores.Items[I].Nome, FSequenciadores.Items[I].Campo),
        Format('Adicionando Sequence %s na tabela %s com o campo %s',
        [FSequenciadores.Items[I].Nome, FNome, FSequenciadores.Items[I].Campo]));
    end;
  end;
end;

{ TLmxMetadataContext }

constructor TLmxMetadataContext.Create;
begin
  FTabelas := TLmxMetadataTabelas.Create([doOwnsValues]);
end;

destructor TLmxMetadataContext.Destroy;
begin
  FreeAndNil(FTabelas);
  inherited;
end;

function TLmxMetadataContext.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

function TLmxMetadataContext.GetScriptCriacao: string;
begin
  Result := FTabelas.GetScriptCriacao;
end;

procedure TLmxMetadataContext.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
  FTabelas.SetConexao(AConexao);
end;

{ TLmxMetadataTabelas }

function TLmxMetadataTabelas.Adicionar(const ANomeTabela : string; out ATabela : TLmxMetadataTabela) : Boolean;
begin
  Result := (ANomeTabela <> '') and (not TryGetValue(ANomeTabela, ATabela));
  if Result then
  begin
    ATabela := TLmxMetadataTabela.Create(ANomeTabela);
    Add(ANomeTabela, ATabela);
  end;
end;

function TLmxMetadataTabelas.GetConexao: TLmxConexao;
begin
  Result := FConexao;
  if Result = nil then
    Result := LmxConexao;
end;

function TLmxMetadataTabelas.GetScriptCriacao: string;
var
  lEnum: TPairEnumerator;
begin
  Result := '';
  lEnum := GetEnumerator;
  try
    while lEnum.MoveNext do
    begin
      Result := Result + '-- TABELA (' + lEnum.Current.Key + ')' + sLineBreak;
      Result := Result + lEnum.Current.Value.GetScriptCriacao + sLineBreak;
    end;
  finally
    FreeAndNil(lEnum);
  end;
end;

procedure TLmxMetadataTabelas.SetConexao(const AConexao: TLmxConexao);
begin
  FConexao := AConexao;
end;

{ TLmxMetadataAlteracoes }

procedure TLmxMetadataAlteracoes.CopyFrom(
  const AAlteracoes: TLmxMetadataAlteracoes);
var
  I: Integer;
  lAlteracao: TLmxMetadataAlteracao;
begin
  for I := 0 to AAlteracoes.Count - 1 do
  begin
    lAlteracao := TLmxMetadataAlteracao.Create;
    lAlteracao.CopyFrom(AAlteracoes[I]);
  end;
end;

function TLmxMetadataAlteracoes.GetMaiorIndiceInserirTabelaOuCampo: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Self.Count - 1 do
  begin
    if Self[I].Tipo in [taInserirTabela, taInserirCampo] then
      Result := I + 1;
  end;
end;

function TLmxMetadataAlteracoes.NovaAlteracao(const ATipo: TLmxTipoAlteracao;
  const ATabela, ACampo, AScript, ADescricao: string): TLmxMetadataAlteracao;
begin
  Result := TLmxMetadataAlteracao.Create;
  Result.Tipo := ATipo;
  Result.Tabela := ATabela;
  Result.Campo := ACampo;
  Result.Descricao := ADescricao;
  Result.Script := AScript;

  if ATipo in [taInserirTabela, taInserirCampo, taInserirChavePrimaria] then
    Insert(GetMaiorIndiceInserirTabelaOuCampo, Result)
  else
    Add(Result);
end;

function TLmxMetadataAlteracoes.ToString: string;
var
  lAlteracao: TLmxMetadataAlteracao;
begin
  for lAlteracao in Self do
  begin
    if Result <> '' then
      Result := Result + sLineBreak;
    Result := Result + lAlteracao.Script;
  end;
end;

{ TLmxMetadataAlteracao }

procedure TLmxMetadataAlteracao.CopyFrom(
  const AAlteracao: TLmxMetadataAlteracao);
begin
  FDescricao := AAlteracao.Descricao;
  FTabela    := AAlteracao.Tabela;
  FCampo     := AAlteracao.Campo;
  FTipo      := AAlteracao.Tipo;
  FScript    := AAlteracao.Script;
end;



{ TLmxMetadataIndice }

constructor TLmxMetadataIndice.Create(const ATabela : string);
begin
  FTabela := ATabela;
end;

function TLmxMetadataIndice.GetScriptAtivarIndice(
  const AAtivar: Boolean): string;
begin
  if AAtivar then
    Result := Format('ALTER INDEX %s ACTIVE', [FNome])
  else
    Result := Format('ALTER INDEX %s INACTIVE', [FNome]);
end;

{ TLmxMetadataIndices }

function TLmxMetadataIndices.Novo(const ATabela,
  ANome, ACampos: string): TLmxMetadataIndice;
begin
  Result := TLmxMetadataIndice.Create(ATabela);
  Result.Ativo := True;
  Result.Unico := False;
  Result.Nome := ANome;
  Result.Campos := ACampos;
  Add(Result);
end;

function TLmxMetadataIndices.PorNome(const ANome: string): TLmxMetadataIndice;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if UpperCase(Items[I].Nome) = UpperCase(ANome) then
      Result := Items[I];
    if Result <> nil then
      Exit;
  end;
end;

{ TLmxMetadataSequenciadores }

function TLmxMetadataSequenciadores.Novo(const ATabela, ANome,
  ACampo: string): TLmxMetadataSequenciador;
begin
  Result := TLmxMetadataSequenciador.Create(ATabela);
  Result.Nome := ANome;
  Result.Campo := ACampo;
  Add(Result);
end;

function TLmxMetadataSequenciadores.PorNome(
  const ANome: string): TLmxMetadataSequenciador;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if UpperCase(Items[I].Nome) = UpperCase(ANome) then
      Result := Items[I];
    if Result <> nil then
      Exit;
  end;
end;

{ TLmxMetadataSequenciador }

constructor TLmxMetadataSequenciador.Create(const ATabela: string);
begin
  FTabela := ATabela;
end;

initialization
  FLmxMetadata := TLmxMetadata.Create;

finalization
  FreeAndNil(FLmxMetadata);


end.

