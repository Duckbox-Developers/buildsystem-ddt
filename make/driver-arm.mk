#
# driver
#
ifeq ($(BOXTYPE), hd51)
DRIVER_VER = 4.10.12
DRIVER_DATE = 20180424
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://source.mynonpublic.com/gfutures/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), hd60)
DRIVER_VER = 4.4.35
DRIVER_DATE = 20180918
DRIVER_SRC = $(KERNEL_TYPE)-drivers-$(DRIVER_VER)-$(DRIVER_DATE).zip

EXTRA_PLAYERLIB_DATE = 20180912
EXTRA_PLAYERLIB_SRC = $(KERNEL_TYPE)-libs-$(EXTRA_PLAYERLIB_DATE).zip

EXTRA_MALILIB_DATE = 20180912
EXTRA_MALILIB_SRC = $(KERNEL_TYPE)-mali-$(EXTRA_MALILIB_DATE).zip

EXTRA_MALI_MODULE_VER = DX910-SW-99002-r7p0-00rel0
EXTRA_MALI_MODULE_SRC = $(EXTRA_MALI_MODULE_VER).tgz
EXTRA_MALI_MODULE_PATCH = 0001-hi3798mv200-support.patch

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(DRIVER_SRC)

$(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(EXTRA_PLAYERLIB_SRC)

$(ARCHIVE)/$(EXTRA_MALILIB_SRC):
	$(WGET) http://downloads.mutant-digital.net/$(KERNEL_TYPE)/$(EXTRA_MALILIB_SRC)

$(ARCHIVE)/$(EXTRA_MALI_MODULE_SRC):
	$(WGET) https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu/$(EXTRA_MALI_MODULE_SRC);name=driver

endif

ifeq ($(BOXTYPE), vusolo4k)
DRIVER_VER = 3.14.28
DRIVER_DATE = 20180702
DRIVER_REV = r0
DRIVER_SRC = vuplus-dvb-proxy-$(KERNEL_TYPE)-$(DRIVER_VER)-$(DRIVER_DATE).$(DRIVER_REV).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(DRIVER_SRC)
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
ifeq ($(BOXTYPE), hd60)
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	install -d $(TARGET_DIR)/bin
	mv $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/turnoff_power $(TARGET_DIR)/bin
	$(MAKE) install-extra-libs
	$(MAKE) mali-gpu-modul
	$(TOUCH)

$(D)/install-extra-libs: $(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC) $(ARCHIVE)/$(EXTRA_MALILIB_SRC) $(D)/zlib $(D)/libpng $(D)/freetype $(D)/libcurl $(D)/libxml2 $(D)/libjpeg_turbo2 $(D)/harfbuzz
	install -d $(TARGET_DIR)/usr/lib
	unzip -o $(PATCHES)/libgles-mali-utgard-headers.zip -d $(TARGET_DIR)/usr/include
	unzip -o $(ARCHIVE)/$(EXTRA_PLAYERLIB_SRC) -d $(TARGET_DIR)/usr/lib
	unzip -o $(ARCHIVE)/$(EXTRA_MALILIB_SRC) -d $(TARGET_DIR)/usr/lib
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libmali.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libEGL.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libGLESv1_CM.so
	ln -sf libMali.so $(TARGET_DIR)/usr/lib/libGLESv2.so

$(D)/mali-gpu-modul: $(ARCHIVE)/$(EXTRA_MALI_MODULE_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	$(REMOVE)/$(EXTRA_MALI_MODULE_VER)
	$(UNTAR)/$(EXTRA_MALI_MODULE_SRC)
	set -e; cd $(BUILD_TMP)/$(EXTRA_MALI_MODULE_VER); \
		$(call apply_patches,$(EXTRA_MALI_MODULE_PATCH)); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- \
		M=$(BUILD_TMP)/$(EXTRA_MALI_MODULE_VER)/driver/src/devicedrv/mali \
		EXTRA_CFLAGS="-DCONFIG_MALI_SHARED_INTERRUPTS=y \
		-DCONFIG_MALI400=m \
		-DCONFIG_MALI450=y \
		-DCONFIG_MALI_DVFS=y \
		-DCONFIG_GPU_AVS_ENABLE=y" \
		CONFIG_MALI_SHARED_INTERRUPTS=y \
		CONFIG_MALI400=m \
		CONFIG_MALI450=y \
		CONFIG_MALI_DVFS=y \
		CONFIG_GPU_AVS_ENABLE=y ; \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- \
		M=$(BUILD_TMP)/$(EXTRA_MALI_MODULE_VER)/driver/src/devicedrv/mali \
		EXTRA_CFLAGS="-DCONFIG_MALI_SHARED_INTERRUPTS=y \
		-DCONFIG_MALI400=m \
		-DCONFIG_MALI450=y \
		-DCONFIG_MALI_DVFS=y \
		-DCONFIG_GPU_AVS_ENABLE=y" \
		CONFIG_MALI_SHARED_INTERRUPTS=y \
		CONFIG_MALI400=m \
		CONFIG_MALI450=y \
		CONFIG_MALI_DVFS=y \
		CONFIG_GPU_AVS_ENABLE=y \
		DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	$(REMOVE)/$(EXTRA_MALI_MODULE_VER)
	$(TOUCH)
endif
ifeq ($(BOXTYPE), vusolo4k)
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
UTIL_VER = 17.1
UTIL_DATE = 20180702
UTIL_REV = r0
UTIL_SRC = platform-util-$(KERNEL_TYPE)-$(UTIL_VER)-$(UTIL_DATE).$(UTIL_REV).tar.gz

$(ARCHIVE)/$(UTIL_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(UTIL_SRC)

$(D)/platform_util: $(D)/bootstrap $(ARCHIVE)/$(UTIL_SRC)
	$(START_BUILD)
	$(UNTAR)/$(UTIL_SRC)
	install -m 0755 $(BUILD_TMP)/platform-util-$(KERNEL_TYPE)/* $(TARGET_DIR)/usr/bin
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)

#
# libgles
#
GLES_VER = 17.1
GLES_DATE = 20180702
GLES_REV = r0
GLES_SRC = libgles-$(KERNEL_TYPE)-$(GLES_VER)-$(GLES_DATE).$(GLES_REV).tar.gz

$(ARCHIVE)/$(GLES_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(GLES_SRC)

$(D)/libgles: $(D)/bootstrap $(ARCHIVE)/$(GLES_SRC)
	$(START_BUILD)
	$(UNTAR)/$(GLES_SRC)
	install -m 0755 $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/lib/* $(TARGET_DIR)/usr/lib
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_DIR)/usr/lib/libGLESv2.so
	cp -a $(BUILD_TMP)/libgles-$(KERNEL_TYPE)/include/* $(TARGET_DIR)/usr/include
	$(REMOVE)/libgles-$(KERNEL_TYPE)
	$(TOUCH)

#
# vmlinuz initrd
#
INITRD_DATE = 20170209
INITRD_SRC = vmlinuz-initrd_$(KERNEL_TYPE)_$(INITRD_DATE).tar.gz

$(ARCHIVE)/$(INITRD_SRC):
	$(WGET) http://archive.vuplus.com/download/kernel/$(INITRD_SRC)

$(D)/vmlinuz_initrd: $(D)/bootstrap $(ARCHIVE)/$(INITRD_SRC)
	$(START_BUILD)
	tar -xf $(ARCHIVE)/$(INITRD_SRC) -C $(TARGET_DIR)/boot
	install -d $(TARGET_DIR)/boot
	$(TOUCH)
endif
