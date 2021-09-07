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

unit pmm;

interface

uses
  multiboot;

const
  PMMStackAddr = $FF000000;
  PageSize = $1000;

var
  IsPagingActive: Boolean;

procedure InstallPMM(const Start: LongWord);
procedure FindUsableRAM(const MB: PMultiBootInfo);
function AllocPage: LongWord;
procedure FreePage(const p: LongWord);

implementation

uses
  console;

var
  MemorySize, MaxBlocks, UsedBlocks, LastFree: LongWord;
  MemoryMap: PLongWord;

procedure InstallPMM(const Start: LongWord);
begin
  WriteString('Installing PMM...'#9#9);
  MemoryMap := PLongWord(Align(Start + PageSize, PageSize));
  WriteStrLn('[ OK ]');
end;

procedure FindUsableRAM(const MB: PMultiBootInfo);
var
  i, j: LongWord;
  ME: PMemoryMap;
begin
  // Find all the usable areas of memory
  i := MB^.MemoryMapAddress;
  while i < MB^.MemoryMapAddress + MB^.MemoryMapLength do begin
    ME := PMemoryMap(i);
    // Does this entry specify usable RAM?
    if ME^.MType = 1 then begin
      // For every page in this entry, add to the free page stack
      j := ME^.BaseLowAddress;
      while (j < ME^.BaseLowAddress + ME^.LowLength) do begin
        FreePage(j);
        Inc(j, PageSize);
      end;
    end;
    { The multiboot specification is strange in this respect
      the size member does not include "size" itself in its calculations,
      so we must add sizeof (uint32_t) }
    Inc(i, ME^.Size + SizeOf(LongWord));
  end;
end;

procedure SetBit(const Bit: LongWord); inline;
begin
  MemoryMap[Bit div 32] := MemoryMap[Bit div 32] or (1 shl (Bit mod 32));
end;

procedure UnsetBit(const Bit: LongWord); inline;
begin
  MemoryMap[Bit div 32] := MemoryMap[Bit div 32] and not (1 shl (Bit mod 32));
end;

function IsBitSet(const Bit: LongWord): Boolean; inline;
begin
  IsBitSet := MemoryMap[Bit div 32] and (1 shl (Bit mod 32)) = 1;
end;

function FindFirstFree: LongWord;
var
  i, j, Bit: LongWord;
begin
  for i := LastFree to MaxBlocks do
    if MemoryMap[i] <> $FFFFFFFF then
      for j := 0 to 31 do begin
        Bit := 1 shl j;
        if MemoryMap[i] and Bit = 0 then begin
          FindFirstFree := i * 32 + j;
          LastFree := i;
          Exit;
        end;
      end;
  for i := 0 to LastFree - 1 do
    if MemoryMap[i] <> $FFFFFFFF then
      for j := 0 to 31 do begin
        Bit := 1 shl j;
        if MemoryMap[i] and Bit = 0 then begin
          FindFirstFree := i * 32 + j;
          LastFree := i;
          Exit;
        end;
      end;
  FindFirstFree := $FFFFFFFF;
end;

function GetAvailableBlocks: LongWord; inline;
begin
  GetAvailableBlocks := MaxBlocks - UsedBlocks;
end;

function AllocPage: LongWord;
var
  Frame: LongWord;
begin
  if GetAvailableBlocks <> 0 then begin
    Frame := FindFirstFree;
    if Frame <> $FFFFFFFF then begin
      SetBit(Frame);
      AllocPage := Frame * PageSize;
      Inc(UsedBlocks);
      Exit;
    end;
  end;
  AllocPage := 0;
end;

procedure FreePage(const p: LongWord);
begin
  UnSetBit(p div PageSize);
  Dec(UsedBlocks);
end;

end.

