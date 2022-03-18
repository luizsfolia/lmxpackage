unit uLmxComandoSql;

interface

uses
  Generics.Collections, uLmxInterfaces, SysUtils;

type

  TLmxGeradorConsultaCampo = class;
  TLmxGeradorConsultaTabela = class;
  TLmxGeradorConsultaJoin = class;

  TLmxGeradorConsultaTabelas = class(TObjectList<TLmxGeradorConsultaTabela>)
  public
    function GetCampos : string;

    function ToString: string; override;

    function ByNome(const ANome : string) : TLmxGeradorConsultaTabela;
    function ByCampo(const ANome : string) : TLmxGeradorConsultaCampo;
  end;

  TLmxGeradorConsultaCampos = class(TObjectList<TLmxGeradorConsultaCampo>)
  public

    function ByNome(const ANome : string) : TLmxGeradorConsultaCampo;
    function ToSql : string;
  end;

  TLmxGeradorConsultaJoins = class(TObjectList<TLmxGeradorConsultaJoin>)
  public
    function ToSql : string;
  end;

  TLmxGeradorConsultaJoin = class
  private
    FTabelaBase: TLmxGeradorConsultaTabela;
    FTabela: TLmxGeradorConsultaTabela;
    FCondicao: string;
    FAlias: string;
  public
    constructor Create(const ATabelaBase, ATabela : TLmxGeradorConsultaTabela;
      const AAlias : string; const ACondicao : string = '');
    destructor Destroy; override;

    property TabelaBase : TLmxGeradorConsultaTabela read FTabelaBase;
    property Tabela : TLmxGeradorConsultaTabela read FTabela;
    property Alias : string read FAlias;
    property Condicao : string read FCondicao;

    function ToString: string; override;
  end;

  TPDVGeradorConsultaLeftJoin = class(TLmxGeradorConsultaJoin)
  public
    function ToString: string; override;
  end;

  TLmxGeradorConsultaTabela = class
  private
    FNome: string;
    FTabelaFrom : TLmxGeradorConsultaTabela;
    FCampos : TLmxGeradorConsultaCampos;
    FAlias: string;
  public
    constructor Create(const ANome : string; const ATabelaFrom : TLmxGeradorConsultaTabela = nil;
      const AAlias : string = '');
    destructor Destroy; override;

    property Nome : string read FNome;
    property Alias : string read FAlias;
    property Campos : TLmxGeradorConsultaCampos read FCampos;

    function AddField(const ACalculo, ACampo : string) : TLmxGeradorConsultaCampo; overload;
    function AddField(const ACampo : string) : TLmxGeradorConsultaCampo; overload;

//    function AddDescricao(const ACampo, ADescricao : string) : TLmxGeradorConsultaTabela; overload;

    function ToString: string; override;
  end;

  TLmxGeradorConsultaCampo = class
  private
    FNome: string;
    FTabela : TLmxGeradorConsultaTabela;
    FCalculo: string;
    FDescricao: string;
    FVisivel: Boolean;
    FEditMask: string;
    FSequencia: Integer;
    FFiltrar: Boolean;
  public
    constructor Create(const ATabela : TLmxGeradorConsultaTabela);

    property Sequencia : Integer read FSequencia write FSequencia;
    property Nome : string read FNome write FNome;
    property Descricao : string read FDescricao write FDescricao;
    property Calculo : string read FCalculo write FCalculo;
    property Visivel : Boolean read FVisivel write FVisivel;
    property Tabela : TLmxGeradorConsultaTabela read FTabela;
    property EditMask : string read FEditMask write FEditMask;
    property Filtrar : Boolean read FFiltrar write FFiltrar;

    function GetNome(const AConsiderarAlias : Boolean = True): string;
    function GetDescricao : string;

    function ToString: string; override;
  end;

  TLmxGeradorConsulta = class(TInterfacedObject, ILmxGeradorConsulta)
  private
    FTabelacalculados : TLmxGeradorConsultaTabela;
    FTabela : TLmxGeradorConsultaTabela;
    FTabelas : TLmxGeradorConsultaTabelas;
    FInner : TLmxGeradorConsultaJoins;
    FLeft : TLmxGeradorConsultaJoins;
    FCampos : TLmxGeradorConsultaCampos;
    FCondicao : string;
    FOrderBy : string;
    FGroupBy : string;
//    FUSerId : Integer;
    FRequisicaoCliente : ILmxRequisicaoCliente;
  private
    procedure GerarConsulta;
//    function GetUserId: Integer;
//    procedure SetUserId(const pUserId: Integer);
  protected
    procedure DoGerarConsulta; virtual;
  public
//    function From(const ATabela : string; const AAlias : string = '') : TLmxGeradorConsultaTabela;
    function From(const ATabela : string; const AAlias : string = '') : ILmxGeradorConsulta;
    function AddCampo(const ATabelaOrAlias : string; const ACampo : string; const ADescricao : string = '') : ILmxGeradorConsulta;
    function AddCampoCalculado(const ACalculo, ACampo : string; const ADescricao : string = '') : ILmxGeradorConsulta;
    function DoCampoVisible(const ACampo : string; const AVisible : Boolean) : ILmxGeradorConsulta;
    function DoEditMaskCampo(const ACampo : string; const AEditMask : string) : ILmxGeradorConsulta;
    function DoCampoFiltravel(const ACampo : string; const AFiltravel : Boolean) : ILmxGeradorConsulta;

    constructor Create;
    destructor Destroy; override;
    function AddCondicao(const ACondicao: string) : ILmxGeradorConsulta;
    function AddOrderBy(const AOrderBy: string) : ILmxGeradorConsulta;
    function AddGroupBy(const AGroupBy: string) : ILmxGeradorConsulta;

    property Tabela : TLmxGeradorConsultaTabela read FTabela;
    function ToString: string; override;

    function leftJoin(const ATabela : string; const AAlias : string; const ACondicao : string) : ILmxGeradorConsulta;
    function InnerJoin(const ATabela : string; const AAlias : string; const ACondicao : string) : ILmxGeradorConsulta;

    function GetFieldFullName(const ACampo : string; out AFiltrar : Boolean) : string;
    function GetDescricaoCampo(const ACampo : string) : string;
    function GetCampoVisivel(const ACampo : string) : Boolean;
    function GetEditMask(const ACampo : string) : string;

//    procedure SetUserId(const pUserId : Integer);
//    function GetUserId : Integer;

    function GetRequisicaoCliente : ILmxRequisicaoCliente;
    procedure SetRequisicaoCliente(pRequisicao : ILmxRequisicaoCliente);

    class function GetConsulta(const pRequisicaoCliente : ILmxRequisicaoCliente = nil) : ILmxGeradorConsulta; virtual;

  end;


implementation

{ TLmxGeradorConsultaTabela }

function TLmxGeradorConsultaTabela.AddField(
  const ACampo: string): TLmxGeradorConsultaCampo;
//var
//  lCampo : TLmxGeradorConsultaCampo;
begin
  Result := AddField('', ACampo);
//  lCampo := TLmxGeradorConsultaCampo.Create(Self);
//  lCampo.Nome := ACampo;
//  lCampo.Descricao := ADescricao;
//  FCampos.Add(lCampo);
//  Result := Self;
end;

function TLmxGeradorConsultaTabela.AddField(const ACalculo, ACampo: string): TLmxGeradorConsultaCampo;
var
  lCampo : TLmxGeradorConsultaCampo;
begin
  lCampo := TLmxGeradorConsultaCampo.Create(Self);
  lCampo.Nome := ACampo;
//  lCampo.Descricao := ADescricao;
  lCampo.Calculo := ACalculo;
  FCampos.Add(lCampo);
  Result := lCampo;
end;

constructor TLmxGeradorConsultaTabela.Create(const ANome : string; const ATabelaFrom : TLmxGeradorConsultaTabela
  ;const AAlias : string);
begin
  FTabelaFrom := ATabelaFrom;
  FAlias := AAlias;
  FNome := ANome;
  FCampos := TLmxGeradorConsultaCampos.Create;
end;

destructor TLmxGeradorConsultaTabela.Destroy;
begin
  FreeAndNil(FCampos);
  inherited;
end;

function TLmxGeradorConsultaTabela.ToString: string;
begin
  Result := 'SELECT ' + FCampos.ToSql + ' FROM ' + FNome;
end;

{ TLmxGeradorConsultaCampo }

constructor TLmxGeradorConsultaCampo.Create(
  const ATabela: TLmxGeradorConsultaTabela);
begin
  FTabela :=  ATabela;
  FVisivel := True;
  FFiltrar := True;
end;

function TLmxGeradorConsultaCampo.GetDescricao: string;
begin
  Result := FNome;
  if FDescricao <> '' then
    Result := FDescricao;
end;

function TLmxGeradorConsultaCampo.GetNome(const AConsiderarAlias : Boolean): string;
var
  lAlias: string;
  lTabela: string;
begin
  if FCalculo <> '' then
  begin
    if AConsiderarAlias then
      Result := FCalculo + ' as ' + FNome
    else
      Result := FNome;
  end else begin
    lTabela := FTabela.Nome;
    lAlias := FTabela.Alias;
    if lAlias <> '' then
      lTabela := lAlias;
    if lTabela <> '' then
      lTabela := lTabela + '.';
    Result := lTabela + FNome;
    if (FNome <> '*') and AConsiderarAlias then
      Result := Result + ' as "' + lTabela + FNome + '"';
  end;
end;

function TLmxGeradorConsultaCampo.ToString: string;
begin
  Result := GetNome(True);
end;

{ TLmxGeradorConsulta }

function TLmxGeradorConsulta.AddCampo(const ATabelaOrAlias, ACampo: string; const ADescricao : string) : ILmxGeradorConsulta;
var
  lTabela: TLmxGeradorConsultaTabela;
  lCampo: TLmxGeradorConsultaCampo;
begin
  lCampo := nil;
  lTabela := FTabelas.ByNome(ATabelaOrAlias);
  if lTabela <> nil then
  begin
    lCampo := lTabela.AddField(ACampo);
    lCampo.Descricao := ADescricao;
  end;

  if lCampo <> nil then
    FCampos.Add(lCampo);
  Result := Self;
end;

function TLmxGeradorConsulta.AddCampoCalculado(const ACalculo, ACampo: string; const ADescricao : string) : ILmxGeradorConsulta;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  lCampo := FTabelacalculados.AddField(ACalculo, ACampo);
  lCampo.Descricao := ADescricao;

  FCampos.Add(lCampo);

  Result := Self;
end;

function TLmxGeradorConsulta.AddCondicao(const ACondicao: string) : ILmxGeradorConsulta;
begin
  FCondicao := ACondicao;

  Result := Self;
end;

function TLmxGeradorConsulta.AddGroupBy(const AGroupBy: string) : ILmxGeradorConsulta;
begin
  FGroupBy := AGroupBy;

  Result := Self;
end;

function TLmxGeradorConsulta.AddOrderBy(const AOrderBy: string) : ILmxGeradorConsulta;
begin
  FOrderBy := AOrderBy;

  Result := Self;
end;

function TLmxGeradorConsulta.DoCampoFiltravel(const ACampo: string;
  const AFiltravel: Boolean) : ILmxGeradorConsulta;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  lCampo := FTabelas.ByCampo(ACampo);
//  if lCampo = nil then
//    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    lCampo.Filtrar := AFiltravel;

  Result := Self;
end;

function TLmxGeradorConsulta.DoCampoVisible(const ACampo: string;
  const AVisible: Boolean) : ILmxGeradorConsulta;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo = nil then
    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    lCampo.Visivel := AVisible;

  Result := Self;
end;

function TLmxGeradorConsulta.DoEditMaskCampo(const ACampo, AEditMask: string) : ILmxGeradorConsulta;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo = nil then
    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    lCampo.EditMask := AEditMask;

  Result := Self;
end;

constructor TLmxGeradorConsulta.Create;
begin
  FLeft := TLmxGeradorConsultaJoins.Create;
  FInner := TLmxGeradorConsultaJoins.Create;
  FTabelas := TLmxGeradorConsultaTabelas.Create;
  FTabelacalculados := TLmxGeradorConsultaTabela.Create('');
  FCampos := TLmxGeradorConsultaCampos.Create(False);
end;

destructor TLmxGeradorConsulta.Destroy;
begin
  FreeAndNil(FCampos);
  FreeAndNil(FTabelacalculados);
  FreeAndNil(FTabelas);
  FreeAndNil(FLeft);
  FreeAndNil(FInner);
  inherited;
end;

procedure TLmxGeradorConsulta.DoGerarConsulta;
begin

end;

//function TLmxGeradorConsulta.From(
//  const ATabela: string; const AAlias : string): TLmxGeradorConsultaTabela;
//begin
//  FTabela := TLmxGeradorConsultaTabela.Create(ATabela, nil, AAlias);
//  Result := FTabela;
//  FTabelas.Add(FTabela);
//end;

function TLmxGeradorConsulta.From(
  const ATabela: string; const AAlias : string) : ILmxGeradorConsulta;
begin
  FTabela := TLmxGeradorConsultaTabela.Create(ATabela, nil, AAlias);
  FTabelas.Add(FTabela);

  Result := Self;
end;

procedure TLmxGeradorConsulta.GerarConsulta;
begin
  DoGerarConsulta;
end;

function TLmxGeradorConsulta.GetCampoVisivel(const ACampo: string): Boolean;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  Result := True;
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo = nil then
    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    Result := lCampo.Visivel;
end;

class function TLmxGeradorConsulta.GetConsulta(const pRequisicaoCliente : ILmxRequisicaoCliente): ILmxGeradorConsulta;
begin
  Result := Self.Create;
  Result.SetRequisicaoCliente(pRequisicaoCliente);
  Result.GerarConsulta;
end;

function TLmxGeradorConsulta.GetDescricaoCampo(const ACampo: string): string;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  Result := ACampo;
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo = nil then
    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    Result := lCampo.GetDescricao
end;

function TLmxGeradorConsulta.GetEditMask(const ACampo: string): string;
var
  lCampo: TLmxGeradorConsultaCampo;
begin
  Result := '';
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo = nil then
    lCampo := FTabelacalculados.Campos.ByNome(ACampo);
  if lCampo <> nil then
    Result := lCampo.EditMask;
end;

function TLmxGeradorConsulta.GetFieldFullName(const ACampo: string; out AFiltrar : Boolean): string;
var
  lCampo: TLmxGeradorConsultaCampo;
  lAlias: string;
begin
  Result := '';
  lCampo := FTabelas.ByCampo(ACampo);
  if lCampo <> nil then
  begin
    Result := lCampo.GetNome(False);
    AFiltrar := lCampo.Filtrar;
  end;
  if Result = '' then
  begin
    if FTabelacalculados.Campos.ByNome(ACampo) <> nil then
    begin
      Result := ACampo;
      AFiltrar := False;
    end else begin
      lAlias := FTabela.Nome;
      if FTabela.Alias <> '' then
        lAlias := FTabela.Alias;
      Result := lAlias + '.' +  ACampo;
    end;
  end;
end;

function TLmxGeradorConsulta.GetRequisicaoCliente: ILmxRequisicaoCliente;
begin
  Result := FRequisicaoCliente;
end;

//function TLmxGeradorConsulta.GetUserId: Integer;
//begin
//  Result := FUSerId;
//end;

function TLmxGeradorConsulta.InnerJoin(const ATabela, AAlias,
  ACondicao: string) : ILmxGeradorConsulta;
var
  lTabela: TLmxGeradorConsultaTabela;
begin
  lTabela := TLmxGeradorConsultaTabela.Create(ATabela, FTabela, AAlias);
  FLeft.Add(TLmxGeradorConsultaJoin.Create(FTabela, lTabela, AAlias, ACondicao));
//  Result := lTabela;
  FTabelas.Add(lTabela);

  Result := Self;
end;

function TLmxGeradorConsulta.leftJoin(const ATabela, AAlias,
  ACondicao: string) : ILmxGeradorConsulta;
var
  lTabela: TLmxGeradorConsultaTabela;
begin
  lTabela := TLmxGeradorConsultaTabela.Create(ATabela, FTabela, AAlias);
  FLeft.Add(TPDVGeradorConsultaLeftJoin.Create(FTabela, lTabela, AAlias, ACondicao));
//  Result := lTabela;
  FTabelas.Add(lTabela);
  REsult := Self;
end;

procedure TLmxGeradorConsulta.SetRequisicaoCliente(
  pRequisicao: ILmxRequisicaoCliente);
begin
  FRequisicaoCliente := pRequisicao;
end;

//procedure TLmxGeradorConsulta.SetUserId(const pUserId: Integer);
//begin
//  FUSerId := pUserId;
//end;

function TLmxGeradorConsulta.ToString: string;
var
  lAlias: string;
  lCamposCalculados: string;
  lCondicao: string;
  lOrderBy: string;
  lGroupBy: string;
  lFilter: string;
begin
  Result := '';
  if FTabela <> nil then
  begin
    lAlias := '';
    if FTabela.Alias <> '' then
      lAlias := ' AS ' + FTabela.Alias;

    lCamposCalculados := '';
    if FTabelacalculados.Campos.Count > 0 then
      lCamposCalculados := ',' + FTabelacalculados.Campos.ToSql;

    lCondicao := FCondicao;
    if lCondicao <> '' then
    begin
      lCondicao := ' WHERE ' + lCondicao;
      lFilter := ' %_FILTER_AND_OR_% ';
    end else
      lFilter := ' %_FILTER_WHERE_% ';

    lOrderBy := FOrderBy;
    if lOrderBy <> '' then
      lOrderBy := ' ORDER BY ' + lOrderBy;

    lGroupBy := FGroupBy;
    if lGroupBy <> '' then
      lGroupBy := ' GROUP BY ' + lGroupBy;

//    Result := 'SELECT ' + FTabelas.GetCampos + lCamposCalculados + ' FROM ' + FTabela.Nome + lAlias;
    Result := 'SELECT ' + FCampos.ToSql + ' FROM ' + FTabela.Nome + lAlias;
    Result := Result + FLeft.ToSql;
    Result := Result + lCondicao;
    Result := Result + lFilter;
    Result := Result + lGroupBy;
    Result := Result + lOrderBy;
  end;
end;

{ TLmxGeradorConsultaJoin }

constructor TLmxGeradorConsultaJoin.Create(const ATabelaBase,
  ATabela: TLmxGeradorConsultaTabela; const AAlias, ACondicao: string);
begin
  FTabelaBase := ATabelaBase;
  FTabela := ATabela;
  FAlias := AAlias;
  FCondicao := ACondicao;
end;

destructor TLmxGeradorConsultaJoin.Destroy;
begin
//  FreeAndNil(FTabela);
  inherited;
end;

function TLmxGeradorConsultaJoin.ToString: string;
var
  lAlias: string;
begin
  lAlias := FAlias;
  if lAlias <> '' then
    lAlias := ' AS ' + lAlias;
  Result := sLineBreak + ' INNER JOIN ' + FTabela.Nome + lAlias + sLineBreak +
    ' ON ' + FCondicao;
end;

{ TLmxGeradorConsultaCampos }

function TLmxGeradorConsultaCampos.ByNome(
  const ANome: string): TLmxGeradorConsultaCampo;
var
  lEnumCampos: TEnumerator;
  lNome: string;
  lEncontrado: Boolean;
begin
  Result := nil;
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
    begin
      lNome := lEnumCampos.Current.GetNome(False);
      if Length(lNome) > 31 then
        lEncontrado := (Pos(UpperCase(ANome), UpperCase(lNome)) > 0)
      else
        lEncontrado := (UpperCase(lEnumCampos.Current.GetNome(False)) = UpperCase(ANome));
      if lEncontrado then
      begin
        Result := lEnumCampos.Current;
        Exit;
      end;
    end;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

function TLmxGeradorConsultaCampos.ToSql: string;
var
  lEnumCampos: TEnumerator;
begin
  Result := '';
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + lEnumCampos.Current.ToString;
    end;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

{ TLmxGeradorConsultaJoins }

function TLmxGeradorConsultaJoins.ToSql: string;
var
  lEnumCampos: TEnumerator;
begin
  Result := '';
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
      Result := Result + lEnumCampos.Current.ToString;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

{ TPDVGeradorConsultaLeftJoin }

function TPDVGeradorConsultaLeftJoin.ToString: string;
var
  lAlias: string;
begin
  lAlias := FAlias;
  if lAlias <> '' then
    lAlias := ' AS ' + lAlias;
  Result := sLineBreak + ' LEFT OUTER JOIN ' + FTabela.Nome + lAlias + sLineBreak +
    ' ON ' + FCondicao;
end;

{ TLmxGeradorConsultaTabelas }

function TLmxGeradorConsultaTabelas.ByCampo(
  const ANome: string): TLmxGeradorConsultaCampo;
var
  lEnumCampos: TEnumerator;
  lCampo: TLmxGeradorConsultaCampo;
begin
  Result := nil;
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
    begin
      lCampo := lEnumCampos.Current.Campos.ByNome(ANome);
      if lCampo <> nil then
      begin
        Result := lCampo;
        Exit;
      end;
    end;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

function TLmxGeradorConsultaTabelas.ByNome(
  const ANome: string): TLmxGeradorConsultaTabela;
var
  lEnumCampos: TEnumerator;
begin
  Result := nil;
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
    begin
      if (UpperCase(lEnumCampos.Current.Nome) = UpperCase(ANome)) or (UpperCase(lEnumCampos.Current.Alias) = UpperCase(ANome)) then
      begin
        Result := lEnumCampos.Current;
        Exit;
      end;
    end;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

function TLmxGeradorConsultaTabelas.GetCampos: string;
var
  lEnumCampos: TEnumerator;
  lCampos: string;
begin
  Result := '';
  lEnumCampos := GetEnumerator;
  try
    while lEnumCampos.MoveNext do
    begin
      lCampos := lEnumCampos.Current.Campos.ToSql;
      if lCampos <> '' then
      begin
        if Result <> '' then
          Result := Result + ',';
        Result := Result + lCampos;
      end;
    end;
  finally
    FreeAndNil(lEnumCampos);
  end;
end;

function TLmxGeradorConsultaTabelas.ToString: string;
begin
  Result := '';
end;

end.
