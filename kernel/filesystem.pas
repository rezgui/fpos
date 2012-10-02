unit filesystem;

interface

uses
  x86;

type

  THardDiskParam = record
    Cylinders: LongWord;
    Heads: LongWord;
    Sectors: LongWord;
  end;

  THardDiskPorts = (
    Data := $1F0,
    Error,        { $1F1 }
    SectorCount,  { $1F2 }
    SectorNumber, { $1F3 }
    LowCylinder,  { $1F4 }
    HighCylinder, { $1F5 }
    Head,         { $1F6 }
    Status,       { $1F7 }
    Command       { $1F7 }
    );

  THardDiskCommands = (
    ReadHD := $20,
    WriteHD := $30
    );

procedure AccessHardDisk(var Buf;
  const SectorToAccess, Sector, Cylinder, Head: LongWord;
  const Cmd: THardDiskCommands);

implementation

procedure AccessHardDisk(var Buf;
  const SectorToAccess, Sector, Cylinder, Head: LongWord;
  const Cmd: THardDiskCommands);
begin
  { Loop until disk is ready }
  while ReadPortL(Ord(Status)) and $C0 <> $40 do ;
  { Writes cylinder and sector information to correct ports }
  WritePortB(SectorToAccess, Ord(SectorCount));
  WritePortB(Sector, Ord(SectorNumber));
  WritePortB(Cylinder, Ord(LowCylinder));
  WritePortB(Cylinder shr 8, Ord(HighCylinder));
  { The port for head information is also used for selecting the hard disk }
  WritePortB($A0 or Head, Ord(Head));
  WritePortB(Ord(Cmd), Ord(Command));
  case Cmd of
    ReadHD: ReadPortL(Ord(Data), Buf, SectorToAccess shl 7);
    WriteHD: WritePortL(Ord(Data), Buf, SectorToAccess shl 7);
  end;
  { Insure the work is done }
  while ReadPortL(Ord(Status)) and $80 <> 0 do ;
end;

end.

