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
  TCPUID = array [1..4] of LongInt;
  TVendor = array [0..11] of Char;

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

