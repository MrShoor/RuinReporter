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

function RuinR_AppHandler: TApplicationExceptionHandler;

implementation

uses
  Windows,
  _RuinTypes, _RuinReport;

var
  GV_AppHandler: TApplicationExceptionHandler;

procedure RuinExceptProc(Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer);
var report: TReport;
begin
  if RuinR_Mode = rrmNone then Exit;

  report := BuildReport(Obj, Addr, FrameCount, Frame);
  case RuinR_Mode of
    rrmFile:
        SaveReportToFile(report);
    rrmHTTP:
        SendReport_HTTP(report);
  end;

  MessageBox(0, 'Encountered error. Application will be closed.', 'Sorry', MB_OK or MB_ICONERROR);
  Halt(-1);
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

finalization
  ExceptProc := @DummyExceptProc;
  FreeAndNil(GV_AppHandler);

end.

