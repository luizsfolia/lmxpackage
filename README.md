# lmxpackage

Versão atual 1.0.0

# Instalação

Não é nescessária nenhuma instalação, basta adicionar o caminho do repositório no path do Delphi

# boss

para usar no boss, basta instalar o boss e no seu projeto usar

boos init

boss install https://github.com/luizsfolia/lmxpackage.git

# Exemplos

Classe DataBaseExemplo

uses
  uLmxCore, uLmxAttributes, System.Math, Generics.Collections, System.Classes;

type

  TTipoUsuario = (tuUsuarioNormal, tuAdministrador);

  [TLmxAttributeMetadata]
  TUsuario = class(TBaseTabelaPadrao)
  private
    FEmail: string;
    FLogin: string;
    FNome: string;
    FTipoUsuario: TTipoUsuario;
  public
    [TLmxAttributeMetadata(100)]
    property Nome : string read FNome write FNome;
    [TLmxAttributeMetadata(100)]
    property Email : string read FEmail write FEmail;
    [TLmxAttributeMetadata(100)]
    property Login : string read FLogin write FLogin;
    [TLmxAttributeMetadata]
    property TipoUsuario : TTipoUsuario read FTipoUsuario write FTipoUsuario;

    function IsAdmin : Boolean;
  end;

  TUsuarios = class(TBaseList<TUsuario>);


Conexao com DataBase (Firebird)
  
    TContextDataBaseConfig.Default.RegistrarConexao(TLmxConexaoFirebird,
    procedure (const pControleConexao : TLmxControleConexao)
    begin
      pControleConexao.HostName := 'localhost';
      pControleConexao.DataBase :=  'c:\tmp\Database\lmxteste.FDB';
      pControleConexao.ClasseDriver := TLmxConexaoFirebird.ClassName;
      pControleConexao.User_Name := 'sysdba';
      pControleConexao.Password := 'masterkey';
    end
  
  
Criando/Atualizando DataBase  
  
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

  
  
Criando Server  HTTP
  
  FServer := TLmxHttpServer.Create;
  FServer.AdicionarComando(THttpUsuario, '/Usuarios');
  
Classe Exemplo Http
  
uses
  System.Classes, 
  uLmxHttpServer, uLmxHelper, uLmxAttributes, uLmx.Context.Usuario, uLmx.Model.Usuario,
  uLmx.Http.Base, uLmxCore;

type

  THttpUsuario = class(THttp<TUsuario,IContextUsuario,TBaseList<TUsuario>>);
  
Exemplo Context
  
uses
  System.Classes, 
  System.SysUtils, 
  Generics.Collections,
  uLmxInterfaces,
  uLmx.Context.DataBase,
  uLmxHelper,
  uLmxCore,
  uLmx.Model.Usuario;

type

  IContextUsuario = interface(IContextDataBase<TUsuario>)
    ['{C783A57C-B5B6-42E8-A466-9075583DE035}']
  end;
  
```delphi
  TContextUsuario = class(TContextDataBase<TUsuario>, IContextUsuario);
  
  TLmxGeradorConsultaUsuario = class(TLmxGeradorConsulta)
  public
    procedure DoGerarConsulta; override;
  end;
```  

