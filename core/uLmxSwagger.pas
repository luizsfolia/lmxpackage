unit uLmxSwagger;

interface

uses
  Classes, SysUtils, Generics.Collections, uLmxAttributes, System.JSON, uLmxHttp, uLmxHttpServer, uLmxSerialization,
  Rtti, System.TypInfo;

type

  TLmxComandoHttpSwagger = class(TLmxServerComand)
  protected
    function DoProcessarComando(const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean; override;
  end;

  TLmxSwagger = class

  end;

//  TLmxSwaggerItem = class(TLmxSwagger)
//  public
//    property stype : string read GetType;
//  end;

  TLmxSwaggerInfoContact = class(TObjectDictionary<string,string>);

  TLmxSwaggerInfo = class
  private
    FVersion: string;
    FLicense: string;
    FTitle: string;
    FDescription: string;
    FContact: TLmxSwaggerInfoContact;
    FTermsOfService: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Description : string read FDescription write FDescription;
    property Version : string read FVersion write FVersion;
    property Title : string read FTitle write FTitle;
    property TermsOfService : string read FTermsOfService write FTermsOfService;
    property Contact : TLmxSwaggerInfoContact read FContact write FContact;
    property License : string read FLicense write FLicense;
  end;


  TLmxSwaggerTag = class
  private
    FName: string;
    FExternalDocs: string;
    FDescription: string;
  public
    property Name : string read FName write FName;
    property Description : string read FDescription write FDescription;
    property ExternalDocs : string read FExternalDocs write FExternalDocs;
  end;

  TLmxSwaggerTags = class(TObjectList<TLmxSwaggerTag>);

  TLmxSwaggerProperty = class
  private
    FsType: string;
    FFormat: string;
    FExample: string;
    FReference: string;
    FName: string;
  public
    property sType : string read FsType write FsType;
    property Name : string read FName write FName;
    property Format : string read FFormat write FFormat;
    property Reference : string read FReference write FReference;
    property Example : string read FExample write FExample;
  end;

  TLmxSwaggerPropertyes = class(TObjectList<TLmxSwaggerProperty>);

  TLmxSwaggerParameter = class
  private
    FName: string;
    FCollectionFormat: string;
    FItems: string;
    FRequired: Boolean;
    FDescription: string;
    FTags: string;
    FschemaRef: string;
    FPropIn: string;
  public
    property Name : string read FName write FName;
    property TypeIn : string read FTags write FTags;
    property Description : string read FDescription write FDescription;
    property Required : Boolean read FRequired write FRequired;
    property Items : string read FItems write FItems;
    property CollectionFormat : string read FCollectionFormat write FCollectionFormat;
    property schemaRef : string read FschemaRef write FschemaRef;
    property PropIn : string read FPropIn write FPropIn;
  end;

  TLmxSwaggerParameters = class(TObjectList<TLmxSwaggerParameter>);


  TLmxSwaggerResponse = class
  private
    FDescription: string;
    FClasseRetorno: string;
    FIsEnum: Boolean;
  public
    property Description : string read FDescription write FDescription;
    property ClasseRetorno : string read FClasseRetorno write FClasseRetorno;
    property IsEnum : Boolean read FIsEnum write FIsEnum;
  end;

  TLmxSwaggerResponses = class(TObjectDictionary<Integer,TLmxSwaggerResponse>);

  TLmxSwaggerPath = class
  private
    FOperationId: string;
    FTags: TArray<string>;
    FProduces: TArray<string>;
//    FsType: string;
    FSummary: string;
    FParameters: TLmxSwaggerParameters;
    FDescription: string;
    FRota: string;
    FResponses: TLmxSwaggerResponses;
  public

    constructor Create;
    destructor Destroy; override;

    property Rota : string read FRota write FRota;
//    property sType : string read FsType write FsType;
    property Tags : TArray<string> read FTags write FTags;
    property Summary : string read FSummary write FSummary;
    property Description : string read FDescription write FDescription;
    property OperationId : string read FOperationId write FOperationId;
    property Produces : TArray<string> read FProduces write FProduces;
    property Parameters : TLmxSwaggerParameters read FParameters write FParameters;

    property Responses : TLmxSwaggerResponses read FResponses write FResponses;

    function GetType : string; virtual;

  end;

  TLmxSwaggerPathClass = class of TLmxSwaggerPath;

  TLmxSwaggerPathGet = class(TLmxSwaggerPath)
  public
    function GetType : string; override;
  end;

  TLmxSwaggerPathPost = class(TLmxSwaggerPath)
  public
    function GetType : string; override;
  end;

  TLmxSwaggerPathPut = class(TLmxSwaggerPath)
  public
    function GetType : string; override;
  end;

  TLmxSwaggerPathDelete = class(TLmxSwaggerPath)
  public
    function GetType : string; override;
  end;

  TLmxSwaggerPaths = class(TObjectList<TLmxSwaggerPath>);

  TLmxSwaggerDefinition = class
  private
    FName: string;
    FPropertyes: TLmxSwaggerPropertyes;
    FsType: string;
  public
    constructor Create;
    destructor Destroy; override;

    property sType : string read FsType write FsType;
    property Name : string read FName write FName;

    property Propertyes : TLmxSwaggerPropertyes read FPropertyes;

  end;

  TLmxSwaggerDefinitions = class(TObjectDictionary<string,TLmxSwaggerDefinition>);


  TLmxSwaggerObject = class
  private
//    FPropertyes: TLmxSwaggerPropertyes;
    FPaths: TLmxSwaggerPaths;
    FVersao: string;
    FInfo: TLmxSwaggerInfo;
    FTags: TLmxSwaggerTags;
    FBasePath: string;
    Fhost: string;
    Fschemes: TArray<string>;
    FDefinitions: TLmxSwaggerDefinitions;
  public
    constructor Create;
    destructor Destroy; override;

    property Versao : string read FVersao write FVersao;
    property Host : string read Fhost write Fhost;
    property BasePath : string read FBasePath write FBasePath;
    property Schemes : TArray<string> read Fschemes write FSchemes;

    property Tags : TLmxSwaggerTags read FTags;
    property Info : TLmxSwaggerInfo read FInfo;
//    property Propertyes : TLmxSwaggerPropertyes read FPropertyes;
    property Paths : TLmxSwaggerPaths read FPaths;
    property Definitions : TLmxSwaggerDefinitions read FDefinitions;
  end;

  TLmxSwggerGenerator = class
  private
    function GetTypeKindAsString(const ATypeKind : TTypeKind) : string;

    function GetJsonObjectInfoContact(const AInfoCOntact : TLmxSwaggerInfoContact) : TJSONObject;
    function GetJsonObjectInfo(const AInfo : TLmxSwaggerInfo) : TJSONObject;
    function GetJsonObjectTags(const ATags : TLmxSwaggerTags) : TJSONArray;
    function GetJsonObjectParameterPath(const AParameters : TLmxSwaggerParameters) : TJsonArray;
    function GetJsonObjectPaths(const APaths : TLmxSwaggerPaths) : TJSONObject;
    function GetJsonObjectSchemes(const ASchemas : TArray<string>) : TJSONArray;
    function GetJsonObjectDefinition(const ADefinition : TLmxSwaggerDefinition) : TJSONObject;
    function GetJsonObjectDefinitions(const ADefinitions : TLmxSwaggerDefinitions) : TJSONObject;

    procedure GetDefinitions(const AMetodo : TLmxServerComandMethodAttributes; const ASwaggerObjectDefinitions : TLmxSwaggerDefinitions);
    procedure GetPathParameters(const AMetodo : TLmxServerComandMethodAttributes; const ASwaggerObjectDefinitions : TLmxSwaggerParameters);
    procedure DoAddPath(var ASwaggerObject: TLmxSwaggerObject; lTag: TLmxSwaggerTag; lMetodo: TLmxServerComandMethodAttributes; const APath: TLmxSwaggerPath);

  public
    function GerarJsonDeSwaggerObject(const ASwaggerObject : TLmxSwaggerObject) : string;
    function GerarSwaggerObject(const AServer : TLmxHttpServer; out ASwaggerObject : TLmxSwaggerObject) : string;
    function GerarJsonDeSwaggerObjectSerializable(const ASwaggerObject : TLmxSwaggerObject) : string;
  end;



implementation

{ TLmxSwaggerObject }

constructor TLmxSwaggerObject.Create;
begin
  FVersao := '2.0';
  FTags := TLmxSwaggerTags.Create;
  FInfo := TLmxSwaggerInfo.Create;
//  FPropertyes := TLmxSwaggerPropertyes.Create;
  FPaths := TLmxSwaggerPaths.Create;
  FDefinitions := TLmxSwaggerDefinitions.Create([doOwnsValues]);
end;

destructor TLmxSwaggerObject.Destroy;
begin
  FDefinitions.FRee;
  FTags.Free;
  FInfo.Free;
  FPaths.Free;
//  FPropertyes.Free;
  inherited;
end;

{ TLmxSwaggerPath }

constructor TLmxSwaggerPath.Create;
begin
  FParameters := TLmxSwaggerParameters.Create;
  FResponses := TLmxSwaggerResponses.Create([doOwnsValues]);
end;

destructor TLmxSwaggerPath.Destroy;
begin
  FResponses.Free;
  FParameters.Free;
  inherited;
end;

function TLmxSwaggerPath.GetType: string;
begin
  Result := 'get';
end;

{ TLmxSwggerGenerator }

function TLmxSwggerGenerator.GerarJsonDeSwaggerObject(const ASwaggerObject : TLmxSwaggerObject): string;
var
//  lObjeto: TLmxSwaggerProperty;
  lJsonObject: TJSONObject;
begin
  lJsonObject := TJsonObject.Create;
  try
    lJsonObject.AddPair('swagger', TJSONString.Create(ASwaggerObject.Versao));
    lJsonObject.AddPair('info', GetJsonObjectInfo(ASwaggerObject.Info));
    if ASwaggerObject.Host <> '' then
      lJsonObject.AddPair('host', ASwaggerObject.Host);
    if ASwaggerObject.BasePath <> '' then
      lJsonObject.AddPair('basePath', ASwaggerObject.BasePath);
    lJsonObject.AddPair('tags', GetJsonObjectTags(ASwaggerObject.Tags));
    lJsonObject.AddPair('schemes', GetJsonObjectSchemes(ASwaggerObject.Schemes));
    lJsonObject.AddPair('paths', GetJsonObjectPaths(ASwaggerObject.Paths));
    lJsonObject.AddPair('definitions', GetJsonObjectDefinitions(ASwaggerObject.Definitions));

    Result := lJsonObject.ToString;

  finally
    lJsonObject.Free;
  end;
end;

function TLmxSwggerGenerator.GerarJsonDeSwaggerObjectSerializable(
  const ASwaggerObject: TLmxSwaggerObject): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(ASwaggerObject, False);
  try
    Result := lSerialization.ToJson;
  finally
    lSerialization.Free;
  end;
end;

procedure TLmxSwggerGenerator.DoAddPath(var ASwaggerObject: TLmxSwaggerObject; lTag: TLmxSwaggerTag; lMetodo: TLmxServerComandMethodAttributes; const APath: TLmxSwaggerPath);
var
  lResultado: TLmxServerComandMethodPropriedadeResultado;
  lResponse : TLmxSwaggerResponse;
begin
  APath.Tags := [lTag.Name];
  APath.Summary := lMetodo.Sumario;
  APath.Description := lMetodo.Descricao;
  APath.Produces := ['application/json'];

  for lResultado in lMetodo.Resultados do
  begin
    lResponse := TLmxSwaggerResponse.Create;
    lResponse.Description := lResultado.Descricao;
    lResponse.ClasseRetorno := lMetodo.Retorno.NomeClasse;
    if lMetodo.Retorno.TypeKind = tkEnumeration then
      lResponse.IsEnum := True;
    APath.Responses.Add(lResultado.Codigo, lResponse);
  end;

  if not APath.Responses.TryGetValue(200, lResponse) then
  begin
    lResponse := TLmxSwaggerResponse.Create;
    lResponse.Description := 'Retorno OK';
    lResponse.ClasseRetorno := lMetodo.Retorno.NomeClasse;
    if lMetodo.Retorno.TypeKind = tkEnumeration then
      lResponse.IsEnum := True;

    APath.Responses.Add(200, lResponse);
  end;

  ASwaggerObject.Paths.Add(APath);
  GetPathParameters(lMetodo, APath.Parameters);
  GetDefinitions(lMetodo, ASwaggerObject.Definitions);
end;

function TLmxSwggerGenerator.GerarSwaggerObject(const AServer: TLmxHttpServer;
  out ASwaggerObject: TLmxSwaggerObject): string;
var
  lComandos: TObjectDictionary<string, TLmxServerComandClass>;
  lAtributosComando: TLmxServerComandAttributes;
  lEnumComandos: TObjectDictionary<string, TLmxServerComandClass>.TPairEnumerator;
  lPath: TLmxSwaggerPath;
  lMetodo: TLmxServerComandMethodAttributes;
  lTag: TLmxSwaggerTag;
  lNameTag: string;
begin
  ASwaggerObject := TLmxSwaggerObject.Create;

  ASwaggerObject.Info.Version := '2.0';
  ASwaggerObject.Info.License := 'Total';
  ASwaggerObject.Info.Title := 'Sistema X';
  ASwaggerObject.Info.Description := 'Sistema X';
  ASwaggerObject.Info.Contact.Add('email', 'luiz@1234.com.br');
  ASwaggerObject.Info.TermsOfService := 'Teste';

  ASwaggerObject.schemes := ['http'];

  AServer.ObterListaComandos(lComandos);
  try
    lEnumComandos := lComandos.GetEnumerator;
    try
      while lEnumComandos.MoveNext do
      begin
        lAtributosComando := TLmxSerialization.GetServerCommandAttributes(lEnumComandos.Current.Value);
        try
          lTag := TLmxSwaggerTag.Create;

          lNameTag := lEnumComandos.Current.Key;
          if lNameTag[1] = '/' then
            Delete(lNameTag, 1, 1);

          lTag.Name := lNameTag;
          lTag.Description := lAtributosComando.Descricao;

  //        lTag.ExternalDocs := '';
  //        lTag.Description := 'teste';

          ASwaggerObject.Tags.Add(lTag);

          for lMetodo in lAtributosComando.Metodos do
          begin
            lPath := nil;
            if lMetodo.PermiteGet then
              lPath := TLmxSwaggerPathGet.Create
            else if lMetodo.PermitePost then
              lPath := TLmxSwaggerPathPost.Create
            else if lMetodo.PermitePut then
              lPath := TLmxSwaggerPathPut.Create
            else if lMetodo.PermiteDelete then
              lPath := TLmxSwaggerPathDelete.Create;

            if lPath <> nil then
            begin
              lPath.Rota := lEnumComandos.Current.Key + lMetodo.ObterRotaMetodo;
              lPath.Summary := lMetodo.Sumario;
              lPath.Description := lMetodo.Descricao;
              DoAddPath(ASwaggerObject, lTag, lMetodo, lPath);
            end;

{          if lMetodo.PermitePost then
          begin
            lPath := TLmxSwaggerPathPost.Create;
            if lPath <> nil then
            begin
              lPath.Rota := lEnumComandos.Current.Key + lMetodo.ObterRotaMetodo;
              lPath.Summary := lMetodo.Sumario;
              lPath.Description := lMetodo.Descricao;
              DoAddPath(ASwaggerObject, lTag, lMetodo, lPath);
            end;
          end;

          if lMetodo.PermitePut then
          begin
            lPath := TLmxSwaggerPathPut.Create;
            if lPath <> nil then
            begin
              lPath.Rota := lEnumComandos.Current.Key + lMetodo.ObterRotaMetodo;
              lPath.Summary := lMetodo.Sumario;
              lPath.Description := lMetodo.Descricao;
              DoAddPath(ASwaggerObject, lTag, lMetodo, lPath);
            end;
          end;

          if lMetodo.PermiteDelete then
          begin
            lPath := TLmxSwaggerPathDelete.Create;
            if lPath <> nil then
            begin
              lPath.Rota := lEnumComandos.Current.Key + lMetodo.ObterRotaMetodo;
              lPath.Summary := lMetodo.Sumario;
              lPath.Description := lMetodo.Descricao;
              DoAddPath(ASwaggerObject, lTag, lMetodo, lPath);
            end;
          end;    }

          end;
        finally
          lAtributosComando.Free;
        end;
      end;

    finally
      lEnumComandos.Free;
    end;

  finally
    lComandos.Free;
  end;


end;

procedure TLmxSwggerGenerator.GetDefinitions(
  const AMetodo : TLmxServerComandMethodAttributes; const ASwaggerObjectDefinitions: TLmxSwaggerDefinitions);
var
  lParametro: TLmxServerComandMethodParameters;

  procedure InternalAdicionarDefinicao(const ANomeClasse : string; const APropriedades : TLmxServerComandMethodPropriedadesClasse);
  var
    lPropriedade: TLmxServerComandMethodPropriedadeClasse;
    lDefinition: TLmxSwaggerDefinition;
    lSwaggerPropriedade: TLmxSwaggerProperty;
  begin
    if not ASwaggerObjectDefinitions.TryGetValue(ANomeClasse, lDefinition) then
    begin
      lDefinition := TLmxSwaggerDefinition.Create;
      lDefinition.Name := ANomeClasse;
      lDefinition.sType := 'object';

      ASwaggerObjectDefinitions.Add(ANomeClasse, lDefinition);

      for lPropriedade in APropriedades do
      begin
        lSwaggerPropriedade := TLmxSwaggerProperty.Create;

        lSwaggerPropriedade.Name := lPropriedade.Nome;

        case lPropriedade.TypeKind of
          tkUnknown: ;
          tkInteger: lSwaggerPropriedade.sType := 'integer';
          tkChar: lSwaggerPropriedade.sType := 'string';
          tkEnumeration: ;
          tkFloat: ;
          tkString: lSwaggerPropriedade.sType := 'string';
          tkSet: ;
          tkClass: ;
          tkMethod: ;
          tkWChar: ;
          tkLString: lSwaggerPropriedade.sType := 'string';
          tkWString: lSwaggerPropriedade.sType := 'string';
          tkVariant: ;
          tkArray: ;
          tkRecord: ;
          tkInterface: ;
          tkInt64: ;
          tkDynArray: ;
          tkUString: lSwaggerPropriedade.sType := 'string';
          tkClassRef: ;
          tkPointer: ;
          tkProcedure: ;
        end;

        if lSwaggerPropriedade.sType = '' then
          lSwaggerPropriedade.sType := 'string';

        lDefinition.Propertyes.Add(lSwaggerPropriedade);

      end;
    end;
  end;

begin


  if AMetodo.Retorno.TypeKind = tkClass then
  begin
    InternalAdicionarDefinicao(AMetodo.Retorno.NomeClasse, AMetodo.Retorno.Propriedades);
  end;


  for lParametro in AMetodo.Parametros do
  begin
    if lParametro.TypeKind = tkClass then
    begin
      if lParametro.FromQuery or lParametro.FromBody or lParametro.FromHeader then
        InternalAdicionarDefinicao(lParametro.NomeClasse, lParametro.Propriedades);
    end;
  end;



//  ASwaggerObjectDefinitions.Add( lDefinition);

//  AMetodo.
//
//  if AMetodo.Evento.ReturnType.TypeKind = tkClass then
//  begin
//    if not ASwaggerObjectDefinitions.TryGetValue(AMetodo.Evento.ReturnType.QualifiedName, lDefinition) then
//    begin
//      lDefinition := TLmxSwaggerDefinition.Create;
//
//      lDefinition.Name := AMetodo.Evento.Name;
//      lDefinition.sType := AMetodo.Evento.ReturnType.QualifiedName;
//
//
//      lClass := GetTypeData(lParametro.ParamType.Handle)^.ClassType;
//      lSerialization := TLmxSerialization.Create();
//
//      if TLmxSerialization.ObterMetodoCreate(lClass, lEventoCreate) then
//        lInstancia := lEventoCreate.Invoke(lClass, []).AsObject
//      else
//        lInstancia := lClass.Create;
//
//      for lField in AMetodo. do
//      begin
//
//      end;
//      AMetodo.Evento.ReturnType.GetFields
//
//      lDefinition.Propertyes.AD
//
//      ASwaggerObjectDefinitions.Add(AMetodo.Evento.ReturnType.QualifiedName, lDefinition);
//
//    end;
//  end;
//
//  for lParametro in AMetodo.Evento.GetParameters do
//  begin
//    lProperty := TLmxSwaggerProperty.CReate;
//
//    lProperty.Name := lParametro.Name;
//    lProperty.sType := lParametro.ParamType.QualifiedName;
//  end;


end;

function TLmxSwggerGenerator.GetJsonObjectDefinition(
  const ADefinition: TLmxSwaggerDefinition): TJSONObject;
var
  lPropriedades: TJSONObject;
  lPropriedade : TLmxSwaggerProperty;
begin
  Result := TJSONObject.Create;
  for lPropriedade in ADefinition.Propertyes do
  begin
    lPropriedades := TJSONObject.Create;
    lPropriedades.AddPair('type', lPropriedade.sType);
    if lPropriedade.Format <> '' then
      lPropriedades.AddPair('format', lPropriedade.Format);

    Result.AddPair(lPropriedade.Name, lPropriedades);
  end;
end;

function TLmxSwggerGenerator.GetJsonObjectDefinitions(
  const ADefinitions: TLmxSwaggerDefinitions): TJSONObject;
var
  lObjeto: TJSONObject;
  lLista: TJSONObject;
  lEnumDefinition: TLmxSwaggerDefinitions.TPairEnumerator;
begin
  lLista := TJSONObject.Create;

  lEnumDefinition := ADefinitions.GetEnumerator;
  try
    while lEnumDefinition.MoveNext do
    begin
      lObjeto := TJSONObject.Create;
      lObjeto.AddPair('type', lEnumDefinition.Current.Value.sType);
      lObjeto.AddPair('properties', GetJsonObjectDefinition(lEnumDefinition.Current.Value));
      lLista.AddPair(lEnumDefinition.Current.Value.Name, lObjeto);
    end;
  finally
    lEnumDefinition.Free;
  end;

  Result := lLista;
end;

function TLmxSwggerGenerator.GetJsonObjectInfo(const AInfo : TLmxSwaggerInfo): TJSONObject;
var
  lObjetoInfoContact: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('description', AInfo.Description);
  Result.AddPair('version', TJsonString.Create(AInfo.version));
  Result.AddPair('title', TJsonString.Create(AInfo.title));
  if AInfo.termsOfService <> '' then
    Result.AddPair('termsOfService', TJsonString.Create(AInfo.termsOfService));

  lObjetoInfoContact := GetJsonObjectInfoContact(AInfo.Contact);
  if lObjetoInfoContact.Count > 0 then
    Result.AddPair('contact', lObjetoInfoContact)
  else
    lObjetoInfoContact.Free;

//  Result.AddPair('license', TJsonString.Create(AInfo.license));

end;

function TLmxSwggerGenerator.GetJsonObjectInfoContact(
  const AInfoCOntact: TLmxSwaggerInfoContact): TJSONObject;
var
  lEnumContact: TLmxSwaggerInfoContact.TPairEnumerator;
begin
  lEnumContact := AInfoCOntact.GetEnumerator;
  try
    Result := TJSONObject.Create;
    while lEnumContact.MoveNext do
    begin
      Result.AddPair(lEnumContact.Current.Key, lEnumContact.Current.Value);
    end;
  finally
    lEnumContact.Free;
  end;
end;

function TLmxSwggerGenerator.GetJsonObjectParameterPath(
  const AParameters: TLmxSwaggerParameters): TJsonArray;
var
  lJosnObjectItem: TJSONObject;
  lPArameter: TLmxSwaggerParameter;
  lObjectSchema: TJSONObject;
begin
  Result := TJSONArray.Create;
  for lPArameter in AParameters do
  begin
    lJosnObjectItem := TJSONObject.Create;
    lJosnObjectItem.AddPair('name', lParameter.Name);
//    lJosnObjectItem.AddPair('required', 'True');

    if lPArameter.schemaRef <> '' then
    begin
      lJosnObjectItem.AddPair('in', lPArameter.PropIn); // 'body');
      lObjectSchema := TJSONObject.Create;
      lObjectSchema.AddPair('$ref', lPArameter.schemaRef);
      lJosnObjectItem.AddPair('schema', lObjectSchema )
    end else begin
      lJosnObjectItem.AddPair('type', lParameter.TypeIn);
      lJosnObjectItem.AddPair('in', lPArameter.PropIn); //'query');
    end;


    Result.AddElement(lJosnObjectItem);
  end;
end;

function TLmxSwggerGenerator.GetJsonObjectPaths(const APaths: TLmxSwaggerPaths): TJSONObject;
var
  lTag: TLmxSwaggerPath;
  lLista: TJSONObject;
//  lItemPath: TJSONObject;
  lRota: TJSONObject;
  lItemGetPost: TJSONObject;
  lEnumResponses: TLmxSwaggerResponses.TPairEnumerator;
  lObjetoResponse: TJSONObject;
  lObjetoResponseMaster: TJSONObject;
  lItem: string;
  lJArray: TJSONArray;
  lParametros: TJSONArray;
  lObjetoSchema: TJSONObject;
  lObjetoItem: TJSONObject;
  lValorAtual : TJSONObject;
begin
  lLista := TJSONObject.Create;

  for lTag in APaths do
  begin
    lRota := TJSONObject.Create;

    lItemGetPost := TJSONObject.Create;

    lJArray := TJSONArray.Create;
    for lItem in lTag.Tags do
      lJArray.Add(lItem);
    lItemGetPost.AddPair('tags', lJArray);
    if lTag.Summary <> '' then
      lItemGetPost.AddPair('summary', lTag.Summary);
    if lTag.Description <> '' then
      lItemGetPost.AddPair('description', lTag.Description);
    if lTag.OperationId <> '' then
      lItemGetPost.AddPair('operationId', lTag.OperationId);

    lJArray := TJSONArray.Create;
    for lItem in lTag.Produces do
      lJArray.Add(lItem);
    lItemGetPost.AddPair('produces', lJArray);

    lEnumResponses := ltag.Responses.GetEnumerator;
    try
      lObjetoResponseMaster := TJSONObject.Create;

      while lEnumResponses.MoveNext do
      begin

        lObjetoResponse := TJSONObject.Create;
        lObjetoResponse.AddPair('description', lEnumResponses.Current.Value.Description);

        if lEnumResponses.Current.Value.ClasseRetorno <> '' then
        begin
          lObjetoSchema := TJSONObject.Create;
          if lEnumResponses.Current.Value.IsEnum then
          begin
            lObjetoSchema.AddPair('type', 'array');

            lObjetoItem := TJsonObject.Create;
            lObjetoItem.AddPair('$ref', '#/definitions/' + lEnumResponses.Current.Value.ClasseRetorno);

            lObjetoSchema.AddPair('item', lObjetoItem);
          end else begin
            lObjetoSchema.AddPair('$ref', '#/definitions/' + lEnumResponses.Current.Value.ClasseRetorno);
          end;

          lObjetoResponse.AddPair('schema', lObjetoSchema);

        end;

        lObjetoResponseMaster.AddPair(IntToStr(lEnumResponses.Current.Key), lObjetoResponse);
      end;

      if lObjetoResponseMaster.Count > 0 then
        lItemGetPost.AddPair('responses', lObjetoResponseMaster)
      else
        lObjetoResponseMaster.Free;
    finally
      lEnumResponses.Free;
    end;

    lParametros := GetJsonObjectParameterPath(lTag.Parameters);
    if lParametros.Count > 0 then
      lItemGetPost.AddPair('parameters', lParametros)
    else
      lParametros.Free;




    lValorAtual := TJSONObject(lLista.Values[lTag.Rota]);
    if lValorAtual <> nil then
      lValorAtual.AddPair(lTag.GetType, lItemGetPost)
    else begin
      lRota.AddPair(lTag.GetType, lItemGetPost);
      lLista.AddPair(lTag.Rota, lRota);
    end;

//    lRota.AddPair(lTag.Rota, lItemGetPost);
//    lLista.AddPair(lTag.Rota, lRota);

  end;

  Result := lLista;
end;

function TLmxSwggerGenerator.GetJsonObjectSchemes(const ASchemas: TArray<string>): TJSONArray;
var
  lSchema: string;
  lLista: TJSONArray;
begin
  lLista := TJSONArray.Create;

  for lSchema in ASchemas do
  begin
    lLista.Add(lSchema);
  end;

  Result := lLista
end;

function TLmxSwggerGenerator.GetJsonObjectTags(const ATags: TLmxSwaggerTags): TJSONArray;
var
  lTag: TLmxSwaggerTag;
  lItem: TJSONObject;
  lLista: TJSONArray;
begin


  lLista := TJSONArray.Create;

  for lTag in ATags do
  begin
    lItem := TJSONObject.Create;

    lItem.AddPair('name', lTag.Name);
//    lItem.AddPair('externalDocs', lTag.ExternalDocs);
    if lTag.Description <> '' then
      lItem.AddPair('description', lTag.Description);
//    lItem.AddPair('name', lTag.Name);
//    lItem.AddPair('name', lTag.Name);

    lLista.AddElement(lItem);

  end;

  Result := lLista
end;

procedure TLmxSwggerGenerator.GetPathParameters(const AMetodo: TLmxServerComandMethodAttributes;
  const ASwaggerObjectDefinitions: TLmxSwaggerParameters);
var
  lParametro: TLmxServerComandMethodParameters;
  lSwaggerParametro : TLmxSwaggerParameter;
begin
  for lParametro in AMetodo.Parametros do
  begin
    if lParametro.FromQuery or lParametro.FromBody then
    begin
      lSwaggerParametro := TLmxSwaggerParameter.Create;
      lSwaggerParametro.Name := lParametro.Nome;

      if lParametro.FromQuery then
        lSwaggerParametro.PropIn := 'query'
      else if lParametro.FromBody then
        lSwaggerParametro.PropIn := 'body';

      if lParametro.NomeClasse <> '' then
        lSwaggerParametro.schemaRef := '#/definitions/' + lParametro.NomeClasse
      else begin
        lSwaggerParametro.TypeIn := GetTypeKindAsString(lParametro.TypeKind);
      end;


      ASwaggerObjectDefinitions.Add(lSwaggerParametro);
    end;
  end;

end;

function TLmxSwggerGenerator.GetTypeKindAsString(const ATypeKind : TTypeKind): string;
begin
  Result := EmptyStr;
  case ATypeKind of
    tkUnknown: ;
    tkInteger: Result := 'integer';
    tkChar: Result := 'string';
    tkEnumeration: ;
    tkFloat: ;
    tkString: Result := 'string';
    tkSet: ;
    tkClass: ;
    tkMethod: ;
    tkWChar: ;
    tkLString: Result := 'string';
    tkWString: Result := 'string';
    tkVariant: ;
    tkArray: ;
    tkRecord: ;
    tkInterface: ;
    tkInt64: ;
    tkDynArray: ;
    tkUString: Result := 'string';
    tkClassRef: ;
    tkPointer: ;
    tkProcedure: ;
  end;
end;

{ TLmxSwaggerInfo }

constructor TLmxSwaggerInfo.Create;
begin
  FContact := TLmxSwaggerInfoContact.Create;
end;

destructor TLmxSwaggerInfo.Destroy;
begin
  FContact.Free;
  inherited;
end;

{ TLmxSwaggerDefinition }

constructor TLmxSwaggerDefinition.Create;
begin
  FPropertyes := TLmxSwaggerPropertyes.Create;
end;

destructor TLmxSwaggerDefinition.Destroy;
begin
  FPropertyes.Free;
  inherited;
end;

{ TLmxSwaggerPathGet }

function TLmxSwaggerPathGet.GetType: string;
begin
   REsult := 'get';
end;

{ TLmxSwaggerPathPost }

function TLmxSwaggerPathPost.GetType: string;
begin
  Result := 'post';
end;

{ TLmxSwaggerPathPut }

function TLmxSwaggerPathPut.GetType: string;
begin
  Result := 'put';
end;

{ TLmxSwaggerPathDelete }

function TLmxSwaggerPathDelete.GetType: string;
begin
  Result := 'delete';
end;

{ TLmxComandoHttpSwagger }

function TLmxComandoHttpSwagger.DoProcessarComando(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
var
  lSwagger: TLmxSwggerGenerator;
  lSwaggerObject: TLmxSwaggerObject;
  lJson: string;
begin
  lSwagger := TLmxSwggerGenerator.Create;
  try
    lSwagger.GerarSwaggerObject(AInfoComando.InfoComando.Server, lSwaggerObject);
    lJson := lSwagger.GerarJsonDeSwaggerObject(lSwaggerObject);

    AInfoComando.ResposneInfo.ResponseNo := 200;
    AInfoComando.ResposneInfo.ResponseText := lJson;
    AInfoComando.ResposneInfo.ContentType := 'application/json';
    AInfoComando.ResposneInfo.ContentText := lJson;

  finally
    lSwagger.Free;
  end;
end;

end.
