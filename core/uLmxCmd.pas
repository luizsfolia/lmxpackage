unit uLmxCmd;

interface

uses
  {$IFDEF MSWINDOWS}Winapi.Windows, {$ENDIF} SysUtils;

type

  TLmxCor = (cpcPreto, cpcAzul, cpcVerde, cpcVerdeAgua, cpcVermelho, cpcRoxo,
    cpcAmarelo, cpcBranco, cpcCinza, cpcAzulClaro);

  TLmxCommandLine = class
  private
    {$IFDEF MSWINDOWS}
    FStdHandle : THandle;
    {$ENDIF}
  public
    constructor Create;

    procedure Clear;
    {$IFDEF MSWINDOWS}
    function ObterLinhaAtual : TConsoleScreenBufferInfo;

    procedure Escrever(const ATexto : string; const ACursor : TConsoleScreenBufferInfo); overload;

    {$ENDIF}
    procedure Escrever(const ATexto : string; const AQuebrarLinha : Boolean = True;
      const ACorFonte : TLmxCor = cpcBranco; const ACorFundo : TLmxCor = cpcCinza); overload;

    function Executar(const AComando : string; const AAguardar : Boolean = True) : Integer;

    procedure LerTexto(const ATextoDescricao : string; var ATexto : string; const ACorFonte : TLmxCor = cpcBranco; const ACorFundo : TLmxCor = cpcCinza);
  end;

  TLmxSystemParam = class
  public
    function ValorParametroAsInteger(const ANomeParametro : string) : Integer;
    function ValorParametro(const ANomeParametro : string) : string; overload;
    function ValorParametro(const AIndex : Integer) : string; overload;
    function IndexParametro(const AParametro : string) : Integer;
    function TemParametro(const AParametro : string) : Boolean;
  end;

  function LmxCommandLine : TLmxCommandLine;
  function LmxSystemParam : TLmxSystemParam;


implementation

var
  FLmxCommandLine : TLmxCommandLine;
  FLmxSystemParam : TLmxSystemParam;

function LmxCommandLine : TLmxCommandLine;
begin
  Result := FLmxCommandLine;
end;

function LmxSystemParam : TLmxSystemParam;
begin
  Result := FLmxSystemParam;
end;


{ TLmxCommandLine }

procedure TLmxCommandLine.Clear;
{$IFDEF MSWINDOWS}
var
  hStdOut: HWND;
  ScreenBufInfo: TConsoleScreenBufferInfo;
  Coord1: TCoord;
  z: Integer;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hStdOut, ScreenBufInfo);
  for z := 1 to ScreenBufInfo.dwSize.Y do
    WriteLn('');
  Coord1.X := 0;
  Coord1.Y := 0;
  SetConsoleCursorPosition(hStdOut, Coord1);
{$ENDIF}
end;

{$IFDEF MSWINDOWS}
procedure TLmxCommandLine.Escrever(const ATexto : string; const ACursor : TConsoleScreenBufferInfo);
var
  lNovaCoordenada : TCoord;
begin
  lNovaCoordenada.X := 0;
  lNovaCoordenada.Y := ACursor.dwCursorPosition.Y;
  SetConsoleCursorPosition(FStdHandle, lNovaCoordenada);
  Write(StringofChar(' ', ACursor.dwSize.x));
  SetConsoleCursorPosition(FStdHandle, lNovaCoordenada);
  Write(ATexto);
end;
{$ENDIF}

constructor TLmxCommandLine.Create;
begin
{$IFDEF MSWINDOWS}
  FStdHandle := GetStdHandle(STD_OUTPUT_HANDLE);
{$ENDIF}
end;

procedure TLmxCommandLine.Escrever(const ATexto: string; const AQuebrarLinha : Boolean;
  const ACorFonte, ACorFundo : TLmxCor);
begin
{$IFDEF MSWINDOWS}
  SetConsoleTextAttribute(GetStdHandle(
                          STD_OUTPUT_HANDLE),
                          Integer(ACorFonte) or
                          FOREGROUND_INTENSITY);

//  SetConsoleTextAttribute(GetStdHandle(
//                          STD_OUTPUT_HANDLE),
//                          FOREGROUND_RED or
//                          FOREGROUND_INTENSITY);
  if AQuebrarLinha then
    WriteLn(ATexto)
  else
    Write(ATexto);

  SetConsoleTextAttribute(GetStdHandle(
                          STD_OUTPUT_HANDLE),
                          FOREGROUND_RED or
                          FOREGROUND_GREEN or
                          FOREGROUND_BLUE);
{$ENDIF}
end;

function TLmxCommandLine.Executar(const AComando: string;
  const AAguardar: Boolean): Integer;
{$IFDEF MSWINDOWS}
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  Handle: Boolean;
  ExitCode: longword;
  lMsgFinal: String;
  lRaise: Boolean;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := 1;
  lMsgFinal := '';

  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := True;
  SA.lpSecurityDescriptor := nil;

  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
//    if AValidar then
//      SI.wShowWindow := SW_SHOWMINNOACTIVE
//    else
      SI.wShowWindow := SW_SHOWMINNOACTIVE;
    SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
    SI.hStdOutput := StdOutPipeWrite;
    SI.hStdError := StdOutPipeWrite;

//    lCaminoServicoLiberacao := CaminhoServicoLiberacao;
//    if not (FileExists(lCaminoServicoLiberacao)) then
//      raise Exception.Create('App não encontrado !');

//    if AValidar then
//      Handle := CreateProcess(
//        nil, pChar(ExtractFileName(lCaminoServicoLiberacao + ' ' + '-Validar -Empresa=' + intTostr(XMLConfig.EmpresaLocal))),
//        nil, nil, True, 0, nil, pChar(ExtractFilePath(lCaminoServicoLiberacao)), SI, PI)
//    else
//      Handle := CreateProcess(
//        nil, pChar(ExtractFileName(lCaminoServicoLiberacao + ' ' + '-Empresa=' + intTostr(XMLConfig.EmpresaLocal))),
//        nil, nil, True, 0, nil, pChar(ExtractFilePath(lCaminoServicoLiberacao)), SI, PI);
////      Handle := CreateProcess(
////        pChar(ExtractFileName(lCaminoServicoLiberacao)), nil, nil, nil, True, 0,
////        nil, pChar(ExtractFilePath(lCaminoServicoLiberacao)), SI, PI);

    Handle := CreateProcess(
      nil, pChar(AComando),
      nil, nil, True, 0, nil, nil, SI, PI);

    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;

            lRaise := False;

            WasOK := WasOK and (not lRaise);

            lMsgFinal := lMsgFinal + String(Buffer);
            Buffer := '';
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, 2000);
        GetExitCodeProcess(PI.hProcess, ExitCode);

        Result := ExitCode;

      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
{$ENDIF}
end;

procedure TLmxCommandLine.LerTexto(const ATextoDescricao: string;
  var ATexto: string; const ACorFonte, ACorFundo: TLmxCor);
var
  lTexto: string;
begin
  Escrever(ATextoDescricao, False, ACorFonte, ACorFundo);
  Readln(lTexto);
  if lTexto <> '' then
    ATexto := lTexto;
end;

{$IFDEF MSWINDOWS}
function TLmxCommandLine.ObterLinhaAtual: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(FStdHandle, Result);
end;
{$ENDIF}

{ TLmxSystemParam }

function TLmxSystemParam.IndexParametro(const AParametro: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 1 to ParamCount do
  begin
    if UpperCase(AParametro) = UpperCase(ParamStr(I)) then
    begin
      Result := I;
      exit;
    end;
  end;
end;

function TLmxSystemParam.TemParametro(const AParametro: string): Boolean;
begin
  Result := (IndexParametro(AParametro) <> -1);
end;

function TLmxSystemParam.ValorParametro(const ANomeParametro: string): string;
var
  lIndice: Integer;
begin
  Result := '';
  lIndice := IndexParametro(ANomeParametro);
  if lIndice > -1 then
    Result := ValorParametro(lIndice + 1);
end;

function TLmxSystemParam.ValorParametro(const AIndex: Integer): string;
begin
  Result := ParamStr(AIndex);
end;

function TLmxSystemParam.ValorParametroAsInteger(
  const ANomeParametro: string): Integer;
begin
  Result := StrToIntDef(ValorParametro(ANomeParametro), 0);
end;

initialization
  FLmxCommandLine := TLmxCommandLine.Create;
  FLmxSystemParam := TLmxSystemParam.Create;

finalization
  FreeAndNil(FLmxSystemParam);
  FreeAndNil(FLmxCommandLine);

end.
