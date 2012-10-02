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

