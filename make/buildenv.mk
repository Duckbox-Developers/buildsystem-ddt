# set up environment for other makefiles
# print '+' before each executed command
# SHELL := $(SHELL) -x

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

BASE_DIR             := $(shell pwd)

ARCHIVE               = $(HOME)/Archive
APPS_DIR              = $(BASE_DIR)/apps
BUILD_TMP             = $(BASE_DIR)/build_tmp
DRIVER_DIR            = $(BASE_DIR)/driver
FLASH_DIR             = $(BASE_DIR)/flash
SOURCE_DIR            = $(BASE_DIR)/source

-include $(BASE_DIR)/config

# for local extensions
-include $(BASE_DIR)/config.local

# default platform...
MAKEFLAGS            += --no-print-directory
GIT_PROTOCOL         ?= http
ifneq ($(GIT_PROTOCOL), http)
GITHUB               ?= git://github.com
else
GITHUB               ?= https://github.com
endif
GIT_NAME             ?= Duckbox-Developers
GIT_NAME_DRIVER      ?= Duckbox-Developers
GIT_NAME_APPS        ?= Duckbox-Developers
GIT_NAME_FLASH       ?= Duckbox-Developers

TUFSBOX_DIR           = $(BASE_DIR)/tufsbox
CROSS_BASE            = $(BASE_DIR)/cross/$(BOXARCH)/$(BOXTYPE)
TARGET_DIR            = $(TUFSBOX_DIR)/cdkroot
BOOT_DIR              = $(TUFSBOX_DIR)/cdkroot-tftpboot
CROSS_DIR             = $(TUFSBOX_DIR)/cross
HOST_DIR              = $(TUFSBOX_DIR)/host
RELEASE_DIR           = $(TUFSBOX_DIR)/release

CUSTOM_DIR            = $(BASE_DIR)/custom
OWN_BUILD             = $(BASE_DIR)/own_build
PATCHES               = $(BASE_DIR)/Patches
SCRIPTS_DIR           = $(BASE_DIR)/scripts
SKEL_ROOT             = $(BASE_DIR)/root
D                     = $(BASE_DIR)/.deps
# backwards compatibility
DEPDIR                = $(D)

SUDOCMD               = echo $(SUDOPASSWD) | sudo -S

MAINTAINER           ?= $(shell whoami)
MAIN_ID               = $(shell echo -en "\x74\x68\x6f\x6d\x61\x73")
CCACHE                = /usr/bin/ccache

BUILD                ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/misc/config.guess 2>/dev/null)

ifeq ($(BOXARCH), sh4)
CCACHE_DIR            = $(HOME)/.ccache-bs-sh4
export CCACHE_DIR
TARGET               ?= sh4-linux
BOXARCH              ?= sh4
KERNELNAME            = uImage
TARGET_MARCH_CFLAGS   =
CORTEX_STRINGS        =
else
CCACHE_DIR            = $(HOME)/.ccache-bs-arm
export CCACHE_DIR
TARGET               ?= arm-cortex-linux-gnueabihf
BOXARCH              ?= arm
KERNELNAME            = zImage
TARGET_MARCH_CFLAGS   = -march=armv7ve -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard
CORTEX_STRINGS        = -lcortex-strings
endif

OPTIMIZATIONS        ?= size
ifeq ($(OPTIMIZATIONS), size)
TARGET_O_CFLAGS       = -Os
TARGET_EXTRA_CFLAGS   = -ffunction-sections -fdata-sections
TARGET_EXTRA_LDFLAGS  = -Wl,--gc-sections
endif
ifeq ($(OPTIMIZATIONS), normal)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), kerneldebug)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif
ifeq ($(OPTIMIZATIONS), debug)
TARGET_O_CFLAGS       = -O0 -g
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
endif

TARGET_LIB_DIR        = $(TARGET_DIR)/usr/lib
TARGET_INCLUDE_DIR    = $(TARGET_DIR)/usr/include

TARGET_CFLAGS         = -pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) $(TARGET_EXTRA_CFLAGS) -I$(TARGET_INCLUDE_DIR)
TARGET_CPPFLAGS       = $(TARGET_CFLAGS)
TARGET_CXXFLAGS       = $(TARGET_CFLAGS)
TARGET_LDFLAGS        = $(CORTEX_STRINGS) -Wl,-rpath -Wl,/usr/lib -Wl,-rpath-link -Wl,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) -L$(TARGET_DIR)/lib $(TARGET_EXTRA_LDFLAGS)
LD_FLAGS              = $(TARGET_LDFLAGS)
PKG_CONFIG            = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_PATH       = $(TARGET_LIB_DIR)/pkgconfig

VPATH                 = $(D)

PATH                 := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(CROSS_BASE)/bin:$(PATH):/sbin:/usr/sbin:/usr/local/sbin

TERM_RED             := \033[00;31m
TERM_RED_BOLD        := \033[01;31m
TERM_GREEN           := \033[00;32m
TERM_GREEN_BOLD      := \033[01;32m
TERM_YELLOW          := \033[00;33m
TERM_YELLOW_BOLD     := \033[01;33m
TERM_NORMAL          := \033[0m

# certificates
CA_BUNDLE             = ca-certificates.crt
CA_BUNDLE_DIR         = /etc/ssl/certs

# helper-"functions"
REWRITE_LIBTOOL       = sed -i "s,^libdir=.*,libdir='$(TARGET_DIR)/usr/lib'," $(TARGET_DIR)/usr/lib
REWRITE_LIBTOOLDEP    = sed -i -e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/usr/lib,\ $(TARGET_DIR)/usr/lib,g" $(TARGET_DIR)/usr/lib
REWRITE_PKGCONF       = sed -i "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',"

# unpack tarballs, clean up
UNTAR                 = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE                = rm -rf $(BUILD_TMP)

#
split_deps_dir=$(subst ., ,$(1))
DEPS_DIR              = $(subst $(D)/,,$@)
PKG_NAME              = $(word 1,$(call split_deps_dir,$(DEPS_DIR)))
PKG_NAME_HELPER       = $(shell echo $(PKG_NAME) | sed 's/.*/\U&/')
PKG_VER_HELPER        = A$($(PKG_NAME_HELPER)_VER)A
PKG_VER               = $($(PKG_NAME_HELPER)_VER)

START_BUILD           = @echo "=============================================================="; \
                        echo; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL)"; \
                        else \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL)"; \
                        fi

TOUCH                 = @touch $@; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
                        else \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
                        fi; \
                        echo

#
PATCH                 = patch -p1 -i $(PATCHES)
APATCH                = patch -p1 -i
define apply_patches
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(APATCH) $$p; \
                else \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(PATCH)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(APATCH) $$i; \
            else \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(PATCH)/$$i; \
            fi; \
        fi; \
    done; \
    if [ $(PKG_VER_HELPER) == "AA" ]; then \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
    else \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
    fi; \
    echo
endef

# wget tarballs into archive directory
WGET = wget --no-check-certificate -t6 -T20 -c -P $(ARCHIVE)

TUXBOX_CUSTOMIZE = [ -x $(CUSTOM_DIR)/$(notdir $@)-local.sh ] && \
	KERNEL_VER=$(KERNEL_VER) && \
	BOXTYPE=$(BOXTYPE) && \
	$(CUSTOM_DIR)/$(notdir $@)-local.sh \
	$(RELEASE_DIR) \
	$(TARGET_DIR) \
	$(BASE_DIR) \
	$(SOURCE_DIR) \
	$(FLASH_DIR) \
	$(BOXTYPE) \
	$(FLAVOUR) \
	|| true

#
#
#
CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET)

BUILDENV = \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

CONFIGURE_TOOLS = \
	./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

MAKE_OPTS := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	ARCH=sh \
	CROSS_COMPILE=$(TARGET)-

#
# image
#
ifeq ($(IMAGE), neutrino)
BUILD_CONFIG       = build-neutrino
else ifeq ($(IMAGE), neutrino-wlandriver)
BUILD_CONFIG       = build-neutrino
WLANDRIVER         = WLANDRIVER=wlandriver
else
BUILD_CONFIG       = build-neutrino
endif

#
DRIVER_PLATFORM   := $(WLANDRIVER)

#
ifeq ($(BOXTYPE), ufs910)
KERNEL_PATCHES_24  = $(UFS910_PATCHES_24)
DRIVER_PLATFORM   += UFS910=ufs910
endif
ifeq ($(BOXTYPE), ufs912)
KERNEL_PATCHES_24  = $(UFS912_PATCHES_24)
DRIVER_PLATFORM   += UFS912=ufs912
endif
ifeq ($(BOXTYPE), ufs913)
KERNEL_PATCHES_24  = $(UFS913_PATCHES_24)
DRIVER_PLATFORM   += UFS913=ufs913
endif
ifeq ($(BOXTYPE), ufs922)
KERNEL_PATCHES_24  = $(UFS922_PATCHES_24)
DRIVER_PLATFORM   += UFS922=ufs922
endif
ifeq ($(BOXTYPE), ufc960)
KERNEL_PATCHES_24  = $(UFC960_PATCHES_24)
DRIVER_PLATFORM   += UFC960=ufc960
endif
ifeq ($(BOXTYPE), tf7700)
KERNEL_PATCHES_24  = $(TF7700_PATCHES_24)
DRIVER_PLATFORM   += TF7700=tf7700
endif
ifeq ($(BOXTYPE), hl101)
KERNEL_PATCHES_24  = $(HL101_PATCHES_24)
DRIVER_PLATFORM   += HL101=hl101
endif
ifeq ($(BOXTYPE), spark)
KERNEL_PATCHES_24  = $(SPARK_PATCHES_24)
DRIVER_PLATFORM   += SPARK=spark
endif
ifeq ($(BOXTYPE), spark7162)
KERNEL_PATCHES_24  = $(SPARK7162_PATCHES_24)
DRIVER_PLATFORM   += SPARK7162=spark7162
endif
ifeq ($(BOXTYPE), fortis_hdbox)
KERNEL_PATCHES_24  = $(FORTIS_HDBOX_PATCHES_24)
DRIVER_PLATFORM   += FORTIS_HDBOX=fortis_hdbox
endif
ifeq ($(BOXTYPE), hs7110)
KERNEL_PATCHES_24  = $(HS7110_PATCHES_24)
DRIVER_PLATFORM   += HS7110=hs7110
endif
ifeq ($(BOXTYPE), hs7119)
KERNEL_PATCHES_24  = $(HS7119_PATCHES_24)
DRIVER_PLATFORM   += HS7119=hs7119
endif
ifeq ($(BOXTYPE), hs7420)
KERNEL_PATCHES_24  = $(HS7420_PATCHES_24)
DRIVER_PLATFORM   += HS7420=hs7420
endif
ifeq ($(BOXTYPE), hs7429)
KERNEL_PATCHES_24  = $(HS7429_PATCHES_24)
DRIVER_PLATFORM   += HS7429=hs7429
endif
ifeq ($(BOXTYPE), hs7810a)
KERNEL_PATCHES_24  = $(HS7810A_PATCHES_24)
DRIVER_PLATFORM   += HS7810A=hs7810a
endif
ifeq ($(BOXTYPE), hs7819)
KERNEL_PATCHES_24  = $(HS7819_PATCHES_24)
DRIVER_PLATFORM   += HS7819=hs7819
endif
ifeq ($(BOXTYPE), atemio520)
KERNEL_PATCHES_24  = $(ATEMIO520_PATCHES_24)
DRIVER_PLATFORM   += ATEMIO520=atemio520
endif
ifeq ($(BOXTYPE), atemio530)
KERNEL_PATCHES_24  = $(ATEMIO530_PATCHES_24)
DRIVER_PLATFORM   += ATEMIO530=atemio530
endif
ifeq ($(BOXTYPE), atevio7500)
KERNEL_PATCHES_24  = $(ATEVIO7500_PATCHES_24)
DRIVER_PLATFORM   += ATEVIO7500=atevio7500
endif
ifeq ($(BOXTYPE), octagon1008)
KERNEL_PATCHES_24  = $(OCTAGON1008_PATCHES_24)
DRIVER_PLATFORM   += OCTAGON1008=octagon1008
endif
ifeq ($(BOXTYPE), adb_box)
KERNEL_PATCHES_24  = $(ADB_BOX_PATCHES_24)
DRIVER_PLATFORM   += ADB_BOX=adb_box
endif
ifeq ($(BOXTYPE), ipbox55)
KERNEL_PATCHES_24  = $(IPBOX55_PATCHES_24)
DRIVER_PLATFORM   += IPBOX55=ipbox55
endif
ifeq ($(BOXTYPE), ipbox99)
KERNEL_PATCHES_24  = $(IPBOX99_PATCHES_24)
endif
ifeq ($(BOXTYPE), ipbox9900)
KERNEL_PATCHES_24  = $(IPBOX9900_PATCHES_24)
DRIVER_PLATFORM   += IPBOX9900=ipbox9900
endif
ifeq ($(BOXTYPE), cuberevo)
KERNEL_PATCHES_24  = $(CUBEREVO_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO=cuberevo
endif
ifeq ($(BOXTYPE), cuberevo_mini)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI=cuberevo_mini
endif
ifeq ($(BOXTYPE), cuberevo_mini2)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI2_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI2=cuberevo_mini2
endif
ifeq ($(BOXTYPE), cuberevo_mini_fta)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_FTA_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_MINI_FTA=cuberevo_mini_fta
endif
ifeq ($(BOXTYPE), cuberevo_250hd)
KERNEL_PATCHES_24  = $(CUBEREVO_250HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_250HD=cuberevo_250hd
endif
ifeq ($(BOXTYPE), cuberevo_2000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_2000HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_2000HD=cuberevo_2000hd
endif
ifeq ($(BOXTYPE), cuberevo_3000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_3000HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_3000HD=cuberevo_3000hd
endif
ifeq ($(BOXTYPE), cuberevo_9500hd)
KERNEL_PATCHES_24  = $(CUBEREVO_9500HD_PATCHES_24)
DRIVER_PLATFORM   += CUBEREVO_9500HD=cuberevo_9500hd
endif
ifeq ($(BOXTYPE), vitamin_hd5000)
KERNEL_PATCHES_24  = $(VITAMIN_HD5000_PATCHES_24)
DRIVER_PLATFORM   += VITAMIN_HD5000=vitamin_hd5000
endif
ifeq ($(BOXTYPE), sagemcom88)
KERNEL_PATCHES_24  = $(SAGEMCOM88_PATCHES_24)
DRIVER_PLATFORM   += SAGEMCOM88=sagemcom88
endif
ifeq ($(BOXTYPE), arivalink200)
KERNEL_PATCHES_24  = $(ARIVALINK200_PATCHES_24)
DRIVER_PLATFORM   += ARIVALINK200=arivalink200
endif
