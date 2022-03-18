unit uLmx.Http.Usuario;

interface

uses
  uLmxHttpServer, uLmxHelper, uLmxAttributes, uLmx.Context.Usuario, uLmx.Model.Usuario,
  uLmx.Http.Base, System.Classes, IOUtils, uLmxCore;

type

  THttpTesteArquivo = class(TLmxServerComand)
  public
    [HttpGet]
    [TLmxAttributeComando('')]
    function TesteArquivo([FromServices] pContext : IContextUsuario) : ILmxRetornoArquivo;
  end;


  THttpUsuario = class(THttp<TUsuario,IContextUsuario,TBaseList<TUsuario>>)
  public
    [HttpGet]
    [TLmxAttributeComando('/ObterListaAssesores')]
    function ObterListaAssesores (
      [FromServices]  pContext : IContextUsuario) : ILmxRetorno<TUsuarios>;

    [HttpGet]
    [TLmxAttributeComando('{id}/Assesores')]
    function AssesoresDoUsuario (
      [FromServices]  pContext : IContextUsuario) : ILmxRetorno<TUsuarios>;

    [HttpGet]
    [TLmxAttributeComando('{login}/Usuarios')]
    function UsuariosDoLogin (
      [FromParams] login : string;
      [FromServices]  pContext : IContextUsuario) : string;

  end;

implementation

uses
  System.SysUtils;

{ THttpUsuario }

function THttpUsuario.AssesoresDoUsuario(
  pContext: IContextUsuario): ILmxRetorno<TUsuarios>;
begin
  Result := TLmxRetorno<TUsuarios>.Create(pContext.ObterListaAssesores);
end;

function THttpUsuario.ObterListaAssesores(
  pContext: IContextUsuario): ILmxRetorno<TUsuarios>;
var
  lUsuario: TUsuario;
  lId: Integer;
begin
  lUsuario := TUsuario.Create;
  lUsuario.Nome := 'ricardo';

  pContext.Incluir(lUsuario, lId);
  Result := TLmxRetorno<TUsuarios>.Create(pContext.ObterListaAssesores);
end;

function THttpUsuario.UsuariosDoLogin(login: string;
  pContext: IContextUsuario): string;
var
  lLista: TBaseList<TUsuario>;
begin
  pContext.GetRequisicaoCliente.SetLimit(5);

  lLista := pContext.Lista;
  Result := login + ' - ' +
  pContext.GetRequisicaoCliente.GetLimit.ToString + ' - ' +
  lLista.ToJsonString;
  lLista.Free;
end;

{ THttpTesteArquivo }

function THttpTesteArquivo.TesteArquivo(pContext : IContextUsuario): ILmxRetornoArquivo;
begin
  Result := TLmxRetornoArquivo.Create;

  TFile.WriteAllText('c:\tmp\teste.txt', pContext.ObterListaAssesores.ToJsonString);

  Result.SetFileName('c:\tmp\teste.txt');
  Result.SetReturnFileName('Teste1223.json');
end;

end.
