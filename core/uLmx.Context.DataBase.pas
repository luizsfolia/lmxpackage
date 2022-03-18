unit uLmx.Context.DataBase;

interface

uses
  uLmxInterfaces, uLmxConexao, uLmx.Service.DataBase, uLmxCore, uLmxComandoDefault, uLmxComandoManutencao,
  uLmxDataSet, uLmxHelper, uLmxSerialization;

type

  IContextDataBase = interface(ILmxContext)
    ['{35ECD329-7BEA-4E2F-A0EF-1B4ED765B8B2}']
    function ObterConexao : TLmxConexao;
    procedure SetConexao(const pConexao : TLmxConexao);
  end;

  TContextDataBase = class(TLmxContext, IContextDataBase)
  private
    FConexao : TLmxConexao;
    FManterConexao : Boolean;
  public
    function ObterConexao : TLmxConexao;
    procedure SetConexao(const pConexao : TLmxConexao);
    function GetServiceEvent(pGuid : TGuid) : ILmxContext; override;

    destructor Destroy; override;
  end;

  IContextDataBase<T : TBaseTabelaPadrao> = interface(IContextDataBase)
    ['{0D477DE8-45CC-4A74-82E7-8E1857FC8295}']

    function PermiteDeletar(const pObjeto : T) : Boolean;

    function Buscar(const pGerador : ILmxGeradorConsulta; const pFiltro : string = '') : string; overload;
    function Buscar(const pFiltro : string = '') : string; overload;
    function Lista : TBaseList<T>;
    function ById(const pId : Integer) : T;
    function Incluir(pObjeto : T; out AId : Integer) : Boolean;
    function Salvar(const pObjeto : T) : Boolean;
    function Deletar(const pId : Integer) : Boolean;
    function Desabilitar(const pId : Integer) : Boolean;
    function Habilitar(const pId : Integer) : Boolean;
  end;

  TContextDataBase<T : TBaseTabelaPadrao> = class(TContextDataBase, IContextDataBase<T>)
  private
    FLista : TBaseList<T>;
  protected
    function TemRelacionamento(const pTabela : string; const pCampoRelacionamento : string; const pId : Integer) : Boolean;
    function PermiteDeletar(const pObjeto : T) : Boolean; virtual;
    function GetConsultaBuscar : ILmxGeradorConsulta; virtual;
    function Buscar(const pGerador : ILmxGeradorConsulta; const pFiltro : string = '') : string; overload;
    function Buscar(const pConsulta : string; const pFiltro : string = '') : string; overload;
  public
    function Buscar(const pFiltro : string = '') : string; overload;
    function Lista : TBaseList<T>; virtual;
    function ById(const pId : Integer) : T; virtual;
    function Incluir(pObjeto : T; out AId : Integer) : Boolean; virtual;
    function Salvar(const pObjeto : T) : Boolean; virtual;
    function Deletar(const pId : Integer) : Boolean; virtual;
    function Desabilitar(const pId : Integer) : Boolean; virtual;
    function Habilitar(const pId : Integer) : Boolean; virtual;
  end;


implementation

uses
  System.SysUtils;

{ TContextDataBase }

destructor TContextDataBase.Destroy;
begin
  if not FManterConexao then
    FConexao.Free;
  inherited;
end;

function TContextDataBase.GetServiceEvent(pGuid: TGuid): ILmxContext;
begin
  Result := inherited GetServiceEvent(pGuid);
  if Result <> nil then
    (Result as IContextDataBase).SetConexao(Self.ObterConexao);
end;

function TContextDataBase.ObterConexao: TLmxConexao;
begin
  if FConexao = nil then
  begin
    if TContextDataBaseConfig.Default.ClasseConexao = nil then
      raise Exception.Create('TContextDataBaseConfig.Default.ClasseConexao está sem ser atribuída');

    FConexao := TContextDataBaseConfig.Default.ClasseConexao.Create;
    FConexao.ConfigurarConexao(TContextDataBaseConfig.Default.ControleConexao);
    FConexao.OnQueryExecute := TContextDataBaseConfig.Default.OnQueryExecute;
  end;
  Result := FConexao;
end;

procedure TContextDataBase.SetConexao(const pConexao: TLmxConexao);
begin
  FConexao := pConexao;
  FManterConexao := True;
end;

{ TContextDataBase<T> }

function TContextDataBase<T>.Buscar(const pGerador : ILmxGeradorConsulta; const pFiltro: string): string;
var
  lConsulta: ILmxGeradorConsulta;
  lDataSet: TLmxDataSet;
begin
  lConsulta := pGerador;
  if lConsulta <> nil then
  begin
    if Self.ObterConexao.NovaConsulta(lConsulta, lDataSet, pFiltro) then
    begin
      try
        if Self.GetRequisicaoCliente.GetResponseBuscarComoJson then
          Result := TLmxSerialization.ExternalDataSetToJsonArrayString(lDataSet.DataSet)
        else
          Result := lDataSet.DataSet.XMLData;
      finally
        lDataSet.Free;
      end;
    end;
  end;
end;

function TContextDataBase<T>.Buscar(const pFiltro: string): string;
begin
  Result := Buscar(GetConsultaBuscar, pFiltro);
end;

function TContextDataBase<T>.Buscar(const pConsulta, pFiltro: string): string;
var
  lDataSet: TLmxDataSet;
begin
  if Self.ObterConexao.NovaConsulta(pConsulta, lDataSet, pFiltro) then
  begin
    try
      Result := lDataSet.DataSet.XMLData;
    finally
      lDataSet.Free;
    end;
  end;
end;

function TContextDataBase<T>.ById(const pId: Integer): T;
begin
  Result := T.Create;
  TLmxComandoBaseDefault<T>.CriarEExecutar(pId, Result, nil, Self.ObterConexao);
end;

function TContextDataBase<T>.Deletar(const pId: Integer): Boolean;
var
  lObjeto: T;
begin
  Result := False;
  lObjeto := ById(pId);
  try
    if PermiteDeletar(lObjeto) then
      Result := TLmxComandoBaseManutencao<T>.Excluir(pId, lObjeto, nil, ObterConexao);
  finally
    lObjeto.Free;
  end;
end;

function TContextDataBase<T>.Desabilitar(const pId: Integer): Boolean;
var
  lObjeto: T;
begin
  lObjeto := ById(pId);
  try
    Self.ObterConexao.Executar(lObjeto.GetScriptActive(False));
    Result := True;
  finally
    lObjeto.Free;
  end;
end;

function TContextDataBase<T>.GetConsultaBuscar: ILmxGeradorConsulta;
begin
  Result := nil;
end;

function TContextDataBase<T>.Habilitar(const pId: Integer): Boolean;
var
  lObjeto: T;
begin
  lObjeto := ById(pId);
  try
    Self.ObterConexao.Executar(lObjeto.GetScriptActive(True));
    Result := True;
  finally
    lObjeto.Free;
  end;
end;

function TContextDataBase<T>.Incluir(pObjeto: T; out AId: Integer): Boolean;
begin
  pObjeto.Id := 0;
  Result := TLmxComandoBaseManutencao<T>.CriarEExecutar(pObjeto, nil, Self.ObterConexao);
  AId := pObjeto.Id;
end;

function TContextDataBase<T>.Lista: TBaseList<T>;
begin
  if FLista = nil then
  begin
    FLista := TBaseList<T>.Create;
    TLmxComandoBaseDefaultList<TBaseList<T>, T>.CriarEExecutar(FLista, function : T begin Result := T.Create end, nil, Self.ObterConexao, '', Self.GetRequisicaoCliente);
  end;
  Result := FLista;
end;

function TContextDataBase<T>.PermiteDeletar(const pObjeto : T): Boolean;
begin
  Result := True;
end;

function TContextDataBase<T>.Salvar(const pObjeto: T): Boolean;
begin
  Result := TLmxComandoBaseManutencao<T>.CriarEExecutar(pObjeto, nil, Self.ObterConexao);
end;

function TContextDataBase<T>.TemRelacionamento(const pTabela,
  pCampoRelacionamento: string; const pId: Integer): Boolean;
const
  SQL =
    'SELECT COUNT(1) contagem FROM %s WHERE %s = :%s';
var
  lConsulta : TLmxDataSet;
  lSql: string;
begin
  lSql := Format(SQL, [pTabela, pCampoRelacionamento, pCampoRelacionamento]);
  if Self.ObterConexao.NovaConsulta(lSql, lConsulta, TLmxParamsSql.Create.AddParam(pCampoRelacionamento, pId)) then
  begin
    try
      Result := (lConsulta.FieldByName('contagem').AsInteger > 0);
    finally
      lConsulta.Free;
    end;
  end;
end;

end.
