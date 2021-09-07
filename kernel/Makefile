include ../make.rules

kernel:
	$(NASM) $(NASMOPT) -f elf -o obj/prt0.o prt0.asm
	$(FPC) $(FPCOPT) -XPi386-linux- -k'--gc-sections -s -T linker.ld' -Fu../rtl/units/i386-fpos $(IFPC) -Fuobj -FUobj -o../build/fpos.bin kernel

clean:
	$(RRM) obj/*
