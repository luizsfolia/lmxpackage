unit uLmxControllerBase;

interface

uses
  Classes, uLmxTypes, SysUtils, Generics.Collections, uLmxInterfacesPrinter;

type

  TLmxControllerBase = class;

  TLmxOnSalvarController = reference to function(const Self : TLmxControllerBase; out ASalvar : Boolean) : Boolean;

  TSegurancaUsuario = class

  end;

  TSegurancaController = class
  private
    FPermiteAlterar: Boolean;
    FPermiteExcluir: Boolean;
    FPermiteIncluir: Boolean;
    FSomenteLeitura: Boolean;
  public
    constructor Create;

    property PermiteIncluir : Boolean read FPermiteIncluir write FPermiteIncluir;
    property PermiteExcluir : Boolean read FPermiteExcluir write FPermiteExcluir;
    property PermiteAlterar : Boolean read FPermiteAlterar write FPermiteAlterar;
    property SomenteLeitura : Boolean read FSomenteLeitura write FSomenteLeitura;

    procedure CopiarDe(const ASegurancaController : TSegurancaController);
  end;

//  TValidacaoController = class
//  public
//    property Descricao : string read FDescricao write FDescricao;
//    property Valido : Boolean read FValido write FValido;
//  end;

//  TValidacoesController = class
//  private
//  public
//    procedure NovaValidacao
//  end;

  TLmxControllerBaseClass = class of TLmxControllerBase;

  TLmxControllerList = class(TObjectDictionary<TLmxControllerBaseClass, TLmxControllerBase>);

  TLmxControllerBase = class
  private
    FCodigo : Integer;
//    FSomenteLeitura: Boolean;
    FStatus: TLmxControlerStatus;
//    FPermiteAlterar: Boolean;
//    FPermiteExcluir: Boolean;
//    FPermiteIncluir: Boolean;
    FSeguranca : TSegurancaController;
    FControllers : TLmxControllerList;
//    FControllerBase : TLmxControllerBase;

    procedure ToAlterado;
//    procedure ToMarcadoExclusao;
    procedure ToExcluido;
    procedure ToIncluido;
  protected
    FPrinter : ILmxInterfacesPrinter;

    procedure Inicializar; virtual;
    procedure Finalizar; virtual;

    function DoSalvar : Boolean; virtual;
    function DoExcluir : Boolean; virtual;
    function DoIncluir : Boolean; virtual;

    function DoValidar(out AValidacoes : string) : Boolean; virtual;

    function DoEmitirRelatorioGerencial(const ARelatorio : string;
      const AFecharAoConcluir : Boolean = True) : Boolean;
    function DoCortarPapel : Boolean;

  public
//    constructor Create(const AParent : TLmxControllerBase = nil); virtual;
    constructor Create; virtual;
    destructor Destroy; override;

    property Seguranca : TSegurancaController read FSeguranca;

//    property PermiteIncluir : Boolean read FPermiteIncluir write FPermiteIncluir;
//    property PermiteAlterar : Boolean read FPermiteAlterar write FPermiteAlterar;
//    property PermiteExcluir : Boolean read FPermiteExcluir write FPermiteExcluir;
//    property SomenteLeitura : Boolean read FSomenteLeitura write FSomenteLeitura;
    property Status : TLmxControlerStatus read FStatus;

    procedure Build(const ACodigo : Integer); virtual;
//    function Mostrar(const AOwner : TComponent = nil) : Boolean; overload; virtual;
//    function Mostrar(const AOwner : TComponent; AOnSalvar : TLmxOnSalvarController) : Boolean; overload; virtual;

    function Validar(out AValidacoes : string) : Boolean; virtual;
    function Incluir : Boolean; virtual;
    function Salvar(out AValidacoes : string) : Boolean; overload; virtual;
    function Salvar : Boolean; overload; virtual;
    function Excluir : Boolean; virtual;

    procedure SetPrinter(const APrinter : ILmxInterfacesPrinter);
  end;

implementation

{ TLmxControllerBase }

procedure TLmxControllerBase.Build(const ACodigo: Integer);
begin
  FCodigo := ACodigo;
end;

constructor TLmxControllerBase.Create;
begin
//  FControllerBase := AParent;
  FControllers := TLmxControllerList.Create([doOwnsValues]);
  FStatus := tcsAtivo;
  FSeguranca := TSegurancaController.Create;
  Inicializar;
end;

destructor TLmxControllerBase.Destroy;
begin
  FreeAndNil(FSeguranca);
  FreeAndNil(FControllers);
  Finalizar;
  inherited;
end;

function TLmxControllerBase.DoCortarPapel: Boolean;
begin
  Result := False;
  if Assigned(FPrinter) then
    Result := FPrinter.CortarPapel;
end;

function TLmxControllerBase.DoEmitirRelatorioGerencial(const ARelatorio: string;
  const AFecharAoConcluir: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FPrinter) then
    Result := FPrinter.EmitirRelatorioGerencial(ARelatorio, AFecharAoConcluir);
end;

function TLmxControllerBase.DoExcluir: Boolean;
begin
  Result := True;
end;

function TLmxControllerBase.DoIncluir: Boolean;
begin
  Result := DoSalvar;
end;

function TLmxControllerBase.DoSalvar: Boolean;
begin
  Result := False;
end;

function TLmxControllerBase.DoValidar(out AValidacoes: string): Boolean;
begin
  Result := True;
end;

function TLmxControllerBase.Excluir: Boolean;
begin
  Result := False;
  if FSeguranca.PermiteExcluir then
  begin
    Result := DoExcluir;
    if Result then
      ToExcluido;
  end;
end;

procedure TLmxControllerBase.Finalizar;
begin

end;

function TLmxControllerBase.Incluir: Boolean;
begin
  Result := False;
  if FSeguranca.PermiteIncluir then
  begin
    Result := DoIncluir;
    if Result then
      ToIncluido;
  end;
end;

procedure TLmxControllerBase.Inicializar;
begin

end;

function TLmxControllerBase.Salvar(out AValidacoes: string): Boolean;
begin
  Result := False;
  if FSeguranca.PermiteAlterar then
  begin
    Result := Validar(AValidacoes);
    if Result then
    begin
      Result := DoSalvar;
      if Result then
        ToAlterado;
    end;
  end;
end;

function TLmxControllerBase.Salvar: Boolean;
var
  lValidacoes: string;
begin
  Result := Salvar(lValidacoes);
end;

procedure TLmxControllerBase.SetPrinter(const APrinter: ILmxInterfacesPrinter);
begin
  FPrinter := APrinter;
end;

procedure TLmxControllerBase.ToAlterado;
begin
  FStatus := tcsAlterado;
end;

procedure TLmxControllerBase.ToExcluido;
begin
  FStatus := tcsExcluido;
end;

procedure TLmxControllerBase.ToIncluido;
begin
  FStatus := tcsAtivo;
end;

function TLmxControllerBase.Validar(out AValidacoes: string): Boolean;
begin
  Result := DoValidar(AValidacoes);
end;

//procedure TLmxControllerBase.ToMarcadoExclusao;
//begin
//  FStatus := tcsMarcadoExclusao;
//end;

{ TSegurancaController }

procedure TSegurancaController.CopiarDe(
  const ASegurancaController: TSegurancaController);
begin
  if ASegurancaController <> nil then
  begin
    FPermiteAlterar := ASegurancaController.PermiteAlterar;
    FPermiteExcluir := ASegurancaController.PermiteExcluir;
    FPermiteIncluir := ASegurancaController.PermiteIncluir;
    FSomenteLeitura := ASegurancaController.SomenteLeitura;
  end;
end;

constructor TSegurancaController.Create;
begin
  FPermiteAlterar := True;
  FPermiteExcluir := True;
  FPermiteIncluir := True;
  FSomenteLeitura := False;
end;


end.
