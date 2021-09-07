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

program FPOSKernel;

uses
  multiboot,
  console,
  gdt,
  idt,
  isr,
  irq,
  timer,
  keybrd,
  rtc,
  pmm,
  vmm,
  heap,
  crc,
  bios_data;

var
  KernelEnd: LongWord; external name 'end'; // End of kernel
{
  procedure TempAssert(const Msg, FName: String; LineNo: LongInt;
    ErrorAddr: Pointer);
  var
    Line: String;
  begin
    SetTextColor(scBlack, scRed);
    Str(LineNo, Line);
    if Msg = '' then
      WriteString('Assertion failed')
    else
      WriteString(Msg);
    WriteString(' in ' + FName + ' line ' + Line + ' at address $' + HexStr(
      LongWord(ErrorAddr), 8) + '!');
    SetTextColor(scBlack, scLightGrey);
    WriteChar(#10);
    asm
      cli
      hlt
    end;
  end;
}

var
  MB: PMultiBootInfo; export name 'MultiBootInfo';
  MagicNumber: LongWord; export name 'MagicNumber';
begin
  { Old situation:
    We don't have Pascal's Write(Ln) support yet, so assertion will not print
    anything by default. We'll override it for now

    Current situation:
    Write(Ln) works as expected, no assertion error procedure override required.
  }
  // AssertErrorProc:=@TempAssert;
  Console.Install;
  if MagicNumber <> MultiBootBootloaderMagic then begin
    Console.SetTextColor(scBlack, scRed);
    WriteLn('ERROR: a multiboot-compliant boot loader is needed!');
    Console.SetTextColor(scBlack, scLightGrey);
    asm
      cli
      hlt
    end;
  end;
  GDT.Install;
  IDT.Install;
  ISR.Install;
  IRQ.Install;
  Timer.Install(500);
  Keybrd.Install;
  RTC.Install;
  PMM.Install(MB^.UpperMemory);
  VMM.Install;
  Heap.Install;
  PMM.FindUsableRAM(MB);
  asm
    sti
  end;

  WriteLn(LineEnding+'Welcome to FPOS Shell!');
  Write('FPOS>');
  while True do ;
end.

