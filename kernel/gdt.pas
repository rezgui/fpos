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

unit gdt;

interface

type

  TGDTEntry = packed record
    LowLimit: Word;
    LowBase: Word;
    MiddleBase: Byte;
    Access: Byte;
    Granularity: Byte;
    HighBase: Byte;
  end;

  TGDTPtr = packed record
    Limit: Word;
    Base: LongWord;
  end;

var
  GDTList: array [0..4] of TGDTEntry;
  GDTPtr: TGDTPtr; export name 'GDTPtr';

procedure SetGate(Num: Byte; Base, Limit: LongWord; Acc, Gran: Byte);
procedure Install;

implementation

uses
  console;

procedure FlushGDT; external name 'FlushGDT';

procedure SetGate(Num: Byte; Base, Limit: LongWord; Acc, Gran: Byte);
begin
  with GDTList[Num] do begin
    LowBase := (Base and $FFFF);
    MiddleBase := (Base shr 16) and $FF;
    HighBase := (Base shr 24) and $FF;
    LowLimit := (Limit and $FFFF);
    Granularity := ((Limit shr 16) and $0F) or (Gran and $F0);
    Access := Acc;
  end;
end;

procedure Install;
begin
  WriteString('Installing GDT...'#9#9);
  with GDTPtr do begin
    Limit := SizeOf(GDTList) - 1;
    Base := PtrUInt(@GDTList);
  end;
  GDT.SetGate(0, 0, 0, 0, 0); // nil descriptor
  GDT.SetGate(1, 0, $FFFFFFFF, $9A, $CF); // Kernel space code
  GDT.SetGate(2, 0, $FFFFFFFF, $92, $CF); // Kernel space data
  GDT.SetGate(3, 0, $FFFFFFFF, $FA, $CF); // User space code
  GDT.SetGate(4, 0, $FFFFFFFF, $F2, $CF); // User space data
  FlushGDT;
  WriteStrLn('[ OK ]');
end;

end.

