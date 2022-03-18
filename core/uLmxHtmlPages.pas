unit uLmxHtmlPages;

interface

uses
  uLmxHttpServer, uLmxAttributes, uLmxHtml,
  System.SysUtils, System.IOUtils;

type

  THttpPages = class(TLmxServerComand)
  protected
    function GetHtmlFileIndex(const pPage : string) : string;
    function GetHtmlFile(const pFile : string) : string;
  public
//    [HttpGet]
//    [TLmxAttributeComando('/{Page}')]
//    function Get(
//      [FromParams] const Page : string) : string;
  end;

implementation

{ THttpPages }

function THttpPages.GetHtmlFile(const pFile: string): string;
var
  lFolder : string;
  lFileName: string;
begin
  Result := '';
  lFileName := pFile + '.html';
  lFolder := ExtractFilePath(ParamStr(0)) + 'Pages\';
  if TDirectory.Exists(lFolder) and TFile.Exists(lFolder + lFileName) then
  begin
    Result := lFolder + lFileName;
  end;
end;

function THttpPages.GetHtmlFileIndex(const pPage: string): string;
var
  lFolder : string;
  lFileName: string;
begin
  Result := '';
  lFileName := pPage;
  lFolder := ExtractFilePath(ParamStr(0)) + 'Pages\';
  if TDirectory.Exists(lFolder) and TFile.Exists(lFolder + pPage + '\Index.html') then
  begin
    Result := lFolder + pPage + '\Index.html';
  end;
end;

end.
