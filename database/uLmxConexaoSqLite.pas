unit uLmxConexaoSqlite;

interface

uses
  uLmxConexao, {$IFDEF VER270}System.SysUtils{$ELSE}SysUtils{$ENDIF}, uLmxInterfacesRegister,
  IOUtils, uLmxCmd, uLmxDataSet, Generics.Collections, uLmxInterfaces;

type

//  TLmxConexaoEstruturaCampo = class
//  public
//    property Nome : string read FNome write FNome;
//    property Tipo :
//  end;
//
//  TLmxConexaoEstruturaCampos = class(TObjectDictionary<string,TLmxConexaoEstruturaCampo>)
//  public
//    constructor Create;
//  end;
//
//  TLmxConexaoEstruturaTabela = class
//  private
//    FSchemaSQL: string;
//    FCampos: TLmxConexaoEstruturaCampos;
//  public
//    property SchemaSQL : string read FSchemaSQL write FSchemaSQL;
//    property Campos : TLmxConexaoEstruturaCampos read FCampos;
//  end;

  TLmxConexaoSqlite = class(TLmxConexao)
  private
//    function GetLocalInstalacaoSqlite : string;
  protected
    function GetDriverName : string; override;

    function DoBackup(const ANomeArquivoBackup : string) : Boolean; override;

    function DoScriptCriarTabela(const ATabela : string; const ACampos : string) : string; override;
    function DoScriptCriarDataBase(const ADataBaseName : string) : string; override;
    function DoScriptTabelaExiste(const AConexao, ATabela : string) : string; override;
    function DoScriptCriarCampo(const ANome, ATipo : string; const ANotNull : Boolean; const APrimaryKey : Boolean = False) : string; override;
    function DoScriptCriarChavePrimaria(const ANome : string) : string; override;
    function DoScriptCriarChaveEstrangeira(const ANome, ATabelaReferencia, ACampoReferencia : string) : string; override;
    function DoExecuteDirect(const ASQL: string): Boolean; override;
    function DoDataBaseExiste(const AConexao: string): Boolean; override;
    function DoConfigurarConexao(const AConexao: ILmxConnection): Boolean; override;
    function DoScriptObterInfoDataBase(const AConexao: string; out ANomeCampoTabela : string): string; override;
    function DoScriptObterInfoTabela(const AConexao: string; const ANome: string): string; override;
    function DoScriptObterInfoChaveEstrangeira(const AConexao: string; const ANomeTabela: string): string; override;
    function DoScriptObterInfoChavePrimaria(const AConexao: string; const ANomeTabela: string): string; override;
    function DoScriptAdicionarChavePrimaria(const ATabela, ANome: string): string; override;
    function DoScriptAdicionarChaveEstrangeira(const ATabela, ANome, ATabelaReferencia, ACampoReferencia : string): string; override;
    function DoScriptAdicionarCampo(const ATabela: string; const ANome: string; const ATipo: string; const ANotNull: Boolean): string; override;
    function DoScriptAlterarCampo(const ATabela: string; const ANome: string; const ATipo: string; const ANotNull: Boolean): string; override;

    function DoGetExisteInstalacao : Boolean; override;

    function DoGetDataSetInfoTabela(const ATabela : string; out ADataSet : TLmxDataSet) : Boolean; override;
//    function DoGetCampoIsPrimaryKeyFromScript(const AScript : string; out AIsPrimaryKey : Boolean) : string; override;
    function DoGetInfoCampoFromScript(const AScript : string; out ANome : string; out ATipo : string;
      out ATamanho, ADecimais : Integer; out ANotNull, AIsPrimaryKey : Boolean) : string; override;

    function DoScriptProximaSequencia(const ATabela : string; const ACampo : string; const ACondicao : string = '') : string; override;
    function DoScriptNovoIndice(const ATabela: string; const ANome: string;
      const ACampos: string): string; override;
    function DoScriptObterInfoIndices(const AConexao: string;
      const ANomeTabela: string): string; override;
    function DoScriptObterInfoCamposIndice(const AConexao: string;
      const ANomeIndice: string): string; override;
    function DoScriptObterInfoSequences(const AConexao, ANomeTabela : string) : string; override;


  public
    function GetCampoDateTime: string; override;
    function GetCampoBoolean: string; override;
    function GetCampoString(const ATamanho : Integer) : string; override;

  end;


implementation

{ TLmxConexaoSqLite }

function TLmxConexaoSqlite.DoExecuteDirect(const ASQL: string): Boolean;
//var
//  lLocalFirebird: string;
//  lCaminhoIsql: string;
//  lArquivoTemporario: string;
//  lArquivoTemporarioBat: string;
//  lExecutor: string;
begin
  Result := (Executar(ASQL) > 0);// False;
//  lLocalFirebird := GetLocalInstalacaoSqlite;
//  if lLocalFirebird <> '' then
//  begin
//    lCaminhoIsql := IncludeTrailingPathDelimiter(lLocalFirebird) + 'bin\';
//    lArquivoTemporario := TPath.GetTempFileName;
//    TFile.WriteAllText(lArquivoTemporario, ASQL);
//
//    lArquivoTemporarioBat := TPath.GetHomePath + '\tmpGerarDataBase.bat';
//    lExecutor := '"' + lCaminhoIsql + '"' + 'isql -input ' + '"' + lArquivoTemporario + '"';
////    lExecutor
//    TFile.WriteAllText(lArquivoTemporarioBat,lExecutor);
////    TFile.Replace(lArquivoTemporarioBat, );
//
////    ShellExecute(0, nil, 'cmd.exe', pWideChar(lExecutor), nil, SW_HIDE);
//    ShellExecute(0, nil, pChar(lArquivoTemporarioBat), nil, nil, SW_HIDE);
//    Sleep(2000);
//    Result := True;
//  end;
end;

function TLmxConexaoSqlite.DoGetInfoCampoFromScript(const AScript: string;
  out ANome: string; out ATipo: string; out ATamanho, ADecimais : Integer; out ANotNull, AIsPrimaryKey: Boolean): string;
var
  lScript: string;
  lPosicaoFinalNome: Integer;
  lPosicaoFinalTipo: Integer;
  lPosicaoInicialNome: Integer;
begin
  lScript := Trim(AScript);

  if Pos('PRIMARY KEY', lScript) = 1 then
  begin
    AIsPrimaryKey := True;

    ATamanho := 0;
    ADecimais := 0;
    ATipo    :=  '';
    ANotNull := False;

    lPosicaoInicialNome := Pos('(', lScript);
    lPosicaoFinalNome := Pos(')', lScript);

    ANome    := Trim(copy(lScript, lPosicaoInicialNome + 1, lPosicaoFinalNome - lPosicaoInicialNome - 1));

  end else begin
    lPosicaoFinalNome := Pos(' ', lScript);
    ANome    := Trim(copy(lScript, 1, lPosicaoFinalNome));
    lPosicaoFinalTipo := Pos(' ', lScript{$IFDEF VER270}, lPosicaoFinalNome + 1{$ENDIF});
    if lPosicaoFinalTipo = 0 then
      lPosicaoFinalTipo := Length(lScript);
    ATipo    := Trim(copy(lScript, lPosicaoFinalNome + 1, lPosicaoFinalTipo - lPosicaoFinalNome));
    ANotNull := (Pos('NOT NULL', lScript) > 0);

    DoGetTamanhoCampoFromString(AScript, ATamanho, ADecimais);
    if ATipo = 'INTEGER' then
      ATamanho := 4;
    if ATipo = 'TIMESTAMP' then
      ATamanho := 8;

    AIsPrimaryKey := (Pos('PRIMARY KEY', lScript) > 0);
  end;

end;

function TLmxConexaoSqlite.DoGetDataSetInfoTabela(const ATabela: string;
  out ADataSet: TLmxDataSet): Boolean;
//var
//  lSql: string;
begin
//  lSql := 'SELECT * FROM sqlite_master where type = "table" and name = "' + ATabela + '"';

//  NovaConsulta(ATabela, ADataSet)
  Result := False;
end;

function TLmxConexaoSqlite.DoGetExisteInstalacao: Boolean;
begin
  Result := TFile.Exists('sqlite3.dll') or TFile.Exists('sqlite.exe');
{$IFDEF VER270}
  if not Result then
    Result := TFile.Exists(TPath.GetLibraryPath + 'sqlite3.dll');
{$ELSE}
  if not Result then
    Result := TFile.Exists(ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
{$ENDIF}
//  Result := GetLocalInstalacaoSqlite <> '';
end;

function TLmxConexaoSqlite.DoScriptAdicionarCampo(const ATabela, ANome,
  ATipo: string; const ANotNull: Boolean): string;
const
  SQL_ALTER_FIELD =
    'ALTER TABLE %s ADD %s;';
begin
  Result := Format( SQL_ALTER_FIELD,  [ATabela, DoScriptCriarCampo(ANome, ATipo, ANotNull)]);
end;

function TLmxConexaoSqlite.DoScriptAdicionarChaveEstrangeira(const ATabela,
  ANome, ATabelaReferencia, ACampoReferencia: string): string;
const
  SQL_ALTER_FK =
    'ALTER TABLE %s ADD COLUMN %s INTEGER %s;';
//  SQL_ALTER_FK =
//    'ALTER TABLE %s ADD %s;';
begin
  Result := '';

//  Result := Format( SQL_ALTER_FK,  [ATabela, ATabelaReferencia + '_TMP',
//    DoScriptCriarChaveEstrangeira(ANome, ATabelaReferencia, ACampoReferencia)]);


//  Result := Result + sLineBreak +
//    'UPDATE ' + ATabela + ' SET ' + ATabelaReferencia + '_TMP' + ' = ' + ATabelaReferencia + ';';
//  Result := Result + sLineBreak +
//    'ALTER TABLE ' + ATabela + ' DROP COLUMN ' + ATabelaReferencia + '_TMP;' ;

//  Result := Format( SQL_ALTER_FK,  [ATabela,
//    DoScriptCriarChaveEstrangeira(ANome, ATabelaReferencia, ACampoReferencia)]);
//  Result := ''; //Format( SQL_ALTER_FK,  [ATabela, ATabela, Copy(ATabelaReferencia, 1, 5),
//    DoScriptCriarChaveEstrangeira(ANome, ATabelaReferencia, ACampoReferencia)]);
end;

function TLmxConexaoSqlite.DoScriptAdicionarChavePrimaria(const ATabela,
  ANome: string): string;
const
  SQL_ALTER_PK =
    'ALTER TABLE %s ADD %s;';
begin
  Result := ''; // Format( SQL_ALTER_PK,  [ATabela, DoScriptCriarChavePrimaria(ANome)]);
end;

function TLmxConexaoSqlite.DoScriptAlterarCampo(const ATabela, ANome,
  ATipo: string; const ANotNull: Boolean): string;
const
  SQL_CREATE_FIELD =
    'ALTER TABLE %s ALTER COLUMN %s %s';
//  SQL_ALTER_NOT_NULL =
//    'UPDATE RDB$RELATION_FIELDS SET ' +
//    ' RDB$NULL_FLAG = 1 ' +
//    ' WHERE (RDB$FIELD_NAME = ''%s'') AND '+
//    '(RDB$RELATION_NAME = ''%s'');';
begin
//  if ANotNull then
//    Result := Format( SQL_ALTER_NOT_NULL,  [UpperCase(ANome), UpperCase(ATabela)])
//  else
    Result := ''; // Format( SQL_CREATE_FIELD,  [UpperCase(ATabela), UpperCase(ANome), UpperCase(ATipo)]);
end;

function TLmxConexaoSqlite.DoScriptCriarCampo(const ANome, ATipo: string;
  const ANotNull: Boolean; const APrimaryKey : Boolean): string;
const
  SQL_CREATE_FIELD =
    '%s %s %s%s';
var
  lIsNotNull: string;
  lIsPrimaryKey: string;
begin
  lIsNotNull := '';
  lIsPrimaryKey := '';
  if ANotNull then
    lIsNotNull := 'NOT NULL';
  if APrimaryKey then
    lIsPrimaryKey := ' PRIMARY KEY';

  Result := Format( SQL_CREATE_FIELD,  [UpperCase(ANome), UpperCase(ATipo), lIsNotNull, lIsPrimaryKey]);
end;

function TLmxConexaoSqlite.DoScriptCriarChaveEstrangeira(const ANome,
  ATabelaReferencia, ACampoReferencia: string): string;
const
//  SQL_CREATE_FK =
//    'FOREIGN KEY (%s) REFERENCES %s(%s)';
  SQL_CREATE_FK =
    'REFERENCES %s(%s)';
begin
//  Result := Format( SQL_CREATE_FK,  [UpperCase(ANome), UpperCase(ATabelaReferencia), UpperCase(ACampoReferencia)]);
  Result := Format( SQL_CREATE_FK,  [UpperCase(ATabelaReferencia), UpperCase(ACampoReferencia)]);
end;

function TLmxConexaoSqlite.DoScriptCriarChavePrimaria(
  const ANome: string): string;
const
  SQL_CREATE_PK =
    'PRIMARY KEY (%s)';
begin
  Result := ''; //Format( SQL_CREATE_PK,  [UpperCase(ANome)]);
end;

function TLmxConexaoSqlite.DoScriptCriarDataBase(
  const ADataBaseName: string): string;
begin
  Result := '';
end;

function TLmxConexaoSqlite.DoScriptCriarTabela(const ATabela,
  ACampos: string): string;
const
  SQL_CREATE_TABLE =
    'CREATE TABLE %s ( ' +
    '%s);';
begin
  Result := Format( SQL_CREATE_TABLE, [UpperCase(ATabela), ACampos]);
end;

function TLmxConexaoSqlite.DoScriptNovoIndice(const ATabela, ANome,
  ACampos: string): string;
begin
  Result := Format('CREATE INDEX %s ON %s (%s)', [ANome, ATabela, ACampos]);
end;

function TLmxConexaoSqlite.DoScriptObterInfoCamposIndice(const AConexao,
  ANomeIndice: string): string;
var
  lCampos: string;
begin
  DoGetInfoIndexFromString(ANomeIndice, lCampos);
  Result := lCampos;




//    Format(
//    'SELECT RDB$FIELD_NAME AS NOME ' +
//    ' FROM RDB$INDEX_SEGMENTS ' +
//    ' WHERE RDB$INDEX_SEGMENTS.RDB$INDEX_NAME = ''%s'' ',
//    [ANomeIndice]);
end;

function TLmxConexaoSqlite.DoScriptObterInfoChaveEstrangeira(const AConexao,
  ANomeTabela: string): string;
begin
  Result := '';
end;

function TLmxConexaoSqlite.DoScriptObterInfoChavePrimaria(const AConexao,
  ANomeTabela: string): string;
begin
  Result := '';
end;

function TLmxConexaoSqlite.DoScriptObterInfoDataBase(
  const AConexao: string; out ANomeCampoTabela : string): string;
const
  SQL_INFO_DB =
  'SELECT name AS "NomeTabela" FROM sqlite_master WHERE type = "table" ';
begin
  Result := SQL_INFO_DB;
  ANomeCampoTabela := '';
end;

function TLmxConexaoSqlite.DoScriptObterInfoIndices(const AConexao,
  ANomeTabela: string): string;
const
  SQL_INFO_DB =
  'SELECT name AS "Nome",' + sLineBreak +
  '      Sql AS SchemaIndex,' + sLineBreak +
  '      tbl_name AS Tabela,' + sLineBreak +
  '      1 AS Ativo,' + sLineBreak +
  '      0 AS Unico ' + sLineBreak +
  ' FROM sqlite_master ' + sLineBreak +
  ' WHERE type = "index" and tbl_name = "%s" ';
begin
  Result := Format( SQL_INFO_DB,  [ANomeTabela]);
end;

function TLmxConexaoSqlite.DoScriptObterInfoSequences(const AConexao,
  ANomeTabela: string): string;
begin
  Result := '';
end;

function TLmxConexaoSqlite.DoScriptObterInfoTabela(const AConexao,
  ANome: string): string;
const
  SQL_INFO_DB =
  'SELECT DISTINCT Name AS Nome,' + sLineBreak +
  '      Sql AS SchemaTabela,' + sLineBreak +
  '      0 AS Tipo,' + sLineBreak +
//  '      "AAA" AS Descricao_Campo,' + sLineBreak +
//  '      "AAA" AS Valor_Padrao_Campo,' + sLineBreak +
  '      0 AS Tamanho, ' + sLineBreak +
  '      0 AS Decimais, ' + sLineBreak +
  '      0 AS "NotNull" ' + sLineBreak +
  ' FROM sqlite_master' + sLineBreak +
  ' WHERE type = "table" and name = "%s" ';
begin
  Result := Format( SQL_INFO_DB,  [ANome]);
end;

function TLmxConexaoSqlite.DoScriptProximaSequencia(const ATabela, ACampo,
  ACondicao: string): string;
begin
  Result := Format('SELECT COALESCE(MAX( %s ), 0) FROM %s %s', [ACampo, ATabela, ACondicao]);
end;

function TLmxConexaoSqlite.DoBackup(
  const ANomeArquivoBackup: string): Boolean;
//var
//  lDiretorioBackups: string;
//  lNomeBackup: string;
begin
  Result := False;
//  // GFix
//  LmxCommandLine.Executar('gfix -v -f ' + ControleConexao.DataBase + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );
//  LmxCommandLine.Executar('gfix -m -i ' + ControleConexao.DataBase + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );
//
//  lDiretorioBackups := ExtractFilePath(ControleConexao.DataBase) + '/BackupDB';
//  if TDirectory.Exists(lDiretorioBackups) then
//    TDirectory.CreateDirectory(lDiretorioBackups);
//
//  lNomeBackup := lDiretorioBackups + '/' + FormatDateTime('yyyymmddhhnnsszz', Now) + '_' + TPath.GetFileNameWithoutExtension(ControleConexao.DataBase) + '.bkplmx';
//  LmxCommandLine.Executar('gbak -g -b -z -l -v' + ControleConexao.DataBase + ' ' + lNomeBackup + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );
//  // GBak
end;

function TLmxConexaoSqlite.DoConfigurarConexao(
  const AConexao: ILmxConnection): Boolean;
begin
  AConexao.Params.Values['DriverName']    := 'Sqlite';
  AConexao.Params.Values['DriverUnit']    := 'Data.DbxSqlite';
  AConexao.Params.Values['DriverPackageLoader']    := 'TDBXSqliteDriverLoader,DBXSqliteDriver230.bpl';
  AConexao.Params.Values['MetaDataPackageLoader']    := 'TDBXSqliteMetaDataCommandFactory,DbxSqliteDriver230.bpl';
  AConexao.Params.Values['FailIfMissing']    := 'false';
  AConexao.Params.Values['ColumnMetaDataSupported'] := 'false';

//  AConexao.TableScope := [tsSynonym,tsTable,tsView];

//  AConexao.Params.Values['DriverName']    := 'WIN_1252';

  {$IFDEF WIN32}
  AConexao.LibraryName := 'sqlite3.dll';
  {$ENDIF}

//  Database=c:\tmp\teste4.db3

//  AConexao.Params.Values['ServerCharSet']    := 'WIN_1252';
//  AConexao.LibraryName := 'sqlite3.dll';
  Result := True;
end;

function TLmxConexaoSqlite.DoDataBaseExiste(
  const AConexao: string): Boolean;
//const
//  SQL_TABLE_EXISTS = 'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''%s''';
begin
  Result := TFile.Exists(AConexao);
//  Result := Format( SQL_TABLE_EXISTS, [ATabela]);
end;

function TLmxConexaoSqlite.DoScriptTabelaExiste(const AConexao,
  ATabela: string): string;
const
  SQL_TABLE_EXISTS = 'SELECT * FROM sqlite_master WHERE type = "table" and name = "%s" ';
begin
  Result := Format( SQL_TABLE_EXISTS, [UpperCase(ATabela)]);
end;

function TLmxConexaoSqlite.GetCampoBoolean: string;
begin
  Result := 'SMALLINT';
end;

function TLmxConexaoSqlite.GetCampoDateTime: string;
begin
  Result := 'TIMESTAMP';
end;

function TLmxConexaoSqlite.GetCampoString(const ATamanho: Integer): string;
begin
//  Result := 'TEXT';
  Result := 'VARCHAR(' + IntToStr(ATamanho) + ')';
end;

function TLmxConexaoSqlite.GetDriverName: string;
begin
  Result := 'Sqlite';
end;

//function TLmxConexaoSqlite.GetLocalInstalacaoSqlite: string;
//begin
//  Result := '';
////  Result := TFile.Exists(TPath.GetLibraryPath + 'sqlite3.dll');
//end;

//{ TLmxConexaoEstruturaCampos }
//
//constructor TLmxConexaoEstruturaCampos.Create;
//begin
//  inherited Create([doOwnsValues]);
//end;

initialization
  uLmxInterfacesRegister.RegisterInterface.Conexoes.RegistrarConexao
    (TLmxConexaoSqlite, 'Banco de Dados Sqlite');

end.
