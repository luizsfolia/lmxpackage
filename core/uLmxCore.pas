unit uLmxCore;

interface

uses
  Generics.Collections, uLmxDataSet, SysUtils, DB, uLmxAttributes, RTTI, TypInfo, Classes, DBClient;

var
  FContextoBase : TRttiContext;

type

  TBase = class;
  TBaseList = class;

  TBaseClass = class of TBase;

//  TBaseList = class(TObjectList<TBase>)
//  public
//    constructor Create; reintroduce;
//    procedure Limpar;
//  end;

  TOnCriarDataSet = reference to procedure (const ADataSet : TClientDataSet);
  TOnGerarRegistroBase = reference to procedure (const ADataSet : TDataSet; const AObjeto : TBase);
  TOnGerarDataSetVinculado = reference to procedure (const ANomeObjeto : string; const AObjeto : TBase; out ADataSet : TDataSet);

  TBaseVerificador = class(TList<TBase>)
  public
    function JaVerificou(const AObjeto : TBase) : Boolean;
  end;

  TBaseField = class
  private
    FForeingKey: Boolean;
    FPrimaryKey: Boolean;
    FValor: string;
    FNome: string;
    FZeroIsNull: Boolean;
    FTamanho: Integer;
    FActiveField: Boolean;
  public
    property Nome : string read FNome write FNome;
    property Valor : string read FValor write FValor;
    property Tamanho : Integer read FTamanho write FTamanho;
    property PrimaryKey : Boolean read FPrimaryKey write FPrimaryKey;
    property ForeingKey : Boolean read FForeingKey write FForeingKey;
    property ZeroIsNull : Boolean read FZeroIsNull write FZeroIsNull;
    property ActiveField : Boolean read FActiveField write FActiveField;

    procedure CopiarDe(const AField : TBaseField);
    function Clonar: TBaseField;
  end;

  TBaseFieldList = class(TObjectDictionary<string,TBaseField>)
  public
    constructor Create; reintroduce;
  end;

  TBase = class(TInterfacedPersistent)
  private
    FFilhos : TObjectList<TBase>;
//    FVerificados : TBaseVerificador;
    function InternalIgualAEste(const AOutro : TBase; const AVerificados : TBaseVerificador) : Boolean; virtual;
    procedure InternalLimpar(const AVerificados : TBaseVerificador); virtual;
    procedure InternalDeOutro(const AOutro : TBase; const AVerificados : TBaseVerificador); virtual;
    procedure InternalDeDataSet(const ADataSet : TLmxDataSet; const AVerificados : TBaseVerificador); overload; virtual;
    procedure InternalDeDataSet(const ADataSet : TDataSet; const AVerificados : TBaseVerificador); overload; virtual;
    procedure InternalParaDataSet(const ADataSet : TDataSet; const AVerificados : TBaseVerificador; const AOnGerarRegistroBase : TOnGerarRegistroBase = nil); overload; virtual;
    procedure InternalCriarDataSet(const ADataSet : TClientDataSet; const AVerificados : TBaseVerificador; const AOnGerarDataSetVinculado : TOnGerarDataSetVinculado = nil); virtual;

    function InternalDiferencas(const AOutro : TBase; const AVerificados : TBaseVerificador; out AFieldList : TBaseFieldList) : Boolean; overload; virtual;
    function InternalDiferencas(const ADataSet : TLmxDataSet; const AVerificados : TBaseVerificador; out AFieldList : TBaseFieldList) : Boolean; overload; virtual;

    function InternalGetFieldValue(const AField : TRttiProperty; const AFieldValueBase : TBaseField) : string; overload; virtual;
//    function InternalGetFieldValue(const AField : TRttiProperty) : string; overload; virtual;
    function InternalGetFieldName(const AField : TRttiProperty; const AFieldValueBase : TBaseField) : string; overload; virtual;
    function InternalGetFieldName(const AField : TRttiProperty; out APrimaryKey : Boolean) : string; overload; virtual;
    function InternalGetFieldName(const AField : TRttiProperty; out APrimaryKey : Boolean; out AZeroIsNull : Boolean) : string; overload; virtual;
    function InternalGetCondicaoPk(const AType : TRttiType) : string; virtual;
    function InternalGettableName(const AType : TRttiType) : string; virtual;
    function InternalGetFiledProperties(const AType : TRttiType; out AFieldList : TBaseFieldList;
      out AFiledPkList : TBaseFieldList) : Boolean; virtual;
    function InternalGetPossuiSequence(const AType : TRttiType; out ANome : string) : Boolean; virtual;
    function InternalGetFieldNameActive(const AType : TRttiType; out ANome : string) : Boolean; virtual;

    function InternalToScriptProximaSequencia(const AVerificados : TBaseVerificador) : string; virtual;
    function InternalToScript(const ANomeTabela, ACondicao : string) : string; overload;
    function InternalToScript(const AVerificados : TBaseVerificador; const ACondicao : string) : string; overload; virtual;
    function InternalToScriptSelect(const AVerificados : TBaseVerificador) : string; virtual;
    function InternalToScriptInsert(const AVerificados : TBaseVerificador) : string; virtual;
    function InternalToScriptUpdate(const AVerificados : TBaseVerificador; const ARegistroAtual : TBase = nil; const ADataSet : TLmxDataSet = nil) : string; virtual;
    function InternalToScriptDelete(const AVerificados : TBaseVerificador; const ARegistroAtual : TBase = nil; const ADataSet : TLmxDataSet = nil) : string; virtual;
    function InternalToScriptActive(const AVerificados : TBaseVerificador; const ARegistroAtual : TBase = nil; const ADataSet : TLmxDataSet = nil) : string; virtual;
    function InternalToScriptInActive(const AVerificados : TBaseVerificador; const ARegistroAtual : TBase = nil; const ADataSet : TLmxDataSet = nil) : string; virtual;
    function InternalGetValorPk : Integer; virtual;
    procedure InternalSetValorPk(const AValor : Integer); virtual;
  protected
    procedure DoLimpar(const AVerificados : TBaseVerificador); virtual;
    procedure DoAdicionarFilho(const AClasseFilho : TBaseClass; out AFilho); virtual;
    procedure DoRemoverFilho(const AFilho : TBase); virtual;
    procedure Inicializar; virtual;
    procedure Finalizar; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Limpar; virtual;

    procedure DeDataSet(const ADataSet : TLmxDataSet); overload; virtual;
    procedure DeDataSet(const ADataSet : TDataSet); overload; virtual;
    procedure DeOutro(const AOutro : TBase); virtual;
    procedure CriarDataSet(const ADataSet : TClientDataSet; const ACriarDataSet : Boolean = True; const AOnCriarDataSet : TOnCriarDataSet = nil); virtual;
    procedure GerarRegistro(const ADataSet : TDataSet; const AOnGerarRegistroBase : TOnGerarRegistroBase = nil); overload; virtual;
    function GetScriptProximaSequencia : string;
    function GetPossuiSequenciador(out ANome : string) : Boolean;
    function GetScript(const ACondicao : string) : string;
    function GetScriptSelect : string;
    function GetScriptInsert : string;
    function GetScriptUpdate : string; overload;
    function GetScriptUpdate(const ARegistroAtual : TBase) : string; overload;
    function GetScriptUpdate(const ARegistroAtual : TLmxDataSet) : string; overload;
    function GetScriptDelete : string;
    function GetScriptActive(const pActive : Boolean) : string;

    function GetValorCampoPk : Integer;
    procedure SetValorCampoPk(const AValor : Integer);

    function IgualAEste(const AOutro : TBase) : Boolean; virtual;

    function EstaVazio : Boolean; virtual;
  end;

  TBaseTabelaPadrao = class(TBase)
  private
    FId: Integer;
  public
    [TLmxAttributeMetadata('',mtcAuto,True)]
    [TLmxAttributeMetadataPrimaryKey]
    property Id : Integer read FId write FId;

    procedure DeOutro(const AOutro : TBase); override;
    procedure DeDataSet(const ADataSet: TLmxDataSet); override;
    function EstaVazio : Boolean; override;
  end;

  TOnGerarRegistro<T : TBase> = reference to procedure (const ADataSet : TDataSet; const AObjeto : T);

  TBaseList = class(TBase, ILmxEnumerable)
  private
    FDescription : string;
//    function GetEnumerator: TEnumerator<TBase>;
  protected
    FLista : TObjectList<TBase>;
    function GetItemClass : TBaseClass; virtual;
    function GetItem(const AIndex: Integer): TBase;
    function GetItemObject(const AIndex: Integer): TObject;
    function GetDescription : string; virtual;

    procedure SetItem(const AIndex: Integer; const Value: TBase);
    function InternalToScriptSelect(const AVerificados : TBaseVerificador) : string; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function Count : Integer;
    function GetNewItemObject: TObject;

    property Item[const AIndex : Integer] : TBase read GetItem write SetItem;
    function Add(const AItem : TBase) : Integer; virtual;
    function IndexOf(const AItem : TBase) : Integer;
    function First : TBase;
    function Last : TBase;

    procedure Clear;

    procedure Limpar; override;
    procedure SetDescription(const ADescription : string);

    procedure DeDataSet(const ADataSet : TLmxDataSet); override;
    procedure DeOutro(const AOutro : TBaseList); reintroduce; virtual;
    procedure GerarRegistro(const ADataSet : TDataSet; const AOnGerarRegistroBase : TOnGerarRegistroBase = nil); overload; override;

    procedure CriarDataSet(const ADataSet : TClientDataSet; const ACriarDataSet : Boolean = True; const AOnCriarDataSet : TOnCriarDataSet = nil); override;
    function IgualAEste(const AOutro : TBaseList) : Boolean; reintroduce; virtual;
    function EstaVazio : Boolean; override;
  end;

  TBaseListEnum<T : Class, constructor> = class(TInterfacedPersistent, ILmxEnumerable)
  private
    FList : TObjectList<T>;
  protected
    function GetItemObject(const AIndex: Integer): TObject;
    function GetNewItemObject: TObject;
    function GetDescription : string; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    function GetEnumerator: TEnumerator<T>;
    function First : T;
    function Remove(const Value : T) : Integer;
    procedure Clear;

    function Add(const Value : T) : Integer; overload;
    function Add : T; overload;
    function Count: Integer;
  end;

  TBaseList<T : TBase> = class(TBaseList)
  private
    function GetItem(const AIndex: Integer): T;
    procedure SetItem(const AIndex: Integer; const Value: T);
  protected
    function GetItemClass : TBaseClass; override;
    function InternalGettableName(const AClass : TClass) : string; reintroduce; overload;
    function InternalToScriptSelect(const AVerificados : TBaseVerificador) : string; override;
  public
    property Item[const AIndex : Integer] : T read GetItem write SetItem; default;
    function GetList : TList<T>;

    function GetEnumerator: TEnumerator<T>;

    procedure GerarRegistro(const ADataSet : TDataSet; const AOnGerarRegistro : TOnGerarRegistro<T>); overload;
  end;



implementation

{ TBaseTabelaPadrao }

procedure TBaseTabelaPadrao.DeDataSet(const ADataSet: TLmxDataSet);
begin
  inherited;
  FId := ADataSet.FieldByName('Id').AsInteger;
end;

procedure TBaseTabelaPadrao.DeOutro(const AOutro: TBase);
begin
  inherited;
  if AOutro <> nil then
    FId := TBaseTabelaPadrao(AOutro).Id;
end;

function TBaseTabelaPadrao.EstaVazio: Boolean;
begin
  Result := FId = 0;
end;

{ TBaseList }

function TBaseList.Add(const AItem: TBase): Integer;
begin
//  FControleLista.BeginWrite;
//  try
    Result := FLista.Add(AItem);
//  finally
//    FControleLista.EndWrite;
//  end;
end;

procedure TBaseList.Clear;
begin
  FLista.Clear;
end;

function TBaseList.Count: Integer;
begin
//  FControleLista.BeginRead;
//  try
    Result := FLista.Count;
//  finally
//    FControleLista.EndRead;
//  end;
end;

constructor TBaseList.Create;
begin
  inherited Create;
  FDescription := Self.ClassName;
  FLista := TObjectList<TBase>.Create;
//  FControleLista := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TBaseList.CriarDataSet(const ADataSet: TClientDataSet; const ACriarDataSet : Boolean;
  const AOnCriarDataSet : TOnCriarDataSet);
begin
  if Count > 0 then
    Item[0].CriarDataSet(ADataSet, ACriarDataSet, AOnCriarDataSet);
end;

procedure TBaseList.DeDataSet(const ADataSet: TLmxDataSet);
var
  lItem: TBase;
begin
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    lItem := GetItemClass.Create;
    lItem.DeDataSet(ADataSet);
    FLista.Add(lItem);
    ADataSet.Next;
  end;
end;

procedure TBaseList.DeOutro(const AOutro: TBaseList);
var
  I: Integer;
  lItem: TBase;
begin
  for I := 0 to AOutro.Count - 1 do
  begin
    lItem := GetItemClass.Create;
    lItem.DeOutro(AOutro.Item[I]);
    FLista.Add(lItem);
  end;
end;

destructor TBaseList.Destroy;
begin
//  FreeAndNil(FControleLista);
  FreeAndNil(FLista);
  inherited;
end;

function TBaseList.EstaVazio: Boolean;
begin
  Result := (Count = 0);
end;

function TBaseList.First: TBase;
begin
  Result := FLista.First;
end;

procedure TBaseList.GerarRegistro(const ADataSet: TDataSet; const AOnGerarRegistroBase : TOnGerarRegistroBase);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Item[I].GerarRegistro(ADataSet, AOnGerarRegistroBase);
end;

//function TBaseList.GetEnumerator: TEnumerator<TBase>;
//begin
//  Result := FLista.GetEnumerator;
//end;

function TBaseList.GetDescription: string;
begin
  Result := FDescription;
end;

function TBaseList.GetItem(const AIndex: Integer): TBase;
begin
//  FControleLista.BeginRead;
//  try
    Result := FLista.Items[AIndex];
//  finally
//    FControleLista.EndRead;
//  end;
end;

function TBaseList.GetItemClass: TBaseClass;
begin
  Result := TBase;
end;

function TBaseList.GetItemObject(const AIndex: Integer): TObject;
begin
  Result := GetItem(AIndex);
end;

function TBaseList.GetNewItemObject: TObject;
var
  lResultado: TBase;
begin
  lResultado := GetItemClass.Create;
  Self.Add(lResultado);
  Result := lResultado;
end;

function TBaseList.IgualAEste(const AOutro: TBaseList): Boolean;
begin
  Result := (Count = AOutro.Count);
end;

function TBaseList.IndexOf(const AItem: TBase): Integer;
begin
  Result := FLista.IndexOf(AItem);
end;

function TBaseList.InternalToScriptSelect(
  const AVerificados: TBaseVerificador): string;
begin
  REsult := '';
end;

function TBaseList.Last: TBase;
begin
  Result := FLista.Last;
end;

procedure TBaseList.Limpar;
begin
//  FControleLista.BeginWrite;
//  try
    FLista.Clear;
//  finally
//    FControleLista.Free;
//  end;
end;

procedure TBaseList.SetDescription(const ADescription: string);
begin
  FDescription := ADescription;
end;

procedure TBaseList.SetItem(const AIndex: Integer; const Value: TBase);
begin
//  FControleLista.BeginWrite;
//  try
    FLista.Items[AIndex] := Value;
//  finally
//    FControleLista.EndWrite;
//  end;
end;

{ TBase }

constructor TBase.Create;
begin
  FFilhos := TObjectList<TBase>.Create;
  Inicializar;
end;

procedure TBase.DeDataSet(const ADataSet: TLmxDataSet);
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    InternalDeDataSet(ADataSet, lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

procedure TBase.CriarDataSet(const ADataSet: TClientDataSet; const ACriarDataSet : Boolean;
  const AOnCriarDataSet : TOnCriarDataSet);
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    InternalCriarDataSet(ADataSet, lVerificados);
    if ACriarDataSet and (ADataSet.FieldDefList.Count > 0) and (not ADataSet.Active) then
    begin
      if Assigned(AOnCriarDataSet) then
        AOnCriarDataSet(ADataSet);
      ADataSet.CreateDataSet;
    end;
  finally
    FreeAndNil(lVerificados);
  end;
end;

procedure TBase.DeDataSet(const ADataSet: TDataSet);
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    InternalDeDataSet(ADataSet, lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

procedure TBase.DeOutro(const AOutro: TBase);
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    InternalDeOutro(AOutro, lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

destructor TBase.Destroy;
begin
  Finalizar;
  FreeAndNil(FFilhos);
  inherited;
end;

procedure TBase.DoAdicionarFilho(const AClasseFilho: TBaseClass; out AFilho);
begin
  TBase(AFilho) := AClasseFilho.Create;
  FFilhos.Add(TBase(AFilho));
end;

procedure TBase.DoLimpar(const AVerificados: TBaseVerificador);
begin

end;

procedure TBase.DoRemoverFilho(const AFilho: TBase);
begin
  FFilhos.Remove(AFilho);
end;

function TBase.EstaVazio: Boolean;
begin
  Result := False;
end;

procedure TBase.Finalizar;
begin
end;

procedure TBase.GerarRegistro(const ADataSet: TDataSet; const AOnGerarRegistroBase : TOnGerarRegistroBase);
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    InternalParaDataSet(ADataSet, lVerificados, AOnGerarRegistroBase);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetPossuiSequenciador(out ANome: string): Boolean;
begin
  Result := InternalGetPossuiSequence(FContextoBase.GetType(Self.ClassType), ANome);
end;

function TBase.GetScript(const ACondicao: string): string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScript(lVerificados, ACondicao);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptActive(const pActive: Boolean): string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    if pActive then
      Result := InternalToScriptActive(lVerificados)
    else
      Result := InternalToScriptInActive(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptDelete: string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptDelete(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptInsert: string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptInsert(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptProximaSequencia: string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptProximaSequencia(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptSelect: string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptSelect(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptUpdate(const ARegistroAtual: TLmxDataSet): string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptUpdate(lVerificados, nil, ARegistroAtual);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetValorCampoPk: Integer;
begin
  REsult := InternalGetValorPk;
end;

function TBase.GetScriptUpdate(const ARegistroAtual: TBase): string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptUpdate(lVerificados, ARegistroAtual, nil);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.GetScriptUpdate: string;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalToScriptUpdate(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

function TBase.IgualAEste(const AOutro: TBase): Boolean;
var
  lVerificados: TBaseVerificador;
begin
  lVerificados := TBaseVerificador.Create;
  try
    Result := InternalIgualAEste(AOutro, lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;
end;

procedure TBase.Inicializar;
begin

end;

procedure TBase.InternalDeDataSet(const ADataSet : TLmxDataSet; const AVerificados: TBaseVerificador);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lFieldDataSet: TField;
  lValor: TValue;
  lId: Integer;
  lIsFk: Boolean;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin

    lRttiType := FContextoBase.GetType(Self.ClassType);

    lRttiProperties := lRttiType.GetProperties;

    for lField in lRttiProperties do
    begin
      lNomeCampo := '';
      lIsFk := False;
      lFieldAtributes := lField.GetAttributes;
      for lFieldAtribute in lFieldAtributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
        begin
          lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
            .NomeCampo;
        end;

        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
        begin
          lIsFk := True;
        end;

      end;

      if lNomeCampo = EmptyStr then
        lNomeCampo := lField.Name;

      if lIsFk then
        lNomeCampo := lNomeCampo + '_id';

      if lNomeCampo <> EmptyStr then
      begin
        lFieldDataSet := ADataSet.FindField(lNomeCampo);
        if (lField.PropertyType.TypeKind = tkClass) then
        begin
          if lFieldDataSet <> nil then
          begin
            if (lField.GetValue(Self).IsInstanceOf(TBase)) and (not lField.GetValue(Self).IsEmpty) then
            begin
              try
                lId := lFieldDataSet.AsInteger;
              except
                lId := 0;
              end;
              TBase(lField.GetValue(Self).AsObject).SetValorCampoPk(lId);
            end;
          end;
//          if (lField.GetValue(Self).IsInstanceOf(TBaseTabelaPadrao)) then
//            TBaseTabelaPadrao(lField.GetValue(Self).AsObject).Id := lFieldDataSet.AsInteger;
        end else begin
  //        if (lField.GetValue(Self).IsInstanceOf(TBase)) then
  //          TBase(lField.GetValue(Self).AsObject).InternalDeDataSet(AVerificados);
  //      end else begin
            if lFieldDataSet <> nil then
            begin

              case lField.PropertyType.TypeKind of
                tkEnumeration  : lField.SetValue(Self, TValue.FromOrdinal(lField.PropertyType.Handle, lFieldDataSet.AsInteger));
                tkInteger,
                tkInt64        : lField.SetValue(Self, TValue.From<Integer>(lFieldDataSet.AsInteger));

                tkChar,
                tkWChar,
                tkString,
                tkLString,
                tkWString,
                tkUString      : lField.SetValue(Self, TValue.From<String>(lFieldDataSet.AsString));

                tkFloat        :
                  begin
                    if lField.PropertyType.QualifiedName = 'System.TDateTime' then
                    begin
                      try
                        lValor := TValue.From<Extended>(lFieldDataSet.AsExtended);
                      except
                        lValor := TValue.From<Extended>(StrToDateTimeDef(StringReplace(lFieldDataSet.AsString, '.', '/', [rfReplaceAll]), 0));
                      end;
                      lField.SetValue(Self, lValor);
                    end else
                      lField.SetValue(Self, TValue.From<Double>(lFieldDataSet.AsFloat));
                  end;
                tkVariant      : lField.SetValue(Self, TValue.FromVariant(lFieldDataSet.AsVariant));
              end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TBase.InternalCriarDataSet(const ADataSet: TClientDataSet;
  const AVerificados: TBaseVerificador; const AOnGerarDataSetVinculado : TOnGerarDataSetVinculado);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lFieldDataSet: TField;
  lTamanhoCampo: Integer;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);

    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      lNomeCampo := EmptyStr;
      lTamanhoCampo := 0;
      lFieldAtributes := lField.GetAttributes;
      for lFieldAtribute in lFieldAtributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
        begin
          lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
            .NomeCampo;
          lTamanhoCampo := TLmxAttributeMetadata(lFieldAtribute)
            .Tamanho;
        end;
      end;
      if lNomeCampo = EmptyStr then
        lNomeCampo := lField.Name;

      if (lField.PropertyType.TypeKind = tkClass) then
      begin
        lFieldDataSet := ADataSet.FindField(lNomeCampo);
        if lFieldDataSet = nil then
          ADataSet.FieldDefs.Add(lNomeCampo, ftInteger, lTamanhoCampo);
      end else begin
        lFieldDataSet := ADataSet.FindField(lNomeCampo);
        if lFieldDataSet = nil then
        begin
          case lField.PropertyType.TypeKind of
            tkUnknown     : ADataSet.FieldDefs.Add(lNomeCampo, ftString);
            tkInteger     : ADataSet.FieldDefs.Add(lNomeCampo, ftInteger, lTamanhoCampo);
            tkChar        : ADataSet.FieldDefs.Add(lNomeCampo, ftString, lTamanhoCampo);
            tkEnumeration : ADataSet.FieldDefs.Add(lNomeCampo, ftInteger, lTamanhoCampo);
            tkFloat       : ADataSet.FieldDefs.Add(lNomeCampo, ftFloat, lTamanhoCampo);
            tkString      : ADataSet.FieldDefs.Add(lNomeCampo, ftString, lTamanhoCampo);
            tkUString     : ADataSet.FieldDefs.Add(lNomeCampo, ftString, lTamanhoCampo);
          end;
        end;
      end;
    end;
  end;
end;

procedure TBase.InternalDeDataSet(const ADataSet: TDataSet;
  const AVerificados: TBaseVerificador);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lFieldDataSet: TField;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin

    lNomeCampo := EmptyStr;
    lRttiType := FContextoBase.GetType(Self.ClassType);

    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      lFieldAtributes := lField.GetAttributes;
      for lFieldAtribute in lFieldAtributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
        begin
          lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
            .NomeCampo;
        end;
      end;
      if lNomeCampo = EmptyStr then
        lNomeCampo := lField.Name;

      lFieldDataSet := ADataSet.FindField(lNomeCampo);
      if (lField.PropertyType.TypeKind = tkClass) then
      begin
        if (lField.GetValue(Self).IsInstanceOf(TBase)) then
          TBase(lField.GetValue(Self).AsObject).SetValorCampoPk(lFieldDataSet.AsInteger);
//          if (lField.GetValue(Self).IsInstanceOf(TBaseTabelaPadrao)) then
//            TBaseTabelaPadrao(lField.GetValue(Self).AsObject).Id := lFieldDataSet.AsInteger;
      end else begin
//      if not (lField.PropertyType.TypeKind = tkClass) then
//      begin
//        if (lField.GetValue(Self).IsInstanceOf(TBase)) then
//          TBase(lField.GetValue(Self).AsObject).InternalDeDataSet(AVerificados);
//      end else begin
          lFieldDataSet := ADataSet.FieldByName(lNomeCampo);
          if lFieldDataSet <> nil then
          begin

            case lField.PropertyType.TypeKind of
              tkEnumeration  : lField.SetValue(Self, TValue.FromOrdinal(lField.PropertyType.Handle, lFieldDataSet.AsInteger));
              tkInteger,
              tkInt64        : lField.SetValue(Self, TValue.From<Integer>(lFieldDataSet.AsInteger));

              tkChar,
              tkWChar,
              tkString,
              tkLString,
              tkWString,
              tkUString      : lField.SetValue(Self, TValue.From<String>(lFieldDataSet.AsString));

//              tkFloat        : lField.SetValue(Self, TValue.From<Double>(lFieldDataSet.AsFloat));
              tkFloat        :
                begin
                  if lField.PropertyType.QualifiedName = 'System.TDateTime' then
                    lField.SetValue(Self, TValue.From<Extended>(lFieldDataSet.AsExtended))
                  else
                    lField.SetValue(Self, TValue.From<Double>(lFieldDataSet.AsFloat));
                end;
              tkVariant      : lField.SetValue(Self, TValue.FromVariant(lFieldDataSet.AsVariant));
            end;
        end;
      end;
    end;
  end;
end;

procedure TBase.InternalDeOutro(const AOutro: TBase;
  const AVerificados: TBaseVerificador);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lLmxEnum: ILmxEnumerable;
  lIsBase: Boolean;
  lValueOutro: TValue;
  I: Integer;
  lObjeto: TObject;
  lLmxEnumOutro: ILmxEnumerable;
begin
  if AOutro = nil then
    Exit;
  if Self.Equals(AOutro) then
    Exit;
  if Self.ClassNameIs(AOutro.ClassName) or (AOutro.InheritsFrom(Self.ClassType)) or (Self.InheritsFrom(AOutro.ClassType)) then
  begin
    if (not AVerificados.JaVerificou(AOutro)) then
    begin
      lRttiType := FContextoBase.GetType(Self.ClassType);
      lRttiProperties := lRttiType.GetProperties;
      for lField in lRttiProperties do
      begin
        lValueOutro := lField.GetValue(AOutro);
        if (lField.PropertyType.TypeKind = tkClass) and (not lValueOutro.IsEmpty) then
        begin
          lIsBase := (lField.GetValue(Self).IsInstanceOf(TBase)) and (lValueOutro.IsInstanceOf(TBase)) and (not lField.GetValue(Self).IsEmpty);
          if lIsBase then
          begin
            if Supports(lField.GetValue(Self).AsObject, ILmxEnumerable) and (Supports(lValueOutro.AsObject, ILmxEnumerable)) then
            begin
              lLmxEnumOutro := lValueOutro.AsInterface as ILmxEnumerable;
              lLmxEnum := lField.GetValue(Self).AsInterface as ILmxEnumerable;
              for I := 0 to lLmxEnumOutro.Count - 1 do
              begin
                if lLmxEnumOutro.GetItemObject(I).InheritsFrom(TBase) then
                begin
                  lObjeto := lLmxEnum.GetNewItemObject;
                  TBase(lObjeto).InternalDeOutro(TBase(lLmxEnumOutro.GetItemObject(I)), AVerificados);
                end;
              end;
            end else
              TBase(lField.GetValue(Self).AsObject).InternalDeOutro(TBase(lValueOutro.AsObject), AVerificados);

//            if (lField.GetValue(Self).IsInstanceOf(TBase)) and (lField.GetValue(AOutro).IsInstanceOf(TBase)) and
//              (not lField.GetValue(Self).IsEmpty) then
//              TBase(lField.GetValue(Self).AsObject).InternalDeOutro(TBase(lField.GetValue(AOutro).AsObject), AVerificados);
          end;
        end else begin
          try
            if lField.IsWritable then
              lField.SetValue(Self, lField.GetValue(AOutro));
          except on E:Exception do
            begin
              raise Exception.Create(Format('Erro ao Copiar informações da Classe %s, campo %s : ' + E.Message, [AOutro.ClassName, lField.Name]));
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TBase.InternalDiferencas(const ADataSet: TLmxDataSet;
  const AVerificados: TBaseVerificador;
  out AFieldList: TBaseFieldList): Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lNomeCampo: string;
  lFieldDataSet: TField;
  lValor : TValue;
  lDiferente: Boolean;
  lPrimary: Boolean;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lvalorCampo: Integer;
  lBaseField: TBaseField;
  lCampoBase: TBase;
  lZeroIsNull: Boolean;
begin
//  if (not AVerificados.JaVerificou(Self)) then
//  begin
//    Result := False;
    AFieldList := TBaseFieldList.Create;
    lRttiType := FContextoBase.GetType(Self.ClassType);
    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      lNomeCampo := InternalGetFieldName(lField, lPrimary, lZeroIsNull);
      if lNomeCampo <> '' then
      begin
        lValor.Empty;
        lFieldDataSet := ADataSet.FieldByName(lNomeCampo);
        if lFieldDataSet <> nil then
        begin
          if (lField.PropertyType.TypeKind = tkClass) then
          begin
            lFieldAtributes := lField.GetAttributes;
            for lFieldAtribute in lFieldAtributes do
            begin
              if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
                lValor := TValue.From<Integer>(TBase(lField.GetValue(Self).AsObject).GetValorCampoPk);
            end;
            if not lValor.IsEmpty then
            begin
              lCampoBase := nil;
              if lField.GetValue(Self).AsObject.InheritsFrom(TBase) then
                lCampoBase := TBase(lField.GetValue(Self).AsObject);
              if lCampoBase <> nil then
              begin
                lvalorCampo := TBase(lField.GetValue(Self).AsObject).GetValorCampoPk;
                lBaseField := TBaseField.Create;
                try
                  if (lValorCampo = 0) and lZeroIsNull then
                    lBaseField.Valor := 'NULL'
                  else
                    lBaseField.Valor := IntToStr(lValorCampo);
                finally
                  lDiferente := (lValorCampo <> StrToIntDef(lFieldDataSet.AsString, 0));
                  if lDiferente then
                    AFieldList.AddOrSetValue(UpperCase(lFieldDataSet.FieldName), lBaseField)
                  else
                    FreeAndNil(lBaseField);
                end;
              end;
            end;
          end else begin
            case lField.PropertyType.TypeKind of
              tkEnumeration  :
                begin
                  if lField.PropertyType.QualifiedName = 'System.Boolean' then
                  begin
                    lValor := TValue.FromVariant(lFieldDataSet.AsInteger = 1)
                  end else
                    lValor := TValue.FromOrdinal(lField.PropertyType.Handle, lFieldDataSet.AsInteger);
                end;
              tkInteger,
              tkInt64        : lValor := TValue.From<Integer>(lFieldDataSet.AsInteger);

              tkChar,
              tkWChar,
              tkString,
              tkLString,
              tkWString,
              tkUString      : lValor := TValue.From<String>(lFieldDataSet.AsString);

              tkFloat        :
                begin
                  if lField.PropertyType.QualifiedName = 'System.TDateTime' then
                  begin
                    try
                      lValor := TValue.From<TDatetime>(lFieldDataSet.AsDateTime)
                    except
                      lValor := TValue.From<TDatetime>(StrToDateTimeDef(StringReplace(lFieldDataSet.AsString, '.', '/', [rfReplaceAll]), 0))
                    end;
                  end else
                    lValor := TValue.From<Double>(lFieldDataSet.AsFloat);
                end;
              tkVariant      : lValor := TValue.FromVariant(lFieldDataSet.AsVariant);
            end;

            if not lValor.IsEmpty then
            begin
              if lField.PropertyType.QualifiedName = 'System.Boolean' then
                lDiferente := (lField.GetValue(Self).AsBoolean <> lValor.AsBoolean)
              else if lField.PropertyType.QualifiedName = 'System.TDateTime' then
                lDiferente := (lField.GetValue(Self).AsExtended <> lValor.AsExtended)
              else if lField.PropertyType.TypeKind = tkEnumeration then
                lDiferente := (lField.GetValue(Self).AsOrdinal <> lValor.AsOrdinal)
              else
                lDiferente := (lField.GetValue(Self).AsVariant <> lValor.AsVariant);
              if lDiferente then
              begin
                lBaseField := TBaseField.Create;
                InternalGetFieldValue(lField, lBaseField);
                AFieldList.AddOrSetValue(UpperCase(InternalGetFieldName(lField, lPrimary)), lBaseField);
              end;
            end;
          end;
        end;

      end;
    end;
    Result := AFieldList.Count > 0;
//  end;
end;

function TBase.InternalDiferencas(const AOutro: TBase;
  const AVerificados: TBaseVerificador;
  out AFieldList: TBaseFieldList): Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lDiferente: Boolean;
  lPrimary: Boolean;
  lBaseField: TBaseField;
begin
  AFieldList := TBaseFieldList.Create;
  Result := False;
  if Self.Equals(AOutro) then
    Result := False;
  if not Self.ClassNameIs(AOutro.ClassName) then
    Result := False;

  if (not AVerificados.JaVerificou(AOutro)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      if (lField.PropertyType.TypeKind <> tkClass) then
      begin
        if lField.PropertyType.TypeKind = tkEnumeration then
          lDiferente := (lField.GetValue(Self).AsOrdinal <> lField.GetValue(AOutro).AsOrdinal)
        else
          lDiferente := (lField.GetValue(Self).AsVariant <> lField.GetValue(AOutro).AsVariant);
        if lDiferente then
        begin
          lBaseField := TBaseField.Create;
          InternalGetFieldValue(lField, lBaseField);
          AFieldList.AddOrSetValue(InternalGetFieldName(lField, lPrimary), lBaseField);
        end;
      end;
    end;
    Result := AFieldList.Count > 0;
  end;
end;

function TBase.InternalGetCondicaoPk(const AType : TRttiType): string;
var
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
begin
  InternalGetFiledProperties(AType, lFields, lPks);
  try
    lEnum := lPks.GetEnumerator;
    try
      Result := '';
      while lEnum.MoveNext do
      begin
        if Result <> '' then
          Result := Result + ' and ';
        Result := Result + '(' + lEnum.Current.Key + ' = ' + lEnum.Current.Value.Valor + ')';
      end;
    finally
      FreeAndNil(lEnum);
    end;
  finally
    FreeAndNil(lPks);
    FreeAndNil(lFields);
  end;
end;

function TBase.InternalGetFieldName(const AField : TRttiProperty; out APrimaryKey : Boolean): string;
var
  lZeroIsNull: Boolean;
begin
  Result := InternalGetFieldName(AField, APrimaryKey, lZeroIsNull);
end;

function TBase.InternalGetFieldName(const AField: TRttiProperty;
  out APrimaryKey, AZeroIsNull: Boolean): string;
var
  lBasefield: TBaseField;
begin
  lBasefield := TBaseField.Create;
  try
    InternalGetFieldName(AField, lBasefield);
    AZeroIsNull := lBasefield.ZeroIsNull;
    Result := lBasefield.Nome;
  finally
    FreeAndNil(lBasefield);
  end;
end;

function TBase.InternalGetFieldNameActive(const AType : TRttiType; out ANome: string): Boolean;
var
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
begin
  Result := False;
  InternalGetFiledProperties(AType, lFields, lPks);
  try
    lEnum := lFields.GetEnumerator;
    try
      ANome := '';
      while lEnum.MoveNext do
      begin
        if lEnum.Current.Value.ActiveField then
          ANome := lEnum.Current.Value.Nome;
      end;
    finally
      FreeAndNil(lEnum);
    end;
  finally
    FreeAndNil(lPks);
    FreeAndNil(lFields);
  end;
end;

function TBase.InternalGetFieldName(const AField: TRttiProperty;
  const AFieldValueBase: TBaseField): string;
var
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
begin
  Result := '';
  lFieldAtributes := AField.GetAttributes;
  for lFieldAtribute in lFieldAtributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
    begin
      Result := AField.Name + '_id';
      AFieldValueBase.ForeingKey := True;
      AFieldValueBase.ZeroIsNull := True;
    end else if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
    begin
      Result := TLmxAttributeMetadata(lFieldAtribute)
        .NomeCampo;
      if Result = EmptyStr then
        Result := AField.Name;
      AFieldValueBase.Tamanho := TLmxAttributeMetadata(lFieldAtribute).Tamanho;
    end else if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataPrimaryKey.ClassName) then
      AFieldValueBase.PrimaryKey := True
    else if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataZeroIsNull.ClassName) then
      AFieldValueBase.ZeroIsNull := True;

    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataActive.ClassName) then
      AFieldValueBase.ActiveField := True;

    AFieldValueBase.Nome := Result;
  end;
  Result := UpperCase(Result);
end;

function TBase.InternalGetFieldValue(const AField: TRttiProperty;
  const AFieldValueBase: TBaseField): string;
var
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lObterValor: Boolean;
  lObjeto: TBase;
  lTamanho: Integer;
  lZeroIsNull: Boolean;
  lValorCampo: Integer;


  function FormatarValor(const AValor : Double) : string;
  begin
    Result := FormatFloat('0.,00', AValor);
    Result := StringReplace(Result, '.', '', [rfReplaceAll]);
    Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
  end;

  function FormatarDateTime(const AValor : Double) : string;
  begin
    Result := '';
    if AValor <> 0 then
      Result := FormatDateTime('dd.mm.yyyy hh:nn:ss:zzzz', AValor);
  end;

begin
  Result := '';
//  AFieldValueBase := TBaseField.Create;

  lZeroIsNull := False;
  if (AField.PropertyType.TypeKind = tkClass) then
  begin
    lFieldAtributes := AField.GetAttributes;
    lObterValor := False;
    for lFieldAtribute in lFieldAtributes do
    begin
      if (lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName)) then
      begin
        lZeroIsNull := True;
        lObterValor := True;
      end else if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataZeroIsNull.ClassName) then
        lZeroIsNull := True;
    end;

    if lObterValor then
    begin
      AFieldValueBase.ForeingKey := True;
      lObjeto :=  TBase(AField.GetValue(Self).AsObject);
      if lObjeto <> nil then
      begin
        Result := IntToStr(TBase(AField.GetValue(Self).AsObject).GetValorCampoPk);
        if (Result = '0') and lZeroIsNull then
          Result := 'NULL';
      end;
    end;

  end else begin
    case AField.PropertyType.TypeKind of
      tkEnumeration  :
        if AField.PropertyType.QualifiedName = 'System.Boolean' then
        begin
          if AField.GetValue(Self).AsBoolean then
            Result := '1'
          else
            Result := '0';
        end
        else
          Result := intToStr(AField.GetValue(Self).AsOrdinal); // AField.SetValue(Self, TValue.FromOrdinal(AField.PropertyType.Handle, lFieldDataSet.AsInteger));
      tkInteger,
      tkInt64        :
        begin
          lValorCampo := AField.GetValue(Self).AsInteger;
          if (lValorCampo = 0) and lZeroIsNull then
            Result := 'NULL'
          else
            Result := intToStr(lValorCampo); //AField.SetValue(Self, TValue.From<Integer>(lFieldDataSet.AsInteger));
        end;
      tkChar,
      tkWChar,
      tkString,
      tkLString,
      tkWString,
      tkUString      :
        begin
          lTamanho := AFieldValueBase.Tamanho;
          if lTamanho = 0 then
            lTamanho := 20;
          Result := QuotedStr(copy(AField.GetValue(Self).AsString, 1, lTamanho)); // AField.SetValue(Self, TValue.From<String>(lFieldDataSet.AsString));
        end;
      tkFloat        :
        begin
          if AField.PropertyType.QualifiedName = 'System.TDateTime' then
            Result := QuotedStr(FormatarDateTime(AField.GetValue(Self).AsExtended))
          else
            Result := FormatarValor(AField.GetValue(Self).AsExtended);
          end;

      tkVariant      : Result := AField.GetValue(Self).AsString; // AField.SetValue(Self, TValue.FromVariant(lFieldDataSet.AsVariant));
    end;
  end;
  AFieldValueBase.Valor := Result;
end;

//function TBase.InternalGetFieldValue(const AField: TRttiProperty): string;
//var
//  lValor: TBaseField;
//begin
//  Result := InternalGetFieldValue(AField, lValor);
//  try
//
//  finally
//    FreeAndNil(lValor);
//  end;
//
//end;

function TBase.InternalGetFiledProperties(const AType : TRttiType;
  out AFieldList: TBaseFieldList; out AFiledPkList : TBaseFieldList): Boolean;
var
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lNomeCampo: string;
  lValorCampo : string;
//  lPrimaryKey : Boolean;
//  lZeroIsNull : Boolean;
  lBaseField: TBaseField;
begin
  AFieldList := TBaseFieldList.Create;
  AFiledPkList := TBaseFieldList.Create;
  lRttiProperties := AType.GetProperties;
  for lField in lRttiProperties do
  begin
    lBaseField := TBaseField.Create;
    lNomeCampo := InternalGetFieldName(lField, lBaseField); //lPrimarykey, lZeroIsNull);
    if lNomeCampo <> '' then
    begin
      lValorCampo := InternalGetFieldValue(lField, lBaseField);
      if lNomeCampo <> '' then
      begin
        AFieldList.AddOrSetValue(lNomeCampo, lBaseField);
        if lBaseField.PrimaryKey then
          AFiledPkList.AddOrSetValue(lNomeCampo, lBaseField.Clonar);
      end;
    end else
      FreeAndNil(lBaseField);
  end;
  Result := True;
end;

function TBase.InternalGettableName(const AType: TRttiType): string;
var
  lFieldAtribute: TCustomAttribute;
begin
  Result := '';
  for lFieldAtribute in AType.GetAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
    begin
      Result :=TLmxAttributeMetadata(lFieldAtribute).NomeCampo;
      if Result = EmptyStr then
        Result := Copy(Self.ClassName, 2, Length(Self.ClassName));
    end;
  end;
  Result := UpperCase(Result);
end;

function TBase.InternalGetValorPk: Integer;
var
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
  lRttiType: TRttiType;
begin
  Result := 0;
  lRttiType := FContextoBase.GetType(Self.ClassType);
  try
    InternalGetFiledProperties(lRttiType, lFields, lPks);
    try
      lEnum := lPks.GetEnumerator;
      try
        if lEnum.MoveNext then
          Result := StrToInt(lEnum.Current.Value.Valor);
      finally
        FreeAndNil(lEnum);
      end;
    finally
      FreeAndNil(lPks);
      FreeAndNil(lFields);
    end;
  finally
     lRttiType.Free;
  end;
end;

function TBase.InternalGetPossuiSequence(const AType: TRttiType; out ANome : string): Boolean;
var
  lFieldAtribute: TCustomAttribute;
begin
  Result := False;
  for lFieldAtribute in AType.GetAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataSequence.ClassName) then
    begin
      Result := True;
      ANome := TLmxAttributeMetadataSequence(lFieldAtribute).Nome
    end;
  end;
end;

function TBase.InternalIgualAEste(const AOutro: TBase;
  const AVerificados: TBaseVerificador): Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
begin
  Result := True;
  if Self.Equals(AOutro) then
    Exit;
  if not Self.ClassNameIs(AOutro.ClassName) then
    Result := False;

  if (not AVerificados.JaVerificou(AOutro)) and Result then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      if Result then
      begin
        if (lField.PropertyType.TypeKind = tkClass) and (not lField.GetValue(AOutro).IsEmpty) then
        begin
          if (lField.GetValue(Self).IsInstanceOf(TBase)) and (lField.GetValue(AOutro).IsInstanceOf(TBase)) and
            (not lField.GetValue(Self).IsEmpty) then
            Result := TBase(lField.GetValue(Self).AsObject).InternalIgualAEste(TBase(lField.GetValue(AOutro).AsObject), AVerificados);
        end
        else begin
          if lField.PropertyType.TypeKind = tkEnumeration then
            Result := (lField.GetValue(Self).AsOrdinal = lField.GetValue(AOutro).AsOrdinal)
          else
            Result := (lField.GetValue(Self).AsVariant = lField.GetValue(AOutro).AsVariant);
        end;
      end;
    end;
  end;
end;

procedure TBase.InternalLimpar(const AVerificados: TBaseVerificador);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lAtributo: TCustomAttribute;
  lNoClear: Boolean;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin
    DoLimpar(AVerificados);
    lRttiType := FContextoBase.GetType(Self.ClassType);
    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      lNoClear := False;
      for lAtributo in lField.GetAttributes do
      begin
        if (not lNoClear) and lAtributo.ClassNameIs(TLmxAttributeNoClear.ClassName) then
          lNoClear := True;
        if not lField.IsWritable then
          lNoClear := True;
      end;
      lNoClear := (not lNoClear) and ((lField.Name = 'RefCount') or (lField.Name = 'Disposed'));
      if (not lNoClear) then
      begin
        if (lField.PropertyType.TypeKind = tkClass) and (not lField.GetValue(Self).IsEmpty) then
        begin
          if (lField.GetValue(Self).IsInstanceOf(TBaseList)) and (not lField.GetValue(Self).IsEmpty) then
            TBaseList(lField.GetValue(Self).AsObject).Limpar
          else begin
            if (lField.GetValue(Self).IsInstanceOf(TBase)) and (not lField.GetValue(Self).IsEmpty)
              and (FFilhos.IndexOf(TBase(lField.GetValue(Self).AsObject)) = -1) then
              TBase(lField.GetValue(Self).AsObject).InternalLimpar(AVerificados);
          end;
        end else begin
          lField.SetValue(Self, lField.GetValue(Self).Empty);
        end;
      end;
    end;
  end;
end;

procedure TBase.InternalParaDataSet(const ADataSet: TDataSet;
  const AVerificados: TBaseVerificador; const AOnGerarRegistroBase : TOnGerarRegistroBase);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lNomeCampo: string;
  lFieldDataSet: TField;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin
    ADataSet.Append;

    lRttiType := FContextoBase.GetType(Self.ClassType);

    lRttiProperties := lRttiType.GetProperties;
    for lField in lRttiProperties do
    begin
      lNomeCampo := EmptyStr;
      lFieldAtributes := lField.GetAttributes;
      for lFieldAtribute in lFieldAtributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
        begin
          lNomeCampo := TLmxAttributeMetadata(lFieldAtribute)
            .NomeCampo;
        end;
      end;
      if lNomeCampo = EmptyStr then
        lNomeCampo := lField.Name;

      if (lField.PropertyType.TypeKind = tkClass) then
      begin
        if (lField.GetValue(Self).IsInstanceOf(TBase)) then
        begin
          lFieldDataSet := ADataSet.FindField(lNomeCampo);
          if lFieldDataSet <> nil then
          begin
            lFieldDataSet.AsInteger := TBase(lField.GetValue(Self).AsObject).GetValorCampoPk;
          end;
        end;
      end else begin
//      if not (lField.PropertyType.TypeKind = tkClass) then
//      begin
//        if (lField.GetValue(Self).IsInstanceOf(TBase)) then
//          TBase(lField.GetValue(Self).AsObject).InternalDeDataSet(AVerificados);
//      end else begin
          lFieldDataSet := ADataSet.FindField(lNomeCampo);
          if lFieldDataSet <> nil then
          begin

            case lField.PropertyType.TypeKind of
              tkEnumeration  : lFieldDataSet.AsInteger := lField.GetValue(Self).AsOrdinal;
              tkInteger,
              tkInt64        : lFieldDataSet.AsInteger := lField.GetValue(Self).AsInteger;

              tkChar,
              tkWChar,
              tkString,
              tkLString,
              tkWString,
              tkUString      : lFieldDataSet.AsString := lField.GetValue(Self).AsString;

              tkFloat        : lFieldDataSet.AsExtended := lField.GetValue(Self).AsExtended;
              tkVariant      : lFieldDataSet.AsVariant := lField.GetValue(Self).AsVariant;
            end;
        end;
      end;
    end;
    lFieldDataSet := ADataSet.FindField('Ident_Object');
    if lFieldDataSet <> nil then
      lFieldDataSet.AsInteger := Integer(Self);
    if Assigned(AOnGerarRegistroBase) then
      AOnGerarRegistroBase(ADataSet, Self);
    ADataSet.Post;
  end;
end;

procedure TBase.InternalSetValorPk(const AValor: Integer);
var
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
  lRttiType: TRttiType;
begin
  lRttiType := FContextoBase.GetType(Self.ClassType);
  try
    InternalGetFiledProperties(lRttiType, lFields, lPks);
    try
      lEnum := lPks.GetEnumerator;
      try
        if lEnum.MoveNext then
          lRttiType.GetProperty(lEnum.Current.Key).SetValue(Self, TValue.From<Integer>(AValor));
      finally
        FreeAndNil(lEnum);
      end;
    finally
      FreeAndNil(lPks);
      FreeAndNil(lFields);
    end;
  finally
     lRttiType.Free;
  end;
end;

function TBase.InternalToScript(const AVerificados: TBaseVerificador;
  const ACondicao: string): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicao: string;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lNomeTabela := InternalGettableName(lRttiType);
      if lNomeTabela <> '' then
      begin
        lCondicao := ACondicao;
        if lCondicao <> ''  then
          Result := Format('SELECT * FROM %s WHERE %s', [lNomeTabela, lCondicao]);
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

function TBase.InternalToScriptActive(const AVerificados: TBaseVerificador;
  const ARegistroAtual: TBase; const ADataSet: TLmxDataSet): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicaoPk: string;
  lCampoActive: string;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      if InternalGetFieldNameActive(lRttiType, lCampoActive) then
      begin
        lNomeTabela := InternalGettableName(lRttiType);
        if lNomeTabela <> '' then
        begin
          lCondicaoPk := InternalGetCondicaoPk(lRttiType);
          Result := Format('UPDATE %s SET 1 WHERE %s', [lNomeTabela, lCondicaoPk]);
        end;
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

function TBase.InternalToScript(const ANomeTabela, ACondicao: string): string;
begin
  Result := '';
  if ANomeTabela <> '' then
  begin
    if ACondicao <> ''  then
      Result := Format('SELECT * FROM %s WHERE %s', [ANomeTabela, ACondicao]);
  end;
end;

function TBase.InternalToScriptDelete(const AVerificados: TBaseVerificador;
  const ARegistroAtual: TBase; const ADataSet: TLmxDataSet): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicaoPk: string;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lNomeTabela := InternalGettableName(lRttiType);
      if lNomeTabela <> '' then
      begin
        lCondicaoPk := InternalGetCondicaoPk(lRttiType);
        Result := Format('DELETE FROM %s WHERE %s', [lNomeTabela, lCondicaoPk]);
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

function TBase.InternalToScriptInActive(const AVerificados: TBaseVerificador;
  const ARegistroAtual: TBase; const ADataSet: TLmxDataSet): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicaoPk: string;
  lCampoActive: string;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      if InternalGetFieldNameActive(lRttiType, lCampoActive) then
      begin
        lNomeTabela := InternalGettableName(lRttiType);
        if lNomeTabela <> '' then
        begin
          lCondicaoPk := InternalGetCondicaoPk(lRttiType);
          Result := Format('UPDATE %s SET 0 WHERE %s', [lNomeTabela, lCondicaoPk]);
        end;
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

function TBase.InternalToScriptInsert(
  const AVerificados: TBaseVerificador): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lFieldNames: string;
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
  lFieldValues: string;
  lDeveAdicionar: Boolean;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lNomeTabela := InternalGettableName(lRttiType);
      if lNomeTabela <> '' then
      begin
        InternalGetFiledProperties(lRttiType, lFields, lPks);
        try
          lEnum := lFields.GetEnumerator;
          try
            lFieldNames := '';
            while lEnum.MoveNext do
            begin
              if (lEnum.Current.Value.ForeingKey or lEnum.Current.Value.ZeroIsNull) then
                lDeveAdicionar := (StrToIntDef(lEnum.Current.Value.Valor, 0) > 0)
              else
                lDeveAdicionar := (lEnum.Current.Value.Valor <> '''''') and
                  (lEnum.Current.Value.Valor <> '');

              if lDeveAdicionar then
              begin
                if lFieldNames <> '' then
                  lFieldNames := lFieldNames + ',';
                lFieldNames := lFieldNames + lEnum.Current.Key;

                if lFieldValues <> '' then
                  lFieldValues := lFieldValues + ',';
                lFieldValues := lFieldValues + lEnum.Current.Value.Valor;
              end;
            end;
          finally
            FreeAndNil(lEnum);
          end;
        finally
          FreeAndNil(lPks);
          FreeAndNil(lFields);
        end;

        if (lNomeTabela <> '') and (lFieldNames <> '') and (lFieldValues <> '') then
          Result := Format('INSERT INTO %s (%s) VALUES (%s)', [lNomeTabela, lFieldNames, lFieldValues]);
      end;
    finally

    end;
  end;
end;

function TBase.InternalToScriptProximaSequencia(
  const AVerificados: TBaseVerificador): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lNomeTabela := InternalGettableName(lRttiType);
      if lNomeTabela <> '' then
        Result := Format('SELECT COALESCE(MAX(ID),0) FROM %s', [lNomeTabela]);
    finally

    end;
  end;
end;

function TBase.InternalToScriptSelect(
  const AVerificados: TBaseVerificador): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicao: string;
begin
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lCondicao := InternalGetCondicaoPk(lRttiType);
      if lCondicao <> ''  then
      begin
        lNomeTabela := InternalGettableName(lRttiType);
        if lNomeTabela <> '' then
        begin
          Result := InternalToScript(lNomeTabela,  lCondicao);
        end;
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

function TBase.InternalToScriptUpdate(
  const AVerificados: TBaseVerificador; const ARegistroAtual : TBase; const ADataSet : TLmxDataSet): string;
var
  lRttiType: TRttiType;
  lNomeTabela: string;
  lFieldValues: string;
  lPks: TBaseFieldList;
  lFields: TBaseFieldList;
  lFieldsAlterados: TBaseFieldList;
  lEnum: TBaseFieldList.TPairEnumerator;
  lCondicaoPk: string;
  lComparado: Boolean;
  lAlterado: Boolean;
begin
  Result := '';
//  lComparado := False;
  if (not AVerificados.JaVerificou(Self)) then
  begin
    lRttiType := FContextoBase.GetType(Self.ClassType);
    try
      lNomeTabela := InternalGettableName(lRttiType);
      if lNomeTabela <> '' then
      begin
        InternalGetFiledProperties(lRttiType, lFields, lPks);
        lComparado := False;
        if ARegistroAtual <> nil then
          lComparado := InternalDiferencas(ARegistroAtual, AVerificados, lFieldsAlterados)
        else if ADataSet <> nil then
          lComparado := InternalDiferencas(ADataSet, AVerificados, lFieldsAlterados);

        try
          if lComparado then
          begin
            lEnum := lFields.GetEnumerator;
            try
              lFieldValues := '';
              while lEnum.MoveNext do
              begin
                if not lPks.ContainsKey(lEnum.Current.Key) then
                begin
                  if lComparado then
                    lAlterado := lFieldsAlterados.ContainsKey(UpperCase(lEnum.Current.Key))
                  else
                    lAlterado := True;

                  if lAlterado then
                  begin
                    if lFieldValues <> '' then
                      lFieldValues := lFieldValues + ',';
                    lFieldValues := lFieldValues + Format('%s = %s',
                      [lEnum.Current.Key, lEnum.Current.Value.Valor]);
                  end;
                end;
              end;
            finally
              FreeAndNil(lEnum);
            end;
          end;
        finally
          FreeAndNil(lPks);
          FreeAndNil(lFields);
          FreeAndNil(lFieldsAlterados);
        end;

        if lComparado then
        begin
          lCondicaoPk := InternalGetCondicaoPk(lRttiType);
          if lFieldValues <> '' then
            Result := Format('UPDATE %s SET %s WHERE %s', [lNomeTabela, lFieldValues, lCondicaoPk]);
        end;
      end;
    finally
      lRttiType.Free;
    end;
  end;
end;

procedure TBase.Limpar;
var
  lVerificados: TBaseVerificador;
  I: Integer;
begin
  for I := 0 to FFilhos.Count - 1 do
    FFilhos[I].Limpar;

  lVerificados := TBaseVerificador.Create;
  try
    InternalLimpar(lVerificados);
  finally
    FreeAndNil(lVerificados);
  end;

end;


procedure TBase.SetValorCampoPk(const AValor: Integer);
begin
  InternalSetValorPk(AValor);
end;

{ TBaseVerificador }

function TBaseVerificador.JaVerificou(const AObjeto: TBase): Boolean;
begin
  if Self.IndexOf(AObjeto) = -1 then
  begin
    Result := False;
    Self.Add(AObjeto);
  end else
    result := True;
end;


{ TBaseList<T> }

procedure TBaseList<T>.GerarRegistro(const ADataSet: TDataSet;
  const AOnGerarRegistro: TOnGerarRegistro<T>);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Item[I].GerarRegistro(ADataSet,
      procedure (const ADataSet : TDataSet; const AObjeto : TBase)
      begin
        AOnGerarRegistro(ADataSet, Item[I])
      end
    );

//    DoGerarRegistro);
//    ADataSet.Append;
//    AOnGerarRegistro(ADataSet, Item[I]);
//    ADataSet.Post;
  end;
end;

function TBaseList<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := TEnumerator<T>(FLista.GetEnumerator);
end;

function TBaseList<T>.GetItem(const AIndex: Integer): T;
begin
  Result := T(FLista.Items[AIndex]);
end;

function TBaseList<T>.GetItemClass: TBaseClass;
begin
  Result := T;
end;

function TBaseList<T>.GetList: TList<T>;
var
  I: Integer;
begin
  Result := TList<T>.Create;
  for I := 0 to Count - 1 do
    Result.Add(Item[I]);
end;

function TBaseList<T>.InternalGettableName(const AClass: TClass): string;
var
  lFieldAtribute: TCustomAttribute;
  lRttiType: TRttiType;
begin
  Result := '';

  lRttiType := FContextoBase.GetType(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType);
  try
    for lFieldAtribute in lRttiType.GetAttributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeMetadata.ClassName) then
      begin
        Result :=TLmxAttributeMetadata(lFieldAtribute).NomeCampo;
        if Result = EmptyStr then
          Result := Copy(AClass.ClassName, 2, Length(AClass.ClassName));
      end;
    end;
  finally
    FreeAndNil(lRttiType);
  end;
end;

function TBaseList<T>.InternalToScriptSelect(
  const AVerificados: TBaseVerificador): string;
var
//  lRttiType: TRttiType;
  lNomeTabela: string;
  lCondicao: string;
  lTipo: PTypeInfo;
begin
  Result := '';
  if (not AVerificados.JaVerificou(Self)) then
  begin
//    lRttiType := FContextoBase.GetType(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType);
    try
      lNomeTabela := InternalGettableName(GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType);
      if lNomeTabela <> '' then
      begin
//          Result := Format('SELECT * FROM %s WHERE %s', [lNomeTabela, lCondicao]);
          lCondicao := '';
          Result := Format('SELECT * FROM %s %s', [lNomeTabela, lCondicao]);
      end;
    finally

    end;
  end;
end;

procedure TBaseList<T>.SetItem(const AIndex: Integer; const Value: T);
begin
  FLista.Items[AIndex] := TBase(Value);
end;

{ TBaseFieldList }

constructor TBaseFieldList.Create;
begin
  inherited Create([doOwnsValues]);
end;

{ TBaseField }

function TBaseField.Clonar: TBaseField;
begin
  Result := TBaseField.Create;
  Result.CopiarDe(Self);
end;

procedure TBaseField.CopiarDe(const AField: TBaseField);
begin
  FForeingKey := AField.ForeingKey;
  FPrimaryKey := AField.PrimaryKey;
  FValor := AField.Valor;
  FNome := AField.Nome;
  FZeroIsNull := AField.ZeroIsNull;
  FTamanho := AField.Tamanho;
  FActiveField := AField.ActiveField;
end;


{ TBaseListEnum<T> }

function TBaseListEnum<T>.Add(const Value: T): Integer;
begin
  Result := FList.Add(Value);
end;

function TBaseListEnum<T>.Add: T;
begin
  Result := T.Create;
  FList.Add(Result);
end;

procedure TBaseListEnum<T>.Clear;
begin
  FList.Clear;
end;

function TBaseListEnum<T>.Count: Integer;
begin
  Result := FList.Count;
end;


constructor TBaseListEnum<T>.Create;
begin
  FList := TObjectList<T>.Create;
end;


destructor TBaseListEnum<T>.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;


function TBaseListEnum<T>.First: T;
begin
  Result := FList.First;
end;


function TBaseListEnum<T>.GetDescription: string;
begin
  Result := Self.ClassName;
end;


function TBaseListEnum<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FList.GetEnumerator;
end;


function TBaseListEnum<T>.GetItemObject(const AIndex: Integer): TObject;
begin
  Result := T(FList.Items[AIndex]);
end;


function TBaseListEnum<T>.GetNewItemObject: TObject;
var
  lResultado: TObject;
begin
//  Result := T.Create;
  lResultado := T.Create;
  FList.Add(lResultado);
  Result := lResultado;
end;


function TBaseListEnum<T>.Remove(const Value: T): Integer;
begin
  Result := FList.Remove(Value);
end;


end.
