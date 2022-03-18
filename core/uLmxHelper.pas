unit uLmxHelper;

interface

uses
  IOUtils, SysUtils, Classes, uLmxAttributes, uLmxSerialization, uLmxDataSet;

type

  TLmxHelperObject = class helper for TObject
  public
    function SalvarEmArquivo(const AFileName: string; const ASomenteSerializaveis : Boolean = True): Boolean;
    function CarregarDeArquivo(const AFileName: string; const ASomenteSerializaveis : Boolean = True): Boolean;

    procedure ClonarDeOutro(const AObject : TObject);
    procedure CarregarDeDataSet(const ADataSet : TLmxDataSet);

    function ScriptInsert(const AObject : TObject) : string;

    function GetCaminhoRest : string;

    function ToJsonString(const ASomenteSerializaveis : Boolean = False): string;
    function ToJsonArrayString(const ALista: ILmxEnumerable; const ASomenteSerializaveis : Boolean = False): string;

    function FromJsonString(const ADados : string; const ASomenteSerializaveis : Boolean = False): Boolean;
    function FromXmlString(const ADados : string; const ASomenteSerializaveis : Boolean = True): Boolean;

//    function FromJsonArrayString<T : Class, constructor>(const AEnumObject : ILmxEnumerable; const ADados : string;
//      const AClasse : TClass; const AOnAddObject : TOnAddObjectEnumJson<T>; const ASomenteSerializaveis : Boolean = False): Boolean;
    function FromJsonArrayString(const ALista: ILmxEnumerable; const ADados : string; const AOnNovoITem :  TOnNewItemObjectEnumJson = nil; const ASomenteSerializaveis : Boolean = False): Boolean;


    function FromString(const ADados : string; const ASomenteSerializaveis : Boolean = True): Boolean;
    function FromArrayString(const ADados : string; const ASomenteSerializaveis : Boolean = True): Boolean;

    function ToParamsGet: string;
  end;


//  TLmxHelperEnum = class helper for ILmxEnumerable
//  public
//    function ToJsonString(const ASomenteSerializaveis : Boolean = False): string;
//  end;


implementation

{ TLmxHelperObject }

function TLmxHelperObject.CarregarDeArquivo(const AFileName: string; const ASomenteSerializaveis : Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  {$IFDEF MSWINDOWS}
//  CoInitialize(nil);
  {$ENDIF}
  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
  try
    if TFile.Exists(AFileName) then
    begin
      if TPath.GetExtension(AFileName) = '.json' then
        lSerialization.FromJsonFile(AFileName)
      else
        lSerialization.FromXmlFile(AFileName);
    end;
    Result := True;
  finally
    FreeAndNil(lSerialization);
  {$IFDEF MSWINDOWS}
//    CoUninitialize;
  {$ENDIF}
  end;
end;

procedure TLmxHelperObject.CarregarDeDataSet(const ADataSet: TLmxDataSet);
var
  lSerialization: TLmxSerialization;
  lJsonString: string;
begin
  lSerialization := TLmxSerialization.Create(Self);
  try
//    lJsonString := lSerialization.ExternalDataSetToJsonString(ADataSet.DataSet);
//    lSerialization.FromJsonString(Self, );
  finally
    FreeAndNil(lSerialization);
  end;
end;

procedure TLmxHelperObject.ClonarDeOutro(const AObject: TObject);
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self);
  try
    lSerialization.FromOther(AObject);
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxHelperObject.FromArrayString(const ADados: string;
  const ASomenteSerializaveis: Boolean): Boolean;
begin
  Result := False;
  if ADados <> '' then
  begin
    if ADados[1] = '<' then
      Result := FromXmlString(ADados, ASomenteSerializaveis)
    else
      Result := FromJsonString(ADados, ASomenteSerializaveis);
  end;
end;

//function TLmxHelperObject.FromJsonArrayString<T>(const AEnumObject : ILmxEnumerable; const ADados: string;
//  const AClasse : TClass; const AOnAddObject : TOnAddObjectEnumJson<T>; const ASomenteSerializaveis: Boolean): Boolean;
//var
//  lSerialization: TLmxSerialization;
//begin
//  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
//  try
//    lSerialization.EnumGerarObjetoDeJson(procedure(const ADados : String) begin  end);
//
//
//
//    lSerialization.EnumCarregarObjetoDeJson(AEnumObject, ADados, function : TClass begin Result := AClasse end,
//      AOnAddObject);
////      procedure(const AObjeto : TObject) begin AEnumObject.AddObject(AObjeto) end );
//    Result := True;
//  finally
//    FreeAndNil(lSerialization);
//  end;
//end;

function TLmxHelperObject.FromJsonArrayString(const ALista: ILmxEnumerable; const ADados: string;
  const AOnNovoITem :  TOnNewItemObjectEnumJson; const ASomenteSerializaveis: Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
  try
    lSerialization.EnumGerarObjetoDeJson(ALista, ADados, AOnNovoITem);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;


function TLmxHelperObject.FromJsonString(const ADados : string;
  const ASomenteSerializaveis: Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
  try
    lSerialization.FromJson(ADados);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxHelperObject.FromString(const ADados: string;
  const ASomenteSerializaveis: Boolean): Boolean;
begin
  Result := False;
  if ADados <> '' then
  begin
    if ADados[1] = '<' then
      Result := FromXmlString(ADados, ASomenteSerializaveis)
    else
      Result := FromJsonString(ADados, ASomenteSerializaveis);
  end;
end;

function TLmxHelperObject.FromXmlString(const ADados: string;
  const ASomenteSerializaveis: Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
  try
    lSerialization.FromXml(ADados);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxHelperObject.GetCaminhoRest: string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self);
  try
    Result := lSerialization.GetCaminhoRest;
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxHelperObject.SalvarEmArquivo(const AFileName: string; const ASomenteSerializaveis : Boolean): Boolean;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
  try
    if LowerCase(TPath.GetExtension(AFileName)) = '.json' then
      lSerialization.ToJsonFile(AFileName)
    else
      lSerialization.ToXmlFile(AFileName);
    Result := True;
  finally
    FreeAndNil(lSerialization);
  end;
end;


function TLmxHelperObject.ScriptInsert(const AObject: TObject): string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, False);
  try
    Result := lSerialization.ToScriptInsert;
  finally
    FreeAndNil(lSerialization);
  end;
end;

function TLmxHelperObject.ToJsonArrayString(const ALista: ILmxEnumerable;
  const ASomenteSerializaveis: Boolean): string;
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

function TLmxHelperObject.ToJsonString(
  const ASomenteSerializaveis: Boolean): string;
var
  lSerialization: TLmxSerialization;
  lSerializationArray : ILmxEnumerable;
begin
  if Supports(Self, ILmxEnumerable) then
  begin
    lSerializationArray := TInterfacedObject(Self) as ILmxEnumerable;
    Result := ToJsonArrayString(lSerializationArray, ASomenteSerializaveis)
  end else begin
    lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
    try
      Result := lSerialization.ToJson;
    finally
      FreeAndNil(lSerialization);
    end;
  end;
end;

function TLmxHelperObject.ToParamsGet: string;
var
  lSerialization: TLmxSerialization;
begin
  lSerialization := TLmxSerialization.Create(Self, False);
  try
    Result := lSerialization.ToParamsGet;
  finally
    FreeAndNil(lSerialization);
  end;
end;

//{ TLmxHelperEnum }
//
//function TLmxHelperEnum.ToJsonString(
//  const ASomenteSerializaveis: Boolean): string;
//var
//  lSerialization: TLmxSerialization;
//begin
//  lSerialization := TLmxSerialization.Create(Self, ASomenteSerializaveis);
//  try
//    Result := lSerialization.ToJson;
//  finally
//    FreeAndNil(lSerialization);
//  end;
//end;

end.
