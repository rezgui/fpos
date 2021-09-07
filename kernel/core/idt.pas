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

unit idt;

interface

type

  TIDTEntry = packed record
    LowBase: Word;
    Selector: Word;
    Always0: Byte;
    Flags: Byte;
    HiBase: Word;
  end;

  TIDTPtr = packed record
    Limit: Word;
    Base: LongWord;
  end;

var
  IDTList: array [0..255] of TIDTEntry;
  IDTPtr: TIDTPtr;

procedure SetGate(Num: Byte; Base: LongWord; Sel: Word; Flg: Byte);
procedure Install;

implementation

uses
  console;

procedure LoadIDT; assembler; nostackframe;
asm
  lidt [IDTPtr]
end;

procedure SetGate(Num: Byte; Base: LongWord; Sel: Word; Flg: Byte);
begin
  with IDTList[Num] do begin
    LowBase := Base and $FFFF;
    HiBase := (Base shr 16) and $FFFF;
    Selector := Sel;
    Always0 := 0;
    Flags := Flg;
  end;
end;

procedure Install;
begin
  WriteString('Installing IDT...'#9#9);
  with IDTPtr do begin
    Limit := SizeOf(IDTList) - 1;
    Base := PtrUInt(@IDTList);
  end;
  FillByte(IDTList, SizeOf(IDTList), 0);
  LoadIDT;
  WriteStrLn('[ OK ]');
end;

end.

