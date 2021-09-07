include make.rules

all: fpos

rtl:
	make -C rtl

kernel:
	make -C kernel

compile:
	make -C rtl
	make -C kernel

iso:
	$(MKISOFS) -R -b boot/grub/stage2_eltorito -no-emul-boot \
		-boot-load-size 4 -boot-info-table -o fpos.iso iso	

fpos: compile
	$(MKISOFS) -R -b boot/grub/stage2_eltorito -no-emul-boot \
		-boot-load-size 4 -boot-info-table -o fpos.iso iso			

clean-rtl:
	make -C rtl clean

clean-kernel:
	make -C kernel clean

clean: clean-rtl clean-kernel
	$(RM) fpos.iso
	$(RM) iso/boot/fpos.bin
