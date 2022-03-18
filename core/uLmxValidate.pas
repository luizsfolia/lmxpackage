unit uLmxValidate;

interface

uses
  SysUtils, Classes, Variants, SOAPHTTPClient, XMLIntf, XMLDoc, InvokeRegistry, IDHttp;

type

  TStrReplaceFlags = set of (srfReplaceAll, srfIgnoreCase, srfMultReplace);

  TLmxCheckCMC7 = class
  private
    { Private declarations }
    FCMC7        : String;
    FCMC7Bloco1  : String;
    FCMC7Bloco3  : String;
    FCMC7Bloco2  : String;
    FBanco       : String;
    FAgencia     : String;
    FDvCCT       : Char;
    FComp        : String;
    FNumero      : String;
    FConta       : String;
    FTipificacao : Char;
    FDvBcoAg     : Char;
    FDvCMC7      : Char;
    function DigitosAIgnorarConta(Banco: String): integer;
    procedure SetCMC7(Banda: String);
    procedure ZeraCampos;
    function AdicionaZerosEsqueda(const Texto : string; const Tamanho : Integer): string;
    function CalcDigitoCMC7(Documento : String; Inicial, Final : integer) : String;
  public
    { Public declarations }
    property CMC7        : String read FCMC7  write SetCMC7 stored false ;
    property CMC7Bloco1  : String read FCMC7Bloco1  stored false ;
    property CMC7Bloco2  : String read FCMC7Bloco2  stored false ;
    property CMC7Bloco3  : String read FCMC7Bloco3  stored false ;
    property Banco       : String read FBanco       stored false ;
    property Agencia     : String read FAgencia     stored false ;
    property DvCCT       : Char   read FDvCCT       stored false ; { Díg.Verif. Comp+Cheque+Tipificação }
    property Comp        : String read FComp        stored false ;
    property Numero      : String read FNumero      stored false ;
    property Conta       : String read FConta       stored false ;
    property Tipificacao : Char   read FTipificacao stored false ; { Tipificação(5-Comum 6-Bancário 7-Salário 8-Administr. 9-CPMF) }
    property DvBcoAg     : Char   read FDvBcoAg     stored false ; { Dígito verificador do Banco+Agência: }
    property DvCMC7      : Char   read FDvCMC7      stored false ;

    procedure MontaCMC7(pBanco, pAgencia, pConta, pNrCheque, pCamaraCompesacao : String; pTipificacao : String = '5'); overload;
    procedure MontaCMC7(Bloco1, Bloco2, Bloco3 : String); overload;
    procedure MontaCMC7(BlocoUnico : String); overload;

    constructor Create;

    destructor Destroy; override;

    class function Execute(CMC7: String): Boolean;
  end;

  TLmxCheckInsc = class
  private
    function CharToInt(ch: Char): ShortInt;
    function IntToChar(int: ShortInt): Char;
    function IsNumero(const s: string): Boolean;
    function CHKIEMG(const iemg: string): Boolean;
    function ChkIEAC(const ie: string): Boolean;
    function ChkIEAL(const ie: string): Boolean;
    function CHKIEAM(const ie: string): Boolean;
    function CHKIEAP(const ie: string): Boolean;
    function CHKIEBA(const ie: string): Boolean;
    function CHKIECE(const ie: string): Boolean;
    function CHKIEDF(const ie: string): Boolean;
    function CHKIEES(const ie: string): Boolean;
    function CHKIEGO(const ie: string): Boolean;
    function CHKIEMA(const ie: string): Boolean;
    function CHKIEMT(const ie: string): Boolean;
    function CHKIEMS(const ie: string): Boolean;
    function CHKIEPA(const ie: string): Boolean;
    function CHKIEPB(const ie: string): Boolean;
    function CHKIEPR(const ie: string): Boolean;
    function CHKIEPE(const ie: string): Boolean;
    function CHKIEPI(const ie: string): Boolean;
    function CHKIERJ(const ie: string): Boolean;
    function CHKIERN(const ie: string): Boolean;
    function CHKIERS(const ie: string): Boolean;
    function CHKIERO(const ie: string): Boolean;
    function ValidaInscRO(SIE: string): Boolean;
    function CHKIERR(const ie: string): Boolean;
    function CHKIESC(const ie: string): Boolean;
    function CHKIESP(const ie: string): Boolean;
    function CHKIESE(const ie: string): Boolean;
    function CHKIETO(const ie: string): Boolean;
  public
    class function Execute(const ie, uf: string): Boolean;
  end;

  TCEP = class
  private
    FLogradouro: String;
    FBairro: String;
    FUF: String;
    FCidade: String;
    FEndereco: String;
    FCodigoIbge: Integer;
  public
    property Logradouro : String read FLogradouro;
    property Endereco : String read FEndereco;
    property Bairro : String read FBairro;
    property Cidade : String read FCidade;
    property UF : String read FUF;
    property CodigoIbge : Integer read FCodigoIbge;
  end;

  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/cep
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : wscepSoap
  // service   : wscep
  // port      : wscepSoap
  // URL       : http://www.bronzebusiness.com.br/webservices/wscep.asmx
  // ************************************************************************ //
  wscepSoap = interface(IInvokable)
    ['{BE88904F-D954-5C7B-5AEC-FFB8B0904CD1}']
		function cep(const strcep: String): String; stdcall;
	end;

  TLmxConsultaCEP = class
  private
//    function GetwscepSoap(UseWSDL: Boolean=System.False; Addr: string = ''; HTTPRIO: THTTPRIO = nil): wscepSoap;
    function GetConsultaByRepublicaVirtual(const ACep : String) : TCep;
    function GetConsultaViaCep(const ACep : string) : TCep;
  public
    class function Execute(const ACep : String): TCep;
  end;

  TLmxCheckCPF = class
  public
    class function Formata(const ACPF : string): string;
    class function Execute(const ACPF : string): Boolean;
  end;

  TLmxCheckCNPJ = class
  public
    class function Formata(const ACNPJ : string): string;
    class function Execute(const ACNPJ : string): Boolean;
  end;


implementation

function CharIsNum(const C: Char): Boolean;
begin
  Result := CharInSet(C, ['0'..'9']);
//  Result := (C in ['0'..'9']);
end;

function StrAlignRight(InString: String; Quanto: Integer; FillString: String = ' '): String;
var
  TempStr: String;
  Ct, i: Integer;
begin
  TempStr := '';
  if Length(InString) < Quanto then
  begin
    Ct := Quanto - Length(InString);
    for i := 1 to Ct do
      TempStr := TempStr + FillString;
    TempStr := TempStr + InString;
  end
  else
  begin
    Ct := (Length(InString) - Quanto) + 1;
    TempStr := Copy(InString,Ct,Length(InString));
  end;

  Result := TempStr;
end;

function StrEmpty(const Str : String): Boolean;
begin
  Result := Trim(Str) = '';
end;

function StrOnlyNumbers(const Str : String): String;
var
  I : Integer;
begin
  Result := '';
  for I := 1 to Length(Str) do
    if Pos(Str[I], '0123456789') > 0 then
      Result := Result + Str[I];
end;

function StrStringReplace(const S, OldPattern, NewPattern: string; Flags: TStrReplaceFlags): string;
var
  I : Integer;
begin
  if srfMultReplace in Flags then
  begin
    Result := S;
    for I := 1 to Length(OldPattern) do
      Result := SysUtils.StringReplace(Result, OldPattern[I], NewPattern[I], SysUtils.TReplaceFlags(Flags - [srfMultReplace]));
  end else
  begin
    Result := SysUtils.StringReplace(S, OldPattern, NewPattern, SysUtils.TReplaceFlags(Flags));
  end;
end;

function StrReplicate(const cStr: String; const nQtd: Integer): String;
var
  cnt:Integer;
begin
  Result := '';
  for cnt := 1 to nQtd do
    Result := Result + cStr;
end;

{TFASCheckInsc}

function TLmxCheckInsc.CHKIEMG(const iemg: string): Boolean;
var
  npos, i: byte;
  ptotal, psoma: Integer;
  dig1, dig2: Char;
  ie, insc: string;
  nresto: SmallInt;
begin
  //
  Result := true;
  ie := Trim(iemg);
  if (StrEmpty(ie)) then
    exit;
  if copy(ie, 1, 2) = 'PR' then
    exit;
  if copy(ie, 1, 6) = 'ISENTO' then
    exit;

  Result := false;
  if (Trim(iemg) = '.') then
    Exit;
  if (length(ie) <> 13) then
    Exit;
  if not IsNumero(ie) then
    Exit;

  dig1 := copy(ie, 12, 1)[1];
  dig2 := copy(ie, 13, 1)[1];
  insc := copy(ie, 1, 3) + '0' + copy(ie, 4, 8);
  //  CALCULA DIGITO 1
  npos := 12;
  i := 1;
  ptotal := 0;
  while npos > 0 do
  begin
    inc(i);
    psoma := CharToInt(insc[npos]) * i;
    if psoma >= 10 then
      psoma := psoma - 9;
    inc(ptotal, psoma);
    if i = 2 then
      i := 0;
    dec(npos);
  end;
  nResto := ptotal mod 10;
  if NResto = 0 then
    nResto := 10;
  nResto := 10 - nResto;
  if nResto <> CharToInt(dig1) then
    exit;

  // CALCULA DIGITO 2
  npos := 12;
  i := 1;
  ptotal := 0;
  while npos > 0 do
  begin
    inc(i);
    if i = 12 then
      i := 2;
    inc(ptotal, CharToInt(ie[npos]) * i);
    dec(npos);
  end;
  nResto := ptotal mod 11;
  if (nResto = 0) or (nResto = 1) then
    nResto := 11;
  nResto := 11 - nResto;
  if nResto <> CharToInt(dig2) then
    exit;
  Result := true;
end; // ChkMG

function TLmxCheckInsc.ChkIEAC(const ie: string): Boolean;
var
  b, i, soma: Integer;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 13) then
    exit;
  if not IsNumero(ie) then
    exit;
  b := 4;
  soma := 0;
  for i := 1 to 11 do
  begin
    inc(soma, CharToInt(ie[i]) * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  dig := 11 - (soma mod 11);
  if (dig >= 10) then
    dig := 0;
  Result := (IntToChar(dig) = ie[12]);
  if not Result then
    exit;

  b := 5;
  soma := 0;
  for i := 1 to 12 do
  begin
    inc(soma, CharToInt(ie[i]) * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  dig := 11 - (soma mod 11);
  if (dig >= 10) then
    dig := 0;
  Result := (IntToChar(dig) = ie[13]);
end; // ChkIEAC

function TLmxCheckInsc.ChkIEAL(const ie: string): Boolean;
var
  b, i, soma: Integer;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  if copy(ie, 1, 2) <> '24' then
    exit;
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, CharToInt(ie[i]) * b);
    dec(b);
  end;
  soma := soma * 10;
  dig := soma - trunc(soma / 11) * 11;
  if dig = 10 then
    dig := 0;
  Result := (IntToChar(dig) = ie[09]);
end; // ChkIEAL

function TLmxCheckInsc.CHKIEAM(const ie: string): Boolean;
var
  b, i, soma: Integer;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, CharToInt(ie[i]) * b);
    dec(b);
  end;
  if soma < 11 then
    dig := 11 - soma
  else
  begin
    i := (soma mod 11);
    if i <= 1 then
      dig := 0
    else
      dig := 11 - i;
  end;
  Result := (IntToChar(dig) = ie[09]);
end; // ChkIEAM

function TLmxCheckInsc.CHKIEAP(const ie: string): Boolean;
var
  p, d, b, i, soma: Integer;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  p := 0;
  d := 0;
  i := StrToInt(copy(ie, 1, 8));
  if (i >= 03000001) and (i <= 03017000) then
  begin
    p := 5;
    d := 0;
  end
  else if (i >= 03017001) and (i <= 03019022) then
  begin
    p := 9;
    d := 1;
  end;
  b := 9;
  soma := p;
  for i := 1 to 08 do
  begin
    inc(soma, CharToInt(ie[i]) * b);
    dec(b);
  end;
  dig := 11 - (soma mod 11);
  if dig = 10 then
    dig := 0
  else if dig = 11 then
    dig := d;
  Result := (IntToChar(dig) = ie[09]);
end; // ChkIEAP

function TLmxCheckInsc.CHKIEBA(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..8] of byte;
  NumMod: word;
  dig: SmallInt;
  die: string;
begin
  Result := false;
  if (length(ie) <> 8) then
    exit;
  die := copy(ie, 1, 8);
  if not IsNumero(die) then
    exit;
  for i := 1 to 8 do
    nro[i] := CharToInt(die[i]);
  if nro[1] in [0, 1, 2, 3, 4, 5, 8] then
    NumMod := 10
  else
    NumMod := 11;
  // calculo segundo
  b := 7;
  soma := 0;
  for i := 1 to 06 do
  begin
    inc(soma, (nro[i] * b));
    dec(b);
  end;
  i := soma mod NumMod;
  if NumMod = 10 then
  begin
    if i = 0 then
      dig := 0
    else
      dig := NumMod - i;
  end
  else
  begin
    if i <= 1 then
      dig := 0
    else
      dig := NumMod - i;
  end;
  Result := (dig = nro[8]);
  if not Result then
    exit;
  // calculo segundo
  b := 8;
  soma := 0;
  for i := 1 to 06 do
  begin
    inc(soma, (nro[i] * b));
    dec(b);
  end;
  inc(soma, (nro[8] * 2));
  i := soma mod NumMod;
  if NumMod = 10 then
  begin
    if i = 0 then
      dig := 0
    else
      dig := NumMod - i;
  end
  else
  begin
    if i <= 1 then
      dig := 0
    else
      dig := NumMod - i;
  end;
  Result := (dig = nro[7]);
end; // ChkIEBA

function TLmxCheckInsc.CHKIECE(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..9] of byte;
  dig: SmallInt;
  die: string;
begin
  Result := false;
  if (length(ie) > 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  die := ie;
  if length(ie) < 9 then
  begin
    repeat
      die := '0' + die;
    until length(die) = 9;
  end;
  for i := 1 to 9 do
    nro[i] := CharToInt(die[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, (nro[i] * b));
    dec(b);
  end;
  dig := 11 - (soma mod 11);
  if dig >= 10 then
    dig := 0;
  Result := (dig = nro[9]);
end; // ChkIECE

function TLmxCheckInsc.CHKIEDF(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..13] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 13) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 13 do
    nro[i] := CharToInt(ie[i]);
  b := 4;
  soma := 0;
  for i := 1 to 11 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  dig := 11 - (soma mod 11);
  if dig >= 10 then
    dig := 0;
  Result := (dig = nro[12]);
  if not Result then
    exit;

  b := 5;
  soma := 0;
  for i := 1 to 12 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  dig := 11 - (soma mod 11);
  if dig >= 10 then
    dig := 0;
  Result := (dig = nro[13]);
end; // ChkIEDF

function TLmxCheckInsc.CHKIEES(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..9] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 9 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := soma mod 11;
  if i < 2 then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[9]);
end; // ChkIEES

function TLmxCheckInsc.CHKIEGO(const ie: string): Boolean;
var
  n, b, i, soma: Integer;
  nro: array[1..9] of byte;
  dig: SmallInt;
  s: string;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  s := copy(ie, 1, 2);
  if (s = '10') or (s = '11') or (s = '15') then
  begin
    for i := 1 to 9 do
      nro[i] := CharToInt(ie[i]);
    n := trunc(StrToFloat(ie) / 10);
    if n = 11094402 then
    begin
      if (nro[9] = 0) or (nro[9] = 1) then
      begin
        Result := true;
        exit;
      end;
    end;

    b := 9;
    soma := 0;
    for i := 1 to 08 do
    begin
      inc(soma, nro[i] * b);
      dec(b);
    end;
    i := (soma mod 11);
    if i = 0 then
      dig := 0
    else if i = 1 then
    begin
      if (n >= 10103105) and (n <= 10119997) then
        dig := 1
      else
        dig := 0;
    end
    else
    begin
      dig := 11 - i;
    end;
    Result := (dig = nro[9]);
  end;
end; // ChkIEGO

function TLmxCheckInsc.CHKIEMA(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..9] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 9 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[9]);
end; // ChkIEMA

function TLmxCheckInsc.CHKIEMT(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..11] of byte;
  dig: SmallInt;
  die: string;
begin
  Result := false;
  if (length(ie) < 9) then
    exit;
  die := ie;
  if length(die) < 11 then
  begin
    repeat
      die := '0' + die;
    until length(die) = 11;
  end;
  if not IsNumero(die) then
    exit;
  for i := 1 to 11 do
    nro[i] := CharToInt(die[i]);
  b := 3;
  soma := 0;
  for i := 1 to 10 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[11]);
end; // ChkIEMT

function TLmxCheckInsc.CHKIEMS(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  if copy(ie, 1, 2) <> '28' then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
end; // ChkIEMS

function TLmxCheckInsc.CHKIEPA(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  if copy(ie, 1, 2) <> '15' then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
end; // ChkIEPA

function TLmxCheckInsc.CHKIEPB(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
end; // ChkIEPB

function TLmxCheckInsc.CHKIEPR(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..10] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 10) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 10 do
    nro[i] := CharToInt(ie[i]);
  b := 3;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 7;
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
  if not result then
    exit;

  b := 4;
  soma := 0;
  for i := 1 to 09 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 7;
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[10]);
end; // ChkIEPR

// Refeito para novo calculo em 14/01/2011 liandro
function TLmxCheckInsc.CHKIEPE(const ie: string): Boolean;
var
  i: integer;
  dig1, soma1, soma2: Integer;
  dig2, resto1, resto2: Integer;
  nro: array[1..9] of byte;
begin
  Result := false;
  // Validações
  if (length(ie) <> 9) then
    exit;

  if not IsNumero(ie) then
    exit;

  // Soma dos Digitos
  for i := 1 to 9 do
    nro[i] := CharToInt(ie[i]);

  // Primeiro Digito
  soma1 := 0;
  for i := 1 to 7 do
    soma1 := soma1 + (nro[i] * (9 - i));

  resto1 := (soma1 mod 11);
  if (resto1 = 0) or (resto1 = 1) then
    dig1 := 0
  else
    dig1 := 11 - resto1;

  // Segundo Digito
  soma2 := (dig1 * 2);
  for i := 1 to 7 do
    soma2 := soma2 + (nro[i] * (10 - i));

  resto2 := (soma2 mod 11);
  if (resto2 = 0) or (resto2 = 1) then
    dig2 := 0
  else
    dig2 := 11 - resto2;

  // Verifica se digitos batem
  Result := ((InttoStr(dig1) + InttoStr(Dig2)) = InttoStr(nro[8]) + InttoStr(nro[9]));
end; // ChkIEPE

function TLmxCheckInsc.CHKIEPI(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
end; // ChkIEPI

function TLmxCheckInsc.CHKIERJ(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..08] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 08) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 08 do
    nro[i] := CharToInt(ie[i]);
  b := 2;
  soma := 0;
  for i := 1 to 07 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 7;
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[08]);
end; // ChkIERJ

function TLmxCheckInsc.CHKIERN(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  soma := soma * 10;
  dig := (soma mod 11);
  if (dig = 10) then
    dig := 0;
  Result := (dig = nro[09]);
end; // ChkIERN

function TLmxCheckInsc.CHKIERS(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..10] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 10) then
    exit;
  if not IsNumero(ie) then
    exit;

  for i := 1 to 10 do
    nro[i] := CharToInt(ie[i]);
  b := 2;
  soma := 0;
  for i := 1 to 09 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
    if b = 1 then
      b := 9;
  end;
  dig := 11 - (soma mod 11);
  if (dig >= 10) then
    dig := 0;
  Result := (dig = nro[10]);
end; // ChkIERS

// Rondônia - versão antiga
function TLmxCheckInsc.CHKIERO(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 6;
  soma := 0;
  for i := 4 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b)
  end;
  dig := 11 - (soma mod 11);
  if (dig >= 10) then
    dig := dig - 10;
  Result := (dig = nro[09]);
end; // ChkIERO

// Rondônia - versão nova
function TLmxCheckInsc.ValidaInscRO(SIE: string): Boolean;
var
  i, x, y, z, j: integer;
  s: string;
begin
  //i := 1;
  y := 6;
  //x := 0;
  z := 0;
  //j := 0;
  for j := 1 to length(trim(sie)) do
    if CharIsNum(sie[j]) then
      s := s + sie[j];
  if length(s) < 14 then
  begin
    for i := 1 to (14 - length(Trim(s))) do
      s := '0' + trim(s)
  end;
  for i := 1 to (length(s) - 1) do
  begin
    x := strtoint(s[i]) * y;
    z := z + x;
    if y > 2 then
      dec(y)
    else
      y := 9;
  end;
  x := z mod 11;
  y := 11 - x;
  if (y = 11) or (y = 10) then
    y := y-10;
  if inttostr(y) = s[14] then
    Result := true
  else
    Result := false;
end;

function TLmxCheckInsc.CHKIERR(const ie: string): Boolean;
var
  i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  if copy(ie, 1, 2) <> '24' then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * i);
  end;
  dig := (soma mod 09);
  Result := (dig = nro[09]);
end; // ChkIERR

function TLmxCheckInsc.CHKIESC(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  i := (soma mod 11);
  if (i <= 1) then
    dig := 0
  else
    dig := 11 - i;
  Result := (dig = nro[09]);
end; // ChkIESC

function TLmxCheckInsc.CHKIESP(const ie: string): Boolean;
var
  i, soma: Integer;
  nro: array[1..12] of byte;
  dig: SmallInt;
  s: string;
begin
  Result := false;
  if UpperCase(copy(ie, 1, 1)) = 'P' then
  begin
    s := copy(ie, 2, 9);
    if not IsNumero(s) then
      exit;
    for i := 1 to 8 do
      nro[i] := CharToInt(s[i]);
    soma := (nro[1] * 1) + (nro[2] * 3) + (nro[3] * 4) + (nro[4] * 5) +
      (nro[5] * 6) + (nro[6] * 7) + (nro[7] * 8) + (nro[8] * 10);
    dig := (soma mod 11);
    if (dig >= 10) then
      dig := 0;
    Result := (dig = nro[09]);
    if not Result then
      exit;
  end
  else
  begin
    if (length(ie) < 12) then
      exit;
    if not IsNumero(ie) then
      exit;
    for i := 1 to 12 do
      nro[i] := CharToInt(ie[i]);
    soma := (nro[1] * 1) + (nro[2] * 3) + (nro[3] * 4) + (nro[4] * 5) +
      (nro[5] * 6) + (nro[6] * 7) + (nro[7] * 8) + (nro[8] * 10);
    dig := (soma mod 11);
    if (dig >= 10) then
      dig := 0;
    Result := (dig = nro[09]);
    if not Result then
      exit;
    soma := (nro[1] * 3) + (nro[2] * 2) + (nro[3] * 10) + (nro[4] * 9) +
      (nro[5] * 8) + (nro[6] * 7) + (nro[7] * 6) + (nro[8] * 5) +
      (nro[9] * 4) + (nro[10] * 3) + (nro[11] * 2);

    dig := (soma mod 11);
    if (dig >= 10) then
      dig := 0;
    Result := (dig = nro[12]);
  end;
end; // ChkIESP

function TLmxCheckInsc.CHKIESE(const ie: string): Boolean;
var
  b, i, soma: Integer;
  nro: array[1..09] of byte;
  dig: SmallInt;
begin
  Result := false;
  if (length(ie) <> 09) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 09 do
    nro[i] := CharToInt(ie[i]);
  b := 9;
  soma := 0;
  for i := 1 to 08 do
  begin
    inc(soma, nro[i] * b);
    dec(b);
  end;
  dig := 11 - (soma mod 11);
  if (dig >= 10) then
    dig := 0;
  Result := (dig = nro[09]);
end; // ChkIESE

function TLmxCheckInsc.CHKIETO(const ie: string): Boolean;
var
  i, soma: Integer;
  nro: array[1..9] of byte;
  dig: SmallInt;
  //s: string;
begin
  Result := false;
  if (length(ie) <> 9) then
    exit;
  if not IsNumero(ie) then
    exit;
  for i := 1 to 9 do
    nro[i] := CharToInt(ie[i]);
  soma := (nro[1] * 9) + (nro[2] * 8) + (nro[3] * 7) +
    (nro[4] * 6) + (nro[5] * 5) + (nro[6] * 4) +
    (nro[7] * 3) + (nro[8] * 2);
  dig := (soma mod 11);
  if (dig < 2) then
    dig := 0
  else
    dig := 11 - dig;
  Result := (dig = nro[9]);
end; // ChkIETO

class function TLmxCheckInsc.Execute(const ie, uf: string): Boolean;
var
  duf, die: string;
  lFASCheckInsc : TLmxCheckInsc;
const
  isento = 'ISENTO';
begin
  Result := False;

  if (Trim(ie) = '.') then
    Exit;

  duf := UpperCase(uf);
  die := Trim(StrStringReplace(UpperCase(ie),'-./', '', [srfMultReplace]));
  if isento = die then
  begin
    Result := True;
    Exit;
  end;

  lFASCheckInsc := TLmxCheckInsc.Create;
  try
    if duf = 'AC' then
      Result := lFASCheckInsc.ChkIEAC(die)
    else if duf = 'AL' then
      Result := lFASCheckInsc.ChkIEAL(die)
    else if duf = 'AP' then
      Result := lFASCheckInsc.ChkIEAP(die)
    else if duf = 'AM' then
      Result := lFASCheckInsc.ChkIEAM(die)
    else if duf = 'BA' then
      Result := lFASCheckInsc.ChkIEBA(die)
    else if duf = 'CE' then
      Result := lFASCheckInsc.ChkIECE(die)
    else if duf = 'DF' then
      Result := lFASCheckInsc.ChkIEDF(die)
    else if duf = 'ES' then
      Result := lFASCheckInsc.ChkIEES(die)
    else if duf = 'GO' then
      Result := lFASCheckInsc.ChkIEGO(die)
    else if duf = 'MA' then
      Result := lFASCheckInsc.ChkIEMA(die)
    else if duf = 'MG' then
      Result := lFASCheckInsc.ChkIEMG(die)
    else if duf = 'MT' then
      Result := lFASCheckInsc.ChkIEMT(die)
    else if duf = 'MS' then
      Result := lFASCheckInsc.ChkIEMS(die)
    else if duf = 'PA' then
      Result := lFASCheckInsc.ChkIEPA(die)
    else if duf = 'PB' then
      Result := lFASCheckInsc.ChkIEPB(die)
    else if duf = 'PR' then
      Result := lFASCheckInsc.ChkIEPR(die)
    else if duf = 'PE' then
      Result := lFASCheckInsc.ChkIEPE(die)
    else if duf = 'PI' then
      Result := lFASCheckInsc.ChkIEPI(die)
    else if duf = 'RJ' then
      Result := lFASCheckInsc.ChkIERJ(die)
    else if duf = 'RN' then
      Result := lFASCheckInsc.ChkIERN(die)
    else if duf = 'RS' then
      Result := lFASCheckInsc.ChkIERS(die)
    else if duf = 'RO' then
      Result := (lFASCheckInsc.ChkIERO(die) or lFASCheckInsc.ValidaInscRO(die))
    else if duf = 'RR' then
      Result := lFASCheckInsc.ChkIERR(die)
    else if duf = 'SC' then
      Result := lFASCheckInsc.ChkIESC(die)
    else if duf = 'SP' then
      Result := lFASCheckInsc.ChkIESP(die)
    else if duf = 'SE' then
      Result := lFASCheckInsc.ChkIESE(die)
    else if duf = 'TO' then
      Result := lFASCheckInsc.ChkIETO(die)
    else
      Result := false;
  finally
    lFASCheckInsc.Free;
  end;
end;

function TLmxCheckCMC7.AdicionaZerosEsqueda(const Texto : string; const Tamanho
    : Integer): string;
begin
  Result := StrAlignRight(Trim(Texto),Tamanho,'0') ;
end;

function TLmxCheckCMC7.CalcDigitoCMC7(Documento : String; Inicial, Final : integer) : String;
var
  I: Integer;
  vVal1, vVal2, vVal3, vSoma, vPeso : Real;
begin
  vSoma := 0;
  for I := 1 to Length(Documento) do
  begin
    if Odd(I) then
       vPeso := Inicial
    else
       vPeso := Final;

    if CharIsNum(Documento[I]) then
//    if Documento[I] in ['0'..'9'] then
    begin
       vVal1 := StrToFloat(Documento[I])*vPeso;
       if (vVal1 > 9) then
          vVal2 := StrToFloat(copy(formatFloat('0',vVal1),1,1)) + StrToFloat(copy(formatFloat('0',vVal1),length(formatFloat('0',vVal1)),1))
       else
          vVal2 := vVal1;
       vSoma := vSoma+vVal2;
    end;
  end;
  vVal3 := round((10-(vSoma/10))*100)/100;

  Result := copy(formatFloat('0.000',frac(vVal3)),3,1);
end;

class function TLmxCheckCMC7.Execute(CMC7: String): Boolean;
var
  Dv : string;
  lFASCheckCMC7: TLmxCheckCMC7;
begin
  // contador: 123 4567 8 901 234567 8  9 0123456789 0
  // conteudo: 745 0030 2 018 000379 5  7 0030079144 9
  //           --- ---- - --- ------ -  - ---------- -
  //           |   |    |  |  |      |  | |          |
  //           |   |    |  |  |      |  | |          ---> digito verificador 3
  //           |   |    |  |  |      |  | -------------> conta corrente
  //           |   |    |  |  |      |  ---------------> digito verificador 1
  //           |   |    |  |  |      ------------------> Tipificação ( 5 padrao/normal, 8 ch tributário, 9 administrativo )
  //           |   |    |  |  -------------------------> cheque
  //           |   |    |  ----------------------------> compe ( camara de compensação )
  //           |   |    -------------------------------> digito verificador 2
  //           |   ------------------------------------> agência
  //           ----------------------------------------> banco
  lFASCheckCMC7 := TLmxCheckCMC7.Create;
  try
    CMC7   := StrOnlyNumbers(CMC7);  { Retirando marcadores }
    Result := (Length(CMC7) = 30);

    // calculo do digito (2)
    if Result then
    begin
       Dv     := lFASCheckCMC7.CalcDigitoCMC7(Copy(CMC7,9,3) + Copy(CMC7,12,6) + Copy(CMC7,18,1),1,2);
       Result := (Dv = copy(CMC7,8,1));
    end;

    // calculo do digito (1)
    if Result then
    begin
      Dv     := lFASCheckCMC7.CalcDigitoCMC7(Copy(CMC7,1,7),2,1);
      Result := (Dv = copy(CMC7,19,1));
    end;

    // calculo do digito (3)
    if Result then
    begin
      Dv     := lFASCheckCMC7.CalcDigitoCMC7(Copy(CMC7,20,10),1,2);
      Result := (Dv = copy(CMC7,30,1));
    end;
  finally
    lFASCheckCMC7.Free;
  end;
end;

constructor TLmxCheckCMC7.Create;
begin
 inherited Create;

 ZeraCampos;
end;

procedure TLmxCheckCMC7.ZeraCampos;
begin
  FCMC7       := '';
  FCMC7Bloco1 := '';
  FCMC7Bloco2 := '';
  FCMC7Bloco3 := '';
  FBanco      := '';
  FAgencia    := '';
  FComp       := '';
  FNumero     := '';
  FConta      := '';
  FDvCCT      := ' ';
  FTipificacao:= ' ';
  FDvBcoAg    := ' ';
  FDvCMC7     := ' ';
end;

destructor TLmxCheckCMC7.Destroy;
begin
  inherited Destroy ;
end;

function TLmxCheckCMC7.DigitosAIgnorarConta(Banco: String): integer;
var
  CodBanco : Integer;
begin
  CodBanco := StrToIntDef(Banco,0);
  case CodBanco of
     1: Result := 2;    /// 001 - Banco do Brasil
    41: Result := 0;    /// 041 - Banrisul Obs: Este banco utiliza todo o campo para o número da conta
   104: Result := 0;    /// 104 - CEF. Utiliza apenas 7, mas os 3 primeiros são necessários para calcular o dv
// 237: Result := 3;    /// 237 - Bradesco
   341: Result := 4;    /// 341 - Itau
// 409: Result := 3;    /// 409 - Unibanco
   479: Result := 2;    /// 479 - Bank of Boston
  else
    Result := 3;
  end;
end;

procedure TLmxCheckCMC7.SetCMC7(Banda: String);
Const
  vDigitos = '<99999999<9999999999>999999999999:' ;
var
  Ignorar : Integer;
  I : Integer ;
begin
  ZeraCampos ;

  Banda := Trim(Banda) ;
  if Banda = '' then
    exit ;

  if Length( Banda ) <> 34 then
     raise Exception.Create('Banda CMC7 deve ter 34 caracteres');

// 1234567890123456789012345678901234
// <00100049<0030000061>900000000109:

// O byte 34 pode vir conforme configuração do Teclado x Leitor:
{   teclado Leitor
    Ingles  Ingles  <<>:
    Ingles  ABNT    <<>?
    ABNT    ABNT    <<>:
    ABNT    Ingles  <<>Ç
}
  for I := 1 to 33 do
  begin
    if vDigitos[I] = '9' then
     begin
       if not CharIsNum(Banda[I]) then
           raise Exception.CreateFmt('Caracter da posição %d da Banda deve ser numérico',[I]);
     end
    else
       if vDigitos[I] <> Banda[I] then
          raise Exception.CreateFmt('Caracter da posição %d da Banda deve ser %s',[I,vDigitos[I]]);

  end ;

  if Pos(Banda[34],'?:çÇ') = 0 then
    raise Exception.CreateFmt('Último caracter inválido %s', [Banda[34]]);

  if not Execute(Banda) then
     raise Exception.Create('CMC7 Inválido');

  try
  // '<' + Banco(3) + Agencia(4) + DV2(1) + '<' + CamaraCompesacao(3) +
  //    NrCheque(6) + Tipificacao(1) + '>' + DV1(1) + Conta(10) + DV3(1) + ':'
  // 1234567890123456789012345678901234
  // <00100049<0030000065>900000000109:

     FCMC7Bloco1 := copy(Banda,2 , 8) ;
     FCMC7Bloco2 := copy(Banda,11,10) ;
     FCMC7Bloco3 := copy(Banda,22,12) ;

     FBanco      := Copy(Banda,2 ,3);
     FAgencia    := Copy(Banda,5 ,4);
     FDvCCT      := Copy(Banda,9 ,1)[1];
     FComp       := Copy(Banda,11,3);
     FNumero     := Copy(Banda,14,6);
     FTipificacao:= Copy(Banda,20,1)[1];
     FDvBcoAg    := Copy(Banda,22,1)[1];

     Ignorar     := DigitosAIgnorarConta(FBanco);
     FConta      := Copy(Banda,23+Ignorar,10-Ignorar);

     FDvCMC7     := Copy(Banda,33,1)[1];

     FCMC7       := Banda
  except
     ZeraCampos ;
  end ;
end;

procedure TLmxCheckCMC7.MontaCMC7(pBanco,pAgencia,pConta,pNrCheque,pCamaraCompesacao,pTipificacao : String) ;
// Dica retirada do site http://www.ramosdainformatica.com.br/art_recentes01.php?CDA=297 e ajustado conforme necessidade
var
  vDv1, vDv2, vDv3 : string;
  Tip : Integer ;
begin
  // zeros a esquerda do banco
  pBanco := AdicionaZerosEsqueda(pBanco,3);
  // zeros a esquerda da agencia
  pAgencia := AdicionaZerosEsqueda(pAgencia,4);
  // zeros a esquerda da conta
  pConta := AdicionaZerosEsqueda(pConta,10);
  // zeros a esquerda do NrCheque
  pNrCheque := AdicionaZerosEsqueda(pNrCheque,6);
  // zeros a esquerda do CamaraCompesacao
  pCamaraCompesacao := AdicionaZerosEsqueda(pCamaraCompesacao,3);
  Tip := StrToIntDef(pTipificacao,0) ;
  if (Tip < 5) or (Tip > 9) then
     raise Exception.Create('Campo Tipificação deve estar na faixa 5..9') ;

  // calculo do digito (2)
  vDv2 := CalcDigitoCMC7(pCamaraCompesacao+pNrCheque+pTipificacao,1,2);
   // calculo do digito (1)
  vDv1 := CalcDigitoCMC7(pBanco+pAgencia,2,1);
  // calculo do digito (3)
  vDv3 := CalcDigitoCMC7(pConta,1,2);

  CMC7 := '<'+pBanco+pAgencia+vDV2+'<'+pCamaraCompesacao+pNrCheque+pTipificacao+'>'+vDV1+pConta+vDV3+':';
  // '<' + Banco(3) + Agencia(4) + DV2(1) + '<' + CamaraCompesacao(3) +
  //    NrCheque(6) + Tipificacao(1) + '>' + DV1(1) + Conta(10) + DV3(1) + ':'
  // 1234567890123456789012345678901234
  // <00100049<0030000065>900000000109:
end;

procedure TLmxCheckCMC7.MontaCMC7(Bloco1, Bloco2, Bloco3: String);
begin
  Bloco1 := AdicionaZerosEsqueda(Bloco1, 8) ;
  Bloco2 := AdicionaZerosEsqueda(Bloco2,10) ;
  Bloco3 := AdicionaZerosEsqueda(Bloco3,12) ;

  CMC7 := '<'+Bloco1+'<'+Bloco2+'>'+Bloco3+':';
end;

procedure TLmxCheckCMC7.MontaCMC7(BlocoUnico: String);
begin
  if Length(BlocoUnico) <> 30 then
    raise Exception.Create('CMC7 a ser montado deve conter 30 caracteres.');

  Insert('<', BlocoUnico, 1);
  Insert('<', BlocoUnico, 10);
  Insert('>', BlocoUnico, 21);
  Insert(':', BlocoUnico, 34);

  CMC7 := BlocoUnico;
end;

{ chInt - Converte um caracter numérico para o valor inteiro correspondente. }
function TLmxCheckInsc.CharToInt(ch: Char): ShortInt;
begin
  Result := Ord(ch) - Ord('0');
end;

{ intCh = Converte um valor inteiro (de 0 a 9) para o caracter numérico correspondente. }
function TLmxCheckInsc.IntToChar(int: ShortInt): Char;
begin
  Result := Chr(int + Ord('0'));
end;

function TLmxCheckInsc.IsNumero(const s: string): Boolean;
var
  i: byte;
begin
  Result := false;
  for i := 1 to length(s) do
    if not CharIsNum(s[i]) then
      exit;
  Result := true;
end; { IsNumero }


{ TFASConsultaCEP }

class function TLmxConsultaCEP.Execute(const ACep : String): TCep;
var
  lFASConsultaCEP: TLmxConsultaCEP;
begin
  lFASConsultaCEP := TLmxConsultaCEP.Create;
  try
    Result := lFASConsultaCEP.GetConsultaViaCep(ACep);
    if Result = nil then
      Result := lFASConsultaCEP.GetConsultaByRepublicaVirtual(ACep);
  finally
    lFASConsultaCEP.Free;
  end;
end;

function TLmxConsultaCEP.GetConsultaByRepublicaVirtual(
  const ACep: String): TCep;
var
  lHttp: TIdHTTP;
  lResponseBody: string;
  lResponseCode: Integer;
  lXmlRetorno: IXMLDocument;
  lConsulta: IXMLNode;

  function GetValor(const ANode : IXMLNode; const ACampo : string) : string;
  var
    lValor: OleVariant;
  begin
    lValor := ANode.ChildNodes.FindNode(ACampo).NodeValue;
    if not VarIsNull(lValor) then
      Result := lValor;
  end;

begin
//  http://republicavirtual.com.br/web_cep.php?cep=92035000
  Result := nil;
  lHttp := TIDHttp.Create(nil);
  try
    lHttp.HandleRedirects := True;
    lHttp.Request.ContentType := 'Application/Text';
    try
      {$IFDEF MSWINDOWS}
      lResponseBody := Utf8ToAnsi(RawByteString(lHttp.Get('http://republicavirtual.com.br/web_cep.php?cep=' + ACep)));
      {$ENDIF}
      lResponseCode := lHttp.ResponseCode;
      lHttp.Disconnect;
      if lResponseCode = 200 then
      begin
        lXmlRetorno := TXMLDocument.Create(nil);
        lXmlRetorno.Active := True;
        lXmlRetorno.LoadFromXML(lResponseBody);

        lConsulta := lXmlRetorno.DocumentElement;

        if StrToIntDef(GetValor(lConsulta, 'resultado'), 0) > 0 then
        begin
          Result := TCEP.Create;
          Result.FLogradouro := GetValor(lConsulta, 'tipo_logradouro') + GetValor(lConsulta, 'logradouro');
          Result.FBairro := GetValor(lConsulta, 'bairro');
          Result.FUF := GetValor(lConsulta, 'uf');
          Result.FCidade := GetValor(lConsulta, 'cidade');
        end;
      end;
    except

    end;
  finally
    FreeAndNil(lHttp);
  end;

end;

function TLmxConsultaCEP.GetConsultaViaCep(const ACep: string): TCep;
var
  lXmlRetorno: IXMLDocument;
  lConsulta: IXMLNode;

  function GetValor(const ANode : IXMLNode; const ACampo : string) : string;
  var
    lValor: OleVariant;
  begin
    lValor := ANode.ChildNodes.FindNode(ACampo).NodeValue;
    if not VarIsNull(lValor) then
      Result := lValor;
  end;

begin
  Result := nil;
  try
    lXmlRetorno := TXMLDocument.Create(nil);
    try
      lXmlRetorno.FileName := 'https://viacep.com.br/ws/' + ACep + '/xml/';
      lXmlRetorno.Active := True;

      lConsulta := lXmlRetorno.DocumentElement;

      Result := TCEP.Create;
      Result.FLogradouro := GetValor(lConsulta, 'logradouro');
      Result.FBairro := GetValor(lConsulta, 'bairro');
      Result.FUF := GetValor(lConsulta, 'uf');
      Result.FCidade := GetValor(lConsulta, 'localidade');
      Result.FCodigoIbge := StrToIntDef(GetValor(lConsulta, 'ibge'), 0);
    finally
      lXmlRetorno := nil;
    end;
  except

  end;
end;

//function TLmxConsultaCEP.GetwscepSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): wscepSoap;
//const
//  defWSDL = 'http://www.bronzebusiness.com.br/webservices/wscep.asmx?WSDL';
//  defURL  = 'http://www.bronzebusiness.com.br/webservices/wscep.asmx';
//  defSvc  = 'wscep';
//  defPrt  = 'wscepSoap';
//var
//  RIO: THTTPRIO;
//begin
//  Result := nil;
//  if (Addr = '') then
//  begin
//    if UseWSDL then
//      Addr := defWSDL
//    else
//      Addr := defURL;
//  end;
//  if HTTPRIO = nil then
//    RIO := THTTPRIO.Create(nil)
//  else
//		RIO := HTTPRIO;
//  try
//    Result := (RIO as wscepSoap);
//		if UseWSDL then
//		begin
//			RIO.WSDLLocation := Addr;
//			RIO.Service := defSvc;
//			RIO.Port := defPrt;
//		end else
//			RIO.URL := Addr;
//	finally
//		if (Result = nil) and (HTTPRIO = nil) then
//			RIO.Free;
//	end;
//end;

{ TFASCheckCNPJ }

class function TLmxCheckCNPJ.Execute(const ACNPJ: string): Boolean;
var
  I, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, d1, d2: integer;
  cCnpj, Digitado, Calculado: string;
begin
  try
    if Length(ACNPJ) > 14 then
    begin
      for I := 1 to Length(ACNPJ) do
      begin
        if (CharInSet(ACNPJ[I], ['0'..'9'])) then
//        if (ACNPJ[I] in ['0'..'9']) then
          cCnpj := cCnpj + ACNPJ[I]
        else
          Continue;
      end;
    end
    else
      cCnpj := ACNPJ;
    cCnpj := Copy(cCnpj, 1, 14);
    for I := 0 to 9 do
      if cCnpj = StrReplicate(IntToStr(I), 14) then
        raise Exception.Create('');
    n1 := StrToInt(cCnpj[1]);
    n2 := StrToInt(cCnpj[2]);
    n3 := StrToInt(cCnpj[3]);
    n4 := StrToInt(cCnpj[4]);
    n5 := StrToInt(cCnpj[5]);
    n6 := StrToInt(cCnpj[6]);
    n7 := StrToInt(cCnpj[7]);
    n8 := StrToInt(cCnpj[8]);
    n9 := StrToInt(cCnpj[9]);
    n10 := StrToInt(cCnpj[10]);
    n11 := StrToInt(cCnpj[11]);
    n12 := StrToInt(cCnpj[12]);
    d1 := n12 * 2 + n11 * 3 + n10 * 4 + n9 * 5 + n8 * 6 + n7 * 7 + n6 * 8 + n5 *
      9 + n4 * 2 + n3 * 3 + n2 * 4 + n1 * 5;
    d1 := 11 - (d1 mod 11);
    if d1 >= 10 then
      d1 := 0;
    d2 := d1 * 2 + n12 * 3 + n11 * 4 + n10 * 5 + n9 * 6 + n8 * 7 + n7 * 8 + n6 *
      9 + n5 * 2 + n4 * 3 + n3 * 4 + n2 * 5 + n1 * 6;
    d2 := 11 - (d2 mod 11);
    if d2 >= 10 then
      d2 := 0;
    Calculado := IntToStr(d1) + IntToStr(d2);
    Digitado := cCnpj[13] + cCnpj[14];
    if Calculado = Digitado then
      Result := True
    else
      Result := False;
  except
    Result := False;
  end;
end;

class function TLmxCheckCNPJ.Formata(const ACNPJ: string): string;
begin
  Result := ACNPJ;
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '', [rfReplaceAll]);
  //00.000.000/0000-00
  Result := StrAlignRight('00000000000000'+Result, 14);
  Insert('.', Result, 3);
  Insert('.', Result, 7);
  Insert('/', Result, 11);
  Insert('-', Result, 16);
end;

{ TFASCheckCPF }

class function TLmxCheckCPF.Execute(const ACPF: string): Boolean;
var
  I, n1, n2, n3, n4, n5, n6, n7, n8, n9, d1, d2: integer;
  cCpf, Digitado, Calculado: string;
begin
  try
    if Length(ACPF) > 11 then
    begin
      for I := 1 to Length(ACPF) do
      begin
//        if (ACPF[I] in ['0'..'9']) then
        if (CharInSet(ACPF[I], ['0'..'9'])) then
          cCpf := cCpf + ACPF[I]
        else
          Continue;
      end;
    end
    else
      cCpf := ACPF;
    cCpf := Copy(cCpf, 1, 11);
    for I := 0 to 9 do
      if cCpf = StrReplicate(IntToStr(I), 11) then
        raise Exception.Create('');
    n1 := StrToInt(cCpf[1]);
    n2 := StrToInt(cCpf[2]);
    n3 := StrToInt(cCpf[3]);
    n4 := StrToInt(cCpf[4]);
    n5 := StrToInt(cCpf[5]);
    n6 := StrToInt(cCpf[6]);
    n7 := StrToInt(cCpf[7]);
    n8 := StrToInt(cCpf[8]);
    n9 := StrToInt(cCpf[9]);
    d1 := n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8 + n2 * 9
      + n1 * 10;
    d1 := 11 - (d1 mod 11);
    if d1 >= 10 then
      d1 := 0;
    d2 := d1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7 + n4 * 8 + n3 * 9
      + n2 * 10 + n1 * 11;
    d2 := 11 - (d2 mod 11);
    if d2 >= 10 then
      d2 := 0;
    Calculado := IntToStr(d1) + IntToStr(d2);
    Digitado := cCpf[10] + cCpf[11];
    if Calculado = Digitado then
      Result := True
    else
      Result := False;
  except
    Result := False;
  end;
end;

class function TLmxCheckCPF.Formata(const ACPF: string): string;
begin
  Result := ACPF;
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '', [rfReplaceAll]);
  //000.000.000-00
  Result := StrAlignRight('00000000000'+Result, 11);
  Insert('.', Result, 4);
  Insert('.', Result, 8);
  Insert('-', Result, 12);
end;


initialization
	InvRegistry.RegisterInterface(TypeInfo(wscepSoap), 'http://tempuri.org/', 'utf-8');
	InvRegistry.RegisterDefaultSOAPAction(TypeInfo(wscepSoap), 'http://tempuri.org/cep');
	InvRegistry.RegisterInvokeOptions(TypeInfo(wscepSoap), ioDocument);

end.

