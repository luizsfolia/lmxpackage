unit uLmxControllerView;

interface

uses
  SysUtils, Classes, uLmxControllerBase, uLmxInterfaces, uLmxUtils;

type

  TLmxControllerView<I : ILmxBaseView> = class(TInterfacedObject, ILmxControllerView)
  private
    FView: TGUID;
    FViewExterna : I;
    FControllerClass : TLmxControllerBaseClass;
    FController : TLmxControllerBase;
    FDescricao : string;
    function GetControllerClass : TLmxControllerBaseClass;
  protected
    function GetDescricao : string; virtual;
  public
    constructor Create(const AControllerClass : TLmxControllerBaseClass; const AView : TGUID;
      const ADescricao : string = '');

    property ControllerClass : TLmxControllerBaseClass read GetControllerClass;

    procedure SetController(const AController : TLmxControllerBase);
    procedure SetView(const AView : I);
    procedure SetDescricao(const ADescricao : string);
    function PossuiTelaRegistrada : Boolean; virtual;

    function Mostrar(const AOwner : TComponent = nil) : Boolean; virtual;
    function Listar(const AOwner : TComponent; const pDescricao, pChave : string; const pConsulta : ILmxGeradorConsulta) : Boolean; virtual;
  end;

  TLmxControllerCadastroView<I : ILmxCadastroView> = class(TLmxControllerView<I>)
  public
    function Mostrar(const AOwner : TComponent = nil) : Boolean; override;
  end;

  TLmxControllerLancamentoView<I : ILmxLancamentoView> = class(TLmxControllerView<I>)
  public
    function Mostrar(const AOwner : TComponent = nil) : Boolean; override;
  end;


implementation

{ TLmxControllerBaseView }

constructor TLmxControllerView<I>.Create(
  const AControllerClass: TLmxControllerBaseClass; const AView: TGUID; const ADescricao : string);
begin
  FControllerClass := AControllerClass;
  FView := AView;
  FDescricao := ADescricao;
end;

function TLmxControllerView<I>.GetControllerClass : TLmxControllerBaseClass;
begin
  Result := FControllerClass;
end;

function TLmxControllerView<I>.GetDescricao: string;
begin
  Result := FDescricao;
end;


function TLmxControllerView<I>.Listar(const AOwner: TComponent;
  const pDescricao, pChave: string;
  const pConsulta: ILmxGeradorConsulta): Boolean;
begin
  Result := True;
  if (FViewExterna <> nil) and (FController <> nil) then
  begin
    FViewExterna.Build(FController);
    Result := FViewExterna.Mostrar;
  end;
end;

function TLmxControllerView<I>.Mostrar(const AOwner : TComponent): Boolean;
begin
  Result := True;
  if (FViewExterna <> nil) and (FController <> nil) then
  begin
    FViewExterna.Build(FController);
    Result := FViewExterna.Mostrar;
  end;
end;

function TLmxControllerView<I>.PossuiTelaRegistrada: Boolean;
begin
  Result := uLmxUtils.LmxUtils.InterfaceUtils.Exists(FView);
end;

procedure TLmxControllerView<I>.SetController(
  const AController: TLmxControllerBase);
begin
  FController := AController;
end;

procedure TLmxControllerView<I>.SetDescricao(const ADescricao: string);
begin
  FDescricao := ADescricao;
end;

procedure TLmxControllerView<I>.SetView(const AView: I);
begin
  FViewExterna := AView;
end;

{ TLmxControllerCadastroView<I> }

function TLmxControllerCadastroView<I>.Mostrar(
  const AOwner: TComponent): Boolean;
var
  lCadastro : ILmxCadastroView;
begin
  Result := False;
  if FController = nil then
    raise Exception.Create('Um objeto de controller do tipo ' + FControllerClass.ClassName + ' deve ser setado ');
  Result := True;
  lCadastro := uLmxUtils.LmxUtils.InterfaceUtils.New(FView, AOwner) as ILmxCadastroView;
  if lCadastro <> nil then
  begin
    lCadastro.Build(GetDescricao, FController, FController.Seguranca.SomenteLeitura);
    Result := lCadastro.Mostrar;
  end;
end;

{ TLmxControllerLancamentoView<I> }

function TLmxControllerLancamentoView<I>.Mostrar(
  const AOwner: TComponent): Boolean;
var
  lCadastro : ILmxLancamentoView;
begin
  Result := False;
  if FController = nil then
    raise Exception.Create('Um objeto de controller do tipo ' + FControllerClass.ClassName + ' deve ser setado ');
  Result := True;
  lCadastro := uLmxUtils.LmxUtils.InterfaceUtils.New(FView, AOwner) as ILmxLancamentoView;
  if lCadastro <> nil then
  begin
    lCadastro.Build(GetDescricao, FController);
    Result := lCadastro.Mostrar;
  end;
end;

end.
