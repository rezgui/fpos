OUTPUT_FORMAT("elf32-i386")
INPUT(
obj\prt0.o
obj\kernel.o
obj\multiboot.o
obj\console.o
obj\speaker.o
obj\gdt.o
obj\idt.o
obj\isr.o
obj\irq.o
obj\timer.o
obj\keybrd.o
obj\commands.o
obj\cpuid.o
obj\pmm.o
obj\vmm.o
obj\heap.o
obj\rtc.o
..\rtl\units\i386-fpos\system.o
..\rtl\units\i386-fpos\x86.o
)
ENTRY(_start)
SECTIONS
{
  .text  0x100000 :
  {
    text = .; _text = .; __text = .;
    *(.text)
    . = ALIGN(4096);
  }
  .data  :
  {
    data = .; _data = .; __data = .;
    *(.data)
    kimage_text = .;
    LONG(text);
    kimage_data = .;
    LONG(data);
    kimage_bss = .;
    LONG(bss);
    kimage_end = .;
    LONG(end);
    . = ALIGN(4096);
  }
  .bss  :
  {
    bss = .; _bss = .; __bss = .;
    *(.bss)
    . = ALIGN(4096);
  }
  end = .; _end = .; __end = .;
}
