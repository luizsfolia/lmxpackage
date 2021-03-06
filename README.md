# lmxpackage

Versão atual 1.0.0

# Instalação

Não é nescessária nenhuma instalação, basta adicionar o caminho do repositório no path do Delphi

# boss

para usar no boss, basta instalar o boss e no seu projeto usar

boos init

boss install https://github.com/luizsfolia/lmxpackage.git

# Exemplos


você pode abrir um server de exemplo que está em 
https://github.com/luizsfolia/lmxpackage/blob/main/exemplos/GrupoExemplos.groupproj

Abaixo seguem alguns exemplos utilizados do projeto acima

## Crinado Server HTTP

```delphi
var
  FServer : TLmxHttpServer;
begin
  FServer := TLmxHttpServer.Create;
  FServer.AdicionarComando(TModuloCllientes, '/Clientes'); // Classe descrita abaixo na opção sem ORM 
  FServer.Ativar(8500); // server sendo ativado na porta 8500
end
```
## Sem OrmLmx

### Exemplo de classe de comando

```delphi
  TModuloCllientes = class(TLmxServerComand)
  public
    [HttpGet]
    [TLmxAttributeComando('')]
    function GetClientes : ILmxRetorno<TClientes>;

    [HttpGet]
    [TLmxAttributeComando('/{id}')]
    function GetCliente([FromParams] const id : Integer) : ILmxRetorno<TCliente>;

    [HttpPost]
    [TLmxAttributeComando('')]
    function PostCliente(const pCliente : TCliente) : ILmxRetorno<TCliente>;
  end;
```

## Implementação da classe de comando

```delphi
function TModuloCllientes.GetCliente(const id: Integer): ILmxRetorno<TCliente>;
begin
  Result := TLmxRetorno<TCliente>.Create;
  Result.Retorno.Nome := 'Luiz';
  Result.Retorno.Id := id;
end;

function TModuloCllientes.GetClientes : ILmxRetorno<TClientes>;
var
  lCliente: TCliente;
begin
  Result := TLmxRetorno<TClientes>.Create;

  lCliente := TCliente.Create;
  lCliente.Nome := 'Luiz';
  lCliente.Id := 1;

  Result.Retorno.Add(lCliente);

  lCliente := TCliente.Create;
  lCliente.Nome := 'Ricardo';
  lCliente.Id := 2;

  Result.Retorno.Add(lCliente);

end;

function TModuloCllientes.PostCliente(const pCliente: TCliente): ILmxRetorno<TCliente>;
begin
  // Salvar no DataBase o pCliente
  Result := GetCliente(pCliente.id);
end;
```

## classe de modelo
```delphi

uses
  uLmxCore, uLmxAttributes, System.Classes;

type

  [TLmxAttributeMetadata]
  TCliente = class(TBaseTabelaPadrao)
  private
    FNome: string;
  public
    [TLmxAttributeMetadata(80)]
    property Nome : string read FNome write FNome;
  end;

  TClientes = class(TBaseList<TCliente>)
  end;
```


## Com Orm Lmx
### Classe DataBaseExemplo

```delphi
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
  end;

  TUsuarios = class(TBaseList<TUsuario>);
```

### Conexao com DataBase (Firebird)
  
```delphi
  TContextDataBaseConfig.Default.RegistrarConexao(TLmxConexaoFirebird,
    procedure (const pControleConexao : TLmxControleConexao)
    begin
      pControleConexao.HostName := 'localhost';
      pControleConexao.DataBase :=  'c:\tmp\Database\lmxteste.FDB';
      pControleConexao.ClasseDriver := TLmxConexaoFirebird.ClassName;
      pControleConexao.User_Name := 'sysdba';
      pControleConexao.Password := 'masterkey';
    end
```  
  
### Criando/Atualizando DataBase  
  
```delphi
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
```
  
  
### Criando Server  HTTP
  
```delphi
  FServer := TLmxHttpServer.Create;
  FServer.AdicionarComando(THttpUsuario, '/Usuarios');
```
  
### Classe Exemplo Http
  
```delphi

uses
  System.Classes, 
  uLmxHttpServer, uLmxHelper, uLmxAttributes, uLmx.Context.Usuario, uLmx.Model.Usuario,
  uLmx.Http.Base, uLmxCore;

type

  THttpUsuario = class(THttp<TUsuario,IContextUsuario,TBaseList<TUsuario>>);
```
  
### Exemplo Context
  
```delphi
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
  
  TContextUsuario = class(TContextDataBase<TUsuario>, IContextUsuario);
```  

### Exemplo Gerador de Consulta

```delphi
TLmxGeradorConsultaUsuario = class(TLmxGeradorConsulta)
  public
    procedure DoGerarConsulta; override;
  end;

procedure TLmxGeradorConsultaUsuario.DoGerarConsulta;
begin
  inherited;
  From('usuario');
  AddCampo('usuario', '*');
  AddCampoCalculado('0', 'teste');
end;


```
