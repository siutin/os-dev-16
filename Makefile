dev = /dev/sde
ASMFLAGS = -f bin

OWN_USER = martin
BUILD_PATH = build/
OUTPUT_FILENAME = os

SIM = qemu
VMX_PATH = ./sim/sim.vmx
QEMU = qemu-system-i386

all:bootloader os  about vidmem echo help exit reg install
	cpy $(dev) bootloader os about vidmem echo help exit reg
	@echo "Done...Written to disk"

bootloader:bootloader.asm
	nasm $(ASMFLAGS) bootloader.asm

os:os.asm
	nasm $(ASMFLAGS) os.asm

reg:reg.asm
	nasm $(ASMFLAGS) reg.asm

about:about.asm
	nasm $(ASMFLAGS) about.asm

help:help.asm
	nasm $(ASMFLAGS) help.asm

vidmem:vidmem.asm
	nasm $(ASMFLAGS) vidmem.asm

echo:echo.asm
	nasm $(ASMFLAGS) echo.asm

exit:exit.asm
	nasm $(ASMFLAGS) exit.asm

install:cpy.c
	cc cpy.c -o cpy
	cp cpy /bin/cpy

clean:
	rm bootloader
	rm os
	rm echo
	rm vidmem
	rm about
	rm filetable
	rm help
	rm reg
	rm exit
	rm -rf build/*

img: all
	mkdir -p $(BUILD_PATH)
	dd status=noxfer conv=notrunc if=$(dev) of=$(BUILD_PATH)/$(OUTPUT_FILENAME).img bs=1024 count=1024
	chown $(OWN_USER) $(BUILD_PATH)/$(OUTPUT_FILENAME).img

vdi: img
	VBoxManage convertdd $(BUILD_PATH)/$(OUTPUT_FILENAME).img $(BUILD_PATH)/$(OUTPUT_FILENAME).vdi

vmdk: img
	qemu-img convert $(BUILD_PATH)/$(OUTPUT_FILENAME).img -O vmdk $(BUILD_PATH)/$(OUTPUT_FILENAME).vmdk

run-qemu: img
	$(QEMU) -hda $(BUILD_PATH)/$(OUTPUT_FILENAME).img

run-vmware: vmdk
	vmware $(VMX_PATH) -x

run-virtualbox: vdi
	echo "not supported yet"

run:
ifeq ($(SIM),qemu)
	make run-qemu
else ifeq ($(SIM),vmware)
	make run-vmware
else ifeq ($(SIM),virtualbox)
	make run-virtualbox
else
	echo "not supported yet"
endif
