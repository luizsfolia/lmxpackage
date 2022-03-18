unit uLmxControleConexao;

interface

uses
  uLmxAttributes, uLmxHelper;

type

  [TLmxAttributeSerializable('Conexao')]
  TLmxControleConexao = class
  private
    FDataBase: string;
    FUser_Name: string;
    FPassword: string;
    FHostName: string;
    FClasseDriver: string;
    FLogarComandos: Boolean;
  public
    [TLmxAttributeSerializable('ClasseDriver')]
    property ClasseDriver : string read FClasseDriver write FClasseDriver;
    [TLmxAttributeSerializable('Database')]
    property DataBase : string read FDataBase write FDataBase;
    [TLmxAttributeSerializable('HostName')]
    property HostName : string read FHostName write FHostName;
    [TLmxAttributeSerializable('User_Name')]
    property User_Name : string read FUser_Name write FUser_Name;
    [TLmxAttributeSerializable('Password')]
    property Password : string read FPassword write FPassword;
    [TLmxAttributeSerializable('LogarComandos')]
    property LogarComandos : Boolean read FLogarComandos write FLogarComandos;

    procedure FromOther(const AControleConexao : TLmxControleConexao);
  end;


implementation

{ TLmxControleConexao }

procedure TLmxControleConexao.FromOther(
  const AControleConexao: TLmxControleConexao);
begin
  FDataBase := AControleConexao.DataBase;
  FUser_Name := AControleConexao.User_Name;
  FPassword := AControleConexao.Password;
  FHostName := AControleConexao.HostName;
  FClasseDriver := AControleConexao.ClasseDriver;
end;

end.
