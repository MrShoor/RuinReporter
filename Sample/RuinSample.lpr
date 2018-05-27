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
  RuinR_AppName := 'RuinR_Demo';
  RuinR_Mode := rrmHTTP;
  RuinR_UserID := 'Demo_User';
  RuinR_HTTPServer := 'your_server.com';

  RequireDerivedFormResource := True;
  Application.OnException := @RuinR_AppHandler.OnException;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

