#
# makefile to build kernel arm
#

#
# Patches Kernel
#
HD51_PATCHES = \
		armbox/hd51_TBS-fixes-for-4.10-kernel.patch \
		armbox/hd51_0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/hd51_0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/hd51_0001-STV-Add-PLS-support.patch \
		armbox/hd51_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/hd51_blindscan2.patch \
		armbox/hd51_dvbs2x.patch \
		armbox/hd51_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/hd51_reserve_dvb_adapter_0.patch \
		armbox/hd51_blacklist_mmc0.patch \
		armbox/hd51_export_pmpoweroffprepare.patch \
		armbox/4_10_fix-multiple-defs-yyloc.patch

E4HDULTRA_PATCHES = \
		armbox/hd51_TBS-fixes-for-4.10-kernel.patch \
		armbox/hd51_0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/hd51_0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/hd51_0001-STV-Add-PLS-support.patch \
		armbox/hd51_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/hd51_blindscan2.patch \
		armbox/hd51_dvbs2x.patch \
		armbox/hd51_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/hd51_reserve_dvb_adapter_0.patch \
		armbox/hd51_blacklist_mmc0.patch \
		armbox/hd51_export_pmpoweroffprepare.patch \
		armbox/4_10_fix-multiple-defs-yyloc.patch \
		armbox/e4hdultra_v3-1-3-media-si2157-Add-support-for-Si2141-A10.patch \
		armbox/e4hdultra_v3-2-3-media-si2168-add-support-for-Si2168-D60.patch \
		armbox/e4hdultra_v3-3-3-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_v3-3-4-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_v3-3-5-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		armbox/e4hdultra_move-default-dialect-to-SMB3.patch \
		armbox/e4hdultra_add-more-devices-rtl8xxxu.patch \
		armbox/e4hdultra_0005-xbox-one-tuner-4.10.patch \
		armbox/e4hdultra_0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \

COMMON_PATCHES_3_14 = \
		armbox/vuplus_common/3_14_bcm_genet_disable_warn.patch \
		armbox/vuplus_common/3_14_linux_dvb-core.patch \
		armbox/vuplus_common/3_14_dvbs2x.patch \
		armbox/vuplus_common/3_14_dmx_source_dvr.patch \
		armbox/vuplus_common/3_14_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		armbox/vuplus_common/3_14_usb_core_hub_msleep.patch \
		armbox/vuplus_common/3_14_rtl8712_fix_build_error.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc6.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc7.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc8.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc9.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc10.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc11.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc12.patch \
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc13.patch \
		armbox/vuplus_common/3_14_fix-linker-issue-undefined-reference.patch \
		armbox/vuplus_common/3_14_0001-Support-TBS-USB-drivers.patch \
		armbox/vuplus_common/3_14_0001-STV-Add-PLS-support.patch \
		armbox/vuplus_common/3_14_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vuplus_common/3_14_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vuplus_common/3_14_blindscan2.patch \
		armbox/vuplus_common/3_14_genksyms_fix_typeof_handling.patch \
		armbox/vuplus_common/3_14_0001-tuners-tda18273-silicon-tuner-driver.patch \
		armbox/vuplus_common/3_14_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		armbox/vuplus_common/3_14_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		armbox/vuplus_common/3_14_0003-cxusb-Geniatech-T230-support.patch \
		armbox/vuplus_common/3_14_CONFIG_DVB_SP2.patch \
		armbox/vuplus_common/3_14_dvbsky.patch \
		armbox/vuplus_common/3_14_rtl2832u-2.patch \
		armbox/vuplus_common/3_14_0004-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/vuplus_common/3_14_0005-uaccess-dont-mark-register-as-const.patch \
		armbox/vuplus_common/3_14_0006-makefile-disable-warnings.patch \
		armbox/vuplus_common/3_14_linux_dvb_adapter.patch \
		armbox/vuplus_common/3_14_fix-multiple-defs-yyloc.patch

COMMON_PATCHES_4_1 = \
		armbox/vuplus_common/4_1_linux_dvb_adapter.patch \
		armbox/vuplus_common/4_1_linux_dvb-core.patch \
		armbox/vuplus_common/4_1_linux_4_1_45_dvbs2x.patch \
		armbox/vuplus_common/4_1_dmx_source_dvr.patch \
		armbox/vuplus_common/4_1_bcmsysport_4_1_45.patch \
		armbox/vuplus_common/4_1_linux_usb_hub.patch \
		armbox/vuplus_common/4_1_0001-regmap-add-regmap_write_bits.patch \
		armbox/vuplus_common/4_1_0002-af9035-fix-device-order-in-ID-list.patch \
		armbox/vuplus_common/4_1_0003-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-soloHD.patch \
		armbox/vuplus_common/4_1_0004-af9035-add-USB-ID-07ca-0337-AVerMedia-HD-Volar-A867.patch \
		armbox/vuplus_common/4_1_0005-Add-support-for-EVOLVEO-XtraTV-stick.patch \
		armbox/vuplus_common/4_1_0006-dib8000-Add-support-for-Mygica-Geniatech-S2870.patch \
		armbox/vuplus_common/4_1_0007-dib0700-add-USB-ID-for-another-STK8096-PVR-ref-desig.patch \
		armbox/vuplus_common/4_1_0008-add-Hama-Hybrid-DVB-T-Stick-support.patch \
		armbox/vuplus_common/4_1_0009-Add-Terratec-H7-Revision-4-to-DVBSky-driver.patch \
		armbox/vuplus_common/4_1_0010-media-Added-support-for-the-TerraTec-T1-DVB-T-USB-tu.patch \
		armbox/vuplus_common/4_1_0011-media-tda18250-support-for-new-silicon-tuner.patch \
		armbox/vuplus_common/4_1_0012-media-dib0700-add-support-for-Xbox-One-Digital-TV-Tu.patch \
		armbox/vuplus_common/4_1_0013-mn88472-Fix-possible-leak-in-mn88472_init.patch \
		armbox/vuplus_common/4_1_0014-staging-media-Remove-unneeded-parentheses.patch \
		armbox/vuplus_common/4_1_0015-staging-media-mn88472-simplify-NULL-tests.patch \
		armbox/vuplus_common/4_1_0016-mn88472-fix-typo.patch \
		armbox/vuplus_common/4_1_0017-mn88472-finalize-driver.patch \
		armbox/vuplus_common/4_1_0001-dvb-usb-fix-a867.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc6.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc7.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc8.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc9.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc10.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc11.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc12.patch \
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc13.patch \
		armbox/vuplus_common/4_1_0001-Support-TBS-USB-drivers-for-4.1-kernel.patch \
		armbox/vuplus_common/4_1_0001-TBS-fixes-for-4.1-kernel.patch \
		armbox/vuplus_common/4_1_0001-STV-Add-PLS-support.patch \
		armbox/vuplus_common/4_1_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/vuplus_common/4_1_blindscan2.patch \
		armbox/vuplus_common/4_1_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/vuplus_common/4_1_0002-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/vuplus_common/4_1_0003-uaccess-dont-mark-register-as-const.patch \
		armbox/vuplus_common/4_1_fix-multiple-defs-yyloc.patch

VUDUO4K_PATCHES = $(COMMON_PATCHES_4_1) \

VUDUO4KSE_PATCHES = $(COMMON_PATCHES_4_1) \

VUUNO4KSE_PATCHES = $(COMMON_PATCHES_4_1) \
		armbox/vuuno4kse_bcmgenet-recovery-fix.patch \
		armbox/vuuno4kse_linux_rpmb_not_alloc.patch

VUULTIMO4K_PATCHES = $(COMMON_PATCHES_3_14) \
		armbox/vuultimo4k_bcmsysport_3.14.28-1.12.patch \
		armbox/vuultimo4k_linux_prevent_usb_dma_from_bmem.patch

VUZERO4K_PATCHES = $(COMMON_PATCHES_4_1) \
		armbox/vuzero4k_bcmgenet-recovery-fix.patch \
		armbox/vuzero4k_linux_rpmb_not_alloc.patch

VUUNO4K_PATCHES = $(COMMON_PATCHES_3_14) \
		armbox/vuuno4k_bcmsysport_3.14.28-1.12.patch \
		armbox/vuuno4k_linux_prevent_usb_dma_from_bmem.patch

VUSOLO4K_PATCHES = $(COMMON_PATCHES_3_14) \
		armbox/vusolo4k_linux_rpmb_not_alloc.patch \
		armbox/vusolo4k_fix_mmc_3.14.28-1.10.patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_ARM)

$(ARCHIVE)/$(KERNEL_SRC):
	$(DOWNLOAD) $(KERNEL_URL)/$(KERNEL_SRC)

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
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $(KERNEL_DTB_VER) zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k e4hdultra))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7))
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	cat $(KERNEL_DIR)/arch/arm/boot/zImage $(KERNEL_DIR)/arch/arm/boot/dts/$(KERNEL_DTB_VER) > $(TARGET_DIR)/boot/zImage.dtb
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k e4hdultra))
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
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
	$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/armbox/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
