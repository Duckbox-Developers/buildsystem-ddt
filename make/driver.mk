#
# driver
#
driver-clean:
	$(MAKE) -C $(DRIVER_DIR) ARCH=sh KERNEL_LOCATION=$(KERNEL_DIR) distclean
	rm -f $(D)/driver
#	rm -f $(D)/driver-symlink

driver-symlink:
	set -e; cd $(DRIVER_DIR); \
		rm -f player2 multicom; \
		ln -s $(PLAYER2_LINK) player2; \
		ln -s $(MULTICOM_LINK) multicom; \
		rm -f .config; printf "export CONFIG_PLAYER_$(PLAYER_VER)=y\nexport CONFIG_MULTICOM$(MULTICOM_VER)=y\n" > .config; \
		cd include; \
		rm -f stmfb player2 multicom; \
		ln -s stmfb-3.1_stm24_0104 stmfb; \
		ln -s $(PLAYER2_LINK) player2; \
		ln -s ../$(MULTICOM_LINK)/include multicom; \
		cd ../stgfb; \
		rm -f stmfb; \
		ln -s stmfb-3.1_stm24_0104 stmfb
	cp $(DRIVER_DIR)/stgfb/stmfb/linux/drivers/video/stmfb.h $(TARGETPREFIX)/usr/include/linux
	cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_ioctls.h $(TARGETPREFIX)/usr/include/linux/dvb
	$(if $(PLAYERXXX),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_audio.h $(TARGETPREFIX)/usr/include/linux/dvb)
	$(if $(PLAYERXXX),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_dvb.h $(TARGETPREFIX)/usr/include/linux/dvb)
	$(if $(PLAYERXXX),cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_video.h $(TARGETPREFIX)/usr/include/linux/dvb)
	touch $(D)/$(notdir $@)

$(D)/driver: $(DRIVER_DIR)/Makefile $(D)/bootstrap $(D)/linux-kernel
	$(MAKE) -C $(DRIVER_DIR) ARCH=sh \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(DRIVER_DIR) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(TARGET)-
	$(MAKE) -C $(DRIVER_DIR) ARCH=sh \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(DRIVER_DIR) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(TARGET)- \
		BIN_DEST=$(TARGETPREFIX)/bin \
		INSTALL_MOD_PATH=$(TARGETPREFIX) \
		install
	$(DEPMOD) -ae -b $(TARGETPREFIX) -F $(KERNEL_DIR)/System.map -r $(KERNEL_VERSION)
	touch $@
