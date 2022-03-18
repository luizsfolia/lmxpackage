unit uLmx.Service.DataBase;

interface

uses
  uLmxControleConexao, System.SysUtils,  uLmxInterfacesRegister,
  uLmxConexao, uLmxDriverConexaoFireDac, uLmxDataSet;
type

  TContextQueryExecute = reference to procedure (const ASQL, AFiltro : string; const AQuantidadeRegistros : Integer);
  TOnConfigContextDataBase = reference to procedure (const pControleConexao : TLmxControleConexao);

  TContextDataBaseConfig = class
  private
    class var FConfig : TContextDataBaseConfig;
  private
    FControleConexao: TLmxControleConexao;
    FOnContextQueryExecute: TContextQueryExecute;
    FOnConfig : TOnConfigContextDataBase;
    FClasseConexao : TLmxConexaoClass;

  public
    constructor Create;
    destructor Destroy; override;

    class constructor Create;
    class destructor Destroy;

    property ControleConexao : TLmxControleConexao read FControleConexao;
    function ClasseConexao : TLmxConexaoClass;
    procedure OnQueryExecute (const ATipo : TTipoExecucaoQuery;
      const ASQL, AFiltro : string; const AQuantidadeRegistros : Integer);

    property OnContextQueryExecute : TContextQueryExecute read FOnContextQueryExecute write FOnContextQueryExecute;

//    procedure SetOnConfig(const pClasseConexao : TLmxConexaoClass; const pOnConfig : TOnConfigContextDataBase);
    procedure RegistrarConexao(
      const pClasseConexao : TLmxConexaoClass;
      const pOnConfig : TOnConfigContextDataBase);

    class function Default : TContextDataBaseConfig;
  end;

implementation

{ TContextDataBaseConfig }

function TContextDataBaseConfig.ClasseConexao: TLmxConexaoClass;
begin
  Result := FClasseConexao;
end;

class constructor TContextDataBaseConfig.Create;
begin
  FConfig := TContextDataBaseConfig.Create;
end;

constructor TContextDataBaseConfig.Create;
begin
  FControleConexao := TLmxControleConexao.Create;
  uLmxConexao.RegistrarDriverConexao(TLmxDriverConexaoFireDac.Create(nil));

//  RegistrarTabelas;
end;

class function TContextDataBaseConfig.Default: TContextDataBaseConfig;
begin
  Result := FConfig;
end;

destructor TContextDataBaseConfig.Destroy;
begin
  FControleConexao.Free;
end;

class destructor TContextDataBaseConfig.Destroy;
begin
  FConfig.Free;
end;

procedure TContextDataBaseConfig.OnQueryExecute(const ATipo: TTipoExecucaoQuery;
  const ASQL, AFiltro: string; const AQuantidadeRegistros: Integer);
begin
  if Assigned(FOnContextQueryExecute) then
    FOnContextQueryExecute(ASQL, AFiltro, AQuantidadeRegistros);
end;



procedure TContextDataBaseConfig.RegistrarConexao(
  const pClasseConexao: TLmxConexaoClass;
  const pOnConfig: TOnConfigContextDataBase);
begin
  FClasseConexao := pClasseConexao;
  FOnConfig := pOnConfig;

  if Assigned(FOnConfig) then
    FOnConfig(FControleConexao)
  else
    raise Exception.Create('ma configuração de DataBase deve ser passada. Tente registrar o evento TContextDataBaseConfig.Default.SetOnConfig');

//  FControleConexao.HostName := 'localhost';
////  FControleConexao.DataBase := ExtractFilePath(ParamStr(0)) + 'Database\lmxfin.FDB';
//  FControleConexao.DataBase :=  'c:\tmp\Database\lmxfin.FDB';
////  FControleConexao.DataBase :=  'E:\Database\lmxfin.FDB';
//  FControleConexao.ClasseDriver := ClasseConexao.ClassName;
//  FControleConexao.User_Name := 'sysdba';
//  FControleConexao.Password := 'masterkey';
end;

end.
