#
# KERNEL
#
ifeq ($(BOXTYPE), vuduo)
KERNEL_VER             = 3.9.6
KERNEL_TYPE            = vuduo
KERNEL_SRC_VER         = 3.9.6
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
KERNEL_CONFIG          = vuduo_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_PATCHES_MIPS    = $(VUDUO_PATCHES)
endif

#
# Todo: findkerneldevice.py

DEPMOD = $(HOST_DIR)/bin/depmod

#
# Patches Kernel
#
COMMON_PATCHES_MIPS = \

VUDUO_PATCHES = \
		mipsbox/add-dmx-source-timecode.patch \
		mipsbox/af9015-output-full-range-SNR.patch \
		mipsbox/af9033-output-full-range-SNR.patch \
		mipsbox/as102-adjust-signal-strength-report.patch \
		mipsbox/as102-scale-MER-to-full-range.patch \
		mipsbox/cinergy_s2_usb_r2.patch \
		mipsbox/cxd2820r-output-full-range-SNR.patch \
		mipsbox/dvb-usb-dib0700-disable-sleep.patch \
		mipsbox/dvb_usb_disable_rc_polling.patch \
		mipsbox/it913x-switch-off-PID-filter-by-default.patch \
		mipsbox/tda18271-advertise-supported-delsys.patch \
		mipsbox/fix-dvb-siano-sms-order.patch \
		mipsbox/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mipsbox/nfs-max-rwsize-8k.patch \
		mipsbox/0001-rt2800usb-add-support-for-rt55xx.patch \
		mipsbox/linux-sata_bcm.patch \
		mipsbox/fix_fuse_for_linux_mips_3-9.patch \
		mipsbox/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mipsbox/linux-3.9-gcc-4.9.3-build-error-fixed.patch \
		mipsbox/kernel-add-support-for-gcc-5.patch \
		mipsbox/rtl8712-fix-warnings.patch \
		mipsbox/rtl8187se-fix-warnings.patch \
		mipsbox/kernel-add-support-for-gcc6.patch \
		mipsbox/0001-Support-TBS-USB-drivers-3.9.patch \
		mipsbox/0001-STV-Add-PLS-support.patch \
		mipsbox/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/blindscan2.patch \
		mipsbox/genksyms_fix_typeof_handling.patch \
		mipsbox/kernel-add-support-for-gcc7.patch \
		mipsbox/test.patch \
		mipsbox/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mipsbox/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mipsbox/CONFIG_DVB_SP2.patch \
		mipsbox/dvbsky-t330.patch
#		mipsbox/fixed_mtd.patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_MIPS)

$(ARCHIVE)/$(KERNEL_SRC):
	$(WGET) $(KERNEL_URL)/$(KERNEL_SRC)

$(D)/kernel.do_prepare: $(ARCHIVE)/$(KERNEL_SRC) $(PATCHES)/mipsbox/$(KERNEL_CONFIG)
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	$(UNTAR)/$(KERNEL_SRC)
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$$i; \
		done
	install -m 644 $(PATCHES)/mipsbox/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
ifeq ($(BOXTYPE), vuduo)
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- vmlinux modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), vuduo)
	gzip -9c < "$(KERNEL_DIR)/vmlinux" > "$(KERNEL_DIR)/kernel_cfe_auto.bin"
	install -m 644 $(KERNEL_DIR)/kernel_cfe_auto.bin $(BOOT_DIR)/vmlinux
	install -m 644 $(KERNEL_DIR)/kernel_cfe_auto.bin $(TARGET_DIR)/boot/vmlinux-mips-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-mips-$(KERNEL_VER)
	cp $(KERNEL_DIR)/kernel_cfe_auto.bin $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif

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
	$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/mipsbox/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
