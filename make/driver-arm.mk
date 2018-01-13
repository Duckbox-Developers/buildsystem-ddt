#
# driver
#
ifeq ($(BOXTYPE), hd51)
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(KERNEL_VER)-$(KERNEL_DATE).zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://source.mynonpublic.com/gfutures/$(DRIVER_SRC)
endif
ifeq ($(BOXTYPE), vusolo4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20171222
DRIVER_REV = r0
DRIVER_SRC = $(KERNEL_TYPE)-$(DRIVER_VER)-$(DRIVER_DATE).$(DRIVER_REV).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/vuplus-dvb-proxy-$(DRIVER_SRC)
endif

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
ifeq ($(BOXTYPE), hd51)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(TOUCH)
endif
ifeq ($(BOXTYPE), vusolo4k)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/vuplus-dvb-proxy-$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(TOUCH)
endif
