{ Pascal conversion of original C code by Uranium-239 & Napalm }
unit rtc;

interface

type
  TTime = record
    Second, Minute, Hour, DayOfWeek, DayOfMonth, Month, Year: Byte;
  end;

function GetTime: TTime;
procedure Install;

implementation

uses
  x86, console, irq;

var
  GlobalTime: TTime;
  IsBCD: Boolean;

function ReadRegister(Reg: Byte): Byte;
begin
  WritePortB($70, Reg);
  ReadRegister := ReadPortB($71);
end;

procedure WriteRegister(Reg, Value: Byte);
begin
  WritePortB($70, Reg);
  WritePortB($71, Value);
end;

function BCDToBin(BCD: Byte): Byte;
begin
  BCDToBin := ((BCD shr 4) * 10) + (BCD and $0F);
end;

function GetTime: TTime; [public, alias: 'GetTime']; inline;
begin
  GetTime := GlobalTime;
end;

procedure RTCHandler(var r: TRegisters);
// const
// DaysOnMonth: array [1..12] of Byte = (31,28,31,30,31,30,31,31,30,31,30,31);
// MaxDaysThisMonth: Byte = 0;
begin
  if ReadRegister($0C) and $40 <> 0 then
    with GlobalTime do
      if IsBCD then begin
        Second := BCDToBin(ReadRegister($00));
        Minute := BCDToBin(ReadRegister($02));
        Hour := BCDToBin(ReadRegister($04));
        Month := BCDToBin(ReadRegister($08));
        Year := BCDToBin(ReadRegister($09));
        DayOfWeek := BCDToBin(ReadRegister($06));
        DayOfMonth := BCDToBin(ReadRegister($07));
      end else begin
        Second := ReadRegister($00);
        Minute := ReadRegister($02);
        Hour := ReadRegister($04);
        Month := ReadRegister($08);
        Year := ReadRegister($09);
        DayOfWeek := ReadRegister($06);
        DayOfMonth := ReadRegister($07);
      end;
  // if ReadRegister($0C) and $10<>0 then begin
  // Inc(Second);
  // if Second>=60 then begin
  // Second:=0;
  // Inc(Minute);
  // if Minute>=60 then begin
  // Minute:=0;
  // Inc(Hour);
  // if Hour>=60 then begin
  // Hour:=0;
  // Inc(DayOfMonth);
  // if DayOfMonth>=MaxDaysThisMonth then begin
  // DayOfMonth:=1;
  // Inc(Month);
  // if Month>12 then begin
  // Month:=1;
  // Inc(Year);
  // end;
  // MaxDaysThisMonth:=DaysOnMonth[Month];
  // if Month=2 then begin // February - need to check for leap Year
  // if Year mod 400=0 then
  // Inc(MaxDaysThisMonth)
  // else if (Year mod 100<>0) and (Year mod 4=0) then
  // Inc(MaxDaysThisMonth);
  // end;
  // end;
  // end;
  // end;
  // end;
  // end;
end;

procedure Install;
var
  Status: Byte;
begin
  WriteString('Installing RTC...'#9#9);
  WriteRegister($0A, ReadRegister($0A) or $0F);
  Status := ReadRegister($0B);
  Status := Status or $02;               // 24 Hour clock
  Status := Status and $10;              // no update ended interrupts
  Status := Status and not $20;          // no alarm interrupts
  Status := Status or $40;               // enable periodic interrupt
  IsBCD := Boolean(not (Status and $04)); // check if data type is BCD
  WriteRegister($0B, Status);
  ReadRegister($0C);
  IRQ.InstallHandler(8, @RTCHandler);
  WriteStrLn('[ OK ]');
end;

end.

