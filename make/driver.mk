#
# driver
#
driver-clean:
	$(MAKE) -C $(DRIVER_DIR) ARCH=sh KERNEL_LOCATION=$(KERNEL_DIR) distclean
	rm -f $(D)/driver

driver-symlink:
	$(SET) -e; cd $(DRIVER_DIR); \
		rm -f player2 multicom; \
		ln -s $(PLAYER2_LINK) player2; \
		ln -s $(MULTICOM_LINK) multicom; \
		rm -f .config; printf "export CONFIG_PLAYER_$(PLAYER_VERSION_DRIVER)=y\nexport CONFIG_MULTICOM$(MULTICOM_VERSION)=y\n" > .config; \
		cd include; \
		rm -f stmfb player2 multicom; \
		ln -s stmfb-3.1_stm24_0104 stmfb; \
		ln -s $(PLAYER2_LINK) player2; \
		ln -s ../$(MULTICOM_LINK)/include multicom; \
		cd ../stgfb; \
		rm -f stmfb; \
		ln -s stmfb-3.1_stm24_0104 stmfb
	cp $(DRIVER_DIR)/stgfb/stmfb/linux/drivers/video/stmfb.h $(TARGET_DIR)/usr/include/linux
	cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_ioctls.h $(TARGET_DIR)/usr/include/linux/dvb
	$(if $(PLAYER228),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_audio.h $(TARGET_DIR)/usr/include/linux/dvb)
	$(if $(PLAYER228),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_dvb.h $(TARGET_DIR)/usr/include/linux/dvb)
	$(if $(PLAYER228),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_video.h $(TARGET_DIR)/usr/include/linux/dvb)
	touch $(D)/$(notdir $@)

driver: $(D)/driver
$(D)/driver: $(DRIVER_DIR)/Makefile $(D)/bootstrap $(D)/linux-kernel
	$(START_BUILD)
	$(MAKE) -C $(KERNEL_DIR) ARCH=sh CONFIG_DEBUG_SECTION_MISMATCH=y \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(DRIVER_DIR) \
		M=$(DRIVER_DIR) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(TARGET)- \
		modules
	$(MAKE) -C $(KERNEL_DIR) ARCH=sh CONFIG_DEBUG_SECTION_MISMATCH=y \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(DRIVER_DIR) \
		M=$(DRIVER_DIR) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(TARGET)- \
		BIN_DEST=$(TARGET_DIR)/bin \
		INSTALL_MOD_PATH=$(TARGET_DIR) \
		modules_install
	$(DEPMOD) -ae -b $(TARGET_DIR) -F $(KERNEL_DIR)/System.map -r $(KERNEL_VERSION)
	$(TOUCH)
