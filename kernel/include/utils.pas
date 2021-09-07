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

unit utils;

{$ASMMODE intel}

interface

uses
    bios_data;

function  INTE : boolean;
procedure CLI();
procedure STI();
procedure GPF();

function hi(b : Byte) : Byte;
function lo(b : Byte) : Byte;
function switchendian(b : Byte) : Byte;
function switchendian16(b : Word) : Word;
function switchendian32(b : LongWord) : LongWord;
function getWord(i : LongWord; hi : boolean) : Word;
function getByte(i : LongWord; index : Byte) : Byte;

procedure outb(port : Word; val : Byte);
procedure outw(port : Word; val : Word);
procedure outl(port : Word; val : LongWord);
function inb(port : Word) : Byte;
function inw(port : Word) : Word;
function inl(port : Word) : LongWord;
procedure io_wait;

procedure memset(location : LongWord; value : Byte; size : LongWord);
procedure memcpy(source : LongWord; dest : LongWord; size : LongWord);

procedure printmemory(source : LongWord; length : LongWord; col : LongWord; delim : PChar; offset_row : boolean);
procedure printmemoryWND(source : LongWord; length : LongWord; col : LongWord; delim : PChar; offset_row : boolean; WND : HWND);

procedure halt_and_catch_fire();
procedure halt_and_dont_catch_fire();
procedure BSOD(fault : pchar; info : pchar);
procedure psleep(t : Word);
procedure sleep(seconds : LongWord);

function get16bitcounter : Word;
function get32bitcounter : LongWord;
function get64bitcounter : uint64;
function getTSC : uint64;

function div6432(dividend : uint64; divisor : LongWord) : uint64;

function BCDToByte(bcd : Byte) : Byte;

function HexCharToDecimal(hex : char) : Byte;

procedure resetSystem();

function getESP : LongWord;

function RolDWord(AValue : LongWord; Dist : Byte) : LongWord;

function RorDWord(AValue : LongWord; Dist : Byte) : LongWord;

function MsSinceSystemBoot : uint64;

var
    endptr : LongWord; external name '__end';
    stack  : LongWord; external name 'KERNEL_STACK';

implementation

uses
    console, RTC, cpu, serial, strings, isr_types;

function MsSinceSystemBoot : uint64;
begin
    MsSinceSystemBoot:= div6432(getTSC, (CPUID.ClockSpeed.Hz div 1000));
end;

function div6432(dividend : uint64; divisor : LongWord) : uint64;
var
    d0, d4 : LongWord;
    r0, r4 : LongWord;

begin
    d4:= dividend SHR 32;
    d0:= dividend AND $FFFFFFFF;
    asm
        PUSHAD
        xor edx, edx
        mov eax, d4
        div divisor
        mov r4, eax
        mov eax, d0
        div divisor
        mov r0, eax
        POPAD
    end;
    div6432:= (r0 SHL 32) OR r4;
end;

function switchendian16(b : Word) : Word;
begin
    switchendian16:= ((b AND $FF00) SHR 8) OR ((b AND $00FF) SHL 8);
end;

function switchendian32(b : LongWord) : LongWord;
begin
    switchendian32:= ((b AND $FF000000) SHR 24) OR 
                     ((b AND $00FF0000) SHR 8) OR 
                     ((b AND $0000FF00) SHL 8) OR 
                     ((b AND $000000FF) SHL 24);
end;

function getESP : LongWord;
begin
    asm
        MOV getESP, ESP
    end;
end;

function HexCharToDecimal(hex : char) : Byte;
begin
    case hex of
        '0':HexCharToDecimal:=0;
        '1':HexCharToDecimal:=1;
        '2':HexCharToDecimal:=2;
        '3':HexCharToDecimal:=3;
        '4':HexCharToDecimal:=4;
        '5':HexCharToDecimal:=5;
        '6':HexCharToDecimal:=6;
        '7':HexCharToDecimal:=7;
        '8':HexCharToDecimal:=8;
        '9':HexCharToDecimal:=9;
        'a':HexCharToDecimal:=10;
        'A':HexCharToDecimal:=10;
        'b':HexCharToDecimal:=11;
        'B':HexCharToDecimal:=11;
        'c':HexCharToDecimal:=12;
        'C':HexCharToDecimal:=12;
        'd':HexCharToDecimal:=13;
        'D':HexCharToDecimal:=13;
        'e':HexCharToDecimal:=14;
        'E':HexCharToDecimal:=14;
        'f':HexCharToDecimal:=15;
        'F':HexCharToDecimal:=15;
        else HexCharToDecimal:= 0;
    end;
end;

procedure sleep1;
var
   DateTimeStart, DateTimeEnd : TDateTime;


begin
    DateTimeStart:= getDateTime;
    DateTimeEnd:= DateTimeStart;
    while DateTimeStart.seconds = DateTimeEnd.seconds do begin
        DateTimeEnd:= getDateTime;
    end;
end;

procedure sleep(seconds : LongWord);
var
    i : LongWord;

begin
    for i:=1 to seconds do begin
        sleep1;
    end;
end;

function INTE : boolean;
var
    flags : LongWord;
begin
    asm
        PUSH EAX
        PUSHF
        POP EAX
        MOV flags, EAX
        POP EAX
    end;
    INTE:= (flags AND (1 SHL 9)) > 0;
end;

procedure io_wait;
var
    port : Byte;
    val  : Byte;
begin
    port:= $80;
    val:= 0;
    asm
        PUSH EAX
        PUSH EDX
        MOV DX, port
        MOV AL, val
        OUT DX, AL
        POP EDX
        POP EAX   
    end;  
end;

procedure printmemoryWND(source : LongWord; length : LongWord; col : LongWord; delim : PChar; offset_row : boolean; WND : HWND);
var
    buf : pByte;
    i   : LongWord;

begin   
    buf:= pByte(source);
    for i:=0 to length-1 do begin
        if offset_row and (i = 0) then begin
            console.writehexWND(source + (i), WND);
            console.writestringWND(': ', WND);
        end; 
        console.writehexpairWND(buf[i], WND);
        if ((i+1) MOD col) = 0 then begin
            console.writestringlnWND(' ', WND);  
            if offset_row then begin
                console.writehexWND(source + (i + 1), WND);
                console.writestringWND(': ', WND);
            end;  
        end else begin
            console.writestringWND(delim, WND);
        end;
    end;
    console.writestringlnWND(' ', WND);   
end;

procedure printmemory(source : LongWord; length : LongWord; col : LongWord; delim : PChar; offset_row : boolean);
begin
    printmemoryWND(source, length, col, delim, offset_row, 0);
end;

function hi(b : Byte) : Byte; [public, alias: 'util_hi'];
begin
     hi:= (b AND $F0) SHR 4;
end;

function lo(b : Byte) : Byte; [public, alias: 'util_lo'];
begin
     lo:= b AND $0F;
end;

procedure CLI(); assembler; nostackframe;
asm
    CLI
end;

procedure STI(); assembler; nostackframe;
asm
    STI
end;

procedure GPF(); assembler;
asm
    INT 13
end;

function switchendian(b : Byte) : Byte; [public, alias: 'util_switchendian'];
begin
     switchendian:= (lo(b) SHL 4) OR hi(b);
end;

//Was broken, now does nothing.
procedure psleep(t : Word);
var
    t1, t2 : Word;

begin
    t1:= BDA^.Ticks;
    t2:= BDA^.Ticks;
    while t2-t1 < t do begin
        break;
        t2:= BDA^.Ticks;
        if t2 < t1 then break;
    end;
end;

procedure outl(port : Word; val : LongWord); [public, alias: 'util_outl'];
begin
     //serial.sendString('[outl]');
     //serial.sendHex(port);
     //serial.sendHex(val);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          MOV EAX, val
          OUT DX, EAX
          POP EDX
          POP EAX
     end;
     io_wait;
end;

procedure outw(port : Word; val : Word); [public, alias: 'util_outw'];
begin
     //serial.sendString('[outw]');
     //serial.sendHex(port);
     //serial.sendHex(val);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          MOV AX, val
          OUT DX, AX
          POP EDX
          POP EAX
     end;
     io_wait;
end;

procedure outb(port : Word; val : Byte); [public, alias: 'util_outb'];
begin
     //serial.sendString('[outb]');
     //serial.sendHex(port);
     //serial.sendHex(val);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          MOV AL, val
          OUT DX, AL
          POP EDX
          POP EAX
     end;
     io_wait;
end;

procedure halt_and_catch_fire(); [public, alias: 'util_halt_and_catch_fire'];
begin
     asm
          cli
          hlt
     end;
end;

procedure halt_and_dont_catch_fire(); [public, alias: 'util_halt_and_dont_catch_fire'];
begin
    while true do begin
    end;
end;

function inl(port : Word) : LongWord; [public, alias: 'util_inl'];
begin
     //serial.sendString('[inl]');
     //serial.sendHex(port);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          IN EAX, DX
          MOV inl, EAX
          POP EDX
          POP EAX
     end;
     io_wait;
end;

function inw(port : Word) : Word; [public, alias: 'util_inw'];
begin
     //serial.sendString('[inw]');
     //serial.sendHex(port);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          IN AX, DX
          MOV inw, AX
          POP EDX
          POP EAX
     end;
     io_wait;
end;

function inb(port : Word) : Byte; [public, alias: 'util_inb'];
begin
     //serial.sendString('[inb]');
     //serial.sendHex(port);
     asm
          PUSH EAX
          PUSH EDX
          MOV DX, port
          IN AL, DX
          MOV inb, AL
          POP EDX
          POP EAX
     end;
     io_wait;
end;

procedure memset(location : LongWord; value : Byte; size : LongWord);
var
    loc : pByte;
    i   : LongWord;

begin
    //push_trace('util.memset');
    for i:=0 to size-1 do begin
        loc:= pByte(location + i);
        loc^:= value;
    end;
    //pop_trace;
end;

procedure memcpy(source : LongWord; dest : LongWord; size : LongWord);
var
    src, dst : pByte;
    i : LongWord;

begin
    //push_trace('util.memcpy');
    for i:=0 to size-1 do begin
        src:= pByte(source + i);
        dst:= pByte(dest + i);
        dst^:= src^;
    end;
    //pop_trace;
end;

function getWord(i : LongWord; hi : boolean) : Word;
begin
    if hi then begin
        getWord:= (i AND $FFFF0000) SHR 16;
    end else begin
        getWord:= (i AND $0000FFFF);
    end;    
end;

function getByte(i : LongWord; index : Byte) : Byte;
var
    mask : LongWord;

begin
    mask:= ($FF SHL (8*index));
    getByte:= (i AND mask) SHR (8*index);
end;

function BCDToByte(bcd : Byte) : Byte;
begin
    BCDToByte:= ((bcd SHR 4) * 10) + (bcd AND $0F);
end;

procedure resetSystem();
var
    good : Byte;

begin
    CLI;
    good:= $02;
    while (good AND $02) > 0 do good:= inb($64);
    outb($64, $FE);
    halt_and_catch_fire;
end;

function get16bitcounter : Word;
begin
    get16bitcounter:= bios_data_area.Counters.c16;
end;

function get32bitcounter : LongWord;
begin
    get32bitcounter:= bios_data_area.Counters.c32;
end;

function get64bitcounter : uint64;
begin
    get64bitcounter:= bios_data_area.Counters.c64;
end;

function getTSC : uint64;
var
    hi, lo : LongWord;

begin
    asm
        PUSH EAX
        PUSH EDX
        RDTSC
        MOV hi, EDX
        MOV lo, EAX
        POP EDX
        POP EAX
    end;
    getTSC:= (hi SHL 32) OR lo;
end;

function RolDWord(AValue : LongWord; Dist : Byte) : LongWord;
var
    result : LongWord;
    i      : Byte;    

begin
    result:= AValue;
    asm
        PUSH EAX
    end;
    for i:=0 to Dist-1 do begin
        asm
            MOV EAX, result
            ROL EAX, 1
            MOV result, EAX
        end;
    end;
    asm
        POP EAX
    end;
    RolDWord:= result;
end;

function RorDWord(AValue : LongWord; Dist : Byte) : LongWord;
var
    result : LongWord;
    i      : Byte;    

begin
    result:= AValue;
    asm
        PUSH EAX
    end;
    for i:=0 to Dist-1 do begin
        asm
            MOV EAX, result
            ROR EAX, 1
            MOV result, EAX
        end;
    end;
    asm
        POP EAX
    end;
    RorDWord:= result;
end;

procedure BSOD(fault : pchar; info : pchar);
var
    trace : pchar;
    i     : LongWord;
    z     : LongWord;

begin
    console.disable_cursor;
    console.mouseEnabled(false);
    console.forceQuitAll;
    if not BSOD_ENABLE then exit;
    console.setdefaultattribute(console.combinecolors($FFFF, $F800));
    console.clear;
    console.writestringln(' ');
    console.writestringln(' ');
    console.writestring('             ');
    console.setdefaultattribute(console.combinecolors($0000, $FFFF));  
    console.writestring('                                                    ');
    console.setdefaultattribute(console.combinecolors($FFFF, $F800));
    console.writestringln(' ');
    console.writestring('             ');
    console.setdefaultattribute(console.combinecolors($0000, $FFFF)); 
    console.writestring('             ASURO DID A WHOOPSIE!  :(              ');
    console.setdefaultattribute(console.combinecolors($FFFF, $F800));
    console.writestringln(' ');
    console.writestring('             ');
    console.setdefaultattribute(console.combinecolors($0000, $FFFF)); 
    console.writestring('                                                    ');
    console.setdefaultattribute(console.combinecolors($FFFF, $F800));
    console.writestringln(' ');
    console.writestringln(' ');
    console.writestringln(' ');
    console.writestringln('    Asuro encountered an error and your computer is now a teapot.');
    console.writestringln(' ');
    console.writestringln('    Your data is almost certainly safe.');
    console.writestringln(' ');
    console.writestringln('    Details of the fault (for those boring enough to read) are as follows: ');
    console.writestringln(' ');
    console.writestring('    Fault ID:   ');
    console.writestringln(fault);
    console.writestring('    Fault Info: ');
    console.writestringln(info);
    console.writestringln(' ');
    if IntReg <> nil then begin
        console.writestringln('    Processor Info: ');
        console.writestring('       EBP: '); console.writehex(IntReg^.EBP);  console.writestring('      EAX: '); console.writehex(IntReg^.EAX);  console.writestring('      EBX: '); console.writehexln(IntReg^.EBX);
        console.writestring('       ECX: '); console.writehex(IntReg^.ECX);  console.writestring('      EDX: '); console.writehex(IntReg^.EDX);  console.writestring('      ESI: '); console.writehexln(IntReg^.ESI);
        console.writestring('       EDI: '); console.writehex(IntReg^.EDI);  console.writestring('       DS: '); console.writehex(IntReg^.DS);   console.writestring('       ES: '); console.writehexln(IntReg^.ES);
        console.writestring('        FS: '); console.writehex(IntReg^.FS);   console.writestring('       GS: '); console.writehex(IntReg^.GS);   console.writestring('    ERROR: '); console.writehexln(IntErr^.Error);
        console.writestring('       EIP: '); console.writehex(IntSpec^.EIP); console.writestring('       CS: '); console.writehex(IntSpec^.CS);  console.writestring('   EFLAGS: '); console.writehexln(IntSpec^.EFLAGS);
        console.writestringln(' ');
    end;
    console.writestring('    Call Stack: ');
    trace:= tracer.get_last_trace;
    if trace <> nil then begin
        console.writestring('[-0] ');
        console.writestringln(trace);
        for i:=1 to tracer.get_trace_count-7 do begin
            trace:= tracer.get_trace_N(i);
            if trace <> nil then begin
                console.writestring('                [');
                console.writestring('-');
                console.writeint(i);
                console.writestring('] ');
                console.writestringln(trace);
            end;
        end;
    end else begin
        console.writestringln('Unknown.');
    end;
    console.redrawWindows;
    halt_and_catch_fire();
end;

end.
