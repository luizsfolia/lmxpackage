unit uLmxModeloBase;


interface
uses
  System.SysUtils, System.Classes, System.JSON, System.DateUtils, Generics.Collections, uLmxAttributes,
  DB, REST.Response.Adapter, uLmxSerialization;

type
  TLmxModeloBase = class
  private
    FIsEmpty: boolean;
  protected
    function CarregarValorDeJson<T>(const AJsonObject: TJSONObject; const pNomeCampo : string) : T; overload;
    procedure CarregarValorDeJson<T>(const AJsonObject: TJSONObject; const pNomeCampo : string; var ACampo : T); overload;
    procedure CarregarValorDeJson(const AJsonObject: TJSONObject; const pNomeCampo : string; ACampo : TLmxModeloBase); overload;
    procedure CarregarValorDeJson(const AJsonObject: TJSONObject; const pNomeCampo : string; var ACampo : TDateTime); overload;
    procedure CarregarValorDeJson(const AJsonObject: TJSONObject; const pNomeCampo : string; var ACampo : TDate); overload;
    procedure CarregarValorDeJson<T : class>(const AJsonObject: TJSONObject; const pNomeCampo : string; ACampo : TObjectList<T>); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : Boolean); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : Integer); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : String); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : TDateTime); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : TDate); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : Currency); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : Double); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : TJsonValue); overload;
    procedure GerarValorParaJson(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : TLmxModeloBase); overload;
    procedure GerarValorParaJson<T : class>(const AJsonObject: TJSONObject; const pNomeCampo : string; const AValorCampo : TObjectList<T>); overload;

    //procedure InternalToJsonObject(const AJsonObject : TJSONObject); virtual;
    //procedure InternalFromJsonObject(const AJsonObject : TJSONObject); virtual;

    procedure InternalInicializar; virtual;
    procedure InternalFinalizar; virtual;

    {procedure InternalFromDataSet(const pDataSet : TDataSet); virtual;
    procedure InternalToDataSet(const pDataSet : TDataSet); virtual;}

  public
    constructor Create;
    destructor Destroy; override;

    function ToJsonObject : TJSONObject; virtual;
    procedure FromJsonObject(const AJsonObject : TJSONObject); virtual;

    function ToJsonString : string;
    procedure FromJsonString(const AJsonString : string);

    procedure FromDataSet(const pDataSet : TDataSet);
    //procedure ToDataSet(const pDataSet : TDataSet);
    [TLmxAttributeNoSerializable]
    property IsEmpty: boolean read FIsEmpty write FIsEmpty;

    function GetValorByFieldName(const pFieldName : string) : string;
  end;

  TLmxModeloBaseList<T : TLmxModeloBase, constructor> = class(TInterfacedPersistent, ILmxEnumerable)
  private
    FList : TObjectList<T>;
    function GetItem(index: Integer): T;
  protected
    function GetItemObject(const AIndex: Integer): TObject;
    function GetNewItemObject: TObject;
    function GetDescription : string;
  public
    constructor Create;
    destructor Destroy; override;

    function GetEnumerator: TEnumerator<T>;
    function First : T;
    function Remove(const Value : T) : Integer;
    procedure Clear;

    function ToJsonObject : TJSONArray;
    procedure FromJsonObject(const AJsonObject : TJSONArray);

    function ToJsonString : string;
    procedure FromJsonString(const AJsonString : string; const AOnNovoITem: TOnNewItemObjectEnumJson = nil);

    procedure FromDataSet(const pDataSet : TDataSet); overload;
    procedure ToDataSet(const pDataSet : TDataSet);

    procedure FromDataSet(const pDataSet : TDataSet; const pOnCarregarITem : TProc<T, string>); overload;

    function Add(const Value : T) : Integer; overload;
    function Add : T; overload;
    function Count: Integer;

    property ItemObject[index: Integer]:T read GetItem; default;
  end;

implementation

{ TLmxModeloBase }

procedure TLmxModeloBase.CarregarValorDeJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; var ACampo: TDateTime);
var
  lJsonValue : TJsonValue;
begin
  lJsonValue := AJsonObject.Values[pNomeCampo];
  if lJsonValue <> nil then
    ACampo := ISO8601ToDate(lJsonValue.GetValue<String>);
end;

function TLmxModeloBase.CarregarValorDeJson<T>(const AJsonObject: TJSONObject;
  const pNomeCampo: string): T;
var
  lJsonValue : TJsonValue;
begin
  lJsonValue := AJsonObject.Values[pNomeCampo];
  if lJsonValue <> nil then
    Result := lJsonValue.GetValue<T>;
end;

procedure TLmxModeloBase.CarregarValorDeJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; var ACampo: TDate);
var
  lJsonValue : TJsonValue;
begin
  lJsonValue := AJsonObject.Values[pNomeCampo];
  if lJsonValue <> nil then
    ACampo := ISO8601ToDate(lJsonValue.GetValue<String>);
end;

procedure TLmxModeloBase.CarregarValorDeJson<T>(const AJsonObject: TJSONObject;
  const pNomeCampo: string; ACampo: TObjectList<T>);
var
  lJsonValue : TJsonValue;
begin
//  lJsonValue := AJsonObject.Values[pNomeCampo];
//  if (lJsonValue <> nil) and (lJsonValue is TJSONArray) and (ACampo.InheritsFrom(TLmxModeloBaseList<T>)) then
//    TLmxModeloBaseList<T>(ACampo).FromJsonObject(TJSONArray(lJsonValue));
end;

constructor TLmxModeloBase.Create;
begin
  FIsEmpty := True;
  InternalInicializar;
end;

destructor TLmxModeloBase.Destroy;
begin
  InternalFinalizar;
  inherited;
end;

procedure TLmxModeloBase.FromDataSet(const pDataSet: TDataSet);
begin
  FIsEmpty := pDataSet.IsEmpty;
  FromJsonString(TLmxSerialization.ExternalDataSetToJsonString(pDataSet));
end;

procedure TLmxModeloBase.FromJsonObject(const AJsonObject: TJSONObject);
begin
  TLmxSerialization.FromJsonString(Self,AJsonObject.ToString);
end;

procedure TLmxModeloBase.FromJsonString(const AJsonString: string);
var
  lJsonStream : TStringStream;
  lObjetoJson : TJSONObject;
  JSONArray: TJSONArray;
begin
//  lJsonStream := TStringStream.Create(AJsonString.Replace('\/', '/', [rfReplaceAll]));
//  lJsonStream := TStringStream.Create(AJsonString.Replace('\', '\\', [rfReplaceAll]));

  FIsEmpty := (AJsonString = '') or (AJsonString = '{}');
  if AJsonString.Substring(0, 1) = '[' then
  begin
    JSONArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(AJsonString), 0) as TJSONArray;
    try
      if JSONArray = nil then
        raise Exception.Create('O Json passado para ser carregado na classe ' + Self.ClassName + ' parece não ser válido.');
      lJsonStream := TStringStream.Create(JSONArray.Items[0].ToString,TEncoding.UTF8);
    finally
      JSONArray.Free;
    end;
  end else begin
    lJsonStream := TStringStream.Create(AJsonString,TEncoding.UTF8);
  end;

  lObjetoJson := TJSONObject.Create;
  try
    lJsonStream.Position := 0;
    lObjetoJson.Parse(lJsonStream.Bytes, 0);
    FromJsonObject(lObjetoJson);
  finally
    lJsonStream.Free;
    lObjetoJson.Free;
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: TDateTime);
begin
  if AValorCampo <> 0 then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONString.Create(DateToISO8601(AValorCampo)));
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo, AValorCampo: String);
begin
  if AValorCampo <> '' then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONString.Create(AValorCampo.Replace('\', '\\')));
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: Integer);
begin
  if AValorCampo <> 0 then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONNumber.Create(AValorCampo));
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: TJsonValue);
begin
  AJsonObject.RemovePair(pNomeCampo);
  AJsonObject.AddPair(pNomeCampo, AValorCampo);
end;

procedure TLmxModeloBase.InternalFinalizar;
begin

end;

{
procedure TLmxModeloBase.InternalFromDataSet(const pDataSet: TDataSet);
begin
end;
}
{
procedure TLmxModeloBase.InternalFromJsonObject(const AJsonObject: TJSONObject);
begin

end;
}

procedure TLmxModeloBase.InternalInicializar;
begin

end;

{
procedure TLmxModeloBase.InternalToDataSet(const pDataSet: TDataSet);
begin

end;
}
{
procedure TLmxModeloBase.InternalToJsonObject(const AJsonObject: TJSONObject);
begin

end;
}

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: Boolean);
begin
  AJsonObject.RemovePair(pNomeCampo);
  AJsonObject.AddPair(pNomeCampo, TJSONBool.Create(AValorCampo))
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: Double);
begin
  if AValorCampo <> 0 then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONNumber.Create(AValorCampo));
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: Currency);
begin
  if AValorCampo <> 0 then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONNumber.Create(AValorCampo));
  end;
end;

{
procedure TLmxModeloBase.ToDataSet(const pDataSet: TDataSet);
begin
  InternalToDataSet(pDataSet);
end;
}

function TLmxModeloBase.ToJsonObject: TJSONObject;
begin
  Result := TJSONObject(TJSONObject.ParseJSONValue(TLmxSerialization.ToJsonString(Self)));
end;

function TLmxModeloBase.ToJsonString: string;
var
  lObjeto : TJSONObject;
begin
  lObjeto := ToJsonObject;
  try
    Result := lObjeto.ToString;
  finally
    lObjeto.Free;
  end;
end;

procedure TLmxModeloBase.CarregarValorDeJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; ACampo: TLmxModeloBase);
var
  lJsonValue : TJsonValue;
begin
  lJsonValue := AJsonObject.Values[pNomeCampo];
  if (lJsonValue <> nil) and (lJsonValue is TJSONObject) then
    ACampo.FromJsonObject(TJsonObject(lJsonValue));
end;

procedure TLmxModeloBase.CarregarValorDeJson<T>(const AJsonObject: TJSONObject;
  const pNomeCampo : string; var ACampo : T);
var
  lJsonValue : TJsonValue;
begin
  lJsonValue := AJsonObject.Values[pNomeCampo];
  if lJsonValue <> nil then
    ACampo := lJsonValue.GetValue<T>;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: TLmxModeloBase);
begin
  if AValorCampo <> nil then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, AValorCampo.ToJsonObject);
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: TDate);
begin
  if AValorCampo <> 0 then
  begin
    AJsonObject.RemovePair(pNomeCampo);
    AJsonObject.AddPair(pNomeCampo, TJSONString.Create(DateToISO8601(AValorCampo)));
  end;
end;

procedure TLmxModeloBase.GerarValorParaJson<T>(const AJsonObject: TJSONObject;
  const pNomeCampo: string; const AValorCampo: TObjectList<T>);
begin

end;

function TLmxModeloBase.GetValorByFieldName(const pFieldName: string): string;
var
  lObjeto: TJSONObject;
  lValor: TJSONValue;
begin
  Result := '0';
  lObjeto := Self.ToJsonObject;
  try
    lValor := lObjeto.GetValue(pFieldName);
    if lValor <> nil then
      Result := lObjeto.GetValue(pFieldName).ToString
  finally
    lObjeto.Free;
  end;
end;

//procedure TDuxClasseBase.GerarValorParaJson<T>(const AJsonObject: TJSONObject;
//  const pNomeCampo: string; const AValorCampo: TDuxClasseBaseList<T>);
//begin
//  if AValorCampo <> nil then
//    AJsonObject.AddPair(pNomeCampo, AValorCampo.ToJsonObject);
//end;

{ TLmxModeloBaseList<T> }

function TLmxModeloBaseList<T>.Add(const Value : T) : Integer;
begin
  Result := FList.Add(Value);
end;

function TLmxModeloBaseList<T>.Add: T;
begin
  Result := T.Create;
  FList.Add(Result);
end;

procedure TLmxModeloBaseList<T>.Clear;
begin
  FList.Clear;
end;

function TLmxModeloBaseList<T>.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TLmxModeloBaseList<T>.Create;
begin
  FList := TObjectList<T>.Create;
end;

destructor TLmxModeloBaseList<T>.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TLmxModeloBaseList<T>.First: T;
begin
  Result := nil;
  if FList.Count > 0 then
    Result := FList.First;
end;

procedure TLmxModeloBaseList<T>.FromDataSet(const pDataSet: TDataSet);
begin
  FromJsonString(TLmxSerialization.ExternalDataSetToJsonArrayString(pDataSet));
end;

procedure TLmxModeloBaseList<T>.FromDataSet(const pDataSet: TDataSet;
  const pOnCarregarITem : TProc<T, string>);
begin
  if Assigned(pOnCarregarITem) then
  begin
    FromJsonString(TLmxSerialization.ExternalDataSetToJsonArrayString(
      pDataSet,
      True),
      procedure(const AItem : TObject; const ADados : String)
      begin
        if Assigned(pOnCarregarITem) then
          pOnCarregarITem(T(AItem), ADados);
      end);

//      procedure (pITemObject : TJsonObject)
//      var
//        lITem: TLmxModeloBase;
//      begin
//        lITem := T.Create;
//        lITem.FromJsonObject(pITemObject);
//        pOnCarregarITem(lItem);
//      end)

  end else
    FromJsonString(TLmxSerialization.ExternalDataSetToJsonArrayString(pDataSet))

end;

procedure TLmxModeloBaseList<T>.FromJsonObject(const AJsonObject: TJSONArray);
var
  lItem : T;
  lJsonArray : TJSONArray;
  I: Integer;
begin

  for I := 0 to AJsonObject.Count - 1 do
  begin
    lItem := T.Create;
    lItem.FromJsonObject(AJsonObject.Items[I] as TJsonObject);
    Self.Add(lItem);
  end;
end;

procedure TLmxModeloBaseList<T>.FromJsonString(const AJsonString: string; const AOnNovoITem: TOnNewItemObjectEnumJson);
//var
//  lJsonStream : TStringStream;
//  lObjetoJson : TJSONObject;
//  I : Integer;
//  lItem : T;
//  lArray : TJSONArray;
begin
  TLmxSerialization.FromJsonArrayString(Self, Self, AJsonString,
    (procedure(const AItem : TObject; const ADados : String)
     begin
       T(AItem).IsEmpty := False;
       if Assigned(AOnNovoITem) then
         AOnNovoITem(AITem, ADados);
     end));

{  lArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(AJsonString), 0) as TJSONArray;
  try
    if lArray = nil then
      raise Exception.Create('O Json passado para ser carregado na classe ' + Self.ClassName + ' parece não ser válido.');

    for i := 0 to lArray.Count - 1 do
    begin
      lObjetoJson := lArray.Items[I] as TJsonObject;

      lItem := T.Create;
      lItem.FromJsonObject(lObjetoJson);
      Self.Add(lItem);
    end;
  finally
    lArray.Free;
  end;     }
end;

function TLmxModeloBaseList<T>.GetDescription: string;
begin
  Result := Self.ClassName;
end;

function TLmxModeloBaseList<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FList.GetEnumerator;
end;

//function TLmxModeloBaseList<T>.GetItemClass: T;
//begin
//  Result := T;
//end;

function TLmxModeloBaseList<T>.GetItemObject(const AIndex: Integer): TObject;
begin
  Result := T(FList.Items[AIndex]);
end;

function TLmxModeloBaseList<T>.GetItem(index: Integer): T;
begin
  Result := T(FList.Items[index]);
end;

function TLmxModeloBaseList<T>.GetNewItemObject: TObject;
var
  lResultado: TLmxModeloBase;
begin
//  Result := T.Create;
  lResultado := T.Create;
  FList.Add(lResultado);
  Result := lResultado;
end;

function TLmxModeloBaseList<T>.Remove(const Value: T) : Integer;
begin
  Result := FList.Remove(Value);
end;

procedure TLmxModeloBaseList<T>.ToDataSet(const pDataSet: TDataSet);
var
  lJsonAray : TJSONArray;
  lConversor : TCustomJSONDataSetAdapter;
begin
  lJsonAray := ToJsonObject;
  lConversor := TCustomJSONDataSetAdapter.Create(nil);
  try
    lConversor.Dataset := pDataset;
    lConversor.UpdateDataSet(lJsonAray);
  finally
    lConversor.Free;
    lJsonAray.Free;
  end;
end;

function TLmxModeloBaseList<T>.ToJsonObject: TJSONArray;
var
  lItem : T;
begin
  Result := TJSONArray.Create;
  for lItem in Self do
  begin
    Result.AddElement( lItem.ToJsonObject );
  end;
end;

function TLmxModeloBaseList<T>.ToJsonString: string;
begin
  Result := TLmxSerialization.ToJsonArrayString(Self);
end;

end.
