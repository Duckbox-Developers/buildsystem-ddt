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

ifeq ($(BOXTYPE), vuuno)
DRIVER_VER = 3.9.6
DRIVER_DATE = 20171204
DRIVER_SRC = vuplus-dvb-modules-$(BOXTYPE)-$(DRIVER_VER)-$(DRIVER_DATE).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/vuplus-dvb-modules/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), vuultimo)
DRIVER_VER = 3.9.6
DRIVER_DATE = 20171204
DRIVER_SRC = vuplus-dvb-modules-$(BOXTYPE)-$(DRIVER_VER)-$(DRIVER_DATE).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/vuplus-dvb-modules/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm8000)
DRIVER_VER = 3.2
DRIVER_DATE = 20140604a
DRIVER_SRC = dreambox-dvb-modules-$(BOXTYPE)-$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE).tar.bz2

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.0.0/dreambox-dvb-modules/$(DRIVER_SRC)
	$(DOWNLOAD) https://github.com/oe-mirrors/dreambox/raw/main/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm820)
DRIVER_VER = 3.4-4.0
DRIVER_DATE = 20181018
DRIVER_SRC = dreambox-dvb-modules_$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE)_$(BOXTYPE).tar.xz

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.0.0/dreambox-dvb-modules/$(DRIVER_SRC)
	$(DOWNLOAD) https://github.com/oe-mirrors/dreambox/raw/main/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm7080)
DRIVER_VER = 3.4-4.0
DRIVER_DATE = 20190502
DRIVER_SRC = dreambox-dvb-modules_$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE)_$(BOXTYPE).tar.xz

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.0.0/dreambox-dvb-modules/$(DRIVER_SRC)
	$(DOWNLOAD) https://github.com/oe-mirrors/dreambox/raw/main/$(DRIVER_SRC)
endif

driver-clean:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuuno vuultimo))
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm820 dm7080 dm8000))
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra/$(KERNEL_TYPE)*
endif

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 vuuno vuultimo))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
ifeq ($(BOXTYPE), vuduo2)
#	$(MAKE) platform_util
#	$(MAKE) libgles
	$(MAKE) vmlinuz_initrd
endif
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm820 dm7080 dm8000))
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm820 dm7080))
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra --transform='s/.*\///'
	find $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra -type d -empty -delete
else
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
endif
ifeq ($(BOXTYPE), dm8000)
	tar -xf $(SKEL_ROOT)/release/grautec.tar.gz -C $(TARGET_DIR)/
endif
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

#
# vmlinuz initrd
#
ifeq ($(BOXTYPE), vuduo2)
INITRD_DATE = 20130220
endif
INITRD_SRC = vmlinuz-initrd_$(KERNEL_TYPE)_$(INITRD_DATE).tar.gz

$(ARCHIVE)/$(INITRD_SRC):
	$(DOWNLOAD) http://code.vuplus.com/download/release/kernel/$(INITRD_SRC)

$(D)/vmlinuz_initrd: $(D)/bootstrap $(ARCHIVE)/$(INITRD_SRC)
	$(START_BUILD)
	tar -xf $(ARCHIVE)/$(INITRD_SRC) -C $(TARGET_DIR)/boot
	install -d $(TARGET_DIR)/boot
	$(TOUCH)
