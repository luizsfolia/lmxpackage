unit uLmxProxy;

interface

uses
  uLmxHttpRest, System.Rtti, Generics.Collections, System.SysUtils;

type
  TLmxRotaAttribute = class(TCustomAttribute)
  private
    FRota: string;
  public
    constructor Create(const pRota: string = '');
    property Rota: string read FRota write FRota;
  end;

  TLmxProxyBase = class;

  ILmxProxyHttpRest = interface
  ['{EABAB1E4-87EF-4C8E-BCFE-E880AB61EA14}']
    function GetRotaBase: string;
    procedure SetRotaBase(const Value: string);
    procedure SetProxy(pProxy: TLmxProxyBase);
    function AddParametro(const pNome: string; const pValue: TValue): ILmxProxyHttpRest;
    function SetObject(pObject: TObject): ILmxProxyHttpRest;
    function Get(pMetodoName: string = ''): TLmxResponseValue;
    function Post(pMetodoName: string = ''): TLmxResponseValue;
    function Put(pMetodoName: string = ''): TLmxResponseValue;
    function Delete(pMetodoName: string = ''): TLmxResponseValue;
  end;

  TLmxProxyHttpRest = class(TInterfacedObject, ILmxProxyHttpRest)
  private
    FHttpRest: TLmxHttpRest;
    FRotaBase: string;
    FProxy: TLmxProxyBase;
    FObject: TObject;
  public
    constructor Create(pLmxHttpRestClass: TLmxHttpRestClass);
    destructor Destroy; override;
    function GetRotaBase: string;
    procedure SetRotaBase(const Value: string);
    procedure SetProxy(pProxy: TLmxProxyBase);
    function SetObject(pObject: TObject): ILmxProxyHttpRest;
    function AddParametro(const pNome: string; const pValue: TValue): ILmxProxyHttpRest;
    function Get(pMetodoName: string = ''): TLmxResponseValue;
    function Post(pMetodoName: string = ''): TLmxResponseValue;
    function Put(pMetodoName: string = ''): TLmxResponseValue;
    function Delete(pMetodoName: string = ''): TLmxResponseValue;
    property RotaBase: string read GetRotaBase write SetRotaBase;
  end;

  TLmxProxyBase = class
  private
    FRotaBase: string;
  protected
    //class function Proxy: TLmxProxyBase;
    function CriarProxyHttpRest: ILmxProxyHttpRest; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    property RotaBase: string read FRotaBase;
    function NewHttpRest: ILmxProxyHttpRest;
  end;

  TLmxProxyBaseclass = class of TLmxProxyBase;

  TLmxHttpProxyBase<T: constructor, TLmxProxyBase> = class
    class function Proxy: T;
  end;

implementation


{ TWmsProxyBase<T> }

constructor TLmxProxyBase.Create;
var
  lRttiContext : TRttiContext;
  lRttiType    : TRttiType;
  lAttribute   : TCustomAttribute;
begin
  inherited;
  lRttiContext := TRttiContext.Create;
  lRttiType := lRttiContext.GetType(Self.ClassInfo);
  for lAttribute in lRttiType.GetAttributes do
  begin
    if lAttribute is TLmxRotaAttribute then
    begin
      FRotaBase := TLmxRotaAttribute(lAttribute).Rota;
    end;
  end;
end;

function TLmxProxyBase.CriarProxyHttpRest: ILmxProxyHttpRest;
begin
  Result := TLmxProxyHttpRest.Create(TLmxHttpRest);
end;

destructor TLmxProxyBase.Destroy;
begin
  inherited;
end;

function TLmxProxyBase.NewHttpRest: ILmxProxyHttpRest;
begin
  Result := CriarProxyHttpRest;
  Result.SetRotaBase(FRotaBase);
  Result.SetProxy(Self);
end;

{ TLmxAttributeRota }

constructor TLmxRotaAttribute.Create(const pRota: string);
begin
  FRota := pRota;
end;

class function TLmxHttpProxyBase<T>.Proxy: T;
begin
  Result := T.Create;
end;

{ TLmxProxyHttpRest }

function TLmxProxyHttpRest.AddParametro(const pNome: string; const pValue: TValue): ILmxProxyHttpRest;
begin
  FHttpRest.Parametro[pNome] := pValue;
  Result := self;
end;

constructor TLmxProxyHttpRest.Create(pLmxHttpRestClass: TLmxHttpRestClass);
begin
  FHttpRest := pLmxHttpRestClass.Create(nil);
end;

function TLmxProxyHttpRest.Delete(pMetodoName: string): TLmxResponseValue;
var
  lMetodo: string;
begin
  lMetodo := pMetodoName;
  if lMetodo <> '' then
    lMetodo := '/' + lMetodo;
  FHttpRest.Rota:= RotaBase + lMetodo;
  Result := FHttpRest.Delete;
end;

destructor TLmxProxyHttpRest.Destroy;
begin
  FHttpRest.Free;
  FProxy.Free;
  inherited;
end;

function TLmxProxyHttpRest.Get(pMetodoName: string): TLmxResponseValue;
var
  lMetodo: string;
begin
  lMetodo := pMetodoName;
  if lMetodo <> '' then
    lMetodo := '/' + lMetodo;
  FHttpRest.Rota:= RotaBase + lMetodo;
  Result := FHttpRest.Get;
end;

function TLmxProxyHttpRest.GetRotaBase: string;
begin
  Result := FRotaBase;
end;

function TLmxProxyHttpRest.Post(pMetodoName: string): TLmxResponseValue;
var
  lMetodo: string;
begin
  lMetodo := pMetodoName;
  if lMetodo <> '' then
    lMetodo := '/' + lMetodo;
  FHttpRest.Rota:= RotaBase + lMetodo;
  Result := FHttpRest.Post(FObject);
end;

function TLmxProxyHttpRest.Put(pMetodoName: string): TLmxResponseValue;
var
  lMetodo: string;
begin
  lMetodo := pMetodoName;
  if lMetodo <> '' then
    lMetodo := '/' + lMetodo;
  FHttpRest.Rota:= RotaBase + lMetodo;
  Result := FHttpRest.Put(FObject);
end;

function  TLmxProxyHttpRest.SetObject(pObject: TObject): ILmxProxyHttpRest;
begin
  FObject:= pObject;
  Result := Self;
end;

procedure TLmxProxyHttpRest.SetProxy(pProxy: TLmxProxyBase);
begin
  FProxy := pProxy;
end;

procedure TLmxProxyHttpRest.SetRotaBase(const Value: string);
begin
  FRotaBase := Value;
end;

end.
