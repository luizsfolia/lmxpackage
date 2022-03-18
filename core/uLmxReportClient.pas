unit uLmxReportClient;

interface

uses
  Winapi.Windows, SysUtils;

//  function EmitirRelatorio(AArquivoModelo, AArquivoDados, ANomeArquivoSaida, AIndexDataSet : ShortString;
//    AFormato : Integer) : Integer; stdcall; external 'lmxReports.dll';

type

  TLmxEmitirRelatorio = function(AArquivoModelo, AArquivoDados, ANomeArquivoSaida, AIndexDataSet : ShortString;
    AFormato : Integer) : Integer; stdcall;

  TLmxReportClient = class
  private
    FHandle : THandle;
    FLmxEmitirRelatorio : TLmxEmitirRelatorio;
    function CarregarDll : Boolean;
  public
    function Emitir(AArquivoModelo, AArquivoDados, ANomeArquivoSaida, AIndexDataSet : ShortString;
      AFormato : Integer) : Integer;
  end;

  function ReportClient :  TLmxReportClient;

implementation

var
  FReportClient :  TLmxReportClient;

function ReportClient :  TLmxReportClient;
begin
  Result := FReportClient;
end;


{ TLmxReportClient }

function TLmxReportClient.CarregarDll: Boolean;
begin
  if FHandle = 0 then
    FHandle := LoadLibrary('lmxReports.dll');
  Result := FHandle > 0;
end;

function TLmxReportClient.Emitir(AArquivoModelo, AArquivoDados,
  ANomeArquivoSaida, AIndexDataSet: ShortString; AFormato: Integer): Integer;
begin
  Result := 0;
  if CarregarDll then
  begin
    if @FLmxEmitirRelatorio  = nil then
      @FLmxEmitirRelatorio := GetProcAddress(FHandle, 'EmitirRelatorio');
    Result := FLmxEmitirRelatorio(AArquivoModelo, AArquivoDados, ANomeArquivoSaida, AIndexDataSet, AFormato);
  end;
end;

initialization
  FReportClient := TLmxReportClient.Create;
finalization
  FreeAndNil(FReportClient);

end.
