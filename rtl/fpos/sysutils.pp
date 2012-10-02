unit sysutils;

interface

{$MODE objfpc}
{ force ansistrings }
{$H+}

{$DEFINE HAS_SLEEP}
{$DEFINE HAS_OSERROR}

{ Include platform independent interface part }
{$i sysutilh.inc}

implementation

uses
  sysconst;

{ Include platform independent implementation part }
{$i sysutils.inc}

type
  TTime = record
    Second,Minute,Hour,DayOfWeek,DayOfMonth,Month,Year: Byte;
  end;

procedure Sound(Hz: LongWord); external name 'Sound';
procedure TimerWait(Ticks: LongWord); external name 'TimerWait';
function GetTime: TTime; external name 'GetTime';

Procedure GetLocalTime(var SystemTime: TSystemTime);
begin
  with GetTime do begin
    SystemTime.Year:=Year;
    SystemTime.Month:=Month;
    SystemTime.Day:=DayOfMonth;
    SystemTime.Hour:=Hour;
    SystemTime.Minute:=Minute;
    SystemTime.Second:=Second;
    SystemTime.MilliSecond:=Second*1000;
  end;
end;

Function GetLastOSError : Integer;
begin
  Result:=0;
end;

Function FileOpen (Const FileName : string; Mode : Integer) : THandle;
begin
  Result:=0;
end;

Function FileCreate (Const FileName : String) : THandle;
begin
  Result:=0;
end;

Function FileCreate (Const FileName : String; Mode : Integer) : THandle;
begin
  Result:=0;
end;

Function FileRead (Handle : THandle; out Buffer; Count : longint) : Longint;
begin
  Result:=0;
end;

Function FileWrite (Handle : THandle; const Buffer; Count : Longint) : Longint;
begin
  Result:=0;
end;

Function FileSeek (Handle : THandle; FOffset, Origin: Longint) : Longint;
begin
  Result:=0;
end;

Function FileSeek (Handle : THandle; FOffset: Int64; Origin: Longint) : Int64;
begin
  Result:=0;
end;

Procedure FileClose (Handle : THandle);
begin

end;

Function FileTruncate (Handle : THandle;Size: Int64) : boolean;
begin
  Result:=false;
end;

Function FileAge (Const FileName : String): Longint;
begin
  Result:=0;
end;

Function FileExists (Const FileName : String) : Boolean;
begin
  Result:=false;
end;

Function DirectoryExists (Const Directory : String) : Boolean;
begin
  Result:=false;
end;

Function FindFirst (Const Path : String; Attr : Longint; out Rslt : TSearchRec) : Longint;
begin
  Result:=0;
end;

Function FindNext (Var Rslt : TSearchRec) : Longint;
begin
  Result:=0;
end;

Procedure FindClose (Var F : TSearchrec);
begin

end;

Function FileGetDate (Handle : THandle) : Longint;
begin
  Result:=0;
end;

Function FileSetDate (Handle : THandle;Age : Longint) : Longint;
begin
  Result:=0;
end;

Function FileGetAttr (Const FileName : String) : Longint;
begin
  Result:=0;
end;

Function FileSetAttr (Const Filename : String; Attr: longint) : Longint;
begin
  Result:=0;
end;

Function DeleteFile (Const FileName : String) : Boolean;
begin
  Result:=false;
end;

Function RenameFile (Const OldName, NewName : String) : Boolean;
begin
  Result:=false;
end;

Function  DiskFree(drive: byte) : int64;
begin
  Result:=0;
end;

Function  DiskSize(drive: byte) : int64;
begin
  Result:=0;
end;

Function GetCurrentDir : String;
begin
  Result:='';
end;


Function SetCurrentDir (Const NewDir : String) : Boolean;
begin
  Result:=false;
end;

Function CreateDir (Const NewDir : String) : Boolean;
begin
  Result:=false;
end;

Function RemoveDir (Const Dir : String) : Boolean;
begin
  Result:=false;
end;

function SysErrorMessage(ErrorCode: Integer): String;
begin

end;

Function GetEnvironmentVariable(Const EnvVar : String) : String;
begin

end;

Function GetEnvironmentVariableCount : Integer;
begin

end;

Function GetEnvironmentString(Index : Integer) : String;
begin

end;

procedure Sleep(milliseconds: Cardinal);
begin
  TimerWait(milliseconds div 10);
end;

function ExecuteProcess(Const Path: AnsiString; Const ComLine: AnsiString;Flags:TExecuteFlags=[]):integer;
begin

end;

function ExecuteProcess(Const Path: AnsiString; Const ComLine: Array of AnsiString;Flags:TExecuteFlags=[]):integer;
begin

end;

Initialization
  InitExceptions;       { Initialize exceptions. OS independent }

Finalization
  DoneExceptions;

end.
