include make.rules

all: fpos

iso: clean-iso makeiso

fpos: clean-boot clean-rtl clean-kernel compile iso

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

compile: 
	make -C rtl
	make -C kernel

makeiso:
	$(CP) build/fpos.bin iso/boot/fpos.bin
	$(MKISOFS) -R -b boot/grub/stage2_eltorito -no-emul-boot \
		-boot-load-size 4 -boot-info-table -o build/fpos.iso iso	
