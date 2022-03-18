program ServerExemploSemOrm;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uLmxHttpServer,
  uModuloClientes in 'uModuloClientes.pas',
  uModeloCliente in 'uModeloCliente.pas';

var
  FServer : TLmxHttpServer;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }

    FServer := TLmxHttpServer.Create;
    FServer.AdicionarComando(TModuloCllientes, '/Clientes');
    FServer.Ativar(8500);

    while True do
      Sleep(50000);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
