unit system;

interface

{$define FPC_IS_SYSTEM}

{ include system-independent routine headers }
{$I systemh.inc}

const
  LineEnding = #13#10;
  LFNSupport = true;
  DirectorySeparator = '\';
  DriveSeparator = ':';
  ExtensionSeparator = '.';
  PathSeparator = ';';
  AllowDirectorySeparators : set of char = ['\','/'];
  AllowDriveSeparators : set of char = [':'];
  { FileNameCaseSensitive is defined separately below!!! }
  maxExitCode = 65535;
  MaxPathLen = 260;
  AllFilesMask = '*';
  { Default filehandles }
  UnusedHandle    : THandle = THandle(-1);
  StdInputHandle  : THandle = 1;
  StdOutputHandle : THandle = 0;
  StdErrorHandle  : THandle = 2;
  FileNameCaseSensitive : boolean = false;
  CtrlZMarksEOF: boolean = true; (* #26 is considered as end of file *)
  sLineBreak = LineEnding;
  DefaultTextLineBreakStyle : TTextLineBreakStyle = tlbsCRLF;

var
{ C compatible arguments }
  argc : longint;
  argv : ppchar;

implementation

{$I system.inc}

procedure SysInitStdIO;
begin
  OpenStdIO(Output,fmOutput,StdOutputHandle);
end;

procedure system_exit;
begin

end;

begin
  SysResetFPU;
  if not(IsLibrary) then
    SysInitFPU;
  InitHeap;
  SysInitExceptions;
  SysInitStdIO;
  InOutRes:=0;
  InitSystemThreads;
  initvariantmanager;
{$ifndef VER2_2}
  initunicodestringmanager;
{$else VER2_2}
  initwidestringmanager;
{$endif VER2_2}
end.
