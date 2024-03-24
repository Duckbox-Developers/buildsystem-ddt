#
# flashimage
#

flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 ufs910 ufs922 ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	cd $(BASE_DIR)/flash/nor_flash && echo "$(SUDOPASSWD)" | sudo -S ./make_flash.sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 atevio7500 ufs912 ufs913 tf7700))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && $(SUDOCMD) ./$(BOXTYPE).sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk flash-image-$(BOXTYPE)-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
ifeq ($(VU_MULTIBOOT), 1)
	$(MAKE) flash-image-vu-multi-rootfs
else
	$(MAKE) flash-image-vu-rootfs
endif
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuuno vuultimo))
	$(MAKE) flash-image-vuduo
endif
ifeq ($(BOXTYPE), dm8000)
	$(MAKE) flash-image-dm_old flash-image-dm_old-usb
endif
	$(TUXBOX_CUSTOMIZE)

ofgimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-rootfs
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	$(MAKE) flash-image-vu-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

oi \
online-image:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	$(MAKE) flash-image-vu-online
endif
	$(TUXBOX_CUSTOMIZE)

disk \
diskimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk flash-image-$(BOXTYPE)-disk-image
endif
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	cd $(BASE_DIR)/flash/nor_flash && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/spark7162 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/atevio7500 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs912 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs913 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/tf7700 && $(SUDOCMD) rm -rf ./tmp ./out
	echo ""

# general
IMAGE_BUILD_DIR = $(BUILD_TMP)/image-build

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
### armbox bre2ze4k hd51 h7 e4hdultra
# general
$(BOXTYPE)_IMAGE_NAME = disk
$(BOXTYPE)_BOOT_IMAGE = boot.img
$(BOXTYPE)_IMAGE_LINK = $($(BOXTYPE)_IMAGE_NAME).ext4
$(BOXTYPE)_IMAGE_ROOTFS_SIZE = 294912

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51))
	IMAGEDIR = $(BOXTYPE)
endif
ifeq ($(BOXTYPE), h7)
	IMAGEDIR = zgemma/$(BOXTYPE)
endif
ifeq ($(BOXTYPE), e4hdultra)
	IMAGEDIR = e4hd
endif

# emmc image
EMMC_IMAGE = $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 1024

KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
SWAP_DATA_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SWAP_PARTITION_OFFSET = $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
endif

flash-image-$(BOXTYPE)-multi-disk: $(D)/host_resize2fs $(D)/host_parted
	rm -rf $(IMAGE_BUILD_DIR)
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	# lcd flashlogo for e4hdultra
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
	fi
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
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 2 82))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swapdata ext4 $(SWAP_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
endif
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
endif
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP; \
		echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_1; \
		echo "boot emmcflash0.kernel2 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p5 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_2; \
		echo "boot emmcflash0.kernel3 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p7 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_3; \
		echo "boot emmcflash0.kernel4 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p9 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_4; \
		cp $(SKEL_ROOT)/release/lcdsplash.bmp $(IMAGE_BUILD_DIR)/; \
	else \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP; \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_1; \
		echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_2; \
		echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_3; \
		echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_4; \
	fi
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4 ::
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/lcdsplash.bmp ::; \
	fi
	@if [ "$(BOXTYPE)" == "hd51" -o "$(BOXTYPE)" == "bre2ze4k" -o "$(BOXTYPE)" == "h7" ]; then \
		echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_1_12; \
		echo "boot emmcflash0.kernel2 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_2_12; \
		echo "boot emmcflash0.kernel3 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_3_12; \
		echo "boot emmcflash0.kernel4 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP_4_12; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3_12 ::; \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4_12 ::; \
	fi
	dd conv=notrunc if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR)); \
	else \
		dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage.dtb of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR)); \
	fi
	$(HOST_DIR)/bin/resize2fs $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE_MULTI)k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR)) count=$(shell expr $($(BOXTYPE)_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR))
	mv $(IMAGE_BUILD_DIR)/disk.img $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/

flash-image-$(BOXTYPE)-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
		cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/kernel.bin; \
	else \
		cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/kernel.bin; \
	fi
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/imageversion
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/rootfs.tar.bz2 $(IMAGEDIR)/kernel.bin $(IMAGEDIR)/disk.img $(IMAGEDIR)/imageversion $(IMAGEDIR)/lcdflashing.bmp; \
	else \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/rootfs.tar.bz2 $(IMAGEDIR)/kernel.bin $(IMAGEDIR)/disk.img $(IMAGEDIR)/imageversion; \
	fi
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-$(BOXTYPE)-online:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin; \
	else \
		cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin; \
	fi
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	echo $(BOXTYPE)_$(FLAVOUR)_flash_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 kernel.bin imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

# disk image
flash-image-$(BOXTYPE)-disk-image:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	cd $(RELEASE_DIR); \
	echo $(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/imageversion
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_disk_img_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/disk.img $(IMAGEDIR)/imageversion $(IMAGEDIR)/lcdflashing.bmp; \
	else \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_disk_img_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/disk.img $(IMAGEDIR)/imageversion; \
	fi
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)
endif

### armbox vu+
# general
ifeq ($(BOXTYPE), vuduo4k)
VU_PREFIX = vuplus/duo4k
VU_INITRD = vmlinuz-initrd-7278b1
VU_FR = echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/reboot.update
endif
ifeq ($(BOXTYPE), vuduo4kse)
VU_PREFIX = vuplus/duo4kse
VU_INITRD = vmlinuz-initrd-7445d0
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
	echo $(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs*.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel*_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
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
	echo $(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR) && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VU_PREFIX)/rootfs.tar.bz2 $(VU_PREFIX)/initrd_auto.bin $(VU_PREFIX)/kernel_auto.bin $(VU_PREFIX)/*.update $(VU_PREFIX)/imageversion
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
	echo $(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VU_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(VU_PREFIX) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 initrd_auto.bin kernel_auto.bin *.update imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

### mipsbox vuduo
# general
ifeq ($(BOXTYPE), vuduo)
VUDUO_PREFIX = vuplus/duo
VUDUO_ROOT_EXT = jffs2
VUDUO_UBIFS = 4096
endif
ifeq ($(BOXTYPE), vuuno)
VUDUO_PREFIX = vuplus/uno
VUDUO_ROOT_EXT = jffs2
VUDUO_UBIFS = 4096
endif
ifeq ($(BOXTYPE), vuultimo)
VUDUO_PREFIX = vuplus/ultimo
VUDUO_ROOT_EXT = jffs2
VUDUO_UBIFS = 3894
endif
ifeq ($(BOXTYPE), vuduo2)
VUDUO_PREFIX = vuplus/duo2
VUDUO_ROOT_EXT = bin
VUDUO_UBIFS = 8192
VUDUO2_INITRD = cp $(TARGET_DIR)/boot/vmlinuz-initrd-7425b0 $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/initrd_cfe_auto.bin
endif

flash-image-vuduo: $(D)/host_mtd_utils
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)
	touch $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/reboot.update
	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)
	$(VUDUO2_INITRD)
	$(HOST_DIR)/bin/mkfs.ubifs -r $(RELEASE_DIR) -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi -m 2048 -e 126976 -c $(VUDUO_UBIFS) -F
	echo '[ubifs]' > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'image=$(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	$(HOST_DIR)/bin/ubinize -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.$(VUDUO_ROOT_EXT) -m 2048 -p 128KiB $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR)/ && \
	zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO_PREFIX)*
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-dm_old: $(D)/buildimage $(D)/host_mtd_utils $(D)/$(BOXTYPE)_2nd
	@echo -e "$(TERM_YELLOW_BOLD)==============================="
	@echo -e "===> Creating FLASH Image. <==="
	@echo -e "===============================$(TERM_NORMAL)"
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	rm -f $(RELEASE_DIR)/boot/*
	cp $(TARGET_DIR)/boot/vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz $(RELEASE_DIR)/boot/
	cp $(ARCHIVE)/secondstage-$(BOXTYPE)-84.bin $(IMAGE_BUILD_DIR)/$(BOXTYPE)/
	ln -sf vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz $(RELEASE_DIR)/boot/vmlinux
	echo "/boot/bootlogo-$(BOXTYPE).elf.gz filename=/boot/bootlogo-$(BOXTYPE).jpg" > $(RELEASE_DIR)/boot/autoexec.bat
	echo "/boot/vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs rw console=ttyS0,115200n8" >> $(RELEASE_DIR)/boot/autoexec.bat
	cp $(RELEASE_DIR)/boot/autoexec.bat $(RELEASE_DIR)/boot/autoexec_$(BOXTYPE).bat
	cp $(SKEL_ROOT)/release/bootlogo-$(BOXTYPE).elf.gz $(RELEASE_DIR)/boot/
	cp $(SKEL_ROOT)/release/bootlogo-$(BOXTYPE).jpg $(RELEASE_DIR)/boot/
	$(HOST_DIR)/bin/mkfs.jffs2 --root=$(RELEASE_DIR)/boot/ --disable-compressor=lzo --compression-mode=size --eraseblock=131072 --output=$(IMAGE_BUILD_DIR)/$(BOXTYPE)/boot.jffs2
	$(HOST_DIR)/bin/mkfs.ubifs -r $(RELEASE_DIR) -o $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.ubifs -m 2048 -e 126KiB -c 1961 -x favor_lzo -F
	echo '[ubifs]' > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'mode=ubi' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'image=$(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.ubifs' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'vol_id=0' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	$(HOST_DIR)/bin/ubinize -o $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.ubi -m 2048 -p 128KiB -s 512 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	rm -f $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.ubifs
	rm -f $(IMAGE_BUILD_DIR)/$(BOXTYPE)/ubinize.cfg
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d.%m.%Y-%H.%M') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	$(HOST_DIR)/bin/buildimage -a $(BOXTYPE) -e 0x20000 -f 0x4000000 -s 2048 -b 0x100000:secondstage-$(BOXTYPE)-84.bin -d 0x700000:boot.jffs2 -d 0xF800000:rootfs.ubi > $(BOXTYPE).nfi && \
	echo "Neutrino: Release" > $(BOXTYPE).nfo && \
	echo "Machine: Dreambox $(BOXTYPE)" >> $(BOXTYPE).nfo && \
	echo "Date: `date '+%Y%m%d'`" >> $(BOXTYPE).nfo && \
	echo "Issuer: $(MAINTAINER)" >> $(BOXTYPE).nfo && \
	echo "Link: https://github.com/Duckbox-Developers" >> $(BOXTYPE).nfo && \
	echo -n "MD5: " >> $(BOXTYPE).nfo && \
	md5sum -b $(BOXTYPE).nfi | awk -F " " '{print $$1}' >> $(BOXTYPE).nfo; \
	zip -jr $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_flash_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGE_BUILD_DIR)/$(BOXTYPE)/$(BOXTYPE).{nfi,nfo}
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-dm_old-usb:
	@echo -e "$(TERM_YELLOW_BOLD)========================================================"
	@echo -e "===> Creating USB Image for sda1 FAT and sda2 EXT4. <==="
	@echo -e "========================================================$(TERM_NORMAL)"
	rm -f $(RELEASE_DIR)/boot/*
	cp $(TARGET_DIR)/boot/vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz $(RELEASE_DIR)/boot/
	ln -sf vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz $(RELEASE_DIR)/boot/vmlinux
	echo "/boot/bootlogo-$(BOXTYPE).elf.gz filename=/boot/bootlogo-$(BOXTYPE).jpg" > $(RELEASE_DIR)/boot/autoexec.bat
	echo "/boot/vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs rw console=ttyS0,115200n8" >> $(RELEASE_DIR)/boot/autoexec.bat
	cp $(RELEASE_DIR)/boot/autoexec.bat $(RELEASE_DIR)/boot/autoexec_$(BOXTYPE).bat
	cp $(SKEL_ROOT)/release/bootlogo-$(BOXTYPE).elf.gz $(RELEASE_DIR)/boot/
	cp $(SKEL_ROOT)/release/bootlogo-$(BOXTYPE).jpg $(RELEASE_DIR)/boot/
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cp $(RELEASE_DIR)/boot/vmlinux-$(KERNEL_VER)-$(BOXTYPE).gz $(IMAGE_BUILD_DIR)/$(BOXTYPE)/vmlinux.gz
	echo "/usb/vmlinux.gz console=ttyS0,115200n8 rootdelay=10 root=/dev/sda2 rootfstype=ext3 rw" > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/autoexec.bat
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	tar cvzf $(IMAGE_BUILD_DIR)/$(BOXTYPE)_usb_boot_$(shell date '+%d.%m.%Y-%H.%M').tar.gz . > /dev/null 2>&1
	rm -fr $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	cd $(RELEASE_DIR) && \
	tar cvzf $(IMAGE_BUILD_DIR)/$(BOXTYPE)_usb_root_$(shell date '+%d.%m.%Y-%H.%M').tar.gz . > /dev/null 2>&1; \
	zip -jr $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGE_BUILD_DIR)/$(BOXTYPE)_usb_{boot,root}_$(shell date '+%d.%m.%Y-%H.%M').tar.gz*
	# cleanup
	rm -f $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').tar.gz*
	rm -rf $(IMAGE_BUILD_DIR)
