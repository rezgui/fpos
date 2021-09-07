include make.rules

all: clean-boot cleancompile iso

iso: clean-iso makeiso

fpos: compile iso

clean: clean-rtl clean-kernel clean-boot clean-iso

clean-rtl:
	make -C rtl clean

clean-kernel:
	make -C kernel clean

clean-boot: 
	$(RM) build/fpos.bin

clean-iso: 
	$(RM) build/fpos.iso

rtl: 
	make -C rtl

kernel: 
	make -C kernel

rtlwithclean: clean-rtl rtl

kernelwithclean: clean-kernel kernel

compile: rtl kernel

cleancompile: rtlwithclean kernelwithclean

makeiso:
	$(CP) build/fpos.bin iso/boot/fpos.bin
	$(MKISOFS) -R -b boot/grub/stage2_eltorito -no-emul-boot \
		-boot-load-size 4 -boot-info-table -o build/fpos.iso iso	
