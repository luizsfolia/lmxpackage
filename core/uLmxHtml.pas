unit uLmxHtml;

interface

uses
  {$IFDEF MSWINDOWS}Xml.Win.msxmldom{$ELSE}Xml.omnixmldom{$ENDIF},
  uLmxAttributes, IOUtils, Generics.Collections, XmlIntf;

type

  ILmxHtmlPage = interface
  ['{3DF5DB46-C767-4743-BD20-654D08DE1395}']
    procedure SetHmtlFile(const pFile : string);
    procedure SetHmtlContent(const pContent : string);
    procedure SetHtmlContentType(const pContentType : string);
    procedure SetCaminhoServerBase(const pCaminhoserverBase : string);
    function GetHmtlFile : string;
    function GetHmtlContent : string;
    function GetHmtlContentType : string;
    function GetHmtlResponse : string;

    function GetLinkedValue(const pLinked : string) : string;
    procedure SetLinkedValue(const pLinked : string; const pValue : string);
  end;

  TLmxHtmlPage = class(TInterfacedObject, ILmxHtmlPage)
  private
    FHtmlFile : string;
    FHtmlContent : string;
    FHtmlContentType : string;
    FLinkedList : TDictionary<string,string>;
    procedure CarregarHtmlDeArquivo;
    procedure CarregarLinkedValues;
    function ContentReplaced : string;
  protected
    procedure SetHmtlFile(const pFile : string);
    procedure SetHmtlContent(const pContent : string);
    procedure SetHtmlContentType(const pContentType : string);
    procedure SetCaminhoServerBase(const pCaminhoserverBase : string);
    function GetHmtlFile : string;
    function GetHmtlContent : string;
    function GetHmtlContentType : string;

    function GetHmtlResponse : string;

    function GetLinkedValue(const pLinked : string) : string;
    procedure SetLinkedValue(const pLinked : string; const pValue : string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, Xml.xmldom, Xml.XMLDoc;

{ TLmxHtmlPage }

procedure TLmxHtmlPage.CarregarHtmlDeArquivo;
begin
  if FHtmlFile <> '' then
    SetHmtlContent(TFile.ReadAllText(FHtmlFile, TEncoding.UTF8));
end;

procedure TLmxHtmlPage.CarregarLinkedValues;
//var
//  lHtmlDocumento: TXMLDocument;
//  lLista: IDOMNodeList;
//  i : Integer;
//  lStringBuilder: TStringBuilder;
//  lInicio: Integer;
//  lIndice: Integer;
begin

//  lInicio := 0;
//  lIndice := FHtmlContent.IndexOf('lmx_linked', lInicio);
//  while lIndice > 0 do
//  begin
//    lInicio := lIndice;
//
//    FHtmlContent.LastIndexOf()
//    FHtmlContent.Substring()
//
//    SetLinkedValue();
//
//    lIndice := FHtmlContent.IndexOf('lmx_linked', lInicio);
//  end;
//
//  lStringBuilder := TStringBuilder.Create(FHtmlContent);
//  lStringBuilder.
//

//  lHtmlDocumento := TXmlDocument.Create(nil);
//  lHtmlDocumento.LoadFromXML(FHtmlContent);
//  lLista := lHtmlDocumento.DOMDocument.getElementsByTagName('lmx_link');
//
//  for i := 0 to lLista.length - 1 do
//  begin
//    SetLinkedValue(lLista.item[i].nodeName, lLista.item[i].nodeValue);
//  end;
end;

function TLmxHtmlPage.ContentReplaced: string;
var
  lEnum: TDictionary<string, string>.TPairEnumerator;
begin
  Result := FHtmlContent;
  lEnum := FLinkedList.GetEnumerator;
  try
    while lEnum.MoveNext do
    begin
      Result := Result.Replace('%' + lEnum.Current.Key + '%', lEnum.Current.Value, [rfReplaceAll]);
    end;
  finally
    lEnum.Free;
  end;
end;

constructor TLmxHtmlPage.Create;
begin
  FHtmlContentType := 'text/html; charset=utf-8; multipart/form-data; boundary=something';
  FLinkedList := TDictionary<string,string>.Create;
end;

destructor TLmxHtmlPage.Destroy;
begin
  FLinkedList.Free;
  inherited;
end;

function TLmxHtmlPage.GetHmtlContent: string;
begin
  REsult := FHtmlContent;
end;

//function TLmxHtmlPage.RetornoAsObject: TObject;
//begin
//  Result := nil;
//end;

function TLmxHtmlPage.GetHmtlContentType: string;
begin
  Result := FHtmlContentType;
end;

function TLmxHtmlPage.GetHmtlFile: string;
begin
  Result := FHtmlFile;
end;

function TLmxHtmlPage.GetHmtlResponse: string;
begin
  Result := ContentReplaced;
end;

function TLmxHtmlPage.GetLinkedValue(const pLinked: string): string;
begin
  FLinkedList.TryGetValue(pLinked, Result);
end;

procedure TLmxHtmlPage.SetHtmlContentType(const pContentType: string);
begin
  FHtmlContentType := pContentType;
end;

procedure TLmxHtmlPage.SetLinkedValue(const pLinked, pValue: string);
begin
  FLinkedList.AddOrSetValue(pLinked, pValue);
end;

procedure TLmxHtmlPage.SetCaminhoServerBase(const pCaminhoserverBase: string);
begin
  SetLinkedValue('server', pCaminhoserverBase);
end;

procedure TLmxHtmlPage.SetHmtlContent(const pContent: string);
begin
  FHtmlContent := pContent;
  CarregarLinkedValues;
end;

procedure TLmxHtmlPage.SetHmtlFile(const pFile: string);
begin
  FHtmlFile := pFile;
  CarregarHtmlDeArquivo;
end;

end.
