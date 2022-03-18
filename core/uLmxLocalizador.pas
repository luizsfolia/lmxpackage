unit uLmxLocalizador;

interface
uses
  System.SysUtils, System.Classes, IdUDPServer, IdGlobal, IdSocketHandle;

type
  TLmxLocalizador = class
  private
    class var FLocaliador : TLmxLocalizador;
    FPortaServidor : Integer;
    FPortaLocal : Integer;
    FUdpServer : TIdUDPServer;
    FListaServidores : TStringList;
    FOnLocalizado: TProc;
    procedure AoReceberMensagemLocalizacao(AThread: TIdUDPListenerThread; const AData: TIdBytes;
      ABinding: TIdSocketHandle);
  public
    constructor Create(const pPortaServidor, pPortaLocal : Integer; const pOnLocalizado: TProc);
    destructor Destroy; override;

    class destructor Destroy;

    procedure IniciarLocalizador(const pPortaServidor : Integer = 0);
    procedure FinalizarLocalizador;

    function Servidores : string;

    class function GetLocalizador(const pPortaServidor, pPortaLocal : Integer; const pOnLocalizado: TProc) : TLmxLocalizador;
  end;

implementation

{ TLmxLocalizador }

procedure TLmxLocalizador.AoReceberMensagemLocalizacao(
  AThread: TIdUDPListenerThread; const AData: TIdBytes;
  ABinding: TIdSocketHandle);
var
  lMensagem : string;
begin
  lMensagem := BytesToString(AData);
  if FListaServidores.IndexOf(lMensagem) = -1 then
    FListaServidores.Add(lMensagem);
  if Assigned(FOnLocalizado) then
    FOnLocalizado;
end;

constructor TLmxLocalizador.Create(const pPortaServidor, pPortaLocal: Integer;
  const pOnLocalizado: TProc);
begin
  FPortaServidor := pPortaServidor;
  FPortaLocal := pPortaLocal;
  FOnLocalizado := pOnLocalizado;

  FListaServidores := TStringList.Create;

  FUdpServer := TIdUDPServer.Create(nil);
  FUdpServer.OnUDPRead := AoReceberMensagemLocalizacao;

  FUdpServer.DefaultPort := pPortaLocal;
end;

class destructor TLmxLocalizador.Destroy;
begin
  if TLmxLocalizador.FLocaliador <> nil then
    TLmxLocalizador.FLocaliador.Free;
end;

destructor TLmxLocalizador.Destroy;
begin
  FreeAndNil(FListaServidores);
  FreeAndNil(FUdpServer);
  inherited;
end;

procedure TLmxLocalizador.FinalizarLocalizador;
begin
  FUdpServer.Active := False;
end;

class function TLmxLocalizador.GetLocalizador(const pPortaServidor, pPortaLocal : Integer; const pOnLocalizado: TProc): TLmxLocalizador;
begin
  if TLmxLocalizador.FLocaliador = nil then
    TLmxLocalizador.FLocaliador := TLmxLocalizador.Create(pPortaServidor, pPortaLocal, pOnLocalizado);
  Result := TLmxLocalizador.FLocaliador;
end;

procedure TLmxLocalizador.IniciarLocalizador(const pPortaServidor : Integer);
begin
  if pPortaServidor > 0 then
    FPortaServidor := pPortaServidor;
  FUdpServer.Active := True;
  FUdpServer.broadcast('GC=' + FPortaLocal.ToString, FPortaServidor);
end;


function TLmxLocalizador.Servidores: string;
begin
  Result := FListaServidores.Text;
end;

end.
