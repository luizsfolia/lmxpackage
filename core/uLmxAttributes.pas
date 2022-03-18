unit uLmxAttributes;

interface

uses
  System.SysUtils,
  System.Classes;

type

  ILmxRetorno = interface(IInterface)
  ['{3B901FFC-CFFB-4D64-92E8-DD0800C15A4E}']
    function RetornoAsObject : TObject;
  end;

  ILmxRetorno<T> = interface(ILmxRetorno)
  ['{B7FFD37C-78DF-4744-9978-E5E04D68E1F3}']
    function GetRetorno : T;
    procedure SetRetorno(const Value : T);
    property Retorno : T read GetRetorno write SetRetorno;
  end;

  TLmxInfoRetornoArquivo = class
  private
    FFileStream : TMemoryStream;
    FFileName : string;
    FReturnFileName : string;
  public
    constructor Create;
    destructor Destroy; override;

    function GetFileStream : TMemoryStream;
    procedure SetFileStream(const Value : TMemoryStream);

    function GetFileName : string;
    procedure SaveToFile(const pFileName : string);
    procedure LoadFromFile(const pFileName : string);
    procedure SetFileName(const pFileName : string);

    function GetReturnFileName : string;
    procedure SetReturnFileName(const pFileName : string);
  end;

  ILmxRetornoArquivo = interface(ILmxRetorno<TLmxInfoRetornoArquivo>)
  ['{B9A3F84C-E3EC-4E8F-B53E-694F812A7694}']

    procedure SaveToFile(const pFileName : string);
    function GetFileName : string;
    procedure SetFileName(const pFileName : string);

    function GetReturnFileName : string;
    procedure SetReturnFileName(const pFileName : string);
  end;

  ILmxEnumerable = interface(IInterface)
  ['{C56D32F7-A87C-4195-8378-8318644A7804}']
    procedure Clear;
    function Count : Integer;
    function GetItemObject(const AIndex: Integer): TObject;
    function GetNewItemObject: TObject;
    function GetDescription : string;
//    function GetItemClass : TClass;
//    function AddObject(const AObjeto : TObject) : Boolean;
  end;

  TLmxRetorno<T : class, constructor> = class(TInterfacedObject, ILmxRetorno, ILmxRetorno<T>)
  private
    FManterRetorno : Boolean;
    FRetorno : T;
    function GetRetorno : T;
    procedure SetRetorno(const Value : T);
  public
    constructor Create(const ARetorno : T; const pManterObjeto : Boolean = False); overload;
    constructor Create; overload;
    destructor Destroy; override;

    property Retorno : T read GetRetorno write SetRetorno;

    function RetornoAsObject : TObject;
  end;

  TLmxRetornoArquivo = class(TLmxRetorno<TLmxInfoRetornoArquivo>, ILmxRetornoArquivo)
  public
    function GetFileName : string;
    procedure SaveToFile(const pFileName : string);
    procedure LoadFromFile(const pFileName : string);
    procedure SetFileName(const pFileName : string);

    function GetReturnFileName : string;
    procedure SetReturnFileName(const pFileName : string);
  end;

  TLmxSerializationFormat = (sfLmx, sfChild);

  TLmxAttributeSerializable = class(TCustomAttribute)
  private
    FDescricao: string;
    FFormato : TLmxSerializationFormat;
  public
    constructor Create(const ADescricao: string = ''; const AFormato : TLmxSerializationFormat = sfLmx);
    property Descricao: string read FDescricao write FDescricao;
    property Formato : TLmxSerializationFormat read FFormato write FFormato;
  end;

  TLmxAttributeNoSerializable = class(TCustomAttribute);
  TLmxAttributeOnlyPKSerializable = class(TCustomAttribute);

  TLmxMetadataTipoCampo = (mtcAuto, mtcInteger, mtcChar, mtcVarchar, mtcBoolean, mtcNumeric, mtcDateTime,
    mtcBlobText);

  TLmxAttributeMetadata = class(TCustomAttribute)
  private
    FNomeCampo: string;
    FTipoCampo: TLmxMetadataTipoCampo;
    FNotNull: Boolean;
    FDecimais: Integer;
    FTamanho: Integer;
  public
    constructor Create; overload;
    constructor Create(const ANomeCampo: string; const ATipoCampo : TLmxMetadataTipoCampo = mtcAuto;
      const ANotNull : Boolean = False; const ATamanho : Integer = 0;
      const ADecimais : Integer = 0); overload;
    constructor Create(const ATamanho : Integer; const ADecimais : Integer = 0); overload;
    property NomeCampo: string read FNomeCampo write FNomeCampo;
    property TipoCampo : TLmxMetadataTipoCampo read FTipoCampo write FTipoCampo;
    property Tamanho : Integer read FTamanho write FTamanho;
    property Decimais : Integer read FDecimais write FDecimais;
    property NotNull : Boolean read FNotNull write FNotNull;
  end;

  TLmxAttributeMetadataZeroIsNull = class(TCustomAttribute);

  TLmxAttributeMetadataPrimaryKey = class(TCustomAttribute);

  TLmxAttributeMetadataForeignKey = class(TCustomAttribute)
  private
    FTabela : string;
    FCampo: string;
  public
    constructor Create; overload;
    constructor Create(const ATabela, ACampo : string); overload;

    property Tabela : string read FTabela write FTabela;
    property Campo : string read FCampo write FCampo;
  end;

  TLmxAttributeMetadataIndex = class(TCustomAttribute)
  private
    FTabela : string;
    FCampos: string;
    FNome: string;
  public
    constructor Create(const ATabela, ANome, ACampos : string);

    property Tabela : string read FTabela write FTabela;
    property Nome : string read FNome write FNome;
    property Campos : string read FCampos write FCampos;
  end;

  TLmxAttributeMetadataSequence = class(TCustomAttribute)
  private
    FCampo: string;
    FNome: string;
  public
    constructor Create; overload;
    constructor Create(const ACampo, ANome : string); overload;

    property Campo : string read FCampo write FCampo;
    property Nome : string read FNome write FNome;
  end;

  TLmxAttributeMetadataActive = class(TCustomAttribute);

  TLmxAttributeMetadataForeignKey<T> = class(TCustomAttribute)
  private
    FClasse : T;
  public
    property Classe : T read FClasse write FClasse;
  end;

  TLmxAttributeMetadataCalculado = class(TLmxAttributeMetadata)
  public
    constructor Create(const ANomeCampo: string; const ATipoCampo : TLmxMetadataTipoCampo;
      const ANotNull : Boolean = False; const ATamanho : Integer = 0;
      const ADecimais : Integer = 0); reintroduce;
  end;

  TLmxAttributeCaminhoRest = class(TCustomAttribute)
  private
    FCaminho: string;
  public
    constructor Create(const ACaminho: string = '');
    property Caminho: string read FCaminho write FCaminho;
  end;


  TLmxAttributeComandoMetodo = (cmGet, cmPost, cmPut, cmDelete);
  TLmxAttributeComandoMetodos = set of TLmxAttributeComandoMetodo;

  TLmxAttributeComandoBase = class(TCustomAttribute);

  TLmxAttributeComando = class(TLmxAttributeComandoBase)
  private
    FNome: string;
//    FMetodos: TLmxAttributeComandoMetodos;
  public
//    constructor Create(const ANome: string = ''; const AMetodos : TLmxAttributeComandoMetodos = []);
    constructor Create(const ANome: string = '');
    property Nome: string read FNome write FNome;

    function RotaSetParametros : string;
    function ParametrosDeRota : string;
    function PosParametrosRota : string;
//    property Metodos : TLmxAttributeComandoMetodos read FMetodos write FMetodos;
  end;

  TLmxAttributeComandoAutenticacaoObrigatoria = class(TLmxAttributeComandoBase);

  TLmxAttributeNoClear = class(TCustomAttribute);

  FromBody = class(TCustomAttribute);
  FromQuery = class(TCustomAttribute);
  FromHeader = class(TCustomAttribute);
  FromServices = class(TCustomAttribute);
  FromParams = class(TCustomAttribute);

  HttpPost = class(TCustomAttribute);
  HttpPut = class(TCustomAttribute);
  HttpGet = class(TCustomAttribute);
  HttpDelete = class(TCustomAttribute);

//  TLmxAttributeComandoProduce = (acpXml, acpJson);
//  TLmxAttributeComandoProduces = set of TLmxAttributeComandoProduce;

  TLmxAttributeComandoDescricao = class(TLmxAttributeComandoBase)
  private
    FDescription: string;
    FSummary: string;
  public
    constructor Create(const ASumary, ADescription : string);
    property Summary : string read FSummary write FSummary;
    property Description : string read FDescription write FDescription;
//    property Produces :
  end;

  TLmxAttributeComandoResult = class(TLmxAttributeComandoBase)
  private
    FResultCode: Integer;
    FDescription: string;
  public
    constructor Create(const AResultCode : Integer; const ADescription : string);
    property ResultCode : Integer read FResultCode write FResultCode;
    property Description : string read FDescription write FDescription;
  end;

  TLmxAttributeComandoInfo = class(TLmxAttributeComandoBase)
  private
//    FCaminho: string;
    FDescricao: string;
    FNome: string;
    FTipo: string;
    FSumario: string;
  public
    constructor Create(const pNome, pTipo, pSumario, pDescricao : string);

    property Nome : string read FNome write FNome;
//    property Caminho : string read FCaminho write FCaminho;
    property Tipo : string read FTipo write FTipo;
    property Sumario : string read FSumario write FSumario;
    property Descricao : string read FDescricao write FDescricao;
  end;

  TLmxAttributeComandoInfoParametro = class(TLmxAttributeComandoBase)
  private
    FTipoValor: string;
    FDescricao: string;
    FTipoParametro: string;
    FNome: string;
    FClasseBase: TClass;
  public
    constructor Create(const pNome, pTipoParametro, pTipoValor, pDescricao : string; const pClasseBase : TClass = nil);

    property Nome : string read FNome write FNome;
    property TipoParametro : string read FTipoParametro write FTipoParametro;
    property TipoValor : string read FTipoValor write FTipoValor;
    property Descricao : string read FDescricao write FDescricao;
    property ClasseBase : TClass read FClasseBase write FClasseBase;
  end;


implementation

{ TLmxAttributeSerializable }

constructor TLmxAttributeSerializable.Create(const ADescricao: string;  const AFormato : TLmxSerializationFormat);
begin
  FDescricao := ADescricao;
  FFormato := AFormato;
end;

{ TLmxAtributeMetadata }

constructor TLmxAttributeMetadata.Create(const ANomeCampo : string; const ATipoCampo : TLmxMetadataTipoCampo;
  const ANotNull : Boolean; const ATamanho, ADecimais : Integer);
begin
  FNomeCampo := ANomeCampo;
  FTipoCampo := ATipoCampo;
  FNotNull := ANotNull;
  FTamanho := ATamanho;
  FDecimais := ADecimais;
end;

constructor TLmxAttributeMetadata.Create;
begin

end;

constructor TLmxAttributeMetadata.Create(const ATamanho, ADecimais: Integer);
begin
  Create('', mtcAuto, False, ATamanho, ADecimais );
end;

{ TLmxAtributeMetadataForeignKey }

constructor TLmxAttributeMetadataForeignKey.Create;
begin

end;



constructor TLmxAttributeMetadataForeignKey.Create(const ATabela,
  ACampo: string);
begin
  Create;
  FTabela := ATabela;
  FCampo := ACampo;
end;

{ TLmxAtributeMetadataCalculado }

constructor TLmxAttributeMetadataCalculado.Create(const ANomeCampo: string;
  const ATipoCampo: TLmxMetadataTipoCampo; const ANotNull: Boolean;
  const ATamanho, ADecimais: Integer);
begin
  inherited Create(ANomeCampo, ATipoCampo, ANotNull, ATamanho, ADecimais);
end;

{ TLmxAttributeCaminhoRest }

constructor TLmxAttributeCaminhoRest.Create(const ACaminho: string);
begin
  FCaminho := ACaminho;
end;

{ TLmxAtributeComando }

constructor TLmxAttributeComando.Create(const ANome: string);
begin
  FNome := ANome;
//  FMetodos := AMetodos;
end;

{ TLmxAtributeMetadataIndex }

constructor TLmxAttributeMetadataIndex.Create(const ATabela, ANome,
  ACampos: string);
begin
  FNome := ANome;
  FTabela := ATabela;
  FCampos := ACampos;
end;

{ TLmxAttributeComandoDescricao }

constructor TLmxAttributeComandoDescricao.Create(const ASumary, ADescription: string);
begin
  FSummary := ASumary;
  FDescription := ADescription;
end;

{ TLmxAttributeComandoResult }

constructor TLmxAttributeComandoResult.Create(const AResultCode: Integer;
  const ADescription: string);
begin
  FResultCode := AResultCode;
  FDescription := ADescription;
end;

{ TLmxAttributeComandoInfo }

constructor TLmxAttributeComandoInfo.Create(const pNome, pTipo,
  pSumario, pDescricao: string);
begin
  FNome := pNome;
//  FCaminho := pCaminho;
  FTipo := pTipo;
  FSumario := pSumario;
  FDescricao := pDescricao;
end;

{ TLmxAttributeComandoInfoParametro }

constructor TLmxAttributeComandoInfoParametro.Create(const pNome,
  pTipoParametro, pTipoValor, pDescricao: string; const pClasseBase : TClass);
begin
  FNome := pNome;
  FTipoParametro := pTipoParametro;
  FTipoValor := pTipoValor;
  FDescricao := pDescricao;
  FClasseBase := pClasseBase;
end;

{ TLmxRetornot<T> }

constructor TLmxRetorno<T>.Create(const ARetorno : T; const pManterObjeto : Boolean);
begin
  FManterRetorno := pManterObjeto;
  FRetorno := ARetorno;
end;

constructor TLmxRetorno<T>.Create;
begin
  FRetorno := T.Create;
end;

destructor TLmxRetorno<T>.Destroy;
begin
  if not FManterRetorno then
    FRetorno.Free;
  inherited;
end;

function TLmxRetorno<T>.GetRetorno: T;
begin
  Result := FRetorno;
end;

function TLmxRetorno<T>.RetornoAsObject: TObject;
begin
  Result := FRetorno;
end;

procedure TLmxRetorno<T>.SetRetorno(const Value: T);
begin
  FRetorno := Value;
end;

function TLmxAttributeComando.ParametrosDeRota: string;
var
  lIndiceInicio: Integer;
  lIndiceFinal: Integer;
begin
  Result := '';
  lIndiceInicio := FNome.IndexOf('{');
  lIndiceFinal := FNome.IndexOf('}');
  if lIndiceInicio <> - 1 then
    Result := FNome.Substring(lIndiceInicio + 1, (lIndiceFinal - (lIndiceInicio + 1)));
end;

function TLmxAttributeComando.PosParametrosRota: string;
var
  lIndiceFinal: Integer;
begin
  Result := '';
  lIndiceFinal := FNome.IndexOf('}');
  if lIndiceFinal <> - 1 then
    Result := FNome.Substring(lIndiceFinal + 1, FNome.Length);
end;

function TLmxAttributeComando.RotaSetParametros: string;
var
  lIndiceInicio: Integer;
begin
  Result := FNome;
  lIndiceInicio := FNome.IndexOf('{');
  if lIndiceInicio <> - 1 then
    Result := FNome.Substring(1, lIndiceInicio);

end;

{ TLmxAttributeMetadataSequence }

constructor TLmxAttributeMetadataSequence.Create(const ACampo, ANome: string);
begin
  FCampo := ACampo;
  FNome := ANome;
end;

constructor TLmxAttributeMetadataSequence.Create;
begin

end;

{ TLmxInfoRetornoArquivo }

constructor TLmxInfoRetornoArquivo.Create;
begin
  FFileStream := TMemoryStream.Create;
end;

destructor TLmxInfoRetornoArquivo.Destroy;
begin
  FFileStream.Free;
  inherited;
end;

function TLmxInfoRetornoArquivo.GetFileName: string;
begin
  Result := FFileName;
end;

function TLmxInfoRetornoArquivo.GetFileStream: TMemoryStream;
begin
  Result := FFileStream;
end;

function TLmxInfoRetornoArquivo.GetReturnFileName: string;
begin
  Result := FReturnFileName;
  if FReturnFileName = '' then
    REsult := ExtractFileName(FFileName);
end;

procedure TLmxInfoRetornoArquivo.LoadFromFile(const pFileName: string);
begin
  if FileExists(pFileName) then
    FFileStream.LoadFromFile(pFileName);
end;

procedure TLmxInfoRetornoArquivo.SaveToFile(const pFileName: string);
begin
  FFileName := pFileName;
  Self.GetFileStream.SaveToFile(pFileName);
end;

procedure TLmxInfoRetornoArquivo.SetFileName(const pFileName: string);
begin
  FFileName := pFileName;
end;

procedure TLmxInfoRetornoArquivo.SetFileStream(const Value: TMemoryStream);
begin
  Value.Position := 0;
  FFileStream.CopyFrom(Value, Value.Size);
end;

procedure TLmxInfoRetornoArquivo.SetReturnFileName(const pFileName: string);
begin
  FReturnFileName := pFileName;
end;

//{ TLmxRetornoArquivo }
//
//function TLmxRetornoArquivo.GetFileName: string;
//begin
//end;
//
//procedure TLmxRetornoArquivo.SaveToFile(const pFileName: string);
//begin
//  FFileName := pFileName;
//  Self.GetRetorno.GetFileStream.SaveToFile(pFileName);
//end;

{ TLmxRetornoArquivo }

function TLmxRetornoArquivo.GetFileName: string;
begin
  Result := Self.GetRetorno.GetFileName;
end;

function TLmxRetornoArquivo.GetReturnFileName: string;
begin
  Result := Self.GetRetorno.GetReturnFileName;
end;

procedure TLmxRetornoArquivo.LoadFromFile(const pFileName: string);
begin
  Self.GetRetorno.LoadFromFile(pFileName);
end;

procedure TLmxRetornoArquivo.SaveToFile(const pFileName: string);
begin
  Self.GetRetorno.SaveToFile(pFileName);
end;

procedure TLmxRetornoArquivo.SetFileName(const pFileName: string);
begin
  Self.GetRetorno.SetFileName(pFileName);
end;

procedure TLmxRetornoArquivo.SetReturnFileName(const pFileName: string);
begin
  Self.GetRetorno.SetReturnFileName(pFileName);
end;


end.
