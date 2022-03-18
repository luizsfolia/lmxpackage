unit uServerPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Samples.Spin, uLmx.Server, Vcl.ComCtrls, Vcl.ExtCtrls, System.NetEncoding,
  System.Threading;

type
  TForm1 = class(TForm)
    pgcServidor: TPageControl;
    tbsDadosServer: TTabSheet;
    lblStatusServidor: TLabel;
    Label1: TLabel;
    lblServerName: TLabel;
    Label2: TLabel;
    lblVersaoAtual: TLabel;
    btnAtivarServidor: TBitBtn;
    edtPortaServer: TSpinEdit;
    ctrlHabilitarLog: TCheckBox;
    BitBtn1: TBitBtn;
    chkLogSQL: TCheckBox;
    chkLogErros: TCheckBox;
    ctrlSalvarEmArquivo: TCheckBox;
    memComandos: TMemo;
    Splitter1: TSplitter;
    Label3: TLabel;
    edtPortaHttps: TSpinEdit;
    procedure btnAtivarServidorClick(Sender: TObject);
  private
    procedure DoMostrarNaTela(const pTexto : string);
    procedure DoAtualizarParametros;


  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uLmxHttpServer, uLmxAttributes;

{$R *.dfm}

procedure TForm1.btnAtivarServidorClick(Sender: TObject);
begin
  FormatSettings := TFormatSettings.Create(1046);

  DoAtualizarParametros;

  memComandos.Lines.Add('Iniciando Server...');
  memComandos.Lines.Add('Registrando comandos...');
  TLmxServer.Default.RegistrarComandos;
  TLmxServer.Default.RegistrarMiddleWares;
  TLmxServer.Default.RegistrarServices;
  memComandos.Lines.Add('Registrando DataBase...');
  TLmxServer.Default.RegistrarDataBase;
  memComandos.Lines.Add('Atualizando Registros...');
  TLmxServer.Default.RegistrarDefaults;
  TLmxServer.Default.Ativar(edtPortaServer.Value); //, edtPortaHttps.Value);
  memComandos.Lines.Add('Server Http Ativo na porta ' + edtPortaServer.Value.ToString);
  memComandos.Lines.Add('Server Https Ativo na porta ' + edtPortaHttps.Value.ToString);

  memComandos.Lines.Add('Voce pode tentar...');
  memComandos.Lines.Add('http://localhost:' + edtPortaServer.Text + '/Usuarios');
  memComandos.Lines.Add('http://localhost:' + edtPortaServer.Text + '/Usuarios/1');
  memComandos.Lines.Add('Ou...');
  memComandos.Lines.Add('https://localhost:' + edtPortaHttps.Text + '/Usuarios');
  memComandos.Lines.Add('https://localhost:' + edtPortaHttps.Text + '/Usuarios/1');

  BitBtn1.Enabled := not TLmxServer.Default.Ativo;

  lblStatusServidor.Caption := TLmxServer.Default.GetServidores;

end;

procedure TForm1.DoAtualizarParametros;
begin
  if ctrlHabilitarLog.Checked then
  begin
    TLmxServer.Default.SetOnProcessarComando(
      procedure(const AComando : TLmxInfoComandoServidor; const AInfoComandoRodado : TLmxInfoComandoProcessadoNoServidor)
      var
        lBody: string;
      begin
        lBody := '';
        if AComando.Tipo = cmPost then
          lBody := 'Body [' +  AComando.GetBodyAsString + ']';
        DoMostrarNaTela(AComando.Identificador + ' - ' + TNetEncoding.URL.Decode(AComando.RequestInfo.RawHTTPCommand) + ' - ' + AInfoComandoRodado.ResposneInfo.ContentText + ' - ' + lBody);
      end);
  end else
    TLmxServer.Default.SetOnProcessarComando(nil);

  if chkLogSQL.Checked then
  begin
    TLmxServer.Default.SetOnAlterarBancoDados(
      procedure (const ATabela : string; const AAlteracoes : string)
      begin
        DoMostrarNaTela('DataBase : ' + Atabela + ' - ' + AAlteracoes);
      end);
  end else
    TLmxServer.Default.SetOnAlterarBancoDados(nil);

  if chkLogErros.Checked then
  begin
    TLmxServer.Default.SetOnErroComando(
      procedure(const AComando : TLmxInfoComandoServidor; const pErro : string; const pDataBase : string)
      var
        lBody: string;
      begin
        lBody := '';
        if AComando.Tipo = cmPost then
          lBody := 'Body [' +  AComando.GetBodyAsString + ']';
        DoMostrarNaTela('Erro : ' + AComando.Identificador + ' - ' + TNetEncoding.URL.Decode(AComando.RequestInfo.RawHTTPCommand) + ' - ' + pErro + ' - ' + lBody);
      end);
  end else
    TLmxServer.Default.SetOnErroComando(nil);

  if chkLogSQL.Checked then
  begin
    TLmxServer.Default.SetOnExecuteQuery(
      procedure (const ASQL, AFiltro : string; const AQuantidadeRegistros : Integer)
      begin
        DoMostrarNaTela('SQL : ' + ASQL + ' - Filtro : ' + AFiltro);
      end);
  end else
    TLmxServer.Default.SetOnExecuteQuery(nil);

//  TLmxHttpOnErroComandoRef = reference to ;

//  if ctrlHabilitarLogErros.Checked then
//    WmsServer.HttpServer.OnErroComando := OnErroComando
//  else
//    WmsServer.HttpServer.OnErroComando := nil;

end;

procedure TForm1.DoMostrarNaTela(const pTexto: string);
begin
  TTask.Run(
  procedure
  begin
    TThread.Synchronize(
    TThread.CurrentThread,
    procedure
    begin
      memComandos.Lines.Add(FormatDateTime('[dd/MM/yyyy hh:mm:ssss] - ', Now) + pTexto);
    end);
  end);
end;

end.
