unit _RuinReport;

{$mode objfpc}{$H+}

interface

uses
  _RuinTypes, WinInet;

function  BuildReport(Obj : TObject; Addr : CodePointer; FrameCount:Longint; Frame: PCodePointer): TReport;
procedure SendReport_HTTP(const AReport: TReport);
procedure SaveReportToFile(const AReport: TReport);

implementation

uses Classes, SysUtils, Windows, RuinR;

procedure DisplayMessage(const s: string);
var ws: WideString;
begin
  ws := WideString(s);
  MessageBoxW(0, PWideChar(ws), 'Report error', MB_OK or MB_ICONERROR);
end;

function BuildReport(Obj: TObject; Addr: CodePointer; FrameCount: Longint; Frame: PCodePointer): TReport;
var
  i: Integer;
begin
  Result.UserID := RuinR_UserID;
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

procedure HTTP_Post(const agent, host, url: string; data: string);
var int_handle : HINTERNET;
    connect_handle : HINTERNET;
    request_handle : HINTERNET;
    accept: array [0..1] of string;
    header: string;

    tmpbuffer: string;
    bytesread: Cardinal;
    alltxt: string;
begin
  request_handle := nil;
  int_handle := nil;
  connect_handle := nil;
  try
    int_handle := InternetOpen(PChar(agent), INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
    if (int_handle = nil) then
    begin
      DisplayMessage('Unable to open conneciton');
      Exit;
    end;

    connect_handle := InternetConnect(int_handle, PChar(host), 80, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if (connect_handle = nil) then
    begin
      DisplayMessage('Report server not available');
      Exit;
    end;

    accept[0] := '*/*';
    accept[1] := '';

    request_handle := HttpOpenRequest(connect_handle, 'POST', PChar(url), nil, nil, @accept[0], 0, 1);
    if (request_handle = nil) then
    begin
      DisplayMessage('Unable to open HTTP request');
      Exit;
    end;

    header := 'Content-Type: application/x-www-form-urlencoded' + sLineBreak + 'Content-Length: ';
    header := header + IntToStr(Length(data)) + sLineBreak;

    if not HttpSendRequest(request_handle, PChar(header), Length(header), PChar(data), Length(data)) then
    begin
      DisplayMessage('Report not sended');
      Exit;
    end;

    SetLength(tmpbuffer, 1024);
    bytesread := 1024;
    alltxt := '';
    while InternetReadFile(request_handle, @tmpbuffer[1], 1024, bytesread) and (bytesread > 0) do
      alltxt := alltxt + Copy(tmpbuffer, 1, bytesread);

    if alltxt <> 'OK' then
      DisplayMessage(alltxt);
  finally
    if (request_handle) <> nil then InternetCloseHandle(request_handle);
    if (connect_handle) <> nil then InternetCloseHandle(connect_handle);
    if (int_handle) <> nil then InternetCloseHandle(int_handle);
  end;
end;

procedure SendReport_HTTP(const AReport: TReport);
begin
  HTTP_Post('RuinReporter v0.1', RuinR_HTTPServer, RuinR_HTTPPage, 'data='+AReport.ToJSON());
end;

function GetApplicationStoragePath: string;
var path: WideString;
begin
  SetLength(path, GetEnvironmentVariableW('appdata', nil, 0) - 1);
  GetEnvironmentVariableW('appdata', PWideChar(path), Length(path) + 1);
  Result := string(path);
end;

function GenerateFileName: string;
var path, filepart: string;
    wpath: UnicodeString;
begin
  Result := '';
  if RuinR_AppName = '' then
  begin
    DisplayMessage('RuinR_AppName not defined');
    Exit;
  end;

  path := GetApplicationStoragePath();
  path := path + '\' + RuinR_AppName;
  wpath := UnicodeString(path);
  if not DirectoryExists(wpath) then
  begin
    if not CreateDir(wpath) then
    begin
      DisplayMessage('Unable to create directory: "' + path + '"');
      Exit;
    end;
  end;
  filepart := '\RuniR_' + FormatDateTime('YYYY_MM_DD_hh_nn_ss',Now()) + '.txt';
  Result := path + filepart;
end;

procedure SaveReportToFile(const AReport: TReport);
var sl: TStringList;
    targetfile: string;
begin
  targetfile := GenerateFileName();
  if targetfile = '' then Exit;

  sl := TStringList.Create;
  try
    sl.Text := AReport.ToText();
    try
      sl.SaveToFile(targetfile);
    except
      on e: EFCreateError do DisplayMessage('Unable to create report file');
      on e: EFOpenError do DisplayMessage('Unable to open report file');
    end;
  finally
    FreeAndNil(sl);
  end;
end;

end.
