#
# KERNEL
#
ifeq ($(BOXTYPE), hd51)
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20171103
KERNEL_TYPE            = hd51
KERNEL_SRC             = linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = hd51_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_PATCHES_ARM     = $(HD51_PATCHES)
KERNEL_DTB_VER         = bcm7445-bcm97445svmb.dtb
endif

ifeq ($(BOXTYPE), vusolo4k)
KERNEL_VER             = 3.14.28-1.8
KERNEL_TYPE            = vusolo4k
KERNEL_SRC_VER         = 3.14-1.8
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
KERNEL_CONFIG          = vusolo4k_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_PATCHES_ARM     = $(VUSOLO4K_PATCHES)
endif

#
# Todo: findkerneldevice.py

DEPMOD = $(HOST_DIR)/bin/depmod

#
# Patches Kernel
#
COMMON_PATCHES_ARM = \

HD51_PATCHES = \
		armbox/hd51_TBS-fixes-for-4.10-kernel.patch \
		armbox/hd51_0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/hd51_0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/hd51_0001-STV-Add-PLS-support.patch \
		armbox/hd51_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/hd51_blindscan2.patch \
		armbox/hd51_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/hd51_reserve_dvb_adapter_0.patch \
		armbox/hd51_blacklist_mmc0.patch \
		armbox/hd51_export_pmpoweroffprepare.patch

VUSOLO4K_PATCHES = \
		armbox/vusolo4k_bcm_genet_disable_warn.patch \
		armbox/vusolo4k_linux_dvb-core.patch \
		armbox/vusolo4k_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		armbox/vusolo4k_usb_core_hub_msleep.patch \
		armbox/vusolo4k_rtl8712_fix_build_error.patch \
		armbox/vusolo4k_0001-Support-TBS-USB-drivers.patch \
		armbox/vusolo4k_0001-STV-Add-PLS-support.patch \
		armbox/vusolo4k_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vusolo4k_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vusolo4k_linux_dvb_adapter.patch \
		armbox/vusolo4k_kernel-gcc6.patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_ARM)

$(ARCHIVE)/$(KERNEL_SRC):
	$(WGET) $(KERNEL_URL)/$(KERNEL_SRC)

$(D)/kernel.do_prepare: $(ARCHIVE)/$(KERNEL_SRC) $(PATCHES)/armbox/$(KERNEL_CONFIG)
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	$(UNTAR)/$(KERNEL_SRC)
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$$i; \
		done
	install -m 644 $(PATCHES)/armbox/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $(KERNEL_DTB_VER) zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	cat $(KERNEL_DIR)/arch/arm/boot/zImage $(KERNEL_DIR)/arch/arm/boot/dts/$(KERNEL_DTB_VER) > $(TARGET_DIR)/boot/zImage.dtb
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)

$(D)/kernel-headers: $(D)/kernel.do_prepare
	$(START_BUILD)
	cd $(KERNEL_DIR); \
		install -d $(TARGET_DIR)/usr/include
		cp -a include/linux $(TARGET_DIR)/usr/include
		cp -a include/asm-arm $(TARGET_DIR)/usr/include/asm
		cp -a include/asm-generic $(TARGET_DIR)/usr/include
		cp -a include/mtd $(TARGET_DIR)/usr/include
	$(TOUCH)

kernel-distclean:
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile
	rm -f $(D)/kernel.do_prepare

kernel-clean:
	-$(MAKE) -C $(KERNEL_DIR) clean
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile

#
# Helper
#
kernel.menuconfig kernel.xconfig: \
kernel.%: $(D)/kernel
	$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/armbox/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
