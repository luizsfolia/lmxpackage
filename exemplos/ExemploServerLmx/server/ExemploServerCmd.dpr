program ExemploServerCmd;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uLmxHttp,
  uLmxCmd,
  uLmx.Server in 'uLmx.Server.pas',
  uLmx.Context.Usuario in 'context\uLmx.Context.Usuario.pas',
  uLmx.Http.Usuario in 'http\uLmx.Http.Usuario.pas',
  uLmx.Model.Usuario in 'modelo\uLmx.Model.Usuario.pas';

var
  FPortaHttp : Integer;
  FPortaHttps : Integer;

begin
  try

    uLmxCmd.LmxCommandLine.Escrever('Iniciando Server...');

//    ReportMemoryLeaksOnShutdown := True;

    FPortaHttp := LmxSystemParam.ValorParametroAsInteger('http');
    FPortaHttps := LmxSystemParam.ValorParametroAsInteger('https');

    if FPortaHttp = 0 then
      FPortaHttp := 8500;

    FormatSettings := TFormatSettings.Create(1046);

    uLmxCmd.LmxCommandLine.Escrever('Registrando comandos...');
    TLmxServer.Default.RegistrarComandos;
    TLmxServer.Default.RegistrarMiddleWares;
    TLmxServer.Default.RegistrarServices;
    LmxCommandLine.Escrever('Registrando DataBase...');
    TLmxServer.Default.RegistrarDataBase;
    uLmxCmd.LmxCommandLine.Escrever('Atualizando Registros...');
    TLmxServer.Default.RegistrarDefaults;
    TLmxServer.Default.Ativar(FPortaHttp, FPortaHttps);
    uLmxCmd.LmxCommandLine.Escrever('Server Http Ativo na porta 8500');
    uLmxCmd.LmxCommandLine.Escrever('Server Https Ativo na porta 8501');

    uLmxCmd.LmxCommandLine.Escrever('Voce pode tentar...', True, cpcVerde);
    uLmxCmd.LmxCommandLine.Escrever('http://localhost:' + FPortaHttp.ToString + '/Usuarios', True, cpcVerde);
    uLmxCmd.LmxCommandLine.Escrever('http://localhost:' + FPortaHttp.ToString + '/Usuarios/1', True, cpcVerde);

    if FPortaHttps > 0 then
    begin
      uLmxCmd.LmxCommandLine.Escrever('https://localhost:' + FPortaHttps.ToString + '/Usuarios', True, cpcVerde);
      uLmxCmd.LmxCommandLine.Escrever('https://localhost:' + FPortaHttps.ToString + '/Usuarios/1', True, cpcVerde);
    end;


    while True do
      Sleep(50000);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
