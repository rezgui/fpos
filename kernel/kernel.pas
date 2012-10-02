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
  tests;

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

  LinkedListTest;
  WriteLnTest;

  WriteLn(LineEnding+'Welcome to FPOS Shell!');
  Write('FPOS>');
  while True do ;
end.

