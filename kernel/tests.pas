unit tests;

interface

procedure LinkedListTest;
procedure WriteLnTest;

implementation

type
  PT = ^TT;

  TT = record
    Value: LongWord;
    Next: PT;
  end;

procedure LinkedListTest;
var
  P, T: PT;
  i: LongWord;
begin
  WriteLn('Testing for linked lists...');
  New(P);
  T := P;
  T^.Value := 0;
  for i := 1 to 5 do begin
    New(T^.Next);
    T := T^.Next;
    with T^ do begin
      Value := i;
      Next := nil;
    end;
  end;
  T := P;
  while Assigned(T) do begin
    WriteLn('$' + HexStr(PtrUInt(T), 8) + ' = ',T^.Value);
    P := T;
    T := T^.Next;
    Dispose(P);
  end;
end;

procedure WriteLnTest;
type
  TEnum = (a, b, c);
var
  e: TEnum;
begin
  WriteLn('Testing for WriteLn of many types...');
  e := c;
  WriteLn('Test string ', 255, ' ', 12.34, ' ', 1.5e+10: 2: 4, ' ', e);
end;

end.
