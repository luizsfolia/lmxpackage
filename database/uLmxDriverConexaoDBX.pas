unit uLmxDriverConexaoDBX;

interface

uses
  Classes, DB, SysUtils, uLmxInterfaces, SQLExpr;

type

  TLmxQueryDBX = class(TInterfacedObject, ILmxQuery)
  private
    FSQLConnection : ILmxConnection<TSQLConnection>;
    FSQLQuery : TSQLQuery;

    function GetConnection : ILmxConnection;
    procedure SetConnection(const AValue : ILmxConnection);
    function GetCommandText : string;
    procedure SetCommandText(const AValue : string);
    function GetDataSet : TDataSet;
    function GetSQL : TStrings;
    function GetFields : TFields;
  public
    constructor Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TSQLConnection>);
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

  TLmxDataSetDBX = class(TInterfacedObject, ILmxDataSet)
  private
    FSQLConnection : ILmxConnection<TSQLConnection>;
    FSQLDataset : TSQLDataSet;

    function GetConnection : ILmxConnection;
    procedure SetConnection(const AValue : ILmxConnection);
    function GetCommandText : string;
    procedure SetCommandText(const AValue : string);
    function GetDataSet : TDataSet;
    function GetFields : TFields;
  public
    constructor Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TSQLConnection>);
    destructor Destroy; override;

    procedure Open;
    function IsEmpty : Boolean;
    procedure DisableControls;
    procedure EnableControls;
    function ExecSQL : Integer;

    procedure Close;


    property Connection : ILmxConnection read GetConnection write SetConnection;
    property CommandText : string read GetCommandText write SetCommandText;
    property Fields : TFields read GetFields;
  end;

  TLmxDriverConexaoDBX = class(TInterfacedObject, ILmxConnection, ILmxConnection<TSQLConnection>)
  private
    FSQLConnection : TSQLConnection;
    function GetConnectionName : string;
    procedure SetConnectionName(const AValue : string);
    function GetDriverName : string;
    procedure SetDriverName(const AValue : string);
    function GetParams : TStrings;
    function GetLibraryName : string;
    procedure SetLibraryName(const AValue : string);
  public
    constructor Create(const AOwner : TComponent; const AConexao : TSQLConnection = nil);
    destructor Destroy; override;

    procedure Close;
    procedure CloseDataSets;

    function GetConnection : TSQLConnection;
    function CloneConnection : ILmxConnection;
    function NewQuery(const AOwner : TComponent) : ILmxQuery;
    function NewDataSet(const AOwner : TComponent) : ILmxDataset;


    property Params : TStrings read GetParams;
    property DriverName : string read GetDriverName write SetDriverName;
    property LibraryName : string read GetLibraryName write SetLibraryName;
  end;

implementation

{ TLmxQueryDBX }

procedure TLmxQueryDBX.Close;
begin
  FSQLQuery.Close;
end;

constructor TLmxQueryDBX.Create(const AOwner : TComponent; const ASQLConnection : ILmxConnection<TSQLConnection>);
begin
  FSQLConnection := ASQLConnection;
  FSQLQuery := TSQLQuery.Create(AOwner);
  FSQLQuery.SQLConnection := FSQLConnection.GetConnection;
end;

destructor TLmxQueryDBX.Destroy;
begin

  inherited;
end;

procedure TLmxQueryDBX.DisableControls;
begin
  FSQLQuery.DisableControls;
end;

procedure TLmxQueryDBX.EnableControls;
begin
  FSQLQuery.EnableControls;
end;

function TLmxQueryDBX.ExecSQL: Integer;
begin
  Result := FSQLQuery.ExecSQL;
end;

function TLmxQueryDBX.GetCommandText: string;
begin
  Result := FSQLQuery.CommandText;
end;

function TLmxQueryDBX.GetConnection: ILmxConnection;
begin
  Result := FSQLConnection;
end;

function TLmxQueryDBX.GetDataSet: TDataSet;
begin
  Result := FSQLQuery;
end;

function TLmxQueryDBX.GetFields: TFields;
begin
  Result := FSQLQuery.Fields;
end;

function TLmxQueryDBX.GetSQL: TStrings;
begin
  Result := FSQLQuery.SQL;
end;

function TLmxQueryDBX.IsEmpty: Boolean;
begin
  Result := FSQLQuery.IsEmpty;
end;

procedure TLmxQueryDBX.Open;
begin
  FSQLQuery.Open;
end;

procedure TLmxQueryDBX.SetCommandText(const AValue: string);
begin
  FSQLQuery.CommandText := AValue;
end;

procedure TLmxQueryDBX.SetConnection(const AValue: ILmxConnection);
begin
//  FSQLConnection := AValue;
end;

{ TLmxDataSetDBX }

procedure TLmxDataSetDBX.Close;
begin
  FSQLDataset.Close;
end;

constructor TLmxDataSetDBX.Create(const AOwner: TComponent; const ASQLConnection : ILmxConnection<TSQLConnection>);
begin
  FSQLConnection := ASQLConnection;
  FSQLDataset := TSQLDataSet.Create(AOwner);
  FSQLDataset.SQLConnection := FSQLConnection.GetConnection;
end;

destructor TLmxDataSetDBX.Destroy;
begin
  FreeAndNil(FSQLDataset);
  inherited;
end;

procedure TLmxDataSetDBX.DisableControls;
begin
  FSQLDataset.DisableControls;
end;

procedure TLmxDataSetDBX.EnableControls;
begin
  FSQLDataset.EnableControls;
end;

function TLmxDataSetDBX.ExecSQL: Integer;
begin
  Result := FSQLDataset.ExecSQL;
end;

function TLmxDataSetDBX.GetCommandText: string;
begin
  Result := FSQLDataset.CommandText;
end;

function TLmxDataSetDBX.GetConnection: ILmxConnection;
begin
  Result := FSQLConnection;
end;

function TLmxDataSetDBX.GetDataSet: TDataSet;
begin
  Result := FSQLDataset;
end;

function TLmxDataSetDBX.GetFields: TFields;
begin
  Result := FSQLDataset.Fields;
end;

function TLmxDataSetDBX.IsEmpty: Boolean;
begin
  Result := FSQLDataset.IsEmpty;
end;

procedure TLmxDataSetDBX.Open;
begin
  FSQLDataset.Open;
end;

procedure TLmxDataSetDBX.SetCommandText(const AValue: string);
begin
  FSQLDataset.CommandText := AValue;
end;

procedure TLmxDataSetDBX.SetConnection(const AValue: ILmxConnection);
begin
//  FSQLConnection := AValue;
end;

{ TLmxDriverConexaoDBX }

function TLmxDriverConexaoDBX.CloneConnection: ILmxConnection;
var
  lConexao: TSQLConnection;
begin
  lConexao := FSQLConnection.CloneConnection;
  Result := TLmxDriverConexaoDBX.Create(lConexao.Owner, lConexao) as ILmxConnection;
end;

procedure TLmxDriverConexaoDBX.Close;
begin
  FSQLConnection.Close;
end;

procedure TLmxDriverConexaoDBX.CloseDataSets;
begin
  FSQLConnection.CloseDataSets;
end;

constructor TLmxDriverConexaoDBX.Create(const AOwner : TComponent; const AConexao: TSQLConnection);
begin
  FSQLConnection := AConexao;
  if FSQLConnection = nil then
    FSQLConnection := TSQLConnection.Create(AOwner);

  FSQLConnection.KeepConnection := False;
  FSQLConnection.LoginPrompt := False;
end;

destructor TLmxDriverConexaoDBX.Destroy;
begin
  if FSQLConnection.Owner = nil then
    FreeAndNil(FSQLConnection);
  inherited;
end;

function TLmxDriverConexaoDBX.GetConnection: TSQLConnection;
begin
  Result := FSQLConnection;
end;

function TLmxDriverConexaoDBX.GetConnectionName: string;
begin
  Result := FSQLConnection.ConnectionName;
end;

function TLmxDriverConexaoDBX.GetDriverName: string;
begin
  Result := FSQLConnection.DriverName;
end;

function TLmxDriverConexaoDBX.GetLibraryName: string;
begin
  Result := FSQLConnection.LibraryName;
end;

function TLmxDriverConexaoDBX.GetParams: TStrings;
begin
  Result := FSQLConnection.Params;
end;

function TLmxDriverConexaoDBX.NewDataSet(const AOwner: TComponent): ILmxDataset;
begin
  Result := TLmxDataSetDBX.Create(AOwner, Self);
end;

function TLmxDriverConexaoDBX.NewQuery(const AOwner: TComponent): ILmxQuery;
begin
  Result := TLmxQueryDBX.Create(AOwner, Self);
end;

procedure TLmxDriverConexaoDBX.SetConnectionName(const AValue: string);
begin
  FSQLConnection.ConnectionName := AValue;
end;

procedure TLmxDriverConexaoDBX.SetDriverName(const AValue: string);
begin
  FSQLConnection.DriverName := AValue;
end;

procedure TLmxDriverConexaoDBX.SetLibraryName(const AValue: string);
begin
  FSQLConnection.LibraryName := AValue;
end;

end.
