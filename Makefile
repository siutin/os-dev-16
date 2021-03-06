ASMFLAGS = -f bin

BUILD_PATH = build/
OUTPUT_FILENAME = os

SIM = qemu
VMX_PATH = ./sim/sim.vmx
QEMU = qemu-system-i386

modules = bootloader os about vidmem echo help exit reg
objects = $(modules:%=$(BUILD_PATH)/%)

all: prepare $(modules) install
	dd status=noxfer conv=notrunc if=/dev/zero of=$(BUILD_PATH)/$(OUTPUT_FILENAME).img bs=1024 count=1024
	$(BUILD_PATH)/cpy $(BUILD_PATH)/$(OUTPUT_FILENAME).img $(objects)
	@echo "Done...Written to image"

$(modules): %: %.asm
	nasm $(ASMFLAGS) $*.asm -o $(BUILD_PATH)/$*

prepare:
	mkdir -p $(BUILD_PATH)

install:cpy.c
	cc cpy.c -o $(BUILD_PATH)/cpy

clean:
	rm -rf build/*

vdi: all
	VBoxManage convertdd $(BUILD_PATH)/$(OUTPUT_FILENAME).img $(BUILD_PATH)/$(OUTPUT_FILENAME).vdi

vmdk: all
	qemu-img convert $(BUILD_PATH)/$(OUTPUT_FILENAME).img -O vmdk $(BUILD_PATH)/$(OUTPUT_FILENAME).vmdk

run-qemu: all
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
