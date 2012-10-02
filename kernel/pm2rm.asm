segment .code
use16
PM2RM:                     ; near or far, your choice
  cli                      ; We can't afford an interrupt here
  mov     eax,DataSelector ; Get a selector with RM attrs
  mov     ds,eax           ; Load all selectors
  mov     es,eax           ; ...
  mov     fs,eax           ; ...
  mov     gs,eax           ; ...
  mov     ss,eax           ; ...

; We should be in identity-mapped memory at this point

  mov     eax,cr0         ; Get current value
  and     eax,0x7FFFFFFF  ; Disable paging
  mov     cr0,eax         ; Set current value, paging is now disabled

  xor     eax,eax         ; A convenient zero
  mov     cr3,eax         ; Flush the TLB

  mov     eax,cr0         ; Get current value
  and     al,0xFE         ; Tell the CPU to enter RM
  mov     cr0,eax         ; Set current value, we're now in RM

  mov     ax,DataSegment  ; Get valid data segment
  mov     ds,ax           ; Set to known value

  lidt    [RM_IDT]        ; Load the RM Interrupt Descriptor Table

  jmp     L1              ; Load CS with RM value
L1:
  lss     sp,[StackPointer] ; SS:SP ==> valid stack

  sti                     ; OK to interrupt now

; From here on, the instructions are optional (except for the ret)

  xor     ax,ax           ; A convenient zero
  mov     es,ax           ; Set to known value
  mov     fs,ax           ; ...
  mov     gs,ax           ; ...

  ret                     ; near or far return depending upon initial proc

segment .data
DataSelector:
  dw 0

DataSegment:
  dw 0

StackPointer:
  times 256 dw 0

org 0
RM_IDT:
