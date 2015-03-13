# Free Pascal Operating System #
_<sub>version 01-01-2010</sub>_

---


Bugs and help / improvements will be appreciated, please send them to
leledumbo\_cool@yahoo.co.id.

## Implemented: ##
  * GDT, IDT       ( no problem... I hope )
  * ISR            ( currently, only page fault has additional handler )
  * IRQ            ( no problem... I hope  )
  * Console        ( including simple command processing )
  * Keyboard       ( try to be US-std, but I don't know the keymap. Just guessing for now )
  * Memory Manager ( needs testing )
  * Speaker        ( just for fun :-) )
  * RTC            ( seems wrong at PM, also for DayOfWeek )

## Fixed: ##
  * Successive Write(Ln) fails due to 103 IOResult
  * Some inline assembler and assembler routines are missing, register list, causing it to crash randomly (please test)

## Changed: ##
  * Updated to FPC RTL [revision 14499](https://code.google.com/p/fpos/source/detail?r=14499)

## Next: ##
  * System calls
  * Multitasking
  * Filesystem ( perhaps FAT12 is the most obvious, or should we create one ourselves? )

## Note: ##
  * Some files are not used due to unusability ( multitasking & filesystem )

## How to compile: ##
  * Make sure you have working FPC installation ( try using latest 2.5.x snapshot if your version fails )
  * Copy executables under tools to a directory listed in your PATH ( or Path )
  * Open Command Prompt **( start->run->cmd )**, cd to fpos top directory, then type **'make'**

## How to test: ##
  * Adapt "run on (Qemu | Bochs).bat" to your Qemu / Bochs installation
    1. **on Linux**, you must change **'i386-linux-ld'** in **make.rules** to **'ld'**
    1. **Windows only**, most Linux users should get them easily