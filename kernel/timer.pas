unit timer;

interface

procedure TimerPhase(const Hz: LongWord);
procedure Install(const PhasePerSecond: LongWord);
procedure TimerWait(const Ticks: LongWord);

implementation

uses
  x86, console, irq;

var
  CurrentPhase: LongWord;
  TimerTicks: LongWord = 0;

procedure TimerHandler(var r: TRegisters);
begin
  Inc(TimerTicks);
  if TimerTicks mod CurrentPhase = 0 then begin // One second has passed...
    TimerTicks := 0;
    // WriteLn('Tick');
  end;
end;

procedure TimerPhase(const Hz: LongWord);
var
  Divisor: LongWord;
begin
  Divisor := 1193180 div Hz;
  WritePortB($43, $36);
  WritePortB($40, Divisor and $FF);
  WritePortB($40, Divisor shr 8);
end;

procedure Install(const PhasePerSecond: LongWord);
begin
  WriteString('Installing Timer...'#9#9);
  IRQ.InstallHandler(0, @TimerHandler);
  { With this, TimerWait(100) will (approximately) wait for 1 second }
  TimerPhase(PhasePerSecond);
  CurrentPhase := PhasePerSecond;
  WriteStrLn('[ OK ]');
end;

procedure TimerWait(const Ticks: LongWord); [public, alias: 'TimerWait'];
var
  ETicks: LongWord;
begin
  ETicks := TimerTicks + Ticks;
  while TimerTicks < ETicks do ;
end;

end.

