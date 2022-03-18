program ExemploServerOrmVcl;

uses
  Vcl.Forms,
  uServerPrincipal in 'uServerPrincipal.pas' {Form1},
  uLmx.Context.Usuario in 'context\uLmx.Context.Usuario.pas',
  uLmx.Http.Usuario in 'http\uLmx.Http.Usuario.pas',
  uLmx.Model.Usuario in 'modelo\uLmx.Model.Usuario.pas',
  uLmx.Server in 'uLmx.Server.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
