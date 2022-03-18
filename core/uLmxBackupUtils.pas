unit uLmxBackupUtils;

interface

uses
  uLmxConexao, System.SysUtils;

type

  TLmxBackupUtils = class
  public
//    procedure DoLoadLastBackup;
//    procedure DoLoad;
//    procedure DoBackup;
//    procedure DoRestaure;
//    procedure DoFix;
//    procedure DoSend;



    // Fazer Backup
    // Fazer Fix no Banco
    procedure FazerBackup;
  end;

  function LmxBackupUtils : TLmxBackupUtils;


implementation

var
  FLmxBackupUtils : TLmxBackupUtils;


function LmxBackupUtils : TLmxBackupUtils;
begin
  Result := FLmxBackupUtils;
end;


{ TLmxBackupUtils }

procedure TLmxBackupUtils.FazerBackup;
begin
  LmxConexao.Backup('./NomeBackup.lmx');
end;

initialization
  FLmxBackupUtils := TLmxBackupUtils.Create;

finalization
  FreeAndNil(FLmxBackupUtils);

end.
