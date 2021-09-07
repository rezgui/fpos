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

unit Heap;

interface

const
  HeapStart = $D0000000;
  HeapEnd = $FFBFF000;

type
  UBit31 = 0..(1 shl 31) - 1;

  PHeader = ^THeader;

  THeader = bitpacked record
    Prev, Next: PHeader;
    Allocated: Boolean;
    Length: UBit31;
  end;

procedure Install;
function MemAlloc(l: LongWord): Pointer;
procedure MemFree(p: Pointer);

implementation

uses
  console, pmm, vmm;

var
  HeapMax: LongWord = HeapStart;
  HeapFirst: PHeader = nil;

procedure AllocChunk(Start, Len: LongWord);
var
  Page: LongWord;
begin
  while Start + Len > HeapMax do begin
    Page := PtrUInt(AllocPage);
    Map(HeapMax, page, True, True, False);
    Inc(HeapMax, PageSize);
  end;
end;

procedure FreeChunk(Chunk: PHeader);
var
  Page: LongWord;
begin
  Chunk^.Prev^.Next := nil;
  if not Assigned(Chunk^.Prev) then
    HeapFirst := nil;
  // While the heap max can contract by a page and still be greater than the Chunk address...
  while HeapMax - PageSize >= PtrUInt(Chunk) do begin
    Dec(HeapMax, PageSize);
    GetMapping(HeapMax, @page);
    FreePage(Page);
    UnMap(HeapMax);
  end;
end;

procedure SplitChunk(Chunk: PHeader; Len: LongWord);
var
  NewChunk: PHeader;
begin
  // In order to split a Chunk, once we split we need to know that there will be enough
  // space in the new Chunk to store the Chunk header, otherwise it just isn't worthwhile.
  if Chunk^.Length - Len > SizeOf(THeader) then begin
    NewChunk := PHeader(PtrUInt(Chunk) + Chunk^.Length);
    with NewChunk^ do begin
      Prev := Chunk;
      Next := nil;
      Allocated := False;
      Length := Chunk^.Length - Len;
    end;
    Chunk^.Next := NewChunk;
    Chunk^.Length := Len;
  end;
end;

procedure GlueChunk(Chunk: PHeader);
begin
  with Chunk^ do begin
    if Assigned(Next) and not Next^.Allocated then begin
      Length := Length + Next^.Length;
      Next^.Next^.Prev := Chunk;
      Next := Next^.Next;
    end;
    if Assigned(Prev) and not Prev^.Allocated then begin
      Prev^.Length := Prev^.Length + Length;
      Prev^.Next := Next;
      Next^.Prev := Prev;
      Chunk := Prev;
    end;
    if not Assigned(Next) then
      FreeChunk(Chunk);
  end;
end;

procedure Install;
begin
  WriteString('Installing Heap...'#9#9);
  // There's actually nothing to be done
  WriteStrLn('[ OK ]');
end;

function MemAlloc(l: LongWord): Pointer; [public, alias: 'MemAlloc'];
var
  CurHeader, PrevHeader: PHeader;
  ChunkStart: LongWord;
begin
  Inc(l, SizeOf(THeader));
  CurHeader := HeapFirst;
  PrevHeader := nil;
  while Assigned(CurHeader) do begin
    if not CurHeader^.Allocated and (CurHeader^.Length >= l) then begin
      SplitChunk(CurHeader, l);
      CurHeader^.Allocated := True;
      MemAlloc := Pointer(PtrUInt(CurHeader) + SizeOf(THeader));
      Exit;
    end;
    PrevHeader := CurHeader;
    CurHeader := CurHeader^.Next;
  end;

  if PrevHeader <> nil then
    ChunkStart := PtrUInt(PrevHeader) + PrevHeader^.Length
  else begin
    ChunkStart := HeapStart;
    HeapFirst := PHeader(ChunkStart);
  end;

  AllocChunk(ChunkStart, l);
  CurHeader := PHeader(ChunkStart);
  with CurHeader^ do begin
    Prev := PrevHeader;
    Next := nil;
    Allocated := True;
    Length := l;
  end;

  PrevHeader^.Next := CurHeader;
  MemAlloc := Pointer(ChunkStart + SizeOf(THeader));
end;

procedure MemFree(p: Pointer); [public, alias: 'MemFree'];
var
  Header: PHeader;
begin
  Header := PHeader(PtrUInt(p) - SizeOf(THeader));
  Header^.Allocated := False;
  GlueChunk(Header);
end;

end.

