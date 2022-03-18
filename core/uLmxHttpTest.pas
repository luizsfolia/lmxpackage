unit uLmxHttpTest;

interface

uses
  Generics.Collections, SysUtils;

type

  TLmxMaquinaRede = class
  private
    FPortasAbertas: TList<Integer>;
    FIPMaquina: string;
    FNomeMaquina: string;
  public
    constructor Create;
    destructor Destroy; override;

    property NomeMaquina : string read FNomeMaquina write FNomeMaquina;
    property IPMaquina : string read FIPMaquina write FIPMaquina;
    property PortasAbertas : TList<Integer> read FPortasAbertas;
  end;

  TLmxMaquinasRede = class(TObjectList<TLmxMaquinaRede>);

  ILmxRede = interface
    function IPLocal : string;
    function ListarMaquinasRede(out AMaquinasRede : TLmxMaquinasRede) : Boolean;
    function TestTCPPort(IPAddr: string; TCPPort: Word; Timeout: Integer): Boolean;
  end;


implementation


{ TLmxMaquinaRede }

constructor TLmxMaquinaRede.Create;
begin
  FPortasAbertas := TList<Integer>.Create;
end;

destructor TLmxMaquinaRede.Destroy;
begin
  FreeAndNil(FPortasAbertas);
  inherited;
end;

end.
