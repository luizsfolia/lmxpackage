unit uLmxComandoManutencao;

interface

uses
  uLmxComando, uLmxConexao, uLmxDataSet, uLmxCore, SysUtils;

type

  TLmxComandoBaseManutencao<T : TBase> = class(TLmxComandoBase<T>)
  private
    function Inserir : Boolean;
    function Alterar(const ADataSet : TLmxDataSet) : Boolean;
  protected
    function DoAntesIncluir : Boolean; virtual;
    function DoAposIncluir : Boolean; virtual;
    function DoAntesAlterar(const ADataSet : TLmxDataSet) : Boolean; virtual;
    function DoAposAlterar(const ADataSet : TLmxDataSet) : Boolean; virtual;
    procedure DoNovoId(const ANovoId : Integer); virtual;
    function DoExecutar : Boolean; override;
    function Excluir : Boolean; overload;
  public
    function Executar : Boolean; override;

    class function Excluir(const AId : Integer; const AObjeto: T; const ACache: TLmxCache = nil; const pConexao : TLmxConexao = nil): Boolean; overload;
    class function CriarEExecutar(const AObjeto : T; const ACache : TLmxCache = nil; const pConexao : TLmxConexao = nil) : Boolean; overload; virtual;
  end;

implementation

{ TLmxComandoBaseManutencao<T> }

function TLmxComandoBaseManutencao<T>.Alterar(const ADataSet : TLmxDataSet): Boolean;
var
  lSql: string;
begin
  Result := False;
  if DoAntesAlterar(ADataSet) then
  begin
    lSql := Objeto.GetScriptUpdate(ADataSet);
    if lSql <> '' then
      Result := FConexao.Executar(lSql) > 0
    else
      Result := True;
    if Result then
      Result := DoAposAlterar(ADataSet);
  end;
end;

class function TLmxComandoBaseManutencao<T>.CriarEExecutar(const AObjeto: T;
  const ACache: TLmxCache; const pConexao : TLmxConexao): Boolean;
var
  lId: Integer;
begin
  if AObjeto is TBaseTabelaPadrao then
    lId := TBaseTabelaPadrao(AObjeto).Id
  else
    raise Exception.Create('O Objeto passado como parâmetro não é do tipo TBaseTabelaPadrao');

  Result := inherited CriarEExecutar(lId, AObjeto, ACache, pConexao);
end;

function TLmxComandoBaseManutencao<T>.DoAntesAlterar(
  const ADataSet: TLmxDataSet): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseManutencao<T>.DoAntesIncluir: Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseManutencao<T>.DoAposAlterar(
  const ADataSet: TLmxDataSet): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseManutencao<T>.DoAposIncluir: Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseManutencao<T>.DoExecutar: Boolean;
begin
  Result := True;
end;

procedure TLmxComandoBaseManutencao<T>.DoNovoId(const ANovoId: Integer);
begin
  if Objeto is TBaseTabelaPadrao then
    TBaseTabelaPadrao(Objeto).Id := ANovoId;
end;

class function TLmxComandoBaseManutencao<T>.Excluir(const AId : Integer; const AObjeto: T;
  const ACache: TLmxCache; const pConexao : TLmxConexao): Boolean;
var
  lComando : TLmxComandoBaseManutencao<T>;
begin
  lComando := Self.Create;
  try
    lComando.Id := AId;
    lComando.Objeto := AObjeto;
    lComando.Cache := ACache;
    lComando.Conexao := pConexao;
    Result := lComando.Excluir;
  finally
    FreeAndNil(lComando)
  end;
end;

function TLmxComandoBaseManutencao<T>.Excluir: Boolean;
var
  lSql: string;
begin
  Result := False;
  if FId > 0 then
  begin
    lSql := Objeto.GetScriptDelete;
    Result := FConexao.Executar(lSql) > 0;
    if Result and (FCache <> nil) then
      FCache.RetirarItem(FId, Objeto);
  end;
end;

function TLmxComandoBaseManutencao<T>.Executar: Boolean;
var
  lConsulta: TLmxDataSet;
  lSql: string;
  lScriptNovoId: string;
  lNovoId: Integer;
  lDeveInserir: Boolean;
  lDeveAlterar: Boolean;
begin
  Result := False;

  lDeveInserir := (FId = 0);

  if lDeveInserir and FUtilizarCache and FCache.ExisteItem<T>(TBaseClass(Objeto.ClassType), FId) then
    lDeveInserir := False;

  if not lDeveInserir then
  begin
    lSql :=  Objeto.GetScriptSelect;
    if FConexao.NovaConsulta(lSql, lConsulta) then
    begin
      try
        if lConsulta.IsEmpty then
        begin
          lDeveInserir := True;
        end else begin
          Result := Alterar(lConsulta);
        end;
      finally
        FreeAndNil(lConsulta);
      end;
    end;
  end;

  if lDeveInserir then
    Result := Inserir;

  if Result and (FId > 0) then
  begin
    Result := DoExecutar;
    if Result and FUtilizarCache and (FCache <> nil) then
      FCache.AtualizarItem(FId, FObjeto);
  end;

end;

function TLmxComandoBaseManutencao<T>.Inserir: Boolean;
var
  lScriptNovoId: string;
  lNovoId: Integer;
  lSql: string;
  lNomeSequenciador: string;
begin
  if FId = 0 then
  begin
    if Objeto.GetPossuiSequenciador(lNomeSequenciador) then
    begin
      lNovoId := FConexao.ProximaSequenciaUsandoSequenciador(lNomeSequenciador);
    end else begin
      lScriptNovoId := Objeto.GetScriptProximaSequencia;
      lNovoId := FConexao.ProximaSequencia(lScriptNovoId);
    end;
    FId := lNovoId;
    DoNovoId(lNovoId);
  end;
  if DoAntesIncluir then
  begin
    lSql := Objeto.GetScriptInsert;
    if lSql <> '' then
      Result := FConexao.Executar(lSql) > 0;
  end;
  if Result then
    Result := DoAposIncluir;
end;

end.
