# FPOS - Free Pascal Operating System  <img src="https://img.shields.io/badge/Code-FreePascal-blue"> <img src="https://img.shields.io/badge/Code-ASM-red">
<p align="right">version 0.01 -  Date Build : 01-01-2010</p>

<p align="center">
  
</p>

## Introduction :
<img align="right" src="https://wiki.freepascal.org/images/9/92/built_with_fpc_logo.png">
FPOS is a operating system consists of a minimal kernel built on FreePascal and asm. It contains a Scheme implementation of a hard drive (ATA) driver, keyboard (PS2), serial (8250 UART), FAT32 filesystem and a small real time clock manager. The project was built to experiment with developement of operating system using a high level functional language to study the developement process and the use of Scheme to build a fairly complex system.
<br><br>


Boot             |  Shell (CLI) | Command (Help)
:-------------------------:|:-------------------------:|:-------------------------:
<img src="res/fpos_boot.png" width="300">  |  <img src="res/fpos_boot.png" width="300">|  <img src="res/fpos_boot.png" width="300">

Bugs and help / improvements will be appreciated, please send them to (Yacine REZGUI) yacine.rezgui@gmail.com and (Mario Ray Mahardhika) leledumbo_cool@yahoo.co.id.

## Implemented :
- [x] GDT, IDT       ( no problem... I hope )
- [x] ISR            ( currently, only page fault has additional handler )
- [x] IRQ            ( no problem... I hope  )
- [x] Console        ( including simple command processing )
- [x] Keyboard       ( try to be US-std, but I don't know the keymap. Just guessing for now )
- [x] Memory Manager ( needs testing )
- [x] Speaker        ( just for fun :-) )
- [x] RTC            ( seems wrong at PM, also for DayOfWeek )

## Fixed :
- Successive Write(Ln) fails due to 103 IOResult
- Some inline assembler and assembler routines are missing register list, causing it to crash randomly (please test)

## Changed :
- Updated to FPC RTL revision 14499

## Added :
-

## Next :
- System calls
- Multitasking
- Filesystem ( perhaps FAT12 is the most obvious, or should we create one ourselves? )

## Note :
- Some files are not used due to unusability ( multitasking & filesystem )

# How to compile :
- Make sure you have working FPC installation ( try using latest 2.5.x snapshot if your version fails )
- Copy executables** under tools to a directory listed in your PATH ( or Path )
- Open Command Prompt ( start->run->cmd ), cd to fpos top directory, then type 'make'

## How to test :
- Adapt "run on (Qemu | Bochs).bat" to your Qemu / Bochs installation

* : on Linux, you must change 'i386-linux-ld' in make.rules to 'ld'
**: Windows only, most Linux users should get them easily
