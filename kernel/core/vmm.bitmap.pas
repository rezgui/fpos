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
  PageSize = 4096;
  PageTableSize = 1024*4096;
  PageDirSize = 1024*PageTableSize;

type
  UBit3 = 0..(1 shl 3)-1;
  UBit20 = 0..(1 shl 20)-1;

  PPageTableEntry = ^TPageTableEntry;
  TPageTableEntry = bitpacked record
    Present,Writable,UserMode,WriteThrough,
    NotCacheable,Accessed,Dirty,AttrIndex,
    GlobalPage: Boolean;
    Avail: UBit3;
    FrameAddr: UBit20;
  end;

  PPageDirEntry = ^TPageDirEntry;
  TPageDirEntry = bitpacked record
    Present,Writable,UserMode,WriteThrough,
    NotCacheable,Accessed,Reserved,PageSize,
    GlobalPage: Boolean;
    Avail: UBit3;
    TableAddr: UBit20;
  end;

  PPageTable = ^TPageTable;
  TPageTable = array [0..1023] of TPageTableEntry;
  PPageDir = ^TPageDir;
  TPageDir = array [0..1023] of TPageDirEntry;

function AllocPage(e: PPageTableEntry): Boolean;
procedure FreePage(e: PPageTableEntry);
function GetCurrentDir: PPageDir; inline;
function LookUpPTEntry(p: PPageTable; Addr: LongWord): PPageTableEntry; inline;
function LookUpPDEntry(p: PPageDir; Addr: LongWord): PPageDirEntry; inline;
procedure InstallVMM;

implementation

uses
  pmm,console;

var
  CurrentDir,KernelPageDir: PPageDir;

function AllocPage(e: PPageTableEntry): Boolean;
var
  p: PLongWord;
begin
  p:=AllocBlock;
  if p<>nil then begin
    e^.FrameAddr:=PtrUInt(p) shl 12;
    e^.Present:=true;
    AllocPage:=true;
  end else
    AllocPage:=false;
end;

procedure FreePage(e: PPageTableEntry);
begin
  if e^.FrameAddr<>0 then FreeBlock(PLongWord(e^.FrameAddr));
  e^.Present:=false;
end;

procedure ClearPageTable(p: PPageTable); inline;
begin
  FillByte(p^,SizeOf(TPageTable),0);
end;

procedure ClearPageDir(p: PPageDir); inline;
begin
  FillByte(p^,SizeOf(TPageDir),0);
end;

function VirtToPTIndex(Addr: LongWord): LongWord; inline;
begin
  if Addr<PageTableSize then
    VirtToPTIndex:=Addr div PageSize
  else
    VirtToPTIndex:=0;
end;

function VirtToPDIndex(Addr: LongWord): LongWord; inline;
begin
  if Addr<PageDirSize then
    VirtToPDIndex:=Addr div PageSize
  else
    VirtToPDIndex:=0;
end;

function LookUpPTEntry(p: PPageTable; Addr: LongWord): PPageTableEntry; inline;
begin
  LookUpPTEntry:=PPageTableEntry(p[VirtToPTIndex(Addr)]);
end;

function LookUpPDEntry(p: PPageDir; Addr: LongWord): PPageDirEntry; inline;
begin
  LookUpPDEntry:=PPageDirEntry(p[VirtToPDIndex(Addr)]);
end;

procedure SwitchPageDir(p: PPageDir);
begin
  CurrentDir:=p;
  asm
    mov eax,CurrentDir
    mov cr3,eax
  end ['eax'];
end;

function GetCurrentDir: PPageDir; inline;
begin
  GetCurrentDir:=CurrentDir;
end;

procedure FlushTLBEntry(Addr: LongWord); pascal; assembler;
asm
  cli
  invlpg Addr
  sti
end;

procedure InstallVMM;
var
  DefPageTable: PPageTable;
  i,Frame: LongWord;
  Page: TPageTableEntry;
  PageDirEntry: PPageDirEntry;
begin
  WriteString('Installing VMM...'#9#9);
  DefPageTable:=PPageTable(AllocBlock);
  if DefPageTable=nil then Exit;
  ClearPageTable(DefPageTable);
  Frame:=0;
  for i:=0 to 1023 do begin
		FillByte(Page,SizeOf(TPageTableEntry),0);
    with Page do begin
      Present:=true;
      FrameAddr:=Frame shr 12;
		end;
    DefPageTable^[VirtToPTIndex(Frame)]:=Page;
    Inc(Frame,PageSize);
	end;
  KernelPageDir:=PPageDir(AllocBlock);
  if KernelPageDir=nil then Exit;
  ClearPageDir(KernelPageDir);
  with LookUpPDEntry(KernelPageDir,0)^ do begin
    Present:=true;
    Writable:=true;
    TableAddr:=PtrUInt(DefPageTable) shr 12;
  end;
  SwitchPageDir(KernelPageDir);
  asm
    mov eax,cr0
    or  eax,$80000000 // Enable paging bit
    mov cr0,eax
  end ['eax'];
  WriteStrLn('[ OK ]');
end;

end.
