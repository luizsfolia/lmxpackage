unit uLmxUtilsFmx;

interface

uses
  System.Rtti, FMX.Grid, Generics.Collections, System.SysUtils, FMX.Graphics,
  System.Types;

type

  TOnFormatarCelula<T : class> = reference to procedure(const pColuna : TColumn; const Canvas: TCanvas; const Bounds: TRectF; const pObjeto : T);

  TOnDrawColumnCell = procedure (Sender: TObject;
    const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
    const Row: Integer; const Value: TValue; const State: TGridDrawStates) of object;

  TLmxFmxGridAttribute = class(TCustomAttribute);

  TLmxFmxGridDescricaoAttribute = class(TLmxFmxGridAttribute)
  private
    FDescricao: string;
  public
    constructor Create(const pDescricao : string);
    property Descricao : string read FDescricao write FDescricao;
  end;

  TLmxFmxGridFormatoMoedaAttribute = class(TLmxFmxGridAttribute)

  end;

//  TLmxFmxGridFormatacaoCondicionalAttribute = class(TLmxFmxGridAttribute)
//  private
//    FOnFormatar: TOnFormatarCelula;
//  public
//    constructor Create(const pOnFormatar : TOnFormatarCelula);
//    property OnFormatar : TOnFormatarCelula read FOnFormatar write FOnFormatar;
//  end;

//  TLmxFmxGridFormatacaoCelulaAttribute = class(TCustomAttribute)
//  private
//    FOnDrawColumnCell: TOnDrawColumnCell;
//  public
//    constructor Create(const pOnDrawColumnCell : TOnDrawColumnCell);
//    property OnDrawColumnCell : TOnDrawColumnCell read FOnDrawColumnCell write FOnDrawColumnCell;
//  end;

  IPreenchimento<T : class> = interface
    ['{F8807783-3389-4461-B5A9-0B6144307B6E}']
    function SetStringGrid(const pStringGrid : TStringGrid) : IPreenchimento<T>;
    function SetLista(const pLista : TList<T>) : IPreenchimento<T>;
    function SetGuardarObjetonaLinha : IPreenchimento<T>;

    function SetFormatacaoCondicional(const pCampo : string; const pOnFormatar : TOnFormatarCelula<T>) : IPreenchimento<T>;
    function Preencher : IPreenchimento<T>;
  end;

  TLmxFmxPreenchimento<T : class> = class(TInterfacedObject, IPreenchimento<T>)
  private
    FStringGrid : TStringGrid;
    FLista : TList<T>;
    FDicionarioFormatacao : TDictionary<string, TOnFormatarCelula<T>>;
    FGuardarObjetonaLinha : Boolean;

    procedure OnDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
  public
    constructor Create;
    destructor Destroy; override;

    function SetStringGrid(const pStringGrid : TStringGrid) : IPreenchimento<T>;
    function SetLista(const pLista : TList<T>) : IPreenchimento<T>;
    function SetGuardarObjetonaLinha : IPreenchimento<T>;

    function SetFormatacaoCondicional(const pCampo : string; const pOnFormatar : TOnFormatarCelula<T>) : IPreenchimento<T>;
    function Preencher : IPreenchimento<T>;
  end;


  TLmxUtilsFmx = class
  public
//    class procedure PreencherStringGrid<T : class>(const pStringGrid : TStringGrid; const pLista : TList<T>);
    class function DefinirPreenchimento<T : class>(const pStringGrid : TStringGrid; const pLista : TList<T>) : IPreenchimento<T>;
    class function TentaObterObjetoLinha<T : class>(const pStringGrid : TStringGrid; const pRow : Integer; out AObjeto : T) : Boolean;
  end;


implementation


{ TLmxUtilsFmx }

//class procedure TLmxUtilsFmx.PreencherStringGrid<T>(const pStringGrid: TStringGrid;
//  const pLista: TList<T>);
//var
//  lRttiContext: TRttiContext;
//  lType: TRttiType;
//  lAtributo: TCustomAttribute;
//  lProperty: TRttiProperty;
//  lPropertyes : TArray<TRttiProperty>;
//  lColunaNova: TColumn;
//  lContagemColuna: Integer;
//  lContagemLinha: Integer;
//  lItem: TObject;
//  lDescricao: string;
//  lFormatoMoeda: Boolean;
//  lEvento: TOnFormatarCelula;
//  lIsFmx : Boolean;
//begin
//  pStringGrid.BeginUpdate;
//  pStringGrid.ClearColumns;
//  lRttiContext := TRttiContext.Create;
//  try
//    lType := lRttiContext.GetType(T);
//    pStringGrid.RowCount := pLista.Count;
//
//    lPropertyes := lType.GetProperties;
//
//    for lProperty in lPropertyes do
//    begin
//
//      lDescricao := lProperty.Name;
//      lFormatoMoeda := False;
//      lEvento := nil;
//      lIsFmx := False;
//
//      for lAtributo in lProperty.GetAttributes do
//      begin
//        if (not lIsFmx) and (lAtributo is TLmxFmxGridAttribute) then
//          lIsFmx := True;
//        if lAtributo is TLmxFmxGridDescricaoAttribute then
//          lDescricao := TLmxFmxGridDescricaoAttribute(lAtributo).Descricao;
//        if lAtributo is TLmxFmxGridFormatoMoedaAttribute then
//          lFormatoMoeda := True;
//        if lAtributo is TLmxFmxGridFormatacaoCondicionalAttribute then
//          lEvento := TLmxFmxGridFormatacaoCondicionalAttribute(lAtributo).OnFormatar;
//      end;
//
////      if lIsFmx then
////      begin
//        case lProperty.PropertyType.TypeKind of
//          tkUnknown: ;
//          tkInteger: lColunaNova := TIntegerColumn.Create(pStringGrid);
//          tkChar: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkEnumeration: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkFloat:
//            if lFormatoMoeda then
//            begin
//              lColunaNova := TCurrencyColumn.Create(pStringGrid)
//            end
//            else
//              lColunaNova := TFloatColumn.Create(pStringGrid);
//          tkString: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkSet: ;
//          tkClass: ;
//          tkMethod: ;
//          tkWChar: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkLString: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkWString: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkVariant: ;
//          tkArray: ;
//          tkRecord: ;
//          tkInterface: ;
//          tkInt64: ;
//          tkDynArray: ;
//          tkUString: lColunaNova := TStringColumn.Create(pStringGrid);
//          tkClassRef: ;
//          tkPointer: ;
//          tkProcedure: ;
//          tkMRecord: ;
//        end;
//        lColunaNova.Header := lDescricao;
//
//        if Assigned(lEvento) then
//          lEvento(lColunaNova);
//
//        pStringGrid.AddObject(lColunaNova);
//        lColunaNova.Visible := lIsFmx;
////      end;
//    end;
//
//    lContagemLinha := 0;
//    for lItem in pLista do
//    begin
//      lContagemColuna := 0;
//      for lProperty in lPropertyes do
//      begin
//        case lProperty.PropertyType.TypeKind of
//          tkUnknown: ;
//          tkInteger: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsInteger.ToString;
//          tkChar: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkEnumeration: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsInteger.ToString;
//          tkFloat: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsExtended.ToString;
//          tkString: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkSet: ;
//          tkClass: ;
//          tkMethod: ;
//          tkWChar: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkLString: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkWString: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkVariant: ;
//          tkArray: ;
//          tkRecord: ;
//          tkInterface: ;
//          tkInt64: ;
//          tkDynArray: ;
//          tkUString: pStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
//          tkClassRef: ;
//          tkPointer: ;
//          tkProcedure: ;
//          tkMRecord: ;
//        end;
//
//        Inc(lContagemColuna);
//      end;
//      Inc(lContagemLinha);
//    end;
//  finally
//    lRttiContext.Free;
//    pStringGrid.EndUpdate;
//  end;
//end;

{ TLmxUtilsFmx }

class function TLmxUtilsFmx.DefinirPreenchimento<T>(
  const pStringGrid: TStringGrid; const pLista: TList<T>): IPreenchimento<T>;
begin
  Result := TLmxFmxPreenchimento<T>.Create;
  Result.SetStringGrid(pStringGrid);
  REsult.SetLista(pLista);
end;

class function TLmxUtilsFmx.TentaObterObjetoLinha<T>(
  const pStringGrid: TStringGrid; const pRow : Integer; out AObjeto: T): Boolean;
var
  lValor: string;
  lIntObjeto: Integer;
begin
  AObjeto := nil;
  lValor := pStringGrid.Cells[pStringGrid.ColumnCount - 1, pRow];
  if lValor <> '' then
  begin
    lIntObjeto := lValor.ToInteger;
    AObjeto := T(lIntObjeto);
  end;
  Result := AObjeto <> nil;
end;

{ TLmxFmxGridDescricaoAttribute }

constructor TLmxFmxGridDescricaoAttribute.Create(const pDescricao: string);
begin
  FDescricao := pDescricao;
end;

//{ TLmxFmxGridFormatacaoCondicionalAttribute }
//
//constructor TLmxFmxGridFormatacaoCondicionalAttribute.Create(
//  const pOnFormatar: TOnFormatarCelula);
//begin
//  FOnFormatar := pOnFormatar;
//end;
//
//{ TLmxFmxGridFormatacaoCelulaAttribute }
//
//constructor TLmxFmxGridFormatacaoCelulaAttribute.Create(
//  const pOnDrawColumnCell: TOnDrawColumnCell);
//begin
//  FOnDrawColumnCell := pOnDrawColumnCell;
//end;

{ TLmxFmxPreenchimento<T> }

constructor TLmxFmxPreenchimento<T>.Create;
begin
  FDicionarioFormatacao := TDictionary<string,TOnFormatarCelula<T>>.Create;
end;

destructor TLmxFmxPreenchimento<T>.Destroy;
begin
  FDicionarioFormatacao.Free;
  inherited;
end;

procedure TLmxFmxPreenchimento<T>.OnDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  lObjeto: T;
  lEvento: TOnFormatarCelula<T>;
begin
  if FDicionarioFormatacao.TryGetValue(Column.Header, lEvento) then
  begin
    if TLmxUtilsFmx.TentaObterObjetoLinha<T>(TStringGrid(Sender), Row, lObjeto) then
      lEvento(Column, Canvas, Bounds, lObjeto);
  end;
end;

function TLmxFmxPreenchimento<T>.Preencher : IPreenchimento<T>;
var
  lRttiContext: TRttiContext;
  lType: TRttiType;
  lAtributo: TCustomAttribute;
  lProperty: TRttiProperty;
  lPropertyes : TArray<TRttiProperty>;
  lColunaNova: TColumn;
  lContagemColuna: Integer;
  lContagemLinha: Integer;
  lItem: TObject;
  lDescricao: string;
  lFormatoMoeda: Boolean;
  lEvento: TOnFormatarCelula<T>;
  lIsFmx : Boolean;
begin
  FStringGrid.BeginUpdate;

  if Assigned(FStringGrid.OnDrawColumnCell) then
    FStringGrid.OnDrawColumnCell := nil;

  FStringGrid.ClearColumns;
  lRttiContext := TRttiContext.Create;
  try
    lType := lRttiContext.GetType(T);
    FStringGrid.RowCount := FLista.Count;

    lPropertyes := lType.GetProperties;

    for lProperty in lPropertyes do
    begin

      lDescricao := lProperty.Name;
      lFormatoMoeda := False;
      lEvento := nil;
      lIsFmx := False;

      for lAtributo in lProperty.GetAttributes do
      begin
        if (not lIsFmx) and (lAtributo is TLmxFmxGridAttribute) then
          lIsFmx := True;
        if lAtributo is TLmxFmxGridDescricaoAttribute then
          lDescricao := TLmxFmxGridDescricaoAttribute(lAtributo).Descricao;
        if lAtributo is TLmxFmxGridFormatoMoedaAttribute then
          lFormatoMoeda := True;
//        if lAtributo is TLmxFmxGridFormatacaoCondicionalAttribute then
//          lEvento := TLmxFmxGridFormatacaoCondicionalAttribute(lAtributo).OnFormatar;
      end;

//      if lIsFmx then
//      begin
        case lProperty.PropertyType.TypeKind of
          tkUnknown: ;
          tkInteger: lColunaNova := TIntegerColumn.Create(FStringGrid);
          tkChar: lColunaNova := TStringColumn.Create(FStringGrid);
          tkEnumeration: lColunaNova := TStringColumn.Create(FStringGrid);
          tkFloat:
            if lFormatoMoeda then
            begin
              lColunaNova := TCurrencyColumn.Create(FStringGrid);
            end
            else
              lColunaNova := TFloatColumn.Create(FStringGrid);
          tkString: lColunaNova := TStringColumn.Create(FStringGrid);
          tkSet: ;
          tkClass: ;
          tkMethod: ;
          tkWChar: lColunaNova := TStringColumn.Create(FStringGrid);
          tkLString: lColunaNova := TStringColumn.Create(FStringGrid);
          tkWString: lColunaNova := TStringColumn.Create(FStringGrid);
          tkVariant: ;
          tkArray: ;
          tkRecord: ;
          tkInterface: ;
          tkInt64: ;
          tkDynArray: ;
          tkUString: lColunaNova := TStringColumn.Create(FStringGrid);
          tkClassRef: ;
          tkPointer: ;
          tkProcedure: ;
          tkMRecord: ;
        end;
        lColunaNova.Header := lDescricao;

//        if Assigned(lEvento) then
//          lEvento(lColunaNova);
//        lColunaNova.Name := 'col_' + lProperty.Name;

//        if FDicionarioFormatacao.TryGetValue(lProperty.Name, lEvento) then
//          lEvento(lColunaNova);

        FStringGrid.AddObject(lColunaNova);
        lColunaNova.Visible := lIsFmx;
//      end;
    end;

    if FGuardarObjetonaLinha then
    begin
      lColunaNova := TIntegerColumn.Create(FStringGrid);
      lColunaNova.Header := 'Object';
      lColunaNova.Visible := False;
      FStringGrid.AddObject(lColunaNova);
    end;

    lContagemLinha := 0;
    for lItem in FLista do
    begin
      lContagemColuna := 0;
      for lProperty in lPropertyes do
      begin
        case lProperty.PropertyType.TypeKind of
          tkUnknown: ;
          tkInteger: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsInteger.ToString;
          tkChar: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkEnumeration: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsInteger.ToString;
          tkFloat: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsExtended.ToString;
          tkString: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkSet: ;
          tkClass: ;
          tkMethod: ;
          tkWChar: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkLString: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkWString: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkVariant: ;
          tkArray: ;
          tkRecord: ;
          tkInterface: ;
          tkInt64: ;
          tkDynArray: ;
          tkUString: FStringGrid.Cells[lContagemColuna, lContagemLinha] := lProperty.GetValue(lItem).AsString;
          tkClassRef: ;
          tkPointer: ;
          tkProcedure: ;
          tkMRecord: ;
        end;

        Inc(lContagemColuna);
      end;

      if FGuardarObjetonaLinha then
        FStringGrid.Cells[lContagemColuna, lContagemLinha] := Integer(lItem).ToString;

      Inc(lContagemLinha);
    end;

    Result := Self;
  finally
    lRttiContext.Free;

    if FDicionarioFormatacao.Count > 0 then
      FStringGrid.OnDrawColumnCell := OnDrawColumnCell;

    FStringGrid.EndUpdate;
  end;
end;

function TLmxFmxPreenchimento<T>.SetFormatacaoCondicional(const pCampo: string;
  const pOnFormatar: TOnFormatarCelula<T>): IPreenchimento<T>;
begin
  FDicionarioFormatacao.AddOrSetValue(pCampo, pOnFormatar);
  Result := Self;
end;

function TLmxFmxPreenchimento<T>.SetGuardarObjetonaLinha: IPreenchimento<T>;
begin
  FGuardarObjetonaLinha := True;
  Result := Self;
end;

function TLmxFmxPreenchimento<T>.SetLista(
  const pLista: TList<T>): IPreenchimento<T>;
begin
  FLista := pLista;
  Result := Self;
end;

function TLmxFmxPreenchimento<T>.SetStringGrid(
  const pStringGrid: TStringGrid): IPreenchimento<T>;
begin
  FStringGrid := pStringGrid;
  Result := Self;
end;

end.
