unit uLmx.Server;

interface

uses
  ActiveX,
  System.SysUtils, IdCustomHTTPServer,
  uLmxHelper,
  uLmxInterfaces,
  uLmxHttpServer,
  uLmxCmd,
  uLmxMetaData,
  uLmxInterfacesRegister,
  uLmxConexao,
  // Context
  uLmx.Context.Usuario,
  // Model
  uLmx.Model.Usuario,
  // Http
  uLmx.Http.Usuario,
  uLmx.Service.DataBase,
  uLmxConexaoFirebird;


type


  TLmxServer = class
  private
    class var FFinServer : TLmxServer;
  private
    FServer : TLmxHttpServer;

    procedure OnErroComando(const AComando : TLmxInfoComandoServidor; const pErro : string; const pDataBase : string);
    procedure OnAlterarBancoDados(const ATabela : string; const AAlteracoes : string);
    procedure OnProcessarComando(const AComando : TLmxInfoComandoServidor; const AInfoComandoRodado : TLmxInfoComandoProcessadoNoServidor);
  public
    procedure RegistrarMiddleWares;
    procedure RegistrarServices;
    procedure RegistrarDefaults;

    procedure RegistrarDataBase;
    procedure RegistrarConsultas;

    procedure RegistrarComandos;

    constructor Create;
    destructor Destroy; override;

    class constructor Create;
    class destructor Destroy;

    procedure SetOnProcessarComando(const pOnProcessarComandoRef : TLmxHttpOnProcessarComandoRef);
    procedure SetOnErroComando(const pOnErroComandoRef : TLmxHttpOnErroComandoRef);
    procedure SetOnAlterarBancoDados(const pOnAlterarBancoDadosRef : TLmxOnAlteracaoDataBaseRef);
    procedure SetOnExecuteQuery(const pOnExecuteQuery : TContextQueryExecute);

    procedure Ativar(const pPorta : Integer; const pPortaHttps : Integer = 0);
    procedure Fechar;

    function Ativo : Boolean;
    function GetServidores : string;

    class function Default : TLmxServer;
  end;


implementation

uses
  uLmxComando, uLmxControleConexao, uLmxDriverConexaoFireDac;

{ TLmxServer }

procedure TLmxServer.Ativar(const pPorta: Integer; const pPortaHttps: Integer);
begin
  FServer.Ativar(pPorta, False, pPortaHttps);
end;

function TLmxServer.Ativo: Boolean;
begin
  Result := FServer.Ativo;
end;

class constructor TLmxServer.Create;
begin
  FFinServer := TLmxServer.Create;
end;

constructor TLmxServer.Create;
begin
  Coinitialize(nil);
  FServer := TLmxHttpServer.Create;
  FServer.OnErroComando := OnErroComando;
  FServer.OnProcessarComando := OnProcessarComando;
end;

class function TLmxServer.Default: TLmxServer;
begin
  Result := TLmxServer.FFinServer;
end;

destructor TLmxServer.Destroy;
begin
  FServer.Free;
  CoUninitialize;
end;

class destructor TLmxServer.Destroy;
begin
  FFinServer.Free;
end;

procedure TLmxServer.Fechar;
begin
  FServer.Desativar;
end;

function TLmxServer.GetServidores: string;
begin
  Result := FServer.Enderecos.Text;
end;

procedure TLmxServer.OnAlterarBancoDados(const ATabela, AAlteracoes: string);
begin
  {$IFDEF CONSOLE}
  uLmxCmd.LmxCommandLine.Escrever('BD : ' + ATabela + ' - ' + AAlteracoes , True, cpcVerdeAgua);
  {$ENDIF}
end;

procedure TLmxServer.OnErroComando(const AComando: TLmxInfoComandoServidor;
  const pErro, pDataBase: string);
begin
  {$IFDEF CONSOLE}
  uLmxCmd.LmxCommandLine.Escrever(pErro, True, cpcVermelho);
  {$ENDIF}
end;

procedure TLmxServer.OnProcessarComando(
  const AComando: TLmxInfoComandoServidor;
  const AInfoComandoRodado: TLmxInfoComandoProcessadoNoServidor);
begin
  {$IFDEF CONSOLE}
  if (AComando <> nil) and (AComando.RequestInfo <> nil) then
    uLmxCmd.LmxCommandLine.Escrever(AComando.RequestInfo.URI + ' Params : ' + AComando.RequestInfo.Params.Text, True, cpcCinza);
//  if AInfoComandoRodado <> nil then
//    uLmxCmd.LmxCommandLine.Escrever(AInfoComandoRodado.ResposneInfo.ContentText, True, cpcCinza);
  {$ENDIF}
end;

procedure TLmxServer.RegistrarComandos;
begin
  FServer.AdicionarComando(THttpUsuario, '/Usuarios');
  FServer.AdicionarComando(THttpTesteArquivo, '/Arquivo');
end;

procedure TLmxServer.RegistrarConsultas;
begin

end;

procedure TLmxServer.RegistrarDataBase;
var
  lConexao: TLmxConexaoFirebird;
begin
  uLmxConexao.RegistrarDriverConexao(TLmxDriverConexaoFireDac.Create(nil));

  // Registros de Tabelas
  RegisterInterface.Tabelas.Registrar(TUsuario, 'Usuario');


  TContextDataBaseConfig.Default.RegistrarConexao(TLmxConexaoFirebird,
    procedure (const pControleConexao : TLmxControleConexao)
    begin
      pControleConexao.HostName := 'localhost';
      pControleConexao.DataBase :=  'c:\tmp\Database\lmxteste.FDB';
      pControleConexao.ClasseDriver := TLmxConexaoFirebird.ClassName;
      pControleConexao.User_Name := 'sysdba';
      pControleConexao.Password := 'masterkey';

      // Criação / Atualização do Banco de Dados
      lConexao := TLmxConexaoFirebird.Create;
      try
        lConexao.ConfigurarConexao(pControleConexao);

        LmxMetadata.SetConexao(lConexao);
        LmxMetadata.ExecutarNoBancoDeDados := True;
        LmxMetadata.OnAlteracaoDataBaseEvent := OnAlterarBancoDados;
        LmxMetadata.CriarDataBase;

        if (not LmxMetadata.TemTelaRegistrada) then
          LmxMetadata.AtualizarTabelasRegistradas;
      finally
        lConexao.Free;
      end;

    end);


//  uLmxConexao.RegistrarConexao(TLmxDriverConexaoFireDac.Create(nil));

end;

procedure TLmxServer.RegistrarDefaults;
begin
end;

procedure TLmxServer.RegistrarMiddleWares;
begin
  FServer.AdicionarMiddleWare(
    procedure ( const AComando : TLmxServerComand;const AInfoComando : TLmxInfoComandoServidor;
      const AResponseInfo : TIdHTTPResponseInfo; const ARota : string; const Next : TProc)
    var
      lValorToken: string;
      lUsuario: TUsuario;
    begin
      if AInfoComando.TentarObterValorHeader('Token', lValorToken) then
      begin
        lUsuario := TUsuario.Create;
        try
          lUsuario.FromJsonString(lValorToken);
          AComando.InfoAuth.CodUser := lUsuario.ID;
          AComando.InfoAuth.User := lUsuario.Login;
          AComando.InfoAuth.IsAdmin := (lUsuario.TipoUsuario = tuAdministrador);
//          AComando.

        finally
          lUsuario.Free;
        end;
      end;

      Next;
    end);

  FServer.AdicionarMiddleWare(
    procedure ( const AComando : TLmxServerComand;const AInfoComando : TLmxInfoComandoServidor;
      const AResponseInfo : TIdHTTPResponseInfo; const ARota : string; const Next : TProc)
    var
      lValor: string;
    begin
      AComando.InfoQuery.ResponseBuscarComoJson := True;

      if AInfoComando.TentarObterValorParametro('Limit', lValor) then
      begin
        AComando.InfoQuery.Limit := lValor.ToInteger;
      end;
      Next;
    end);

end;

procedure TLmxServer.RegistrarServices;
begin
  FServer.AdicionarService<IContextUsuario>(
    IContextUsuario,
    function : IContextUsuario
    begin
      Result := TContextUsuario.Create;
    end);
end;

procedure TLmxServer.SetOnAlterarBancoDados(
  const pOnAlterarBancoDadosRef: TLmxOnAlteracaoDataBaseRef);
begin
  LmxMetadata.SetOnAlteracaoDataBaseRef(pOnAlterarBancoDadosRef);
end;

procedure TLmxServer.SetOnErroComando(
  const pOnErroComandoRef: TLmxHttpOnErroComandoRef);
begin
  FServer.SetOnErroComando(pOnErroComandoRef);
end;

procedure TLmxServer.SetOnExecuteQuery(
  const pOnExecuteQuery: TContextQueryExecute);
begin
  TContextDataBaseConfig.Default.OnContextQueryExecute := pOnExecuteQuery;
end;

procedure TLmxServer.SetOnProcessarComando(
  const pOnProcessarComandoRef: TLmxHttpOnProcessarComandoRef);
begin
  FServer.SetOnProcessarComando(pOnProcessarComandoRef);
end;

end.
