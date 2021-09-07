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

unit speaker;

interface

procedure Sound(Hz: LongWord);
procedure NoSound;

implementation

uses
  x86;

procedure Sound(Hz: LongWord); [public, alias: 'Sound'];
var
  Divisor: LongWord;
  Temp: Byte;
begin
  Divisor := 1193180 div Hz;
  WritePortB($43, $B6);
  WritePortB($42, Divisor);
  WritePortB($42, Divisor shr 8);
  Temp := ReadPortB($61);
  if Temp <> (Temp or 3) then
    WritePortB($61, Temp or 3);
end;

procedure NoSound;
var
  Temp: Byte;
begin
  Temp := ReadPortB($61) and $FC;
  WritePortB($61, Temp);
end;

end.

