unit multitasking;

interface

const
  InitialPriority = 200;

type

  TTSSRec = record
    BackLink: LongWord;
    esp0,ss0: LongWord;
    esp1,ss1: LongWord;
    esp2,ss2: LongWord;
    cr3: LongWord;
    eip: LongWord;
    eflags: LongWord;
    eax,ecx,edx,ebx: LongWord;
    esp,ebp: LongWord;
    esi,edi: LongWord;
    es,cs,ss,ds,fs,gs: LongWord;
    LDT: LongWord;
    TraceBitmap: LongWord;
  end;

  TTaskState = (tsRunning,tsRunnable,tsStopped);

  PTaskRec = ^TTaskRec;
  TTaskRec = record
    TSS: TTSSRec;
    TSSEntry: QWord;
    LDT: array [0..1] of QWord;
    LDTEntry: QWord;
    State: TTaskState;
    Priority: LongWord;
    Next: PTaskRec;
  end;

var
  Task0Stack: array [0..255] of LongWord;
  Task0: TTaskRec = (
    TSS:(
      0,
    );
    TSSEntry: QWord;
    LDT: array [0..1] of QWord;
    LDTEntry: QWord;
    State: TTaskState;
    Priority: LongWord;
    Next: PTaskRec;
  );

implementation


end.
