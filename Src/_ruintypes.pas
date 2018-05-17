unit _RuinTypes;

{$mode objfpc}{$H+}

interface

type
  TStackLine = record
    //LineNo  : Integer;
    //FuncName: string;
    Source  : string;
  end;

  TReport = record
    ExceptionObject : string;
    ExceptionMessage: string;
    Stack: array of TStackLine;
  end;

implementation

end.

