unit uLmxInterfacesRegister;

interface

uses
  {$IFDEF NOGUI}uLmxBaseViewNoGui,{$ELSE}
  {$IFDEF HAS_FMX}
  uLmx.Fmx.View.Base, uLmx.Fmx.View.BaseConsulta, uLmx.Fmx.View.BaseCadastro,
  {$ELSE}
  uLmxBaseView, uLmxBaseConsultaView, uLmxBaseCadastroView, uLmxBaseDataBaseView,
  {$ENDIF}
  {$ENDIF}
  Classes, uLmxInterfaces, SysUtils, uLmxImpressora, Generics.Collections, XMLIntf, XMLDoc, IOUtils,
  uLmxConexao, uLmxCore,  uLmxUtils, System.TypInfo;

type

  TLmxRegisterInterface = class;

  TLmxInterfacesRegister = class
  protected
    FPDVRegister : TLmxRegisterInterface;
  public
    constructor Create(const APDVRegister : TLmxRegisterInterface); virtual;
  end;

  TLmxRegisterConsultas = class(TLmxInterfacesRegister)
  private
    FPDVViewConsultaGenerica : {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF};
    FPDVViewConsultaManutencaoGenerica : {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} ;
  public
    procedure RegistrarConsultaGenerica(const APDVViewConsultaGenerica : {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
    function NewPDVConsultaView(const AOwner : TComponent = nil) : ILmxConsultaView;

    procedure RegistrarConsultaManutencaoGenerica(const APDVViewConsultaGenerica : {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
    function NewPDVConsultaManutencaoView(const AOwner : TComponent = nil) : ILmxConsultaManutencaoView;
  end;

  TLmxRegisterCadastros = class(TLmxInterfacesRegister)
//  private
//    FPDVViewProduto : TLmxBaseCadastroViewClass;
  public
//    procedure RegistrarProdutoView(const APDVViewProduto : TLmxBaseCadastroViewClass);
//    function NewProdutoView(const AOwner : TComponent = nil) : IPDVCadastroProdutoView;
  end;

  TLmxRegisterInfo = class
  private
    FDescricao: string;
    FClasse: TClass;
  public
    property Descricao : string read FDescricao write FDescricao;
    property Classe : TClass read FClasse write FClasse;
  end;

  TLmxRegisterBase<TClasseRegistro : class> = class(TLmxInterfacesRegister)
  private
//    type TRegisterList = TObjectDictionary<TClasseRegistro,TLmxRegisterInfo>;
    type TRegisterList = TObjectDictionary<TClass,TLmxRegisterInfo>;
  private
    FLista : TRegisterList;
  public
    constructor Create(const APDVRegister : TLmxRegisterInterface); override;
    destructor Destroy; override;

    procedure Registrar(const APDVRegistro : TClass; const ADescricao : string);
//    procedure RegistrarImpressoraDefault(const APDVImpressora : TLmxImpressoraClass);
    procedure Listar(out ALista : TRegisterList);
    function GetAsClassOf(const AClassName : string) : TClass;
  end;

  TLmxRegisterContextTabela = class(TLmxInterfacesRegister)
  private
    type TRegisterList = TObjectDictionary<TClass,TGUID>;
  private
    FLista : TRegisterList;
  public
    constructor Create(const APDVRegister : TLmxRegisterInterface); override;
    destructor Destroy; override;

    procedure Registrar(const APDVRegistro : TClass; const AIntf : TGuid);
//    procedure RegistrarImpressoraDefault(const APDVImpressora : TLmxImpressoraClass);
    procedure Listar(out ALista : TRegisterList);
    function GetContextOf(const APDVRegistro : TClass) : TGuid;
//    function GetAsClassOf<T : ILmxContext> : TClass;
  end;

  TLmxRegisterTabelas = class(TLmxRegisterBase<TBase>)
  private
    FPDVViewDataBase : {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} ;
  public
    function GetAsClassOfType(const AClassName : string) : TClass;

    procedure RegistrarTelaDataBase(const APDVViewDataBase: {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
    function NewTelaDataBase(const AOwner : TComponent = nil) : ILmxDataBaseAtualizadorView;
    function TemRegistroParaTelaDataBase : Boolean;
  end;

  TLmxRegisterImpressoras = class
  private
    FImpressoraDefault : TLmxImpressoraClass;
    FImpressoras : TLmxImpressoraList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegistrarImpressora(const APDVImpressora : TLmxImpressoraClass; const ADescricao : string);
    procedure RegistrarImpressoraDefault(const APDVImpressora : TLmxImpressoraClass);
    procedure ListarImpressoras(out AListaImpressoras : TLmxImpressoraList);
    function GetImpressoraAsClassOf(const AImpressora : string) : TLmxImpressoraClass;
    function GetDescricaoFromClassOf(const AClasseImpressora : string) : string;
//    procedure CarregarRegistroImpressoraDefault(const APDVImpressora : TLmxImpressoraClass);
  end;

  TLmxRegisterConexoes = class
  private
//    FConexaoDefault : TLmxConexaoClass;
    FConexoes : TLmxConexaoList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegistrarConexao(const APDVConexao : TLmxConexaoClass; const ADescricao : string);
//    procedure RegistrarConexaoDefault(const APDVConexao : TLmxConexaoClass);
    procedure ListarConexoes(out AListaConexoes : TLmxConexaoList);
    function GetConexaoAsClassOf(const AConexao : string) : TLmxConexaoClass;
    function GetDescricaoFromClassOf(const AClasseConexao : string) : string;
//    procedure CarregarRegistroImpressoraDefault(const APDVImpressora : TLmxImpressoraClass);
  end;


  TLmxRegisterInterface = class
  private
//    FPDVViewClass : TLmxBaseViewClass;
//    FConfiguracoesViewClass : TLmxBaseViewClass;
//    FPDVMensagemViewClass : TLmxBaseViewClass;
    FConsultas: TLmxRegisterConsultas;
    FImpressoras: TLmxRegisterImpressoras;
    FConexoes: TLmxRegisterConexoes;
    FTabelas: TLmxRegisterTabelas;
    FCadastros: TLmxRegisterCadastros;
    FContextTabela: TLmxRegisterContextTabela;
    procedure Validar(const AClass : TClass; const AGuid : TGuid);
  public

    constructor Create;
    destructor Destroy; override;

//    procedure RegistrarPDVView(const APDVView : TLmxBaseViewClass);
//    function NewPDVView(const AOwner : TComponent = nil) : ILmxView;

//    procedure RegistrarConfiguracoesView(const AConfiguracoesView : TLmxBaseViewClass);
//    function NewConfiguracoesView(const AOwner : TComponent = nil) : IConfiguracoesView;

//    procedure RegistrarMensagensView(const AMensagensView : TLmxBaseViewClass);
//    function NewMensagensView(const AOwner : TComponent = nil) : IPDVMensagem;

    property Consultas : TLmxRegisterConsultas read FConsultas;
    property Cadastros : TLmxRegisterCadastros read FCadastros;
    property ContextTabela : TLmxRegisterContextTabela read FContextTabela;
    property Impressoras : TLmxRegisterImpressoras read FImpressoras;
    property Conexoes : TLmxRegisterConexoes read FConexoes;
    property Tabelas : TLmxRegisterTabelas read FTabelas;
  end;

function RegisterInterface : TLmxRegisterInterface;


implementation

var
  FRegisterInterface : TLmxRegisterInterface;

function RegisterInterface : TLmxRegisterInterface;
begin
  Result := FRegisterInterface;
end;

{ TLmxRegisterInterface }

constructor TLmxRegisterInterface.Create;
begin
  FConsultas := TLmxRegisterConsultas.Create(Self);
  FImpressoras := TLmxRegisterImpressoras.Create;
  FConexoes := TLmxRegisterConexoes.Create;
  FTabelas := TLmxRegisterTabelas.Create(Self);
  FCadastros := TLmxRegisterCadastros.Create(Self);
  FContextTabela := TLmxRegisterContextTabela.Create(Self);
end;

destructor TLmxRegisterInterface.Destroy;
begin
  FreeAndNil(FContextTabela);
  FreeAndNil(FCadastros);
  FreeAndNil(FTabelas);
  FreeAndNil(FConexoes);
  FreeAndNil(FImpressoras);
  FreeAndNil(FConsultas);
  inherited;
end;

//function TLmxRegisterInterface.NewConfiguracoesView(
//  const AOwner: TComponent): IConfiguracoesView;
//begin
//  Result := nil;
//  if FConfiguracoesViewClass <> nil then
//    Result := FConfiguracoesViewClass.Create(AOwner) as IConfiguracoesView;
//end;
//
//function TLmxRegisterInterface.NewMensagensView(
//  const AOwner: TComponent): IPDVMensagem;
//begin
//  Result := nil;
//  if FPDVMensagemViewClass <> nil then
//    Result := FPDVMensagemViewClass.Create(AOwner) as IPDVMensagem;
//end;

//function TLmxRegisterInterface.NewPDVView(const AOwner : TComponent) : IPDVView;
//begin
//  Result := nil;
//  if FPDVViewClass <> nil then
//    Result := FPDVViewClass.Create(AOwner) as IPDVView;
//end;
//
//procedure TLmxRegisterInterface.RegistrarConfiguracoesView(
//  const AConfiguracoesView: TLmxBaseViewClass);
//begin
//  Validar(AConfiguracoesView, IConfiguracoesView);
//  FConfiguracoesViewClass := AConfiguracoesView;
//end;
//
//procedure TLmxRegisterInterface.RegistrarMensagensView(
//  const AMensagensView: TLmxBaseViewClass);
//begin
//  Validar(AMensagensView, IPDVMensagem);
//  FPDVMensagemViewClass := AMensagensView;
//end;
//
//procedure TLmxRegisterInterface.RegistrarPDVView(const APDVView: TLmxBaseViewClass);
//begin
//  Validar(APDVView, IPDVView);
//  FPDVViewClass := APDVView;
//end;
//
procedure TLmxRegisterInterface.Validar(const AClass : TClass; const AGuid : TGuid);
begin
  if not Supports(AClass, AGuid) then
    raise Exception.Create(Format('Classe %s não suporta a interface %s',
      [AClass.ClassName, GuidToString(AGuid)]));
end;

{ TLmxRegisterConsultas }

function TLmxRegisterConsultas.NewPDVConsultaManutencaoView(
  const AOwner: TComponent): ILmxConsultaManutencaoView;
begin
  if FPDVViewConsultaManutencaoGenerica = nil then
    raise Exception.Create('Nenhum registro encontrado para a View de Listagem !');
  Result := FPDVViewConsultaManutencaoGenerica.Create(AOwner) as ILmxConsultaManutencaoView;
end;

function TLmxRegisterConsultas.NewPDVConsultaView(const AOwner: TComponent): ILmxConsultaView;
begin
  if FPDVViewConsultaGenerica = nil then
    raise Exception.Create('Nenhum registro encontrado para a View de Consulta !');
  Result := FPDVViewConsultaGenerica.Create(AOwner) as ILmxConsultaView;
end;

procedure TLmxRegisterConsultas.RegistrarConsultaGenerica(const APDVViewConsultaGenerica: {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
begin
  FPDVRegister.Validar(APDVViewConsultaGenerica, ILmxConsultaView);
  FPDVViewConsultaGenerica := APDVViewConsultaGenerica;
end;

procedure TLmxRegisterConsultas.RegistrarConsultaManutencaoGenerica(
  const APDVViewConsultaGenerica: {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
begin
  FPDVRegister.Validar(APDVViewConsultaGenerica, ILmxConsultaManutencaoView);
  FPDVViewConsultaManutencaoGenerica := APDVViewConsultaGenerica;
end;

{ TLmxRegisterImpressoras }

constructor TLmxRegisterImpressoras.Create;
begin
  FImpressoras := TLmxImpressoraList.Create([doOwnsValues]);
end;

destructor TLmxRegisterImpressoras.Destroy;
begin
  FreeAndNil(FImpressoras);
  inherited;
end;

function TLmxRegisterImpressoras.GetDescricaoFromClassOf(
  const AClasseImpressora: string): string;
var
  lEnumImpressoras : TLmxImpressoraList.TPairEnumerator;
begin
  Result := EmptyStr;
  lEnumImpressoras := FImpressoras.GetEnumerator;
  try
    while lEnumImpressoras.MoveNext do
    begin
      if lEnumImpressoras.Current.Value.Classe.ClassName = AClasseImpressora then
        Result := lEnumImpressoras.Current.Value.Descricao;
    end;
  finally
    FreeAndNil(lEnumImpressoras);
  end;
end;

function TLmxRegisterImpressoras.GetImpressoraAsClassOf(const AImpressora: string): TLmxImpressoraClass;
var
  lEnumImpressoras : TLmxImpressoraList.TPairEnumerator;
begin
  Result := nil;
  lEnumImpressoras := FImpressoras.GetEnumerator;
  try
    while lEnumImpressoras.MoveNext do
    begin
      if lEnumImpressoras.Current.Key.ClassName = AImpressora then
        Result := lEnumImpressoras.Current.Key;
    end;
  finally
    FreeAndNil(lEnumImpressoras);
  end;
end;

procedure TLmxRegisterImpressoras.ListarImpressoras(out AListaImpressoras: TLmxImpressoraList);
begin
  AListaImpressoras := FImpressoras;
end;

procedure TLmxRegisterImpressoras.RegistrarImpressora(const APDVImpressora : TLmxImpressoraClass; const ADescricao : string);
var
  lInfoImpressora: TLmxImpressoraInfo;
begin
  lInfoImpressora           := TLmxImpressoraInfo.Create;
  lInfoImpressora.Descricao := ADescricao;
  lInfoImpressora.Classe    := APDVImpressora;
  FImpressoras.Add(APDVImpressora, lInfoImpressora);
end;

procedure TLmxRegisterImpressoras.RegistrarImpressoraDefault(const APDVImpressora: TLmxImpressoraClass);
begin
  FImpressoraDefault := APDVImpressora;
  //Salvar Arquivo de Configuracao
end;


{ TLmxRegisterConexoes }

constructor TLmxRegisterConexoes.Create;
begin
  FConexoes := TLmxConexaoList.Create([doOwnsValues]);
end;

destructor TLmxRegisterConexoes.Destroy;
begin
  FreeAndNil(FConexoes);
  inherited;
end;

function TLmxRegisterConexoes.GetConexaoAsClassOf(
  const AConexao: string): TLmxConexaoClass;
var
  lEnumConexoes : TLmxConexaoList.TPairEnumerator;
begin
  Result := nil;
  lEnumConexoes := FConexoes.GetEnumerator;
  try
    while lEnumConexoes.MoveNext do
    begin
      if lEnumConexoes.Current.Key.ClassName = AConexao then
        Result := lEnumConexoes.Current.Key;
    end;
  finally
    FreeAndNil(lEnumConexoes);
  end;
end;

function TLmxRegisterConexoes.GetDescricaoFromClassOf(
  const AClasseConexao: string): string;
var
  lEnumConexoes : TLmxConexaoList.TPairEnumerator;
begin
  Result := EmptyStr;
  lEnumConexoes := FConexoes.GetEnumerator;
  try
    while lEnumConexoes.MoveNext do
    begin
      if lEnumConexoes.Current.Value.Classe.ClassName = AClasseConexao then
        Result := lEnumConexoes.Current.Value.Descricao;
    end;
  finally
    FreeAndNil(lEnumConexoes);
  end;
end;

procedure TLmxRegisterConexoes.ListarConexoes(
  out AListaConexoes: TLmxConexaoList);
begin
  AListaConexoes := FConexoes;
end;

procedure TLmxRegisterConexoes.RegistrarConexao(
  const APDVConexao: TLmxConexaoClass; const ADescricao: string);
var
  lInfoConexao: TLmxConexaoInfo;
begin
  lInfoConexao           := TLmxConexaoInfo.Create;
  lInfoConexao.Descricao := ADescricao;
  lInfoConexao.Classe    := APDVConexao;
  FConexoes.Add(APDVConexao, lInfoConexao);
end;

//procedure TLmxRegisterConexoes.RegistrarConexaoDefault(
//  const APDVConexao: TLmxConexaoClass);
//begin
//  uPDVConexao.RegistrarConexao(APDVConexao);
//end;

{ TLmxRegisterBase<TClasseRegistro> }

constructor TLmxRegisterBase<TClasseRegistro>.Create(const APDVRegister : TLmxRegisterInterface);
begin
  inherited;
  FLista := TRegisterList.Create([doOwnsValues]);
end;

destructor TLmxRegisterBase<TClasseRegistro>.Destroy;
begin
  FreeAndNil(FLista);
  inherited;
end;

function TLmxRegisterBase<TClasseRegistro>.GetAsClassOf(
  const AClassName: string): TClass;
var
  lEnum : TRegisterList.TPairEnumerator;
begin
  Result := nil;
  lEnum := FLista.GetEnumerator;
  try
    while lEnum.MoveNext do
    begin
      if lEnum.Current.Key.ClassName = AClassName then
        Result := lEnum.Current.Key;
    end;
  finally
    FreeAndNil(lEnum);
  end;
end;

procedure TLmxRegisterBase<TClasseRegistro>.Listar(out ALista: TRegisterList);
begin
  ALista := FLista;
end;

procedure TLmxRegisterBase<TClasseRegistro>.Registrar(
  const APDVRegistro: TClass; const ADescricao: string);
var
  lInfo : TLmxRegisterInfo;
begin
  if not FLista.TryGetValue(APDVRegistro, lInfo) then
  begin
    lInfo           := TLmxRegisterInfo.Create;
    lInfo.Descricao := ADescricao;
    lInfo.Classe    := APDVRegistro;
    FLista.Add(APDVRegistro, lInfo);
  end;
end;

{ TLmxRegisterTabelas }

function TLmxRegisterTabelas.GetAsClassOfType(const AClassName: string): TClass;
var
  lEnum : TRegisterList.TPairEnumerator;
begin
  Result := nil;
  lEnum := FLista.GetEnumerator;
  try
    while lEnum.MoveNext do
    begin
      if lEnum.Current.Key.ClassName = AClassName then
        Result := lEnum.Current.Key;
    end;
  finally
    FreeAndNil(lEnum);
  end;
end;

{ TLmxRegisterCadastros }

//function TLmxRegisterCadastros.NewProdutoView(
//  const AOwner: TComponent): IPDVCadastroProdutoView;
//begin
//  if FPDVViewProduto = nil then
//    raise Exception.Create('Nenhum registro encontrado para o Cadastro de Produto!');
//  Result := FPDVViewProduto.Create(AOwner) as IPDVCadastroProdutoView;
//end;

function TLmxRegisterTabelas.NewTelaDataBase(
  const AOwner: TComponent): ILmxDataBaseAtualizadorView;
begin
  Result := nil;
  if FPDVViewDataBase <> nil then
    Result := FPDVViewDataBase.Create(AOwner) as ILmxDataBaseAtualizadorView;
end;

procedure TLmxRegisterTabelas.RegistrarTelaDataBase(
  const APDVViewDataBase: {$IFDEF HAS_FMX}TLmxFmxViewBaseConsultaClass{$ELSE} TLmxBaseConsultaViewClass{$ENDIF} );
begin
  FPDVRegister.Validar(APDVViewDataBase, ILmxDataBaseView);
  FPDVViewDataBase := APDVViewDataBase;
end;

function TLmxRegisterTabelas.TemRegistroParaTelaDataBase: Boolean;
begin
  Result := FPDVViewDataBase <> nil;
end;

{ TLmxInterfacesRegister }

constructor TLmxInterfacesRegister.Create(const APDVRegister: TLmxRegisterInterface);
begin
  FPDVRegister := APDVRegister;
end;

{ TLmxRegisterContextTabela }

constructor TLmxRegisterContextTabela.Create(
  const APDVRegister: TLmxRegisterInterface);
begin
  inherited;
  FLista := TRegisterList.Create;
end;

destructor TLmxRegisterContextTabela.Destroy;
begin
  FLista.Free;
  inherited;
end;

function TLmxRegisterContextTabela.GetContextOf(
  const APDVRegistro: TClass): TGuid;
begin
  FLista.TryGetValue(APDVRegistro, Result);
end;

procedure TLmxRegisterContextTabela.Listar(out ALista: TRegisterList);
begin

end;

procedure TLmxRegisterContextTabela.Registrar(const APDVRegistro: TClass;
  const AIntf: TGuid);
begin
  FLista.AddOrSetValue(APDVRegistro, AIntf);
end;

initialization
  FRegisterInterface := TLmxRegisterInterface.Create;

finalization
  FreeAndNil(FRegisterInterface);

end.



