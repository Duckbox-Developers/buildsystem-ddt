depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean: depsclean
	-$(MAKE) -C $(DRIVER_DIR) KERNEL_LOCATION=$(KERNEL_DIR) \
		BIN_DEST=$(TARGETPREFIX)/bin \
		INSTALL_MOD_PATH=$(TARGETPREFIX) clean
	-$(MAKE) -C $(APPS_DIR)/tools distclean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(D)/linux-kernel

distclean:
	-$(MAKE) -C $(APPS_DIR) distclean
	-$(MAKE) -C $(APPS_DIR)/tools distclean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(BUILD_TMP)
	-rm -rf $(SOURCE_DIR)
	-rm -rf $(D)
	test -d $(D) || mkdir $(D)
