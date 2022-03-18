unit uLmxDataSet;

interface

uses
  SysUtils, Classes, DBClient, Provider, DB, Generics.Collections, Variants,
  uLmxInterfaces, Math, System.Rtti;

type

  TCDSCracker = class(TClientDataSet);

  TTipoExecucaoQuery = (teqErro, teqSQL, teqFiltro, teqExecute, teqMetadata, teqExecuteDirect);

  TOnQueryExecute = procedure (const ATipo : TTipoExecucaoQuery;
    const ASQL, AFiltro : string; const AQuantidadeRegistros : Integer) of object;


  TLmxParamSql = class(TInterfacedObject, ILmxParamSql)
  private
    FNome: string;
    FValue: TValue;
    FDataType : TFieldType;

    function GetNome: string;
    function GetValue: TValue;
    function GetDataType: TFieldType;
    procedure SetNome(const pValue: string);
    procedure SetValue(const pValue: TValue);
    procedure SetDataType(const Value: TFieldType);
  public
    constructor Create(const pNome : string; const pValue : TValue; const pDataType : TFieldType = ftUnknown);

    property Nome : string read GetNome write SetNome;
    property Value : TValue read GetValue write SetValue;
    property DataType : TFieldType read GetDataType write SetDataType;
  end;


  TLmxParamsSql = class(TInterfacedObject, ILmxParamsSql)
  private
    FParams : TDictionary<string, ILmxParamSql>;
    function GetParametro(const pNome: string): ILmxParamSql;
  public
    constructor Create;
    destructor Destroy; override;

    function AddParam(const pNome : string; const pValue : TValue; const pDataType : TFieldType = ftUnknown) : ILmxParamsSql;

    property Parametro[const pNome : string] : ILmxParamSql read GetParametro;

    procedure Percorrer(const pProc : TProc<string,TValue, TFieldType>);
  end;


  TLmxDataSet = class(TComponent)
  private type
    TLmxCacheIndex = class(TDictionary<string, Integer>)
    private
      FInternalDataSet: TClientDataSet;
    public
      property InternalDataSet : TClientDataSet read FInternalDataSet write FInternalDataSet;
      function GetIndex(const AFieldName : string) : Integer;
    end;
  private
    FSQL : string;
    FFilter : string;
    FDataSet : TClientDataSet;
    FQuery : ILmxQuery;
    FProvider : TDataSetProvider;
    FDataSetExterno : Boolean;
    FOnQueryExecute: TOnQueryExecute;
    FUseCacheIndex: Boolean;
    FPDVCacheIndex : TLmxCacheIndex;
    FConexao : ILmxConnection;
    FGerador : ILmxGeradorConsulta;
//    function GetFieldFullName(const AFieldName : string) : string;
    function GetValidarCampo : Boolean;
    function GetFilter : string;
    function GetSQL : string;
    function GetLocalFilterSemNative(const AFilter : string) : string;
    function GetLocalFilter(const AFilter : string) : string;
    procedure ExecutarOnQueryExecute(const ATipo : TTipoExecucaoQuery;
      const ASQL, AFiltro : string; const AQuantidadeRegistros : Integer);
    procedure SetPropriedades;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Build(const AConexao : ILmxConnection;
      const AGerador : ILmxGeradorConsulta; const AParams : ILmxParamsSql = nil); overload;
    procedure Build(const AConexao : ILmxConnection;
      const ASQL : String; const AParams : ILmxParamsSql = nil); overload;
    procedure Build(const ADataSet : TClientDataSet); overload;
    procedure SetGerador(AGerador : ILmxGeradorConsulta);
    procedure Open;
    procedure Close;
    procedure Refresh(const AFilter : string; const AForceRefreshInDataSet : Boolean = False);
    procedure Find(const AFilter : string);
    procedure FindInDataSet(const AFilter : string);

    function Eof : Boolean;
    procedure First;
    function FieldByName(const AFieldName : string) : TField;
    function FindField(const AFieldName : string) : TField;
    function RecordCount : Integer;
    procedure Next;
    function IsEmpty : Boolean;

    function GetLocalFilterNative(const AFilter : string) : string;
    function LocalFilter(const AFilter : string) : string;
    function FilterAsParams(const AFilter : string) : ILmxParamsSql;

    property DataSet : TClientDataSet read FDataSet;
    property Query : ILmxQuery read FQuery;
    property Provider : TDataSetProvider read FProvider;
    property OnQueryExecute : TOnQueryExecute read FOnQueryExecute write FOnQueryExecute;
    property UseCacheIndex : Boolean read FUseCacheIndex write FUseCacheIndex;
  end;

implementation

{ TLmxDataSet }

procedure TLmxDataSet.Build(const AConexao: ILmxConnection; const ASQL: String; const AParams : ILmxParamsSql);
begin
  FDataSetExterno := False;
  FSQL := ASQL;
  FConexao := AConexao.CloneConnection;
  if FQuery = nil then
    FQuery := FConexao.NewQuery(Self);

  FQuery.Connection := FConexao;
  FQuery.CommandText := GetSQL;

  FQuery.SetParams(AParams);

  FProvider.DataSet := FQuery.GetDataSet;
  FDataSet.SetProvider(FProvider);
end;

procedure TLmxDataSet.Build(const ADataSet: TClientDataSet);
var
  I: Integer;
begin
//  FSQL := ASQL;
//  FQuery.SQLConnection := AConexao;
//  FQuery.CommandText := GetSQL;

//  FProvider.DataSet := FQuery;
  FDataSetExterno := True;
  FDataSet.Data := ADataSet.Data;

  for I := 0 to ADataSet.FieldCount - 1 do
  begin
    FDataSet.Fields[I].DisplayLabel := ADataSet.Fields[I].DisplayLabel;
    FDataSet.Fields[I].Visible := ADataSet.Fields[I].Visible;
    FDataSet.Fields[I].EditMask := ADataSet.Fields[I].EditMask;
  end;
end;

procedure TLmxDataSet.Build(const AConexao: ILmxConnection;
  const AGerador: ILmxGeradorConsulta; const AParams : ILmxParamsSql);
begin
  FGerador := AGerador;
  Build(AConexao, FGerador.ToString, AParams);
end;

procedure TLmxDataSet.Close;
begin
  if FDataSet.Active then
  begin
    FDataSet.Close;
    FQuery.Close;
  end;
end;

constructor TLmxDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FPDVCacheIndex := TLmxCacheIndex.Create;
//  FQuery := TSQLQuery.Create(Self);
  FProvider := TDataSetProvider.Create(Self);
  FDataSet := TClientDataSet.Create(Self);
  FPDVCacheIndex.InternalDataSet := FDataSet;
end;

destructor TLmxDataSet.Destroy;
begin
  FreeAndNil(FPDVCacheIndex);
  if FConexao <> nil then
  begin
    FConexao.Close;
    FConexao := nil;
  end;
  FQuery := nil;
  FDataSet.Free;
  inherited;
end;

function TLmxDataSet.Eof: Boolean;
begin
  Result := FDataSet.Eof;
end;

procedure TLmxDataSet.ExecutarOnQueryExecute(const ATipo: TTipoExecucaoQuery; const ASQL, AFiltro: string;
  const AQuantidadeRegistros: Integer);
begin
  if Assigned(FOnQueryExecute) then
    FOnQueryExecute(ATipo,  ASQL, AFiltro, AQuantidadeRegistros);
end;

function TLmxDataSet.FieldByName(const AFieldName: string): TField;
var
  lField: TField;
begin
  Result := nil;
  if GetValidarCampo then
  begin
    if FUseCacheIndex then
      Result := FDataSet.Fields[FPDVCacheIndex.GetIndex(AFieldName)]
    else
      Result := FDataSet.FieldByName(AFieldName);
  end else begin
    lField := FDataSet.FindField(AFieldName);
    if lField <> nil then
      Result := lField;
  end;
end;

function TLmxDataSet.FilterAsParams(const AFilter: string): ILmxParamsSql;
//var
//  I: Integer;
//  lField: TField;
////  lFiltrar: Boolean;
//  lIsNumero: Boolean;
//  lIsChave: Boolean;
//  lFieldName: string;
//  lIsData: Boolean;
//  lFiltrar: Boolean;
//  lFiltroSemNative: string;
//  lNative: string;
//  lFiltro : string;
//begin
//  Result := TLmxParamsSql.Create;
//
////  lFiltroSemNative := GetLocalFilterSemNative(AFilter);
//  lNative := GetLocalFilterNative(AFilter);
////  lFiltro := '';
////
//  if lNative <> '' then
//  begin
//
//  end;

//
//  if lFiltroSemNative <> '' then
//  begin
//    lIsNumero := StrToIntDef(lFiltroSemNative,0) <> 0;
//    lIsData := StrToDateTimeDef(lFiltroSemNative,0) <> 0;
//
//    for I := 0 to FDataSet.FieldCount - 1 do
//    begin
//      lField := FDataSet.Fields[I];
//
//  //    lFiltrar := lField.InheritsFrom(TIntegerField) or
//  //      lField.InheritsFrom(TStringField);
//
//      lIsChave := pfInKey in lField.ProviderFlags;
//
//      lFieldName := '';
//      lFiltrar := True;
//      if FGerador <> nil then
//      begin
//        lFieldName := FGerador.GetFieldFullName(lField.FieldName, lFiltrar);
//  //      lField.DisplayLabel := FGerador.GetDescricaoCampo(lField.FieldName);
//      end else begin
//        lFieldName := lField.Origin;
//        if lFieldName = '' then
//          lFieldName := VarToStr(TCDSCracker(FDataSet).InternalGetOptionalParam('ORIGIN',lField.FieldNo));
//        lFieldName := lField.FullName;
//      end;
//      if lFiltrar then
//      begin
//        if lFieldName = '' then
//          lFieldName := lField.FieldName;
//        if (lField.InheritsFrom(TDateTimeField) or (lField.InheritsFrom(TSQLTimeStampField))) and lIsData then
//        begin
//          if (lFiltro <> '') then
//            lFiltro := lFiltro + ' or ';
//
//          lFiltro := lFiltro + '(' + lFieldName + ' = ' +
//            QuotedStr(FormatDateTime('dd.mm.yyyy', StrToDateTimeDef(lFiltroSemNative,0))) + ')';
//  //          QuotedStr(lFiltroSemNative) + ')'
//    //    end else if lField.InheritsFrom(TStringField) and ((not lIsNumero) or lIsChave) then begin
//        end else if lField.InheritsFrom(TIntegerField) and (lIsNumero or lIsChave) then
//        begin
//          if (lFiltro <> '') then
//            lFiltro := lFiltro + ' or ';
//
//          lFiltro := lFiltro + '(' + lFieldName + ' = ' +
//            lFiltroSemNative + ')'
//    //    end else if lField.InheritsFrom(TStringField) and ((not lIsNumero) or lIsChave) then begin
//        end else if lField.InheritsFrom(TStringField) then begin
//          if (lFiltro <> '') then
//            lFiltro := lFiltro + ' or ';
//          lFiltro := lFiltro + '(UPPER(' + lFieldName + ') like UPPER(' +
//            QuotedStr('%' + lFiltroSemNative + '%') + '))'
//        end;
//      end;
//    end;
//  end;
//
//  if (lFiltro <> '') then
//  begin
//    if Result <> '' then
//      Result := Result + ' and (' + lFiltro + ')'
//    else
//      Result := lFiltro;
//  end;
begin
end;

procedure TLmxDataSet.Find(const AFilter: string);
var
  lFilter: string;
  lNative: string;
begin
  if AFilter <> '' then
  begin
    lNative := GetLocalFilterNative(AFilter);
    if lNative <> '' then
    begin
      Refresh(lNative);
    end else begin
      Refresh('0 <> 0');
      lFilter := GetLocalFilter(AFilter);
      Refresh(lFilter);
    end;
  end else
    Refresh('');
end;

function TLmxDataSet.FindField(const AFieldName: string): TField;
begin
  if FUseCacheIndex then
    Result := FDataSet.Fields[FPDVCacheIndex.GetIndex(AFieldName)]
  else
    Result := FDataSet.FindField(AFieldName);
end;

procedure TLmxDataSet.FindInDataSet(const AFilter: string);
begin
  if AFilter <> '' then
  begin
    Refresh(AFilter, True);
  end else
    Refresh('');
end;

procedure TLmxDataSet.First;
begin
  FDataSet.First;
end;

function TLmxDataSet.GetFilter: string;
begin
  Result := '';
  if FFilter <> '' then
    Result := '(' + StringReplace(FFilter, 'WHERE', '', [rfReplaceAll]) + ')';
end;

function TLmxDataSet.GetLocalFilter(const AFilter : string): string;
var
  I: Integer;
  lField: TField;
//  lFiltrar: Boolean;
  lIsNumero: Boolean;
  lIsChave: Boolean;
  lFieldName: string;
  lIsData: Boolean;
  lFiltrar: Boolean;
  lFiltroSemNative: string;
  lNative: string;
  lFiltro : string;
begin
  Result := '';

  lFiltroSemNative := GetLocalFilterSemNative(AFilter);
  lNative := GetLocalFilterNative(AFilter);
  lFiltro := '';

  if lNative <> '' then
    Result := lNative;

  if lFiltroSemNative <> '' then
  begin
    lIsNumero := StrToIntDef(lFiltroSemNative,0) <> 0;
    lIsData := StrToDateTimeDef(lFiltroSemNative,0) <> 0;

    for I := 0 to FDataSet.FieldCount - 1 do
    begin
      lField := FDataSet.Fields[I];

  //    lFiltrar := lField.InheritsFrom(TIntegerField) or
  //      lField.InheritsFrom(TStringField);

      lIsChave := pfInKey in lField.ProviderFlags;

      lFieldName := '';
      lFiltrar := True;
      if FGerador <> nil then
      begin
        lFieldName := FGerador.GetFieldFullName(lField.FieldName, lFiltrar);
  //      lField.DisplayLabel := FGerador.GetDescricaoCampo(lField.FieldName);
      end else begin
        lFieldName := lField.Origin;
        if lFieldName = '' then
          lFieldName := VarToStr(TCDSCracker(FDataSet).InternalGetOptionalParam('ORIGIN',lField.FieldNo));
        lFieldName := lField.FullName;
      end;
      if lFiltrar then
      begin
        if lFieldName = '' then
          lFieldName := lField.FieldName;
        if (lField.InheritsFrom(TDateTimeField) or (lField.InheritsFrom(TSQLTimeStampField))) and lIsData then
        begin
          if (lFiltro <> '') then
            lFiltro := lFiltro + ' or ';

          lFiltro := lFiltro + '(' + lFieldName + ' = ' +
            QuotedStr(FormatDateTime('dd.mm.yyyy', StrToDateTimeDef(lFiltroSemNative,0))) + ')';
  //          QuotedStr(lFiltroSemNative) + ')'
    //    end else if lField.InheritsFrom(TStringField) and ((not lIsNumero) or lIsChave) then begin
        end else if lField.InheritsFrom(TIntegerField) and (lIsNumero) then
        begin
          if (lFiltro <> '') then
            lFiltro := lFiltro + ' or ';

          lFiltro := lFiltro + '(' + lFieldName + ' = ' +
            lFiltroSemNative + ')'
    //    end else if lField.InheritsFrom(TStringField) and ((not lIsNumero) or lIsChave) then begin
        end else if lField.InheritsFrom(TStringField) then begin
          if (lFiltro <> '') then
            lFiltro := lFiltro + ' or ';
          lFiltro := lFiltro + '(UPPER(' + lFieldName + ') like UPPER(' +
            QuotedStr('%' + lFiltroSemNative + '%') + '))'
        end;
      end;
    end;
  end;

  if (lFiltro <> '') then
  begin
    if Result <> '' then
      Result := Result + ' and (' + lFiltro + ')'
    else
      Result := lFiltro;
  end;
end;

function TLmxDataSet.GetLocalFilterNative(const AFilter: string): string;
var
  lPosicaoNative: Integer;
  lPosicaoFinal: Integer;
begin
  lPosicaoNative := pos('[Native[', AFilter);
  if lPosicaoNative > 0 then
  begin
    lPosicaoFinal := pos(']]', AFilter);
    Result := Copy(AFilter, lPosicaoNative + length('[Native['), lPosicaoFinal - (lPosicaoNative + length('[Native[')));
  end;
end;

function TLmxDataSet.GetLocalFilterSemNative(const AFilter: string): string;
var
  lPosicaoNative: Integer;
  lPosicaoFinal: Integer;
begin
  lPosicaoNative := pos('[Native[', AFilter);
  if lPosicaoNative > 0 then
  begin
    lPosicaoFinal := pos(']]', AFilter);
    if lPosicaoNative = 1 then
      Result := Copy(AFilter, lPosicaoFinal + length(']]'), length(AFilter))
    else
      Result := Copy(AFilter, 1, lPosicaoNative - 1);
  end else
    Result := AFilter;
end;

function TLmxDataSet.GetSQL: string;
var
  lPosicaoGroupBy: Integer;
  lSQL: string;
  lCondicao : string;
  lPosicaoOrderBy: Integer;
  lMenor: Integer;
  lPosicaoCondicaoWhere: Integer;
  lPosicaoCondicaoAndOr: Integer;
//  lPosicaoCondicao: Integer;
begin
  lSQL := '';
  lCondicao := '';
  if FDataSetExterno then
    Result := ''
  else begin

    if FFilter <> '' then
    begin
      lPosicaoCondicaoWhere := 0;
      lPosicaoCondicaoAndOr := 0;

      while Pos('%_FILTER_WHERE_%', UpperCase(FSQL)) > lPosicaoCondicaoWhere do
        lPosicaoCondicaoWhere := Pos('%_FILTER_WHERE_%', UpperCase(FSQL));
      while Pos('%_FILTER_AND_OR_%', UpperCase(FSQL)) > lPosicaoCondicaoAndOr do
        lPosicaoCondicaoAndOr := Pos('%_FILTER_AND_OR_%', UpperCase(FSQL));

//      lPosicaoWhere := 0;
//      while Pos('WHERE', UpperCase(FSQL)) > lPosicaoWhere do
//        lPosicaoWhere := Pos('WHERE', UpperCase(FSQL));
//      if (lPosicaoWhere = 0) or (lPosicaoWhere > lPosicaoCondicao) then
//        lCondicao := ' WHERE ' + GetFilter
//      else begin
//        lCondicao := ' AND ' + GetFilter;
//      end;

      if lPosicaoCondicaoWhere > 0 then
      begin
        lCondicao := ' WHERE ' + GetFilter;
        lSQL := FSQL.Replace('%_FILTER_WHERE_%', lCondicao);
      end else if lPosicaoCondicaoAndOr > 0 then
      begin
        lCondicao := ' AND ' + GetFilter;
        lSQL := FSQL.Replace('%_FILTER_AND_OR_%', lCondicao);
      end else begin
        lPosicaoOrderBy := Pos('ORDER BY', UpperCase(FSQL));
        lPosicaoGroupBy := Pos('GROUP', UpperCase(FSQL));
        if (lPosicaoGroupBy > 0) or (lPosicaoOrderBy > 0) then
        begin
          if (lPosicaoGroupBy > 0) and (lPosicaoOrderBy > 0) then
            lMenor := Min(lPosicaoGroupBy, lPosicaoOrderBy)
          else if (lPosicaoGroupBy > 0) and (lPosicaoOrderBy = 0) then
            lMenor := lPosicaoGroupBy
          else
            lMenor := lPosicaoOrderBy;
          lSQL := Copy(FSQL, 1, lMenor -1) + lCondicao + ' ' +
            Copy(FSQL, lMenor, Length(FSQL))
        end else
          lSQL := FSQL + lCondicao;
      end;

//      lPosicaoGroupBy := Pos('GROUP', UpperCase(Result));
//      if lPosicaoGroupBy > 0 then
//        Result := Copy(Result, 1, lPosicaoGroupBy -1) + lCondicao + ' ' +
//          Copy(Result, lPosicaoGroupBy, Length(Result))
//      else
//        lSQL := Result + lCondicao;

      Result := lSQL;
    end else begin
      Result := FSQL.Replace('%_FILTER_WHERE_%', lCondicao);
      Result := Result.Replace('%_FILTER_AND_OR_%', lCondicao);
    end;
  end;
end;

function TLmxDataSet.GetValidarCampo: Boolean;
begin
  Result := True; //(FConexao.DriverName <> 'Sqlite');
end;

function TLmxDataSet.IsEmpty: Boolean;
begin
  Result := FDataSet.IsEmpty; // RecordCount = 0;
end;

function TLmxDataSet.LocalFilter(const AFilter: string): string;
begin
  Result := GetLocalFilter(AFilter);
end;

procedure TLmxDataSet.Next;
begin
  FDataSet.Next;
end;

procedure TLmxDataSet.Open;
begin
  if not FDataSetExterno then
  begin
    Close;
    FProvider.DataSet := FQuery.GetDataSet;
//    FProvider.OnGetTableName := GetTableName;
    FDataSet.SetProvider(FProvider);
    FDataSet.Open;
    SetPropriedades;
    ExecutarOnQueryExecute(teqSQL, FSQL, FFilter, FDataSet.RecordCount);
  end;
end;


function TLmxDataSet.RecordCount: Integer;
begin
  Result := FDataSet.RecordCount;
end;

procedure TLmxDataSet.Refresh(const AFilter: string; const AForceRefreshInDataSet : Boolean);
var
  lTipo: TTipoExecucaoQuery;
begin
  try
    FFilter := AFilter;
    if FDataSetExterno or AForceRefreshInDataSet then
    begin
      lTipo := teqFiltro;
      FDataSet.Filtered := False;
      if AFilter <> '' then
      begin
        FDataSet.Filter := AFilter;
        FDataSet.Filtered := True;
      end;
      ExecutarOnQueryExecute(lTipo, FSQL, FFilter, FDataSet.RecordCount);
    end else begin
      Close;
      FQuery.CommandText := GetSQL;
      Open;
    end;
  except on E:Exception do
    ExecutarOnQueryExecute(teqErro, FSQL, FFilter, 0);
  end;
end;

procedure TLmxDataSet.SetGerador(AGerador: ILmxGeradorConsulta);
begin
  FGerador := AGerador;
end;

procedure TLmxDataSet.SetPropriedades;
var
  I: Integer;
begin
  if FGerador <> nil then
  begin
    for I := 0 to FDataSet.FieldCount - 1 do
    begin
      FDataSet.Fields[I].DisplayLabel := FGerador.GetDescricaoCampo(FDataSet.Fields[I].FieldName);
      FDataSet.Fields[I].Visible := FGerador.GetCampoVisivel(FDataSet.Fields[I].FieldName);

  //    FDataSet.Fields[I].Visible := ADataSet.Fields[I].Visible;
  //    FDataSet.Fields[I].EditMask := ADataSet.Fields[I].EditMask;
    end;
  end;
end;

{ TLmxDataSet.TLmxCacheIndex }

function TLmxDataSet.TLmxCacheIndex.GetIndex(const AFieldName: string): Integer;
begin
  Result := -1;
  if not TryGetValue(AFieldName, Result) then
  begin
    Result := FInternalDataSet.FieldByName(AFieldName).Index;
    Add(AFieldName, Result);
  end;
end;


{ TLmxParamsSql }

function TLmxParamsSql.AddParam(const pNome: string;
  const pValue: TValue; const pDataType : TFieldType): ILmxParamsSql;
begin
  FParams.Add(pNome, TLmxParamSql.Create(pNome, pValue, pDataType));
  Result := Self;
end;

constructor TLmxParamsSql.Create;
begin
  FParams := TDictionary<string, ILmxParamSql>.Create;
end;

destructor TLmxParamsSql.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TLmxParamsSql.GetParametro(const pNome: string): ILmxParamSql;
begin
  FParams.TryGetValue(pNome, Result);
end;

procedure TLmxParamsSql.Percorrer(const pProc: TProc<string, TValue, TFieldType>);
var
  lEnum: TDictionary<string, ILmxParamSql>.TPairEnumerator;
begin
  lEnum := FParams.GetEnumerator;
  try
    while lEnum.MoveNext do
      pProc(lEnum.Current.Key, lEnum.Current.Value.Value, lEnum.Current.Value.DataType);
  finally
    lEnum.Free;
  end;
end;

{ TLmxParamSql }

constructor TLmxParamSql.Create(const pNome: string; const pValue: TValue; const pDataType : TFieldType);
begin
  FNome := pNome;
  FValue := pValue;
  FDataType := pDataType;
end;

function TLmxParamSql.GetDataType: TFieldType;
begin
  REsult := FDataType;
end;

function TLmxParamSql.GetNome: string;
begin
  Result := FNome;
end;

function TLmxParamSql.GetValue: TValue;
begin
  REsult := FValue;
end;

procedure TLmxParamSql.SetDataType(const Value: TFieldType);
begin
  FDataType := Value;
end;

procedure TLmxParamSql.SetNome(const pValue: string);
begin
  FNome := pValue;
end;

procedure TLmxParamSql.SetValue(const pValue: TValue);
begin
  FValue := pValue;
end;

end.
