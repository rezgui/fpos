function Do_IsDevice(Handle: THandle):boolean;
begin
  Result:=true;
end;

procedure Do_Close(Handle: THandle);
begin
end;

procedure Do_Erase(p: PChar);
begin
end;

procedure do_truncate (Handle: THandle; fpos: LongInt);
begin
end;

procedure Do_Rename(p1,p2: PChar);
begin
end;

procedure WritePChar(P: PChar); external name 'WritePChar';

function Do_Write(Handle: THandle; Addr: Pointer; Len: LongInt):LongInt;
{
  Arguments:
  Handle  handle of stream where data should be written to
  Addr    address where data is stored
  Len     length of data

  Result:
  The function should return the number of data successfully written.
  In case of success, it should be the same as Len.
}
var
  Buf: array [0..2047] of Char;
begin
  { I'm not sure how data is stored, so I just turn it into PChar
    and print it out to console. The real write should be implemented
    as system call }
  Move(Addr^,Buf,Len);
  Buf[Len]:=#0;
  WritePChar(Buf);
  Do_Write:=Len;
  InOutRes:=0;
end;


function Do_Read(Handle: THandle; Addr: Pointer; Len: LongInt):LongInt;
begin
  Result:=-1;
end;

function Do_FilePos(Handle: thandle):LongInt;
begin
  Result:=-1;
end;

procedure Do_Seek(Handle: THandle;Pos:LongInt);
begin

end;

function Do_Seekend(Handle: THandle): LongInt;
begin
  Result:=-1;
end;

function Do_FileSize(Handle: THandle): LongInt;
begin
  Result:=-1;
end;

procedure Do_Open(var f; p: PChar; Flags: LongInt);
{
  FileRec and TextRec have both Handle and mode as the first items so
  they could use the same routine for opening/creating.
  when (Flags and $100)   the file will be append
  when (Flags and $1000)  the file will be truncate/rewritten
  when (Flags and $10000) there is no check for close (needed for textfiles)
}
var
  OFlags: LongInt; // True flags that should be passed to real file open call
begin
  { Close first if opened }
  if (Flags and $10000=0) then begin
    case FileRec(f).Mode of
      fmInput,fmOutput,fmInOut : Do_Close(FileRec(f).Handle);
      fmClosed : ;
      else begin
        InOutRes:=102; { Not assigned }
        Exit;
      end;
    end;
  end;
  { Reset file Handle }
  FileRec(f).Handle:=UnusedHandle;
  { Convert filemode to FileRec modes }
  case (flags and 3) of
    0: begin
      FileRec(f).mode:=fmInput;
    end;
    1: begin
      FileRec(f).mode:=fmOutput;
    end;
    2: begin
      FileRec(f).mode:=fmInOut;
    end;
  end;
  { Create it ? }
  if (Flags and $1000)<>0 then
  { or Append/Open ? }
  else ;
  { empty name is special }
  if p[0]=#0 then begin
    case FileRec(f).mode of
      fmInput : FileRec(f).Handle:=StdInputHandle;
      fmInOut, { This is set by rewrite }
      fmOutput: FileRec(f).Handle:=StdOutputHandle;
      fmAppend: begin
        FileRec(f).Handle:=StdOutputHandle;
        FileRec(f).mode:=fmOutput; { Fool fmAppend }
      end;
    end;
    Exit;
  end;
  { Must do real open call here }
end;
