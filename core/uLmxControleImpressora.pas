unit uLmxControleImpressora;

interface

uses
  SysUtils, uLmxAttributes;

type

  [TLmxAttributeSerializable('Impressora')]
  TLmxControleImpressora = class
  private
    FClasseImpressora: string;
    FQuantidadeColunas: Integer;
    FPortaComunicacao: string;
    FConcomitante: Boolean;
    FVelocidade: Integer;
    FQrCodeNivelCorrecao: Integer;
    FQrCodeTamanho: Integer;
    FQrCodeVersao: Integer;
    FImpressaoComprimida: Boolean;
    FQrCodeAltura: Integer;
    FQrCodePosicaoCaracteres: Integer;
    FQRCodeFonte: Integer;
    FQrCodeMargem: Integer;
    FBarCodeMargem: Integer;
    FBarCodeTamanho: Integer;
    FBarCodeAltura: Integer;
    FBarCodeFonte: Integer;
    FBarCodePosicaoCaracteres: Integer;
  public
    constructor Create;
    [TLmxAttributeSerializable('ClasseImpressora')]
    property ClasseImpressora : string read FClasseImpressora write FClasseImpressora;
    [TLmxAttributeSerializable('QuantidadeColunas')]
    property QuantidadeColunas : Integer read FQuantidadeColunas write FQuantidadeColunas;
    [TLmxAttributeSerializable('PortaComunicacao')]
    property PortaComunicacao : string read FPortaComunicacao write FPortaComunicacao;
    [TLmxAttributeSerializable('Velocidade')]
    property Velocidade : Integer read FVelocidade write FVelocidade;
    [TLmxAttributeSerializable('Concomitante')]
    property Concomitante : Boolean read FConcomitante write FConcomitante;
    [TLmxAttributeSerializable('QrCode.Altura')]
    property QrCodeAltura : Integer read FQrCodeAltura write FQrCodeAltura;
    [TLmxAttributeSerializable('QrCode.Tamanho')]
    property QrCodeTamanho : Integer read FQrCodeTamanho write FQrCodeTamanho;
    [TLmxAttributeSerializable('QrCode.NivelCorrecao')]
    property QrCodeNivelCorrecao : Integer read FQrCodeNivelCorrecao write FQrCodeNivelCorrecao;
    [TLmxAttributeSerializable('QrCode.Versao')]
    property QrCodeVersao : Integer read FQrCodeVersao write FQrCodeVersao;
    [TLmxAttributeSerializable('QrCode.PosicaoCaracteres')]
    property QrCodePosicaoCaracteres : Integer read FQrCodePosicaoCaracteres write FQrCodePosicaoCaracteres;
    [TLmxAttributeSerializable('QrCode.Fonte')]
    property QRCodeFonte : Integer read FQRCodeFonte write FQRCodeFonte;
    [TLmxAttributeSerializable('QrCode.Margem')]
    property QrCodeMargem : Integer read FQrCodeMargem write FQrCodeMargem;
    [TLmxAttributeSerializable('Impressao.Comprimida')]
    property ImpressaoComprimida : Boolean read FImpressaoComprimida write FImpressaoComprimida;
    [TLmxAttributeSerializable('BarCode.Altura')]
    property BarCodeAltura : Integer read FBarCodeAltura write FBarCodeAltura;
    [TLmxAttributeSerializable('BarCode.Tamanho')]
    property BarCodeTamanho : Integer read FBarCodeTamanho write FBarCodeTamanho;
    [TLmxAttributeSerializable('BarCode.PosicaoCaracteres')]
    property BarCodePosicaoCaracteres : Integer read FBarCodePosicaoCaracteres write FBarCodePosicaoCaracteres;
    [TLmxAttributeSerializable('BarCode.Fonte')]
    property BarCodeFonte : Integer read FBarCodeFonte write FBarCodeFonte;
    [TLmxAttributeSerializable('BarCode.Margem')]
    property BarCodeMargem : Integer read FBarCodeMargem write FBarCodeMargem;
  end;


implementation

{ TLmxControleImpressora }

constructor TLmxControleImpressora.Create;
begin
  FClasseImpressora := 'TLmxImpressoraNenhuma';
  FVelocidade := 115200;
end;

end.
