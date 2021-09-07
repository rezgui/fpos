// Copyright (C) 2010-2021 Yacine REZGUI
// 
// This file is part of fpos.
// 
// fpos is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
// 
// fpos is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with fpos.  If not, see <http://www.gnu.org/licenses/>.

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

