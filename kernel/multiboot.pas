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

unit multiboot;

interface

const
  KernelStackSize = $4000;
  MultiBootBootloaderMagic = $2BADB002;

type
  PELFHeaderSection = ^TELFHeaderSection;

  TELFHeaderSection = packed record
    Num: LongWord;
    Size: LongWord;
    Address: LongWord;
    Shndx: LongWord;
  end;

  PMultiBootInfo = ^TMultiBootInfo;

  TMultiBootInfo = packed record
    Flags: LongWord;
    { The two variables below *can* be declared as a single qword variable,
      if your compiler supports qwords }
    LowerMemory: LongWord;
    UpperMemory: LongWord;
    BootDevice: LongWord;
    CmdLine: LongWord;
    ModuleCount: LongWord;
    ModAddress: LongWord;
    ELFSection: TELFHeaderSection;
    MemoryMapLength: LongWord;
    MemoryMapAddress: LongWord;

    DrivesLength : LongWord;
    DrivesAddress: LongWord;
  
    ConfigTtable : LongWord;
    
    BootLoaderName : LongWord;
    
    ApmTable: LongWord;
    
    Vbe_control_info : LongWord;
    Vbe_mode_info : LongWord;
    Vbe_mode : Word;
    Vbe_interface_seg : Word;
    Vbe_interface_off : Word;
    Vbe_interface_len : Word;
    
    Framebuffer_Address  : QWord;
    Framebuffer_pitch : LongWord;
    Framebuffer_width : LongWord;
    Framebuffer_height: LongWord;
    Framebuffer_bpp : Byte;    
  end;


  PModule = ^TModule;

  TModule = packed record
    ModuleStart: LongWord;
    ModuleEnd: LongWord;
    Name: LongWord;
    Reserved: LongWord;
  end;

  PMemoryMap = ^TMemoryMap;

  TMemoryMap = packed record
    Size: LongWord;
    { Again, you can declare these as a qword }
    BaseLowAddress: LongWord;
    BaseHighAddress: LongWord;
    { And once again, these can be made into one qword variable }
    LowLength: LongWord;
    HighLength: LongWord;
    MType: LongWord;
  end;

implementation

end.

