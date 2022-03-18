unit uLmxConexao;

interface

uses
  SysUtils, DBClient, DBXCommon, uLmxDataSet, Generics.Collections,
  uLmxControleConexao, DB, {$IFDEF VER270}System.Classes{$ELSE}Classes{$ENDIF},
  uLmxInterfaces;

type

  TLmxConexao = class
  private
    FConnection : ILmxConnection;
    FOnQueryExecute: TOnQueryExecute;
    FControleConexao : TLmxControleConexao;
//    FDataBase: string;
//    FUser_Name: string;
//    FPassword: string;
//    FHostName: string;
  protected
    function DoBackup(const ANomeArquivoBackup : string) : Boolean; virtual; abstract;
    function GetDriverName : string; virtual; abstract;
    function DoGetScripts(const AScript : string; const AScripts : TStringList) : Boolean; virtual;
    function DoScriptCriarTabela(const ATabela : string; const ACampos : string) : string; virtual; abstract;
    function DoScriptCriarDataBase(const ADataBaseName : string) : string; virtual; abstract;
    function DoScriptTabelaExiste(const AConexao, ATabela : string) : string; virtual; abstract;
    function DoScriptAdicionarCampo(const ATabela, ANome, ATipo : string; const ANotNull : Boolean) : string; virtual; abstract;
    function DoScriptAlterarCampo(const ATabela, ANome, ATipo : string; const ANotNull : Boolean) : string; virtual; abstract;
    function DoScriptCampoExiste(const AConexao, ATabela, ANomeCampo : string) : string; virtual; abstract;
    function DoScriptCriarCampo(const ANome, ATipo : string; const ANotNull : Boolean; const APrimaryKey : Boolean = False) : string; virtual; abstract;
    function DoScriptCriarChavePrimaria(const ANome : string) : string; virtual; abstract;
    function DoScriptCriarChaveEstrangeira(const ANome, ATabelaReferencia, ACampoReferencia : string) : string; virtual; abstract;
    function DoScriptObterInfoTabela(const AConexao, ANome : string) : string; virtual; abstract;
    function DoScriptObterInfoDataBase(const AConexao : string; out ANomeCampoTabela : string) : string; virtual; abstract;
    function DoScriptObterInfoChaveEstrangeira(const AConexao, ANomeTabela : string) : string; virtual; abstract;
    function DoScriptObterInfoChavePrimaria(const AConexao, ANomeTabela : string) : string; virtual; abstract;
    function DoExecuteDirect(const ASQL : string) : Boolean; virtual;
    function DoConfigurarConexao(const AConexao : ILmxConnection) : Boolean; virtual;
    function DoScriptAdicionarChavePrimaria(const ATabela, ANome: string): string; virtual; abstract;
    function DoScriptAdicionarChaveEstrangeira(const ATabela, ANome, ATabelaReferencia, ACampoReferencia : string): string; virtual; abstract;
    function DoScriptNovoIndice(const ATabela, ANome, ACampos : string) : string; virtual; abstract;
    function DoScriptObterInfoIndices(const AConexao, ANomeTabela : string) : string; virtual; abstract;
    function DoScriptObterInfoCamposIndice(const AConexao, ANomeIndice : string) : string; virtual; abstract;
    function DoScriptGerarSequence(const ATabela: string; const ANome: string; const ANomeCampo : string): string; virtual; abstract;
    function DoScriptValorSequence(const ANome: string): string; virtual; abstract;
    function DoScriptObterInfoSequences(const AConexao, ANomeTabela : string) : string; virtual; abstract;

    function DoScriptProximaSequencia(const ATabela : string; const ACampo : string; const ACondicao : string = '') : string; virtual; abstract;

    function DoGetInfoCampoFromScript(const AScript : string; out ANome : string; out ATipo : string;
      out ATamanho, ADecimais : Integer; out ANotNull, AIsPrimaryKey : Boolean) : string; virtual; abstract;

    function DoGetDataSetInfoTabela(const ATabela : string; out ADataSet : TLmxDataSet) : Boolean; virtual;

    function DoDataBaseExiste(const AConexao : string) : Boolean; virtual; abstract;
    function DoGetExisteInstalacao : Boolean; virtual;

    procedure DoGetTamanhoCampoFromString(const AScript : string; out ATamanho, ADecimais : Integer); virtual;
    procedure DoGetInfoIndexFromString(const AScript : string; out ACampos : string); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    property Connection : ILmxConnection read FConnection;

    property ControleConexao : TLmxControleConexao read FControleConexao;

    function GetScripts(const AScript : string; const AScripts : TStringList) : Boolean;
    function GetScriptNovoIndice(const ATabela, ANome, ACampos : string) : string;
    function GetScriptGerarTabela(const ATabela : string; const ACampos : string) : string;
    function GetScriptCriarDataBase(const ADataBaseName : string) : string;
    function DataBaseExiste(const AConexao : string) : Boolean;
    function GetScriptTabelaExiste(const AConexao, ATabela : string) : string;
    function GetScriptAdicionarCampo(const ATabela, ANome, ATipo : string; const ANotNull : Boolean) : string;
    function GetScriptAlterarCampo(const ATabela, ANome, ATipo : string; const ANotNull : Boolean) : string;
    function GetScriptCampoExiste(const AConexao, ATabela, ANomeCampo : string) : string;
    function GetScriptCriarCampo(const ANome, ATipo : string; const ANotNull : Boolean; const APrimaryKey : Boolean = False) : string;
    function GetScriptCriarChavePrimaria(const ANome : string) : string;
    function GetScriptCriarChaveEstrangeira(const ANome, ATabelaReferencia, ACampoReferencia : string) : string;
    function GetScriptObterInfoTabela(const AConexao, ANome : string) : string;
    function GetScriptObterInfoDataBase(const AConexao : string; out ANomeCampoTabela : string) : string;
    function GetScriptObterInfoChaveEstrangeira(const AConexao, ANomeTabela : string) : string;
    function GetScriptObterInfoIndices(const AConexao, ANomeTabela : string) : string;
    function GetScriptObterInfoCamposIndice(const AConexao, ANomeIndice : string) : string;
    function GetScriptObterInfoChavePrimaria(const AConexao, ANomeTabela : string) : string;
    function GetScriptAdicionarChavePrimaria(const ATabela, ANome: string): string;
    function GetScriptAdicionarChaveEstrangeira(const ATabela, ANome, ATabelaReferencia, ACampoReferencia : string): string;
    function GetScriptObterInfoSequences(const AConexao, ANomeTabela : string) : string;

    function GetScriptNovoSequence(const ATabela, ANome, ACampo : string) : string;

    function GetDataSetInfoTabela(const ATabela : string; out ADataSet : TLmxDataSet) : Boolean;
    function GetInfoCampoFromScript(const AScript : string; out ANome : string; out ATipo : string;
      out ATamanho, ADecimais : Integer; out ANotNull, AIsPrimaryKey : Boolean) : string;


    function GetCampoBoolean : string; virtual;
    function GetCampoChar(const ATamanho : Integer) : string; virtual;
    function GetCampoInteger : string; virtual;
    function GetCampoString(const ATamanho : Integer) : string; virtual;
    function GetCampoNumerico(const ATamanho, ADigitos : Integer) : string; virtual;
    function GetCampoDateTime : string; virtual;
    function GetCampoBlob(const ABinario : Boolean; const ATamanho : Integer) : string; virtual;

    function GetValueAsDateTime(const AData : TDateTime) : string; virtual;
    function GetValueAsDate(const AData : TDateTime) : string; virtual;

    function ProximaSequencia(const AScriptProximaSequencia : string) : Integer; overload;
    function ProximaSequencia(const ATabela, ACampo : string; const ACondicao : string = '') : Integer; overload;

    function ProximaSequenciaUsandoSequenciador(const ASequenciador : string) : Integer;

    function NovaConsulta(const ASQL : string; out AConsulta : TLmxDataSet; const AParams : ILmxParamsSql = nil) : Boolean; overload;
    function NovaConsulta(const ADataSet : TClientDataSet; out AConsulta : TLmxDataSet) : Boolean; overload;
    function NovaConsulta(const AGerador : ILmxGeradorConsulta; out AConsulta : TLmxDataSet; const AParams : ILmxParamsSql = nil) : Boolean; overload;
    function NovaConsulta(const AGerador : ILmxGeradorConsulta; out AConsulta : TLmxDataSet; const pFiltro : string) : Boolean; overload;
    function NovaConsulta(const ASQL : string; out AConsulta : TLmxDataSet; const pFiltro : string) : Boolean; overload;
    property OnQueryExecute : TOnQueryExecute read FOnQueryExecute write FOnQueryExecute;
    function ExecuteDirect(const ASQL : string) : Boolean;
    function Executar(const ASQL : string; const AParams: ILmxParamsSql = nil) : Integer;
    function ExisteRegistro(const ASQL : String) : Boolean;

    function Backup(const ANomeArquivoBackup : string) : Boolean;

    procedure ConfigurarConexao(const AControleConexao : TLmxControleConexao = nil); virtual;

    function ExisteInstalacao : Boolean; virtual;
  end;

  TLmxConexaoClass = class of TLmxConexao;

  TLmxConexaoInfo = class
  private
    FDescricao: string;
    FClasse: TLmxConexaoClass;
  public
    property Descricao : string read FDescricao write FDescricao;
    property Classe : TLmxConexaoClass read FClasse write FClasse;
  end;

  TLmxConexaoList = class(TObjectDictionary<TLmxConexaoClass,TLmxConexaoInfo>);


  function ConexaoPadraoRegistrada : Boolean;
  function LmxConexao : TLmxConexao;
  procedure RegistrarConexao(const AConexao : TLmxConexaoClass; const AControleConexao : TLmxControleConexao);
  procedure DesregistrarConexao;

  procedure RegistrarDriverConexao(const ADriverConexao : ILmxConnection);


implementation

var
  FDriverConexao : ILmxConnection;
  FConexao : TLmxConexao;

function ConexaoPadraoRegistrada : Boolean;
begin
  Result := (FConexao <> nil);
end;

procedure RegistrarDriverConexao(const ADriverConexao : ILmxConnection);
begin
  FDriverConexao := ADriverConexao;
end;

procedure RegistrarConexao(const AConexao : TLmxConexaoClass; const AControleConexao : TLmxControleConexao);
begin
  if AConexao = nil then
    raise Exception.Create('Classe de conexao nao encontrada !');
  if FConexao = nil then
  begin
     FConexao := AConexao.Create;
     FConexao.ConfigurarConexao(AControleConexao);
  end;
end;

procedure DesregistrarConexao;
begin
  if FConexao <> nil then
    FreeAndNil(FConexao);
end;

function LmxConexao : TLmxConexao;
begin
  if FDriverConexao = nil then
    raise Exception.Create('Driver de conexão não registrado. Você deve registrar um driver de conexão para continuar !');
  if FConexao = nil then
    raise Exception.Create('Conexao padrao nao instanciada. Voce deve registrar uma conexao para continuar !');
  Result := FConexao;
end;

{ TLmxConexao }

function TLmxConexao.Backup(const ANomeArquivoBackup: string): Boolean;
begin
  Result := DoBackup(ANomeArquivoBackup);
end;

procedure TLmxConexao.ConfigurarConexao(const AControleConexao : TLmxControleConexao);
begin
  if AControleConexao <> nil then
    FControleConexao.FromOther(AControleConexao);

  FConnection.ConnectionName                  := FControleConexao.DataBase;
  FConnection.Params.Values['HostName']       := FControleConexao.HostName;
  FConnection.Params.Values['Database']       := FControleConexao.DataBase;
  FConnection.Params.Values['User_Name']      := FControleConexao.User_Name;
  FConnection.Params.Values['Password']       := FControleConexao.Password;

  DoConfigurarConexao(FConnection);
end;

constructor TLmxConexao.Create;
begin
  FControleConexao := TLmxControleConexao.Create;

  if FDriverConexao = nil then
    raise Exception.Create('Driver de conexão não registrado. Você deve registrar um driver de conexão para continuar !. Exemplo (  uLmxConexao.RegistrarDriverConexao(TLmxDriverConexaoFireDac.Create(nil)); )');

  FConnection := FDriverConexao; // TSQLConnection.Create(nil);
  FConnection.DriverName := GetDriverName;
//  FSQLConnection.KeepConnection := False;
//  FSQLConnection.LoginPrompt := False;
end;

destructor TLmxConexao.Destroy;
begin
  FreeAndNil(FControleConexao);
  if FConnection <> nil then
  begin
    try
      FConnection.CloseDataSets;
      FConnection.Close;
    except

    end;
  //  FConnection := nil;
//    FreeAndNil(FSQLConnection);
  end;
  inherited;
end;

function TLmxConexao.DoConfigurarConexao(
  const AConexao: ILmxConnection): Boolean;
begin
  Result := True;
end;

function TLmxConexao.DoExecuteDirect(const ASQL: string): Boolean;
begin
  Result := False;
end;

function TLmxConexao.DoGetDataSetInfoTabela(const ATabela: string;
  out ADataSet: TLmxDataSet): Boolean;
begin
  Result := False;
  ADataSet := nil;
end;

function TLmxConexao.DoGetExisteInstalacao: Boolean;
begin
  Result := False;
end;

procedure TLmxConexao.DoGetInfoIndexFromString(const AScript: string;
  out ACampos: string);
var
  lPosicaoInicioTipo: Integer;
  lPosicaoFinalTipo: Integer;
  lScript: string;
  lPosicaoFinalCampos: Integer;
begin


  //CREATE INDEX `IDX_TESTE` ON `TESTE` (`CODIGO` ASC)

  ACampos  := '';
  lScript := AScript;

  if lScript <> '' then
  begin
    lScript := StringReplace(lScript, '`', '', [rfReplaceAll]);
    lPosicaoInicioTipo := Pos('(', lScript);
    lPosicaoFinalTipo := Pos(')', lScript);

    if lPosicaoInicioTipo > 0 then
      ACampos  := Copy(lScript, lPosicaoInicioTipo + 1, (lPosicaoFinalTipo - lPosicaoInicioTipo - 1));

    lPosicaoFinalCampos := Pos(' ', ACampos);
    if lPosicaoFinalCampos > 0 then
      ACampos  := Copy(ACampos, 1, lPosicaoFinalCampos - 1);
  end;

end;

function TLmxConexao.DoGetScripts(const AScript: string;
  const AScripts: TStringList): Boolean;
begin
  AScripts.LineBreak := sLineBreak;
  AScripts.Text := AScript;
  Result := True;
end;

procedure TLmxConexao.DoGetTamanhoCampoFromString(const AScript: string;
  out ATamanho, ADecimais: Integer);
var
  lTipo: string;
  lPosicaoInicioTipo: Integer;
  lPosicaoFinalTipo: Integer;
  lTamanho: Integer;
  lDecimais: Integer;
  lPosicaoDecimalTipo: Integer;
begin
  lTamanho := 0;
  lDecimais := 0;

  if AScript <> '' then
  begin
    lTipo := AScript;
    lPosicaoInicioTipo := Pos('(', lTipo);
    lPosicaoFinalTipo := Pos(')', lTipo);

    lTamanho := 0;
    lDecimais := 0;

    if lPosicaoInicioTipo > 0 then
    begin
      lPosicaoDecimalTipo := Pos(',', lTipo);
      if lPosicaoDecimalTipo > 0 then
      begin
        lDecimais := StrToIntDef(Copy(lTipo, lPosicaoDecimalTipo, (lPosicaoFinalTipo - lPosicaoDecimalTipo)), 0);
        lTamanho := StrToIntDef(Copy(lTipo, lPosicaoInicioTipo, (lPosicaoDecimalTipo - lPosicaoInicioTipo)), 0);
      end else begin
        lDecimais := 0;
        lTamanho  := StrToIntDef(Copy(lTipo, lPosicaoInicioTipo + 1, (lPosicaoFinalTipo - lPosicaoInicioTipo - 1)), 0);
      end;
    end;
  end;

  ATamanho := lTamanho;
  ADecimais := lDecimais;

end;

function TLmxConexao.Executar(const ASQL: string; const AParams: ILmxParamsSql): Integer;
var
  lSQLExecute : ILmxDataSet;
  lConexao: ILmxConnection;
begin
  lSQLExecute := FConnection.NewDataSet(nil);
  try
    lSQLExecute.DisableControls;
    lConexao := FConnection.CloneConnection;
    lSQLExecute.Connection := lConexao;
    lSQLExecute.CommandText := ASQL;
    lSQLExecute.SetParams(AParams);
    if Assigned(OnQueryExecute) then
      OnQueryExecute(teqExecute, ASQL, '', 0);
    Result := lSQLExecute.ExecSQL;
    lSQLExecute.Close;
  finally
    lSQLExecute := nil;
    lConexao := nil;
  end;
end;

function TLmxConexao.ExecuteDirect(const ASQL: string): Boolean;
begin
  Result := DoExecuteDirect(ASQL);
end;

function TLmxConexao.ExisteInstalacao: Boolean;
begin
  Result := DoGetExisteInstalacao;
end;

function TLmxConexao.ExisteRegistro(const ASQL: String): Boolean;
var
  lDataSet: TLmxDataSet;
begin
  Result := False;
  if NovaConsulta(ASQL, lDataSet) then
  begin
    try
      lDataSet.Open;
      Result := (lDataSet.RecordCount > 0);
    finally
      FreeAndNil(lDataSet);
    end;
  end;
end;

function TLmxConexao.GetCampoBlob(const ABinario: Boolean;
  const ATamanho: Integer): string;
begin
  if ABinario then
    Result := 'BLOB SUB_TYPE 0 SEGMENT SIZE ' + IntToStr(ATamanho)
  else
    Result := 'BLOB SUB_TYPE 1 SEGMENT SIZE ' + IntToStr(ATamanho);
end;

function TLmxConexao.GetCampoBoolean: string;
begin
  Result := 'BOOLEAN';
end;

function TLmxConexao.GetCampoChar(const ATamanho : Integer): string;
begin
  Result := 'CHAR(' + IntToStr(ATamanho) + ')';
end;

function TLmxConexao.GetCampoDateTime: string;
begin
  Result := 'DATETIME';
end;

function TLmxConexao.GetInfoCampoFromScript(const AScript: string;
  out ANome: string; out ATipo: string; out ATamanho, ADecimais : Integer; out ANotNull, AIsPrimaryKey: Boolean): string;
begin
  Result := DoGetInfoCampoFromScript(AScript, ANome, ATipo, ATamanho, ADecimais, ANotNull, AIsPrimaryKey);
end;

function TLmxConexao.GetCampoInteger: string;
begin
  Result := 'INTEGER';
end;

function TLmxConexao.GetCampoNumerico(const ATamanho,
  ADigitos: Integer): string;
begin
  Result := 'NUMERIC(' + IntToStr(ATamanho) + ',' + IntToStr(ADigitos) + ')';
end;

function TLmxConexao.GetCampoString(const ATamanho: Integer): string;
begin
  Result := 'VARCHAR(' + IntToStr(ATamanho) + ')';
end;

function TLmxConexao.GetDataSetInfoTabela(const ATabela: string;
  out ADataSet: TLmxDataSet): Boolean;
begin
  Result := DoGetDataSetInfoTabela(ATabela, ADataSet);
end;

function TLmxConexao.GetScriptAdicionarCampo(const ATabela, ANome,
  ATipo: string; const ANotNull: Boolean): string;
begin
  Result := DoScriptAdicionarCampo(ATabela, ANome, ATipo, ANotNull);
end;

function TLmxConexao.GetScriptAdicionarChaveEstrangeira(const ATabela, ANome,
  ATabelaReferencia, ACampoReferencia: string): string;
begin
  Result := DoScriptAdicionarChaveEstrangeira(ATabela, ANome, ATabelaReferencia, ACampoReferencia);
end;

function TLmxConexao.GetScriptAdicionarChavePrimaria(const ATabela,
  ANome: string): string;
begin
  Result := DoScriptAdicionarChavePrimaria(ATabela, ANome);
end;

function TLmxConexao.GetScriptAlterarCampo(const ATabela, ANome, ATipo: string;
  const ANotNull: Boolean): string;
begin
  Result := DoScriptAlterarCampo(ATabela, ANome, ATipo, ANotNull);
end;

function TLmxConexao.GetScriptCampoExiste(const AConexao, ATabela,
  ANomeCampo: string): string;
begin
  Result := DoScriptCampoExiste(AConexao, ATabela, ANomeCampo);
end;

function TLmxConexao.GetScriptCriarCampo(const ANome, ATipo: string;
  const ANotNull: Boolean; const APrimaryKey : Boolean): string;
begin
  Result := DoScriptCriarCampo(ANome, ATipo, ANotNull, APrimaryKey);
end;

function TLmxConexao.GetScriptCriarChaveEstrangeira(const ANome,
  ATabelaReferencia, ACampoReferencia: string): string;
begin
  Result := DoScriptCriarChaveEstrangeira(ANome, ATabelaReferencia, ACampoReferencia);
end;

function TLmxConexao.GetScriptCriarChavePrimaria(const ANome: string): string;
begin
  Result := DoScriptCriarChavePrimaria(ANome);
end;

function TLmxConexao.GetScriptCriarDataBase(
  const ADataBaseName: string): string;
begin
  Result := DoScriptCriarDataBase(ADataBaseName);
end;

function TLmxConexao.DataBaseExiste(const AConexao: string): Boolean;
begin
  Result := DoDataBaseExiste(AConexao);
end;

function TLmxConexao.GetScriptGerarTabela(const ATabela,
  ACampos: string): string;
begin
  Result := DoScriptCriarTabela(ATabela, ACampos);
end;

function TLmxConexao.GetScriptNovoIndice(const ATabela, ANome,
  ACampos: string): string;
begin
  Result := DoScriptNovoIndice(ATabela, ANome, ACampos);
end;

function TLmxConexao.GetScriptNovoSequence(const ATabela, ANome,
  ACampo: string): string;
begin
  Result := DoScriptGerarSequence(ATabela, ANome, ACampo);
end;

function TLmxConexao.GetScriptObterInfoCamposIndice(const AConexao,
  ANomeIndice: string): string;
begin
  Result := DoScriptObterInfoCamposIndice(AConexao, ANomeIndice);
end;

function TLmxConexao.GetScriptObterInfoChaveEstrangeira(const AConexao,
  ANomeTabela: string): string;
begin
  Result := DoScriptObterInfoChaveEstrangeira(AConexao, ANomeTabela);
end;

function TLmxConexao.GetScriptObterInfoChavePrimaria(const AConexao,
  ANomeTabela: string): string;
begin
  Result := DoScriptObterInfoChavePrimaria(AConexao, ANomeTabela);
end;

function TLmxConexao.GetScriptObterInfoDataBase(const AConexao: string; out ANomeCampoTabela : string): string;
begin
  Result := DoScriptObterInfoDataBase(AConexao, ANomeCampoTabela);
  if ANomeCampoTabela = '' then
    ANomeCampoTabela := 'NomeTabela';
end;

function TLmxConexao.GetScriptObterInfoIndices(const AConexao,
  ANomeTabela: string): string;
begin
  Result := DoScriptObterInfoIndices(AConexao, ANomeTabela);
end;

function TLmxConexao.GetScriptObterInfoSequences(const AConexao,
  ANomeTabela: string): string;
begin
  Result := DoScriptObterInfoSequences(AConexao, ANomeTabela);
end;

function TLmxConexao.GetScriptObterInfoTabela(const AConexao, ANome: string): string;
begin
  Result := DoScriptObterInfoTabela(AConexao, ANome);
end;

function TLmxConexao.GetScripts(const AScript: string;
  const AScripts: TStringList): Boolean;
begin
  Result := DoGetScripts(AScript, AScripts);
end;

function TLmxConexao.GetScriptTabelaExiste(const AConexao, ATabela: string): string;
begin
  Result := DoScriptTabelaExiste(AConexao, ATabela);
end;

function TLmxConexao.GetValueAsDate(const AData: TDateTime): string;
begin
  Result := QuotedStr(FormatDateTime('yyyy.mm.dd 00:00:00', AData));
end;

function TLmxConexao.GetValueAsDateTime(const AData: TDateTime): string;
begin
  Result := QuotedStr(FormatDateTime('yyyy.mm.dd hh:nn:ss', AData));
end;

function TLmxConexao.NovaConsulta(const ASQL: string;
  out AConsulta: TLmxDataSet; const pFiltro: string): Boolean;
var
  lFiltro: string;
begin
  AConsulta := TLmxDataSet.Create(nil);
  try
    AConsulta.OnQueryExecute := FOnQueryExecute;
    AConsulta.Build(FConnection, ASQL, nil);
   if pFiltro <> '' then
    begin
      AConsulta.Refresh('0<>0');
      lFiltro := AConsulta.LocalFilter(pFiltro);
      AConsulta.Refresh(lFiltro);
    end else
      AConsulta.Open;
    Result := True;
  except
    FreeAndNil(AConsulta);
    {$IFDEF NOGUI}
    raise;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

function TLmxConexao.NovaConsulta(const AGerador: ILmxGeradorConsulta;
  out AConsulta: TLmxDataSet; const AParams: ILmxParamsSql): Boolean;
begin
  AConsulta := TLmxDataSet.Create(nil);
  try
    AConsulta.OnQueryExecute := FOnQueryExecute;
    AConsulta.Build(FConnection, AGerador, AParams);
    AConsulta.SetGerador(AGerador);
    AConsulta.Open;
    Result := True;
  except
    FreeAndNil(AConsulta);
    {$IFDEF NOGUI}
    raise;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

function TLmxConexao.NovaConsulta(const ASQL: string;
  out AConsulta: TLmxDataSet; const AParams : ILmxParamsSql): Boolean;
begin
  AConsulta := TLmxDataSet.Create(nil);
  try
    AConsulta.OnQueryExecute := FOnQueryExecute;
    AConsulta.Build(FConnection, ASQL, AParams);
    AConsulta.Open;
    Result := True;
  except
    FreeAndNil(AConsulta);
    {$IFDEF NOGUI}
    raise;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

function TLmxConexao.NovaConsulta(const ADataSet: TClientDataSet;
  out AConsulta: TLmxDataSet): Boolean;
begin
  AConsulta := TLmxDataSet.Create(nil);
  try
    AConsulta.OnQueryExecute := FOnQueryExecute;
    AConsulta.Build(ADataSet);
    AConsulta.Open;
    Result := True;
  except
    FreeAndNil(AConsulta);
    {$IFDEF NOGUI}
    raise;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

function TLmxConexao.ProximaSequencia(
  const AScriptProximaSequencia: string): Integer;
var
  lConsulta : ILmxQuery;
  lConexao: ILmxConnection;
begin
  Result := 0;
  lConsulta := Self.FConnection.NewQuery(nil);
  try
    lConsulta.DisableControls;
    lConexao := FConnection.CloneConnection;
    lConsulta.Connection:= lConexao;
    lConsulta.SQL.Add(AScriptProximaSequencia);
    lConsulta.Open;

    if not lConsulta.IsEmpty then
      Result := lConsulta.Fields[0].AsInteger;
    Result := Result + 1;
  finally
    lConsulta := nil;
    lConexao := nil;
  end;
end;

function TLmxConexao.ProximaSequencia(const ATabela, ACampo,
  ACondicao: string): Integer;
begin
  Result := ProximaSequencia(DoScriptProximaSequencia(ATabela, ACampo, ACondicao));
end;

function TLmxConexao.ProximaSequenciaUsandoSequenciador(
  const ASequenciador: string): Integer;
var
  lConsulta : ILmxQuery;
  lConexao: ILmxConnection;
begin
  lConsulta := Self.FConnection.NewQuery(nil);
  try
    lConsulta.DisableControls;
    lConexao := FConnection.CloneConnection;
    lConsulta.Connection:= lConexao;
    lConsulta.SQL.Add(DoScriptValorSequence(ASequenciador));
    lConsulta.Open;
    Result := lConsulta.Fields[0].AsInteger;
  finally
    lConsulta := nil;
    lConexao := nil;
  end;
end;

function TLmxConexao.NovaConsulta(const AGerador: ILmxGeradorConsulta;
  out AConsulta: TLmxDataSet; const pFiltro: string): Boolean;
var
  lFiltro: string;
begin
  AConsulta := TLmxDataSet.Create(nil);
  try
    AConsulta.OnQueryExecute := FOnQueryExecute;
    AConsulta.Build(FConnection, AGerador, nil);
    AConsulta.SetGerador(AGerador);
    if pFiltro <> '' then
    begin
      AConsulta.Refresh('0<>0');
      lFiltro := AConsulta.LocalFilter(pFiltro);
      AConsulta.Refresh(lFiltro);
    end else
      AConsulta.Open;
    Result := True;
  except
    FreeAndNil(AConsulta);
    {$IFDEF NOGUI}
    raise;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

initialization

finalization
  if FConexao <> nil then
    FreeAndNil(FConexao);


end.
