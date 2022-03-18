unit uLmxControleArquivo;

interface

uses
  SysUtils, XMLIntf, IOUtils, XMLDoc, RTTI, TypInfo, uLmxAttributes,
  uLmxHelper, uLmxControleConexao, uLmxControleIdentificacao, uLmxControleImpressora,
  uLmxControleParametros, uFiscalControleArquivo, uAtualizadorControleArquivo,
  uNotaControleArquivo;

type

  [TLmxAtributeSerializable('Configuracoes')]
  TLmxConfiguracoes = class
  private
    FImpressora: TLmxControleImpressora;
    FConexao: TLmxControleConexao;
    FIdentificacao: TLmxControleIdentificacao;
    FControleParametros: TLmxControleParametros;
    FControleFiscal: TFiscalControle;
    FControleAtualizador: TAtualizadorControle;
    FControleNota: TNotaControle;
    function GetNomeDocumentoConfiguracao : string;
  public
    constructor Create;
    destructor Destroy; override;

    property Impressora : TLmxControleImpressora read FImpressora;
    property Conexao : TLmxControleConexao read FConexao;
    property Identificacao : TLmxControleIdentificacao read FIdentificacao;
    property ControleParametros : TLmxControleParametros read FControleParametros;
    property ControleFiscal : TFiscalControle read FControleFiscal;
    property ControleAtualizador : TAtualizadorControle read FControleAtualizador;
    property ControleNota : TNotaControle read FControleNota;
    property NomeDocumentoConfiguracao : string read GetNomeDocumentoConfiguracao;

    function Salvar : Boolean;
  end;

function Configuracoes     : TLmxConfiguracoes;

implementation

var
  FConfiguracoes     : TLmxConfiguracoes;

function Configuracoes : TLmxConfiguracoes;
begin
  Result := FConfiguracoes;
end;


{ TLmxConfiguracoes }

constructor TLmxConfiguracoes.Create;
begin
  FImpressora := TLmxControleImpressora.Create;
  FConexao := TLmxControleConexao.Create;
  FIdentificacao := TLmxControleIdentificacao.Create;
  FControleParametros := TLmxControleParametros.Create;
  FControleFiscal := TFiscalControle.Create;
  FControleAtualizador := TAtualizadorControle.Create;
  FControleNota := TNotaControle.Create;
end;

destructor TLmxConfiguracoes.Destroy;
begin
  FreeAndNil(FControleFiscal);
  FreeAndNil(FControleParametros);
  FreeAndNil(FIdentificacao);
  FreeAndNil(FConexao);
  FreeAndNil(FImpressora);
  FreeAndNil(FControleAtualizador);
  FreeAndNil(FControleNota);
  inherited;
end;

function TLmxConfiguracoes.GetNomeDocumentoConfiguracao: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Configuracoes.xml';
end;

function TLmxConfiguracoes.Salvar: Boolean;
begin
  Result := SalvarEmArquivo(GetNomeDocumentoConfiguracao)
end;

{ TLmxControleConexao }

initialization
  FConfiguracoes     := TLmxConfiguracoes.Create;
  FConfiguracoes.CarregarDeArquivo(FConfiguracoes.GetNomeDocumentoConfiguracao);

finalization
  FreeAndNil(FConfiguracoes);

end.
