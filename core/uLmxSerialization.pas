unit uLmxSerialization;

interface

uses
  XMLIntf, XmlDoc, RTTI, TypInfo, SysUtils, IOUtils, uLmxAttributes, Generics.Collections, {$IF CompilerVersion >= 23.0}REST.JSON, System.JSON,
  Data.DBXJSONReflect,  {$ELSE} DBXJSON, DBXJsonReflect, {$IFEND}Classes,
  Data.DB, System.DateUtils;

type

  TOnGetClasseEnumJson = reference to function () : TClass;
  TOnAddObjectEnumJson<T> = reference to procedure(const AObjeto : T);
  TOnNewItemObjectEnumJson = reference to  procedure(const AItem : TObject; const ADados : String);


  TLmxServerComandMethodPropriedadeResultado = class
  private
    FDescricao: string;
    FCodigo: Integer;
  public
    constructor Create(const ACodigo : Integer; ADescricao : string);

    property Codigo : Integer read FCodigo write FCodigo;
    property Descricao : string read FDescricao write FDescricao;

  end;

  TLmxServerComandMethodPropriedadeResultados = class(TObjectList<TLmxServerComandMethodPropriedadeResultado>);


  TLmxServerComandMethodPropriedadeClasse = class
  private
    FNome: string;
    FTypeKind: TTypeKind;
  public
    property Nome : string read FNome write FNome;
    property TypeKind : TTypeKind read FTypeKind write FTypeKind;
  end;

  TLmxServerComandMethodPropriedadesClasse = class(TObjectList<TLmxServerComandMethodPropriedadeClasse>);

  TLmxServerComandMethodParameters = class
  private
    FNome: string;
    FTypeKind: TTypeKind;
    FPropriedades: TLmxServerComandMethodPropriedadesClasse;
    FNomeClasse: string;
    FFromQuery: Boolean;
    FHandle: PTypeInfo;
    FQualifiedName: string;
    FFromHeader: Boolean;
    FFromBody: Boolean;
    FFromServices: Boolean;
    FFromParams: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    property Nome : string read FNome write FNome;
    property TypeKind : TTypeKind read FTypeKind write FTypeKind;
    property Handle : PTypeInfo read FHandle write FHandle;
    property QualifiedName : string read FQualifiedName write FQualifiedName;
    property NomeClasse : string read FNomeClasse write FNomeClasse;
    property FromQuery : Boolean read FFromQuery write FFromQuery;
    property FromHeader : Boolean read FFromHeader write FFromHeader;
    property FromBody : Boolean read FFromBody write FFromBody;
    property FromServices : Boolean read FFromServices write FFromServices;
    property FromParams : Boolean read FFromParams write FFromParams;


    property Propriedades : TLmxServerComandMethodPropriedadesClasse read FPropriedades;
  end;

  TLmxServerComandMethodParametersList = class(TObjectList<TLmxServerComandMethodParameters>)
  public
    function ObterParametroDeRota(const pNome : string) : TLmxServerComandMethodParameters;
  end;

  TLmxServerComandMethodAttributes = class
  private
    FAutenticacaoObrigatoria: Boolean;
    FRota: string;
    FModosPermitidos: TLmxAttributeComandoMetodos;
    FRotaConfigurada: Boolean;
    FNome: string;
    FEvento: TRttiMethod;
    FParametros: TLmxServerComandMethodParametersList;
    FRetorno: TLmxServerComandMethodParameters;
    FResultados: TLmxServerComandMethodPropriedadeResultados;
    FSumario: string;
    FDescricao: string;
    FRotaSemParametros: string;
    FParametrosRota: string;
    FPosParametrosRota: string;
  public
    constructor Create;
    destructor Destroy; override;

    property RotaConfigurada : Boolean read FRotaConfigurada write FRotaConfigurada;
    property AutenticacaoObrigatoria : Boolean read FAutenticacaoObrigatoria write FAutenticacaoObrigatoria;
    property Rota : string read FRota write FRota;
    property RotaSemParametros : string read FRotaSemParametros write FRotaSemParametros;
    property ModosPermitidos : TLmxAttributeComandoMetodos read FModosPermitidos write FModosPermitidos;
    property Nome : string read FNome write FNome;
    property ParametrosRota : string read FParametrosRota write FParametrosRota;
    property PosParametrosRota : string read FPosParametrosRota write FPosParametrosRota;

    property Descricao : string read FDescricao write FDescricao;
    property Sumario : string read FSumario write FSumario;

    property Evento : TRttiMethod read FEvento write FEvento;

    property Parametros : TLmxServerComandMethodParametersList read FParametros;
    property Retorno : TLmxServerComandMethodParameters read FRetorno;
    property Resultados : TLmxServerComandMethodPropriedadeResultados read FResultados;

    function PermiteGet : Boolean;
    function PermitePost : Boolean;
    function PermitePut : Boolean;
    function PermiteDelete : Boolean;

    function ObterRotaMetodo : string;

    function ParametroRotaValido(const pValorParametro : string; out pValor : string; out APosParametro : string) : Boolean;

  end;

  TLmxServerComandMethodAttributesList = class(TObjectList<TLmxServerComandMethodAttributes>)
  public
    function TentaObterMetodo(const ARota : string; const pTipo : TLmxAttributeComandoMetodo; out AMetodo : TLmxServerComandMethodAttributes) : Boolean;
  end;

  TLmxServerComandAttributes = class
  private
    FAutenticacaoObrigatoria: Boolean;
    FMetodos: TLmxServerComandMethodAttributesList;
    FDescricao: string;
  public
    constructor Create;
    destructor Destroy; override;

    property AutenticacaoObrigatoria : Boolean read FAutenticacaoObrigatoria write FAutenticacaoObrigatoria;
    property Metodos : TLmxServerComandMethodAttributesList read FMetodos;
    property Descricao : string read FDescricao write FDescricao;
  end;

  TLmxRotaRest = class
  private
    FRota: string;
  public
    property Rota : string read FRota write FRota;
  end;

  TLmxRotasRest = class(TObjectList<TLmxRotaRest>)
  public
    procedure NovaRota(const ARota : string);
  end;

  TLmxSerializationDataSet = class
  public
//    function DataSetToJson(const pDataSet : TDataSet) : TJSONObject;
    function DataSetToJsonItemObjectFormat(const pDataSet : TDataSet) : TJSONObject;
    function DataSetToJsonObjectFormat(const pDataSet : TDataSet; const pOnCarregarITem: TProc<TJSONObject> = nil) : TJSONArray;
    function DataSetToJson(const pDataSet : TDataSet) : TJSONObject;
    function DataSetToJsonString(const pDataSet : TDataSet) : string;
    function DataSetToJsonStringObjectFormat(const pDataSet : TDataSet; const pOnCarregarITem: TProc<TJsonObject> = nil) : string;

    function DataSetToJsonItemStringObjectFormat(const pDataSet : TDataSet) : string;
  end;

  TLmxSerialization = class
  private
    FObject: TObject;
    FEnumerable : ILmxEnumerable;
//    FContexto : TRttiContext;
    FSomenteSerializaveis: Boolean;
    FRetornoFormatado: Boolean;
    FFormato : TLmxSerializationFormat;

//    function ObjectToJson(const AObjeto : TObject; const AConversor : TTypeObjectsConverter) : TJSONValue;

    function GetDescricaoObjeto(const AObjeto: TObject; out AFormato : TLmxSerializationFormat) : string;

    procedure CarregarObjetoDeNodoAtributos(const ANodo: IXmlNode;
      const AObjeto: TObject);
    procedure CarregarObjetoDeNodoChilds(const ANodo: IXmlNode;
      const AObjeto: TObject);

    procedure SalvarObjetoEmNodoAtributos(const ANodo: IXmlNode; const AObjeto: TObject);
    procedure SalvarObjetoEmNodoChilds(const ANodo: IXmlNode; const AObjeto: TObject);

    procedure ClonarObjeto(const AObjetoDe, AObjetoPara: TObject);

    function ObterValorChavePrimaria(const AObjeto: TObject) : Integer;
    function SetarValorChavePrimaria(const AObjeto: TObject; const AValorChave : Integer) : Boolean;
    function CriarJsonObject(const AObjeto: TObject) : TJSONObject;
//    procedure CarregarObjetosDeJson(const AObjeto: TObject; const AJsonArray : TJSONArray);
    procedure CarregarObjetoDeJson(const AObjeto: TObject; const ADados: string);
    function CriarListaParametros(const AObjeto: TObject) : TStringList;

    procedure SalvarObjetoEmNodo(const ANodo: IXmlNode; const AObjeto: TObject);
    procedure CarregarObjetoDeNodo(const ANodo: IXmlNode;
      const AObjeto: TObject);
  public
    class var FContexto : TRttiContext;

    property SomenteSerializaveis : Boolean read FSomenteSerializaveis;
    property RetornoFormatado : Boolean read FRetornoFormatado write FRetornoFormatado;
    function ToXml: string;
    function ToString: string; override;
    function ToJson: string;
    procedure ToXmlFile(const AFileName: string);
    procedure ToJsonFile(const AFileName : string);
    function ToParamsGet: string;
    function ToScriptInsert: string;
    function ToJsonArray: string;

    procedure FromJson(const ADados: string);
    procedure FromJsonFile(const AFileName: string);
    procedure FromXml(const ADados: string);
    procedure FromXmlFile(const AFileName: string);

    procedure FromOther(const AOther: TObject);

    function GetCaminhoRest : string;

//    function GetMetodo(const AMetodo : string; const ACaminho : string; out AEvento : TRttiMethod;
//      out APermiteGet, APermitePost : Boolean) : Boolean;

    function EnumCriarJsonObject(const AObjeto : ILmxEnumerable) : TJSONArray;
    procedure EnumCarregarObjetoDeJson<T : Class, constructor>(const AObjeto: ILmxEnumerable; const ADados: string;
      const AGetClasse : TOnGetClasseEnumJson; const AOnAddObject : TOnAddObjectEnumJson<T>);

    procedure EnumGerarObjetoDeJson(const ALista: ILmxEnumerable; const ADados: TJsonValue; const AOnNovoITem :  TOnNewItemObjectEnumJson ); overload;
    procedure EnumGerarObjetoDeJson(const ALista: ILmxEnumerable; const ADados: string; const AOnNovoITem :  TOnNewItemObjectEnumJson ); overload;

    constructor Create(const AObject: TObject; const ASomenteSerializaveis : Boolean = True;
      const AFormato : TLmxSerializationFormat = sfLmx); overload;
    constructor Create(const AObject: ILmxEnumerable; const ASomenteSerializaveis : Boolean = True;
      const AFormato : TLmxSerializationFormat = sfLmx); overload;

    class function ConvertToJsonString(const AObject: ILmxEnumerable) : string;

    class function ObterCaminhoRest(const AClasse : TClass) : TLmxRotasRest;
    class function GetClassAttributes(const AClasse : TClass; const APropriedades : TLmxServerComandMethodPropriedadesClasse) : Boolean;
    class function GetServerCommandAttributes(const AClasse : TClass) : TLmxServerComandAttributes;

    class function ObterMetodoCreate(const AClasse : TClass; out AEvento : TRttiMethod) : Boolean;
//    class function GetMetodo(const AClasse : TClass; const AMetodo : string; out AEvento : TRttiMethod) : Boolean;


    class function ToJsonString(const AObject : TObject; const ASomenteSerializaveis : Boolean = False): string;
    class function ToJsonArrayString(const ALista: ILmxEnumerable; const ASomenteSerializaveis : Boolean = False): string;
    class function FromJsonString(const AObject : TObject; const ADados : string; const ASomenteSerializaveis : Boolean = False): Boolean;
    class function FromJsonArrayString(const AObject : TObject; const ALista: ILmxEnumerable; const ADados : string; const AOnNovoITem :  TOnNewItemObjectEnumJson = nil; const ASomenteSerializaveis : Boolean = False): Boolean;
    class function ExternalToParamsGet(const AObject : TObject): string;
    class function ExternalGetCaminhoRest(const AObject : TObject): string;
    class function ExternalScriptInsert(const AObject : TObject) : string;

    class function ExternalDataSetToJsonArrayString(const pDataSet : TDataSet; const pObjectFormat : Boolean = True;
      const pOnCarregarITem: TProc<TJsonObject> = nil) : string;
    class function ExternalDataSetToJsonString(const pDataSet : TDataSet) : string;

  end;


implementation

{ TLmxSerialization }

procedure TLmxSerialization.CarregarObjetoDeJson(const AObjeto: TObject;
  const ADados: string);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lObjetoJson: TJSONObject;
//  lChild: IXmlNode;
  lValor: Variant;
//  lAtributo: IXMLNode;
  lJsonStream : TStringStream;
  lPairObject: TJSONPair;
  lPairAtributo: TJSONPair;
  lValorAtributo: string;
//  lIsForeignKey : Boolean;
  lLmxEnum: ILmxEnumerable;
  lSomentePK: Boolean;
  lValorDateTime: TDateTime;
  lValorDateTimeFloat: Extended;
  lArray: TArray<Byte>;
begin

  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  {$IF CompilerVersion > 30}
  lJsonStream := TStringStream.Create(ADados, TEncoding.UTF8);
  {$ELSE}
  lJsonStream := TStringStream.Create(ADados, TEncoding.Default);
  {$IFEND}
  lObjetoJson := TJSONObject.Create;
  try
    lObjetoJson.Parse(lJsonStream.Bytes, 0);

    lRttiType := FContexto.GetType(AObjeto.ClassType);

    lDescricaoAtributo := '';
    lClassAttributes := lRttiType.GetAttributes;
    for lFieldAtribute in lClassAttributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
        lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
          .Descricao;
    end;
    if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
      lDescricaoAtributo := AObjeto.ClassName;

  //    if lDescricaoAtributo = '' then
  //      lDescricaoAtributo := AObjeto.ClassName;
  //
  //    lChild := ANodo.ChildNodes.FindNode(lDescricaoAtributo);

    if lDescricaoAtributo <> '' then
    begin
  //      lDescricaoAtributo := AObjeto.ClassName;



//      if lPairObject <> nil then
//      begin
        lRttiProperties := lRttiType.GetProperties;
        for lProperty in lRttiProperties do
        begin
          lDescricaoAtributo := lProperty.Name;
          lFieldAtributes := lProperty.GetAttributes;
          lFieldAtribute := nil;
          if lProperty.GetValue(AObjeto).Kind = tkClass then
          begin
            lPairObject := lObjetoJson.Get(lDescricaoAtributo);
            if lPairObject <> nil then
            begin
              lSomentePK := False;
              for lFieldAtribute in lFieldAtributes do
              begin
//                  if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
//                    lIsForeignKey := True;
                if lFieldAtribute.ClassNameIs(TLmxAttributeOnlyPKSerializable.ClassName) then
                  lSomentePK := True;
              end;
              if Supports(lProperty.GetValue(AObjeto).AsObject, ILmxEnumerable) then
              begin
                lLmxEnum := lProperty.GetValue(AObjeto).AsInterface as ILmxEnumerable;
                EnumGerarObjetoDeJson(lLmxEnum, lPairObject.JsonValue, nil);
              end else begin
                if lPairObject.JsonValue.InheritsFrom(TJSONObject) then
                  CarregarObjetoDeJson(lProperty.GetValue(AObjeto).AsObject, lPairObject.JsonValue.ToString)
                else if (lSomentePK) then
                  SetarValorChavePrimaria(lProperty.GetValue(AObjeto).AsObject, StrToIntDef(lPairObject.JsonValue.ToString, 0))
                else
                  CarregarObjetoDeJson(lProperty.GetValue(AObjeto).AsObject, lPairObject.JsonValue.ToString);
              end;
            end;
          end else begin
            if ((lDescricaoAtributo <> 'RefCount') and (lDescricaoAtributo <> 'Disposed')) and lProperty.IsWritable then
            begin
              for lFieldAtribute in lFieldAtributes do
              begin
                if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
                  lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute).Descricao;
              end;
              if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
                lDescricaoAtributo := lProperty.Name;

              if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
              begin
                lPairAtributo := lObjetoJson.Get(lDescricaoAtributo);
                if lPairAtributo = nil then
                  lPairAtributo := lObjetoJson.Get(LowerCase(lDescricaoAtributo));
                if lPairAtributo <> nil then
                begin
                  if ((lProperty.PropertyType.TypeKind = tkDynArray) and
                      (lProperty.PropertyType.QualifiedName = 'System.TArray<System.Byte>')) then
                  begin
                    {$IF CompilerVersion >= 33}
                       lArray := TJSONArray(lPairAtributo.JsonValue).AsType<TArray<Byte>>;
                    {$ELSE}
                       lArray := TJSONArray(lPairAtributo.JsonValue).GetValue<TArray<Byte>>;
                    {$ENDIF}
                    lProperty.SetValue(AObjeto, TValue.From<TArray<Byte>>(lArray));
                  end else
                  begin
                    lValorAtributo := lPairAtributo.JsonValue.Value;
                    if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
                      lValor := StrToBoolDef(lValorAtributo, False)
                    else if (lProperty.PropertyType.QualifiedName = 'System.TDateTime') or
                        (lProperty.PropertyType.QualifiedName = 'System.TDate') or
                        (lProperty.PropertyType.QualifiedName = 'System.TTime') then
                    begin
                      if TryStrToFloat(lValorAtributo, lValorDateTimeFloat) then
                        lValor := lValorDateTime
                      else if TryStrToDateTime(lValorAtributo,lValorDateTime) then
                        lValor := lValorDateTime
                      else
                        lValor := ISO8601ToDate(lValorAtributo);
                    end
                    else if lProperty.PropertyType.TypeKind = tkInteger then
                      lValor := StrToInt(lValorAtributo)
                    else if lProperty.PropertyType.TypeKind = tkFloat then
                      lValor := StrToFloat(lValorAtributo)
                    else if lProperty.PropertyType.TypeKind = tkEnumeration then
                      lValor := StrToInt(lValorAtributo)
                    else
                      lValor := lValorAtributo;

                    if lProperty.PropertyType.TypeKind = tkEnumeration then
                      lProperty.SetValue(AObjeto, TValue.FromOrdinal(lProperty.PropertyType.Handle, lValor))
                    else
                      lProperty.SetValue(AObjeto, TValue.FromVariant(lValor));
                  end;
                end;
              end;
            end;
          end;
//        end;
      end;
    end;
  finally
    FreeAndNil(lJsonStream);
    FreeAndNil(lObjetoJson);
  end;
end;

procedure TLmxSerialization.CarregarObjetoDeNodo(const ANodo: IXmlNode;
  const AObjeto: TObject);
begin
  if (ANodo <> nil) and (ANodo.AttributeNodes.FindNode('FormatType') = nil) then
     FFormato := sfChild;

  if FFormato = sfLmx then
    CarregarObjetoDeNodoAtributos(ANodo, AObjeto)
  else
    CarregarObjetoDeNodoChilds(ANodo, AObjeto);
end;

procedure TLmxSerialization.CarregarObjetoDeNodoAtributos(const ANodo: IXmlNode;
  const AObjeto: TObject);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lChild: IXmlNode;
  lValor: Variant;
  lAtributo: IXMLNode;
  lValorCampo: TValue;
  lValorOriginal: TValue;
begin
  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lDescricaoAtributo := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
      lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
  end;
  if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
    lDescricaoAtributo := AObjeto.ClassName;

//    if lDescricaoAtributo = '' then
//      lDescricaoAtributo := AObjeto.ClassName;
//
//    lChild := ANodo.ChildNodes.FindNode(lDescricaoAtributo);

  if lDescricaoAtributo <> '' then
  begin
//      lDescricaoAtributo := AObjeto.ClassName;

    if ANodo.NodeName = lDescricaoAtributo then
      lChild := ANodo
    else
      lChild := ANodo.ChildNodes.FindNode(lDescricaoAtributo);


    if lChild <> nil then
    begin
      lRttiProperties := lRttiType.GetProperties;
      for lProperty in lRttiProperties do
      begin
        lDescricaoAtributo := lProperty.Name;
        lFieldAtributes := lProperty.GetAttributes;
        lFieldAtribute := nil;
        if lProperty.GetValue(AObjeto).Kind = tkClass then
          CarregarObjetoDeNodoAtributos(lChild, lProperty.GetValue(AObjeto).AsObject)
        else
        begin
          for lFieldAtribute in lFieldAtributes do
          begin
            if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
              lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
                .Descricao;
          end;
          if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
            lDescricaoAtributo := lProperty.Name;

          if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
          begin
            lAtributo := lChild.AttributeNodes.FindNode(lDescricaoAtributo);
            if lAtributo <> nil then
            begin
              lValorCampo.Empty;
              if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
                lValor := StrToBoolDef(lAtributo.NodeValue, False)
              else if lProperty.PropertyType.QualifiedName = 'System.TDateTime' then
                lValor := DateToISO8601(lAtributo.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkInteger then
                lValor := StrToInt(lAtributo.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkFloat then
                lValor := StrToFloat(lAtributo.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkEnumeration then begin
                  lValor := lAtributo.NodeValue;
                  lValorOriginal := lProperty.GetValue(AObjeto);
                  lValorCampo := TValue.FromOrdinal(lValorOriginal.TypeInfo, GetEnumValue(lValorOriginal.TypeInfo, lValor));
              end else
                lValor := lAtributo.NodeValue;
              if not lValorCampo.IsEmpty then
                lProperty.SetValue(AObjeto, lValorCampo)
              else
                lProperty.SetValue(AObjeto, TValue.FromVariant(lValor));
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TLmxSerialization.CarregarObjetoDeNodoChilds(const ANodo: IXmlNode;
  const AObjeto: TObject);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lChild: IXmlNode;
  lValor: Variant;
  lChildNode: IXMLNode;
  lValorOriginal: TValue;
  lValorCampo: TValue;
begin
  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lDescricaoAtributo := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
      lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
  end;
  if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
    lDescricaoAtributo := AObjeto.ClassName;

//    if lDescricaoAtributo = '' then
//      lDescricaoAtributo := AObjeto.ClassName;
//
//    lChild := ANodo.ChildNodes.FindNode(lDescricaoAtributo);

  if lDescricaoAtributo <> '' then
  begin
//      lDescricaoAtributo := AObjeto.ClassName;

    if ANodo.NodeName = lDescricaoAtributo then
      lChild := ANodo
    else
      lChild := ANodo.ChildNodes.FindNode(lDescricaoAtributo);


    if lChild <> nil then
    begin
      lRttiProperties := lRttiType.GetProperties;
      for lProperty in lRttiProperties do
      begin
        lDescricaoAtributo := lProperty.Name;
        lFieldAtributes := lProperty.GetAttributes;
        lFieldAtribute := nil;
        if lProperty.GetValue(AObjeto).Kind = tkClass then
          CarregarObjetoDeNodoChilds(lChild, lProperty.GetValue(AObjeto).AsObject)
        else
        begin
          for lFieldAtribute in lFieldAtributes do
          begin
            if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
              lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
                .Descricao;
          end;
          if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
            lDescricaoAtributo := lProperty.Name;

          if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
          begin
            lValorCampo.Empty;
            lChildNode := lChild.ChildNodes.FindNode(lDescricaoAtributo);
            if lChildNode <> nil then
            begin
              if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
                lValor := StrToBoolDef(lChildNode.NodeValue, False)
              else if lProperty.PropertyType.QualifiedName = 'System.TDateTime' then
                lValor := DateToISO8601(lChildNode.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkInteger then
                lValor := StrToInt(lChildNode.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkFloat then
                lValor := StrToFloat(lChildNode.NodeValue)
              else if lProperty.PropertyType.TypeKind = tkEnumeration then begin
                  lValor := lChildNode.NodeValue;
                  lValorOriginal := lProperty.GetValue(AObjeto);
                  lValorCampo := TValue.FromOrdinal(lValorOriginal.TypeInfo, GetEnumValue(lValorOriginal.TypeInfo, lValor));
              end else
                lValor := lChildNode.NodeValue;

              if not lValorCampo.IsEmpty then
                lProperty.SetValue(AObjeto, lValorCampo)
              else
                lProperty.SetValue(AObjeto, TValue.FromVariant(lValor));
            end;
          end;
        end;
      end;
    end;
  end;
end;

//procedure TLmxSerialization.CarregarObjetosDeJson(const AObjeto: TObject;
//  const AJsonArray : TJSONArray);
//var
//  I: Integer;
//begin
//  for I := 0 to AJsonArray.Count - 1 do
//  begin
//    lObjeto := T.Create;
//    CarregarObjetoDeJson(lObjeto, lJsonArray.Items[I].ToString);
//    AOnAddObject(lObjeto);
//  end;
//end;

procedure TLmxSerialization.ClonarObjeto(const AObjetoDe, AObjetoPara : TObject);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lField: TRttiProperty;
begin
  if AObjetoDe.Equals(AObjetoPara) then
    raise Exception.Create('Os objetos devem ser diferentes para serem clonados');
  if not AObjetoDe.ClassNameIs(AObjetoPara.ClassName) then
    raise Exception.Create(Format('Os tipos dos objetos devem ser iguais para serem clonados. De[%s]-Para[%s]',
      [AObjetoDe.ClassName, AObjetoPara.ClassName]));
  lRttiType := FContexto.GetType(AObjetoPara.ClassType);
  lRttiProperties := lRttiType.GetProperties;
  for lField in lRttiProperties do
  begin
    if (lField.PropertyType.TypeKind = tkClass) and (not lField.GetValue(AObjetoPara).IsEmpty) then
      ClonarObjeto(lField.GetValue(AObjetoDe).AsObject, lField.GetValue(AObjetoPara).AsObject)
    else
      lField.SetValue(AObjetoPara, lField.GetValue(AObjetoDe));
  end;
end;

class function TLmxSerialization.ConvertToJsonString(
  const AObject: ILmxEnumerable): string;
var
  lSerializator: TLmxSerialization;
begin
  lSerializator := Self.Create(AObject, False, sfLmx);
  try
    Result := lSerializator.ToJson;
  finally
    FreeAndNil(lSerializator);
  end;
end;

constructor TLmxSerialization.Create(const AObject: TObject; const ASomenteSerializaveis : Boolean;
  const AFormato : TLmxSerializationFormat);
begin
  FSomenteSerializaveis := ASomenteSerializaveis;
  FFormato := AFormato;
  FRetornoFormatado := True;
  FObject := AObject;
end;

constructor TLmxSerialization.Create(const AObject: ILmxEnumerable;
  const ASomenteSerializaveis: Boolean;
  const AFormato: TLmxSerializationFormat);
begin
  FSomenteSerializaveis := ASomenteSerializaveis;
  FFormato := AFormato;
  FRetornoFormatado := True;
  FEnumerable := AObject;
end;

function TLmxSerialization.CriarJsonObject(const AObjeto: TObject): TJSONObject;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lValor: TValue;
  lIsForeignKey: Boolean;
  lId: Integer;
  lSerializavel : Boolean;
  lSomentePK: Boolean;
  lDynArray: TArray<Byte>;
  lByte: Byte;
  lJSONArray: TJSONArray;
begin
  Result := TJSONObject.Create;

  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lDescricaoAtributo := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
      lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
  end;
  if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
    lDescricaoAtributo := AObjeto.ClassName;

  if lDescricaoAtributo <> '' then
  begin
    lRttiProperties := lRttiType.GetProperties;
    for lProperty in lRttiProperties do
    begin

      lDescricaoAtributo := lProperty.Name;
      lFieldAtributes := lProperty.GetAttributes;
      lValor := lProperty.GetValue(AObjeto);

      lSerializavel := not FSomenteSerializaveis;
      lIsForeignKey := False;
      lSomentePK := False;
      for lFieldAtribute in lFieldAtributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataForeignKey.ClassName) then
          lIsForeignKey := True;
        if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
        begin
          lSerializavel := True;
          lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute).Descricao;
        end;
        if lFieldAtribute.ClassNameIs(TLmxAttributeNoSerializable.ClassName) then
          lSerializavel := False;
        if lFieldAtribute.ClassNameIs(TLmxAttributeOnlyPKSerializable.ClassName) then
          lSomentePK := True;
      end;
      lSerializavel := lSerializavel and ((lDescricaoAtributo <> 'RefCount') and (lDescricaoAtributo <> 'Disposed'));
      if lSerializavel then
      begin
        if (lValor.Kind = tkClass) then
        begin
          if Supports(lValor.AsObject, ILmxEnumerable) then
            Result.AddPair(lDescricaoAtributo, EnumCriarJsonObject(lValor.AsInterface as ILmxEnumerable))
          else begin
            if lIsForeignKey then
              begin
                lId := 0;
                if not lValor.IsEmpty then
                  lId := ObterValorChavePrimaria(lValor.AsObject);
                if lId > 0 then
                begin
                  if lSomentePK then
                    Result.AddPair(lDescricaoAtributo, TJSONNumber.Create(lId))
                  else
                    Result.AddPair(lDescricaoAtributo, CriarJsonObject(lValor.AsObject));
                end;
              end
            else
              Result.AddPair(lDescricaoAtributo, CriarJsonObject(lValor.AsObject));
          end;
        end
        else
        begin
  //        for lFieldAtribute in lFieldAtributes do
  //        begin
  //          if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
  //            lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
  //              .Descricao;
  //        end;
  //        if lSerializavel then // (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
  //        begin
            if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
            begin
              if lValor.AsBoolean then
                Result.AddPair(lDescricaoAtributo, TJSONTrue.Create)
              else
                Result.AddPair(lDescricaoAtributo, TJSONFalse.Create);
            end else if (lProperty.PropertyType.QualifiedName = 'System.TArray<System.Byte>') then
            begin
              if (lValor.TryAsType<TArray<Byte>>(lDynArray)) then
              begin
                lJSONArray := TJSONArray.Create;
                try
                  for lByte in lDynArray do
                    lJSONArray.Add(lByte);
                  Result.AddPair(lDescricaoAtributo, lJSONArray);
                except
                  lJSONArray.Free;
                end;
              end;
            end else if lProperty.PropertyType.QualifiedName = 'System.TDateTime' then
            begin
              if lValor.AsType<TDateTime> > 0 then
                Result.AddPair(lDescricaoAtributo, TJSONString.Create(DateToISO8601(lValor.AsType<TDateTime>)));
            end else begin
              case lValor.Kind of
  //              tkUnknown     : ;
                tkInteger :
                  begin
                    if lValor.AsInteger <> 0 then
                      Result.AddPair(lDescricaoAtributo, TJSONNumber.Create(lValor.AsInteger));
                  end;
                tkChar, tkWChar, tkString, tkLString, tkWString, tkUString
                  :
                  begin
                    if lValor.AsString <> '' then
                      Result.AddPair(lDescricaoAtributo, TJSONString.Create(lValor.AsString));
                  end;
                tkEnumeration :
                  Result.AddPair(lDescricaoAtributo, TJSONNumber.Create(lValor.AsOrdinal));
                tkFloat, tkInt64:
                  begin
                    if lValor.AsExtended <> 0 then
                      Result.AddPair(lDescricaoAtributo, TJSONNumber.Create(lValor.AsExtended));
                  end;

  //              tkVariant: ;
  //              tkArray: ;
  //              tkRecord: ;
  //              tkInterface: ;
  //              tkInt64: ;
  //              tkDynArray: ;
  //              tkUString: ;
  //              tkClassRef: ;
  //              tkPointer: ;
  //              tkProcedure: ;
              end;
            end;
  //        end;
  //      end;
        end;
      end;
    end;
  end;
end;

procedure TLmxSerialization.EnumCarregarObjetoDeJson<T>(const AObjeto: ILmxEnumerable;
  const ADados: string; const AGetClasse : TOnGetClasseEnumJson; const AOnAddObject : TOnAddObjectEnumJson<T>);
var
  lObjetoJson: TJSONObject;
  lJsonArray: TJSONArray;
//  lPairObject: TJSONPair;
//  lPairAtributo: TJSONPair;
  lJsonStream : TStringStream;
  I : Integer;
  lObjeto: T; //TObject;
  {$IF CompilerVersion >= 32.0}
  lEnum: TJSONObject.TEnumerator;
  {$ELSE}
  lEnum: TJSONPairEnumerator;
  {$ELSE}
  lIndexObj : Integer;
  {$IFEND}


//  procedure CarregarObjeto(const AJsonValue : TJSONValue);
//  var
//    lObjeto : TObject;
//  begin
//    lObjeto := AGetClasse.Create;
//    CarregarObjetoDeJson(lObjeto, AJsonValue.ToString);
//    AOnAddObject(lObjeto);
//  end;

begin
  lJsonStream := TStringStream.Create(ADados);
  lObjetoJson := TJSONObject.Create;
  try
    lJsonStream.Position := 0;
    lObjetoJson.Parse(lJsonStream.Bytes, 0);

  {$IF CompilerVersion >= 23.0}
    lEnum := lObjetoJson.GetEnumerator;
    try
      while lEnum.MoveNext do
      begin
        if (lEnum.Current.JsonValue.InheritsFrom(TJSONArray)) then
        begin
          lJsonArray := TJSONArray(lEnum.Current.JsonValue);
          for I := 0 to lJsonArray.Count - 1 do
          begin
//            CarregarObjeto(lJsonArray.Items[I]);
            lObjeto := T.Create;
            CarregarObjetoDeJson(lObjeto, lJsonArray.Items[I].ToString);
            AOnAddObject(lObjeto);


////            Self.Add(lOrigemArquivo.Nome, lOrigemArquivo);
          end;
        end;
      end;
    finally
      FreeAndNil(lEnum);
    end;
  {$ELSE}
    for lIndexObj := 0 to lObjetoJson.Size - 1 do
    begin
      if (lObjetoJson.Get(lIndexObj).JsonValue.InheritsFrom(TJSONArray)) then
      begin
        lJsonArray := TJSONArray(lObjetoJson.Get(lIndexObj).JsonValue);
        for I := 0 to lJsonArray.Size - 1 do
        begin
//          CarregarObjeto(lJsonArray.Get(I));
            lObjeto := AGetClasse.Create;
            CarregarObjetoDeJson(lObjeto, lJsonArray.Get(I).ToString);
            AOnAddObject(lObjeto);

        end;
      end;
    end;
  {$IFEND}

  finally
    FreeAndNil(lObjetoJson);
    FreeAndNil(lJsonStream);
  end;
end;

function TLmxSerialization.EnumCriarJsonObject(
  const AObjeto: ILmxEnumerable): TJSONArray;
var
//  lEnum : IEnumerator;
//  lJsonArray : TJSONArray;
  I: Integer;
begin
//  Result := TJSONObject.Create;
  Result := TJSONArray.Create;
  for I := 0 to AObjeto.Count - 1 do
  begin
    Result.Add(CriarJsonObject(AObjeto.GetItemObject(I)));
  end;
//  Result.AddPair('Lista', lJsonArray);
end;

procedure TLmxSerialization.EnumGerarObjetoDeJson(const ALista: ILmxEnumerable;
  const ADados: TJsonValue; const AOnNovoITem: TOnNewItemObjectEnumJson);
var
  lJsonArray: TJSONArray;
  I: Integer;
  lObjeto: TObject;
begin
  ALista.Clear;
  {$IF CompilerVersion >= 23.0}
  if ADados.InheritsFrom(TJSONArray) then
  begin
    lJsonArray := TJSONArray(ADados);
    for I := 0 to lJsonArray.Count - 1 do
    begin
      lObjeto := ALista.GetNewItemObject;
      CarregarObjetoDeJson(lObjeto, lJsonArray.Items[I].ToString);
      if Assigned(AOnNovoITem) then
        AOnNovoITem(lObjeto, lJsonArray.Items[I].ToString);
    end;
  end;
  {$ELSE}
  if ADados.InheritsFrom(TJSONArray) then
  begin
    lJsonArray := TJSONArray(ADados);
    for I := 0 to lJsonArray.Size - 1 do
    begin
      lObjeto := ALista.GetNewItemObject;
      CarregarObjetoDeJson(lObjeto, lJsonArray.Get(I).ToString);
      if Assigned(AOnNovoITem) then
        AOnNovoITem(lObjeto, lJsonArray.Get(I).ToString);
    end;
  end;
  {$IFEND}
end;

procedure TLmxSerialization.EnumGerarObjetoDeJson(const ALista: ILmxEnumerable; const ADados: string;
  const AOnNovoITem: TOnNewItemObjectEnumJson);
var
  lObjetoJson: TJSONObject;
  lJsonStream : TStringStream;
//  lJsonValue : TJSONValue;
  lInicial: string;
  lArray: TJSONArray;
  {$IF CompilerVersion >= 32.0}
  lEnum: TJSONObject.TEnumerator;
  {$ELSE}
  lEnum: TJSONPairEnumerator;
  {$ENDIF}
//  {$ELSE}
//  lIndexObj : Integer;
//  lJsonArray: TJSONArray;
begin
  if ADados <> '' then
  begin
    lInicial := ADados.Substring(0, 1);
    if lInicial = '['  then
    begin
      lArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ADados), 0) as TJSONArray;
      try
        if lArray = nil then
          raise Exception.Create('O Json passado para ser carregado na classe ' + Self.ClassName + ' parece não ser válido.');

        EnumGerarObjetoDeJson(ALista, lArray, AOnNovoITem);
      finally
        lArray.Free;
      end;
    end else begin

      lJsonStream := TStringStream.Create(ADados,TEncoding.UTF8);
      lObjetoJson := TJSONObject.Create;
      try
        lJsonStream.Position := 0;
        lObjetoJson.Parse(lJsonStream.Bytes, 0);
      {$IF CompilerVersion >= 23.0}
        lEnum := lObjetoJson.GetEnumerator;
        try
          while lEnum.MoveNext do
          begin
            EnumGerarObjetoDeJson(ALista, lEnum.Current.JsonValue, AOnNovoITem);
          end;
        finally
          FreeAndNil(lEnum);
        end;
      {$ELSE}
        for lIndexObj := 0 to lObjetoJson.Size - 1 do
        begin
          if (lObjetoJson.Get(lIndexObj).JsonValue.InheritsFrom(TJSONArray)) then
          begin
            lJsonArray := TJSONArray(lObjetoJson.Get(lIndexObj).JsonValue);
            for I := 0 to lJsonArray.Size - 1 do
              EnumGerarObjetoDeJson(ALista, lJsonArray.Get(I), AOnNovoITem);
          end;
        end;
      {$ENDIF}

      finally
        FreeAndNil(lObjetoJson);
        FreeAndNil(lJsonStream);
      end;
    end;
  end;
end;

class function TLmxSerialization.ExternalDataSetToJsonArrayString(
  const pDataSet: TDataSet; const pObjectFormat: Boolean; const pOnCarregarITem: TProc<TJsonObject>): string;
var
  lSerializationDataSet : TLmxSerializationDataSet;
begin
  Result := '';
  if pDataSet.Active and not pDataSet.IsEmpty then
  begin
    lSerializationDataSet := TLmxSerializationDataSet.Create;
    try
      if pObjectFormat then
        Result := lSerializationDataSet.DataSetToJsonStringObjectFormat(pDataSet, pOnCarregarITem)
      else
        Result := lSerializationDataSet.DataSetToJsonString(pDataSet);
    finally
      lSerializationDataSet.Free;
    end;
  end;
end;

class function TLmxSerialization.ExternalDataSetToJsonString(
  const pDataSet: TDataSet): string;
var
  lSerializationDataSet : TLmxSerializationDataSet;
begin
  lSerializationDataSet := TLmxSerializationDataSet.Create;
  try
    Result := lSerializationDataSet.DataSetToJsonItemStringObjectFormat(pDataSet)
  finally
    lSerializationDataSet.Free;
  end;
end;

class function TLmxSerialization.ExternalGetCaminhoRest(
  const AObject: TObject): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(AObject);
  try
    Result := lSerialization.GetCaminhoRest;
  finally
    FreeAndNil(lSerialization);
  end;
end;

class function TLmxSerialization.ExternalScriptInsert(
  const AObject: TObject): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(AObject, False);
  try
    Result := lSerialization.ToScriptInsert;
  finally
    FreeAndNil(lSerialization);
  end;
end;

class function TLmxSerialization.ExternalToParamsGet(
  const AObject: TObject): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(AObject, False);
  try
    Result := lSerialization.ToParamsGet;
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxSerialization.CriarListaParametros(
  const AObjeto: TObject): TStringList;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lObjeto: TStringList;
//  lObjetoJson: TJSONObject;
//  lChild: IXmlNode;
begin
  Result := TStringList.Create;

  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lDescricaoAtributo := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
      lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
  end;
  if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
    lDescricaoAtributo := AObjeto.ClassName;

//    if lDescricaoAtributo = '' then
//      lDescricaoAtributo := AObjeto.ClassName;
//
//    lChild := ANodo.AddChild(lDescricaoAtributo);

  if lDescricaoAtributo <> '' then
  begin
//      lDescricaoAtributo := AObjeto.ClassName;

//    lChild := Result.AddPair( AddChild(lDescricaoAtributo);


    lRttiProperties := lRttiType.GetProperties;
    for lProperty in lRttiProperties do
    begin
      lDescricaoAtributo := lProperty.Name;
      lFieldAtributes := lProperty.GetAttributes;
      lFieldAtribute := nil;
      if (lProperty.GetValue(AObjeto).Kind = tkClass) then
      begin
        lObjeto := CriarListaParametros(lProperty.GetValue(AObjeto).AsObject);
        Result.Objects[Result.Add(lDescricaoAtributo)] := lObjeto;
      end
      else
      begin
        for lFieldAtribute in lFieldAtributes do
        begin
          if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
            lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
              .Descricao;
        end;
        if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
        begin
          if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
          begin
            Result.Add(lDescricaoAtributo + '=' + BoolToStr(lProperty.GetValue(AObjeto).AsBoolean, True));
          end else begin
            Result.Add(lDescricaoAtributo + '=' + lProperty.GetValue(AObjeto).AsString);
          end;
        end;
      end;
    end;
  end;
end;

procedure TLmxSerialization.FromJson(const ADados: string);
begin
  CarregarObjetoDeJson(FObject, ADados);
end;

class function TLmxSerialization.FromJsonArrayString(const AObject : TObject;
  const ALista: ILmxEnumerable; const ADados: string;
  const AOnNovoITem: TOnNewItemObjectEnumJson;
  const ASomenteSerializaveis: Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(AObject, ASomenteSerializaveis);
  try
    lSerialization.EnumGerarObjetoDeJson(ALista, ADados, AOnNovoITem);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;

procedure TLmxSerialization.FromJsonFile(const AFileName: string);
begin
  if TFile.Exists(AFileName) then
    FromJson(TFile.ReadAllText(AFileName));
end;

class function TLmxSerialization.FromJsonString(const AObject: TObject;
  const ADados: string; const ASomenteSerializaveis: Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(AObject, ASomenteSerializaveis);
  try
    lSerialization.FromJson(ADados);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;

procedure TLmxSerialization.FromOther(const AOther: TObject);
begin
  ClonarObjeto(AOther, FObject);
end;

procedure TLmxSerialization.FromXml(const ADados: string);
var
  lDocumento: IXMLDocument;
  lRoot: IXmlNode;
begin
  lDocumento := TXMLDocument.Create(nil);
  try
    try
      lDocumento.LoadFromXML(ADados);
    except
      raise Exception.Create('Não foi possível carregar o objeto ');
    end;
    lRoot := lDocumento.DocumentElement;
    CarregarObjetoDeNodo(lRoot, FObject);
  finally
    lDocumento := nil;
  end;
end;

procedure TLmxSerialization.FromXmlFile(const AFileName: string);
var
  lDocumento: IXMLDocument;
  lRoot: IXmlNode;
begin
  if TFile.Exists(AFileName) then
  begin
    lDocumento := TXMLDocument.Create(nil);
    try
      try
        lDocumento.LoadFromFile(AFileName);
        lRoot := lDocumento.DocumentElement;
        CarregarObjetoDeNodo(lRoot, FObject);
      except

      end;
    finally
      lDocumento := nil;
    end;
  end;
end;

function TLmxSerialization.GetCaminhoRest: string;
var
  lRttiType: TRttiType;
  lClassAttributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
begin
  lRttiType := FContexto.GetType(FObject.ClassType);
  Result := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeCaminhoRest.ClassName) then
      Result := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
  end;
end;

class function TLmxSerialization.GetClassAttributes(
  const AClasse: TClass; const APropriedades : TLmxServerComandMethodPropriedadesClasse): Boolean;
var
  lRttiType: TRttiType;
//  lClassAttributes: TArray<TCustomAttribute>;
//  lContexto : TRttiContext;
//  lFieldAtribute: TCustomAttribute;
//  lMetodo: TRttiMethod;
//  lMetodoAttribute: TLmxServerComandMethodAttributes;
//  lParametro: TRttiParameter;
//  lParametroAtributo: TLmxServerComandMethodParameters;
  lProperty: TRttiProperty;
  lPropedadeClasse: TLmxServerComandMethodPropriedadeClasse;
begin
//  Result := False;

//  lContexto := TRttiContext.Create;
//  try
    lRttiType := FContexto.GetType(AClasse);
//    lClassAttributes := lRttiType.GetAttributes;
//    for lFieldAtribute in lClassAttributes do
//    begin
//      if lFieldAtribute.ClassNameIs(TLmxAttributeComandoAutenticacaoObrigatoria.ClassName) then
//        Result.AutenticacaoObrigatoria := True;
//    end;

//    APropriedades := TLmxServerComandMethodPropriedadesClasse.Create;

    for lProperty in lRttiType.GetProperties do
    begin

       lPropedadeClasse := TLmxServerComandMethodPropriedadeClasse.Create;

       lPropedadeClasse.Nome := lProperty.Name;
       lPropedadeClasse.TypeKind := lProperty.PropertyType.TypeKind;


       APropriedades.Add(lPropedadeClasse);
    end;

    Result := True;


//  finally
//    if AContext = nil then
//      lContexto.Free;
//  end;
end;

function TLmxSerialization.GetDescricaoObjeto(const AObjeto: TObject; out AFormato : TLmxSerializationFormat): string;
var
  lRttiType: TRttiType;
  lDescricaoAtributo: string;
  lClassAttributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
begin
  lRttiType := FContexto.GetType(AObjeto.ClassType);

  AFormato := sfLmx;

  lDescricaoAtributo := '';
  lClassAttributes := lRttiType.GetAttributes;
  for lFieldAtribute in lClassAttributes do
  begin
    if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
    begin
      lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
        .Descricao;
      AFormato := TLmxAttributeSerializable(lFieldAtribute).Formato;
    end;
  end;
  if not FSomenteSerializaveis and (lDescricaoAtributo = '') then
    lDescricaoAtributo := AObjeto.ClassName;

  Result := lDescricaoAtributo;
end;


{function TLmxSerialization.GetMetodo(const AMetodo: string;
  const ACaminho : string; out AEvento: TRttiMethod; out APermiteGet, APermitePost : Boolean): Boolean;
var
  lRttiType: TRttiType;
  lClassAttributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lMetodo: TRttiMethod;
  lCaminhoMetodo: string;
  lMetodosPermitidos: TLmxAttributeComandoMetodos;
begin
//  Result := False;

  AEvento := nil;

  lRttiType := FContexto.GetType(FObject.ClassInfo);
  for lMetodo in lRttiType.GetMethods do
  begin
    if (AEvento = nil) then
    begin
      lCaminhoMetodo := '/' + lMetodo.Name;
      lClassAttributes := lMetodo.GetAttributes;
      for lFieldAtribute in lClassAttributes do
      begin
        if lFieldAtribute.ClassNameIs(TLmxAttributeComando.ClassName) then
        begin
          lCaminhoMetodo := TLmxAttributeComando(lFieldAtribute).Nome;
          lMetodosPermitidos := TLmxAttributeComando(lFieldAtribute).Metodos;
          if lMetodosPermitidos = [] then
          begin
            APermiteGet := True;
            APermitePost := True;
          end else begin
            APermiteGet :=  cmGet in lMetodosPermitidos;
            APermitePost := cmPost in lMetodosPermitidos;
          end;
        end;
      end;

      if (lCaminhoMetodo = AMetodo) then
        AEvento := lMetodo;

    end;
  end;

  Result := (AEvento <> nil);
end;   }

class function TLmxSerialization.ObterMetodoCreate(const AClasse : TClass; out AEvento: TRttiMethod): Boolean;
var
  lRttiType: TRttiType;
//  lClassAttributes: TArray<TCustomAttribute>;
//  lContexto : TRttiContext;
//  lFieldAtribute: TCustomAttribute;
begin
//  lContexto := TRttiContext.Create;
//  try
    lRttiType := FContexto.GetType(AClasse);
    AEvento := lRttiType.GetMethod('Create');
    Result := (AEvento <> nil);
//  finally
//    lContexto.Free;
//  end;
end;

class function TLmxSerialization.GetServerCommandAttributes(
  const AClasse: TClass): TLmxServerComandAttributes;
var
  lRttiType: TRttiType;
  lClassAttributes: TArray<TCustomAttribute>;
//  lContexto : TRttiContext;
  lFieldAtribute: TCustomAttribute;
  lMetodo: TRttiMethod;
  lMetodoAttribute: TLmxServerComandMethodAttributes;
  lParametro: TRttiParameter;
  lParametroAtributo: TLmxServerComandMethodParameters;
  lClasse: TClass;
  lAttributesParam : TCustomAttribute;
//  lEnumType: ILmxEnumerable;

  function InternalGetClassAttributes(const AClasse: TClass;
    const APropriedades : TLmxServerComandMethodPropriedadesClasse) : Boolean;
  var
//    lClassAttributes: TArray<TCustomAttribute>;
    lContexto : TRttiContext;
    lProperty: TRttiProperty;
    lPropedadeClasse: TLmxServerComandMethodPropriedadeClasse;
    lRttiTypeClass: TRttiType;
  begin
//    Result := False;

    lRttiTypeClass := lContexto.GetType(AClasse);
//    lClassAttributes := lRttiType.GetAttributes;
//    for lFieldAtribute in lClassAttributes do
//    begin
//      if lFieldAtribute.ClassNameIs(TLmxAttributeComandoAutenticacaoObrigatoria.ClassName) then
//        Result.AutenticacaoObrigatoria := True;
//    end;

//    APropriedades := TLmxServerComandMethodPropriedadesClasse.Create;

    for lProperty in lRttiTypeClass.GetProperties do
    begin

       lPropedadeClasse := TLmxServerComandMethodPropriedadeClasse.Create;

       lPropedadeClasse.Nome := lProperty.Name;
       lPropedadeClasse.TypeKind := lProperty.PropertyType.TypeKind;

       APropriedades.Add(lPropedadeClasse);
    end;

    Result := True;
  end;



begin
  Result := TLmxServerComandAttributes.Create;

//  lContexto := TRttiContext.Create;
//  try
    lRttiType := FContexto.GetType(AClasse);
    lClassAttributes := lRttiType.GetAttributes;
    lMetodoAttribute := nil;
    for lFieldAtribute in lClassAttributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeComandoAutenticacaoObrigatoria.ClassName) then
        Result.AutenticacaoObrigatoria := True;

      if lFieldAtribute.ClassNameIs(TLmxAttributeComandoInfo.ClassName) then
      begin
        if lMetodoAttribute = nil then
          lMetodoAttribute := TLmxServerComandMethodAttributes.Create;
        lMetodoAttribute.Nome := TLmxAttributeComandoInfo(lFieldAtribute).Nome; //TLmxAttributeComandoInfo(lFieldAtribute).Nome;
        lMetodoAttribute.Rota := ''; //TLmxAttributeComandoInfo(lFieldAtribute).Caminho;
        lMetodoAttribute.RotaConfigurada := True;
        lMetodoAttribute.Sumario := TLmxAttributeComandoInfo(lFieldAtribute).Sumario;
        lMetodoAttribute.Descricao := TLmxAttributeComandoInfo(lFieldAtribute).Descricao;
        Result.Descricao := TLmxAttributeComandoInfo(lFieldAtribute).Descricao;
        if TLmxAttributeComandoInfo(lFieldAtribute).Tipo.Equals('GET') then
          lMetodoAttribute.ModosPermitidos := [TLmxAttributeComandoMetodo.cmGet];
        if TLmxAttributeComandoInfo(lFieldAtribute).Tipo.Equals('POST') then
          lMetodoAttribute.ModosPermitidos := [TLmxAttributeComandoMetodo.cmPost];
      end;

      if lFieldAtribute.ClassNameIs(TLmxAttributeComandoInfoParametro.ClassName) then
      begin
        if lMetodoAttribute = nil then
          lMetodoAttribute := TLmxServerComandMethodAttributes.Create;

        if TLmxAttributeComandoInfoParametro(lFieldAtribute).TipoParametro = 'Entrada' then
        begin

          lParametroAtributo := TLmxServerComandMethodParameters.Create;
          lParametroAtributo.Nome := TLmxAttributeComandoInfoParametro(lFieldAtribute).Nome;
          lParametroAtributo.QualifiedName := TLmxAttributeComandoInfoParametro(lFieldAtribute).TipoValor;
          lParametroAtributo.TypeKind := tkString;
          lParametroAtributo.FromQuery := True;

          lMetodoAttribute.Parametros.Add(lParametroAtributo);
        end else begin
//          lMetodoAttribute.Retorno.Nome := 'Retorno';
          lClasse := TLmxAttributeComandoInfoParametro(lFieldAtribute).ClasseBase;
          if lClasse <> nil then
          begin
            lMetodoAttribute.Retorno.Nome := 'Retorno';
            lMetodoAttribute.Retorno.TypeKind := tkClass;
            lMetodoAttribute.Retorno.NomeClasse := lClasse.ClassName;
            InternalGetClassAttributes(lClasse, lMetodoAttribute.Retorno.Propriedades);
            lMetodoAttribute.Retorno.QualifiedName := lClasse.ClassName;
          end else begin
            lMetodoAttribute.Retorno.Nome := TLmxAttributeComandoInfoParametro(lFieldAtribute).Nome;
            lMetodoAttribute.Retorno.QualifiedName := TLmxAttributeComandoInfoParametro(lFieldAtribute).TipoValor;
          end;
        end;
      end;
    end;

    if lMetodoAttribute <> nil then
      Result.Metodos.Add(lMetodoAttribute);

    for lMetodo in lRttiType.GetMethods do
    begin
      lMetodoAttribute := TLmxServerComandMethodAttributes.Create;
      lMetodoAttribute.Nome := lMetodo.Name;

      lClassAttributes := lMetodo.GetAttributes;
      for lFieldAtribute in lClassAttributes do
      begin
        if lFieldAtribute.ClassNameIs(HttpPost.ClassName) then
          lMetodoAttribute.ModosPermitidos := lMetodoAttribute.ModosPermitidos + [cmPost];
        if lFieldAtribute.ClassNameIs(HttpPut.ClassName) then
          lMetodoAttribute.ModosPermitidos := lMetodoAttribute.ModosPermitidos + [cmPut];
        if lFieldAtribute.ClassNameIs(HttpGet.ClassName) then
          lMetodoAttribute.ModosPermitidos := lMetodoAttribute.ModosPermitidos + [cmGet];
        if lFieldAtribute.ClassNameIs(HttpDelete.ClassName) then
          lMetodoAttribute.ModosPermitidos := lMetodoAttribute.ModosPermitidos + [cmDelete];

        if lFieldAtribute.ClassNameIs(TLmxAttributeComandoAutenticacaoObrigatoria.ClassName) then
          lMetodoAttribute.AutenticacaoObrigatoria := True;

        if lFieldAtribute.ClassNameIs(TLmxAttributeComando.ClassName) then
        begin
          lMetodoAttribute.RotaConfigurada := True;
          lMetodoAttribute.Rota := TLmxAttributeComando(lFieldAtribute).Nome;
          lMetodoAttribute.RotaSemParametros := TLmxAttributeComando(lFieldAtribute).RotaSetParametros;
          lMetodoAttribute.ParametrosRota := TLmxAttributeComando(lFieldAtribute).ParametrosDeRota;
          lMetodoAttribute.PosParametrosRota := TLmxAttributeComando(lFieldAtribute).PosParametrosRota;
//          lMetodoAttribute.ModosPermitidos := TLmxAttributeComando(lFieldAtribute).Metodos;
          lMetodoAttribute.Evento := lMetodo;
        end;

        if lFieldAtribute.ClassNameIs(TLmxAttributeComandoResult.ClassName) then
        begin
          lMetodoAttribute.Resultados.Add(
            TLmxServerComandMethodPropriedadeResultado.Create(
              TLmxAttributeComandoResult(lFieldAtribute).ResultCode,
              TLmxAttributeComandoResult(lFieldAtribute).Description));
        end;

        if lFieldAtribute.ClassNameIs(TLmxAttributeComandoDescricao.ClassName) then
        begin
          lMetodoAttribute.Sumario := TLmxAttributeComandoDescricao(lFieldAtribute).Summary;
          lMetodoAttribute.Descricao := TLmxAttributeComandoDescricao(lFieldAtribute).Description;
        end;
      end;

      if (lMetodo.ReturnType <> nil) then
      begin
        lMetodoAttribute.Retorno.Nome := 'Retorno';
        lMetodoAttribute.Retorno.TypeKind := lMetodo.ReturnType.TypeKind;

        if (lMetodo.ReturnType.TypeKind = tkClass) and (lMetodo.ReturnType.IsInstance) then
        begin
          lClasse := GetTypeData(lMetodo.ReturnType.Handle)^.ClassType;

          lMetodoAttribute.Retorno.NomeClasse := lClasse.ClassName;
  //        if Supports(lClasse, ILmxEnumerable, lEnumType) then
  //        begin
  //
  //        end;

          InternalGetClassAttributes(lClasse, lMetodoAttribute.Retorno.Propriedades);
        end;
      end;


      for lParametro in lMetodo.GetParameters do
      begin

        if (lParametro.ParamType <> nil) then
        begin
          lParametroAtributo := TLmxServerComandMethodParameters.Create;
          lParametroAtributo.Nome := lParametro.Name;

          lParametroAtributo.TypeKind := lParametro.ParamType.TypeKind;
          lParametroAtributo.Handle := lParametro.ParamType.Handle;
          lParametroAtributo.QualifiedName := lParametro.ParamType.QualifiedName;


          if (lParametro.ParamType.TypeKind = tkClass) and (lParametro.ParamType.IsInstance) then
          begin

            lClasse := GetTypeData(lParametro.ParamType.Handle)^.ClassType;
            lParametroAtributo.NomeClasse := lClasse.ClassName;

            InternalGetClassAttributes(lClasse, lParametroAtributo.Propriedades);
          end;

          for lAttributesParam in lParametro.GetAttributes do
          begin
            if lAttributesParam.ClassNameIs(FromQuery.ClassName) then
              lParametroAtributo.FromQuery := True;
            if lAttributesParam.ClassNameIs(FromBody.ClassName) then
              lParametroAtributo.FromBody := True;
            if lAttributesParam.ClassNameIs(FromHeader.ClassName) then
              lParametroAtributo.FromHeader := True;
            if lAttributesParam.ClassNameIs(FromServices.ClassName) then
              lParametroAtributo.FromServices := True;
            if lAttributesParam.ClassNameIs(FromParams.ClassName) then
              lParametroAtributo.FromParams := True;
          end;

          lMetodoAttribute.Parametros.Add(lParametroAtributo);
        end;
      end;

      if lMetodoAttribute.RotaConfigurada then
        Result.Metodos.Add(lMetodoAttribute)
      else
        lMetodoAttribute.Free;

    end;

//  finally
//    lContexto.Free;
//  end;
end;

class function TLmxSerialization.ObterCaminhoRest(
  const AClasse: TClass): TLmxRotasRest;
var
  lRttiType: TRttiType;
  lClassAttributes: TArray<TCustomAttribute>;
//  lContexto : TRttiContext;
  lFieldAtribute: TCustomAttribute;
begin
  Result := TLmxRotasRest.Create;

//  lContexto := TRttiContext.Create;
//  try
    lRttiType := FContexto.GetType(AClasse);
//    Result := '';
    lClassAttributes := lRttiType.GetAttributes;
    for lFieldAtribute in lClassAttributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeCaminhoRest.ClassName) then
        Result.NovaRota(TLmxAttributeCaminhoRest(lFieldAtribute).Caminho);
    end;
//  finally
//    lContexto.Free;
//  end;
end;

function TLmxSerialization.ObterValorChavePrimaria(
  const AObjeto: TObject): Integer;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
begin
  Result := 0;

  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lRttiProperties := lRttiType.GetProperties;
  for lProperty in lRttiProperties do
  begin
    lFieldAtributes := lProperty.GetAttributes;
//    lFieldAtribute := nil;
    for lFieldAtribute in lFieldAtributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataPrimaryKey.ClassName) then
      begin
        Result := lProperty.GetValue(AObjeto).AsInteger;
        Exit;
      end;
    end;
  end;
end;

//function TLmxSerialization.ObjectToJson(const AObjeto: TObject; const AConversor : TTypeObjectsConverter): TJSONValue;
//var
//  lMarshal : TJSONMarshal;
//begin
//  lMarshal := TJSONMarshal.Create(TJSONConverter.Create);
//  try
//    {$IFDEF VER270}
//    lMarshal.RegisterConverter(AObjeto.ClassType, AConversor);
//    {$ELSE}
//    lMarshal.RegisterConverter(AObjeto.ClassType, AConversor);
//    {$ENDIF}
//    Result := lMarshal.Marshal(AObjeto);
//  finally
//    lMarshal.Free;
//  end;
//end;

procedure TLmxSerialization.SalvarObjetoEmNodo(const ANodo: IXmlNode;
  const AObjeto: TObject);
var
  lFormato : TLmxSerializationFormat;
begin
  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  GetDescricaoObjeto(AObjeto, lFormato);
  if lFormato = sfLmx then
  begin
//    ANodo.Attributes['FormatType'] := '';
    SalvarObjetoEmNodoAtributos(ANodo, AObjeto)
  end else
    SalvarObjetoEmNodoChilds(ANodo, AObjeto);
end;

procedure TLmxSerialization.SalvarObjetoEmNodoAtributos(const ANodo: IXmlNode;
  const AObjeto: TObject);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lChild: IXmlNode;
  lFormato : TLmxSerializationFormat;
  lValorOriginal: TValue;
begin
  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lDescricaoAtributo := GetDescricaoObjeto(AObjeto, lFormato); // '';
  if lDescricaoAtributo <> '' then
  begin
    lRttiType := FContexto.GetType(AObjeto.ClassType);
    if ANodo.NodeName = lDescricaoAtributo then
      lChild := ANodo
    else
      lChild := ANodo.AddChild(lDescricaoAtributo);

    lRttiProperties := lRttiType.GetProperties;
    for lProperty in lRttiProperties do
    begin
      lDescricaoAtributo := lProperty.Name;
      lFieldAtributes := lProperty.GetAttributes;
      lFieldAtribute := nil;
      if (lProperty.GetValue(AObjeto).Kind = tkClass) then
        SalvarObjetoEmNodoAtributos(lChild, lProperty.GetValue(AObjeto).AsObject)
      else
      begin
        for lFieldAtribute in lFieldAtributes do
        begin
          if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
            lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
              .Descricao;
        end;
        if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
        begin
          if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
          begin
            lChild.Attributes[lDescricaoAtributo]
              := lProperty.GetValue(AObjeto).AsBoolean;
          end else if lProperty.PropertyType.TypeKind = tkEnumeration then begin
            lValorOriginal := lProperty.GetValue(AObjeto);
            lChild.Attributes[lDescricaoAtributo]
              := GetEnumName(lValorOriginal.TypeInfo, lValorOriginal.AsOrdinal);
          end else begin
            lChild.Attributes[lDescricaoAtributo]
              := lProperty.GetValue(AObjeto).AsVariant;
          end;
        end;
      end;
    end;
  end;
end;

procedure TLmxSerialization.SalvarObjetoEmNodoChilds(const ANodo: IXmlNode;
  const AObjeto: TObject);
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
  lDescricaoAtributo: string;
  lChild: IXmlNode;
  lFormato : TLmxSerializationFormat;
begin
  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lDescricaoAtributo := GetDescricaoObjeto(AObjeto, lFormato); // '';
  if lDescricaoAtributo <> '' then
  begin
    lRttiType := FContexto.GetType(AObjeto.ClassType);
    if ANodo.NodeName = lDescricaoAtributo then
      lChild := ANodo
    else
      lChild := ANodo.AddChild(lDescricaoAtributo);

    lRttiProperties := lRttiType.GetProperties;
    for lProperty in lRttiProperties do
    begin
      lDescricaoAtributo := lProperty.Name;
      lFieldAtributes := lProperty.GetAttributes;
      lFieldAtribute := nil;
      if (lProperty.GetValue(AObjeto).Kind = tkClass) then
        SalvarObjetoEmNodoChilds(lChild, lProperty.GetValue(AObjeto).AsObject)
      else
      begin
        for lFieldAtribute in lFieldAtributes do
        begin
          if lFieldAtribute.ClassNameIs(TLmxAttributeSerializable.ClassName) then
            lDescricaoAtributo := TLmxAttributeSerializable(lFieldAtribute)
              .Descricao;
        end;
        if (lFieldAtribute <> nil) or (not FSomenteSerializaveis) then
        begin
          if lProperty.PropertyType.QualifiedName = 'System.Boolean' then
          begin
            lChild[lDescricaoAtributo]
              := lProperty.GetValue(AObjeto).AsBoolean;
          end else begin
            lChild[lDescricaoAtributo]
              := lProperty.GetValue(AObjeto).AsVariant;
          end;
        end;
      end;
    end;
  end;
end;

function TLmxSerialization.SetarValorChavePrimaria(const AObjeto: TObject;
  const AValorChave: Integer): Boolean;
var
  lRttiType: TRttiType;
  lRttiProperties: TArray<TRttiProperty>;
  lProperty: TRttiProperty;
  lFieldAtributes: TArray<TCustomAttribute>;
  lFieldAtribute: TCustomAttribute;
begin
  Result := False;

  if AObjeto = nil then
    raise Exception.Create('Um objeto válido deve ser passado como parâmetro !');

  lRttiType := FContexto.GetType(AObjeto.ClassType);

  lRttiProperties := lRttiType.GetProperties;
  for lProperty in lRttiProperties do
  begin
    lFieldAtributes := lProperty.GetAttributes;
//    lFieldAtribute := nil;
    for lFieldAtribute in lFieldAtributes do
    begin
      if lFieldAtribute.ClassNameIs(TLmxAttributeMetadataPrimaryKey.ClassName) then
      begin
        lProperty.SetValue(AObjeto, TValue.From<Integer>(AValorChave));
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TLmxSerialization.ToJson: string;
//{$IF CompilerVersion >= 23.0}
//{$ELSE}
var
  lObjeto: TJSONObject;
//{$IFEND}
begin
//{$IF CompilerVersion >= 23.0}
//  Result := TJson.ObjectToJsonString(FObject);
//{$ELSE}
  if FEnumerable <> nil then
  begin
    lObjeto := TJSONObject.Create;
    lObjeto.AddPair(FEnumerable.GetDescription, EnumCriarJsonObject(FEnumerable));
  end else begin
    lObjeto := CriarJsonObject(FObject);
  end;

  try
    Result := lObjeto.ToString;
  finally
    FreeAndNil(lObjeto);
  end;
//{$IFEND}
end;

function TLmxSerialization.ToJsonArray: string;
//var
//  lObjeto: TJSONObject;
begin
  Result := '';
//  lObjeto := EnumCriarJsonObject(FObject as IEnumerable);
//  try
//    Result := lObjeto.ToString;
//  finally
//    FreeAndNil(lObjeto);
//  end;
end;

class function TLmxSerialization.ToJsonArrayString(const ALista: ILmxEnumerable; const ASomenteSerializaveis: Boolean): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(ALista, ASomenteSerializaveis);
  try
    Result := lSerialization.ToJson;
  finally
    FreeAndNil(lSerialization);
  end;
end;

procedure TLmxSerialization.ToJsonFile(const AFileName: string);
begin
  TFile.WriteAllText(AFileName, ToJson);
end;

class function TLmxSerialization.ToJsonString(const AObject: TObject;
  const ASomenteSerializaveis: Boolean): string;
var
  lSerialization: TLmxSerialization;
  lSerializationArray : ILmxEnumerable;
begin
  if Supports(AObject, ILmxEnumerable, lSerializationArray) then
  begin
    //lSerializationArray := TInterfacedObject(AObject) as ILmxEnumerable;
    Result := ToJsonArrayString(lSerializationArray, ASomenteSerializaveis)
  end else begin
    lSerialization := TLmxSerialization.Create(AObject, ASomenteSerializaveis);
    try
      Result := lSerialization.ToJson;
    finally
      FreeAndNil(lSerialization);
    end;
  end;
end;

function TLmxSerialization.ToParamsGet: string;
var
  lObjeto: TStringList;
begin
  Result := '';
  lObjeto := CriarListaParametros(FObject);
  try
    lObjeto.Delimiter := '&';
    if lObjeto.Count > 0 then
      Result := '?' + lObjeto.DelimitedText;
  finally
    FreeAndNil(lObjeto);
  end;
end;

function TLmxSerialization.ToScriptInsert: string;
begin
  Result := '';
end;

function TLmxSerialization.ToString: string;
begin
  Result := ToXml;
end;

function TLmxSerialization.ToXml: string;
var
  lDocumento: IXMLDocument;
  lDescricao : string;
  lFormato : TLmxSerializationFormat;
begin
  lDocumento := TXMLDocument.Create(nil);
  try
    if FRetornoFormatado then
      lDocumento.Options := lDocumento.Options + [doNodeAutoIndent];
    lDocumento.Active := True;
    lDescricao := GetDescricaoObjeto(FObject, lFormato);
    lDocumento.AddChild(lDescricao);
    SalvarObjetoEmNodo(lDocumento.DocumentElement, FObject);
    Result := Trim(lDocumento.XML.Text);
  finally
    lDocumento := nil;
  end;
end;

procedure TLmxSerialization.ToXmlFile(const AFileName: string);
var
  lDocumento: IXMLDocument;
  lPrincipal: IXMLNode;
  lDescricaoObjeto: string;
  lNomeArquivo: string;
  lCriarNovo : Boolean;
  lFormato : TLmxSerializationFormat;
begin
  lDocumento := TXMLDocument.Create(nil);
  try
    if FRetornoFormatado then
      lDocumento.Options := lDocumento.Options + [doNodeAutoIndent];
    lDescricaoObjeto := GetDescricaoObjeto(FObject, lFormato);
    lNomeArquivo := TPath.GetFileNameWithoutExtension(AFileName);
    lCriarNovo := (not TFile.Exists(AFileName)) or (lNomeArquivo = lDescricaoObjeto);
    if lCriarNovo then
    begin
      lDocumento.Active := True;
      lPrincipal := lDocumento.AddChild(lDescricaoObjeto);
      lPrincipal.Attributes['FormatType'] := '';
    end else begin
      lDocumento.LoadFromFile(AFileName);
      if lDocumento.DocumentElement.ChildNodes.FindNode(lDescricaoObjeto) <> nil then
        lDocumento.DocumentElement.ChildNodes.Delete(lDescricaoObjeto);
      lPrincipal := lDocumento.DocumentElement.AddChild(lDescricaoObjeto);
    end;
    SalvarObjetoEmNodo(lPrincipal, FObject);
//    if (lDocumento.FileName <> '') then
//      lDocumento.Refresh;
    lDocumento.SaveToFile(AFileName);
  finally
    lDocumento := nil;
  end;
end;


{ TLmxRotasRest }

procedure TLmxRotasRest.NovaRota(const ARota: string);
var
  lRota: TLmxRotaRest;
begin
  lRota := TLmxRotaRest.Create;
  lRota.Rota := ARota;
  Self.Add(lRota);
end;

{ TLmxServerComandAttributes }

constructor TLmxServerComandAttributes.Create;
begin
  FMetodos := TLmxServerComandMethodAttributesList.Create;
end;

destructor TLmxServerComandAttributes.Destroy;
begin
  FreeAndNil(FMetodos);
  inherited;
end;

{ TLmxServerComandMethodAttributes }

constructor TLmxServerComandMethodAttributes.Create;
begin
  FParametros := TLmxServerComandMethodParametersList.Create;
  FRetorno := TLmxServerComandMethodParameters.Create;
  FResultados := TLmxServerComandMethodPropriedadeResultados.Create;
end;

destructor TLmxServerComandMethodAttributes.Destroy;
begin
  FResultados.Free;
  FRetorno.Free;
  FParametros.Free;
  inherited;
end;

function TLmxServerComandMethodAttributes.ObterRotaMetodo: string;
begin
  Result := '/' + FNome;
  if FRotaConfigurada then
    Result := FRota;
end;

function TLmxServerComandMethodAttributes.ParametroRotaValido(
  const pValorParametro: string; out pValor : string; out APosParametro : string): Boolean;
var
  lParametro: TLmxServerComandMethodParameters;
  lValorInteiro: Integer;
  lValorFloat: Double;
  lValorParametro: string;
  lPosicaoProximaQuebra: Integer;
begin
  Result := False;
  lValorParametro := pValorParametro;

  lParametro := FParametros.ObterParametroDeRota(FParametrosRota);
  if lParametro <> nil then
  begin

    if lValorParametro.Contains('/') then
    begin
//      if lValorParametro[1] = '/' then
//        lValorParametro := Copy(lValorParametro, 2, length(lValorParametro);
      lPosicaoProximaQuebra := lValorParametro.IndexOf('/', 2);
      if lPosicaoProximaQuebra = -1 then
        lPosicaoProximaQuebra := length(lValorParametro)
      else
        APosParametro := Copy(lValorParametro, lPosicaoProximaQuebra + 1, Length(lValorParametro) - 1);
      lValorParametro := Copy(lValorParametro, 2, lPosicaoProximaQuebra - 1)  //lValorParametro.Replace('/', '', [rfIgnoreCase]);
    end;
    pValor := lValorParametro;
    case lParametro.TypeKind of
      tkUnknown: ;
      tkInteger, tkInt64 :
          Result := TryStrToInt(lValorParametro, lValorInteiro);
      tkChar, tkString, tkWChar, tkLString, tkWString, tkUString :
        Result := lValorParametro <> '';
      tkFloat:
        Result := TryStrToFloat(lValorParametro, lValorFloat);
    end;
  end;
end;

function TLmxServerComandMethodAttributes.PermiteDelete: Boolean;
begin
  Result := (FModosPermitidos = []) or (cmDelete in FModosPermitidos);
end;

function TLmxServerComandMethodAttributes.PermiteGet: Boolean;
begin
  Result := (FModosPermitidos = []) or (cmGet in FModosPermitidos);
end;

function TLmxServerComandMethodAttributes.PermitePost: Boolean;
begin
  Result := (FModosPermitidos = []) or (cmPost in FModosPermitidos);
end;

function TLmxServerComandMethodAttributes.PermitePut: Boolean;
begin
  Result := (FModosPermitidos = []) or (cmPut in FModosPermitidos);
end;

{function TLmxServerComandMethodAttributes.PermitePut: Boolean;
begin

end;

 TLmxServerComandMethodAttributesList }

function TLmxServerComandMethodAttributesList.TentaObterMetodo(const ARota: string;
  const pTipo : TLmxAttributeComandoMetodo; out AMetodo: TLmxServerComandMethodAttributes): Boolean;
var
  lItem: TLmxServerComandMethodAttributes;
  lValor: string;
  lProvavelMetodo: TLmxServerComandMethodAttributes;
  lRestanteComando: string;
begin
  AMetodo := nil;
  lProvavelMetodo := nil;
  for lItem in Self do
  begin
    if (AMetodo = nil) then
    begin
      if (pTipo in lItem.ModosPermitidos) then
      begin
        if (lItem.ObterRotaMetodo = ARota)  then
          AMetodo := lItem;
        if (AMetodo = nil) and (lItem.ParametrosRota <> '')
          and (lItem.ParametroRotaValido(ARota, lValor, lRestanteComando))
          and (lItem.PosParametrosRota = lRestanteComando)
          then
            lProvavelMetodo := lItem;
      end;
    end;
  end;
  if (AMetodo = nil) then
    AMetodo := lProvavelMetodo;
  Result := (AMetodo <> nil);
end;

{ TLmxServerComandMethodParameters }

constructor TLmxServerComandMethodParameters.Create;
begin
  FPropriedades := TLmxServerComandMethodPropriedadesClasse.Create;
end;

destructor TLmxServerComandMethodParameters.Destroy;
begin
  FPropriedades.Free;
  inherited;
end;

{ TLmxServerComandMethodPropriedadeResultado }

constructor TLmxServerComandMethodPropriedadeResultado.Create(const ACodigo: Integer;
  ADescricao: string);
begin
  FCodigo := ACodigo;
  FDescricao := ADescricao;
end;


{ TLmxServerComandMethodParametersList }

function TLmxServerComandMethodParametersList.ObterParametroDeRota(
  const pNome: string): TLmxServerComandMethodParameters;
var
  lParametro: TLmxServerComandMethodParameters;
begin
  Result := nil;
  for lParametro in Self do
  begin
    if (Result = nil) and (lParametro.FromParams) and (lParametro.Nome = pNome) then
    begin
      Result := lParametro;
    end;
  end;
end;

{ TLmxSerializationDataSet }

function TLmxSerializationDataSet.DataSetToJson(
  const pDataSet: TDataSet): TJSONObject;
var
  lObjectColum : TJSONObject;
  lJsonFields : TJsonArray;
  lJsonValues : TJSONArray;
  lJsonValuesItem : TJSONArray;
  I: Integer;
  lField : TField;
begin
   Result := TJsonObject.Create;

   lJsonFields := TJSONArray.Create;

    for I := 0 to pDataSet.Fields.Count - 1 do
    begin
      lField := pDataSet.Fields[I];
      lObjectColum := TJSONObject.Create;
      lObjectColum.AddPair('name', lField.FieldName);
      lObjectColum.AddPair('friendlyName', lField.DisplayName);
      lObjectColum.AddPair('Size', IntToStr(lField.Size));

      case lField.Datatype of
        ftBoolean:  lObjectColum.AddPair('DataType', 'Boolean');
        ftInteger : lObjectColum.AddPair('DataType', 'Integer');
        ftFloat : lObjectColum.AddPair('DataType', 'Double');
        ftDate : lObjectColum.AddPair('DataType', 'Date');
        ftDatetime : lObjectColum.AddPair('DataType', 'Datetime');
        ftTime : lObjectColum.AddPair('DataType', 'Time');
        ftFMTBcd : lObjectColum.AddPair('DataType', 'FMTBcd');
        else
          lObjectColum.AddPair('DataType', 'string');
      end;

    lJsonFields.AddElement(lObjectColum);


    end;
  Result.AddPair('colums', lJsonFields);

  lJsonValues := TJSONArray.Create;

  pDataSet.First;
  while not pDataSet.Eof do
  begin
    lJsonValuesItem := TJSONArray.Create;

    for I := 0 to pDataSet.Fields.Count - 1 do
    begin
      lField := pDataSet.Fields[I];

      if lField.IsNull then
        lJsonValuesItem.Add('null')
      else begin
        case lField.Datatype of
          ftBoolean: lJsonValuesItem.Add(lField.AsBoolean);
          ftInteger,ftFloat,ftSmallint,ftWord,ftCurrency,ftFMTBcd : lJsonValuesItem.Add(lField.AsFloat);
          ftDate,ftDatetime,ftTime: lJsonValuesItem.Add(DateToISO8601(lField.AsDateTime));
          else
            lJsonValuesItem.Add(lField.AsString);
        end;
      end;
    end;

    lJsonValues.Add(lJsonValuesItem);

    pDataSet.Next;
  end;

  Result.AddPair('values', lJsonValues);

end;

function TLmxSerializationDataSet.DataSetToJsonItemObjectFormat(
  const pDataSet: TDataSet): TJSONObject;
var
  I: Integer;
  lField : TField;
  lArray: TArray<Byte>;
  lJSONArray: TJSONArray;
  lByte: Byte;
begin
  Result := TJSONObject.Create;
  for I := 0 to pDataSet.Fields.Count - 1 do
  begin
    lField := pDataSet.Fields[I];
    if not lField.IsNull then
    begin
      case lField.Datatype of
        ftUnknown, ftString, ftFixedChar,
        ftWideString, ftFixedWideChar,
        ftWideMemo, ftMemo, ftFmtMemo :
          Result.AddPair(LowerCase(lField.FieldName), TJSONString.Create(lField.AsString));
        ftSmallint, ftInteger, ftWord, ftAutoInc,
        ftLargeint, ftBytes, ftVarBytes, ftShortint:
          Result.AddPair(LowerCase(lField.FieldName), TJSONNumber.Create(lField.AsInteger));
        ftBoolean:
          Result.AddPair(LowerCase(lField.FieldName), TJSONBool.Create(lField.AsBoolean));
        ftFloat, ftCurrency, ftBCD, ftFMTBcd,
        ftLongWord, TFieldType.ftExtended, TFieldType.ftSingle:
          Result.AddPair(LowerCase(lField.FieldName), TJSONNumber.Create(lField.AsFloat));
        ftDate, ftTime, ftDateTime, ftTimeStamp:
          Result.AddPair(LowerCase(lField.FieldName), TJSONString.Create(DateToISO8601(lField.AsDateTime)));
        ftBlob: begin
          lArray := TBlobField(lField).AsBytes;
          lJSONArray := TJSONArray.Create;
          try
            for lByte in lArray do
              lJSONArray.Add(lByte);
            Result.AddPair(LowerCase(lField.FieldName), lJSONArray);
          except
            lJSONArray.Free;
          end;
        end
        else
          Result.AddPair(LowerCase(lField.FieldName), TJSONString.Create(lField.AsString));
      end;
    end;
  end;
end;

function TLmxSerializationDataSet.DataSetToJsonItemStringObjectFormat(
  const pDataSet: TDataSet): string;
var
  lRetorno : TJSONObject;
begin
  lRetorno := DataSetToJsonItemObjectFormat(pDataSet);
  try
    Result := lRetorno.ToString;
  finally
    lRetorno.Free;
  end;
end;

function TLmxSerializationDataSet.DataSetToJsonObjectFormat(
  const pDataSet: TDataSet; const pOnCarregarITem: TProc<TJSONObject>): TJSONArray;
var
  lObjectColum : TJSONObject;
begin
  Result := TJSONArray.Create;
  pDataSet.First;
  while not pDataSet.Eof do
  begin
    lObjectColum := DataSetToJsonItemObjectFormat(pDataSet);
    Result.AddElement(lObjectColum);
    if Assigned(pOnCarregarITem) then
      pOnCarregarITem(lObjectColum);
    pDataSet.Next;
  end;
end;

function TLmxSerializationDataSet.DataSetToJsonString(
  const pDataSet: TDataSet): string;
var
  lRetorno : TJSONObject;
begin
  lRetorno := DataSetToJson(pDataSet);
  try
    Result := lRetorno.ToString;
  finally
    lRetorno.Free;
  end;
end;

function TLmxSerializationDataSet.DataSetToJsonStringObjectFormat(
  const pDataSet: TDataSet; const pOnCarregarITem: TProc<TJsonObject>): string;
var
  lRetorno : TJSONArray;
begin
  lRetorno := DataSetToJsonObjectFormat(pDataSet, pOnCarregarITem);
  try
    Result := lRetorno.ToString;
  finally
    lRetorno.Free;
  end;
end;

initialization
  TLmxSerialization.FContexto := TRttiContext.Create;

finalization
  TLmxSerialization.FContexto.Free;

end.
