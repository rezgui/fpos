unit keybrd;

interface

type
  TKeyMap = array [0..127] of Char;

var
  CommandBuffer: String = '';

procedure LoadKeyMap(const KeyMap, ShiftedKeyMap: TKeyMap);
procedure Install;

implementation

uses
  x86, console, irq, commands;

type
  TKeyStatus = (ksCtrl, ksAlt, ksShift, ksCapsLock, ksNumLock, ksScrollLock);
  TKeyStatusSet = set of TKeyStatus;

const
  USKeyMap: TKeyMap = (
    #00,{ 0 }
    #27,{ 1 - Esc }
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=',{ 13 }
    #08,{ 14 - Backspace }
    #09,{ 15 - Tab }
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',{ 27 }
    #10,{ 28 - Enter }
    #00,{ 29 - Ctrl }
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',{ 39 }
    '''',{ 40 - ' }
    '`',{ 41 }
    #00,{ 42 - Left Shift }
    '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',{ 53 }
    #00,{ 54 - Right Shift }
    '*',{ 55 }
    #00,{ 56 - Alt }
    ' ',{ 57 - Space bar }
    #0,{ 58 - Caps lock }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 59 - F1 up to 68 - F10 }
    #0,{ 69 - Num lock}
    #0,{ Scroll Lock }
    #0,{ Home key }
    #0,{ Up Arrow }
    #0,{ Page Up }
    '-',
    #0,{ Left Arrow }
    #0,
    #0,{ Right Arrow }
    '+',
    #0,{ 79 - End key}
    #0,{ Down Arrow }
    #0,{ Page Down }
    #0,{ Insert Key }
    #0,{ Delete Key }
    #0, #0, #0,{ 86 }
    #0,{ F11 Key }
    #0,{ F12 Key }
    #0,{ All other keys are undefined }
    #0,{ 90 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 100 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 110 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 120 }
    #0, #0, #0, #0, #0, #0, #0{ 127 }
    );

  ShiftedUSKeyMap: TKeyMap = (
    #00,{ 0 }
    #27,{ 1 - Esc }
    '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+',{ 13 }
    #08,{ 14 - Backspace }
    #09,{ 15 - Tab }
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}',{ 27 }
    #10,{ 28 - Enter }
    #00,{ 29 - Ctrl }
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',{ 39 }
    '"',{ 40 - ' }
    '~',{ 41 }
    #00,{ 42 - Left Shift }
    '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?',{ 53 }
    #00,{ 54 - Right Shift }
    '*',{ 55 - Numpad * }
    #00,{ 56 - Alt }
    ' ',{ 57 - Space bar }
    #0,{ 58 - Caps lock }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 59 - F1 up to 68 - F10 }
    #0,{ 69 - Num lock }
    #0,{ Scroll Lock }
    { 71 - 83 are numpad keys }
    #0,{ Home key (7) }
    #0,{ Up Arrow (8) }
    #0,{ Page Up (9) }
    '-',
    #0,{ Left Arrow (4) }
    #0,{ (5) }
    #0,{ Right Arrow (6) }
    '+',
    #0,{ End key (1) }
    #0,{ Down Arrow (2) }
    #0,{ Page Down (3) }
    #0,{ Insert Key (0) }
    #0,{ Delete Key (.) }
    { end of numpad keys }
    #0, #0, #0,{ 86 }
    #0,{ F11 Key }
    #0,{ F12 Key }
    { All other keys are undefined }
    #0, #0,{ 90 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 100 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 110 }
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,{ 120 }
    #0, #0, #0, #0, #0, #0, #0{ 127 }
    );

var
  KeyStatus: TKeyStatusSet; // Byte = 0;
  { // Old implementation using single byte and bitwise operation
    bit 0 = ctrl
    bit 1 = alt
    bit 2 = shift
    bit 3 = caps lock
    bit 4 = num lock
    bit 5 = scroll lock
    bit 6 = ???
    bit 7 = ???
  }
  ActiveKeyMap, ActiveShiftedKeyMap: TKeyMap;

procedure LoadKeyMap(const KeyMap, ShiftedKeyMap: TKeyMap);
begin
  ActiveKeyMap := KeyMap;
  ActiveShiftedKeyMap := ShiftedKeyMap;
end;

procedure KeyboardHandler(var r: TRegisters);
var
  ScanCode: Byte;
  c: Char;
begin
  // Read from the keyboard's data buffer
  ScanCode := ReadPortB($60);
  if (ScanCode and $80) = 0 then begin
    // 7th bit isn't set, a key has been pressed
    case ScanCode of { in bitwise, KeyStatus and $4=0 }
      42, 54: if not (ksShift in KeyStatus) then // Left and Right Shift
          // in bitwise, KeyStatus:=KeyStatus or $4;
          Include(KeyStatus, ksShift);
      58: if not (ksCapsLock in KeyStatus) then begin
          { KeyStatus and $8=0 }// Caps Lock = off
          //while ReadPortB($64) and 2 = 0 do ; // Will break if keyboard isn't busy
          WritePort($60, $ED);
          WritePort($60, ReadPortB($60) or $8); // Turns on Caps Lock light
          // in bitwise, KeyStatus:=KeyStatus or $8;
          Include(KeyStatus, ksCapsLock);
          exit;
        end else if (ksCapsLock in KeyStatus) then begin
          //while ReadPortB($64) and 2 = 0 do ; // Will break if keyboard isn't busy
          WritePort($60, $ED);
          WritePort($60, ReadPortB($60) and %11110111);
          Exclude(KeyStatus, ksCapsLock);
          exit;
        end;
    end;
    { Shift priority is higher than Caps Lock, why?
      Try switching the code and you'll understand }
    { in bitwise, KeyStatus and $4<>0 }
    if ksShift in KeyStatus then // Shift = on
      c := ActiveShiftedKeyMap[ScanCode]
    { in bitwise, KeyStatus and $8=0 }
    else if not (ksCapsLock in KeyStatus) then // Caps Lock = off
      c := ActiveKeyMap[ScanCode]
    else // Caps Lock = on
      c := UpCase(ActiveKeyMap[ScanCode]);
    // Handle characters
    case c of
      #8: begin // Backspace
        WriteChar(c);
        Delete(CommandBuffer, Length(CommandBuffer), 1);
      end;
      #10: begin // Newline
        WriteChar(c);
        ProcessCommand(CommandBuffer);
        if CommandBuffer <> '' then begin
          AddToHistory(CommandBuffer);
          CommandBuffer := '';
        end;
        WriteString('FPOS>');
      end;
      #0: begin // Control characters
        while WhereX > 5 do
          WriteChar(#8); // clean up line
        case ScanCode of
          72: begin // Up arrow
            CommandBuffer := PreviousCommand;
            WriteString(CommandBuffer);
          end;
          75: ;//GoToXY(WhereX-1,WhereY); // Left arrow
          77: ;//GoToXY(WhereX+1,WhereY); // Right arrow
          80: begin // Down arrow
            CommandBuffer := NextCommand;
            WriteString(NextCommand);
          end;
        end;
      end;
      else // Other characters
        if Length(CommandBuffer) < 255 then begin // ShortString limit
          WriteChar(c);
          CommandBuffer := CommandBuffer + c;
        end else begin
          WriteStrLn('');
          SetTextColor(scBlack, scRed);
          WriteString('Maximum command length is 255!');
          SetTextColor(scBlack, scLightGrey);
        end;
    end;
  end else begin // A key has been released
    // Turns off 7th bit
    ScanCode := ScanCode and not $80;
    case ScanCode of { in bitwise, KeyStatus and $4<>0 }
      42, 54: if ksShift in KeyStatus then
          Exclude(KeyStatus, ksShift);
    end;
  end;
end;

procedure Install;
begin
  WriteString('Installing Keyboard...'#9#9);
  LoadKeyMap(USKeyMap, ShiftedUSKeyMap);
  IRQ.InstallHandler(1, @KeyboardHandler);
  ResetCommands;
  WriteStrLn('[ OK ]');
end;

end.

