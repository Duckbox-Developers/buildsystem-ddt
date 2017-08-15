DEPMOD = $(HOST_DIR)/bin/depmod

#
# Patches Kernel 24
#
COMMON_PATCHES_24 = \
		linux-sh4-makefile_stm24.patch \
		linux-stm-gpio-fix-build-CONFIG_BUG.patch \
		linux-kbuild-generate-modules-builtin_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-linuxdvb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sound_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-time_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-init_mm_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-copro_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-strcpy_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ext23_as_ext4_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-bpa2_procfs_stm24_$(KERNEL_LABEL).patch \
		linux-ftdi_sio.c_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lzma-fix_stm24_$(KERNEL_LABEL).patch \
		linux-tune_stm24.patch \
		linux-sh4-permit_gcc_command_line_sections_stm24.patch \
		linux-sh4-mmap_stm24.patch \
		linux-defined_is_deprecated_timeconst.pl_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0217),linux-patch_swap_notify_core_support_stm24_$(KERNEL_LABEL).patch) \
		$(if $(P0209),linux-sh4-dwmac_stm24_$(KERNEL_LABEL).patch)

TF7700_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-tf7700_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-sata-v06_stm24_$(KERNEL_LABEL).patch)

UFS910_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stx7100_fdma_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sata_32bit_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sata_stx7100_B4Team_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ufs910_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-ufs910_reboot_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-smsc911x_dma_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-pcm_noise_fix_stm24_$(KERNEL_LABEL).patch

UFS912_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs912_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch

UFS913_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs913_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch

OCTAGON1008_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-octagon1008_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch

ATEVIO7500_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-atevio7500_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
ATEVIO7500_PATCHES_24 += linux-sh4-atevio7500_mtdconcat_stm24_$(KERNEL_LABEL).patch
endif

HS7110_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7110_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)
ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
HS7110_PATCHES_24 += linux-sh4-hs7110_mtdconcat_stm24_$(KERNEL_LABEL).patch
endif

HS7119_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7119_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)

HS7420_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7420_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)
ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
HS7420_PATCHES_24 += linux-sh4-hs7420_mtdconcat_stm24_$(KERNEL_LABEL).patch
endif

HS7429_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7429_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)

HS7810A_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7810a_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)
ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
HS7810A_PATCHES_24 += linux-sh4-hs7810a_mtdconcat_stm24_$(KERNEL_LABEL).patch
endif

HS7819_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-hs7819_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch)

ATEMIO520_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-atemio520_setup_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch) \
		linux-squashfs-downgrade-stm24_$(KERNEL_LABEL)-to-stm23.patch \
		linux-squashfs3.0_lzma_stm23.patch \
		linux-squashfs-downgrade-stm24-patch-2.6.25 \
		linux-squashfs-downgrade-stm24-rm_d_alloc_anon.patch

ATEMIO530_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-atemio530_setup_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-i2c-stm-downgrade_stm24_$(KERNEL_LABEL).patch) \
		linux-squashfs-downgrade-stm24_$(KERNEL_LABEL)-to-stm23.patch \
		linux-squashfs3.0_lzma_stm23.patch \
		linux-squashfs-downgrade-stm24-patch-2.6.25 \
		linux-squashfs-downgrade-stm24-rm_d_alloc_anon.patch

UFS922_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs922_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-fortis_hdbox_i2c_st40_stm24_$(KERNEL_LABEL).patch

UFC960_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs922_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-fortis_hdbox_i2c_st40_stm24_$(KERNEL_LABEL).patch

HL101_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-hl101_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch

SPARK_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-spark_setup_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-linux_yaffs2_stm24_0209.patch) \
		linux-sh4-lirc_stm_stm24_$(KERNEL_LABEL).patch

SPARK7162_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-spark7162_setup_stm24_$(KERNEL_LABEL).patch

FORTIS_HDBOX_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-fortis_hdbox_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0209),linux-sh4-fortis_hdbox_i2c_st40_stm24_$(KERNEL_LABEL).patch)

ADB_BOX_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stx7100_fdma_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sata_32bit_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-adb_box_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-ufs910_reboot_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-pcm_noise_fix_stm24_$(KERNEL_LABEL).patch

IPBOX9900_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ipbox9900_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_bdinfo_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_dvb_ca_stm24_$(KERNEL_LABEL).patch

IPBOX99_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ipbox99_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_bdinfo_stm24_$(KERNEL_LABEL).patch

IPBOX55_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ipbox55_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_bdinfo_stm24_$(KERNEL_LABEL).patch

CUBEREVO_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_MINI_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_mini_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_MINI2_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_mini2_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_MINI_FTA_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_250HD_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_250hd_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch \
		$(if $(P0217),linux-sh4-cuberevo_250hd_sound_stm24_$(KERNEL_LABEL).patch)

CUBEREVO_2000HD_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_2000hd_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_9500HD_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_9500hd_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

CUBEREVO_3000HD_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-cuberevo_3000hd_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-cuberevo_rtl8201_stm24_$(KERNEL_LABEL).patch

VITAMIN_HD5000_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-vitamin_hd5000_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch

SAGEMCOM88_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-sagemcom88_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sagemcom88_sound_stm24_$(KERNEL_LABEL).patch

ARIVALINK200_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-arivalink200_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_bdinfo_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ipbox_dvb_ca_stm24_$(KERNEL_LABEL).patch

#
# HOST-KERNEL
#
HOST_KERNEL_PATCHES = $(KERNEL_PATCHES_24)
HOST_KERNEL_CONFIG = linux-sh4-$(subst _stm24_,_,$(KERNEL_VERSION))_$(BOXTYPE).config

$(D)/linux-kernel.do_prepare: $(PATCHES)/$(BUILD_CONFIG)/$(HOST_KERNEL_CONFIG) \
	$(if $(HOST_KERNEL_PATCHES),$(HOST_KERNEL_PATCHES:%=$(PATCHES)/$(BUILD_CONFIG)/%))
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	REPO=https://github.com/Duckbox-Developers/linux-sh4-2.6.32.71.git;protocol=https;branch=stmicro; \
	[ -d "$(ARCHIVE)/linux-sh4-2.6.32.71.git" ] && \
	(echo "Updating STlinux kernel source"; cd $(ARCHIVE)/linux-sh4-2.6.32.71.git; git pull;); \
	[ -d "$(ARCHIVE)/linux-sh4-2.6.32.71.git" ] || \
	(echo "Getting STlinux kernel source"; git clone -n $$REPO $(ARCHIVE)/linux-sh4-2.6.32.71.git); \
	(echo "Copying kernel source code to build environment"; cp -ra $(ARCHIVE)/linux-sh4-2.6.32.71.git $(KERNEL_DIR)); \
	(echo "Applying patch level P$(KERNEL_LABEL)"; cd $(KERNEL_DIR); git checkout -q $(HOST_KERNEL_REVISION))
	set -e; cd $(KERNEL_DIR); \
		for i in $(HOST_KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$(BUILD_CONFIG)/$$i; \
		done
	install -m 644 $(PATCHES)/$(BUILD_CONFIG)/$(HOST_KERNEL_CONFIG) $(KERNEL_DIR)/.config
	sed -i "s#^\(CONFIG_EXTRA_FIRMWARE_DIR=\).*#\1\"$(BASE_DIR)/integrated_firmware\"#" $(KERNEL_DIR)/.config
	-rm $(KERNEL_DIR)/localversion*
	echo "$(KERNEL_STM_LABEL)" > $(KERNEL_DIR)/localversion-stm
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2-wlandriver neutrino-wlandriver))
	@echo "Using kernel wireless"
	@grep -v "CONFIG_WIRELESS" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_WIRELESS=y" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_CFG80211 is not set" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_WIRELESS_OLD_REGULATORY is not set" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_WIRELESS_EXT=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_WIRELESS_EXT_SYSFS=y" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_LIB80211 is not set" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_WLAN=y" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_WLAN_PRE80211 is not set" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_WLAN_80211=y" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_LIBERTAS is not set" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_USB_ZD1201 is not set" >> $(KERNEL_DIR)/.config
	@echo "# CONFIG_HOSTAP is not set" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/linux-kernel.do_compile: $(D)/linux-kernel.do_prepare
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh include/asm
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh include/linux/version.h
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- uImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@

$(D)/linux-kernel: $(D)/bootstrap host_u_boot_tools $(D)/linux-kernel.do_compile
	install -m 644 $(KERNEL_DIR)/arch/sh/boot/uImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-sh4-$(KERNEL_VERSION)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-sh4-$(KERNEL_VERSION)
	cp $(KERNEL_DIR)/arch/sh/boot/uImage $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VERSION)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VERSION)/source || true
	$(TOUCH)

$(D)/kernel-headers: $(D)/linux-kernel.do_prepare
	$(START_BUILD)
	cd $(KERNEL_DIR); \
		install -d $(TARGET_DIR)/usr/include
		cp -a include/linux $(TARGET_DIR)/usr/include
		cp -a include/asm-sh $(TARGET_DIR)/usr/include/asm
		cp -a include/asm-generic $(TARGET_DIR)/usr/include
		cp -a include/mtd $(TARGET_DIR)/usr/include
	$(TOUCH)

linux-kernel-distclean:
	rm -f $(D)/linux-kernel
	rm -f $(D)/linux-kernel.do_compile
	rm -f $(D)/linux-kernel.do_prepare

linux-kernel-clean:
	-$(MAKE) -C $(KERNEL_DIR) clean
	rm -f $(D)/linux-kernel
	rm -f $(D)/linux-kernel.do_compile

#
# TF7700 installer
#
TFINSTALLER_DIR := $(BASE_DIR)/tfinstaller

tfinstaller: $(D)/bootstrap $(TFINSTALLER_DIR)/u-boot.ftfd $(D)/linux-kernel
	$(START_BUILD)
	$(MAKE) $(MAKE_OPTS) -C $(TFINSTALLER_DIR) HOST_DIR=$(HOST_DIR) BASE_DIR=$(BASE_DIR) KERNEL_DIR=$(KERNEL_DIR)
	$(TOUCH)

$(TFINSTALLER_DIR)/u-boot.ftfd: $(D)/uboot $(TFINSTALLER_DIR)/tfpacker
	$(START_BUILD)
	$(TFINSTALLER_DIR)/tfpacker $(BUILD_TMP)/u-boot-$(U_BOOT_VERSION)/u-boot.bin $(TFINSTALLER_DIR)/u-boot.ftfd
	$(TFINSTALLER_DIR)/tfpacker -t $(BUILD_TMP)/u-boot-$(U_BOOT_VERSION)/u-boot.bin $(TFINSTALLER_DIR)/Enigma_Installer.tfd
	$(REMOVE)/u-boot-$(U_BOOT_VERSION)
	$(TOUCH)

$(TFINSTALLER_DIR)/tfpacker:
	$(START_BUILD)
	$(MAKE) -C $(TFINSTALLER_DIR) tfpacker
	$(TOUCH)

$(D)/tfkernel:
	$(START_BUILD)
	cd $(KERNEL_DIR); \
		$(MAKE) $(if $(TF7700),TF7700=y) ARCH=sh CROSS_COMPILE=$(TARGET)- uImage
	$(TOUCH)

#
# u-boot
#
UBOOT_VERSION = 1.3.1
UBOOT_PATCH  =  u-boot-$(UBOOT_VERSION).patch
ifeq ($(BOXTYPE), tf7700)
UBOOT_PATCH += u-boot-$(UBOOT_VERSION)-tf7700.patch
endif

$(ARCHIVE)/u-boot-$(UBOOT_VERSION).tar.bz2:
	$(WGET) ftp://ftp.denx.de/pub/u-boot/u-boot-$(U_BOOT_VERSION).tar.bz2

$(D)/uboot: bootstrap $(ARCHIVE)/u-boot-$(UBOOT_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/u-boot-$(UBOOT_VERSION)
	$(UNTAR)/u-boot-$(UBOOT_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/u-boot-$(UBOOT_VERSION); \
		$(call post_patch,$(UBOOT_PATCH)); \
		$(MAKE) $(BOXTYPE)_config; \
		$(MAKE)
#	$(REMOVE)/u-boot-$(UBOOT_VERSION)
	$(TOUCH)

#
# Helper
#
linux-kernel.menuconfig linux-kernel.xconfig: \
linux-kernel.%:
	$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/$(BUILD_CONFIG)/$(HOST_KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
