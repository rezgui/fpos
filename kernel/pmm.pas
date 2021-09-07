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

procedure Install(const Start: LongWord);
procedure FindUsableRAM(const MB: PMultiBootInfo);
function AllocPage: LongWord;
procedure FreePage(const p: LongWord);

implementation

uses
  console, vmm;

var
  PMMStackLocation: LongWord = PMMStackAddr;
  PMMStackMax: LongWord = PMMStackAddr;
  PMMLocation: LongWord;

procedure Install(const Start: LongWord);
begin
  WriteString('Installing PMM...'#9#9);
  PMMLocation := Align(Start + PageSize, PageSize);
  WriteStrLn('[ OK ]');
end;

procedure FindUsableRAM(const MB: PMultiBootInfo);
var
  i, j: LongWord;
  ME: PMemoryMap;
begin
  // Find all usable areas of memory
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

function AllocPage: LongWord;
var
  Stack: PLongWord;
begin
  if IsPagingActive then begin
    // Quick sanity check
    if PMMStackLocation = PMMStackAddr then begin
      SetTextColor(scBlack, scRed);
      WriteString('Error: Out of Memory');
      SetTextColor(scBlack, scLightGrey);
      WriteChar(#10);
      asm
        cli
        hlt
      end;
    end;
    // Pop off the stack
    Dec(PMMStackLocation, SizeOf(LongWord));
    Stack := PLongWord(PMMStackLocation);
    AllocPage := Stack^;
  end else begin
    Inc(PMMLocation, PageSize);
    AllocPage := PMMLocation;
  end;
end;

procedure FreePage(const p: LongWord);
var
  Stack: PLongWord;
begin
  // Ignore any page under "location", as it may contain important data initialised
  // at boot (like paging structures!)
  if p < PMMLocation then
    Exit;
  // If we've run out of space on the stack...
  if PMMStackMax <= PMMStackLocation then begin
    // Map the page we're currently freeing at the top of the free page stack
    Map(PMMStackMax, p, True, True, False);
    // Increase the free page stack's size by one page
    Inc(PMMStackMax, PageSize);
  end else begin
    // Else we have space on the stack, so push
    Stack := PLongWord(PMMStackLocation);
    Stack^ := p;
    Inc(PMMStackLocation, SizeOf(LongWord));
  end;
end;

end.

