// Copyright (C) 2010-2021 Yacine REZGUI
// 
// This file is part of fpos.
// 
// fpos is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
// 
// fpos is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with fpos.  If not, see <http://www.gnu.org/licenses/>.

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
