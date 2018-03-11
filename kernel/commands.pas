unit commands;

interface

procedure ProcessCommand(const Cmd: String);
procedure AddToHistory(const Cmd: String);
function PreviousCommand: String;
function NextCommand: String;
procedure ResetCommands;

implementation

uses
  console, cpuid, rtc;

{ Implementation to restart the OS }
procedure Restart;
begin
  ClearScreen;
  WriteLn('Restarting OS...');
  asm
    { PMODE ONLY!!! }
    mov al,$FE
    out 64h,al // Causes a Soft Reset
    { END }
    { USER MODE
      DB 0EAh  // Jump to reboot address (FFFF:0000)
      DW 0000h
      DW 0FFFFh
    }
  end ['eax'];
end;

{ Implementation to display a shutdown msg and halt the OS }
procedure ShutDown;
begin
  ClearScreen;
  SetTextColor(scBlack, scLightGreen);
  WriteLn('You may now remove the OS disk/image from your PC/emulator and ReBoot');
  asm
    cli
    hlt
  end;
end;

procedure DumpRegs;
label
  GetEIP;
var
  Reg: array [0..7] of LongWord;
  SReg: array [0..5] of Word;
  EFLAGS, CurrentEIP: LongWord;
begin
  asm
    // save registers while they are not modified by another procedure call. note that
    // depending on your compiler settings, ebp may already be trashed (stack frame)
    mov dword ptr Reg[4*0],eax
    mov dword ptr Reg[4*1],ecx
    mov dword ptr Reg[4*2],edx
    mov dword ptr Reg[4*3],ebx
    mov dword ptr Reg[4*4],esp
    // esp is already incorrect since it was decreased by
    // the amount of stack space the local variables require
    mov eax,8*4+6*2+4+4
    add dword ptr Reg[4*4],eax // correct esp
    mov dword ptr Reg[4*5],ebp
    mov dword ptr Reg[4*6],esi
    mov dword ptr Reg[4*7],edi
    // save segment registers
    mov word ptr SReg[2*0],ds
    mov word ptr SReg[2*1],es
    mov word ptr SReg[2*2],cs
    mov word ptr SReg[2*3],ss
    mov word ptr SReg[2*4],fs
    mov word ptr SReg[2*5],gs
    // save EFLAGS
    pushfd
    pop dword ptr EFLAGS
    // now get eip
    call GetEIP
    GetEIP: pop dword ptr CurrentEIP
  end ['eax','ebx','ecx','edx','esp','ebp','esi','edi','ds','es','cs','ss','fs','gs'];
  WriteLn('EAX    = ' + HexStr(Reg[0], 8));
  WriteLn('ECX    = ' + HexStr(Reg[1], 8));
  WriteLn('EDX    = ' + HexStr(Reg[2], 8));
  WriteLn('EBX    = ' + HexStr(Reg[3], 8));
  WriteLn('ESP    = ' + HexStr(Reg[4], 8));
  WriteLn('EBP    = ' + HexStr(Reg[5], 8));
  WriteLn('ESI    = ' + HexStr(Reg[6], 8));
  WriteLn('EDI    = ' + HexStr(Reg[7], 8));
  WriteLn('DS     = ' + HexStr(SReg[0], 8));
  WriteLn('ES     = ' + HexStr(SReg[1], 8));
  WriteLn('CS     = ' + HexStr(SReg[2], 8));
  WriteLn('SS     = ' + HexStr(SReg[3], 8));
  WriteLn('FS     = ' + HexStr(SReg[4], 8));
  WriteLn('GS     = ' + HexStr(SReg[5], 8));
  WriteLn('EFLAGS = ' + HexStr(EFLAGS, 8));
  WriteLn('EIP    = ' + HexStr(CurrentEIP, 8));
end;

procedure ShowDate;
const
  Days: array [1..7] of String = (
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
    );
  Months: array [1..12] of String = (
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
    );
var
  s: String;
begin
  with GetTime do begin
    Str(DayOfMonth,s);
    Write(Days[DayOfWeek + 1] + ', ' + Months[Month] + ' ' + s);
    if DayOfMonth in [11..13] then
      Write('th')
    else
      case DayOfMonth mod 10 of
        1: Write('st');
        2: Write('nd');
        3: Write('rd');
        else Write('th');
      end;
    Write(' ');
    if Year < 10 then
      Write('0');
    WriteLn(Year);
  end;
end;

procedure ShowTime;
var
  s,t: String;
begin
  s := '';
  with GetTime do begin
    if Hour < 10 then
      s := s + '0';
    Str(Hour, t);
    s := s + t + ':';
    if Minute < 10 then
      s := s + '0';
    Str(Minute, t);
    s := s + t + ':';
    if Second < 10 then
      s := s + '0';
    Str(Second, t);
    s := s + t;
    WriteLn(s);
  end;
end;

procedure ShowThanks;
const
  ThanksList: array [1..8] of String = (
    'Brendan       (http://www.osdever.net\bkerndev)',
    'Mike          (http://www.brokenthorn.com)',
    'JamesM        (http://www.jamesmolloy.co.uk)',
    'SirStorm25    (???)',
    'Uranium-239   (???)',
    'Napalm        (???)',
    'Xiaoming      (http://en.skelix.org)',
    'Yacine REZGUI (yacine.rezgui@gmail.com)'
    );
var
  i: Byte;
  s: String;
begin
  s := ThanksList[Low(ThanksList)];
  for i := Low(ThanksList) + 1 to High(ThanksList) do
    s := s + LineEnding + ThanksList[i];
  WriteLn(s);
end;

procedure PrintHelp; forward;

type
  TCommands = record
    Name: String;
    Description: String;
    Proc: TProcedure;
  end;

  TCommandHistory = record
    Commands: array [0..255] of String;
    Current: Byte;
  end;

var
  CommandHistory: TCommandHistory;

const
  MaxCmdLen = 8; // Any better idea so I don't have to maintain this maually?
  { Make sure these are always alphabetically sorted as
    the search function performs binary search }
  ShellCommands: array [1..9] of TCommands = (
    (Name: 'cls'; Description: 'Clear the screen';
    Proc: @ClearScreen),
    (Name: 'cpuid'; Description: 'Get CPU ID and Vendor';
    Proc: @DetectCPUID),
    (Name: 'date'; Description: 'Get current date';
    Proc: @ShowDate),
    (Name: 'help'; Description: 'You''re looking at it';
    Proc: @PrintHelp),
    (Name: 'regs'; Description: 'Dump register contents';
    Proc: @DumpRegs),
    (Name: 'restart'; Description: 'Restart the OS';
    Proc: @Restart),
    (Name: 'shutdown'; Description: 'Halts the machine';
    Proc: @Shutdown),
    (Name: 'thanks'; Description: 'List people who have helped';
    Proc: @ShowThanks),
    (Name: 'time'; Description: 'Get current time';
    Proc: @ShowTime)
    );

procedure PrintHelp;
var
  i: Byte;
begin
  WriteLn('Internal commands:');
  for i := Low(ShellCommands) to High(ShellCommands) do
    with ShellCommands[i] do begin
      Write(Name);
        Write(StringOfChar(' ',MaxCmdLen - Length(Name) + 1));
      WriteLn(Description);
    end;
end;

function IsShellCommand(const Cmd: String; var idx: Byte): Boolean;

  function SearchCommand(l, r: Byte): Boolean;
  var
    mid: Byte;
  begin
    if l > r then begin
      SearchCommand := False;
      Exit;
    end;
    mid := (l + r) div 2;
    if Cmd < ShellCommands[mid].Name then
      SearchCommand := SearchCommand(l, mid - 1)
    else if Cmd > ShellCommands[mid].Name then
      SearchCommand := SearchCommand(mid + 1, r)
    else begin
      SearchCommand := True;
      idx := mid;
    end;
  end;

begin
  IsShellCommand := SearchCommand(Low(ShellCommands), High(ShellCommands));
end;

procedure ProcessCommand(const Cmd: String);
var
  i: Byte;
begin
  if IsShellCommand(LowerCase(Cmd), i) then
    ShellCommands[i].Proc
  else if Cmd <> '' then
    // Windows (or DOS?)-like error message
    WriteLn('''' + Cmd + ''' is not recognized as an internal command ' +
      'or external command,' + LineEnding + 'operable program or batch file.');
end;

procedure AddToHistory(const Cmd: String);
begin
  with CommandHistory do
    if Cmd <> Commands[Current] then begin
      Move(Commands[1], Commands, 255 * 256);
      // Shift 1st - 255th up, overwriting the 0th
      Commands[255] := Cmd;
      ResetCommands;
    end;
end;

function PreviousCommand: String;
begin
  with CommandHistory do begin
    PreviousCommand := Commands[Current];
    if (Current > 0) and (Commands[Current - 1] <> '') then
      Dec(Current);
  end;
end;

function NextCommand: String;
begin
  with CommandHistory do begin
    if Current < 255 then
      Inc(Current);
    NextCommand := Commands[Current];
  end;
end;

procedure ResetCommands;
begin
  CommandHistory.Current := 255;
end;

end.

