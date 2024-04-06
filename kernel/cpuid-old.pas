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

{
  Unit implemented so the OS can get information about
  the processor ID and manufacturer for error reporting (if implemented)
  and for fixing certain bugs on different CPU's

  Matt.
}

unit cpuid;

interface

const
  ID_BIT = $200000; // EFLAGS ID bit

type
    PCapabilities_Old = ^TCapabilities_Old;
    TCapabilities_Old = bitpacked record
        FPU   : Boolean;  
        VME   : Boolean;  
        DE    : Boolean;  
        PSE   : Boolean;  
        TSC   : Boolean;  
        MSR   : Boolean;  
        PAE   : Boolean;  
        MCE   : Boolean;  
        CX8   : Boolean;  
        APIC  : Boolean;
        RESV0 : Boolean;  
        SEP   : Boolean; 
        MTRR  : Boolean; 
        PGE   : Boolean; 
        MCA   : Boolean; 
        CMOV  : Boolean; 
        PAT   : Boolean; 
        PSE36 : Boolean; 
        PSN   : Boolean; 
        CLF   : Boolean; 
        RESV1 : Boolean;
        DTES  : Boolean;  
        ACPI  : Boolean;  
        MMX   : Boolean;  
        FXSR  : Boolean;  
        SSE   : Boolean;  
        SSE2  : Boolean;  
        SS    : Boolean;  
        HTT   : Boolean;  
        TM1   : Boolean;  
        IA64  : Boolean; 
        PBE   : Boolean;
    end;
    PCapabilities_New = ^TCapabilities_New;
    TCapabilities_New = bitpacked record
        SSE3         : Boolean; 
        PCLMUL       : Boolean;
        DTES64       : Boolean;
        MONITOR      : Boolean;  
        DS_CPL       : Boolean;  
        VMX          : Boolean;  
        SMX          : Boolean;  
        EST          : Boolean;  
        TM2          : Boolean;  
        SSSE3        : Boolean;  
        CID          : Boolean;
        RESV0        : Boolean;
        FMA          : Boolean;
        CX16         : Boolean; 
        ETPRD        : Boolean; 
        PDCM         : Boolean;
        RESV1        : Boolean; 
        PCIDE        : Boolean; 
        DCA          : Boolean; 
        SSE4_1       : Boolean; 
        SSE4_2       : Boolean; 
        x2APIC       : Boolean; 
        MOVBE        : Boolean; 
        POPCNT       : Boolean; 
        RESV2        : Boolean;
        AES          : Boolean; 
        XSAVE        : Boolean; 
        OSXSAVE      : Boolean; 
        AVX          : Boolean;
        RESV3        : Boolean;
        RDRAND       : Boolean;
        RESV5        : Boolean;
    end;
    TClockSpeed = record
        Hz  : uint32;
        KHz : uint32;
        MHz : uint32;
        GHz : uint32;
    end;
    TCPUID = record
        ClockSpeed    : TClockSpeed;
        Identifier    : Array[0..12] of Char;
        Capabilities0 : PCapabilities_Old;
        Capabilities1 : PCapabilities_New;
    end;


    TVendor = array [0..11] of Char;

var
    CPUID            : TCPUID;
    CAP_OLD, CAP_NEW : uint32;

function IsCPUAvailable: Boolean;
function GetCPUID: TCPUID; assembler;
function GetCPUVendor: TVendor; assembler;
procedure DetectCPUID;

implementation

uses
  Console;

function IsCPUAvailable: Boolean; assembler;
asm
  pushfd
  pop    eax
  mov    edx,eax
  xor    eax,id_bit
  push   eax
  popfd
  pushfd
  pop    eax
  xor    eax,edx
  mov    al,1
end ['eax','edx'];

function GetCPUID: TCPUID; assembler;
asm
  push    ebx         {save affected register}
  push    edi
  mov     edi,eax     {@result}
  mov     eax,1
  cpuid
  stosd               {cpuid[1]}
  mov     eax,ebx
  stosd               {cpuid[2]}
  mov     eax,ecx
  stosd               {cpuid[3]}
  mov     eax,edx
  stosd               {cpuid[4]}
  pop     edi         {restore registers}
  pop     ebx
end ['eax','edx','ebx','ecx','edi'];

function GetCPUVendor: TVendor; assembler;
asm
  push    ebx         {save affected register}
  push    edi
  mov     edi,eax     {@result (tVendor)}
  mov     eax,0
  cpuid
  mov     eax,ebx
  xchg    ebx,ecx     {save ecx result}
  mov     ecx,4
@1:
  stosb
  shr     eax,8
  loop    @1
  mov     eax,edx
  mov     ecx,4
@2:
  stosb
  shr     eax,8
  loop    @2
  mov     eax,ebx
  mov     ecx,4
@3:
  stosb
  shr     eax,8
  loop    @3
  pop     edi         { restore the registers }
  pop     ebx
end ['eax','ebx','ecx','edi'];

procedure DetectCPUID;
var
  CPUID: TCPUID;
  Vendor: TVendor;
begin
  if IsCPUAvailable then begin
    CPUID := GetCPUID;
    Vendor := GetCPUVendor;
    WriteLn('Current CPU in Use: ',CPUID[1]);
    WriteLn('Vendor of CPU: ' + Vendor);
  end else
    WriteLn('Could not get CPU ID????');
end;

end.

