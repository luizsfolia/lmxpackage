unit uLmxControllerProxyBase;

interface

uses
  uLmxComando, uLmxComandoDefault, uLmxComandoManutencao, Generics.Collections,
  System.SysUtils, uLmxConexao, uLmxControllerBase,
  uLmxControllerView, uLmxComandoSQL, uLmxInterfaces,
  System.Classes, uLmxFinder, uLmxUtils, uLmxCore, uProxy.Base, uLmxProxy;

type

  TLmxProxyConsultaProxy = class(TInterfacedObject, ILmxProxy)
  public
    function Buscar(const pFiltro: string = ''): string; virtual;
  end;

  TControllerProxyProxy<T : TBaseTabelaPadrao, constructor> = class(TLmxControllerBase)
  private
    FObjetoPrincipal : T;
  protected
    function DoIncluir: Boolean; override;
    procedure Inicializar; override;
    procedure Finalizar; override;
  public
    property ObjetoPrincipal : T read FObjetoPrincipal;
  end;

  TLmxControlePesquisaProxy<T : TBaseTabelaPadrao, constructor; I : ILmxConsultaView> = class(TLmxControlePesquisa<T>)
  protected
    function GetDescricaoCampo(const pObjetoSelecionado : T) : string; virtual;
    function GetInternalConsultaView(const pOwner : TComponent; const pGeradorConsulta : ILmxProxy = nil) : I; virtual; abstract;
    procedure DoCarregarObjeto(const pId : Integer; out AObjetoSelecionado : T); virtual; abstract;

    function DoSelecionar(const pInicial : string; out AObjetoSelecionado : T) : Boolean; virtual;
    function SetParamsControllerPesquisa : ILmxControlePesquisa<T>; override;
  public
    class function GetConsultaView(const pOwner : TComponent; const pGeradorConsulta : ILmxProxy = nil) : I;

    class procedure MostrarCadastro(const pOwner : TComponent; const pView : I); overload;
    class procedure MostrarCadastro(const pOwner : TComponent); overload;
    class function Selecionar(const pOwner : TComponent; out AObjetoPrincipal : T; const pInicial : string = '') : Boolean;

  end;


implementation


//function TLmxProxyConsultaProxy<T, TProxy>.Buscar(const pFiltro: string): string;
//begin
//  Result := TLmxHttpProxyBase<TProxy>.Proxy.Buscar(pFiltro);
//end;

{ TLmxControlePesquisaProxy<T,TProxy> }

function TLmxControlePesquisaProxy<T, I>.DoSelecionar(const pInicial : string; out AObjetoSelecionado : T) : Boolean;
var
  lSelecionado: Integer;
begin
  AObjetoSelecionado := nil;
  lSelecionado := GetInternalConsultaView(Self.GetOwner)
    .SetRetornoDefault(True)
    .Selecionar(pInicial);
  if lSelecionado > 0 then
    DoCarregarObjeto(lSelecionado, AObjetoSelecionado);
  Result := AObjetoSelecionado <> nil;
end;

class function TLmxControlePesquisaProxy<T, I>.GetConsultaView(
  const pOwner: TComponent; const pGeradorConsulta : ILmxProxy): I;
var
  lPesquisa: TLmxControlePesquisaProxy<T, I>;
begin
  lPesquisa := Self.Create;
  try
    Result := lPesquisa.GetInternalConsultaView(pOwner, pGeradorConsulta);
  finally
    lPesquisa.Free;
  end;
end;

function TLmxControlePesquisaProxy<T, I>.GetDescricaoCampo(
  const pObjetoSelecionado: T): string;
begin
  Result := pObjetoSelecionado.Id.ToString;
end;

class procedure TLmxControlePesquisaProxy<T, I>.MostrarCadastro(
  const pOwner: TComponent; const pView: I);
begin
  pView.Mostrar;
end;

class procedure TLmxControlePesquisaProxy<T, I>.MostrarCadastro(
  const pOwner: TComponent);
begin
  MostrarCadastro(pOwner, Self.GetConsultaView(pOwner));
end;

class function TLmxControlePesquisaProxy<T, I>.Selecionar(
  const pOwner: TComponent; out AObjetoPrincipal: T;
  const pInicial: string): Boolean;
var
  lPesquisa: TLmxControlePesquisaProxy<T,I>;
begin
  lPesquisa := Self.Create;
  try
    Result := lPesquisa.DoSelecionar(pInicial, AObjetoPrincipal);
  finally
    lPesquisa.Free;
  end;
end;

function TLmxControlePesquisaProxy<T, I>.SetParamsControllerPesquisa: ILmxControlePesquisa<T>;
begin
  Self
    .SetOnGetDescricaoControle(
      function(const pObjetoSelecionado : T) : string
      begin
        Result := GetDescricaoCampo(pObjetoSelecionado);
      end)
    .SetCarga(
      procedure(const pId : Integer; out AObjetoSelecionado : T)
      begin
        DoCarregarObjeto(pId, AObjetoSelecionado);
      end)
    .SetPesquisa(
      procedure(const pInicial : string; out AObjetoSelecionado : T)
      begin
        DoSelecionar(pInicial, AObjetoSelecionado)
      end);
  Result := Self;
end;


{ TControllerProxyProxy<T, TProxy> }

//procedure TControllerProxyProxy<T, TProxy>.Build(const AId: Integer);
//begin
//  inherited;
//  TProxy.Proxy.Carregar(AId, FObjetoPrincipal);
//end;
//
//constructor TControllerProxyProxy<T, TProxy>.Create;
//begin
//  inherited;
//  FObjetoPrincipal := T.Create;
//end;
//
//destructor TControllerProxyProxy<T, TProxy>.Destroy;
//begin
//  FObjetoPrincipal.Free;
//  inherited;
//end;
//
//function TControllerProxyProxy<T, TProxy>.DoIncluir: Boolean;
//begin
//  FObjetoPrincipal.Id := 0;
//  Result := TProxy.Proxy.Salvar(FObjetoPrincipal);
//end;
//
//function TControllerProxyProxy<T, TProxy>.DoSalvar: Boolean;
//begin
//  Result := TProxy.Proxy.Salvar(FObjetoPrincipal);
//end;

{ TLmxProxyConsultaProxy }

function TLmxProxyConsultaProxy.Buscar(const pFiltro: string): string;
begin
  Result := '';
end;

{ TControllerProxyProxy<T> }

function TControllerProxyProxy<T>.DoIncluir: Boolean;
begin
  FObjetoPrincipal.Id := 0;
  Result := DoSalvar;
end;


procedure TControllerProxyProxy<T>.Finalizar;
begin
  inherited;
  FObjetoPrincipal.Free;
end;

procedure TControllerProxyProxy<T>.Inicializar;
begin
  inherited;
  FObjetoPrincipal := T.Create;
end;

end.
