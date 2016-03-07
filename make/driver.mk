#
# driver
#
$(D)/driver: $(DRIVER_DIR)/Makefile $(D)/bootstrap $(D)/linux-kernel
	cp $(DRIVER_DIR)/stgfb/stmfb/linux/drivers/video/stmfb.h $(TARGETPREFIX)/usr/include/linux
	cp $(DRIVER_DIR)/player2/linux/include/linux/dvb/stm_ioctls.h $(TARGETPREFIX)/usr/include/linux/dvb
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

driver-clean:
	rm -f $(D)/driver
	$(MAKE) -C $(DRIVER_DIR) ARCH=sh \
	KERNEL_LOCATION=$(KERNEL_DIR) distclean
