unit speaker;

interface

procedure Sound(Hz: LongWord);
procedure NoSound;

implementation

uses
  x86;

procedure Sound(Hz: LongWord); [public, alias: 'Sound'];
var
  Divisor: LongWord;
  Temp: Byte;
begin
  Divisor := 1193180 div Hz;
  WritePortB($43, $B6);
  WritePortB($42, Divisor);
  WritePortB($42, Divisor shr 8);
  Temp := ReadPortB($61);
  if Temp <> (Temp or 3) then
    WritePortB($61, Temp or 3);
end;

procedure NoSound;
var
  Temp: Byte;
begin
  Temp := ReadPortB($61) and $FC;
  WritePortB($61, Temp);
end;

end.

