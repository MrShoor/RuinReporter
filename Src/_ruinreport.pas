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
    if (int_handle = nil) then Exit;

    connect_handle := InternetConnect(int_handle, PChar(host), 80, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if (connect_handle = nil) then Exit;

    accept[0] := '*/*';
    accept[1] := '';

    request_handle := HttpOpenRequest(connect_handle, 'POST', PChar(url), nil, nil, @accept[0], 0, 1);
    if (request_handle = nil) then Exit;

    header := 'Content-Type: application/x-www-form-urlencoded' + sLineBreak + 'Content-Length: ';
    header := header + IntToStr(Length(data)) + sLineBreak;

    if not HttpSendRequest(request_handle, PChar(header), Length(header), PChar(data), Length(data)) then Exit;

    SetLength(tmpbuffer, 1024);
    bytesread := 1024;
    alltxt := '';
    while InternetReadFile(request_handle, @tmpbuffer[1], 1024, bytesread) and (bytesread > 0) do
      alltxt := alltxt + Copy(tmpbuffer, 1, bytesread);

    if alltxt <> 'OK' then
      MessageBox(0, PChar(alltxt), 'Report error', MB_OK or MB_ICONERROR);
  finally
    if (request_handle) <> nil then InternetCloseHandle(request_handle);
    if (connect_handle) <> nil then InternetCloseHandle(connect_handle);
    if (int_handle) <> nil then InternetCloseHandle(int_handle);
  end;
end;

procedure SendReport_HTTP(const AReport: TReport);
begin
  HTTP_Post('RuinReporter v0.1', 'rareeditor.com', 'test.php', 'data='+AReport.ToJSON());
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
    MessageBoxW(0, 'RuinR_AppName not defined', 'Report error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  path := GetApplicationStoragePath();
  path := path + '\' + RuinR_AppName;
  if not DirectoryExists(path) then
  begin
    wpath := UnicodeString(path);
    if not CreateDir(wpath) then
    begin
      wpath := 'Unable to create directory: "' + wpath + '"';
      MessageBoxW(0, PWideChar(wpath), 'Report error', MB_OK or MB_ICONERROR);
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
      on e: EFCreateError do MessageBoxW(0, 'Unable to create report file', 'Report error', MB_OK or MB_ICONERROR);
      on e: EFOpenError do MessageBoxW(0, 'Unable to open report file', 'Report error', MB_OK or MB_ICONERROR);
    end;
  finally
    FreeAndNil(sl);
  end;
end;

end.
