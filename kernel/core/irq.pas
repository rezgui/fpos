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

unit IRQ;

interface

type
  TIRQHandler = procedure (var r: TRegisters);

procedure InstallHandler(const IRQNo: Byte; Handler: TIRQHandler);
procedure UninstallHandler(const IRQNo: Byte);
procedure Install;

implementation

uses
  x86,console,idt;

const
  IRQRoutines: array [0..15] of TIRQHandler = (
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil
  );

procedure IRQ0; external name 'irq0';
procedure IRQ1; external name 'irq1';
procedure IRQ2; external name 'irq2';
procedure IRQ3; external name 'irq3';
procedure IRQ4; external name 'irq4';
procedure IRQ5; external name 'irq5';
procedure IRQ6; external name 'irq6';
procedure IRQ7; external name 'irq7';
procedure IRQ8; external name 'irq8';
procedure IRQ9; external name 'irq9';
procedure IRQ10; external name 'irq10';
procedure IRQ11; external name 'irq11';
procedure IRQ12; external name 'irq12';
procedure IRQ13; external name 'irq13';
procedure IRQ14; external name 'irq14';
procedure IRQ15; external name 'irq15';

procedure InstallHandler(const IRQNo: Byte; Handler: TIRQHandler);
begin
  IRQRoutines[IRQNo]:=Handler;
end;

procedure UninstallHandler(const IRQNo: Byte);
begin
  IRQRoutines[IRQNo]:=nil;
end;

procedure Remap;
begin
  WritePortB($20,$11);
  WritePortB($A0,$11);
  WritePortB($21,$20);
  WritePortB($A1,$28);
  WritePortB($21,$04);
  WritePortB($A1,$02);
  WritePortB($21,$01);
  WritePortB($A1,$01);
  WritePortB($21,$0);
  WritePortB($A1,$0);
end;

procedure Install;
begin
  WriteString('Installing IRQ...'#9#9);
  Remap;
  IDT.SetGate(32,PtrUInt(@IRQ0),$08,$8E);
  IDT.SetGate(33,PtrUInt(@IRQ1),$08,$8E);
  IDT.SetGate(34,PtrUInt(@IRQ2),$08,$8E);
  IDT.SetGate(35,PtrUInt(@IRQ3),$08,$8E);
  IDT.SetGate(36,PtrUInt(@IRQ4),$08,$8E);
  IDT.SetGate(37,PtrUInt(@IRQ5),$08,$8E);
  IDT.SetGate(38,PtrUInt(@IRQ6),$08,$8E);
  IDT.SetGate(39,PtrUInt(@IRQ7),$08,$8E);
  IDT.SetGate(40,PtrUInt(@IRQ8),$08,$8E);
  IDT.SetGate(41,PtrUInt(@IRQ9),$08,$8E);
  IDT.SetGate(42,PtrUInt(@IRQ10),$08,$8E);
  IDT.SetGate(43,PtrUInt(@IRQ11),$08,$8E);
  IDT.SetGate(44,PtrUInt(@IRQ12),$08,$8E);
  IDT.SetGate(45,PtrUInt(@IRQ13),$08,$8E);
  IDT.SetGate(46,PtrUInt(@IRQ14),$08,$8E);
  IDT.SetGate(47,PtrUInt(@IRQ15),$08,$8E);
  WriteStrLn('[ OK ]');
end;

procedure IRQHandler(var r: TRegisters); cdecl; [public, alias: 'IRQHandler'];
var
  Handler: TIRQHandler;
begin
  Handler:=IRQRoutines[r.InterruptNumber-32];
  if Assigned(Handler) then Handler(r);
  if r.InterruptNumber>=40 then WritePortB($A0,$20);
  WritePortB($20,$20);
end;

end.
