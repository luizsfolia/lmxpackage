unit uLmxComandoDefault;

interface

uses
  uLmxComando, uLmxConexao, uLmxDataSet, SysUtils, uLmxCore, uLmxHelper,
  uLmxInterfaces;

type

  TLmxNovoItem<T : TBaseTabelaPadrao> = reference to function : T;

  TLmxComandoBaseDefault<T : TBaseTabelaPadrao> = class(TLmxComandoBase<T>)
  private
    FConexao: TLmxConexao;
  protected
    function GetSql: string; virtual;

    function DoExecutarAposCarregar(const ADataSet : TLmxDataSet) : Boolean; virtual;
    function DoExecutar: Boolean; override;
  public
    property Conexao : TLmxConexao read FConexao write FConexao;

    class function Criar(const AId : Integer; const AObjeto : T; const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil) : TLmxComandoBaseDefault<T>; reintroduce;
    class function CriarEExecutar(const AId : Integer; const AObjeto : T; const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil) : Boolean; reintroduce; overload; virtual;
    class function CriarEExecutar(const AObjeto : T; const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil) : Boolean; reintroduce; overload; virtual;
  end;

  TLmxComandoBaseDefaultList<T : TBaseList; TItem : TBaseTabelaPadrao> = class(TLmxComandoBase<T>)
  private
    FConexao: TLmxConexao;
    FOnNovoItem : TLmxNovoItem<TItem>;
    FConsultaCustomizada : string;
    FRequisicaoCliente: ILmxRequisicaoCliente;

    function GerarNovoItem(const ADataSet : TLmxDataSet; out AItem : TItem) : Boolean; virtual;
  protected
    function DoExecutarAposCarregar(const ADataSet : TLmxDataSet) : Boolean; overload; virtual;
    function DoExecutarAposCarregar(const ADataSet : TLmxDataSet; const AItem : TItem) : Boolean; overload; virtual;
    function DoGerarNovoItem(const ADataSet : TLmxDataSet; out AItem) : Boolean; virtual;
    function DoGetConsultaCustomizada(var AConsulta : string) : Boolean; virtual;
    function DoExecutar: Boolean; override;
  public
    property Conexao : TLmxConexao read FConexao write FConexao;
    property RequisicaoCliente : ILmxRequisicaoCliente read FRequisicaoCliente write FRequisicaoCliente;

    class function Criar(const AObjeto : T; const AOnNovoItem : TLmxNovoItem<TItem>;
      const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil; const AConsultaCustomizada : string = '') : TLmxComandoBaseDefaultList<T, TItem>; reintroduce;
    class function CriarEExecutar(const AObjeto : T; const AOnNovoItem : TLmxNovoItem<TItem>;
      const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil; const AConsultaCustomizada : string = ''
      ; const pRequisicaoCliente : ILmxRequisicaoCliente = nil) : Boolean; reintroduce; overload; virtual;
//    class function CriarEExecutar(const AObjeto : T; const AOnNovoItem : TLmxNovoItem<TItem>;
//      const ACache : TLmxCache = nil; const AConexao : TLmxConexao = nil) : Boolean; reintroduce; overload; virtual;
  end;


implementation

{ TLmxComandoBaseDefault<T> }

class function TLmxComandoBaseDefault<T>.Criar(const AId: Integer;
  const AObjeto: T; const ACache: TLmxCache;
  const AConexao: TLmxConexao): TLmxComandoBaseDefault<T>;
begin
  Result := Self.Create;
  Result.Id := AId;
  Result.Objeto := AObjeto;
  Result.Cache := ACache;
  Result.Conexao := AConexao;

  if Result.Conexao = nil then
    Result.Conexao := LmxConexao;
end;

class function TLmxComandoBaseDefault<T>.CriarEExecutar(const AId: Integer;
  const AObjeto: T; const ACache: TLmxCache;
  const AConexao: TLmxConexao): Boolean;
var
  lComando : TLmxComandoBaseDefault<T>;
begin
  if AObjeto = nil then
    raise Exception.Create('Objeto do tipo ' + T.ClassName + ' não instanciado !');

  lComando := Self.Criar(AId, AObjeto, ACache, AConexao); // Create;
  try
//    lComando.Id := AId;
//    lComando.Objeto := AObjeto;
//    lComando.Cache := ACache;
    Result := lComando.Executar;
  finally
    FreeAndNil(lComando)
  end;
end;

class function TLmxComandoBaseDefault<T>.CriarEExecutar(const AObjeto: T;
  const ACache: TLmxCache; const AConexao: TLmxConexao): Boolean;
begin
  Result := CriarEExecutar(AObjeto.Id, AObjeto, ACache, AConexao);
end;

function TLmxComandoBaseDefault<T>.DoExecutar: Boolean;
var
  lConsulta: TLmxDataSet;
  lSqlConsulta: string;
  lSql: string;
  lValido: Boolean;
begin
  Result := False;

  Objeto.Limpar;
  Objeto.Id := Id;

  lValido := False;
  lSql := GetSql;
  if lSql = '' then
  begin
    lSql := Objeto.GetScriptSelect;
    lValido := (Id > 0);
  end else
    lValido := True;

  if lValido and (FConexao.NovaConsulta(lSql, lConsulta)) then
  begin
    try
      if lConsulta.RecordCount > 0 then
      begin
        Objeto.DeDataSet(lConsulta);
        Result := DoExecutarAposCarregar(lConsulta);
      end;
    finally
      FreeAndNil(lConsulta);
    end;
  end;

  if not Result then
    Objeto.Limpar;
end;

function TLmxComandoBaseDefault<T>.DoExecutarAposCarregar(const ADataSet : TLmxDataSet): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseDefault<T>.GetSql: string;
begin
  Result := '';
end;

{ TLmxComandoBaseDefaultList<T, TItem> }

class function TLmxComandoBaseDefaultList<T, TItem>.Criar(const AObjeto: T; const AOnNovoItem : TLmxNovoItem<TItem>;
  const ACache: TLmxCache; const AConexao: TLmxConexao; const AConsultaCustomizada : string): TLmxComandoBaseDefaultList<T, TItem>;
begin
  Result := Self.Create;
  REsult.FOnNovoItem := AOnNovoItem;
  Result.Objeto := AObjeto;
  Result.Cache := ACache;
  Result.Conexao := AConexao;
  Result.FConsultaCustomizada := AConsultaCustomizada;
end;

class function TLmxComandoBaseDefaultList<T, TItem>.CriarEExecutar(
  const AObjeto: T; const AOnNovoItem : TLmxNovoItem<TItem>; const ACache: TLmxCache;
  const AConexao: TLmxConexao; const AConsultaCustomizada : string;
  const pRequisicaoCliente : ILmxRequisicaoCliente): Boolean;
var
  lComando : TLmxComandoBaseDefaultList<T, TItem>;
begin
  if AObjeto = nil then
    raise Exception.Create('Objeto do tipo ' + T.ClassName + ' não instanciado !');

  lComando := Self.Criar(AObjeto, AOnNovoItem, ACache, AConexao, AConsultaCustomizada);
  try
    lComando.RequisicaoCliente := pRequisicaoCliente;
    Result := lComando.Executar;
  finally
    FreeAndNil(lComando)
  end;
end;

function TLmxComandoBaseDefaultList<T, TItem>.DoExecutar: Boolean;
var
  lConsulta: TLmxDataSet;
  lSqlConsulta: string;
  lItem: TItem;
  lLimite: Integer;
begin
  Result := False;

  Objeto.Limpar;

  if FConexao = nil then
    FConexao := LmxConexao;

//  FConsultaCustomizada := Objeto.GetScriptSelect;
  if DoGetConsultaCustomizada(FConsultaCustomizada) then
  begin
    if FConsultaCustomizada = '' then
      lSqlConsulta := Objeto.GetScriptSelect
    else if Pos('SELECT', UpperCase(FConsultaCustomizada)) > 0 then
      lSqlConsulta := FConsultaCustomizada
    else if Pos('WHERE', UpperCase(FConsultaCustomizada)) > 0 then
      lSqlConsulta := Objeto.GetScriptSelect + ' ' + FConsultaCustomizada
    else
      lSqlConsulta := Objeto.GetScriptSelect + ' WHERE ' + FConsultaCustomizada;

    if Self.RequisicaoCliente <> nil then
    begin
      lLimite := Self.RequisicaoCliente.GetLimit;
//      if (lLimite = 0) and (Pos('WHERE',lSqlConsulta) = 0) then
//        lLimite := 30;
      if lLimite > 0 then
        lSqlConsulta := lSqlConsulta.Replace('SELECT', 'SELECT FIRST ' + lLimite.ToString);
    end;

    if FConexao.NovaConsulta(lSqlConsulta, lConsulta) then
    begin
      try
        while not lConsulta.Eof do
        begin
          GerarNovoItem(lConsulta, lItem);
          DoExecutarAposCarregar(lConsulta, lItem);
          lConsulta.Next;
        end;
        Result := True;
      finally
        FreeAndNil(lConsulta);
      end;
    end;
  end;

  if not Result then
    Objeto.Limpar
  else
    DoExecutarAposCarregar(lConsulta);

end;

function TLmxComandoBaseDefaultList<T, TItem>.DoExecutarAposCarregar(
  const ADataSet: TLmxDataSet; const AItem: TItem): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseDefaultList<T, TItem>.DoExecutarAposCarregar(
  const ADataSet: TLmxDataSet): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseDefaultList<T, TItem>.DoGerarNovoItem(
  const ADataSet: TLmxDataSet; out AItem): Boolean;
var
  lItem: TItem;
begin
  Result := False;
  if Assigned(FOnNovoItem) then
  begin
    lItem := FOnNovoItem;
    Result := True;
  end;
end;

function TLmxComandoBaseDefaultList<T, TItem>.DoGetConsultaCustomizada(
  var AConsulta: string): Boolean;
begin
  Result := True;
end;

function TLmxComandoBaseDefaultList<T, TItem>.GerarNovoItem(
  const ADataSet: TLmxDataSet; out AItem : TItem): Boolean;
var
  lItem: TItem;
begin
  Result := False;
  if Assigned(FOnNovoItem) then
  begin
    lItem := FOnNovoItem;
    lItem.DeDataSet(ADataSet);
    Objeto.Add(lItem);
    AItem := lItem;
    Result := True;
  end;
end;

end.
