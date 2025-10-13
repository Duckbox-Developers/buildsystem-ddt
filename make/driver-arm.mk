#
# driver
#
ifeq ($(BOXTYPE), dcube)
DRIVER_DATE = 20141203
DRIVER_VER = 2.6.34-$(DRIVER_DATE)
DRIVER_SRC = cube-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/cube
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), bre2ze4k)
DRIVER_DATE = 20191120
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = bre2ze4k-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/gfutures
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), hd51)
#DRIVER_DATE = 20180424
#DRIVER_DATE = 20191031
#DRIVER_DATE = 20191101
DRIVER_DATE = 20191120
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = hd51-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/gfutures
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), h7)
#DRIVER_DATE = 20190405
#DRIVER_DATE = 20191110
DRIVER_DATE = 20191123
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = h7-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/zgemma
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), e4hdultra)
DRIVER_DATE = 20191101
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = e4hd-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/ceryon
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm900)
DRIVER_VER = 3.14-1.17
DRIVER_DATE = 20200226
DRIVER_SRC = dreambox-dvb-modules_$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE)_$(BOXTYPE).tar.xz

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.5.0/dreambox-dvb-modules/$(DRIVER_SRC)
#	$(DOWNLOAD) https://github.com/Duckbox-Developers/dreambox/raw/refs/heads/master/$(BOXTYPE)/$(DRIVER_SRC)
	$(DOWNLOAD) https://github.com/oe-mirrors/dreambox/raw/main/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), dm920)
DRIVER_VER = 3.14-1.17
DRIVER_DATE = 20200321
DRIVER_SRC = dreambox-dvb-modules_$(DRIVER_VER)-$(BOXTYPE)-$(DRIVER_DATE)_$(BOXTYPE).tar.xz

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) https://sources.dreamboxupdate.com/download/opendreambox/2.5.0/dreambox-dvb-modules/$(DRIVER_SRC)
#	$(DOWNLOAD) https://github.com/oe-mirrors/dreambox/raw/main/$(DRIVER_SRC)
#	$(DOWNLOAD) https://github.com/Duckbox-Developers/dreambox/raw/refs/heads/master/$(BOXTYPE)/$(DRIVER_SRC)
	$(DOWNLOAD) https://source.mynonpublic.com/dreambox/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
ifeq ($(BOXTYPE), vuduo4k)
DRIVER_VER = 4.1.45
DRIVER_DATE = 20191218
#DRIVER_DATE = 20191125
#DRIVER_DATE = 20191014
#DRIVER_DATE = 20190212
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vuduo4kse)
DRIVER_VER = 4.1.45
DRIVER_DATE = 20210527
#DRIVER_DATE = 20210407
#DRIVER_DATE = 20200903
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4kse)
DRIVER_VER = 4.1.20
DRIVER_DATE = 20210407
#DRIVER_DATE = 20190424
#DRIVER_DATE = 20190104
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vuzero4k)
DRIVER_VER = 4.1.20
DRIVER_DATE = 20210407
#DRIVER_DATE = 20190424
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vuultimo4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20190424
#DRIVER_DATE = 20190104
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20190424
#DRIVER_DATE = 20190104
DRIVER_REV = r0
endif
ifeq ($(BOXTYPE), vusolo4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20190424
DRIVER_REV = r0
endif
DRIVER_SRC = vuplus-dvb-proxy-$(KERNEL_TYPE)-$(DRIVER_VER)-$(DRIVER_DATE).$(DRIVER_REV).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
#	$(DOWNLOAD) http://code.vuplus.com/download/release/vuplus-dvb-proxy/$(DRIVER_SRC)
	$(DOWNLOAD) $(GITHUB)/$(GIT_NAME)/vuplus/raw/refs/heads/master/$(BOXTYPE)/$(DRIVER_SRC)
endif

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra dm900 dm920 dcube))
driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm900 dm920))
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra --transform='s/.*\///'
	find $(TARGET_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)/extra -type d -empty -delete
else
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
endif
	$(TOUCH)
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(MAKE) platform_util
	$(MAKE) libgles
	$(MAKE) vmlinuz_initrd
	$(TOUCH)

#
# platform util
#
ifeq ($(BOXTYPE), vuduo4k)
UTIL_VER = 18.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuduo4kse)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4kse)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuzero4k)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuultimo4k)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4k)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
ifeq ($(BOXTYPE), vusolo4k)
UTIL_VER = 17.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
endif
UTIL_SRC = platform-util-$(KERNEL_TYPE)-$(UTIL_VER)-$(UTIL_DATE).$(UTIL_REV).tar.gz

$(ARCHIVE)/$(UTIL_SRC):
#	$(DOWNLOAD) http://code.vuplus.com/download/release/platform-util/$(UTIL_SRC)
	$(DOWNLOAD) $(GITHUB)/$(GIT_NAME)/vuplus/raw/refs/heads/master/$(BOXTYPE)/$(UTIL_SRC)

$(D)/platform_util: $(D)/bootstrap $(ARCHIVE)/$(UTIL_SRC)
	$(START_BUILD)
	$(UNTAR)/$(UTIL_SRC)
	install -m 0755 $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)/* $(TARGET_DIR)/usr/bin
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)

#
# libgles
#
ifeq ($(BOXTYPE), vuduo4k)
GLES_VER = 18.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuduo4kse)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4kse)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuzero4k)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuultimo4k)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vuuno4k)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
ifeq ($(BOXTYPE), vusolo4k)
GLES_VER = 17.1
GLES_DATE = $(DRIVER_DATE)
GLES_REV = r0
endif
GLES_SRC = libgles-$(KERNEL_TYPE)-$(GLES_VER)-$(GLES_DATE).$(GLES_REV).tar.gz

$(ARCHIVE)/$(GLES_SRC):
#	$(DOWNLOAD) http://code.vuplus.com/download/release/libgles/$(GLES_SRC)
	$(DOWNLOAD) $(GITHUB)/$(GIT_NAME)/vuplus/raw/refs/heads/master/$(BOXTYPE)/$(GLES_SRC)

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
ifeq ($(BOXTYPE), vuduo4k)
INITRD_DATE = 20181030
endif
ifeq ($(BOXTYPE), vuduo4kse)
INITRD_DATE = 20200326
endif
ifeq ($(BOXTYPE), vuuno4kse)
INITRD_DATE = 20170627
endif
ifeq ($(BOXTYPE), vuzero4k)
INITRD_DATE = 20170522
endif
ifeq ($(BOXTYPE), vuultimo4k)
INITRD_DATE = 20170209
endif
ifeq ($(BOXTYPE), vuuno4k)
INITRD_DATE = 20170209
endif
ifeq ($(BOXTYPE), vusolo4k)
INITRD_DATE = 20170209
endif
INITRD_SRC = vmlinuz-initrd_$(KERNEL_TYPE)_$(INITRD_DATE).tar.gz

$(ARCHIVE)/$(INITRD_SRC):
#	$(DOWNLOAD) http://code.vuplus.com/download/release/kernel/$(INITRD_SRC)
	$(DOWNLOAD) $(GITHUB)/$(GIT_NAME)/vuplus/raw/refs/heads/master/$(BOXTYPE)/$(INITRD_SRC)

$(D)/vmlinuz_initrd: $(D)/bootstrap $(ARCHIVE)/$(INITRD_SRC)
	$(START_BUILD)
	tar -xf $(ARCHIVE)/$(INITRD_SRC) -C $(TARGET_DIR)/boot
	install -d $(TARGET_DIR)/boot
	$(TOUCH)
endif
