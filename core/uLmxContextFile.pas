unit uLmxContextFile;

interface

uses
  uLmxInterfaces, System.Classes, IdMultipartFormData;

type

  TLmxContextFile = class(TLmxContext, ILmxContextFile)
  private
    FIdMultipartFormData: TIdMultiPartFormDataStream;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CarregarStreamDeArquivo(out AStream : TFileStream);
    procedure SalvarStreamParaArquivo(const pStream : TFileStream);


    property IdMultipartFormData : TIdMultiPartFormDataStream read FIdMultipartFormData;
  end;

implementation

{ TLmxContextFile }

procedure TLmxContextFile.CarregarStreamDeArquivo(out AStream: TFileStream);
begin

end;

constructor TLmxContextFile.Create;
begin
  FIdMultipartFormData := TIdMultiPartFormDataStream.Create;
end;

destructor TLmxContextFile.Destroy;
begin
  FIdMultipartFormData.Free;
  inherited;
end;

procedure TLmxContextFile.SalvarStreamParaArquivo(const pStream: TFileStream);
begin

end;

end.
