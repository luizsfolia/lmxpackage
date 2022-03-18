unit uLmx.Model.Usuario;

interface


uses
  uLmxCore, uLmxAttributes, System.Math, Generics.Collections, System.Classes;

type

  TTipoUsuario = (tuUsuarioNormal, tuAdministrador);

  [TLmxAttributeMetadata]
  TUsuario = class(TBaseTabelaPadrao)
  private
    FEmail: string;
    FSenha: string;
    FLogin: string;
    FNome: string;
    FIsAssessor: Boolean;
    FTipoUsuario: TTipoUsuario;
  public
    [TLmxAttributeMetadata(100)]
    property Nome : string read FNome write FNome;
    [TLmxAttributeMetadata(100)]
    property Email : string read FEmail write FEmail;
    [TLmxAttributeMetadata(100)]
    property Login : string read FLogin write FLogin;
    [TLmxAttributeMetadata(100)]
    property Senha : string read FSenha write FSenha;
    [TLmxAttributeMetadata]
    property IsAssessor : Boolean read FIsAssessor write FIsAssessor;
    [TLmxAttributeMetadata]
    property TipoUsuario : TTipoUsuario read FTipoUsuario write FTipoUsuario;

    function IsAdmin : Boolean;
  end;

  TUsuarios = class(TBaseList<TUsuario>)
  public
    function GetByNome(const pNome : string) : TUsuario;
  end;

implementation

{ TUsuarios }

function TUsuarios.GetByNome(const pNome: string): TUsuario;
var
  lUsuario: TUsuario;
begin
  Result := nil;
  for lUsuario in Self do
  begin
    if (Result = nil) and (lUsuario.Nome = pNome) then
      Result := lUsuario;
  end;
end;

{ TUsuario }

function TUsuario.IsAdmin: Boolean;
begin
  Result := FTipoUsuario = tuAdministrador;
end;

end.
