#
# set up linux environment for other makefiles
#
# -----------------------------------------------------------------------------

#
# arm
#
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7))
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20180424
KERNEL_TYPE            = $(BOXTYPE)
KERNEL_SRC             = linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = $(BOXTYPE)_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_PATCHES_ARM     = $(HD51_PATCHES)
KERNEL_DTB_VER         = bcm7445-bcm97445svmb.dtb
endif

ifeq ($(BOXTYPE), e4hdultra)
KERNEL_VER             = 4.10.12
KERNEL_DATE            = 20180424
KERNEL_TYPE            = $(BOXTYPE)
KERNEL_SRC             = linux-$(KERNEL_VER)-arm.tar.gz
KERNEL_URL             = http://source.mynonpublic.com/gfutures
KERNEL_CONFIG          = $(BOXTYPE)_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_VER)
KERNEL_PATCHES_ARM     = $(E4HDULTRA_PATCHES)
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
KERNEL_TYPE            = $(BOXTYPE)
ifeq ($(BOXTYPE), vuduo4k)
KERNEL_VER             = 4.1.45-1.17
KERNEL_SRC_VER         = 4.1-1.17
KERNEL_PATCHES_ARM     = $(VUDUO4K_PATCHES)
endif
ifeq ($(BOXTYPE), vuduo4kse)
KERNEL_VER             = 4.1.45-1.17
KERNEL_SRC_VER         = 4.1-1.17
KERNEL_PATCHES_ARM     = $(VUDUO4KSE_PATCHES)
endif
ifeq ($(BOXTYPE), vuuno4kse)
KERNEL_VER             = 4.1.20-1.9
KERNEL_SRC_VER         = 4.1-1.9
KERNEL_PATCHES_ARM     = $(VUUNO4KSE_PATCHES)
endif
ifeq ($(BOXTYPE), vuzero4k)
KERNEL_VER             = 4.1.20-1.9
KERNEL_SRC_VER         = 4.1-1.9
KERNEL_PATCHES_ARM     = $(VUZERO4K_PATCHES)
endif
ifeq ($(BOXTYPE), vuultimo4k)
KERNEL_VER             = 3.14.28-1.12
KERNEL_SRC_VER         = 3.14-1.12
KERNEL_PATCHES_ARM     = $(VUULTIMO4K_PATCHES)
endif
ifeq ($(BOXTYPE), vuuno4k)
KERNEL_VER             = 3.14.28-1.12
KERNEL_SRC_VER         = 3.14-1.12
KERNEL_PATCHES_ARM     = $(VUUNO4K_PATCHES)
endif
ifeq ($(BOXTYPE), vusolo4k)
KERNEL_VER             = 3.14.28-1.8
KERNEL_SRC_VER         = 3.14-1.8
KERNEL_PATCHES_ARM     = $(VUSOLO4K_PATCHES)
endif
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
ifeq ($(VU_MULTIBOOT), 1)
KERNEL_CONFIG          = $(BOXTYPE)_defconfig_multi
else
KERNEL_CONFIG          = $(BOXTYPE)_defconfig
endif
KERNEL_DIR             = $(BUILD_TMP)/linux
endif

# -----------------------------------------------------------------------------

#
# mips
#
ifeq ($(BOXTYPE), vuduo)
KERNEL_VER             = 3.9.6
KERNEL_TYPE            = vuduo
KERNEL_SRC_VER         = 3.9.6
KERNEL_SRC             = stblinux-${KERNEL_SRC_VER}.tar.bz2
KERNEL_URL             = http://code.vuplus.com/download/release/kernel
KERNEL_CONFIG          = vuduo_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNEL_PATCHES_MIPS    = $(VUDUO_PATCHES)
endif

ifeq ($(BOXTYPE), dm8000)
KERNEL_VER             = 3.2
KERNEL_TYPE            = dm8000
KERNEL_SRC_VER         = 3.2.68
KERNEL_SRC             = linux-${KERNEL_SRC_VER}.tar.xz
KERNEL_URL             = https://cdn.kernel.org/pub/linux/kernel/v3.x
KERNEL_CONFIG          = dm8000/dm8000_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux-$(KERNEL_SRC_VER)
KERNEL_PATCHES_MIPS    = $(DM8000_PATCHES)
endif

# -----------------------------------------------------------------------------

#
# sh4
#
ifeq ($(BOXARCH), sh4)
KERNEL_VER             = 2.6.32.71_stm24_0217
KERNEL_REVISION        = 3ec500f4212f9e4b4d2537c8be5ea32ebf68c43b
STM_KERNEL_HEADERS_VER = 2.6.32.46-48
P0217                  = p0217

split_version=$(subst _, ,$(1))
KERNEL_UPSTREAM    =$(word 1,$(call split_version,$(KERNEL_VER)))
KERNEL_STM        :=$(word 2,$(call split_version,$(KERNEL_VER)))
KERNEL_LABEL      :=$(word 3,$(call split_version,$(KERNEL_VER)))
KERNEL_RELEASE    :=$(subst ^0,,^$(KERNEL_LABEL))
KERNEL_STM_LABEL  :=_$(KERNEL_STM)_$(KERNEL_LABEL)
KERNEL_DIR         =$(BUILD_TMP)/linux-sh4-$(KERNEL_VER)
endif

# -----------------------------------------------------------------------------

DEPMOD = $(HOST_DIR)/bin/depmod
