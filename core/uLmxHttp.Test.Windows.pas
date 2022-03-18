unit uLmxHttp.Test.Windows;

interface

uses
  SysUtils, uLmxHttpTest {$IFDEF MSWINDOWS}
  , WinApi.Windows, WinApi.WinSock, IdIPWatch
  {$ENDIF};

type

  TSimpleFDSet = record
    fd_count: u_int;
    fd_array: array[0..0] of TSocket;
  end;

  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array [0 .. 100] of TNetResource;


  TLmxRedeWindows = class(TInterfacedObject, ILmxRede)
  private
    function SocketsInit: Boolean;
    procedure ScanNetworkResources(ResourceType, DisplayType: DWord;
      const AInternalMaquinasRede : TLmxMaquinasRede);
    function CreateNetResourceList(ResourceType: DWord; NetResource: PNetResource;
      out Entries: DWord; out List: PNetResourceArray): Boolean;
  public
    function IPLocal : string;
    function ListarMaquinasRede(out AMaquinasRede : TLmxMaquinasRede) : Boolean;
    function TestTCPPort(IPAddr: string; TCPPort: Word; Timeout: Integer): Boolean;
  end;


implementation

{ TLmxRede }

function TLmxRedeWindows.CreateNetResourceList(ResourceType: DWord;
  NetResource: PNetResource; out Entries: DWord;
  out List: PNetResourceArray): Boolean;
{$IFDEF MSWINDOWS}
var
  EnumHandle: THandle;
  BufSize: DWord;
  Res: DWord;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := False;
  List := Nil;
  Entries := 0;
  if WNetOpenEnum(RESOURCE_GLOBALNET, ResourceType, 0, NetResource, EnumHandle)
    = NO_ERROR then
  begin
    try
      BufSize := $4000; // 16 kByte
      GetMem(List, BufSize);
      try
        repeat
          Entries := DWord(-1);
          FillChar(List^, BufSize, 0);
          Res := WNetEnumResource(EnumHandle, Entries, List, BufSize);
          if Res = ERROR_MORE_DATA then
          begin
            ReAllocMem(List, BufSize);
          end;
        until Res <> ERROR_MORE_DATA;
        Result := Res = NO_ERROR;
        if not Result then
        begin
          FreeMem(List);
          List := Nil;
          Entries := 0;
        end;
      except
        FreeMem(List);
        raise;
      end;
    finally
      WNetCloseEnum(EnumHandle);
    end;
  end;
{$ENDIF}
end;

function TLmxRedeWindows.IPLocal: string;
{$IFDEF MSWINDOWS}
var
  lWatch: TIdIPWatch;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  lWatch := TIdIPWatch.Create(nil);
  try
    Result := lWatch.LocalIP;
  finally
    FreeAndNil(lWatch);
  end;
{$ENDIF}
end;

function TLmxRedeWindows.ListarMaquinasRede(
  out AMaquinasRede: TLmxMaquinasRede): Boolean;

var
  lMaquinaRede: TLmxMaquinaRede;
begin

  AMaquinasRede := TLmxMaquinasRede.Create;

  lMaquinaRede := TLmxMaquinaRede.Create;
  lMaquinaRede.NomeMaquina := IPLocal;
  lMaquinaRede.IPMaquina := IPLocal;

  AMaquinasRede.Add(lMaquinaRede);

{$IFDEF MSWINDOWS}
  ScanNetworkResources(RESOURCETYPE_DISK, RESOURCEDISPLAYTYPE_SERVER,
    AMaquinasRede);
{$ENDIF}
  Result := True;
end;

procedure TLmxRedeWindows.ScanNetworkResources(ResourceType, DisplayType: DWord;
  const AInternalMaquinasRede: TLmxMaquinasRede);

{$IFDEF MSWINDOWS}
  procedure ScanLevel(NetResource: PNetResource);
  var
    Entries: DWord;
    NetResourceList: PNetResourceArray;
    i: Integer;
    lInternalMaquinaRede: TLmxMaquinaRede;
  begin
    if CreateNetResourceList(ResourceType, NetResource, Entries, NetResourceList)
    then
      try
        for i := 0 to Integer(Entries) - 1 do
        begin
          if (DisplayType = RESOURCEDISPLAYTYPE_GENERIC) or
            (NetResourceList[i].dwDisplayType = DisplayType) then
          begin
            lInternalMaquinaRede := TLmxMaquinaRede.Create;
            lInternalMaquinaRede.NomeMaquina := NetResourceList[i].lpRemoteName;
            lInternalMaquinaRede.IPMaquina := StringReplace(lInternalMaquinaRede.NomeMaquina, '\\', '', [rfReplaceAll]);

            AInternalMaquinasRede.Add(lInternalMaquinaRede);

//              List.AddObject(NetResourceList[i].lpRemoteName,
//                Pointer(NetResourceList[i].dwDisplayType));
          end;
          if (NetResourceList[i].dwUsage and RESOURCEUSAGE_CONTAINER) <> 0 then
            ScanLevel(@NetResourceList[i]);
        end;
      finally
        FreeMem(NetResourceList);
      end;
  end;
{$ENDIF}

begin
{$IFDEF MSWINDOWS}
  ScanLevel(Nil);
{$ENDIF}
end;

function TLmxRedeWindows.SocketsInit: Boolean;
{$IFDEF MSWINDOWS}
var
  Data: TWSAData;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Result := WSAStartup($101, Data) = 0;
  {$ENDIF}
end;

function TLmxRedeWindows.TestTCPPort(IPAddr: string; TCPPort: Word;
  Timeout: Integer): Boolean;
{$IFDEF MSWINDOWS}
var
  S: TSocket;
  Addr: TSockAddrIn;
  NonBlocking: Integer;
  Sockets: TSimpleFDSet;
  Res: Integer;
  T: TTimeVal;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := False;
  s := socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if s = INVALID_SOCKET then begin
    if WSAGetLastError = WSANOTINITIALISED then begin
      if not SocketsInit then EXIT;
      s := socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    end else EXIT;
  end;
  try
    NonBlocking := 1;
    if ioctlsocket(s, FIONBIO, NonBlocking) = SOCKET_ERROR then EXIT;
    FillChar(addr, SizeOf(addr), 0);
    addr.sin_family := PF_INET;
    addr.sin_port := htons(TCPPort);
    addr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(IPAddr)));
    Res := connect(s, addr, SizeOf(addr));
    if Res = SOCKET_ERROR then begin
      if WSAGetLastError = WSAEWOULDBLOCK then begin
        Sockets.fd_count := 1;
        Sockets.fd_array[0] := S;
        T.tv_sec := 0;
        T.tv_usec := Timeout * 1000;
        Result := select(0, nil, @Sockets, nil, @T) = 1;
      end;
    end;
  finally
    closesocket(S);
  end;
{$ENDIF}
end;

initialization

finalization
  WSACleanup;


end.

