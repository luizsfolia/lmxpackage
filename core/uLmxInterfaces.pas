unit uLmxInterfaces;

interface

uses
  SysUtils, Classes, uLmxControllerBase, DB, DBClient, Generics.Collections, System.Rtti;

type

  ILmxBaseView = interface
    ['{7740286A-8348-45A7-9915-A98FCF3BDC45}']
    function Mostrar : Boolean;
    procedure Build(const AController: TLmxControllerBase);
  end;

  ILmxSegurancaController = interface
    ['{CDCF0EF0-D9C9-4A75-807C-9C633A8CBC4A}']

  end;

  ILmxQuery = interface;
  ILmxDataSet = interface;

  ILmxParamSql = interface
    ['{05767487-7A94-4662-AFBC-C0453F68BFF8}']
    function GetNome: string;
    function GetValue: TValue;
    function GetDataType : TFieldType;
    procedure SetNome(const Value: string);
    procedure SetValue(const Value: TValue);
    procedure SetDataType(const Value: TFieldType);


    property Nome : string read GetNome write SetNome;
    property Value : TValue read GetValue write SetValue;
    property DataType : TFieldType read GetDataType write SetDataType;
  end;

  ILmxParamsSql = interface
    ['{C9919898-6494-474E-B902-00496FA594DA}']
    function GetParametro(const pNome: string): ILmxParamSql; overload;

    function AddParam(const pNome : string; const pValue : TValue; const pDataType : TFieldType = ftUnknown) : ILmxParamsSql;

    property Parametro[const pNome : string] : ILmxParamSql read GetParametro;

    procedure Percorrer(const pProc : TProc<string,TValue, TFieldType>);
  end;


  ILmxConnection = interface
    ['{812E2E2E-448D-4ABE-9801-7C5EDD0A6E19}']

    function GetConnectionName : string;
    procedure SetConnectionName(const AValue : string);
//    function GetHostName : string;
//    procedure SetHostName(const AValue : string);
//    function GetDatabase : string;
//    procedure SetDatabase(const AValue : string);
//    function GetUser_Name : string;
//    procedure SetUser_Name(const AValue : string);
//    function GetPassword : string;
//    procedure SetPassword(const AValue : string);
    function GetDriverName : string;
    procedure SetDriverName(const AValue : string);
    function GetParams : TStrings;
    function GetLibraryName : string;
    procedure SetLibraryName(const AValue : string);

    procedure Close;
    procedure CloseDataSets;

    function CloneConnection : ILmxConnection;
    function NewQuery(const AOwner : TComponent) : ILmxQuery;
    function NewDataSet(const AOwner : TComponent) : ILmxDataset;

    property Params : TStrings read GetParams;
    property DriverName : string read GetDriverName write SetDriverName;
    property LibraryName : string read GetLibraryName write SetLibraryName;
    property ConnectionName : string read GetConnectionName write SetConnectionName;
//    property HostName : string read GetHostName write SetHostName;
//    property Database : string read GetDatabase write SetDatabase;
//    property User_Name : string read GetUser_Name write SetUser_Name;
//    property Password : string read GetPassword write SetPassword;

  end;

  ILmxRequisicaoCliente = interface
    ['{B4591DF7-91FB-42B1-B8AC-03D623A95FD6}']
    function GetUSerId : Integer;
    function SetUSerId(const pValue : Integer) : ILmxRequisicaoCliente;
    function GetUSerIsAdmin : Boolean;
    function SetUSerIsAdmin(const pValue : Boolean) : ILmxRequisicaoCliente;

    function GetLimit : Integer;
    function SetLimit(const pValue : Integer) : ILmxRequisicaoCliente;

    function GetResponseBuscarComoJson : Boolean;
    function SetResponseBuscarComoJson(const pValue : Boolean) : ILmxRequisicaoCliente;
  end;

  TLmxServicesEventsInterface = class;

  ILmxContext = interface
    ['{B42F6FF2-9F4E-4ABD-B95F-BEDA07207296}']
    procedure SetRequisicaoCliente(const pRequisicao : ILmxRequisicaoCliente);
    function GetRequisicaoCliente : ILmxRequisicaoCliente;
    procedure SetServicesEvents(const pServicesEvents : TLmxServicesEventsInterface);
    function GetServicesEvents : TLmxServicesEventsInterface;
    function GetServiceEvent(pGuid : TGuid) : ILmxContext;
    function GetUSerId : Integer;

    function GetObject : TObject;
  end;

  TLmxServicesEventInterfaces<T : ILmxContext> = reference to function : T;
  TLmxServicesEventsInterface = class(TObjectDictionary<TGuid, TLmxServicesEventInterfaces<ILmxContext>>);

  TLmxContext = class(TInterfacedObject, ILmxContext)
  private
    FRequisicao: ILmxRequisicaoCliente;
    FServicesEvents : TLmxServicesEventsInterface;
  public
//    procedure SetUserId(const pUserId : Integer);
//    function GetUserId : Integer;
    procedure SetRequisicaoCliente(const pRequisicao : ILmxRequisicaoCliente);
    function GetRequisicaoCliente : ILmxRequisicaoCliente;
    procedure SetServicesEvents(const pServicesEvents : TLmxServicesEventsInterface);
    function GetServicesEvents : TLmxServicesEventsInterface; virtual;
    function GetServiceEvent(pGuid : TGuid) : ILmxContext; virtual;
    function GetUSerId : Integer;
    function GetObject : TObject;
  end;


  ILmxContextFile = interface(ILmxContext)
    ['{A89A2C8D-860F-4225-B4B7-4B0D424BD8D4}']
  end;

  

  TLmxContextClass = class of TLmxContext;


  ILmxConnection<T> = interface(ILmxConnection)
    ['{1BBFBF22-5444-4D33-8C4D-FE458B78B681}']
    function GetConnection : T;
  end;

  ILmxDataSet = interface
    ['{3476E0D7-59E9-46A8-8C8B-7A3DE595965E}']

    procedure DisableControls;
    procedure EnableControls;
    function ExecSQL : Integer;

    function GetConnection : ILmxConnection;
    procedure SetConnection(const AValue : ILmxConnection);
    function GetCommandText : string;
    procedure SetCommandText(const AValue : string);
    function GetDataSet : TDataSet;

    procedure SetParams(const AValue : ILmxParamsSql);

    procedure Close;

    property Connection : ILmxConnection read GetConnection write SetConnection;
    property CommandText : string read GetCommandText write SetCommandText;

  end;

  ILmxQuery = interface(ILmxDataSet)
    ['{5E4B9B4A-82A9-4171-BF2C-A9B110C57E5E}']

    function GetSQL : TStrings;
    function GetFields : TFields;

    property SQL : TStrings read GetSQL;
    procedure Open;

    function IsEmpty : Boolean;
    property Fields : TFields read GetFields;

  end;

  ILmxDataSet<T> = interface(ILmxDataSet)
    ['{22DB49E4-FEAD-4EF7-9CFB-CECE9376C293}']


  end;

  ILmxQuery<T> = interface(ILmxQuery)
    ['{D3A6E073-DB09-4149-98BA-9996A28F62D0}']
  end;

  ILmxProxy = interface
    ['{FF301E57-6E3F-45EC-A777-BB616A241627}']
    function Buscar(const pFiltro : string = '') : string;
  end;

  ILmxGeradorConsulta = interface
    ['{EF6A534A-42FC-4887-95F3-7C9ED1D7AFCE}']

//    procedure SetUserId(const pUserId : Integer);
//    function GetUserId : Integer;

    function GetRequisicaoCliente : ILmxRequisicaoCliente;
    procedure SetRequisicaoCliente(pRequisicao : ILmxRequisicaoCliente);

    procedure GerarConsulta;

    function GetFieldFullName(const ACampo : string; out AFiltrar : Boolean) : string;
    function GetDescricaoCampo(const ACampo : string) : string;
    function GetCampoVisivel(const ACampo : string) : Boolean;

    function DoEditMaskCampo(const ACampo, AMascara : string) : ILmxGeradorConsulta;

    function From(const ATabela : string; const AAlias : string = '') : ILmxGeradorConsulta;
    function AddCampo(const ATabelaOrAlias : string; const ACampo : string; const ADescricao : string = '') : ILmxGeradorConsulta;
    function AddCampoCalculado(const ACalculo, ACampo : string; const ADescricao : string = '') : ILmxGeradorConsulta;
    function AddCondicao(const ACondicao : string) : ILmxGeradorConsulta;
    function AddOrderBy(const AOrderBy : string) : ILmxGeradorConsulta;

    function leftJoin(const ATabela : string; const AAlias : string; const ACondicao : string) : ILmxGeradorConsulta;
    function InnerJoin(const ATabela : string; const AAlias : string; const ACondicao : string) : ILmxGeradorConsulta;

    function ToString : string;
  end;


  ILmxCadastroView = interface(ILmxBaseView)
    ['{40698F84-C51E-4224-A4E8-D4FC6F61784A}']
    procedure Build(const ADescricao : string; const AController : TLmxControllerBase; const ASomenteLeitura : Boolean = True); overload;

    procedure ToView;

    procedure ToController;
    function PermiteEditar : Boolean;
  end;

  ILmxManutencaoView = interface(ILmxCadastroView)
    ['{35E3F5DC-59EF-4648-8D69-38FFE400681B}']

  end;

  ILmxLancamentoView = interface(ILmxBaseView)
    ['{9E874CFE-0B49-4C65-97DB-FFC5EEF5E20C}']
    procedure Build(const ADescricao : string; const AController : TLmxControllerBase); overload;

    procedure ToController;
    procedure Avancar;
    procedure Retornar;
  end;

  ILmxControllerView = interface
    ['{B2460C82-1534-4338-95E4-DBA176BDC38E}']
    function GetControllerClass : TLmxControllerBaseClass;
    procedure SetController(const AController : TLmxControllerBase);
    procedure SetDescricao(const ADescricao : string);
    function GetDescricao  : string;
    function PossuiTelaRegistrada : Boolean;
    function Mostrar(const AOwner : TComponent = nil) : Boolean;
    function Listar(const AOwner : TComponent; const pDescricao, pChave : string; const pConsulta : ILmxGeradorConsulta) : Boolean;
  end;


  ILmxConsultaView = interface(ILmxBaseView)
    ['{384C915A-F4FD-4130-AB81-0FB525D43E27}']
    function GetCaption: string;
    procedure SetControlerView(const AControllerView : ILmxControllerView; const ASeguranca: TSegurancaController = nil);
    procedure Build(const ADescricao, ACampoChave : string; const AConsultaBase : ILmxGeradorConsulta); overload;
    procedure Build(const ADescricao, ACampoChave : string; const AProxy : ILmxProxy); overload;
    procedure Build(const ADescricao, ACampoChave, AConsultaBase : string); overload;
    procedure Build(const ADescricao, ACampoChave : string; const ADataSet : TClientDataSet); overload;
    function Consultar(const AInicial : string = '') : Integer; overload;
    function Consultar(out ASelecionados : TArray<Integer>;
      const AInicial: string = ''): Boolean; overload;
    function Selecionar(const AInicial : string = '') : Integer; overload;
    function Selecionar(out ASelecionados : TArray<Integer>;
      const AInicial: string = ''): Boolean; overload;
    function SetRetornoDefault(const pRetornarDefault : Boolean) : ILmxConsultaView;
  end;

  ILmxConsultaManutencaoView = interface(ILmxConsultaView)
    ['{1FFF9A0C-FDDB-4E8E-B843-37018D730D40}']
    function PermiteInserir : Boolean;
    function PermiteAlterar : Boolean;
    function PermiteExcluir : Boolean;

    function Salvar : Boolean;
  end;

  ILmxConsultaGenericaView = interface (ILmxConsultaView)
    ['{22D411E0-E6E4-41F1-8982-CCCD75803AA6}']
  end;

  ILmxCadastroView<T : TLmxControllerBase> = interface(ILmxCadastroView)
    ['{1380A1E6-348B-441F-8C48-9E8733259ADF}']
    function GetController : T;
    procedure Build(const ADescricao : string; const AController : T; const ASomenteLeitura : Boolean = True);
  end;

  ILmxLancamentoView<T : TLmxControllerBase> = interface(ILmxLancamentoView)
    ['{551DE849-DB99-47EE-8E83-64719F207BFB}']
    function GetController : T;
    procedure Build(const ADescricao : string; const AController : T);
  end;

  TLmxFaturasDictionary = class(TDictionary<string, Integer>);

  IPDVImpressora = interface
  ['{E3BF5313-2533-4DCB-9644-CAAA974DCAF8}']
  end;

  ILmxConfiguracoesView = interface(ILmxBaseView)
  ['{4CA4E0DF-9C1D-4849-99C6-6CDD0D738F02}']
  end;

  ILmxDataBaseView = interface(ILmxBaseView)
  ['{467C47BA-0277-4D5B-A066-7A1162D298B6}']
    procedure Fechar;
  end;

  ILmxDataBaseAtualizadorView = interface(ILmxDataBaseView)
  ['{4DFD7E0A-3FEC-4DC8-9957-E3F8B07B1BBF}']
    procedure AtualizarTela(const AMensagem : string);
    procedure NovaAlteracao(const AAlteracao : string);
  end;


implementation


{ TLmxContext }

function TLmxContext.GetObject: TObject;
begin
  Result := Self;
end;

function TLmxContext.GetRequisicaoCliente: ILmxRequisicaoCliente;
begin
  REsult := FRequisicao;
end;

function TLmxContext.GetServiceEvent(pGuid : TGuid): ILmxContext;
var
  ltmp: ILmxContext;
  lEventIntf: TLmxServicesEventInterfaces<ILmxContext>;
begin
  Result := nil;
  if GetServicesEvents.TryGetValue(pGuid, lEventIntf) then
  begin
    ltmp := lEventIntf;
    ltmp.SetRequisicaoCliente(Self.GetRequisicaoCliente);
    ltmp.SetServicesEvents(Self.GetServicesEvents);
    Result := ltmp;
  end;
end;

function TLmxContext.GetServicesEvents: TLmxServicesEventsInterface;
begin
  Result := FServicesEvents;
end;

function TLmxContext.GetUSerId: Integer;
begin
  Result := 0;
  if (FRequisicao <> nil)  then
    Result := FRequisicao.GetUSerId;
end;

procedure TLmxContext.SetRequisicaoCliente(
  const pRequisicao: ILmxRequisicaoCliente);
begin
  FRequisicao := pRequisicao;
end;

procedure TLmxContext.SetServicesEvents(
  const pServicesEvents: TLmxServicesEventsInterface);
begin
  FServicesEvents := pServicesEvents;
end;

end.

