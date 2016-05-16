depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean: depsclean
	-$(MAKE) -C $(DRIVER_DIR) KERNEL_LOCATION=$(KERNEL_DIR) \
		BIN_DEST=$(TARGETPREFIX)/bin \
		INSTALL_MOD_PATH=$(TARGETPREFIX) clean
	-$(MAKE) -C $(APPS_DIR)/tools/aio-grab clean
	-$(MAKE) -C $(APPS_DIR)/tools/devinit clean
	-$(MAKE) -C $(APPS_DIR)/tools/evremote2 clean
	-$(MAKE) -C $(APPS_DIR)/tools/fp_control clean
	-$(MAKE) -C $(APPS_DIR)/tools/hotplug clean
	-$(MAKE) -C $(APPS_DIR)/tools/libeplayer3 clean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_host clean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_image clean
	-$(MAKE) -C $(APPS_DIR)/tools/showiframe clean
	-$(MAKE) -C $(APPS_DIR)/tools/spf_tool clean
	-$(MAKE) -C $(APPS_DIR)/tools/streamproxy clean
	-$(MAKE) -C $(APPS_DIR)/tools/ustslave clean
	-$(MAKE) -C $(APPS_DIR)/tools/vfdctl clean
	-$(MAKE) -C $(APPS_DIR)/tools/wait4button clean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(D)/linux-kernel
	-rm -rf $(D)/linux-kernel.do_compile

distclean:
	-$(MAKE) -C $(APPS_DIR)/tools/aio-grab distclean
	-$(MAKE) -C $(APPS_DIR)/tools/devinit distclean
	-$(MAKE) -C $(APPS_DIR)/tools/evremote2 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/fp_control distclean
	-$(MAKE) -C $(APPS_DIR)/tools/hotplug distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libeplayer3 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_host distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_image distclean
	-$(MAKE) -C $(APPS_DIR)/tools/showiframe distclean
	-$(MAKE) -C $(APPS_DIR)/tools/spf_tool distclean
	-$(MAKE) -C $(APPS_DIR)/tools/streamproxy distclean
	-$(MAKE) -C $(APPS_DIR)/tools/ustslave distclean
	-$(MAKE) -C $(APPS_DIR)/tools/vfdctl distclean
	-$(MAKE) -C $(APPS_DIR)/tools/wait4button distclean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(BUILD_TMP)
	-rm -rf $(SOURCE_DIR)
	-rm -rf $(D)
	test -d $(D) || mkdir $(D)
