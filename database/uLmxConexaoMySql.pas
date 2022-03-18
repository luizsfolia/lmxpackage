unit uLmxConexaoMySql;

interface

uses
  uLmxConexao, {$IFDEF VER270}System.SysUtils, Data.DBXMySQL, System.Win.Registry, Winapi.Windows, System.IOUtils,
  Winapi.ShellAPI {$ELSE}SysUtils, DBXMySQL, System.Win.Registry, Winapi.Windows, IOUtils, Winapi.ShellAPI{$ENDIF},
  uLmxInterfacesRegister;

type

  TLmxConexaoMySql = class(TLmxConexao)
//  private
//    function GetLocalInstalacaoMySql : string;
  protected
    function GetDriverName : string; override;

    function DoScriptCriarTabela(const ATabela : string; const ACampos : string) : string; override;
    function DoScriptCriarDataBase(const ADataBaseName : string) : string; override;
    function DoScriptTabelaExiste(const AConexao, ATabela : string) : string; override;
    function DoScriptCriarCampo(const ANome, ATipo : string; const ANotNull : Boolean; const APrimaryKey : Boolean = False) : string; override;
    function DoScriptCriarChavePrimaria(const ANome : string) : string; override;
    function DoScriptCriarChaveEstrangeira(const ANome, ATabelaReferencia, ACampoReferencia : string) : string; override;
    function DoDataBaseExiste(const AConexao: string): Boolean; override;
    function DoExecuteDirect(const ASQL: string): Boolean; override;

  end;


implementation

{ TLmxConexaoMySql }

function TLmxConexaoMySql.DoDataBaseExiste(const AConexao: string): Boolean;
begin
  Result := True;
end;

function TLmxConexaoMySql.DoExecuteDirect(const ASQL: string): Boolean;
var
  lArquivoTemporario: string;
  lArquivoTemporarioBat: string;
  lExecutor: string;
begin
//  lLocalMySql := GetLocalInstalacaoMySql;
//  if lLocalMySql <> '' then
//  begin
//    lArquivoTemporario := TPath.GetTempFileName;
    lArquivoTemporario := TPath.GetHomePath + '\tmpScript.sql';

    TFile.WriteAllText(lArquivoTemporario, ASQL);

    lArquivoTemporarioBat := TPath.GetHomePath + '\tmpScript.bat';

    lExecutor := 'mysql '  +
      ' -u ' + ControleConexao.User_Name +
      ' -p'  + ControleConexao.Password +
      ' ' + ControleConexao.DataBase +
      ' < "' +lArquivoTemporario + '"';

    TFile.WriteAllText(lArquivoTemporarioBat,lExecutor);

    ShellExecute(0, nil, pChar(lArquivoTemporarioBat), nil, nil, SW_HIDE);
    Sleep(2000);
    Result := True;
//  end;
end;

function TLmxConexaoMySql.DoScriptCriarCampo(const ANome, ATipo: string;
  const ANotNull: Boolean; const APrimaryKey : Boolean): string;
const
  SQL_CREATE_FIELD =
    '%s %s %s';
var
  lIsNotNull: string;
begin
  lIsNotNull := '';
  if ANotNull then
    lIsNotNull := 'NOT NULL';
  Result := Format( SQL_CREATE_FIELD,  [ANome, ATipo, lIsNotNull]);
end;

function TLmxConexaoMySql.DoScriptCriarChaveEstrangeira(const ANome,
  ATabelaReferencia, ACampoReferencia: string): string;
const
  SQL_CREATE_FK =
    'FOREIGN KEY (%s) REFERENCES %s(%s)';
begin
  Result := Format( SQL_CREATE_FK,  [ANome, ATabelaReferencia, ACampoReferencia]);
end;

function TLmxConexaoMySql.DoScriptCriarChavePrimaria(
  const ANome: string): string;
const
  SQL_CREATE_PK =
    'PRIMARY KEY (%s)';
begin
  Result := Format( SQL_CREATE_PK,  [ANome]);
end;

function TLmxConexaoMySql.DoScriptCriarDataBase(
  const ADataBaseName: string): string;
const
  SQL_CREATE_DATABASE = 'SET SQL DIALECT 3 ' +
    'SET NAMES UNICODE_FSS' +
    'CREATE DATABASE ''%s'' ' +
    'USER ''SYSDBA'' PASSWORD ''masterkey'' ' +
    'PAGE_SIZE 16384' +
    'DEFAULT CHARACTER SET UNICODE_FSS;';
begin
  Result := Format( SQL_CREATE_DATABASE, [ADataBaseName]);
end;

function TLmxConexaoMySql.DoScriptCriarTabela(const ATabela,
  ACampos: string): string;
const
  SQL_CREATE_TABLE =
    'CREATE TABLE %s ( ' +
    '%s);';
begin
  Result := Format( SQL_CREATE_TABLE, [ATabela, ACampos]);
end;

function TLmxConexaoMySql.DoScriptTabelaExiste(const AConexao, ATabela: string): string;
const
  SQL_TABLE_EXISTS = 'SELECT * FROM INFORMATION_SCHEMA.TABLES T WHERE T.TABLE_SCHEMA = ''%s'' AND T.TABLE_NAME = ''%s'';';
begin
  Result := Format( SQL_TABLE_EXISTS, [AConexao, ATabela]);
end;

function TLmxConexaoMySql.GetDriverName: string;
begin
  Result := 'MySQL';
end;

{function TLmxConexaoMySql.GetLocalInstalacaoMySql: string;
//const
//  CAMINHO_MYSQL = '\SOFTWARE\Firebird Project\Firebird Server\Instances\';
//var
//  lRegistro : TRegistry;
begin
  Result := '';
//  Result := '"C:\Program Files (x86)\MySQL\MySQL Server 5.6\bin\"'
//  Result := '';
//  lRegistro := TRegistry.Create(KEY_READ);
//  try
//    lRegistro.RootKey := HKEY_LOCAL_MACHINE;
//    if lRegistro.OpenKeyReadOnly(CAMINHO_FIREBIRD) then
//      if lRegistro.ValueExists ('DefaultInstance') then
//        Result := lRegistro.ReadString('DefaultInstance');
//    lRegistro.CloseKey;
//  finally
//    FreeAndNil(lRegistro);
//  end;
end;  }

initialization
  uLmxInterfacesRegister.RegisterInterface.Conexoes.RegistrarConexao
    (TLmxConexaoMySql, 'Banco de Dados MySQL');

end.
