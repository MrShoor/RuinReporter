unit _RuinTypes;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

type
  TStackLine = record
    //LineNo  : Integer;
    //FuncName: string;
    Source  : string;
  end;

  { TReport }

  TReport = record
    UserID: string;
    ExceptionObject : string;
    ExceptionMessage: string;
    Stack: array of TStackLine;
    function ToJSON(): string;
    function ToText(): string;
  end;

implementation

{ TReport }

function TReport.ToJSON: string;
var i: Integer;
begin
  Result := '{"UserID":"'+UserID+'","Object":"'+ExceptionObject+'","Message":"'+ExceptionMessage+'","Stack":"';
  for i := 0 to Length(Stack) - 1 do
    Result := Result + Stack[i].Source + '\n';
  Result := Result + '"}';
end;

function TReport.ToText: string;
var i: Integer;
begin
  Result := 'UserID: ' + UserID + sLineBreak;
  Result := Result + 'ExceptionObject: ' + ExceptionObject + sLineBreak;
  Result := Result + 'ExceptionMessage: ' + ExceptionMessage + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + 'Stack trace: ' + sLineBreak;
  for i := 0 to Length(Stack) - 1 do
    Result := Result + '  ' + Stack[i].Source + sLineBreak;
end;

end.

