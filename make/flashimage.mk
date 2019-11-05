#
# flashimage
#

flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 ufs910 ufs922 ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	cd $(BASE_DIR)/flash/nor_flash && echo "$(SUDOPASSWD)" | sudo -S ./make_flash.sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 atevio7500 ufs912 ufs913 ufc960 tf7700))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && $(SUDOCMD) ./$(BOXTYPE).sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7))
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk flash-image-$(BOXTYPE)-multi-rootfs
endif
ifeq ($(BOXTYPE), hd60)
	$(MAKE) flash-image-hd60-multi-disk flash-image-hd60-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
ifeq ($(VU_MULTIBOOT), 1)
	$(MAKE) flash-image-vu-multi-rootfs
else
	$(MAKE) flash-image-vu-rootfs
endif
endif
ifeq ($(BOXTYPE), vuduo)
	$(MAKE) flash-image-vuduo
endif
	$(TUXBOX_CUSTOMIZE)

ofgimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7))
	$(MAKE) flash-image-$(BOXTYPE)-multi-rootfs
endif
ifeq ($(BOXTYPE), hd60)
	$(MAKE) flash-image-hd60-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	$(MAKE) flash-image-vu-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

oi \
online-image:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7))
	$(MAKE) flash-image-$(BOXTYPE)-online
endif
ifeq ($(BOXTYPE), hd60)
	$(MAKE) flash-image-hd60-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	$(MAKE) flash-image-vu-online
endif
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	cd $(BASE_DIR)/flash/nor_flash && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/spark7162 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/atevio7500 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs912 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs913 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufc960 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/tf7700 && $(SUDOCMD) rm -rf ./tmp ./out
	echo ""

# general
IMAGE_BUILD_DIR = $(BUILD_TMP)/image-build

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7))
### armbox hd51 h7
# general
$(BOXTYPE)_IMAGE_NAME = disk
$(BOXTYPE)_BOOT_IMAGE = boot.img
$(BOXTYPE)_IMAGE_LINK = $($(BOXTYPE)_IMAGE_NAME).ext4
$(BOXTYPE)_IMAGE_ROOTFS_SIZE = 294912

ifeq ($(BOXTYPE), hd51)
	IMAGEDIR = $(BOXTYPE)
endif
ifeq ($(BOXTYPE), h7)
	IMAGEDIR = zgemma/$(BOXTYPE)
endif

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072
KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
KERNEL_PARTITION_SIZE = 8192
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

# partition sizes multi
# without swap data partition 819200
ROOTFS_PARTITION_SIZE_MULTI = 768000
# 51200 * 4
SWAP_DATA_PARTITION_SIZE = 204800

SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

SWAP_DATA_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))

SWAP_PARTITION_OFFSET = $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))

flash-image-$(BOXTYPE)-multi-disk: $(D)/host_resize2fs
	rm -rf $(IMAGE_BUILD_DIR)
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	# move kernel files from $(RELEASE_DIR)/boot to $(IMAGE_BUILD_DIR)
	mv -f $(RELEASE_DIR)/boot/zImage* $(IMAGE_BUILD_DIR)/
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) seek=$(shell expr $($(BOXTYPE)_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
	$(HOST_DIR)/bin/mkfs.ext4 -F $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) -d $(RELEASE_DIR)
	# move kernel files back to $(RELEASE_DIR)/boot
	mv -f $(IMAGE_BUILD_DIR)/zImage* $(RELEASE_DIR)/boot/
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	$(HOST_DIR)/bin/fsck.ext4 -pvfD $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swapdata ext4 $(SWAP_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE)
	echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_4
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4 ::
	@if [ "$(BOXTYPE)" == "hd51" ]; then \
		echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_1_12; \
		echo "boot emmcflash0.kernel2 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_2_12; \
		echo "boot emmcflash0.kernel3 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_3_12; \
		echo "boot emmcflash0.kernel4 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_4_12; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4_12 ::; \
	fi
	dd conv=notrunc if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage.dtb of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	$(HOST_DIR)/bin/resize2fs $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE_MULTI)k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR)) count=$(shell expr $($(BOXTYPE)_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR))
	mv $(IMAGE_BUILD_DIR)/disk.img $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/

flash-image-$(BOXTYPE)-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/kernel.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/rootfs.tar.bz2 $(IMAGEDIR)/kernel.bin $(IMAGEDIR)/disk.img $(IMAGEDIR)/imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-$(BOXTYPE)-online:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 kernel.bin imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)
endif

### armbox hd60
HD60_IMAGE_NAME = disk
HD60_BOOT_IMAGE = bootoptions.img
HD60_IMAGE_LINK = $(HD60_IMAGE_NAME).ext4

HD60_BOOTOPTIONS_PARTITION_SIZE = 4096
HD60_IMAGE_ROOTFS_SIZE = 1048576

HD60_SRCDATE = 20180912
HD60_BOOTARGS_SRC = $(KERNEL_TYPE)-bootargs-$(HD60_SRCDATE).zip
HD60_PARTITONS_SRC = $(KERNEL_TYPE)-partitions-$(HD60_SRCDATE).zip

$(ARCHIVE)/$(HD60_BOOTARGS_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(HD60_BOOTARGS_SRC)

$(ARCHIVE)/$(HD60_PARTITONS_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(HD60_PARTITONS_SRC)

flash-image-hd60-multi-disk: $(ARCHIVE)/$(HD60_BOOTARGS_SRC) $(ARCHIVE)/$(HD60_PARTITONS_SRC)
	# Create image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	unzip -o $(ARCHIVE)/$(HD60_BOOTARGS_SRC) -d $(IMAGE_BUILD_DIR)
	unzip -o $(ARCHIVE)/$(HD60_PARTITONS_SRC) -d $(IMAGE_BUILD_DIR)
	echo $(BOXTYPE)_DDT_recovery_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/recoveryversion
#	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(HD60_IMAGE_LINK) seek=$(shell expr $(HD60_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
#	$(HOST_DIR)/bin/mkfs.ext4 -F $(IMAGE_BUILD_DIR)/$(HD60_IMAGE_LINK) -d $(RELEASE_DIR)
#	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
#	$(HOST_DIR)/bin/fsck.ext4 -pvfD $(IMAGE_BUILD_DIR)/$(HD60_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) bs=1024 count=$(HD60_BOOTOPTIONS_PARTITION_SIZE)
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE)
	echo "bootcmd=mmc read 0 0x1000000 0x53D000 0x8000; bootm 0x1000000 bootargs=console=ttyAMA0,115200 root=/dev/mmcblk0p21 rootfstype=ext4" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "bootcmd=mmc read 0 0x3F000000 0x70000 0x4000; bootm 0x3F000000; mmc read 0 0x1FFBFC0 0x52000 0xC800; bootargs=androidboot.selinux=enforcing androidboot.serialno=0123456789 console=ttyAMA0,115200" > $(IMAGE_BUILD_DIR)/STARTUP_RED
	echo "bootcmd=mmc read 0 0x1000000 0x53D000 0x8000; bootm 0x1000000 bootargs=console=ttyAMA0,115200 root=/dev/mmcblk0p21 rootfstype=ext4" > $(IMAGE_BUILD_DIR)/STARTUP_GREEN
	echo "bootcmd=mmc read 0 0x1000000 0x53D000 0x8000; bootm 0x1000000 bootargs=console=ttyAMA0,115200 root=/dev/mmcblk0p21 rootfstype=ext4" > $(IMAGE_BUILD_DIR)/STARTUP_YELLOW
	echo "bootcmd=mmc read 0 0x1000000 0x53D000 0x8000; bootm 0x1000000 bootargs=console=ttyAMA0,115200 root=/dev/mmcblk0p21 rootfstype=ext4" > $(IMAGE_BUILD_DIR)/STARTUP_BLUE
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_RED ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_GREEN ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_YELLOW ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_BLUE ::
	rm -f $(IMAGE_BUILD_DIR)/STARTUP*
	mv $(IMAGE_BUILD_DIR)/$(HD60_BOOT_IMAGE) $(IMAGE_BUILD_DIR)/$(BOXTYPE)/$(HD60_BOOT_IMAGE)
#	ext2simg -zv $(IMAGE_BUILD_DIR)/$(HD60_IMAGE_LINK) $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.fastboot.gz
	mv $(IMAGE_BUILD_DIR)/bootargs-8gb.bin $(IMAGE_BUILD_DIR)/bootargs.bin
	mv $(IMAGE_BUILD_DIR)/$(BOXTYPE)/bootargs-8gb.bin $(IMAGE_BUILD_DIR)/$(BOXTYPE)/bootargs.bin
	cp $(RELEASE_DIR)/boot/uImage $(IMAGE_BUILD_DIR)/$(BOXTYPE)/uImage
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(shell date '+%d.%m.%Y-%H.%M')_recovery.zip *
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-hd60-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(IMAGE_BUILD_DIR)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_mmc_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(shell date '+%d.%m.%Y-%H.%M')_mmc.zip $(BOXTYPE)/rootfs.tar.bz2 $(BOXTYPE)/uImage $(BOXTYPE)/imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-hd60-online:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/uImage $(IMAGE_BUILD_DIR)/$(BOXTYPE)/uImage
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar --exclude=uImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_DDT_online_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(shell date '+%d.%m.%Y-%H.%M')_online.tgz rootfs.tar.bz2 uImage imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

### armbox vu+
# general
ifeq ($(BOXTYPE), vuduo4k)
VU_PREFIX = vuplus/duo4k
VU_INITRD = vmlinuz-initrd-7278b1
VU_FR = echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/reboot.update
endif
ifeq ($(BOXTYPE), vuuno4kse)
VU_PREFIX = vuplus/uno4kse
VU_INITRD = vmlinuz-initrd-7439b0
VU_FR = echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/reboot.update
endif
ifeq ($(BOXTYPE), vuzero4k)
VU_PREFIX = vuplus/zero4k
VU_INITRD = vmlinuz-initrd-7260a0
VU_FR = echo This file forces the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/force.update
endif
ifeq ($(BOXTYPE), vuultimo4k)
VU_PREFIX = vuplus/ultimo4k
VU_INITRD = vmlinuz-initrd-7445d0
VU_FR = echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/reboot.update
endif
ifeq ($(BOXTYPE), vuuno4k)
VU_PREFIX = vuplus/uno4k
VU_INITRD = vmlinuz-initrd-7439b0
VU_FR = echo This file forces the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/force.update
endif
ifeq ($(BOXTYPE), vusolo4k)
VU_PREFIX = vuplus/solo4k
VU_INITRD = vmlinuz-initrd-7366c0
VU_FR = echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/reboot.update
endif

flash-image-vu-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel1_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel2_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel3_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel4_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar
	mv $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar.bz2 $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs1.tar.bz2
	$(VU_FR)
	echo This file forces creating partitions. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/mkpart.update
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel_auto.bin
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar.bz2
	echo $(BOXTYPE)_DDT_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs*.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel*_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-vu-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar
	$(VU_FR)
	echo This file forces creating partitions. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-vu-online:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(VU_PREFIX)
	cp $(RELEASE_DIR)/boot/$(VU_INITRD) $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/initrd_auto.bin
	cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/kernel_auto.bin
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar --exclude=zImage* --exclude=vmlinuz-initrd* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/rootfs.tar
	$(VU_FR)
	echo This file forces creating partitions. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/mkpart.update
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(VU_PREFIX) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

### mipsbox vuduo
# general
VUDUO_PREFIX = vuplus/duo

flash-image-vuduo:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)
	touch $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/reboot.update
	cp $(RELEASE_DIR)/boot/kernel_cfe_auto.bin $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)
	mkfs.ubifs -r $(RELEASE_DIR) -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi -m 2048 -e 126976 -c 4096 -F
	echo '[ubifs]' > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'image=$(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	ubinize -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.jffs2 -m 2048 -p 128KiB $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO_PREFIX)*
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)
