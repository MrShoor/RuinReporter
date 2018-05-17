unit _RuinReport;

{$mode objfpc}{$H+}

interface

uses
  _RuinTypes;

function  BuildReport(Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer): TReport;
procedure SendReport_HTTP(const AReport: TReport);

implementation

uses SysUtils;

function BuildReport(Obj: TObject; Addr: CodePointer; FrameCount: Longint; Frame: PCodePointer): TReport;
var
  i: Integer;
begin
  if Obj = nil then
    Result.ExceptionObject := 'Unknown object'
  else
    Result.ExceptionObject := Obj.ClassName;
  if Obj is Exception then
    Result.ExceptionMessage := Exception(Obj).Message
  else
    Result.ExceptionMessage := '';

  SetLength(Result.Stack, FrameCount + 1);
  Result.Stack[0].Source := BackTraceStrFunc(Addr);
  for i := 0 to FrameCount - 1 do
    Result.Stack[i+1].Source := BackTraceStrFunc(Frame[i]);
end;

procedure SendReport_HTTP(const AReport: TReport);
begin
  //todo
end;

end.

