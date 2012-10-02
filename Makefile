include make.rules

all: fpos

fpos:
	make -C rtl
	make -C kernel
	$(MKISOFS) -R -b boot/grub/stage2_eltorito -no-emul-boot \
		-boot-load-size 4 -boot-info-table -o fpos.iso iso

clean:
	make -C rtl clean
	make -C kernel clean
	rm -f fpos.iso
	rm -f iso/boot/fpos
