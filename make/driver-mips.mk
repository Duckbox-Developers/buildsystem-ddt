#
# driver
#
ifeq ($(BOXTYPE), vuduo)
DRIVER_VER = 3.9.6
DRIVER_DATE = 20151124
DRIVER_SRC = vuplus-dvb-modules-bm750-$(DRIVER_VER)-$(DRIVER_DATE).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/vuplus-dvb-modules/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), vuduo2)
DRIVER_VER = 3.13.5
DRIVER_DATE = 20190429
DRIVER_SRC = vuplus-dvb-modules-$(BOXTYPE)-$(DRIVER_VER)-$(DRIVER_DATE).tar.gz

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
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2))
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*
endif
ifeq ($(BOXTYPE), dm8000)
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra/$(KERNEL_TYPE)*
endif

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
#ifeq ($(BOXTYPE), vuduo2)
#	$(MAKE) platform_util
#	$(MAKE) libgles
#endif
endif
ifeq ($(BOXTYPE), dm8000)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
	tar -xf $(SKEL_ROOT)/release/grautec.tar.gz -C $(TARGET_DIR)/
endif
	$(TOUCH)

#
# platform util
#
ifeq ($(BOXTYPE), vuduo2)
UTIL_VER = 15.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
UTIL_SRC = platform-util-$(KERNEL_TYPE)-$(UTIL_VER)-$(UTIL_DATE).$(UTIL_REV).tar.gz

$(ARCHIVE)/$(UTIL_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/platform-util/$(UTIL_SRC)

$(D)/platform_util: $(D)/bootstrap $(ARCHIVE)/$(UTIL_SRC)
	$(START_BUILD)
	$(UNTAR)/$(UTIL_SRC)
	install -m 0755 $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)/* $(TARGET_DIR)/usr/bin
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)

#
# libgles
#
ifeq ($(BOXTYPE), vuduo2)
GLES_VER = 15.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
GLES_SRC = libgles-$(KERNEL_TYPE)-$(GLES_VER)-$(GLES_DATE).$(GLES_REV).tar.gz

$(ARCHIVE)/$(GLES_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/libgles/$(GLES_SRC)

$(D)/libgles: $(D)/bootstrap $(ARCHIVE)/$(GLES_SRC)
	$(START_BUILD)
	$(UNTAR)/$(GLES_SRC)
	install -m 0755 $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/lib/* $(TARGET_LIB_DIR)
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_LIB_DIR)/libGLESv2.so
	cp -a $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/include/* $(TARGET_INCLUDE_DIR)
	$(REMOVE)/libgles-$(KERNEL_TYPE)
	$(TOUCH)
