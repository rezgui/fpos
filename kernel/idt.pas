unit idt;

interface

type

  TIDTEntry = packed record
    LowBase: Word;
    Selector: Word;
    Always0: Byte;
    Flags: Byte;
    HiBase: Word;
  end;

  TIDTPtr = packed record
    Limit: Word;
    Base: LongWord;
  end;

var
  IDTList: array [0..255] of TIDTEntry;
  IDTPtr: TIDTPtr;

procedure SetGate(Num: Byte; Base: LongWord; Sel: Word; Flg: Byte);
procedure Install;

implementation

uses
  console;

procedure LoadIDT; assembler; nostackframe;
asm
  lidt [IDTPtr]
end;

procedure SetGate(Num: Byte; Base: LongWord; Sel: Word; Flg: Byte);
begin
  with IDTList[Num] do begin
    LowBase := Base and $FFFF;
    HiBase := (Base shr 16) and $FFFF;
    Selector := Sel;
    Always0 := 0;
    Flags := Flg;
  end;
end;

procedure Install;
begin
  WriteString('Installing IDT...'#9#9);
  with IDTPtr do begin
    Limit := SizeOf(IDTList) - 1;
    Base := PtrUInt(@IDTList);
  end;
  FillByte(IDTList, SizeOf(IDTList), 0);
  LoadIDT;
  WriteStrLn('[ OK ]');
end;

end.

