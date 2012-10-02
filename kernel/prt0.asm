;/////////////////////////////////////////////////////////
;//                                                     //
;//               Freepascal barebone OS                //
;//                      stub.asm                       //
;//                                                     //
;/////////////////////////////////////////////////////////
;//
;//     By:             De Deyn Kim <kimdedeyn@skynet.be>
;//     License:        Public domain
;//
;//     Modified by: Mario Ray M. for his FreePascal OS
;//     with help from Bran's Kernel Development Tutorial

;
; Kernel stub
;

;
; We are in 32bits protected mode
;
bits 32
;
; Possible multiboot header flags
;
MULTIBOOT_MODULE_ALIGN          equ     1<<0
MULTIBOOT_MEMORY_MAP            equ     1<<1
MULTIBOOT_GRAPHICS_FIELDS       equ     1<<2
MULTIBOOT_ADDRESS_FIELDS        equ     1<<16

;
; Multiboot header defines
;
MULTIBOOT_HEADER_MAGIC          equ     0x1BADB002
MULTIBOOT_HEADER_FLAGS          equ     MULTIBOOT_MODULE_ALIGN | MULTIBOOT_MEMORY_MAP
MULTIBOOT_HEADER_CHECKSUM       equ     -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

;
; Kernel stack size
;
KERNEL_STACKSIZE                equ     0x4000

section .text

;
; Multiboot header
;
align 4
dd MULTIBOOT_HEADER_MAGIC
dd MULTIBOOT_HEADER_FLAGS
dd MULTIBOOT_HEADER_CHECKSUM

;
; Export entrypoint
;
global _start
;
; Import kernel entrypoint
;
extern PASCALMAIN
extern MultiBootInfo
extern MagicNumber
;
; Entrypoint
;
_start:
  mov  esp,KERNEL_STACK+KERNEL_STACKSIZE ; Create kernel stack
  mov  [MagicNumber],eax                 ; Multiboot magic number
  mov  [MultiBootInfo],ebx               ; Multiboot info
  call PASCALMAIN                        ; Call kernel entrypoint
  cli                                    ; Clear interrupts
  hlt                                    ; Halt machine

; macro for ISRs without error code
%macro ISRWithoutErrorCode 1
global isr%1
isr%1:
  cli
  push byte 0
  push byte %1
  jmp  ISRCommonStub
%endmacro

; macro for ISRs with error code
%macro ISRWithErrorCode 1
global isr%1
isr%1:
  cli
  push byte %1
  jmp  ISRCommonStub
%endmacro

ISRWithoutErrorCode  0 ; Division By Zero Exception
ISRWithoutErrorCode  1 ; Debug Exception
ISRWithoutErrorCode  2 ; Non Maskable Interrupt Exception
ISRWithoutErrorCode  3 ; Breakpoint Exception
ISRWithoutErrorCode  4 ; Into Detected Overflow Exception
ISRWithoutErrorCode  5 ; Out of Bounds Exception
ISRWithoutErrorCode  6 ; Invalid Opcode Exception
ISRWithoutErrorCode  7 ; No Coprocessor Exception
ISRWithErrorCode     8 ; Double Fault Exception
ISRWithoutErrorCode  9 ; Coprocessor Segment Overrun Exception
ISRWithErrorCode    10 ; Bad TSS Exception
ISRWithErrorCode    11 ; Segment Not Present Exception
ISRWithErrorCode    12 ; Stack Fault Exception
ISRWithErrorCode    13 ; General Protection Fault Exception
ISRWithErrorCode    14 ; Page Fault Exception
ISRWithoutErrorCode 15 ; Unknown Interrupt Exception
ISRWithoutErrorCode 16 ; Coprocessor Fault Exception
ISRWithoutErrorCode 17 ; Alignment Check Exception
ISRWithoutErrorCode 18 ; Machine Check Exception
ISRWithoutErrorCode 19 ; Reserved
ISRWithoutErrorCode 20 ; Reserved
ISRWithoutErrorCode 21 ; Reserved
ISRWithoutErrorCode 22 ; Reserved
ISRWithoutErrorCode 23 ; Reserved
ISRWithoutErrorCode 24 ; Reserved
ISRWithoutErrorCode 25 ; Reserved
ISRWithoutErrorCode 26 ; Reserved
ISRWithoutErrorCode 27 ; Reserved
ISRWithoutErrorCode 28 ; Reserved
ISRWithoutErrorCode 29 ; Reserved
ISRWithoutErrorCode 30 ; Reserved
ISRWithoutErrorCode 31 ; Reserved

; This is our common ISR stub. It saves the processor state, sets
; up for kernel mode segments, calls the Pascal-level ISR handler,
; and finally restores the stack frame.
extern ISRHandler
ISRCommonStub:
  pusha

  push ds
  push es
  push fs
  push gs

  mov  ax,0x10
  mov  ds,ax
  mov  es,ax
  mov  fs,ax
  mov  gs,ax
  mov  eax,esp
  push eax

  mov  eax,ISRHandler
  call eax

  pop  eax
  pop  gs
  pop  fs
  pop  es
  pop  ds

  popa
  add  esp,8
  iret

; macro for IRQs, IRQ 0 corresponds to ISR 32, IRQ 1 to ISR 33, and so on
%macro IRQ 1
global irq%1
irq%1:
  cli
  push byte 0
  push byte %1+32
  jmp  IRQCommonStub
%endmacro

IRQ  0 ; Timer
IRQ  1 ; Keyboard
IRQ  2 ; ???
IRQ  3 ; ???
IRQ  4 ; ???
IRQ  5 ; ???
IRQ  6 ; ???
IRQ  7 ; ???
IRQ  8 ; Real Time Clock
IRQ  9 ; ???
IRQ 10 ; ???
IRQ 11 ; ???
IRQ 12 ; ???
IRQ 13 ; ???
IRQ 14 ; ???
IRQ 15 ; ???

extern IRQHandler
IRQCommonStub:
  pusha

  push ds
  push es
  push fs
  push gs

  mov  ax,0x10
  mov  ds,ax
  mov  es,ax
  mov  fs,ax
  mov  gs,ax
  mov  eax,esp
  push eax

  mov  eax,IRQHandler
  call eax

  pop  eax
  pop  gs
  pop  fs
  pop  es
  pop  ds

  popa
  add  esp,8
  iret

extern GDTPtr
global FlushGDT
FlushGDT:
  push eax
  lgdt [GDTPtr]
  mov  ax,0x10
  mov  ds,ax
  mov  es,ax
  mov  fs,ax
  mov  gs,ax
  mov  ss,ax
  jmp  0x08:flush
flush:
  pop  eax
  ret

; WARNING: doesn't work yet
; global LeavePMode
; LeavePMode:
  ; push eax
  ; cli
  ; lgdt [RealModeGDT]
  ; mov  eax,cr0
  ; or   al,1
  ; mov  cr0,eax
  ; mov  ax,0x08
  ; mov  gs,ax
  ; mov  fs,ax
  ; . . .     <<<< any other segment registers if needed
  ; mov  eax,cr0        ;
  ; and  al,0xFE        ; this clears PM bit
  ; mov  cr0,eax        ;
  ; sti
  ; pop  ebp
  ; ret
; alternate code
  ; push eax
  ; mov  eax,.rmode
  ; mov  [.offset],ax
  ; jmp  0x18:.pmode16b - 0x10000
; align 16
; use16
; .pmode16b:
  ; mov eax,cr0
  ; and al,~1
  ; mov cr0,eax
  ; db 0xea
; .offset:
  ; dw 0
  ; dw 0x1000
; .rmode:
  ; mov ah,0
  ; mov al,0x13
  ; int 0x10
  ; ret

section .data

RealModeGDT:
dq 0,00CF92000000FFFFh    ;only NULL and Data Segment descriptors

RealModeGDTR:
dw RealModeGDTR-RealModeGDT-1
dd RealModeGDT

section .bss
;
; Kernel stack location
;
align 32

KERNEL_STACK:
  resb KERNEL_STACKSIZE
