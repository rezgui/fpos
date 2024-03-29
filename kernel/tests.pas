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

unit tests;

interface

procedure LinkedListTest;
procedure WriteLnTest;

implementation

type
  PT = ^TT;

  TT = record
    Value: LongWord;
    Next: PT;
  end;

procedure LinkedListTest;
var
  P, T: PT;
  i: LongWord;
begin
  WriteLn('Testing for linked lists...');
  New(P);
  T := P;
  T^.Value := 0;
  for i := 1 to 5 do begin
    New(T^.Next);
    T := T^.Next;
    with T^ do begin
      Value := i;
      Next := nil;
    end;
  end;
  T := P;
  while Assigned(T) do begin
    WriteLn('$' + HexStr(PtrUInt(T), 8) + ' = ',T^.Value);
    P := T;
    T := T^.Next;
    Dispose(P);
  end;
end;

procedure WriteLnTest;
type
  TEnum = (a, b, c);
var
  e: TEnum;
begin
  WriteLn('Testing for WriteLn of many types...');
  e := c;
  WriteLn('Test string ', 255, ' ', 12.34, ' ', 1.5e+10: 2: 4, ' ', e);
end;

end.
