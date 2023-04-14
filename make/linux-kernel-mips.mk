#
# makefile to build kernel mips
#

#
# Patches Kernel
#
VUDUO_PATCHES = \
		mipsbox/vuduo/add-dmx-source-timecode.patch \
		mipsbox/vuduo/af9015-output-full-range-SNR.patch \
		mipsbox/vuduo/af9033-output-full-range-SNR.patch \
		mipsbox/vuduo/as102-adjust-signal-strength-report.patch \
		mipsbox/vuduo/as102-scale-MER-to-full-range.patch \
		mipsbox/vuduo/cinergy_s2_usb_r2.patch \
		mipsbox/vuduo/cxd2820r-output-full-range-SNR.patch \
		mipsbox/vuduo/dvb-usb-dib0700-disable-sleep.patch \
		mipsbox/vuduo/dvb_usb_disable_rc_polling.patch \
		mipsbox/vuduo/it913x-switch-off-PID-filter-by-default.patch \
		mipsbox/vuduo/tda18271-advertise-supported-delsys.patch \
		mipsbox/vuduo/fix-dvb-siano-sms-order.patch \
		mipsbox/vuduo/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mipsbox/vuduo/nfs-max-rwsize-8k.patch \
		mipsbox/vuduo/0001-rt2800usb-add-support-for-rt55xx.patch \
		mipsbox/vuduo/linux-sata_bcm.patch \
		mipsbox/vuduo/fix_fuse_for_linux_mips_3-9.patch \
		mipsbox/vuduo/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mipsbox/vuduo/linux-3.9-gcc-4.9.3-build-error-fixed.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc5.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc6.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc7.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc8.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc9.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc10.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc11.patch \
		mipsbox/vuduo/kernel-add-support-for-gcc12.patch \
		mipsbox/vuduo/gcc9_backport.patch \
		mipsbox/vuduo/rtl8712-fix-warnings.patch \
		mipsbox/vuduo/rtl8187se-fix-warnings.patch \
		mipsbox/vuduo/0001-Support-TBS-USB-drivers-3.9.patch \
		mipsbox/vuduo/0001-STV-Add-PLS-support.patch \
		mipsbox/vuduo/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/vuduo/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/vuduo/blindscan2.patch \
		mipsbox/vuduo/genksyms_fix_typeof_handling.patch \
		mipsbox/vuduo/0002-log2-give-up-on-gcc-constant-optimizations.patch \
		mipsbox/vuduo/0003-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mipsbox/vuduo/test.patch \
		mipsbox/vuduo/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mipsbox/vuduo/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mipsbox/vuduo/CONFIG_DVB_SP2.patch \
		mipsbox/vuduo/dvbsky-t330.patch \
		mipsbox/vuduo/fix-multiple-defs-yyloc.patch
#		mipsbox/vuduo/fixed_mtd.patch

VUDUO2_PATCHES = \
		mipsbox/vuduo2/kernel-add-support-for-gcc5.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc6.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc7.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc8.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc9.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc10.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc11.patch \
		mipsbox/vuduo2/kernel-add-support-for-gcc12.patch \
		mipsbox/vuduo2/build-with-gcc12-fixes.patch \
		mipsbox/vuduo2/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mipsbox/vuduo2/add-dmx-source-timecode.patch \
		mipsbox/vuduo2/af9015-output-full-range-SNR.patch \
		mipsbox/vuduo2/af9033-output-full-range-SNR.patch \
		mipsbox/vuduo2/as102-adjust-signal-strength-report.patch \
		mipsbox/vuduo2/as102-scale-MER-to-full-range.patch \
		mipsbox/vuduo2/cxd2820r-output-full-range-SNR.patch \
		mipsbox/vuduo2/dvb-usb-dib0700-disable-sleep.patch \
		mipsbox/vuduo2/dvb_usb_disable_rc_polling.patch \
		mipsbox/vuduo2/it913x-switch-off-PID-filter-by-default.patch \
		mipsbox/vuduo2/tda18271-advertise-supported-delsys.patch \
		mipsbox/vuduo2/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mipsbox/vuduo2/linux-tcp_output.patch \
		mipsbox/vuduo2/linux-3.13-gcc-4.9.3-build-error-fixed.patch \
		mipsbox/vuduo2/rtl8712-fix-warnings.patch \
		mipsbox/vuduo2/0001-Support-TBS-USB-drivers-3.13.patch \
		mipsbox/vuduo2/0001-STV-Add-PLS-support.patch \
		mipsbox/vuduo2/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mipsbox/vuduo2/0001-stv090x-optimized-TS-sync-control.patch \
		mipsbox/vuduo2/0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mipsbox/vuduo2/0003-log2-give-up-on-gcc-constant-optimizations.patch \
		mipsbox/vuduo2/blindscan2.patch \
		mipsbox/vuduo2/linux_dvb_adapter.patch \
		mipsbox/vuduo2/genksyms_fix_typeof_handling.patch \
		mipsbox/vuduo2/test.patch \
		mipsbox/vuduo2/disable-attribute-alias.patch \
		mipsbox/vuduo2/0001-tuners-tda18273-silicon-tuner-driver.patch \
		mipsbox/vuduo2/T220-kern-13.patch \
		mipsbox/vuduo2/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mipsbox/vuduo2/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mipsbox/vuduo2/CONFIG_DVB_SP2.patch \
		mipsbox/vuduo2/dvbsky.patch \
		mipsbox/vuduo2/move-default-dialect-to-SMB3.patch \
		mipsbox/vuduo2/brcm_s3_wol.patch

DM8000_PATCHES = \
		mipsbox/dm8000/kernel-fake-3.2.patch \
		mipsbox/dm8000/linux-dreambox-3.2-3c7230bc0819495db75407c365f4d1db70008044.patch \
		mipsbox/dm8000/unionfs-2.6_for_3.2.62.patch \
		mipsbox/dm8000/0001-correctly-initiate-nand-flash-ecc-config-when-old-2n.patch \
		mipsbox/dm8000/0001-Revert-MIPS-Fix-potencial-corruption.patch \
		mipsbox/dm8000/fadvise_dontneed_change.patch \
		mipsbox/dm8000/fix-proc-cputype.patch \
		mipsbox/dm8000/rtl8712-backport-b.patch \
		mipsbox/dm8000/rtl8712-backport-c.patch \
		mipsbox/dm8000/rtl8712-backport-d.patch \
		mipsbox/dm8000/0007-CHROMIUM-make-3.82-hack-to-fix-differing-behaviour-b.patch \
		mipsbox/dm8000/0008-MIPS-Fix-build-with-binutils-2.24.51.patch \
		mipsbox/dm8000/0009-MIPS-Refactor-clear_page-and-copy_page-functions.patch \
		mipsbox/dm8000/0010-BRCMSTB-Fix-build-with-binutils-2.24.51.patch \
		mipsbox/dm8000/0011-staging-rtl8712-rtl8712-avoid-lots-of-build-warnings.patch \
		mipsbox/dm8000/0001-brmcnand_base-disable-flash-BBT-on-64MB-nand.patch \
		mipsbox/dm8000/0002-ubifs-add-config-option-to-use-zlib-as-default-compr.patch \
		mipsbox/dm8000/em28xx_fix_terratec_entries.patch \
		mipsbox/dm8000/em28xx_add_terratec_h5_rev3.patch \
		mipsbox/dm8000/dvb-usb-siano-always-load-smsdvb.patch \
		mipsbox/dm8000/dvb-usb-af9035.patch \
		mipsbox/dm8000/dvb-usb-a867.patch \
		mipsbox/dm8000/dvb-usb-rtl2832.patch \
		mipsbox/dm8000/dvb_usb_disable_rc_polling.patch \
		mipsbox/dm8000/dvb-usb-smsdvb_fix_frontend.patch \
		mipsbox/dm8000/0001-it913x-backport-changes-to-3.2-kernel.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc6.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc7.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc8.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc9.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc10.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc11.patch \
		mipsbox/dm8000/kernel-add-support-for-gcc12.patch \
		mipsbox/dm8000/misc_latin1_to_utf8_conversions.patch \
		mipsbox/dm8000/0001-dvb_frontend-backport-multistream-support.patch \
		mipsbox/dm8000/genksyms_fix_typeof_handling.patch \
		mipsbox/dm8000/0012-log2-give-up-on-gcc-constant-optimizations.patch \
		mipsbox/dm8000/0013-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mipsbox/dm8000/0014-makefile-silence-packed-not-aligned-warn.patch \
		mipsbox/dm8000/0015-fcrypt-fix-bitoperation-for-gcc.patch \
		mipsbox/dm8000/fix-multiple-defs-yyloc.patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_MIPS)

$(ARCHIVE)/$(KERNEL_SRC):
	$(DOWNLOAD) $(KERNEL_URL)/$(KERNEL_SRC)

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
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 dm8000))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- vmlinux modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2))
	gzip -9c < "$(KERNEL_DIR)/vmlinux" > "$(KERNEL_DIR)/kernel_cfe_auto.bin"
	install -m 644 $(KERNEL_DIR)/kernel_cfe_auto.bin $(TARGET_DIR)/boot/
	ln -sf $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(TARGET_DIR)/boot/vmlinux
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif
ifeq ($(BOXTYPE), dm8000)
	gzip -9c < "$(KERNEL_DIR)/vmlinux" > "$(KERNEL_DIR)/vmlinux-3.2-dm8000.gz"
	install -m 644 $(KERNEL_DIR)/vmlinux-3.2-dm8000.gz $(TARGET_DIR)/boot/
	ln -sf vmlinux-3.2-dm8000.gz $(TARGET_DIR)/boot/vmlinux
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/source || true
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
