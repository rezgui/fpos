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

unit console;

interface

type
  TScreenColor = (
    scBlack, scBlue, scGreen, scCyan,
    scRed, scMagenta, scBrown, scLightGrey,
    scDarkGrey, scLightBlue, scLightGreen, scLightCyan,
    scLightRed, scLightMagenta, scLightBrown, scWhite
    );

function WhereX: Word;
function WhereY: Word;
procedure GoToXY(const X, Y: Word);
procedure ClearScreen;
procedure WriteChar(const c: Char);
procedure WritePChar(P: PChar);
procedure WriteString(const S: String);
procedure WriteInt(i: Integer);
procedure WriteLong(l: LongWord);
procedure WritePCharLn(P: PChar);
procedure WriteStrLn(const S: String);
procedure WriteIntLn(i: Integer);
procedure WriteLongLn(l: LongWord);
procedure SetTextColor(const BackColor, ForeColor: TScreenColor);
procedure Install;

implementation

uses
  x86, keybrd;

var
  // Video memory array
  VidMem: PChar = PChar($B8000);
  CursorPosX: Word = 0;
  CursorPosY: Word = 0;
  // Color attribute
  Attrib: Word = $0F;
  // Blank (space) character for current color
  Blank: Word;

function WhereX: Word;
begin
  WhereX := CursorPosX;
end;

function WhereY: Word;
begin
  WhereY := CursorPosY;
end;

procedure GoToXY(const X, Y: Word);
begin
  if X < 80 then
    CursorPosX := X;
  if Y < 24 then
    CursorPosY := Y;
end;

// Moves screen down one line when cursor is on line 24 (it can't be more, though)
procedure Scroll;
begin
  if CursorPosY >= 24 then begin
    { // line index starts from 0
      for n:=0 to 23 do
        line[n]:=line[n+1] }
    Move((VidMem + 2 * 80)^, VidMem^, 23 * 2 * 80);
    // Empty last line
    FillWord((VidMem + 23 * 2 * 80)^, 80, Blank);
    CursorPosX := 0;
    CursorPosY := 23;
  end;
end;

procedure BlinkCursor;
var
  Temp: LongWord;
begin
  // X,Y mapped to VidMem ( 1-dim array )
  Temp := CursorPosY * 80 + CursorPosX;
  WritePortB($3D4, 14);
  WritePortB($3D5, Temp shr 8);
  WritePortB($3D4, 15);
  WritePortB($3D5, Temp);
end;

procedure ClearScreen;
var
  i: Byte;
begin
  Blank := $0 or (Attrib shl 8);
  for i := 0 to 23 do
    FillWord((VidMem + i * 2 * 80)^, 80, Blank);
  CursorPosX := 0;
  CursorPosY := 0;
  BlinkCursor;
end;

procedure WriteChar(const c: Char);
var
  Offset: Word;

  procedure Print(const c: Char);
  begin
    // First byte = character to print
    Offset := (CursorPosX shl 1) + (CursorPosY * 160);
    VidMem[Offset] := c;
    // Second byte = color attributes
    Inc(Offset);
    VidMem[Offset] := Char(Attrib);
  end;

begin
  // Blank character based on current color attributes
  Blank := $20 or (Attrib shl 8);
  case c of
    // Backspaces
    #08: if Length(CommandBuffer) > 0 then begin
        if CursorPosX > 0 then begin
          if CommandBuffer[Length(CommandBuffer)] = #9 then
            CursorPosX := (CursorPosX - 8) and not 7
          else
            Dec(CursorPosX);
          if CursorPosX < 5 then
            CursorPosX := 5;
        end else
          GoToXY(79, CursorPosY - 1);
        Print(#0);
      end;
    // Tabs, only to a position which is divisible by 8
    #09: CursorPosX := (CursorPosX + 8) and not 7;
    { Newlines, DOS and BIOS way ( consider as if a carriage
      return is also there ) }
    #10: begin
      CursorPosX := 0;
      Inc(CursorPosY);
    end;
    // Carriage return
    #13: CursorPosX := 0;
    // Printable characters, starting from space
    #32..#255: begin
      Print(c);
      Inc(CursorPosX);
    end;
  end;
  // Whoops! Line limit, move on to the next line
  if CursorPosX >= 80 then begin
    CursorPosX := 0;
    Inc(CursorPosY);
  end;
  Scroll;
  BlinkCursor;
end;

procedure WritePChar(P: PChar); [public, alias: 'WritePChar'];
begin
  while P^ <> #0 do begin
    WriteChar(P^);
    Inc(P);
  end;
end;

procedure WriteString(const S: String);
var
  i: Byte;
begin
  for i := 1 to Length(S) do
    WriteChar(S[i]);
end;

procedure WriteInt(i: Integer);
var
  s: String;
begin
  Str(i, s);
  WriteString(s);
end;

{ // Previous implementation without rtl integration
procedure WriteInt(i: Integer);
var
  Buffer: array [0..6] of Char;
  P: PChar;
  Negative: Boolean;
begin
  P:=@Buffer[6];
  P^:=#0;
  Negative:=false;
  if i<0 then begin
    Negative:=true;
    i:=-i;
  end;
  repeat
    Dec(P);
    P^:=Char((i mod 10)+48);
    i:=i div 10;
  until i=0;
  if Negative then begin
    Dec(P);
    P^:='-';
  end;
  WritePChar(P);
end;
}
procedure WriteLong(l: LongWord);
var
  s: String;
begin
  Str(l, s);
  WriteString(s);
end;

{ // Previous implementation without rtl integration
procedure WriteLong(l: LongWord);
var
  Buffer: array [0..9] of Char;
  P: PChar;
begin
  P:=@Buffer[9];
  P^:=#0;
  repeat
    Dec(P);
    P^:=Char((l mod 10)+48);
    l:=l div 10;
  until l=0;
  WritePChar(P);
end;
}
procedure WritePCharLn(P: PChar);
begin
  WritePChar(P);
  WriteChar(#10);
end;

procedure WriteStrLn(const S: String);
begin
  WriteString(S);
  WriteChar(#10);
end;

procedure WriteIntLn(i: Integer);
begin
  WriteInt(i);
  WriteChar(#10);
end;

procedure WriteLongLn(l: LongWord);
begin
  WriteLong(l);
  WriteChar(#10);
end;

procedure SetTextColor(const BackColor, ForeColor: TScreenColor); [public, alias: 'SetTextColor'];
begin
  Attrib := (Ord(BackColor) shl 4) or (Ord(ForeColor) and $0F);
end;

procedure Install;
const
  FPC_OS_LOGO = 'FreePascal OS 0.01  ';
var
  i: Byte;
begin
  SetTextColor(scBlack, scLightGrey);
  ClearScreen;
  SetTextColor(scBlack, scLightGreen);
  for i := 1 to Length(FPC_OS_LOGO) do begin
    VidMem[2 * (i - 1) + 3960] := FPC_OS_LOGO[i];
    VidMem[2 * (i - 1) + 3961] := Char(10 and $0F);
  end;
  SetTextColor(scBlack, scLightGrey);
  WriteString('Booting ');
  SetTextColor(scBlack, scLightGreen);
  WriteString('FreePascal OS 0.01');
  SetTextColor(scBlack, scLightGrey);
  WriteStrLn('...');
end;

end.

