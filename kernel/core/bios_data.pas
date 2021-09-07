// Copyright (C) 2021 Yacine REZGUI
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

unit bios_data;

interface

type
     TBD = bitpacked record
          COM1           : Word;
          COM2           : Word;
          COM3           : Word;
          COM4           : Word;
          LPT1           : Word;
          LPT2           : Word;
          LPT3           : Word;
          EBDA           : Word;
          HardwareFlags  : Word;
          KeyboardFlags  : Word;
          KeyboardBuffer : ARRAY[0..31] OF Byte;
          DisplayMode    : Byte;
          BaseIO         : Word;
          Ticks          : Word;
          HDDCount       : Byte;
          KeyboardStart  : Word;
          KeyboardEnd    : Word;
          KeyboardState  : Byte;
     end;
     PBD = ^TBD;

     TMCFG = bitpacked record
        Signature        : Array[0..3] of Char;
        TableLength     : LongWord;
        Revision         : Byte;
        Checksum         : Byte;
        OEMID           : Array[0..5] of Byte;
        OEMTableID     : QWord;
        OEMRevision     : LongWord;
        CreatorID       : LongWord;
        CreatorRevision : LongWord;
        Reserved         : QWord;
     end;
     PMCFG = ^TMCFG;

     TCounters = record
        c16 : Word;
        c32 : LongWord;
        c64 : QWord;
     end;

const
     BD : PBD = PBD($C0000400);

var
    Counters : TCounters;

procedure tick_update(data : void);

implementation

uses
    console, vmm;

procedure tick_update(data : void);
begin
    //BD^.Ticks:= BD^.Ticks + 1;
    inc(BD^.Ticks);
    inc(Counters.c16);
    inc(Counters.c32);
    inc(Counters.c64);
end;

end.
