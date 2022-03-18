unit uLmxDriverConexaoFireDac;

interface

uses
  Classes, DB, SysUtils, uLmxInterfaces, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite,
  FireDAC.Comp.UI, System.Rtti, Data.FmtBcd;

type

  TLmxQueryFireDac = class(TInterfacedObject, ILmxDataSet, ILmxQuery)
  private
    FSQLConnection : ILmxConnection<TFDCustomConnection>;
    FSQLQuery : TFDQuery;
    function GetConnection : ILmxConnection;
    procedure SetConnection(const AValue : ILmxConnection);
    function GetCommandText : string;
    procedure SetCommandText(const AValue : string);
    function GetDataSet : TDataSet;
    function GetSQL : TStrings;
    function GetFields : TFields;
    procedure SetParams(const AValue : ILmxParamsSql);
  public
    constructor Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TFDCustomConnection>);
    destructor Destroy; override;

    procedure Open;
    function IsEmpty : Boolean;
    procedure DisableControls;
    procedure EnableControls;
    function ExecSQL : Integer;

    procedure Close;

    property Connection : ILmxConnection read GetConnection write SetConnection;
    property CommandText : string read GetCommandText write SetCommandText;
    property SQL : TStrings read GetSQL;
    property Fields : TFields read GetFields;
  end;

//  TLmxDataSetFireDac = class(TInterfacedObject, ILmxDataSet)
//  private
//    FSQLConnection : ILmxConnection<TFDConnection>;
//    FSQLDataset : TFDDataSet;
//
//    function GetConnection : ILmxConnection;
//    procedure SetConnection(const AValue : ILmxConnection);
//    function GetCommandText : string;
//    procedure SetCommandText(const AValue : string);
//    function GetDataSet : TDataSet;
//    function GetFields : TFields;
//  public
//    constructor Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TFDConnection>);
//    destructor Destroy; override;
//
//    procedure Open;
//    function IsEmpty : Boolean;
//    procedure DisableControls;
//    procedure EnableControls;
//    function ExecSQL : Integer;
//
//    procedure Close;
//
//
//    property Connection : ILmxConnection read GetConnection write SetConnection;
//    property CommandText : string read GetCommandText write SetCommandText;
//    property Fields : TFields read GetFields;
//  end;

  TLmxDriverConexaoFireDac = class(TInterfacedObject, ILmxConnection, ILmxConnection<TFDCustomConnection>)
  private
    FOwner : TComponent;
    FSQLConnection : TFDCustomConnection;
    FDPhysDriverLink : TFDPhysDriverLink;
    FDGUIxWaitCursor1 : TFDGUIxWaitCursor;
    function GetConnectionName : string;
    procedure SetConnectionName(const AValue : string);
    function GetDriverName : string;
    procedure SetDriverName(const AValue : string);
    function GetParams : TStrings;
    function GetLibraryName : string;
    procedure SetLibraryName(const AValue : string);
  public
    constructor Create(const AOwner : TComponent; const AConexao : TFDCustomConnection = nil);
    destructor Destroy; override;

    procedure Close;
    procedure CloseDataSets;

    function GetConnection : TFDCustomConnection;
    function CloneConnection : ILmxConnection;
    function NewQuery(const AOwner : TComponent) : ILmxQuery;
    function NewDataSet(const AOwner : TComponent) : ILmxDataset;


    property Params : TStrings read GetParams;
    property DriverName : string read GetDriverName write SetDriverName;
    property LibraryName : string read GetLibraryName write SetLibraryName;
  end;

implementation

{ TLmxQueryFireDac }

procedure TLmxQueryFireDac.Close;
begin
  FSQLQuery.Close;
end;

constructor TLmxQueryFireDac.Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TFDCustomConnection>);
begin
  FSQLConnection := ASQLConnection;
  FSQLQuery := TFDQuery.Create(nil);
  FSQLQuery.Connection := FSQLConnection.GetConnection;
end;

destructor TLmxQueryFireDac.Destroy;
begin
  FreeAndNil(FSQLQuery);
  inherited;
end;

procedure TLmxQueryFireDac.DisableControls;
begin
  FSQLQuery.DisableControls;
end;

procedure TLmxQueryFireDac.EnableControls;
begin
  FSQLQuery.EnableControls;
end;

function TLmxQueryFireDac.ExecSQL: Integer;
begin
  FSQLQuery.ExecSQL;
  Result := FSQLQuery.RowsAffected;
end;

function TLmxQueryFireDac.GetCommandText: string;
begin
  Result := FSQLQuery.SQL.Text;
end;

function TLmxQueryFireDac.GetConnection: ILmxConnection;
begin
  Result := FSQLConnection;
end;

function TLmxQueryFireDac.GetDataSet: TDataSet;
begin
  Result := FSQLQuery;
end;

function TLmxQueryFireDac.GetFields: TFields;
begin
  Result := FSQLQuery.Fields;
end;

function TLmxQueryFireDac.GetSQL: TStrings;
begin
  Result := FSQLQuery.SQL;
end;

function TLmxQueryFireDac.IsEmpty: Boolean;
begin
  Result := FSQLQuery.IsEmpty;
end;

procedure TLmxQueryFireDac.Open;
begin
  FSQLQuery.Open;
end;

procedure TLmxQueryFireDac.SetCommandText(const AValue: string);
begin
  FSQLQuery.SQL.Text := AValue;
end;

procedure TLmxQueryFireDac.SetConnection(const AValue: ILmxConnection);
begin
//  FSQLConnection := AValue;
end;

procedure TLmxQueryFireDac.SetParams(const AValue: ILmxParamsSql);
begin
  if AValue <> nil then
  begin
//    FSQLQuery.Prepare;
    AValue.Percorrer(
      procedure (pNome : string; pValor : TValue; pDataType : TFieldType)
      var
        lParam: TFDParam;
      begin
        lParam := FSQLQuery.Params.FindParam(pNome);
        if lParam <> nil then
        begin
          if lParam.DataType = ftUnknown then
            lParam.DataType := pDataType;

          case lParam.DataType of
            ftString,
            ftMemo,
            ftFixedWideChar, ftWideMemo : lParam.AsString := pValor.AsString;
            ftSmallint,
            ftInteger : lParam.AsInteger := pValor.AsInteger;
            ftBoolean: lParam.AsBoolean := pValor.AsBoolean;

            ftFloat,
            ftCurrency : lParam.AsFloat := pValor.AsType<Double>;

            ftBCD,
            ftFMTBcd : lParam.AsFMTBCD := pValor.AsType<Double>;

            ftDate,
            ftTime,
            ftDateTime: lParam.AsDateTime := pValor.AsType<TDAteTime>;

            ftWord,
            ftBytes,
            ftVarBytes,
            ftAutoInc,
            ftBlob,
            ftGraphic,
            ftFmtMemo, // 12..18
            ftParadoxOle,
            ftDBaseOle,
            ftTypedBinary,
            ftCursor,
            ftFixedChar,
            ftWideString, // 19..24
            ftLargeint,
            ftADT,
            ftArray,
            ftReference,
            ftDataSet,
            ftOraBlob,
            ftOraClob, // 25..31
            ftVariant,
            ftInterface,
            ftIDispatch,
            ftGuid,
            ftTimeStamp : lParam.Value:= pValor.AsExtended;
            ftOraTimeStamp, ftOraInterval, // 38..41
            ftLongWord, ftShortint, ftByte, ftExtended, ftConnection, ftParams, ftStream, //42..48
            ftTimeStampOffset, ftObject, ftSingle :
              raise Exception.Create('Tipo Parametro não implementado');

          end;

//          case pValor.TypeInfo.Kind of
//            tkInteger,
//            tkInt64 : lParam.AsInteger := pValor.AsInteger;
//            tkFloat :
//              if pValor.TypeInfo.Name = '' then
//                lParam.AsDateTime := pValor.AsType<TDateTime>
//              else
//                lParam.AsFloat := pValor.AsExtended;
//            tkChar,
//            tkString,
//            tkWChar,
//            tkLString,
//            tkWString,
//            tkUString : lParam.AsString := pValor.AsString;
//          end;
        end;
      end);
  end;
end;

{ TLmxDataSetFireDac }

{procedure TLmxDataSetFireDac.Close;
begin
  FSQLDataset.Close;
end;

constructor TLmxDataSetFireDac.Create(const AOwner: TComponent; const ASQLConnection : ILmxConnection<TFDCustomConnection>);
begin
  FSQLConnection := ASQLConnection;
  FSQLDataset := TFDDataSet.Create(AOwner);
  FSQLDataset.Connection := FSQLConnection.GetConnection;
end;

destructor TLmxDataSetFireDac.Destroy;
begin
  FreeAndNil(FSQLDataset);
  inherited;
end;

procedure TLmxDataSetFireDac.DisableControls;
begin
  FSQLDataset.DisableControls;
end;

procedure TLmxDataSetFireDac.EnableControls;
begin
  FSQLDataset.EnableControls;
end;

function TLmxDataSetFireDac.ExecSQL: Integer;
begin
//  Result := FSQLDataset.ExecSQL;
end;

function TLmxDataSetFireDac.GetCommandText: string;
begin
//  Result := FSQLDataset.CommandText;
end;

function TLmxDataSetFireDac.GetConnection: ILmxConnection;
begin
  Result := FSQLConnection;
end;

function TLmxDataSetFireDac.GetDataSet: TDataSet;
begin
  Result := FSQLDataset;
end;

function TLmxDataSetFireDac.GetFields: TFields;
begin
  Result := FSQLDataset.Fields;
end;

function TLmxDataSetFireDac.IsEmpty: Boolean;
begin
  Result := FSQLDataset.IsEmpty;
end;

procedure TLmxDataSetFireDac.Open;
begin
  FSQLDataset.Open;
end;

procedure TLmxDataSetFireDac.SetCommandText(const AValue: string);
begin
//  FSQLDataset.CommandText := AValue;
end;

procedure TLmxDataSetFireDac.SetConnection(const AValue: ILmxConnection);
begin
//  FSQLConnection := AValue;
end;
}

{ TLmxDriverConexaoFireDac }

function TLmxDriverConexaoFireDac.CloneConnection: ILmxConnection;
{$IFDEF NOGUI}
{$ELSE}
var
  lConexao: TFDCustomConnection;
{$ENDIF}
begin
  {$IFDEF NOGUI}
  Result := Self;
  {$ELSE}
  lConexao := FSQLConnection.CloneConnection;
  Result := TLmxDriverConexaoFireDac.Create(lConexao.Owner, lConexao) as ILmxConnection;
  {$ENDIF}
end;

procedure TLmxDriverConexaoFireDac.Close;
begin
  FSQLConnection.Close;
end;

procedure TLmxDriverConexaoFireDac.CloseDataSets;
begin
//  FSQLConnection.CloseDataSets;
end;

constructor TLmxDriverConexaoFireDac.Create(const AOwner : TComponent; const AConexao: TFDCustomConnection);
begin
  FOwner := AOwner;

  FDGUIxWaitCursor1 := TFDGUIxWaitCursor.Create(AOwner);
  FDGUIxWaitCursor1.Provider := 'Forms';

  FSQLConnection := AConexao;
  if FSQLConnection = nil then
    FSQLConnection := TFDCustomConnection.Create(AOwner);

//  FSQLConnection.KeepConnection := False;
  FSQLConnection.LoginPrompt := False;
end;

destructor TLmxDriverConexaoFireDac.Destroy;
begin
  if FSQLConnection.Owner = nil then
    FreeAndNil(FSQLConnection);
  if FDPhysDriverLink <> nil then
    FreeAndNil(FDPhysDriverLink);
  FreeAndNil(FDGUIxWaitCursor1);
  inherited;
end;

function TLmxDriverConexaoFireDac.GetConnection: TFDCustomConnection;
begin
  Result := FSQLConnection;
end;

function TLmxDriverConexaoFireDac.GetConnectionName: string;
begin
  Result := FSQLConnection.ConnectionName;
end;

function TLmxDriverConexaoFireDac.GetDriverName: string;
begin
  Result := FSQLConnection.DriverName;
end;

function TLmxDriverConexaoFireDac.GetLibraryName: string;
begin
//  Result := FSQLConnection.LibraryName;
end;

function TLmxDriverConexaoFireDac.GetParams: TStrings;
begin
  Result := FSQLConnection.Params;

  Result.Values['CharacterSet']    := 'WIN1252';


end;

function TLmxDriverConexaoFireDac.NewDataSet(const AOwner: TComponent): ILmxDataset;
begin
  Result := TLmxQueryFireDac.Create(AOwner, Self); //TLmxDataSetFireDac.Create(AOwner, Self);
end;

function TLmxDriverConexaoFireDac.NewQuery(const AOwner: TComponent): ILmxQuery;
begin
  Result := TLmxQueryFireDac.Create(AOwner, Self);
end;

procedure TLmxDriverConexaoFireDac.SetConnectionName(const AValue: string);
begin
  FSQLConnection.ConnectionName := AValue;
end;

procedure TLmxDriverConexaoFireDac.SetDriverName(const AValue: string);
var
  lDriverName: string;
begin
  lDriverName := AValue;
  if AValue = 'Firebird' then
    lDriverName := 'FB'
  else if AValue = 'Sqlite' then
  begin
    lDriverName := 'SQLite';
    FDPhysDriverLink := TFDPhysSQLiteDriverLink.Create(FOwner);
  end;

  FSQLConnection.DriverName := lDriverName;
end;

procedure TLmxDriverConexaoFireDac.SetLibraryName(const AValue: string);
begin
//  FSQLConnection.LibraryName := AValue;
end;

end.

