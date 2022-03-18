unit uLmx.Context.Usuario;

interface


uses
  System.Classes, System.SysUtils, uLmxInterfaces,
  uLmx.Context.DataBase,
  Generics.Collections, uLmxHelper,
  uLmxCore,
  uLmx.Model.Usuario,
  uLmxComandoSql;

type

  IContextUsuario = interface(IContextDataBase<TUsuario>)
    ['{C783A57C-B5B6-42E8-A466-9075583DE035}']

    function ObterUsuarioPorLogin(const pUsuario : string): TUsuario;
    function ObterListaAssesores : TUsuarios;
  end;

  TLmxGeradorConsultaUsuario = class(TLmxGeradorConsulta)
  public
    procedure DoGerarConsulta; override;
  end;


  TContextUsuario = class(TContextDataBase<TUsuario>, IContextUsuario)
  protected
    function GetConsultaBuscar : ILmxGeradorConsulta; override;
  public
    function ObterUsuarioPorLogin(const pUsuario : string): TUsuario;
    function ObterListaAssesores : TUsuarios;
  end;

implementation

uses
  uLmxDataSet;

{ TContextUsuario }

function TContextUsuario.GetConsultaBuscar: ILmxGeradorConsulta;
begin
  Result := TLmxGeradorConsultaUsuario.GetConsulta;
end;

function TContextUsuario.ObterListaAssesores: TUsuarios;
var
  lConsulta: TLmxDataSet;
begin
  Result := TUsuarios.Create;

  if Self.ObterConexao.NovaConsulta('select * from usuario', lConsulta) then
  begin
    try
      Result.DeDataSet(lConsulta);
    finally
      lConsulta.Free;
    end;
  end;
end;

function TContextUsuario.ObterUsuarioPorLogin(const pUsuario: string): TUsuario;
var
  lConsulta: TLmxDataSet;
begin
  Result := TUsuario.Create;

  if Self.ObterConexao.NovaConsulta('select * from usuario where login = :login', lConsulta, TLmxParamsSql.Create.AddParam('login', pUsuario)) then
  begin
    try
      Result.CarregarDeDataSet(lConsulta);
    finally
      lConsulta.Free;
    end;
  end;
end;

{ TLmxGeradorConsultaUsuario }

procedure TLmxGeradorConsultaUsuario.DoGerarConsulta;
begin
  inherited;
  From('usuario');
  AddCampo('usuario', '*');
  AddCampoCalculado('0', 'teste');
end;

end.
