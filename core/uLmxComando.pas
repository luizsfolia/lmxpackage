unit uLmxComando;

interface

uses
  SysUtils, uLmxCache, Generics.Collections, uLmxCore {$IFDEF MSWINDOWS}, Winapi.Windows,
  uLmxConexao {$ENDIF};

type

  TLmxComandoBase<T : TBase> = class;
  TLmxCacheDictionaryItem = class(TObjectDictionary<Integer, TBase>);
  TLmxCacheDictionary = class(TObjectDictionary<TBaseClass, TLmxCacheDictionaryItem>);

  TLmxCache = class
  private
    FCache : TLmxCacheDictionary;
    FInicioTempoDeVida: Integer;
    FTempoDeVida: Integer;
    FBloqueio : TMultiReadExclusiveWriteSynchronizer;
    procedure ValidarTempoDeVida;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Limpar;
    property TempoDeVida : Integer read FTempoDeVida write FTempoDeVida;

    procedure RegistrarCache(const AClasse : TBaseClass);
    function CarregarItem(const AId : Integer; const AItem : TBase) : Boolean; overload;
    function AtualizarItem(const AId : Integer; const AItem : TBase) : Boolean; overload;
    function ObterItem<T : TBase>(const AId : Integer; const AItem : T) : Boolean; overload;
    function CarregarItem<T : TBase>(const AId : Integer; const AItem : T;
      const AComando : TLmxComandoBase<T>) : Boolean; overload;
    function RetirarItem(const AId : Integer; const AItem : TBase) : Boolean; overload;
    function ExisteItem<T : TBase>(const AClasse : TBaseClass; const AId : Integer) : Boolean; overload;
  end;

  TLmxComandoBase = class
  protected
    procedure Inicializar; virtual;
    procedure Finalizar; virtual;

    function DoAntesExecutar : Boolean; virtual;
    function DoExecutar : Boolean; virtual; abstract;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Executar : Boolean; virtual;
  end;

  TLmxComandoBaseClass = class of TLmxComandoBase;

  TLmxComandoBase<T : TBase> = class(TLmxComandoBase)
  private
    procedure SetCache(const Value: TLmxCache);
    procedure SetConexao(const Value: TLmxConexao);
  protected
    FUtilizarCache: Boolean;
    FCarregadaDeCache: Boolean;
    FCache: TLmxCache;
    FId: Integer;
    FObjeto: T;
    FConexao : TLmxConexao;
  public
    constructor Create; override;

    property Id : Integer read FId write FId;
    property Objeto : T read FObjeto write FObjeto;
    property Cache : TLmxCache read FCache write SetCache;
    property Conexao : TLmxConexao read FConexao write SetConexao;
    property UtilizarCache : Boolean read FUtilizarCache write FUtilizarCache;
    property CarregadaDeCache : Boolean read FCarregadaDeCache;

    function Executar : Boolean; override;

    class function Criar(const AId : Integer; const AObjeto : T; const ACache : TLmxCache = nil; const pConexao : TLmxConexao = nil) : TLmxComandoBase<T>;
    class function CriarEExecutar(const AId : Integer; const AObjeto : T; const ACache : TLmxCache = nil; const pConexao : TLmxConexao = nil) : Boolean; overload; virtual;
  end;

  TComandoListaBase = class


  end;

  TComandoListaBaseClass = class of TComandoListaBase;

//  TComandoListaBase<T : TBaseTabelaPadrao, constructor; TLista : TBaseList<T>, constructor;
//    TComandoLista : TLmxComandoBaseDefaultList<TLista, T>; TComandoGet : TLmxComandoBaseDefault<T>;
//    TComandoPost : TLmxComandoBaseManutencao<T>> = class(TComandoListaBase)
//
//  end;

//  protected
//    function DoProcessarComando(const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean; override;
//    function DoProcessarComandoPost(const AInfoComando : TLmxInfoComandoProcessadoNoServidor) : Boolean; override;
//  end;


  TLmxRegistroComandoItem = class
  private
    FComando: TComandoListaBaseClass;
  public
    constructor Create(const AComando : TComandoListaBaseClass);
    property Comando : TComandoListaBaseClass read FComando;
  end;

//  TLmxRegistroComandoItemList = class(TObjectList<TClass, TLmxRegistroComandoItem>))
//
//  end;

  TLmxRegistroComandoList = class(TObjectDictionary<TClass, TLmxRegistroComandoItem>)

  end;

  TLmxRegistroComando = class
  private
    FRegistros : TLmxRegistroComandoList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Registrar(const AClasseObjeto : TClass; const AComando : TLmxComandoBaseClass);
    function ObterComando(const AClasseObjeto : TClass; out  AComando : TLmxComandoBaseClass) : Boolean;
  end;

  function LmxCache : TLmxCache;
  function LmxRegistroComando : TLmxRegistroComando;

implementation

var
  FLmxCache : TLmxCache;
  FLmxRegistroComando : TLmxRegistroComando;

function LmxCache : TLmxCache;
begin
  Result := FLmxCache;
end;

function LmxRegistroComando : TLmxRegistroComando;
begin
  Result := FLmxRegistroComando
end;

{ TLmxComandoBase }

constructor TLmxComandoBase.Create;
begin
  Inicializar;
end;

destructor TLmxComandoBase.Destroy;
begin
  Finalizar;
  inherited;
end;

function TLmxComandoBase.DoAntesExecutar: Boolean;
begin
  Result := True;
end;

function TLmxComandoBase.Executar: Boolean;
begin
  Result := DoAntesExecutar;
  if Result then
    Result := DoExecutar;
end;

procedure TLmxComandoBase.Finalizar;
begin

end;

procedure TLmxComandoBase.Inicializar;
begin

end;

{ TLmxComandoBase<T> }

constructor TLmxComandoBase<T>.Create;
begin
  inherited;
  FUtilizarCache := True;
  FCache := LmxCache;
end;

class function TLmxComandoBase<T>.Criar(const AId: Integer;
  const AObjeto: T; const ACache : TLmxCache; const pConexao : TLmxConexao): TLmxComandoBase<T>;
begin
  Result := Self.Create;
  Result.Id := AId;
  Result.Objeto := AObjeto;
  Result.Cache := ACache;
  Result.Conexao := pConexao;
end;

class function TLmxComandoBase<T>.CriarEExecutar(const AId: Integer;
  const AObjeto: T; const ACache : TLmxCache; const pConexao : TLmxConexao): Boolean;
var
  lComando : TLmxComandoBase<T>;
begin
  if AObjeto = nil then
    raise Exception.Create('Objeto do tipo ' + T.ClassName + ' não instanciado !');

  lComando := Self.Create;
  try
    lComando.Id := AId;
    lComando.Objeto := AObjeto;
    lComando.Cache := ACache;
    lComando.Conexao := pConexao;
    Result := lComando.Executar;
  finally
    FreeAndNil(lComando)
  end;
end;

function TLmxComandoBase<T>.Executar: Boolean;
begin
  Result := False;
  if FUtilizarCache and (FCache <> nil) then
    Result := FCache.CarregarItem<T>(FId, FObjeto, Self);
  if not Result then
    Result := inherited Executar;
end;

procedure TLmxComandoBase<T>.SetCache(const Value: TLmxCache);
begin
  if Value <> nil then
    FCache := Value
  else
    FCache := LmxCache;
end;

procedure TLmxComandoBase<T>.SetConexao(const Value: TLmxConexao);
begin
  if Value <> nil then
    FConexao := Value
  else
    FConexao := LmxConexao;
end;

{ TLmxCache }

function TLmxCache.AtualizarItem(const AId: Integer;
  const AItem: TBase): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
  lObjetoItem: TBase;
begin
  FBloqueio.BeginWrite;
  try

    ValidarTempoDeVida;
    lObjetoItem := nil;
    if FCache.TryGetValue(TBaseClass(AItem.ClassType), lItem) then
    begin
      if lItem.TryGetValue(AId, lObjetoItem) then
        lObjetoItem.DeOutro(AItem);
    end;
    Result := lObjetoItem <> nil;
  finally
    FBloqueio.EndWrite;
  end;
end;

function TLmxCache.CarregarItem(const AId: Integer;
  const AItem: TBase): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
  lPair: TPair<TBaseClass, TLmxCacheDictionaryItem>;
  lClasseBase: TBaseClass;
  lObjetoItem: TBase;
begin
  FBloqueio.BeginRead;

  try
    ValidarTempoDeVida;
    lObjetoItem := nil;
    if FCache.TryGetValue(TBaseClass(AItem.ClassType), lItem) then
    begin
      if not lItem.TryGetValue(AId, lObjetoItem) then
      begin
        FBloqueio.BeginWrite;
        try
          lPair := FCache.ExtractPair(TBaseClass(AItem));
          lClasseBase := lPair.Key;
          lObjetoItem := lClasseBase.Create;
          lObjetoItem.DeOutro(AItem);
          lItem.Add(AId, lObjetoItem);
        finally
          FBloqueio.EndWrite;
        end;
      end;
    end;
    Result := lObjetoItem <> nil;
  finally

    FBloqueio.EndRead;
  end;
end;

function TLmxCache.CarregarItem<T>(const AId: Integer; const AItem: T;
  const AComando: TLmxComandoBase<T>): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
  lPair: TPair<TBaseClass, TLmxCacheDictionaryItem>;
  lClasseBase: TBaseClass;
  lObjetoItem: TBase;
  lObjetoBase : T;
begin
  FBloqueio.BeginRead;
  try
    ValidarTempoDeVida;
    lObjetoItem := nil;
    if AId > 0 then
    begin
      if FCache.TryGetValue(TBaseClass(AItem.ClassType), lItem) then
      begin
        if not lItem.TryGetValue(AId, lObjetoItem) then
        begin
          lPair := FCache.ExtractPair(AItem);
          lClasseBase := TBaseClass(AItem.ClassType);
          lObjetoItem := lClasseBase.Create;
          AComando.UtilizarCache := False;
          try
            FBloqueio.BeginWrite;
            try
              if AComando.Executar then
              begin
                AComando.FCarregadaDeCache := True;
                lObjetoItem.DeOutro(AItem);
                lItem.Add(AId, lObjetoItem);
              end else
                FreeAndNil(lObjetoItem);
            finally
              FBloqueio.EndWrite;
            end;
          finally
            AComando.UtilizarCache := True;
          end;
        end else
          AItem.DeOutro(lObjetoItem);
      end;
    end;
    Result := (lObjetoItem <> nil);
  finally
    FBloqueio.EndRead;
  end;
end;

function TLmxCache.ObterItem<T>(const AId: Integer;
  const AItem: T): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
  lPair: TPair<TBaseClass, TLmxCacheDictionaryItem>;
  lClasseBase: TBaseClass;
  lObjetoItem: TBase;
  lObjetoBase : T;
begin
  FBloqueio.BeginRead;
  try
    ValidarTempoDeVida;
    lObjetoItem := nil;
    if FCache.TryGetValue(TBaseClass(AItem.ClassType), lItem) then
    begin
      if not lItem.TryGetValue(AId, lObjetoItem) then
      begin
        lPair := FCache.ExtractPair(AItem);
        lClasseBase := TBaseClass(AItem.ClassType);
        lObjetoItem := lClasseBase.Create;
        lObjetoItem.DeOutro(AItem);
        lItem.Add(AId, lObjetoItem);
      end else
        AItem.DeOutro(lObjetoItem);
    end;
    Result := (lObjetoItem <> nil);
  finally
    FBloqueio.EndRead;
  end;
end;

constructor TLmxCache.Create;
begin
  FInicioTempoDeVida := {$IFDEF MSWINDOWS} GetTickCount {$ELSE} 0 {$ENDIF};
  FTempoDeVida := 0;
  FCache := TLmxCacheDictionary.Create([doOwnsValues]);
  FBloqueio := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TLmxCache.Destroy;
begin
  FreeAndNil(FBloqueio);
  FreeAndNil(FCache);
  inherited;
end;

function TLmxCache.ExisteItem<T>(const AClasse : TBaseClass; const AId: Integer): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
begin
  FBloqueio.BeginRead;
  try
    Result := FCache.TryGetValue(AClasse, lItem) and lItem.ContainsKey(AId);
  finally
    FBloqueio.EndRead;
  end;
end;

procedure TLmxCache.Limpar;
var
  lEnum: TObjectDictionary<TBaseClass, TLmxCacheDictionaryItem>.TPairEnumerator;
begin
  FBloqueio.BeginWrite;
  try
    lEnum := FCache.GetEnumerator;
    try
      while lEnum.MoveNext do
        lEnum.Current.Value.Clear;
    finally
      FreeAndNil(lEnum);
    end;
  finally
    FBloqueio.EndWrite;
  end;
end;

procedure TLmxCache.RegistrarCache(const AClasse: TBaseClass);
var
  lItem: TLmxCacheDictionaryItem;
begin
  FBloqueio.BeginWrite;
  try

    if not FCache.ContainsKey(AClasse) then
    begin
      lItem := TLmxCacheDictionaryItem.Create([doOwnsValues]);
      FCache.Add(AClasse, lItem);
    end;

  finally
    FBloqueio.EndWrite;
  end;
end;

function TLmxCache.RetirarItem(const AId: Integer;
  const AItem: TBase): Boolean;
var
  lItem: TLmxCacheDictionaryItem;
begin
  FBloqueio.BeginRead;
  try
    ValidarTempoDeVida;
    if FCache.TryGetValue(TBaseClass(AItem.ClassType), lItem) then
      lItem.Remove(AId);
    Result := True;
  finally
    FBloqueio.EndRead;
  end;
end;

procedure TLmxCache.ValidarTempoDeVida;
var
  lTick: Integer;
begin
  lTick := {$IFDEF MSWINDOWS} GetTickCount {$ELSE} 0 {$ENDIF};
  if (FTempoDeVida > 0) and ((lTick - FInicioTempoDeVida) > FTempoDeVida) then
    Limpar;
end;

{ TLmxRegistroComando }

constructor TLmxRegistroComando.Create;
begin
  FRegistros := TLmxRegistroComandoList.Create;
end;

destructor TLmxRegistroComando.Destroy;
begin
  FreeAndNil(FRegistros);
  inherited;
end;

function TLmxRegistroComando.ObterComando(
  const AClasseObjeto: TClass; out  AComando : TLmxComandoBaseClass) : Boolean;
//var
//  lComandoItem: TLmxRegistroComandoItem;
begin
  REsult := False;
//  AComando := nil;
//  Result := FRegistros.TryGetValue(AClasseObjeto, lComandoItem);
//  if Result then
//    AComando := lComandoItem.Comando;
end;

procedure TLmxRegistroComando.Registrar(const AClasseObjeto : TClass; const AComando : TLmxComandoBaseClass);
//var
//  lItem: TLmxRegistroComandoItem;
begin
//  lItem := TLmxRegistroComandoItem.Create(AComando);
//  FRegistros.Add(AClasseObjeto, lItem);
end;

{ TLmxRegistroComandoItem }

constructor TLmxRegistroComandoItem.Create(const AComando: TComandoListaBaseClass);
begin
  FComando := AComando;
end;

initialization
  FLmxCache := TLmxCache.Create;
  FLmxRegistroComando := TLmxRegistroComando.Create;

finalization
  FreeAndNil(FLmxCache);
  FreeAndNil(FLmxRegistroComando);

end.
