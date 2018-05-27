unit RuinR;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TRuinReportMode = (rrmNone, rrmFile, rrmHTTP);

  TApplicationExceptionHandler = class
    procedure OnException(Sender : TObject; E: Exception);
  end;

var RuinR_AppName: string;
var RuinR_Mode   : TRuinReportMode;

var RuinR_HTTPServer: string;
var RuinR_HTTPPage  : string;

var RuinR_UserID : string;

var RuinR_InCrash: Boolean;

function RuinR_AppHandler: TApplicationExceptionHandler;

implementation

uses
  Windows,
  _RuinTypes, _RuinReport;

var
  GV_AppHandler: TApplicationExceptionHandler;

procedure RuinExceptProc(Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer);
var report: TReport;
    msg: UnicodeString;
begin
  RuinR_InCrash := True;

  if RuinR_Mode = rrmNone then Exit;

  report := BuildReport(Obj, Addr, FrameCount, Frame);
  case RuinR_Mode of
    rrmFile:
        SaveReportToFile(report);
    rrmHTTP:
        SendReport_HTTP(report);
  end;

  msg := 'Encountered error. Application will be closed.' + sLineBreak + sLineBreak;
  msg := msg + UnicodeString(Obj.ClassName);
  if Obj is Exception then
    msg := msg + ': "' + UnicodeString(Exception(Obj).Message) + '"';
  MessageBoxW(0, PWideChar(msg), 'Sorry', MB_OK or MB_ICONERROR);
  ExitProcess(1);
end;

procedure DummyExceptProc(Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer);
begin

end;

function RuinR_AppHandler: TApplicationExceptionHandler;
begin
  Result := GV_AppHandler;
end;

{ TApplicationExceptionHandler }

procedure TApplicationExceptionHandler.OnException(Sender : TObject; E: Exception);
begin
  ExceptProc(E, ExceptAddr, ExceptFrameCount, ExceptFrames);
end;

initialization
  ExceptProc := @RuinExceptProc;
  GV_AppHandler := TApplicationExceptionHandler.Create;
  RuinR_HTTPPage := 'report.php';
  RuinR_InCrash := False;

finalization
  ExceptProc := @DummyExceptProc;
  FreeAndNil(GV_AppHandler);

end.

