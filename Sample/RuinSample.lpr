program RuinSample;

{$mode objfpc}{$H+}

uses

  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, untMain,
  RuinR
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.OnException := @RuinR_AppHandler.OnException;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

