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

unit vmm;

interface

const
  PageDirVirtAddr = $FFBFF000;
  PageTableVirtAddr = $FFC00000;

type
  UBit3 = 0..(1 shl 3) - 1;
  UBit20 = 0..(1 shl 20) - 1;

  PPageTableEntry = ^TPageTableEntry;

  TPageTableEntry = bitpacked record
    Present, Writable, UserMode, WriteThrough,
    NotCacheable, Accessed, Dirty, AttrIndex,
    GlobalPage: Boolean;
    Avail: UBit3;
    FrameAddr: UBit20;
  end;

  PPageDirEntry = ^TPageDirEntry;

  TPageDirEntry = bitpacked record
    Present, Writable, UserMode, WriteThrough,
    NotCacheable, Accessed, Reserved, PageSize,
    GlobalPage: Boolean;
    Avail: UBit3;
    TableAddr: UBit20;
  end;

  PPageTable = ^TPageTable;
  TPageTable = array [0..1023] of TPageTableEntry;
  PPageDir = ^TPageDir;
  TPageDir = array [0..1023] of TPageDirEntry;

procedure Install;
procedure SwitchPageDir(const pd: PPageDir);
procedure Map(const va, pa: LongWord;
  const IsPresent, IsWritable, IsUserMode: Boolean);
procedure UnMap(const va: LongWord);
function GetMapping(const va: LongWord; pa: PLongWord): Boolean;

implementation

uses
  console, isr, pmm;

var
  PageDir: PPageDir = PPageDir(PageDirVirtAddr);
  PageTables: PPageTable = PPageTable(PageTableVirtAddr);
  CurrentPageDir: PPageDir;

function PageDirIndex(const x: LongWord): LongWord;
begin
  PageDirIndex := x div 1024;
end;

function PageTableIndex(const x: LongWord): LongWord;
begin
  PageTableIndex := x mod 1024;
end;

procedure PageFaultHandler(var r: TRegisters);
var
  FaultAddr: LongWord;
  Present, ReadOnly, UserMode, Reserved, InstrFetch: Boolean;
begin
  asm
    mov eax,cr2
    mov FaultAddr,eax
  end ['eax'];
  Present := r.ErrorCode and 1 <> 0;
  ReadOnly := r.ErrorCode and 2 = 0;
  UserMode := r.ErrorCode and 4 = 0;
  Reserved := r.ErrorCode and 8 = 0;
  InstrFetch := r.ErrorCode and 16 = 0;
  WriteStrLn('Page Fault at $' + HexStr(r.EIP, 8) + ', Faulting address = $' +
    HexStr(FaultAddr, 8));
  WriteString('Page is ');
  if Present then
    WriteString('present ');
  if ReadOnly then
    WriteString('read-only ');
  if UserMode then
    WriteString('user-mode ');
  if Reserved then
    WriteString('reserved ');
  WriteChar(#10);
  while True do ;
end;

procedure Install;
var
  i, ptIndex: LongWord;
  pd: PPageDir;
  pt: PPageTable;
begin
  WriteString('Installing VMM...'#9#9);
  // Register the page fault handler
  ISR.InstallHandler(14, @PageFaultHandler);
  // Create a page directory
  pd := PPageDir(AllocPage);
  // Initialise it
  FillByte(pd^, PageSize, 0);
  // Identity map the first 4 MB
  with pd^[0] do begin
    TableAddr := AllocPage shr 12;
    Present := True;
    Writable := True;
  end;
  pt := PPageTable(pd^[0].TableAddr shl 12);
  for i := 0 to 1023 do begin
    FillByte(pt^[i], SizeOf(TPageTableEntry), 0);
    with pt^[i] do begin
      FrameAddr := (i * PageSize) shr 12;
      Present := True;
      Writable := True;
    end;
  end;
  // Assign the second-last table and zero it
  with pd^[1022] do begin
    TableAddr := AllocPage shr 12;
    Present := True;
    Writable := True;
  end;
  pt := PPageTable(pd^[1022].TableAddr shl 12);
  FillByte(pt^, PageSize, 0);
  // The last entry of the second-last table is the directory itself
  with pt^[1023] do begin
    FrameAddr := PtrUInt(pd) shr 12;
    Present := True;
    Writable := True;
  end;
  // The last table loops back on the directory itself
  with pd^[1023] do begin
    TableAddr := PtrUInt(pd) shr 12;
    Present := True;
    Writable := True;
  end;
  // Set the current directory
  SwitchPageDir(pd);
  // Enable paging
  asm
    mov eax,cr0
    or  eax,$80000000
    mov cr0,eax
  end ['eax'];
  // We need to map the page table where the physical memory manager keeps its page stack
  // else it will panic on the first "pmm_free_page"
  ptIndex := PageDirIndex(PMMStackAddr shr 12);
  FillByte(PageDir^[ptIndex], SizeOf(TPageDirEntry), 0);
  with PageDir^[ptIndex] do begin
    TableAddr := AllocPage shr 12;
    Present := True;
    Writable := True;
  end;
  FillByte(PageTables^[ptIndex * 1024], PageSize, 0);
  // Paging is now active. Tell the physical memory manager
  IsPagingActive := True;
  WriteStrLn('[ OK ]');
end;

procedure SwitchPageDir(const pd: PPageDir);
begin
  CurrentPageDir := pd;
  asm
    mov eax,pd
    mov cr3,eax
  end ['eax'];
end;

procedure Map(const va, pa: LongWord;
  const IsPresent, IsWritable, IsUserMode: Boolean);
var
  VirtPage, ptIndex: LongWord;
begin
  {$ifdef debug}
  WriteStrLn('Map $' + HexStr(va, 8) + ' to $' + HexStr(pa, 8));
  {$endif}
  VirtPage := va div PageSize;
  ptIndex := PageDirIndex(VirtPage);
  // Find the appropriate page table for 'va'
  if PageDir^[ptIndex].TableAddr shl 12 = 0 then begin
    // The page table holding this page has not been created yet
    with PageDir^[ptIndex] do begin
      TableAddr := AllocPage shr 12;
      Present := True;
      Writable := True;
    end;
    FillByte(PageTables^[ptIndex * 1024], PageSize, 0);
  end;
  // Now that the page table definately exists, we can update the PTE
  with PageTables^[VirtPage] do begin
    FrameAddr := Align(pa, PageSize) shr 12;
    Present := IsPresent;
    Writable := IsWritable;
    UserMode := IsUserMode;
  end;
end;

procedure UnMap(const va: LongWord);
var
  VirtPage: LongWord;
begin
  VirtPage := va div PageSize;
  FillByte(PageTables[VirtPage], SizeOf(TPageTableEntry), 0);
  // Inform the CPU that we have invalidated a page mapping
  asm
    invlpg va
  end;
end;

function GetMapping(const va: LongWord; pa: PLongWord): Boolean;
var
  VirtPage, ptIndex: LongWord;
begin
  VirtPage := va div PageSize;
  ptIndex := PageDirIndex(VirtPage);
  // Find the appropriate page table for 'va'
  if PageDir^[ptIndex].TableAddr shl 12 = 0 then
    GetMapping := False
  else if PageTables^[VirtPage].FrameAddr <> 0 then begin
    if Assigned(pa) then
      pa := Align(Pointer(PageTables^[VirtPage]), PageSize);
    GetMapping := True;
  end;
end;

end.

