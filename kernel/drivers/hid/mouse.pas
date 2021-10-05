unit mouse;

///#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#///

///Written by "RenderedIdeas-LAB" alias "achief-ws" alias Danilo Bleul///

///.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.///

///---A PS2-mouse driver for FPOS, the FreePascal Operating System.---///

///.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.///

///--Thanks to "SANiK", "the-grue", "stevej" and of course "rezgui".--///

///#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#///

{I had to make some changes in the following units:
	- console.pas
}

interface

var
  {mousecase: byte = 0;}     
  mousedata: array[0..5] of shortint;
  mousex: shortint = 0;
  mousey: shortint = 0;
  skip: byte = 0;

procedure Install;

implementation

uses
  x86, console, irq;
	
procedure MouseHandler(var r: TRegisters); //The mouse handler

function inttostr(i:integer):string;
begin
  str(i,inttostr);
end;

var status, mousein: byte;
begin
  
  {case mousecase of
  0:begin
	  mousedata[0]:=ReadPortB($60); //Mouse Button(s)
	  inc(mousecase);
	  exit; //???break
    end;
  1:begin
	  mousedata[1]:=ReadPortB($60); //Mouse x coordinate
	  inc(mousecase);
	  exit; //???break
	end;
  2:begin
	  mousedata[2]:=ReadPortB($60); //Mouse y coordinate
	  mousex:=mousedata[1];
	  mousey:=mousedata[2];
	  
	  console.settextcolor(scblack,sclightgrey);
	  console.Writechar(' ');
	  console.gotoxy(console.wherex+mousex div 40,console.wherey+mousey div 40);
	  console.settextcolor(scblue,sclightgreen);
	  console.Writechar('');
	  writestrln(inttostr(mousex)+'/'+inttostr(mousey));
	  
	  exit; //???break
	end;
  end;}  
  
  mousedata[0]:=ReadPortB($60);
  mousedata[1]:=ReadPortB($60);
  mousedata[2]:=ReadPortB($60);
  mousedata[3]:=ReadPortB($60);
  
  mousex:=mousedata[1];
  mousey:=mousedata[2];
  
  if mousex=mousey then
  begin
    mousex:=0;
	mousey:=0;
  end;
  
  console.settextcolor(scblack,sclightgrey);			/// The following code is optimized for the 80x24 resolution of the
  console.writechar(' ');								/// Console window. By the way, HD resolution will come soon...
  console.gotoxy(console.wherex-1,console.wherey);
  console.BlinkCursor;
  if console.wherex+mousex>=79 then mousex:=0;
  console.gotoxy(console.wherex+mousex,console.wherey-mousey);
  console.settextcolor(scblue,sclightgreen);
  console.writechar('M');
  console.gotoxy(console.wherex-1,console.wherey);
  console.BlinkCursor;
  {writestrln(inttostr(mousex)+' / '+inttostr(mousey));} //check procedure
  exit;
  
end;

procedure MouseWait(waitingtype: byte); //Wait if mouse is busy
var timeout: dword;
begin
  timeout:=100000;
  if waitingtype=0 then //Wait before reciving data
  begin
    while timeout>0 do
	begin
	  if (ReadPortB($64) and 1)=1 then
	  begin
		exit; //???return
	  end;
	end;
  end
  else
  begin
    while timeout>0 do //Wait before sending signal
	begin
	  if (ReadPortB($64) and 2)=0 then
	  begin
	    exit; //???return
	  end;
	end;
  end;
end;

procedure MouseWrite(writebyte: byte); //Write signal to the mouse
begin
  MouseWait(1);
  WritePort($64, $D4); //Prepare for writing
  MouseWait(1);
  WritePort($60, writebyte); //Write
end;

function MouseRead: byte; //Recive data from the mouse
begin
  MouseWait(0);
  MouseRead:=ReadPortB($60);
end;

///.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.///

procedure Install; //Add the mouse handler to IRQ
var status, testbyte: byte;
begin
  MouseWait(1);
  WritePort($64, $A8); //Enable second PS2 port for mouse
  MouseWait(1);
  WritePort($64, $20); //Read controller configuration byte
  MouseWait(0);
  status:=ReadPortB($60) or 2; //Enable second PS2 interrupt bit
  MouseWait(1);
  WritePort($64, $60); //Write controller configuration byte
  MouseWait(1);
  WritePort($60, status); //Send second PS2 interrupt bit
  MouseWrite($F6); //Configure the mouse with default settings
  testbyte:=MouseRead;
  
  MouseWrite($F4); //Enable reporting -> ENABLE MOUSE
  testbyte:=MouseRead;
  
  WriteString('Installing Mouse...'#9#9);
  IRQ.InstallHandler(12, @MouseHandler); //Install mouse handler
  WriteStrLn('[ OK ]');
end;

end.