unit uLmxEmail;

interface

uses
  System.SysUtils, System.Classes, Mapi, Winapi.Windows, OleServer, OutlookXP, System.Win.ComObj,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, IdMessage, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type

  ILmxMensagemEmail = interface
    ['{B6545D0B-507F-43AA-B707-F39F2C1AC6E6}']
    function GetAssunto: string;
    function GetEnderecoDestino: string;
    function GetMensagem: string;
    procedure SetAssunto(const Value: string);
    procedure SetEnderecoDestino(const Value: string);
    procedure SetMensagem(const Value: string);
    property EnderecoDestino : string read GetEnderecoDestino write SetEnderecoDestino;
    property Assunto : string read GetAssunto write SetAssunto;
    property Mensagem : string read GetMensagem write SetMensagem;
  end;

  ILmxConfigEmail = interface
    ['{B78E6810-D235-4448-ACFD-8A5A4F1FFDF4}']

    function GetEndereco: string;
    function GetHost: string;
    function GetLogin: string;
    function GetPort: Integer;
    function GetSenha: string;
    procedure SetEndereco(const Value: string);
    procedure SetHost(const Value: string);
    procedure SetLogin(const Value: string);
    procedure SetPort(const Value: Integer);
    procedure SetSenha(const Value: string);

    property Endereco : string read GetEndereco write SetEndereco;
    property Senha : string read GetSenha write SetSenha;
    property Login : string read GetLogin write SetLogin;
    property Host : string read GetHost write SetHost;
    property Port : Integer read GetPort write SetPort;
  end;

  ILmxEmail = interface
    ['{6DDC5E7D-100E-4B5D-9957-C57611A0546D}']
    function EnviarEmail(const pConfig : ILmxConfigEmail; const pMensagem : ILmxMensagemEmail; pHandle : THandle = 0) : Boolean;
  end;

  TLmxConfigEmail = class(TInterfacedObject, ILmxConfigEmail)
  private
    FEndereco: string;
    FHost: string;
    FLogin: string;
    FPort: Integer;
    FSenha: string;

    function GetEndereco: string;
    function GetHost: string;
    function GetLogin: string;
    function GetPort: Integer;
    function GetSenha: string;
    procedure SetEndereco(const Value: string);
    procedure SetHost(const Value: string);
    procedure SetLogin(const Value: string);
    procedure SetPort(const Value: Integer);
    procedure SetSenha(const Value: string);

  public
    property Endereco : string read GetEndereco write SetEndereco;
    property Senha : string read GetSenha write SetSenha;
    property Login : string read GetLogin write SetLogin;
    property Host : string read GetHost write SetHost;
    property Port : Integer read GetPort write SetPort;
  end;


  TLmxMensagemEmail = class(TInterfacedObject, ILmxMensagemEmail)
  private
    FAssunto: string;
    FEnderecoDestino: string;
    FMensagem: string;
    function GetAssunto: string;
    function GetEnderecoDestino: string;
    function GetMensagem: string;
    procedure SetAssunto(const Value: string);
    procedure SetEnderecoDestino(const Value: string);
    procedure SetMensagem(const Value: string);
  public
    property EnderecoDestino : string read GetEnderecoDestino write SetEnderecoDestino;
    property Assunto : string read GetAssunto write SetAssunto;
    property Mensagem : string read GetMensagem write SetMensagem;
  end;

  TLmxEmail = class(TInterfacedObject, ILmxEmail)
  public
    function EnviarEmail(const pConfig : ILmxConfigEmail; const pMensagem : ILmxMensagemEmail; pHandle : THandle = 0) : Boolean;
  end;

  TLmxEmailUsandoIndy = class(TInterfacedObject, ILmxEmail)
  public
    function EnviarEmail(const pConfig : ILmxConfigEmail; const pMensagem : ILmxMensagemEmail; pHandle : THandle = 0) : Boolean;
  end;

  TLmxEmailOutlook = class(TInterfacedObject, ILmxEmail)
  private
//    function EnviarEmailPeloOutlookOpcao1(pHandle : THandle; const pEndereco, pAssunto, pTexto: string;
//      pAnexo: TStringList = nil; const pEnviarDireto: Boolean = False) : Boolean;
    function EnviarEmailPeloOutlookOpcao2(const pEndereco, pAssunto, pTexto: string) : Boolean;
  public
    function EnviarEmail(const pConfig : ILmxConfigEmail; const pMensagem : ILmxMensagemEmail; pHandle : THandle = 0) : Boolean;
  end;


implementation

{ TLmxConfigEmail }

function TLmxConfigEmail.GetEndereco: string;
begin
  Result := FEndereco;
end;

function TLmxConfigEmail.GetHost: string;
begin
  Result := FHost;
end;

function TLmxConfigEmail.GetLogin: string;
begin
  Result := FLogin;
end;

function TLmxConfigEmail.GetPort: Integer;
begin
  Result := FPort;
end;

function TLmxConfigEmail.GetSenha: string;
begin
  Result := FSenha;
end;

procedure TLmxConfigEmail.SetEndereco(const Value: string);
begin
  FEndereco := Value;
end;

procedure TLmxConfigEmail.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure TLmxConfigEmail.SetLogin(const Value: string);
begin
  FLogin := Value;
end;

procedure TLmxConfigEmail.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

procedure TLmxConfigEmail.SetSenha(const Value: string);
begin
  FSenha := Value;
end;

{ TLmxMensagemEmail }

function TLmxMensagemEmail.GetAssunto: string;
begin
  Result := FAssunto;
end;

function TLmxMensagemEmail.GetEnderecoDestino: string;
begin
  Result := FEnderecoDestino;
end;

function TLmxMensagemEmail.GetMensagem: string;
begin
  Result := FMensagem;
end;

procedure TLmxMensagemEmail.SetAssunto(const Value: string);
begin
  FAssunto := Value;
end;

procedure TLmxMensagemEmail.SetEnderecoDestino(const Value: string);
begin
  FEnderecoDestino := Value;
end;

procedure TLmxMensagemEmail.SetMensagem(const Value: string);
begin
  FMensagem := Value;
end;

{ TLmxEmail }

function TLmxEmail.EnviarEmail(const pConfig: ILmxConfigEmail;
  const pMensagem: ILmxMensagemEmail; pHandle : THandle) : Boolean;
begin
  REsult := False;
end;

{ TLmxEmailOutlook }


function TLmxEmailOutlook.EnviarEmail(const pConfig: ILmxConfigEmail;
  const pMensagem: ILmxMensagemEmail; pHandle : THandle) : Boolean;
begin
  Result := EnviarEmailPeloOutlookOpcao2(pMensagem.EnderecoDestino, pMensagem.Assunto, pMensagem.Mensagem);
end;

//function TLmxEmailOutlook.EnviarEmailPeloOutlookOpcao1(pHandle : THandle; const pEndereco, pAssunto, pTexto: string;
//  pAnexo: TStringList; const pEnviarDireto: Boolean): Boolean;
//type
//  TAttachAccessArray = array [0..0] of TMapiFileDesc;
//  PAttachAccessArray = ^TAttachAccessArray;
//var
//  MapiMessage: TMapiMessage;
//  MError: Cardinal;
//  Sender: TMapiRecipDesc;
//  PRecip, Recipients: PMapiRecipDesc;
//
//  Attachments: PAttachAccessArray;
//  x: integer;
//begin
//  Result := False;
//  MapiMessage.nRecipCount := 1;
//  GetMem( Recipients, MapiMessage.nRecipCount * Sizeof(TMapiRecipDesc) );
//  Attachments := nil;
//
//  try
//    with MapiMessage do
//    begin
//      { Assunto e Texto }
//      ulReserved := 0;
//      lpszSubject :=  PAnsichar(PChar( pAssunto ));
//      lpszNoteText := PAnsichar(PChar( pTexto ));
//
//      lpszMessageType := nil;
//      lpszDateReceived := nil;
//      lpszConversationID := nil;
//      flFlags := 0;
//      Sender.ulReserved := 0;
//      Sender.ulRecipClass := MAPI_ORIG;
//      Sender.lpszName := PAnsichar(PChar( '' ));
//      Sender.lpszAddress := PAnsichar(PChar( '' ));
//      Sender.ulEIDSize := 0;
//      Sender.lpEntryID := nil;
//      lpOriginator := @Sender;
//
//      { Endereço }
//      PRecip := Recipients;
//      PRecip^.ulReserved := 0;
//      PRecip^.ulRecipClass := MAPI_TO;
//
//      PRecip^.lpszName := PAnsichar(PChar( pEndereco ));
//      PRecip^.lpszAddress := StrNew( PAnsichar(PChar('SMTP:' + pEndereco ) ));
//
//      PRecip^.ulEIDSize := 0;
//      PRecip^.lpEntryID := nil;
//      //Inc( PRecip );
//      lpRecips := Recipients;
//
//      { Anexa os arquivos }
//      if pAnexo <> nil then
//      begin
//
//        { Deleta do pAnexo os arquivos que não existem }
//        for x := 0 to pAnexo.Count - 1 do
//          if not FileExists( pAnexo.Strings[x] ) then
//            pAnexo.Delete(x);
//
//        { Anexa os arquivos }
//        if pAnexo.Count > 0 then
//        begin
//          GetMem(Attachments, SizeOf(TMapiFileDesc) * pAnexo.Count);
//          for x := 0 to pAnexo.Count - 1 do
//          begin
//            Attachments[x].ulReserved := 0;
//            Attachments[x].flFlags := 0;
//            Attachments[x].nPosition := ULONG($FFFFFFFF);
//            Attachments[x].lpszPathName := StrNew( PAnsichar(PChar(pAnexo.Strings[x]) ));
//            Attachments[x].lpszFileName :=
//            StrNew( PAnsichar(PChar( ExtractFileName(pAnexo.Strings[x]) ) ));
//            Attachments[x].lpFileType := nil;
//          end;
//        end
//        {endif};
//        nFileCount := pAnexo.Count;
//        lpFiles := @Attachments^;
//      end;
//    end;
//
//    { Enviando o e-mail }
//    if not pEnviarDireto then
//      MError := MapiSendMail(0, pHandle, MapiMessage, MAPI_DIALOG or MAPI_LOGON_UI or MAPI_NEW_SESSION, 0)
//    else
//      MError := MapiSendMail(0, pHandle, MapiMessage, MAPI_LOGON_UI or MAPI_NEW_SESSION or MAPI_SENT, 0);
//
//    case MError of
//      MAPI_E_USER_ABORT: ;
//      { Mostra mensagem que o envio do e-mail foi abortado pelo usuário.
//      Portanto, não será mostrado nada }
//
//      SUCCESS_SUCCESS:
//      Result := True;
//    else
//      raise System.SysUtils.Exception.Create('Ocorreu um erro inesperado!'#13'Código: ' + IntToStr(MError));
//    end;
//  finally
//    PRecip := Recipients;
//    StrDispose( PRecip^.lpszAddress );
//    //Inc( PRecip );
//
//    FreeMem( Recipients, MapiMessage.nRecipCount * Sizeof(TMapiRecipDesc) );
//    for x := 0 to pAnexo.Count - 1 do
//    begin
//      StrDispose( Attachments[x].lpszPathName );
//      StrDispose( Attachments[x].lpszFileName );
//    end;
//  end;
//end;

function TLmxEmailOutlook.EnviarEmailPeloOutlookOpcao2(const pEndereco,
  pAssunto, pTexto: string): Boolean;
var
  OutlookApp: TOutlookApplication;
  email : MailItem;
begin
  OutlookApp := TOutlookApplication.Create(Nil);
  try
    email := OutlookApp.CreateItem(olMailItem) As MailItem;
    email.Subject := 'Envio automático';
    email.BodyFormat := olFormatHTML;
    email.HTMLBody := 'Este email é um <b>teste</b> para envio <b><span style="color:maroon;">automático</span></b>.';
    email.Importance := olImportanceNormal;

    email.Recipients.Add(pEndereco);
//    Result := email.Recipients.ResolveAll;
  //  if (email.Recipients.ResolveAll) then
    email.Send;
    Result := True;
  //  else begin
  //    email.Display(true);
  //    raise System.SysUtils.Exception.Create('Um ou mais destinatários não puderam ser resolvidos.'#13+
  //      'Reveja a informação e tente novamente.');
  //  end;
    OutlookApp.Disconnect;
  finally
    OutlookApp.Free;
  end;
end;

{ TLmxEmailUsandoIndy }

function TLmxEmailUsandoIndy.EnviarEmail(const pConfig: ILmxConfigEmail;
  const pMensagem: ILmxMensagemEmail; pHandle: THandle): Boolean;
var
  lIdSMTP : TIdSMTP;
  lIdMessage : TIdMessage;
  lIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  lIdSMTP := TIdSMTP.Create(nil);
  lIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(lIdSMTP);
  lIdMessage := TIdMessage.Create(lIdSMTP);
  try
		lIdSMTP.AuthType := satDefault;
		lIdSMTP.IOHandler := lIdSSLIOHandlerSocketOpenSSL;

    lIdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvSSLv2;
    lIdSSLIOHandlerSocketOpenSSL.SSLOptions.Mode := sslmClient;

		lIdSMTP.Host := pConfig.Host;
		lIdSMTP.Username:= pConfig.Login;
		lIdSMTP.Password := pConfig.Senha;
		lIdSMTP.Port := pConfig.Port;

//		lIdSMTP.Authenticate := True;
//			IdMessage1.MessageParts.Clear;
//		if ListBoxAnexos.Items.Count > 0 then
//		begin
//			for i:= 0 to ListBoxAnexos.Items.Count - 1 do
//				TIdAttachment.Create(IdMessage1.MessageParts, ListBoxAnexos.Items[i]);
//			end;
//
    lIdMessage.From.Address:= pConfig.Endereco;
		lIdMessage.Subject:= pMensagem.Assunto;
//
		lIdMessage.ContentType:='text/html';

    lIdMessage.Body.Add(pMensagem.Mensagem);

		lIdMessage.Recipients.EMailAddresses := pMensagem.EnderecoDestino;
//		lIdMessage.BccList.EMailAddresses := EdtBCC.Text;
//		lIdMessage.CCList.EMailAddresses := EdtCC.Text;
//
    lIdSMTP.Connect;
		lIdSMTP.Send(lIdMessage);
    Result := True;
    lIdSMTP.Disconnect;
  finally
    lIdSMTP.Free;

  end;
end;

end.
