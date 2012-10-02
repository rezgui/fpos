{ FPOS specific information }
type
  THandle = LongInt;

  TThreadID = LongInt;

  PRegisters = ^TRegisters;
  TRegisters = record
    gs,fs,es,ds: LongWord;
    edi,esi,ebp,esp,ebx,edx,ecx,eax: LongWord;
    InterruptNumber,ErrorCode: LongWord;
    eip,cs,eflags,UserESP,ss: LongWord;
  end;

  PRTLCriticalSection = ^TRTLCriticalSection;
  TRTLCriticalSection = record
  end;

// Get string representation of l in Base-nary format at least Count long
function BaseStr(l: LongWord; const Base,Count: Byte): String;
