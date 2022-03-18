unit uLmx.Comando.Http.Base;

interface

uses
  uLmxAttributes, uLmxCore, uLmxComandoManutencao, uLmxComando, uLmxComandoDefault, uLmxHttp,
  uLmxSerialization, SysUtils, Classes, uLmxHelper;

type

//  [TLmxAttributeCaminhoRest('/Paciente/{%Codigo%}')]
//  [TLmxAttributeCaminhoRest('/Paciente')]
  TComandoHttpListaBase<T : TBaseTabelaPadrao , constructor; TLista : TBaseList<T>, constructor;
    TComandoLista : TLmxComandoBaseDefaultList<TLista, T>; TComandoGet : TLmxComandoBaseDefault<T>;
    TComandoPost : TLmxComandoBaseManutencao<T>> = class(TLmxServerComand)
  protected
    function DoProcessarComando(const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean; override;
    function DoProcessarComandoPost(const AInfoComando : TLmxInfoComandoProcessadoNoServidor) : Boolean; override;
  end;


implementation

{ TComandoHttpListaBase<T, TLista, TComandoLista, TComandoGet, TComandoPost> }

function TComandoHttpListaBase<T, TLista, TComandoLista, TComandoGet, TComandoPost>.DoProcessarComando(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
var
  lObjetos: TLista;
  lJsonString: string;
  lIdObjeto: Integer;
  lObjeto: T;
  lComando: TLmxComandoBaseClass;
  lCondicaoConsulta: string;
begin
  Result := False;
  lObjetos := TLista.Create;
  try
    lCondicaoConsulta := '';
    AInfoComando.InfoComando.TentarObterCondicaoConsulta(lCondicaoConsulta);

    if AInfoComando.InfoComando.TentarObterCodigo(lIdObjeto) then
    begin
      lObjeto := T.Create;
      try
        if TComandoGet.CriarEExecutar(lIdObjeto, lObjeto) then
        begin
          lJsonString := lObjeto.ToJsonString;
          AInfoComando.ResposneInfo.ContentType := 'application/json';
          AInfoComando.ResposneInfo.ContentText := lJsonString;
          Result := True;
        end;
      finally
        FreeAndNil(lObjeto);
      end;
    end else begin
      if TComandoLista.CriarEExecutar(lObjetos, function : T begin Result := T.Create; end, nil, nil, lCondicaoConsulta) then
      begin
        lJsonString := TLmxSerialization.ConvertToJsonString(lObjetos);
        AInfoComando.ResposneInfo.ContentType := 'application/json';
        AInfoComando.ResposneInfo.ContentText := lJsonString;
        Result := True;
      end;
    end;
  finally
    FreeAndNil(lObjetos);
  end;
end;

function TComandoHttpListaBase<T, TLista, TComandoLista, TComandoGet, TComandoPost>.DoProcessarComandoPost(
  const AInfoComando: TLmxInfoComandoProcessadoNoServidor): Boolean;
var
  lObjetos: T;
  lJsonString: string;
  lStream: TStream;
  lRequisicao: TStringList;
  lObjeto: T;
begin
  Result := False;
  lObjetos := T.Create;
  try
    lStream := AInfoComando.InfoComando.RequestInfo.PostStream;

    lRequisicao := TStringList.Create;
    lRequisicao.LoadFromStream(lStream);

    lObjeto := T.Create;

    lObjeto.FromJsonString(lRequisicao.Text);

    TComandoPost.CriarEExecutar(lObjeto.Id, lObjeto);

    Result := True;
  finally
    FreeAndNil(lObjetos);
  end;
end;

end.
