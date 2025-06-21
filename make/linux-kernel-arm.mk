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

DM900_PATCHES = \
		armbox/dm900/linux-dreambox-3.14-6fa88d2001194cbff63ad94cb713b6cd5ea02739.patch \
		armbox/dm900/kernel-fake-3.14.patch \
		armbox/dm900/dvbs2x.patch \
		armbox/dm900/0001-Support-TBS-USB-drivers.patch \
		armbox/dm900/0001-STV-Add-PLS-support.patch \
		armbox/dm900/0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/dm900/0001-stv090x-optimized-TS-sync-control.patch \
		armbox/dm900/genksyms_fix_typeof_handling.patch \
		armbox/dm900/blindscan2.patch \
		armbox/dm900/0001-tuners-tda18273-silicon-tuner-driver.patch \
		armbox/dm900/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		armbox/dm900/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		armbox/dm900/0003-cxusb-Geniatech-T230-support.patch \
		armbox/dm900/CONFIG_DVB_SP2.patch \
		armbox/dm900/dvbsky.patch \
		armbox/dm900/rtl2832u-2.patch \
		armbox/dm900/0004-log2-give-up-on-gcc-constant-optimizations.patch \
		armbox/dm900/0005-uaccess-dont-mark-register-as-const.patch \
		armbox/dm900/0006-makefile-silence-packed-not-aligned-warn.patch \
		armbox/dm900/0007-overlayfs.patch \
		armbox/dm900/move-default-dialect-to-SMB3.patch \
		armbox/dm900/fix-multiple-defs-yyloc.patch \
		armbox/dm900/fix-build-with-binutils-2.41.patch

DM920_PATCHES = \
		$(DM900_PATCHES)

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
		armbox/vuplus_common/3_14_kernel-add-support-for-gcc14.patch \
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
		armbox/vuplus_common/4_1_kernel-add-support-for-gcc14.patch \
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

DCUBE_PATCHES = \
		armbox/dcube/100-arm-linux.patch \
		armbox/dcube/101-apollo_stb.patch \
		armbox/dcube/102-unionfs-2.5.4.patch \
		armbox/dcube/103-apollo_usb.patch \
		armbox/dcube/104-apollo_spi_callbackfix.patch \
		armbox/dcube/105-apollo_sata_fuse_fix.patch \
		armbox/dcube/106-kronos_stb.patch \
		armbox/dcube/107-apollo_linux_warning_fix.patch \
		armbox/dcube/108-apollo_spi_dmac_rf4cefix.patch \
		armbox/dcube/109-apollo_serialwrapperfix.patch \
		armbox/dcube/110-apollo_sfc_div_u64_fix.patch \
		armbox/dcube/111-apollo_mtd_define_fix.patch \
		armbox/dcube/112-apollo_usb_code_from_28kernel.patch \
		armbox/dcube/113-apollo_active_standby.patch \
		armbox/dcube/114-apollo_sfc32M.patch \
		armbox/dcube/115-apollo_sfc_jffs2_fix.patch \
		armbox/dcube/116-apollo_ip3106_kgdb.patch \
		armbox/dcube/117-apollo_sfc_jffs2_32M.patch \
		armbox/dcube/118-apollo_syscall.patch \
		armbox/dcube/119-apollo_perf_events.patch \
		armbox/dcube/120-apollo_cortexa9_errata.patch \
		armbox/dcube/121-apollo_bzImage_support.patch \
		armbox/dcube/122-apollo_cortexa9_freq_detect.patch \
		armbox/dcube/123-apollo_usb_ehci_handlers.patch \
		armbox/dcube/124-apollo_iic_greset_fix.patch \
		armbox/dcube/125-apollo-otg_redesign.patch \
		armbox/dcube/126-apollo_various_fixes.patch \
		armbox/dcube/127-apollo_squashfs_lzma.patch \
		armbox/dcube/128-apollo_gcc_4.5_support.patch \
		armbox/dcube/129-apollo_kronos_emu.patch \
		armbox/dcube/130-apollo_ethernet_AnDSP_changes.patch \
		armbox/dcube/131-apollo_thumb2_support.patch \
		armbox/dcube/132-apollo-mtd_devices.patch \
		armbox/dcube/133-apollo-numonyx_flash.patch \
		armbox/dcube/135-apollo-spi_gp500.patch \
		armbox/dcube/136-apollo-gpio_apis.patch \
		armbox/dcube/137-apollo_chip_rev_detect.patch \
		armbox/dcube/138-apollo_sfc_quad_mode.patch \
		armbox/dcube/139-apollo_usb_gadget_fshs.patch \
		armbox/dcube/140-kronos_i2c.patch \
		armbox/dcube/141-apollo_usb_gadget_flag_cleanup.patch \
		armbox/dcube/142-kronos_usb.patch \
		armbox/dcube/143-apollo_sfc8M.patch \
		armbox/dcube/144-nand_pagesize.patch \
		armbox/dcube/145-apollo_usb_gadget_plugfest_fixes.patch \
		armbox/dcube/146-apollo_usb_no_otg_usbcv_fix.patch \
		armbox/dcube/147-apollo_gmac0_rgmii.patch \
		armbox/dcube/148-apollo_usb_vid_pid_fix.patch \
		armbox/dcube/149-apollo_uart_isr.patch \
		armbox/dcube/150-apollo_macronix_sfc_quad_mode.patch \
		armbox/dcube/151-apollo_find_next_zero_bit.patch \
		armbox/dcube/152-apollo_usb_host_tpl.patch \
		armbox/dcube/153-apollo_nand4k.patch \
		armbox/dcube/154-apollo_network_config.patch \
		armbox/dcube/155-apollo_bzImage_lzma.patch \
		armbox/dcube/156-apollo_sdio_pci_support.patch \
		armbox/dcube/157-apollo_linux_dvb_extension.patch \
		armbox/dcube/158-kronos_bzImage.patch \
		armbox/dcube/159-apollo_onfi_nand_support.patch \
		armbox/dcube/160-apollo_usb_reset_fix.patch \
		armbox/dcube/161-apollo_sfc_macronix_dma.patch \
		armbox/dcube/162-apollo_arm_errata.patch \
		armbox/dcube/163-apollo_nand_onfi_chipsize.patch \
		armbox/dcube/164-kronos_nand.patch \
		armbox/dcube/165-kronos_sdio.patch \
		armbox/dcube/166-apollo_nand_block_erase_err.patch \
		armbox/dcube/167-apollo_mtd_nand_bbt.patch \
		armbox/dcube/168-kronos_mmioaddr.patch \
		armbox/dcube/169-kronos_gpioconfig.patch \
		armbox/dcube/170-kronos_nor_dma_config.patch \
		armbox/dcube/171-kronos_usb_bringup.patch \
		armbox/dcube/172-kronos_gmac.patch \
		armbox/dcube/173-kronos_gpio.patch \
		armbox/dcube/174-kronos_sfc_ext_id.patch \
		armbox/dcube/175-kronos_l2cache.patch \
		armbox/dcube/176-kronos_nand_bringup.patch \
		armbox/dcube/177-apollo_uart_dma.patch \
		armbox/dcube/178-kronos_sata_bringup.patch \
		armbox/dcube/179-kronos_spi_bringup.patch \
		armbox/dcube/181-krome_stb.patch \
		armbox/dcube/182-kronos_active_stby.patch \
		armbox/dcube/183-apollo_sdio_versionfix.patch \
		armbox/dcube/184-kronos_sdio_bringup.patch \
		armbox/dcube/185-kronos_mmc_subsys_2.6.39.1.patch \
		armbox/dcube/186-kronos_rtc.patch \
		armbox/dcube/187-kronos_active_standby_irq_fix.patch \
		armbox/dcube/188-kronos_sdio_wr_fix.patch \
		armbox/dcube/189-apollo_dcs_bus_ntwk_driver.patch \
		armbox/dcube/190-apollo_kronos_eth_leak.patch \
		armbox/dcube/191-kronos_splash_screen.patch \
		armbox/dcube/192-apollo_nand_224B_oob.patch \
		armbox/dcube/193-krome_affinity_symbol_export.patch \
		armbox/dcube/194-krome_ep_build.patch \
		armbox/dcube/195-krome_ep_bringup.patch \
		armbox/dcube/196-krome_gmac0_base.patch \
		armbox/dcube/197-krome_active_stby.patch \
		armbox/dcube/198-krome_sdio_bringup.patch \
		armbox/dcube/199-krome_a9_clk_fix.patch \
		armbox/dcube/200-krome_dualcore.patch \
		armbox/dcube/202-kronos_krome_nand_ecc.patch \
		armbox/dcube/203-krome_uart_fix.patch \
		armbox/dcube/204-kronos-krome_sfc_quadread.patch \
		armbox/dcube/205-krome_gmac_timer_fix.patch \
		armbox/dcube/206-apollo_gpl_header.patch \
		armbox/dcube/207-krome_gpio.patch \
		armbox/dcube/208-sfc_micron_quad_mode.patch \
		armbox/dcube/209-i2c_locking.patch \
		armbox/dcube/210-kronos_sddata4_7_pins_disable.patch \
		armbox/dcube/211-nand_oob_write.patch \
		armbox/dcube/212-kronos-krome_detect_arm_freq.patch \
		armbox/dcube/213-kronos-krome_nand_224oob.patch \
		armbox/dcube/214-kronos-krome_vmalloc_increase.patch \
		armbox/dcube/215-kronos_active_standby_fix.patch \
		armbox/dcube/216-krome_sdio_cdwp_cfg.patch \
		armbox/dcube/217-kronos-krome_nand_read_uldr.patch \
		armbox/dcube/218-kronos-krome_highmem_support.patch \
		armbox/dcube/219-kronos-krome_rev.patch \
		armbox/dcube/220-kronos-krome_max_vmalloc_area.patch \
		armbox/dcube/221-kronos-krome_gmac_lnkstatusint.patch \
		armbox/dcube/222-kronos_print_cortexa9_freq.patch \
		armbox/dcube/223-apollo_sata_coherency_issue_fix.patch \
		armbox/dcube/224-kronosrevb_krome_splash.patch \
		armbox/dcube/225-krome-balboa.patch \
		armbox/dcube/226-krome_print_arm_freq.patch \
		armbox/dcube/227-sd_fallback_normalspeed.patch \
		armbox/dcube/228-kronos-krome_8k_nand.patch \
		armbox/dcube/229-splashlogo_sfc_mx_spi.patch \
		armbox/dcube/230-splashlogo.patch \
		armbox/dcube/231-krome_spi_fix.patch \
		armbox/dcube/232-krome_gmac_fix.patch \
		armbox/dcube/233-krome_splash_fix.patch \
		armbox/dcube/234-ethtool_fix.patch \
		armbox/dcube/235-l2cache_errata.patch \
		armbox/dcube/236-usb_sata_coherency_issue_fix.patch \
		armbox/dcube/237-kronos-krome_mmc.patch \
		armbox/dcube/238-kronos_sata_phy_tuning.patch \
		armbox/dcube/239-kore3_stb.patch \
		armbox/dcube/240-krome_dualcore_mod.patch \
		armbox/dcube/241_krome_dual_sd.patch \
		armbox/dcube/242_moca_loopback.patch \
		armbox/dcube/243-kronos-krome_mem_barriers.patch \
		armbox/dcube/244-usb_sata_coherancy_issue_fix_mod.patch \
		armbox/dcube/245-console_corruption_fix.patch \
		armbox/dcube/246-gmac_flowcontrol.patch \
		armbox/dcube/247-moca_SIOCTOGEXTCLKEN_add.patch \
		armbox/dcube/248-apollo_mem_barriers.patch \
		armbox/dcube/249-apollo_sata_coherancy_issue_fix_mod.patch \
		armbox/dcube/250-gmac_packetloss_memoryleak_fix.patch \
		armbox/dcube/251-arm_user_cache_flush_fix.patch \
		armbox/dcube/252-en256x_standby.patch \
		armbox/dcube/253-splash_newlogo.patch \
		armbox/dcube/254-gmac-dma_fixes.patch \
		armbox/dcube/255-kore3_bringup.patch \
		armbox/dcube/256-sd_suspend_resume.patch \
		armbox/dcube/257-sfc_write_sr_fix.patch \
		armbox/dcube/258-moca_loopback_ret.patch \
		armbox/dcube/259-mmc_csd_struct_v3.patch \
		armbox/dcube/260-kore3_bringup2.patch \
		armbox/dcube/261-sfc_32b_mx_spa.patch \
		armbox/dcube/262-ephy_powerdown.patch \
		armbox/dcube/263-kronos-krome_splash_fix.patch \
		armbox/dcube/300-dmxdev-unblock-read-on-ioctl.patch \
		armbox/dcube/0001-kernel-add-support-for-gcc-5.patch \
		armbox/dcube/fix_return_address_warning.patch \
		armbox/dcube/rtl8712-fix-warnings.patch \
		armbox/dcube/rtl8187se-fix-warnings.patch \
		armbox/dcube/kernel-add-support-for-gcc6.patch \
		armbox/dcube/kernel-add-support-for-gcc7.patch \
		armbox/dcube/kernel-add-support-for-gcc8.patch \
		armbox/dcube/kernel-add-support-for-gcc9.patch \
		armbox/dcube/timeconst_perl5.patch \
		armbox/dcube/0001-dvb_frontend-backport-multistream-support.patch \
		armbox/dcube/log2.patch \
		armbox/dcube/makefile-remove-wall.patch \
		armbox/dcube/uaccess-dont-mark-register-as-const.patch \
		armbox/dcube/compiler-gcc-h-handle-uninitialized-var.patch \
		armbox/dcube/rtl8152.patch \
		armbox/dcube/kernel-linuxdvb_53.patch

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

ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 15.1.0))
GCC15PARM  = CFLAGS_KERNEL="-std=gnu99 -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types"
GCC15PARM += CFLAGS_MODULE="-std=gnu99 -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types"
endif

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k dm900 dm920 dcube))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $(GCC15PARM) $(KERNEL_DTB_VER) zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $(GCC15PARM) DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k dm900 dm920 dcube))
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), dcube))
	cat $(KERNEL_DIR)/arch/arm/boot/zImage $(KERNEL_DIR)/arch/arm/boot/dts/$(KERNEL_DTB_VER) > $(TARGET_DIR)/boot/zImage.dtb
endif
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
