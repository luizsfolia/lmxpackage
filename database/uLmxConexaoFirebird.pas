unit uLmxConexaoFirebird;

interface

uses
  uLmxConexao, SysUtils, System.Win.Registry, uLmxInterfacesRegister, uLmxInterfaces,
  IOUtils, WinApi.ShellApi, WinApi.Windows, WinApi.WinSvc, uLmxCmd{$IFDEF CompilerVersion < 33}, DBXFirebird{$ENDIF};

type

  TLmxConexaoFirebird = class(TLmxConexao)
  private
    function GetLocalInstalacaoFirebird : string;
    function GetLocalServicoFirebirdAtivo : string;
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
    function DoScriptGerarSequence(const ATabela: string; const ANome: string; const ANomeCampo : string): string; override;
    function DoScriptValorSequence(const ANome: string): string; override;
    function DoScriptObterInfoSequences(const AConexao, ANomeTabela : string) : string; override;

    function DoGetExisteInstalacao : Boolean; override;

    function DoScriptProximaSequencia(const ATabela : string; const ACampo : string; const ACondicao : string = '') : string; override;
    function DoScriptNovoIndice(const ATabela: string; const ANome: string;
      const ACampos: string): string; override;
    function DoScriptObterInfoIndices(const AConexao: string;
      const ANomeTabela: string): string; override;
    function DoScriptObterInfoCamposIndice(const AConexao: string;
      const ANomeIndice: string): string; override;
    function DoScriptCampoExiste(const AConexao: string; const ATabela: string;
      const ANomeCampo: string): string; override;
    function DoGetInfoCampoFromScript(const AScript: string; out ANome: string;
      out ATipo: string; out ATamanho: Integer; out ADecimais: Integer;
      out ANotNull: Boolean; out AIsPrimaryKey: Boolean): string; override;


  public
    function GetCampoDateTime: string; override;
    function GetCampoBoolean: string; override;

  end;


implementation

{ TLmxConexaoFirebird }

function TLmxConexaoFirebird.DoExecuteDirect(const ASQL: string): Boolean;
var
  lLocalFirebird: string;
  lCaminhoIsql: string;
  lArquivoTemporario: string;
  lArquivoTemporarioBat: string;
  lExecutor: string;
begin
  Result := False;
  lLocalFirebird := GetLocalInstalacaoFirebird;
  if lLocalFirebird <> '' then
  begin
    lCaminhoIsql := IncludeTrailingPathDelimiter(lLocalFirebird);
    if not TFile.Exists(lCaminhoIsql + 'isql.exe') then
      lCaminhoIsql := lCaminhoIsql + 'bin\';
    if not TFile.Exists(lCaminhoIsql + 'isql.exe') then
      raise Exception.Create('isql não encontrado em ' + lCaminhoIsql);

    lArquivoTemporario := TPath.GetTempFileName;
    TFile.WriteAllText(lArquivoTemporario, ASQL);

    lArquivoTemporarioBat := TPath.GetHomePath + '\tmpGerarDataBase.bat';
    lExecutor := '"' + lCaminhoIsql + '"' + 'isql -input ' + '"' + lArquivoTemporario + '"';
//    lExecutor
    TFile.WriteAllText(lArquivoTemporarioBat,lExecutor);
//    TFile.Replace(lArquivoTemporarioBat, );

//    ShellExecute(0, nil, 'cmd.exe', pWideChar(lExecutor), nil, SW_HIDE);
    ShellExecute(0, nil, pChar(lArquivoTemporarioBat), nil, nil, SW_HIDE);
    Sleep(2000);
    Result := True;
  end;
end;

function TLmxConexaoFirebird.DoGetExisteInstalacao: Boolean;
begin
  Result := GetLocalInstalacaoFirebird <> '';
end;

function TLmxConexaoFirebird.DoGetInfoCampoFromScript(const AScript: string;
  out ANome, ATipo: string; out ATamanho, ADecimais: Integer; out ANotNull,
  AIsPrimaryKey: Boolean): string;
begin
  Result := '';
end;

function TLmxConexaoFirebird.DoScriptAdicionarCampo(const ATabela, ANome,
  ATipo: string; const ANotNull: Boolean): string;
const
  SQL_ALTER_FIELD =
    'ALTER TABLE %s ADD %s;';
begin
  Result := Format( SQL_ALTER_FIELD,  [ATabela, DoScriptCriarCampo(ANome, ATipo, ANotNull)]);
end;

function TLmxConexaoFirebird.DoScriptAdicionarChaveEstrangeira(const ATabela,
  ANome, ATabelaReferencia, ACampoReferencia: string): string;
const
  SQL_ALTER_FK =
    'ALTER TABLE %s ADD CONSTRAINT FK_%s_%s %s;';
begin
  Result := Format( SQL_ALTER_FK,  [ATabela, ATabela, Copy(ATabelaReferencia, 1, 5),
    DoScriptCriarChaveEstrangeira(ANome, ATabelaReferencia, ACampoReferencia)]);
end;

function TLmxConexaoFirebird.DoScriptAdicionarChavePrimaria(const ATabela,
  ANome: string): string;
const
  SQL_ALTER_PK =
    'ALTER TABLE %s ADD CONSTRAINT PK_%s %s;';
begin
  Result := Format( SQL_ALTER_PK,  [ATabela, ATabela, DoScriptCriarChavePrimaria(ANome)]);
end;

function TLmxConexaoFirebird.DoScriptAlterarCampo(const ATabela, ANome,
  ATipo: string; const ANotNull: Boolean): string;
const
  SQL_CREATE_FIELD =
    'ALTER TABLE %s ALTER %s TYPE %s';
  SQL_ALTER_NOT_NULL =
    'UPDATE RDB$RELATION_FIELDS SET ' +
    ' RDB$NULL_FLAG = 1 ' +
    ' WHERE (RDB$FIELD_NAME = ''%s'') AND '+
    '(RDB$RELATION_NAME = ''%s'');';
begin
  if ANotNull then
    Result := Format( SQL_ALTER_NOT_NULL,  [UpperCase(ANome), UpperCase(ATabela)])
  else
    Result := Format( SQL_CREATE_FIELD,  [UpperCase(ATabela), UpperCase(ANome), UpperCase(ATipo)]);
end;

function TLmxConexaoFirebird.DoScriptCampoExiste(const AConexao, ATabela,
  ANomeCampo: string): string;
begin
  REsult := '';
end;

function TLmxConexaoFirebird.DoScriptCriarCampo(const ANome, ATipo: string;
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
  Result := Format( SQL_CREATE_FIELD,  [UpperCase(ANome), UpperCase(ATipo), lIsNotNull]);
end;

function TLmxConexaoFirebird.DoScriptCriarChaveEstrangeira(const ANome,
  ATabelaReferencia, ACampoReferencia: string): string;
const
  SQL_CREATE_FK =
    'FOREIGN KEY (%s) REFERENCES %s(%s)';
begin
  Result := Format( SQL_CREATE_FK,  [UpperCase(ANome), UpperCase(ATabelaReferencia), UpperCase(ACampoReferencia)]);
end;

function TLmxConexaoFirebird.DoScriptCriarChavePrimaria(
  const ANome: string): string;
const
  SQL_CREATE_PK =
    'PRIMARY KEY (%s)';
begin
  Result := Format( SQL_CREATE_PK,  [UpperCase(ANome)]);
end;

function TLmxConexaoFirebird.DoScriptCriarDataBase(
  const ADataBaseName: string): string;
const
  SQL_CREATE_DATABASE = 'SET SQL DIALECT 3; ' +
    ' SET NAMES UNICODE_FSS;' +
    ' CREATE DATABASE ''%s'' ' +
    ' USER ''SYSDBA'' PASSWORD ''masterkey'' ' +
    ' PAGE_SIZE 16384' +
    ' DEFAULT CHARACTER SET UNICODE_FSS;';
begin
  Result := Format( SQL_CREATE_DATABASE, [ADataBaseName]);
end;

function TLmxConexaoFirebird.DoScriptCriarTabela(const ATabela,
  ACampos: string): string;
const
  SQL_CREATE_TABLE =
    'CREATE TABLE %s ( ' +
    '%s);';
begin
  Result := Format( SQL_CREATE_TABLE, [UpperCase(ATabela), ACampos]);
end;

function TLmxConexaoFirebird.DoScriptGerarSequence(const ATabela, ANome,
  ANomeCampo: string): string;
begin
  if ANome = '' then
    Result := Format('CREATE SEQUENCE SEQ_%s', [ATabela])
  else
    Result := Format('CREATE SEQUENCE %s', [ANome]);
end;

function TLmxConexaoFirebird.DoScriptNovoIndice(const ATabela, ANome,
  ACampos: string): string;
begin
  Result := Format('CREATE INDEX %s ON %s (%s)', [ANome, ATabela, ACampos]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoCamposIndice(const AConexao,
  ANomeIndice: string): string;
begin
  Result :=
    Format(
    'SELECT RDB$FIELD_NAME AS NOME ' +
    ' FROM RDB$INDEX_SEGMENTS ' +
    ' WHERE RDB$INDEX_SEGMENTS.RDB$INDEX_NAME = ''%s'' ',
    [ANomeIndice]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoChaveEstrangeira(const AConexao,
  ANomeTabela: string): string;
const
  SQL_INFO_DB =
  '    SELECT A.RDB$RELATION_NAME TabelaRaiz, C.RDB$RELATION_NAME AS TabelaEstrangeira,' +
  '    D.RDB$FIELD_NAME AS CampoEstrangeiro, E.RDB$FIELD_NAME AS CampoRaiz' +
  '      FROM RDB$REF_CONSTRAINTS B, RDB$RELATION_CONSTRAINTS A, RDB$RELATION_CONSTRAINTS C,' +
  '           RDB$INDEX_SEGMENTS D, RDB$INDEX_SEGMENTS E, RDB$INDICES I' +
  '     WHERE (A.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'')' +
  '       AND (A.RDB$CONSTRAINT_NAME = B.RDB$CONSTRAINT_NAME)' +
  '       AND (B.RDB$CONST_NAME_UQ=C.RDB$CONSTRAINT_NAME)' +
  '       AND (C.RDB$INDEX_NAME=D.RDB$INDEX_NAME)' +
  '       AND (A.RDB$INDEX_NAME=E.RDB$INDEX_NAME)' +
  '       AND (A.RDB$INDEX_NAME=I.RDB$INDEX_NAME)' +
  '       AND (A.RDB$RELATION_NAME = ''%s'')';
begin
  Result := Format( SQL_INFO_DB,  [ANomeTabela]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoChavePrimaria(const AConexao,
  ANomeTabela: string): string;
const
  SQL_INFO_DB =
  '    SELECT RDB$FIELD_NAME as NomeCampo' +
  '    FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S' +
  '    WHERE C.RDB$RELATION_NAME = ''%s'' ' +
  '    AND C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
  '    AND S.RDB$INDEX_NAME = C.RDB$INDEX_NAME' +
  '    ORDER BY RDB$FIELD_POSITION';
begin
  Result := Format( SQL_INFO_DB,  [ANomeTabela]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoDataBase(
  const AConexao: string; out ANomeCampoTabela : string): string;
const
  SQL_INFO_DB =
  'SELECT RDB$RELATION_NAME AS NomeTabela FROM RDB$RELATIONS ' +
  '  WHERE RDB$SYSTEM_FLAG = 0;';
begin
  Result := SQL_INFO_DB;
  ANomeCampoTabela := 'NomeTabela';
end;

function TLmxConexaoFirebird.DoScriptObterInfoIndices(const AConexao,
  ANomeTabela: string): string;
const
  SQL_INFO_INDICES =
    'SELECT ' +
    ' RDB$INDEX_NAME AS NOME, ' +
    ' RDB$RELATION_NAME AS TABELA, ' +
    ' CASE WHEN COALESCE(RDB$INDEX_INACTIVE, 0) = 1 THEN 0 ELSE 1 END AS ATIVO, ' +
    ' RDB$UNIQUE_FLAG AS UNICO ' +
    'FROM RDB$INDICES ' +
    'WHERE RDB$RELATION_NAME = ''%s'' ';
begin
  Result := Format(SQL_INFO_INDICES, [ANomeTabela]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoSequences(const AConexao,
  ANomeTabela: string): string;
const
  SQL_INFO_SEQUENCES =
    'SELECT ' +
    ' RDB$GENERATOR_NAME AS NOME, ' +
    ' ''%s'' AS TABELA ' +
    'FROM RDB$GENERATORS ' +
    'WHERE RDB$GENERATOR_NAME = ''SEQ_%s'' ';
begin
  Result := format(SQL_INFO_SEQUENCES, [ANomeTabela, ANomeTabela]);
end;

function TLmxConexaoFirebird.DoScriptObterInfoTabela(const AConexao,
  ANome: string): string;
const
  SQL_INFO_DB =
  'SELECT DISTINCT R.RDB$FIELD_NAME AS Nome,' + sLineBreak +
  '      R.RDB$DESCRIPTION AS Descricao_Campo,' + sLineBreak +
  '      R.RDB$DEFAULT_VALUE AS Valor_Padrao_Campo,' + sLineBreak +
  '' + sLineBreak +
  '      CASE R.RDB$NULL_FLAG' + sLineBreak +
  '        WHEN 1 THEN 1 ' + sLineBreak +
  '        ELSE 0 ' + sLineBreak +
  '      END AS NotNull,' + sLineBreak +
  '' + sLineBreak +
  '      CASE' + sLineBreak +
  '      WHEN F.RDB$FIELD_TYPE in (10, 11, 16, 27) THEN F.RDB$FIELD_PRECISION' + sLineBreak +
  '      WHEN F.RDB$FIELD_TYPE in (37, 40) THEN F.RDB$CHARACTER_LENGTH' + sLineBreak +
  '      WHEN F.RDB$FIELD_TYPE in (261) THEN F.RDB$SEGMENT_LENGTH' + sLineBreak +
  '      ELSE F.RDB$FIELD_LENGTH' + sLineBreak +
  '      END AS Tamanho,' + sLineBreak +
  '      F.RDB$FIELD_PRECISION AS Precisao,' + sLineBreak +
//  '      F.RDB$FIELD_LENGTH AS Tamanho_,' +
//  '      F.RDB$FIELD_PRECISION AS Tamanho,' +
  '      (F.RDB$FIELD_SCALE * -1) AS Decimais,' + sLineBreak +
  '' + sLineBreak +
  '      --TLmxMetadataTipoCampo = (mtcAuto, mtcInteger, mtcChar, mtcVarchar, mtcBoolean, mtcNumeric, mtcDateTime, mtcBlobText)' + sLineBreak +
  '      CASE'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (9) THEN 0'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (8) THEN 1'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (14) THEN 2'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (37, 40) THEN 3'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (7) THEN 4'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (10, 11, 16, 27) THEN 5'  + sLineBreak +
  '        WHEN F.RDB$FIELD_TYPE in (12, 13, 35) THEN 6'  + sLineBreak +
  '        WHEN ((F.RDB$FIELD_TYPE in (261)) and (F.RDB$FIELD_SUB_TYPE = 1)) THEN 7'  + sLineBreak +
  '        ELSE 0 ' + sLineBreak +
  '      END AS Tipo,' + sLineBreak +
  '' + sLineBreak +
  '      F.RDB$FIELD_SUB_TYPE AS SubTipo_Campo,' + sLineBreak +
  '      CSET.RDB$CHARACTER_SET_NAME AS CHARSET_Campo' + sLineBreak +
  '' + sLineBreak +
  ' FROM RDB$RELATION_FIELDS R' + sLineBreak +
  ' LEFT JOIN RDB$FIELDS F ON R.RDB$FIELD_SOURCE = F.RDB$FIELD_NAME' + sLineBreak +
  ' LEFT JOIN RDB$COLLATIONS COLL ON F.RDB$COLLATION_ID = COLL.RDB$COLLATION_ID' + sLineBreak +
  ' LEFT JOIN RDB$CHARACTER_SETS CSET ON F.RDB$CHARACTER_SET_ID = CSET.RDB$CHARACTER_SET_ID' + sLineBreak +
  '' + sLineBreak +
  ' WHERE R.RDB$RELATION_NAME = ''%s'' ' + sLineBreak +
  ' ORDER BY R.RDB$FIELD_POSITION;';
begin
  Result := Format( SQL_INFO_DB,  [ANome]);
end;

function TLmxConexaoFirebird.DoScriptProximaSequencia(const ATabela, ACampo,
  ACondicao: string): string;
begin
  Result := Format('SELECT MAX( %s ) FROM %s %s', [ACampo, ATabela, ACondicao]);
end;

function TLmxConexaoFirebird.DoBackup(
  const ANomeArquivoBackup: string): Boolean;
var
  lDiretorioBackups: string;
  lNomeBackup: string;
begin
  // GFix
  LmxCommandLine.Executar('gfix -v -f ' + ControleConexao.DataBase + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );
  LmxCommandLine.Executar('gfix -m -i ' + ControleConexao.DataBase + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );

  lDiretorioBackups := ExtractFilePath(ControleConexao.DataBase) + '/BackupDB';
  if TDirectory.Exists(lDiretorioBackups) then
    TDirectory.CreateDirectory(lDiretorioBackups);

  lNomeBackup := lDiretorioBackups + '/' + FormatDateTime('yyyymmddhhnnsszz', Now) + '_' + TPath.GetFileNameWithoutExtension(ControleConexao.DataBase) + '.bkplmx';
  LmxCommandLine.Executar('gbak -g -b -z -l -v' + ControleConexao.DataBase + ' ' + lNomeBackup + ' -user ' + ControleConexao.User_Name + ' -pass ' + ControleConexao.Password );
  // GBak
  Result := True;
end;

function TLmxConexaoFirebird.DoConfigurarConexao(
  const AConexao: ILmxConnection): Boolean;
begin
  AConexao.Params.Values['ServerCharSet']    := 'WIN_1252';
  AConexao.LibraryName := 'fbclient.dll';
  Result := True;
end;

function TLmxConexaoFirebird.DoDataBaseExiste(
  const AConexao: string): Boolean;
//const
//  SQL_TABLE_EXISTS = 'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''%s''';
begin
  Result := TFile.Exists(AConexao);
//  Result := Format( SQL_TABLE_EXISTS, [ATabela]);
end;

function TLmxConexaoFirebird.DoScriptTabelaExiste(const AConexao,
  ATabela: string): string;
const
  SQL_TABLE_EXISTS = 'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''%s''';
begin
  Result := Format( SQL_TABLE_EXISTS, [UpperCase(ATabela)]);
end;

function TLmxConexaoFirebird.DoScriptValorSequence(const ANome : string): string;
begin
  Result := Format('SELECT NEXT VALUE FOR $s FROM RDB$DATABASE',[ANome]);
//  Result := Format('NEXT VALUE FOR %s', [ANome]);
end;

function TLmxConexaoFirebird.GetCampoBoolean: string;
begin
  Result := 'SMALLINT';
end;

function TLmxConexaoFirebird.GetCampoDateTime: string;
begin
  Result := 'TIMESTAMP';
end;

function TLmxConexaoFirebird.GetDriverName: string;
begin
  Result := 'Firebird';
end;

function TLmxConexaoFirebird.GetLocalInstalacaoFirebird: string;
const
  CAMINHO_FIREBIRD = '\SOFTWARE\Firebird Project\Firebird Server\Instances\';
var
  lRegistro : TRegistry;
begin
  Result := '';
  lRegistro := TRegistry.Create(KEY_READ);
  try
    lRegistro.RootKey := HKEY_LOCAL_MACHINE;
    if lRegistro.OpenKeyReadOnly(CAMINHO_FIREBIRD) then
      if lRegistro.ValueExists ('DefaultInstance') then
        Result := lRegistro.ReadString('DefaultInstance');
    lRegistro.CloseKey;
  finally
    FreeAndNil(lRegistro);
  end;
  if REsult = '' then
    Result := GetLocalServicoFirebirdAtivo;
end;

function TLmxConexaoFirebird.GetLocalServicoFirebirdAtivo: string;
{var
  SCManHandle, SvcHandle: SC_Handle;
  SS: TServiceStatus;
  sq : PQueryServiceConfig;
  dwStat: DWORD;
  lNeeds: Cardinal;
begin
  dwStat := 0;
  // Open service manager handle.
  SCManHandle := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if (SCManHandle > 0) then
  begin
    SvcHandle := OpenService(SCManHandle, 'FirebirdServerDefaultInstance', SERVICE_QUERY_STATUS);
    // if Service installed
    if (SvcHandle > 0) then
    begin
      if QueryServiceConfig(SvcHandle, sq, 0, lNeeds) then
        Result := sq.lpBinaryPathName;
      // SS structure holds the service status (TServiceStatus);
//      if (QueryServiceStatus(SvcHandle, SS)) then
//        dwStat := ss.dwCurrentState;
      CloseServiceHandle(SvcHandle);
    end;
    CloseServiceHandle(SCManHandle);
  end;
//  Result := dwStat;
}
var
  hSCManager,hSCService: SC_Handle;
  lpServiceConfig: PQueryServiceConfigW;
  nSize, nBytesNeeded: DWord;
begin
  Result := '';
  hSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if (hSCManager > 0) then
  begin
    hSCService := OpenService(hSCManager, PChar('FirebirdServerDefaultInstance'), SERVICE_QUERY_CONFIG);
    if (hSCService > 0) then
    begin
      QueryServiceConfig(hSCService, nil, 0, nSize);
      lpServiceConfig := AllocMem(nSize);
      try
        if not QueryServiceConfig(
          hSCService, lpServiceConfig, nSize, nBytesNeeded) Then Exit;
          Result := lpServiceConfig^.lpBinaryPathName;
      finally
        Dispose(lpServiceConfig);
      end;
      CloseServiceHandle(hSCService);
    end;
  end;


  REsult := ExtractFilePath(Result).Replace('"', '');

end;

initialization
  uLmxInterfacesRegister.RegisterInterface.Conexoes.RegistrarConexao
    (TLmxConexaoFirebird, 'Banco de Dados Firebird');

end.
