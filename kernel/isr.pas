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

unit ISR;

{$mode objfpc}{$H+}

interface

type
  TISRHandler = procedure (var r: TRegisters);

procedure InstallHandler(const ISRNo: Byte; Handler: TISRHandler);
procedure UninstallHandler(const ISRNo: Byte);
procedure Install;

implementation

uses
  speaker,console,idt;

const
  ExceptionMessages: array [0..31] of String = (
    'Division By Zero',
    'Debug',
    'Non Maskable Interrupt',
    'Breakpoint',
    'Into Detected Overflow',
    'Out of Bounds',
    'Invalid Opcode',
    'No Coprocessor',
    'Double Fault',
    'Coprocessor Segment Overrun',
    'Bad TSS',
    'Segment Not Present',
    'Stack Fault',
    'General Protection Fault',
    'Page Fault',
    'Unknown Interrupt',
    'Coprocessor Fault',
    'Alignment Check',
    'Machine Check',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved'
  );
  ISRRoutines: array [0..31] of TISRHandler = (
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil
  );

procedure ISR0; external name 'isr0';
procedure ISR1; external name 'isr1';
procedure ISR2; external name 'isr2';
procedure ISR3; external name 'isr3';
procedure ISR4; external name 'isr4';
procedure ISR5; external name 'isr5';
procedure ISR6; external name 'isr6';
procedure ISR7; external name 'isr7';
procedure ISR8; external name 'isr8';
procedure ISR9; external name 'isr9';
procedure ISR10; external name 'isr10';
procedure ISR11; external name 'isr11';
procedure ISR12; external name 'isr12';
procedure ISR13; external name 'isr13';
procedure ISR14; external name 'isr14';
procedure ISR15; external name 'isr15';
procedure ISR16; external name 'isr16';
procedure ISR17; external name 'isr17';
procedure ISR18; external name 'isr18';
procedure ISR19; external name 'isr19';
procedure ISR20; external name 'isr20';
procedure ISR21; external name 'isr21';
procedure ISR22; external name 'isr22';
procedure ISR23; external name 'isr23';
procedure ISR24; external name 'isr24';
procedure ISR25; external name 'isr25';
procedure ISR26; external name 'isr26';
procedure ISR27; external name 'isr27';
procedure ISR28; external name 'isr28';
procedure ISR29; external name 'isr29';
procedure ISR30; external name 'isr30';
procedure ISR31; external name 'isr31';

procedure InstallHandler(const ISRNo: Byte; Handler: TISRHandler);
begin
  ISRRoutines[ISRNo]:=Handler;
end;

procedure UninstallHandler(const ISRNo: Byte);
begin
  ISRRoutines[ISRNo]:=nil;
end;

procedure Install;
begin
  WriteString('Installing ISR...'#9#9);
  IDT.SetGate(0,PtrUInt(@ISR0),$08,$8E);
  IDT.SetGate(1,PtrUInt(@ISR1),$08,$8E);
  IDT.SetGate(2,PtrUInt(@ISR2),$08,$8E);
  IDT.SetGate(3,PtrUInt(@ISR3),$08,$8E);
  IDT.SetGate(4,PtrUInt(@ISR4),$08,$8E);
  IDT.SetGate(5,PtrUInt(@ISR5),$08,$8E);
  IDT.SetGate(6,PtrUInt(@ISR6),$08,$8E);
  IDT.SetGate(7,PtrUInt(@ISR7),$08,$8E);
  IDT.SetGate(8,PtrUInt(@ISR8),$08,$8E);
  IDT.SetGate(9,PtrUInt(@ISR9),$08,$8E);
  IDT.SetGate(10,PtrUInt(@ISR10),$08,$8E);
  IDT.SetGate(11,PtrUInt(@ISR11),$08,$8E);
  IDT.SetGate(12,PtrUInt(@ISR12),$08,$8E);
  IDT.SetGate(13,PtrUInt(@ISR13),$08,$8E);
  IDT.SetGate(14,PtrUInt(@ISR14),$08,$8E);
  IDT.SetGate(15,PtrUInt(@ISR15),$08,$8E);
  IDT.SetGate(16,PtrUInt(@ISR16),$08,$8E);
  IDT.SetGate(17,PtrUInt(@ISR17),$08,$8E);
  IDT.SetGate(18,PtrUInt(@ISR18),$08,$8E);
  IDT.SetGate(19,PtrUInt(@ISR19),$08,$8E);
  IDT.SetGate(20,PtrUInt(@ISR20),$08,$8E);
  IDT.SetGate(21,PtrUInt(@ISR21),$08,$8E);
  IDT.SetGate(22,PtrUInt(@ISR22),$08,$8E);
  IDT.SetGate(23,PtrUInt(@ISR23),$08,$8E);
  IDT.SetGate(24,PtrUInt(@ISR24),$08,$8E);
  IDT.SetGate(25,PtrUInt(@ISR25),$08,$8E);
  IDT.SetGate(26,PtrUInt(@ISR26),$08,$8E);
  IDT.SetGate(27,PtrUInt(@ISR27),$08,$8E);
  IDT.SetGate(28,PtrUInt(@ISR28),$08,$8E);
  IDT.SetGate(29,PtrUInt(@ISR29),$08,$8E);
  IDT.SetGate(30,PtrUInt(@ISR30),$08,$8E);
  IDT.SetGate(31,PtrUInt(@ISR31),$08,$8E);
  WriteStrLn('[ OK ]');
end;

procedure InterruptHandler(const r: TRegisters);
begin
  with r do begin
    WriteString('Error code'#9'= ');WriteLongLn(ErrorCode);
    WriteString('EAX'#9#9'= $');WriteStrLn(HexStr(eax,8));
    WriteString('EBX'#9#9'= $');WriteStrLn(HexStr(ebx,8));
    WriteString('ECX'#9#9'= $');WriteStrLn(HexStr(ecx,8));
    WriteString('EDX'#9#9'= $');WriteStrLn(HexStr(edx,8));
    WriteString('ESI'#9#9'= $');WriteStrLn(HexStr(esi,8));
    WriteString('EDI'#9#9'= $');WriteStrLn(HexStr(edi,8));
    WriteString('ESP'#9#9'= $');WriteStrLn(HexStr(esp,8));
    WriteString('EBP'#9#9'= $');WriteStrLn(HexStr(ebp,8));
    WriteString('CS'#9#9'= $');WriteStrLn(HexStr(cs,8));
    WriteString('DS'#9#9'= $');WriteStrLn(HexStr(ds,8));
    WriteString('ES'#9#9'= $');WriteStrLn(HexStr(es,8));
    WriteString('FS'#9#9'= $');WriteStrLn(HexStr(fs,8));
    WriteString('GS'#9#9'= $');WriteStrLn(HexStr(gs,8));
    WriteString('SS'#9#9'= $');WriteStrLn(HexStr(ss,8));
    WriteString('EIP'#9#9'= $');WriteStrLn(HexStr(eip,8));
    WriteString('EFLAGS'#9#9'= $');WriteStrLn(HexStr(eflags,8));
    WriteString('User ESP'#9'= $');WriteString(HexStr(UserESP,8));
  end;
  SetTextColor(scBlack,scLightGrey);
  WriteChar(#10);
  Sound(1000);
end;

procedure FaultHandler(var r: TRegisters); cdecl; [public, alias: 'ISRHandler'];
var
  Handler: TISRHandler;
begin
  if r.InterruptNumber<32 then begin
    SetTextColor(scBlack,scRed);
    WriteChar(#10);
    WriteLn(ExceptionMessages[r.InterruptNumber]+' Exception');
    InterruptHandler(r);
    Dump_Stack(Output,get_frame);
    // raise Exception.Create(ExceptionMessages[r.InterruptNumber]+' Exception') at get_caller_addr(get_frame);
    Handler:=ISRRoutines[r.InterruptNumber];
    if Assigned(Handler) then
      Handler(r)
    else
      while true do ;
  end;
end;

end.
