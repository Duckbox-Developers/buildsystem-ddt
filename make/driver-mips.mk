ifeq ($(BOXTYPE), vuduo)
DRIVER_VER = 3.9.6
DRIVER_DATE = 20151124
DRIVER_SRC = vuplus-dvb-modules-bm750-$(DRIVER_VER)-$(DRIVER_DATE).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/vuplus-dvb-modules/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm8000)
DRIVER_VER = 3.2
DRIVER_DATE = 20140604a
DRIVER_SRC = dreambox-dvb-modules-$(BOXTYPE)-$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE).tar.bz2

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.0.0/dreambox-dvb-modules/$(DRIVER_SRC)
endif

driver-clean:
ifeq ($(BOXTYPE), vuduo)
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*
endif
ifeq ($(BOXTYPE), dm8000)
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra/$(KERNEL_TYPE)*
endif

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
ifeq ($(BOXTYPE), vuduo)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
endif
	$(TOUCH)

ifeq ($(BOXTYPE), dm8000)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
	tar -xf $(SKEL_ROOT)/release/grautec.tar.gz -C $(TARGET_DIR)/
endif
