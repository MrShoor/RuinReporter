unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  EMyException = class(Exception);

  { TfrmMain }

  TfrmMain = class(TForm)
    btnMyException: TButton;
    procedure btnMyExceptionClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnMyExceptionClick(Sender: TObject);
begin
  raise EMyException.Create('My exception message.');
end;

end.

