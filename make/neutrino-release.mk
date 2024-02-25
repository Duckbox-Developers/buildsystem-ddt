#
# auxiliary targets for model-specific builds
#

#
# release_cube_common
#
neutrino-release-cube_common:
	install -m 0755 $(SKEL_ROOT)/release/halt_cuberevo $(RELEASE_DIR)/etc/init.d/halt
	install -m 0777 $(SKEL_ROOT)/release/reboot_cuberevo $(RELEASE_DIR)/etc/init.d/reboot
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx24116.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# release_cube_common_tuner
#
neutrino-release-cube_common_tuner:
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/media/dvb/frontends/dvb-pll.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_2000hd
#
neutrino-release-cuberevo_2000hd: neutrino-release-cube_common neutrino-release-cube_common_tuner

#
# cuberevo_250hd
#
neutrino-release-cuberevo_250hd: neutrino-release-cube_common neutrino-release-cube_common_tuner

# cuberevo_mini2
#
neutrino-release-cuberevo_mini2: neutrino-release-cube_common neutrino-release-cube_common_tuner

#
# cuberevo_mini
#
neutrino-release-cuberevo_mini: neutrino-release-cube_common neutrino-release-cube_common_tuner

#
# cuberevo
#
neutrino-release-cuberevo: neutrino-release-cube_common neutrino-release-cube_common_tuner

#
# cuberevo_3000hd
#
neutrino-release-cuberevo_3000hd: neutrino-release-cube_common neutrino-release-cube_common_tuner

#
# common_ipbox
#
neutrino-release-common_ipbox:
	install -m 0755 $(SKEL_ROOT)/release/halt_ipbox $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/siinfo/siinfo.ko $(RELEASE_DIR)/lib/modules/
	cp -f $(SKEL_ROOT)/release/fstab_ipbox $(RELEASE_DIR)/etc/fstab
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/as102_data1_st.hex $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/as102_data2_st.hex $(RELEASE_DIR)/lib/firmware/
	cp -dp $(SKEL_ROOT)/release/lircd_ipbox.conf $(RELEASE_DIR)/etc/lircd.conf
	rm -f $(RELEASE_DIR)/lib/firmware/*
	rm -f $(RELEASE_DIR)/lib/modules/boxtype.ko
	rm -f $(RELEASE_DIR)/etc/network/interfaces

#
# ipbox9900
#
neutrino-release-ipbox9900: neutrino-release-common_ipbox
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox99xx/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/rmu/rmu.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ipbox99xx_fan/ipbox_fan.ko $(RELEASE_DIR)/lib/modules/
	cp -p $(SKEL_ROOT)/release/tvmode_ipbox $(RELEASE_DIR)/usr/bin/tvmode

#
# ipbox99
#
neutrino-release-ipbox99: neutrino-release-common_ipbox
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox99xx/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ipbox99xx_fan/ipbox_fan.ko $(RELEASE_DIR)/lib/modules/
	cp -p $(SKEL_ROOT)/release/tvmode_ipbox $(RELEASE_DIR)/usr/bin/tvmode

#
# ipbox55
#
neutrino-release-ipbox55: neutrino-release-common_ipbox
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox55/front.ko $(RELEASE_DIR)/lib/modules/
	cp -p $(SKEL_ROOT)/release/tvmode_ipbox55 $(RELEASE_DIR)/usr/bin/tvmode

#
# ufs910
#
neutrino-release-ufs910:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/vfd/vfd.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7100.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7100.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/dvb-fe-cx24116.fw
	cp -dp $(SKEL_ROOT)/release/lircd_ufs910.conf $(RELEASE_DIR)/etc/lircd.conf
	rm -f $(RELEASE_DIR)/bin/vdstandby

#
# ufs912
#
neutrino-release-ufs912:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# ufs913
#
neutrino-release-ufs913:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/

#
# ufs922
#
neutrino-release-ufs922:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ufs922_fan/fan_ctrl.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# spark
#
neutrino-release-spark:
	install -m 0755 $(SKEL_ROOT)/release/halt_spark $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/aotom_spark/aotom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw
	rm -f $(RELEASE_DIR)/bin/vdstandby
	cp -dp $(SKEL_ROOT)/release/lircd_spark.conf $(RELEASE_DIR)/etc/lircd.conf

#
# spark7162
#
neutrino-release-spark7162:
	install -m 0755 $(SKEL_ROOT)/release/halt_spark7162 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/aotom_spark/aotom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp -f $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/i2c_spi/i2s.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	rm -f $(RELEASE_DIR)/bin/vdstandby
	cp -dp $(SKEL_ROOT)/release/lircd_spark7162.conf $(RELEASE_DIR)/etc/lircd.conf
	cp $(SKEL_ROOT)/release/fw_env.config_$(BOXTYPE)_neutrino $(RELEASE_DIR)/etc/fw_env.config

#
# fortis_hdbox
#
neutrino-release-fortis_hdbox:
	install -m 0755 $(SKEL_ROOT)/release/halt_fortis_hdbox $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf

#
# atevio7500
#
neutrino-release-atevio7500:
	install -m 0755 $(SKEL_ROOT)/release/halt_fortis_hdbox $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/
	rm -f $(RELEASE_DIR)/lib/modules/boxtype.ko
	rm -f $(RELEASE_DIR)/lib/modules/mpeg2hw.ko

#
# octagon1008
#
neutrino-release-octagon1008:
	install -m 0755 $(SKEL_ROOT)/release/halt_octagon1008 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# tf7700
#
neutrino-release-tf7700:
	install -m 0755 $(SKEL_ROOT)/release/halt_tf7700 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/tffp/tffp.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx24116.fw $(RELEASE_DIR)/lib/firmware/
	cp -f $(SKEL_ROOT)/release/fstab_tf7700 $(RELEASE_DIR)/etc/fstab
	$(MAKE) tfinstaller

#
# WWIO Bre2ze4k
#
neutrino-release-bre2ze4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# Mutant HD51
#
neutrino-release-hd51:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# Zgemma H7
#
neutrino-release-h7:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# E4HD 4K Ultra
#
neutrino-release-e4hdultra:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	install -m 0644 $(SKEL_ROOT)/release/lcdsplash.bmp $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/

#
# vuduo4k
#
neutrino-release-vuduo4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo4k $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo4k $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7278b1 $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7278b1 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/bp3flash.sh $(RELEASE_DIR)/usr/bin/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuduo4kse
#
neutrino-release-vuduo4kse:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo4kse $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo4kse $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7445d0_vuduo4kse $(RELEASE_DIR)/boot/vmlinuz-initrd-7445d0
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7445d0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuuno4kse
#
neutrino-release-vuuno4kse:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuuno4kse $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuuno4kse $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7439b0_se $(RELEASE_DIR)/boot/vmlinuz-initrd-7439b0
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7439b0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuzero4k
#
neutrino-release-vuzero4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuzero4k $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuzero4k $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7260a0 $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7260a0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuultimo4k
#
neutrino-release-vuultimo4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuultimo4k $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuultimo4k $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7445d0 $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7445d0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuuno4k
#
neutrino-release-vuuno4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuuno4k $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuuno4k $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7439b0 $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7439b0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vusolo4k
#
neutrino-release-vusolo4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_vusolo4k $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vusolo4k $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko
ifeq ($(VU_MULTIBOOT), 1)
	cp $(SKEL_ROOT)/release/vmlinuz-initrd-7366c0 $(RELEASE_DIR)/boot/
else
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7366c0 $(RELEASE_DIR)/boot/
endif
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	cp -f $(SKEL_ROOT)/release/nvram $(RELEASE_DIR)/usr/bin/

#
# vuduo
#
neutrino-release-vuduo:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
#	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/

#
# vuduo2
#
neutrino-release-vuduo2:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuduo2 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuduo2 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
#	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko

#
# vuuno
#
neutrino-release-vuuno:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuuno $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuuno $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
#	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko

#
# vuultimo
#
neutrino-release-vuultimo:
	install -m 0755 $(SKEL_ROOT)/release/halt_vuultimo $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_vuultimo $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
#	cp $(TARGET_DIR)/boot/kernel_cfe_auto.bin $(RELEASE_DIR)/boot/
	rm -f $(RELEASE_DIR)/lib/modules/fpga_directc.ko

#
# dm8000
#
neutrino-release-dm8000:
	install -m 0755 $(SKEL_ROOT)/release/halt_dm8000 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/release/fstab_dm8000 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-dm8000/extra/*.ko $(RELEASE_DIR)/lib/modules/

python-iptv-install:
	install -d $(RELEASE_DIR)/usr/bin; \
	install -d $(RELEASE_DIR)/usr/include; \
	install -d $(RELEASE_DIR)/usr/lib; \
	install -d $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	install -d $(RELEASE_DIR)/$(PYTHON_DIR); \
	cp $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)/pyconfig.h $(RELEASE_DIR)/$(PYTHON_INCLUDE_DIR); \
	cp -P $(TARGET_LIB_DIR)/libpython* $(RELEASE_DIR)/usr/lib; \
	cp -P $(TARGET_DIR)/usr/bin/python* $(RELEASE_DIR)/usr/bin; \
	cp -a $(TARGET_DIR)/$(PYTHON_DIR)/* $(RELEASE_DIR)/$(PYTHON_DIR)/; \
	cp -af $(TARGET_DIR)/usr/share/E2emulator $(RELEASE_DIR)/usr/share/; \
	ln -sf /usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/cmdlineIPTV.sh $(RELEASE_DIR)/usr/bin/cmdlineIPTV; \
	rm -f $(RELEASE_DIR)/usr/bin/{cftp,ckeygen,easy_install*,mailmail,pyhtmlizer,tkconch,trial,twist,twistd}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{bsddb,compiler,curses,distutils,email,ensurepip,hotshot,idlelib,lib2to3}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/lib-dynload/*-py$(PYTHON_VER_MAJOR).egg-info
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/{lib-old,lib-tk,multiprocessing,plat-linux2,pydoc_data,sqlite3,unittest,wsgiref}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/*-py$(PYTHON_VER_MAJOR).egg-info
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/setuptools
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{application,conch,cred,enterprise,flow,lore,mail,names,news,pair,persisted}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/{plugins,positioning,runner,scripts,spread,tap,_threads,trial,web,words}
	rm -rf $(RELEASE_DIR)/$(PYTHON_DIR)/site-packages/twisted/python/_pydoctortemplates
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ $(RELEASE_DIR)/usr/share/E2emulator/ \
		\( -name '*.a' \
		-o -name '*.c' \
		-o -name '*.doc' \
		-o -name '*.la' \
		-o -name '*.o' \
		-o -name '*.pyc' \
		-o -name '*.pyx' \
		-o -name 'test' \
		-o -name 'tests' \) \
		-print0 | xargs --no-run-if-empty -0 rm -rf
ifeq ($(OPTIMIZATIONS), size)
	find $(RELEASE_DIR)/$(PYTHON_DIR)/ -name '*.py' -exec rm -f {} \;
	find $(RELEASE_DIR)/usr/share/E2emulator/ -name '*.py' -exec rm -f {} \;
endif

#
# neutrino-release-base
#
# the following target creates the common file base
neutrino-release-base:
	rm -rf $(RELEASE_DIR) || true
	install -d $(RELEASE_DIR)
	install -d $(RELEASE_DIR)/{autofs,bin,boot,dev,dev.static,etc,hdd,lib,media,mnt,proc,ram,root,sbin,swap,sys,tmp,usr,var}
	install -d $(RELEASE_DIR)/etc/{init.d,network,mdev,ssl}
	install -d $(RELEASE_DIR)/etc/network/if-{post-{up,down},pre-{up,down},up,down}.d
	install -d $(RELEASE_DIR)/lib/{modules,udev,firmware,tuxbox}
	install -d $(RELEASE_DIR)/media/{dvd,nfs,usb,sda1,sdb1}
	ln -sf /hdd $(RELEASE_DIR)/media/hdd
	install -d $(RELEASE_DIR)/mnt/{hdd,nfs,usb}
	install -d $(RELEASE_DIR)/mnt/mnt{0..7}
	install -d $(RELEASE_DIR)/usr/{bin,lib,sbin,share}
	install -d $(RELEASE_DIR)/usr/share/{fonts,tuxbox,udhcpc,zoneinfo,lua}
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/logo
	install -d $(RELEASE_DIR)/usr/share/lua/5.2
	install -d $(RELEASE_DIR)/var/{bin,boot,emu,etc,epg,httpd,keys,lib,logos,net,tuxbox,update}
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	install -d $(RELEASE_DIR)/var/lib/{nfs,modules,opkg}
else
	install -d $(RELEASE_DIR)/var/lib/{nfs,modules}
endif
	install -d $(RELEASE_DIR)/var/net/epg
	install -d $(RELEASE_DIR)/var/tuxbox/{config,control,locale,plugins,themes}
	install -d $(RELEASE_DIR)/var/tuxbox/webtv
	install -d $(RELEASE_DIR)/var/tuxbox/config/{webtv,zapit}
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc0.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc0.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc0.d/S40umountfs
	ln -s ../init.d/halt $(RELEASE_DIR)/etc/rc.d/rc0.d/S90halt
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc6.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc6.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc6.d/S40umountfs
	ln -s ../init.d/reboot $(RELEASE_DIR)/etc/rc.d/rc6.d/S90reboot
	ln -sf usr/share $(RELEASE_DIR)/share
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/logos
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/var/httpd/logos
	touch $(RELEASE_DIR)/var/etc/.firstboot
	cp -a $(TARGET_DIR)/bin/* $(RELEASE_DIR)/bin/
	cp -a $(TARGET_DIR)/usr/bin/* $(RELEASE_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/sbin/* $(RELEASE_DIR)/sbin/
	cp -a $(TARGET_DIR)/usr/sbin/* $(RELEASE_DIR)/usr/sbin/
	cp -dp $(TARGET_DIR)/.version $(RELEASE_DIR)/
	ln -sf /.version $(RELEASE_DIR)/var/etc/.version
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuuno vuultimo))
	cp $(TARGET_DIR)/boot/$(KERNELNAME) $(RELEASE_DIR)/boot/
endif
	ln -sf /proc/mounts $(RELEASE_DIR)/etc/mtab
	cp -dp $(SKEL_ROOT)/sbin/MAKEDEV $(RELEASE_DIR)/sbin/
	ln -sf ../sbin/MAKEDEV $(RELEASE_DIR)/dev/MAKEDEV
	ln -sf ../../sbin/MAKEDEV $(RELEASE_DIR)/lib/udev/MAKEDEV
	cp -aR $(SKEL_ROOT)/etc/mdev/* $(RELEASE_DIR)/etc/mdev/
	cp -aR $(SKEL_ROOT)/etc/mdev_$(BOXARCH).conf $(RELEASE_DIR)/etc/mdev.conf
	cp -aR $(SKEL_ROOT)/usr/share/udhcpc/* $(RELEASE_DIR)/usr/share/udhcpc/
	cp -aR $(SKEL_ROOT)/usr/share/zoneinfo/* $(RELEASE_DIR)/usr/share/zoneinfo/
	cp $(SKEL_ROOT)/bin/autologin $(RELEASE_DIR)/bin/
	cp $(SKEL_ROOT)/bin/vdstandby $(RELEASE_DIR)/bin/
	cp $(SKEL_ROOT)/usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/
	cp -aR $(TARGET_DIR)/etc/init.d/* $(RELEASE_DIR)/etc/init.d/
	cp -aR $(TARGET_DIR)/etc/* $(RELEASE_DIR)/etc/
	echo "$(BOXTYPE)" > $(RELEASE_DIR)/etc/hostname
	ln -sf ../../bin/busybox $(RELEASE_DIR)/usr/bin/ether-wake
	ln -sf ../../bin/showiframe $(RELEASE_DIR)/usr/bin/showiframe
	ln -sf ../../usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/fw_setenv
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 fortis_hdbox octagon1008 ufs910 ufs912 ufs913 ufs922 spark ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd tf7700))
	cp $(SKEL_ROOT)/release/fw_env.config_$(BOXTYPE) $(RELEASE_DIR)/etc/fw_env.config
endif
	install -m 0755 $(SKEL_ROOT)/release/rcS_neutrino_$(BOXTYPE) $(RELEASE_DIR)/etc/init.d/rcS
#
#
################################################################################
ifeq ($(BOXARCH), sh4)
################################################################################
#
# player
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko $(RELEASE_DIR)/lib/modules/ || true
	cd $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra && \
	for mod in \
		sound/pseudocard/pseudocard.ko \
		sound/silencegen/silencegen.ko \
		stm/mmelog/mmelog.ko \
		stm/monitor/stm_monitor.ko \
		media/dvb/stm/dvb/stmdvb.ko \
		sound/ksound/ksound.ko \
		media/dvb/stm/mpeg2_hard_host_transformer/mpeg2hw.ko \
		media/dvb/stm/backend/player2.ko \
		media/dvb/stm/h264_preprocessor/sth264pp.ko \
		media/dvb/stm/allocator/stmalloc.ko \
		stm/platform/platform.ko \
		stm/platform/p2div64.ko \
		media/sysfs/stm/stmsysfs.ko \
	;do \
		if [ -e player2/linux/drivers/$$mod ]; then \
			cp player2/linux/drivers/$$mod $(RELEASE_DIR)/lib/modules/; \
			$(TARGET)-strip --strip-unneeded $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		else \
			touch $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		fi; \
	done
#
# modules
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko $(RELEASE_DIR)/lib/modules/ || true
#
# multicom 324
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko $(RELEASE_DIR)/lib/modules/ || true
#
#
#
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/simu_button/simu_button.ko $(RELEASE_DIR)/lib/modules/
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cic/*.ko $(RELEASE_DIR)/lib/modules/
endif
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko $(RELEASE_DIR)/lib/modules/ || true
#
# wlan
#
ifeq ($(IMAGE), neutrino-wlandriver)
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/mt7601u/mt7601Usta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/mt7601u/mt7601Usta.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt2870sta/rt2870sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt2870sta/rt2870sta.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt3070sta/rt3070sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt3070sta/rt3070sta.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt5370sta/rt5370sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt5370sta/rt5370sta.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl871x/8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl871x/8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8188eu/8188eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8188eu/8188eu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192cu/8192cu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192cu/8192cu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192du/8192du.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192du/8192du.ko $(RELEASE_DIR)/lib/modules/ || true
endif
endif
#
#
################################################################################
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
################################################################################
#
#
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ftdi_sio.ko || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko $(RELEASE_DIR)/lib/modules/ || true
ifeq ($(BOXTYPE), dm8000)
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ftdi_sio.ko || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/cp210x.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/usb/serial/cp210x.ko $(RELEASE_DIR)/lib/modules/ || true
endif
#
# wlan
#
ifeq ($(IMAGE), neutrino-wlandriver)
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8188eu/r8188eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8188eu/r8188eu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/wireless/cfg80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/wireless/cfg80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/rfkill/rfkill.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/rfkill/rfkill.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/mac80211/mac80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/mac80211/mac80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko $(RELEASE_DIR)/lib/modules/ || true
ifeq ($(BOXTYPE), dm8000)
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8188eu/r8188eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8188eu/r8188eu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/wireless/cfg80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/wireless/cfg80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/rfkill/rfkill.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/rfkill/rfkill.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/mac80211/mac80211.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/net/mac80211/mac80211.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtlwifi.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192c/rtl8192c-common.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rtl8192cu.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8712/r8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8712/r8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/staging/rtl8192u/r8192u_usb.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/kernel/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko $(RELEASE_DIR)/lib/modules/ || true
endif
endif
endif
#
#
################################################################################
#
# wlan firmware
#
ifeq ($(IMAGE), neutrino-wlandriver)
	install -d $(RELEASE_DIR)/etc/Wireless
	cp -aR $(SKEL_ROOT)/firmware/Wireless/* $(RELEASE_DIR)/etc/Wireless/
	cp -aR $(SKEL_ROOT)/firmware/rtlwifi $(RELEASE_DIR)/lib/firmware/
	cp -aR $(SKEL_ROOT)/firmware/*.bin $(RELEASE_DIR)/lib/firmware/
endif
#
# modules.available
#
	cp -aR $(SKEL_ROOT)/release/modules.available_$(BOXARCH) $(RELEASE_DIR)/etc/modules.available
#
# lib usr/lib
#
	cp -R $(TARGET_DIR)/lib/* $(RELEASE_DIR)/lib/
	rm -f $(RELEASE_DIR)/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/lib/*
	ln -s /var/tuxbox/plugins/libfx2.so $(RELEASE_DIR)/lib/libfx2.so
	cp -R $(TARGET_LIB_DIR)/* $(RELEASE_DIR)/usr/lib/
	rm -rf $(RELEASE_DIR)/usr/lib/{engines,gconv,libxslt-plugins,pkgconfig,python$(PYTHON_VER),sigc++-2.0}
	rm -f $(RELEASE_DIR)/usr/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/usr/lib/*
#
# fonts
#
	if [ -e $(TARGET_DIR)/usr/share/fonts/neutrino.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/neutrino.ttf $(RELEASE_DIR)/usr/share/fonts; \
	fi
	if [ -e $(TARGET_DIR)/usr/share/fonts/micron.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/micron.ttf $(RELEASE_DIR)/usr/share/fonts; \
	fi
	if [ -e $(TARGET_DIR)/usr/share/fonts/DejaVuLGCSansMono-Bold.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/DejaVuLGCSansMono-Bold.ttf $(RELEASE_DIR)/usr/share/fonts; \
		ln -s /usr/share/fonts/DejaVuLGCSansMono-Bold.ttf $(RELEASE_DIR)/usr/share/fonts/tuxtxt.ttf; \
	fi

#
# neutrino
#
#	ln -sf /usr/share $(RELEASE_DIR)/usr/local/share
#	cp $(TARGET_DIR)/usr/local/bin/neutrino $(RELEASE_DIR)/usr/local/bin/
#	cp $(TARGET_DIR)/usr/local/bin/pzapit $(RELEASE_DIR)/usr/local/bin/
#	cp $(TARGET_DIR)/usr/local/bin/sectionsdcontrol $(RELEASE_DIR)/usr/local/bin/
#	if [ -e $(TARGET_DIR)/usr/local/bin/install.sh ]; then \
#		cp -aR $(TARGET_DIR)/usr/local/bin/install.sh $(RELEASE_DIR)/bin/; \
#	fi
#	if [ -e $(TARGET_DIR)/usr/local/bin/luaclient ]; then \
#		cp $(TARGET_DIR)/usr/local/bin/luaclient $(RELEASE_DIR)/bin/; \
#	fi
#	if [ -e $(TARGET_DIR)/usr/local/bin/rcsim ]; then \
#		cp $(TARGET_DIR)/usr/local/bin/rcsim $(RELEASE_DIR)/bin/; \
#	fi
#	if [ -e $(TARGET_DIR)/usr/local/sbin/udpstreampes ]; then \
#		cp $(TARGET_DIR)/usr/local/sbin/udpstreampes $(RELEASE_DIR)/usr/local/sbin/; \
#	fi
#	if [ -e $(TARGET_DIR)/usr/local/bin/udpstreampes ]; then \
#		cp $(TARGET_DIR)/usr/local/bin/udpstreampes $(RELEASE_DIR)/usr/local/bin/; \
#	fi
#
# channellist / tuxtxt / controlscripts
#
	cp -aR $(TARGET_DIR)/var/tuxbox/config/* $(RELEASE_DIR)/var/tuxbox/config
	cp -aR $(TARGET_DIR)/var/tuxbox/control/* $(RELEASE_DIR)/var/tuxbox/control
#
# copy root_neutrino
#
	cp -aR $(SKEL_ROOT)/root_neutrino/* $(RELEASE_DIR)/
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark7162 cuberevo_mini2 cuberevo_3000hd hd51 h7 e4hdultra vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k dm8000 vuduo2 vuultimo vuuno))
	rm -f $(RELEASE_DIR)/var/tuxbox/config/cables.xml
	rm -f $(RELEASE_DIR)/var/tuxbox/config/terrestrial.xml
endif
#
# iso-codes
#
	[ -e $(TARGET_DIR)/usr/share/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/iso-codes $(RELEASE_DIR)/usr/share/ || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/tuxbox/iso-codes $(RELEASE_DIR)/usr/share/tuxbox/ || true
#
# httpd/icons/locale/themes
#
	cp -aR $(TARGET_DIR)/usr/share/tuxbox/neutrino/* $(RELEASE_DIR)/usr/share/tuxbox/neutrino
#
# e2-multiboot
#
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	if [ -e $(TARGET_DIR)/var/lib/opkg/status ]; then \
		cp -af $(TARGET_DIR)/etc/image-version $(RELEASE_DIR)/etc; \
		cp -af $(TARGET_DIR)/etc/issue $(RELEASE_DIR)/etc; \
		cp -af $(TARGET_DIR)/usr/bin/enigma2 $(RELEASE_DIR)/usr/bin; \
		cp -af $(TARGET_DIR)/var/lib/opkg/status $(RELEASE_DIR)/var/lib/opkg; \
	fi
endif
#
# alsa
#
	if [ -e $(TARGET_DIR)/usr/share/alsa ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/alsa/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/cards/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/ctl/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp -dp $(TARGET_DIR)/usr/share/alsa/alsa.conf $(RELEASE_DIR)/usr/share/alsa/alsa.conf; \
		cp $(TARGET_DIR)/usr/share/alsa/cards/aliases.conf $(RELEASE_DIR)/usr/share/alsa/cards/; \
		cp $(TARGET_DIR)/usr/share/alsa/ctl/default.conf $(RELEASE_DIR)/usr/share/alsa/ctl/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/default.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/dmix.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/dsnoop.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
	fi
#
# xupnpd
#
	if [ -e $(TARGET_DIR)/usr/bin/xupnpd ]; then \
		cp -aR $(TARGET_DIR)/usr/share/xupnpd $(RELEASE_DIR)/usr/share; \
		mkdir -p $(RELEASE_DIR)/usr/share/xupnpd/playlists; \
	fi
#
# mc
#
	if [ -e $(TARGET_DIR)/usr/bin/mc ]; then \
		cp -aR $(TARGET_DIR)/usr/share/mc $(RELEASE_DIR)/usr/share/; \
		cp -af $(TARGET_DIR)/usr/libexec $(RELEASE_DIR)/usr/; \
	fi
#
# lua
#
	if [ -d $(TARGET_DIR)/usr/share/lua ]; then \
		cp -aR $(TARGET_DIR)/usr/share/lua $(RELEASE_DIR)/usr/share; \
	fi
#
# plugins
#
	if [ -d $(TARGET_DIR)/var/tuxbox/plugins ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/plugins $(RELEASE_DIR)/var/tuxbox/; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/tuxwetter.so ]; then \
		cp -rf $(TARGET_DIR)/var/tuxbox/config/tuxwetter $(RELEASE_DIR)/var/tuxbox/config; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/sokoban.so ]; then \
		cp -rf $(TARGET_DIR)/usr/share/tuxbox/sokoban $(RELEASE_DIR)/var/tuxbox/plugins; \
		ln -s /var/tuxbox/plugins/sokoban $(RELEASE_DIR)/usr/share/tuxbox/sokoban; \
	fi
	if [ -d $(TARGET_DIR)/usr/share/E2emulator ]; then \
		make python-iptv-install; \
	fi

#
# shairport
#
	if [ -e $(TARGET_DIR)/usr/bin/shairport ]; then \
		cp -f $(TARGET_DIR)/usr/bin/shairport $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSPublish $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSResponder $(RELEASE_DIR)/usr/bin; \
		cp -f $(SKEL_ROOT)/etc/init.d/shairport $(RELEASE_DIR)/etc/init.d/shairport; \
		chmod 755 $(RELEASE_DIR)/etc/init.d/shairport; \
		cp -f $(TARGET_LIB_DIR)/libhowl.so* $(RELEASE_DIR)/usr/lib; \
		cp -f $(TARGET_LIB_DIR)/libmDNSResponder.so* $(RELEASE_DIR)/usr/lib; \
	fi

#
# minisatip
#
	if [ -e $(TARGET_DIR)/usr/bin/minisatip -a -d $(TARGET_DIR)/usr/share/minisatip/html ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/minisatip; \
		cp -aR $(TARGET_DIR)/usr/share/minisatip/html $(RELEASE_DIR)/usr/share/minisatip; \
		rm -f $(RELEASE_DIR)/usr/lib/libdvbcsa*; \
	fi

#
# dropbear
#
	if [ -d $(RELEASE_DIR)/etc/dropbear ]; then \
		mkdir -p $(RELEASE_DIR)/.ssh; \
		chmod 700 $(RELEASE_DIR)/.ssh; \
		ln -s /etc/dropbear/authorized_keys $(RELEASE_DIR)/.ssh/authorized_keys; \
	fi

#
# lcd4linux
#
ifeq ($(EXTERNAL_LCD), $(filter $(EXTERNAL_LCD), lcd4linux both))
	cp -aR $(SKEL_ROOT)/var/tuxbox/lcd $(RELEASE_DIR)/var/tuxbox/
	ln -s /var/tuxbox/lcd $(RELEASE_DIR)/usr/share/tuxbox/lcd
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm8000 vuduo2))
	cp -aR $(SKEL_ROOT)/var/tuxbox/lcd $(RELEASE_DIR)/var/tuxbox/
	ln -s /var/tuxbox/lcd $(RELEASE_DIR)/usr/share/tuxbox/lcd
endif

#
# delete unnecessary files
#
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4 mips))
	rm -f $(RELEASE_DIR)/etc/mdev/ttyUSB-check.sh
endif
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4))
	rm -f $(RELEASE_DIR)/etc/mdev/mdev-mount-mmc-boot.sh
	rm -f $(RELEASE_DIR)/etc/mdev/mdev-mount-mmc.sh
	rm -f $(RELEASE_DIR)/sbin/fsck.ext4
	rm -f $(RELEASE_DIR)/sbin/mkfs.ext4
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
	rm -f $(RELEASE_DIR)/sbin/jfs_fsck
	rm -f $(RELEASE_DIR)/sbin/fsck.jfs
	rm -f $(RELEASE_DIR)/sbin/jfs_mkfs
	rm -f $(RELEASE_DIR)/sbin/mkfs.jfs
	rm -f $(RELEASE_DIR)/sbin/jfs_tune
	rm -f $(RELEASE_DIR)/etc/ssl/certs/ca-certificates.crt
	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/httpd/images/rc_913.jpg
endif
	rm -f $(RELEASE_DIR)/etc/ssl/misc/*
	rm -f $(RELEASE_DIR)/usr/lib/lua/5.2/*.la
	rm -rf $(RELEASE_DIR)/lib/autofs
	rm -f $(RELEASE_DIR)/lib/libSegFault*
	rm -f $(RELEASE_DIR)/lib/libstdc++.*-gdb.py
	rm -f $(RELEASE_DIR)/lib/libthread_db*
	rm -f $(RELEASE_DIR)/lib/libanl*
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)
	rm -rf $(RELEASE_DIR)/usr/lib/alsa
	rm -rf $(RELEASE_DIR)/usr/lib/glib-2.0
	rm -rf $(RELEASE_DIR)/usr/lib/cmake
	rm -f $(RELEASE_DIR)/usr/lib/*.py
	rm -f $(RELEASE_DIR)/usr/lib/libc.so
	rm -f $(RELEASE_DIR)/usr/lib/xml2Conf.sh
	rm -f $(RELEASE_DIR)/usr/lib/libfontconfig*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdcss*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdnav*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdread*
	rm -f $(RELEASE_DIR)/usr/lib/libcurses.so
	[ ! -e $(RELEASE_DIR)/usr/bin/mc ] && rm -f $(RELEASE_DIR)/usr/lib/libncurses* || true
	rm -f $(RELEASE_DIR)/usr/lib/libthread_db*
	rm -f $(RELEASE_DIR)/usr/lib/libanl*
	rm -f $(RELEASE_DIR)/usr/lib/libopkg*
	rm -f $(RELEASE_DIR)/bin/gitVCInfo
	rm -f $(RELEASE_DIR)/bin/evtest
	rm -f $(RELEASE_DIR)/bin/meta
	rm -f $(RELEASE_DIR)/bin/streamproxy
	rm -f $(RELEASE_DIR)/bin/libstb-hal-test
	rm -f $(RELEASE_DIR)/sbin/ldconfig
	rm -f $(RELEASE_DIR)/usr/bin/axfer
	rm -f $(RELEASE_DIR)/usr/bin/compile_et
	rm -f $(RELEASE_DIR)/usr/bin/pic2m2v
	rm -f $(RELEASE_DIR)/usr/bin/mk_cmds
	rm -f $(RELEASE_DIR)/usr/bin/{gdbus-codegen,glib-*,gtester-report}
	rm -f $(RELEASE_DIR)/usr/bin/nhlt-dmic-info
	rm -f $(RELEASE_DIR)/usr/bin/hb-*
	rm -f $(RELEASE_DIR)/usr/lib/libharfbuzz-subset*
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	rm -rf $(RELEASE_DIR)/dev.static
	rm -rf $(RELEASE_DIR)/ram
	rm -rf $(RELEASE_DIR)/root
endif
#
# The main target depends on the model.
# IMPORTANT: it is assumed that only one variable is set. Otherwise the target name won't be resolved.
#
$(D)/neutrino-release: neutrino-release-base neutrino-release-$(BOXTYPE)
	$(TUXBOX_CUSTOMIZE)
	@touch $@
#
# FOR YOUR OWN CHANGES use these folder in own_build/neutrino-hd
#
#	default for all receiver
	find $(OWN_BUILD)/neutrino-hd/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} +
#	receiver specific (only if directory exist)
	[ -d "$(OWN_BUILD)/neutrino-hd.$(BOXTYPE)" ] && find $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
	echo $(BOXTYPE) > $(RELEASE_DIR)/etc/model
#
# nicht die feine Art, aber funktioniert ;)
#
	cp -dpfr $(RELEASE_DIR)/etc $(RELEASE_DIR)/var
	rm -fr $(RELEASE_DIR)/etc
	ln -sf var/etc $(RELEASE_DIR)/etc
#
	ln -s /tmp $(RELEASE_DIR)/lib/init
	ln -s /tmp $(RELEASE_DIR)/var/lib/urandom
	ln -s /tmp $(RELEASE_DIR)/var/lock
	ln -s /tmp $(RELEASE_DIR)/var/log
	ln -s /tmp $(RELEASE_DIR)/var/run
	ln -s /tmp $(RELEASE_DIR)/var/tmp
#
	mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/scan.jpg $(RELEASE_DIR)/var/boot/
	ln -s /var/boot/scan.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3.jpg $(RELEASE_DIR)/var/boot/
	ln -s /var/boot/mp3.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3-?.jpg
	mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/shutdown.jpg $(RELEASE_DIR)/var/boot/
	ln -s /var/boot/shutdown.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/radiomode.jpg $(RELEASE_DIR)/var/boot/
	ln -s /var/boot/radiomode.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/start.jpg $(RELEASE_DIR)/var/boot/
	ln -s /var/boot/start.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
#
# linux-strip all
#
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug normal))
	find $(RELEASE_DIR)/ -name '*' -exec $(TARGET)-strip --strip-unneeded {} &>/dev/null \;
ifeq ($(OPTIMIZE_PICS), 1)
	find $(RELEASE_DIR)/ -iname '*.jpg' -exec jpegoptim --strip-all -q {} \;
	find $(RELEASE_DIR)/ -iname '*.png' -exec optipng -nb -nc -o7 -quiet {} \;
endif
endif
	@echo "***************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Neutrino for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************"
#
# neutrino-release-clean
#
neutrino-release-clean:
	rm -f $(D)/neutrino-release
