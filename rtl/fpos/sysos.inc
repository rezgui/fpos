function GetProcessID:SizeUInt;
begin

end;

function CheckInitialStkLen(stklen : SizeUInt) : SizeUInt;
begin

end;

function ParamCount: LongInt;
begin

end;

function ParamStr(l: LongInt): String;
begin

end;

procedure Randomize;
begin

end;

function BaseStr(l: LongWord; const Base,Count: Byte): String;
const
  BaseTable: array [0..35] of Char = (
    '0','1','2','3','4','5','6','7','8','9','A','B',
    'C','D','E','F','G','H','I','J','K','L','M','N',
    'O','P','Q','R','S','T','U','V','W','X','Y','Z'
  );
var
  Buffer: array [0..255] of Char;
  P: PChar;
  i: Byte;
begin
  if Base in [2..36] then begin
    P:=@Buffer[255];
    P^:=#0;
    i:=0;
    repeat
      Dec(P);
      P^:=BaseTable[l mod Base];
      l:=l div Base;
      Inc(i);
    until l=0;
    while i<Count do begin
      Dec(P);
      P^:='0';
      Inc(i);
    end;
    BaseStr:=StrPas(P);
  end else BaseStr:='';
end;
