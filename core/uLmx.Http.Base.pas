unit uLmx.Http.Base;

interface


uses
  uLmxInterfaces, uLmxConexao, uLmxCore, uLmxComandoDefault, uLmxComandoManutencao,
  uLmxDataSet, uLmxHttpServer, uLmxAttributes, uLmx.Context.DataBase;

type

  THttp<T  : TBaseTabelaPadrao, constructor; TContexto : IContextDataBase<T>; TLista : TBaseList<T>, constructor> = class(TLmxServerComand)
  private
    FContext : TContexto;
  protected
    function GetContext : TContexto; virtual;
  public
    [HttpGet]
    [TLmxAttributeComando('')]
    function Get([FromServices] pContext : TContexto) : ILmxRetorno<TLista>;

    [HttpGet]
    [TLmxAttributeComando('/{Id}')]
    function GetById(
      [FromServices]  pContext : TContexto;
      [FromParams] const Id : Integer) : ILmxRetorno<T>;

    [HttpPost]
    [TLmxAttributeComando('')]
    function Post(
      [FromServices]  pContext : TContexto;
      [FromBody] const pObject : T) : ILmxRetorno<T>;

    [HttpPut]
    [TLmxAttributeComando('/{Id}')]
    function Put(
      [FromServices]  pContext : TContexto;
      [FromParams] const Id : Integer;
      [FromBody] const pObject : T) : ILmxRetorno<T>;

    [HttpDelete]
    [TLmxAttributeComando('/{Id}')]
    function Delete(
      [FromServices]  pContext : TContexto;
      [FromParams] const Id : Integer) : Boolean;

    [HttpGet]
    [TLmxAttributeComando('/Buscar')]
    function Buscar([FromServices] pContext : TContexto;
      [FromQuery] const pFiltro : string) : string;

    [HttpPost]
    [TLmxAttributeComando('/Habilitar')]
    function Habilitar(
      [FromServices]  pContext : TContexto;
      [FromBody] const pObject : T) : ILmxRetorno<T>;

    [HttpPut]
    [TLmxAttributeComando('/Desabilitar')]
    function Desabilitar(
      [FromServices]  pContext : TContexto;
      [FromBody] const pObject : T) : ILmxRetorno<T>;

  end;

implementation


{ THttp<T, IContexto, TLista> }

function THttp<T, TContexto, TLista>.Buscar(pContext: TContexto;
  const pFiltro: string): string;
begin
  Result := pContext.Buscar(pFiltro);
end;

function THttp<T, TContexto, TLista>.Delete(pContext: TContexto;
  const Id: Integer): Boolean;
begin
  Result := pContext.Deletar(Id);
end;

function THttp<T, TContexto, TLista>.Desabilitar(pContext: TContexto;
  const pObject: T): ILmxRetorno<T>;
var
  lObjeto: T;
begin
  pContext.Desabilitar(pObject.Id);
  lObjeto := pContext.ById(pObject.Id);
  Result := TLmxRetorno<T>.Create(lObjeto);
end;

function THttp<T, TContexto, TLista>.Get(
  pContext: TContexto): ILmxRetorno<TLista>;
begin
  Result := TLmxRetorno<TLista>.Create(TLista(pContext.Lista));
end;

function THttp<T, TContexto, TLista>.GetById(pContext: TContexto;
  const Id: Integer): ILmxRetorno<T>;
begin
  REsult := TLmxRetorno<T>.Create(pContext.ById(Id));
end;

function THttp<T, TContexto, TLista>.GetContext: TContexto;
begin
  if FContext = nil then
    FContext := Self.GetComandoProcessado.InfoComando.Server.ObterService<TContexto>(Self);
  Result := FContext;
end;

function THttp<T, TContexto, TLista>.Habilitar(pContext: TContexto;
  const pObject: T): ILmxRetorno<T>;
var
  lObjeto: T;
begin
  pContext.Habilitar(pObject.Id);
  lObjeto := pContext.ById(pObject.Id);
  Result := TLmxRetorno<T>.Create(lObjeto);
end;

function THttp<T, TContexto, TLista>.Post(pContext: TContexto;
  const pObject: T): ILmxRetorno<T>;
var
  lId: Integer;
begin
  if pContext.Incluir(pObject, lId) then
    pObject.Id := lId;
  Result := TLmxRetorno<T>.Create(pObject, True);
end;

function THttp<T, TContexto, TLista>.Put(pContext: TContexto;
  const Id : Integer; const pObject: T): ILmxRetorno<T>;
begin
  Result := nil;
  if Id > 0 then
  begin
    pObject.Id := Id;
    pContext.Salvar(pObject);
    Result := TLmxRetorno<T>.Create(pObject, True);
  end;
end;

end.
