TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config find-help2man
TOOLCHECK += find-cmake find-gperf

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK) preqs
	@echo "All required tools seem to be installed."
	@echo
ifeq ($(BOXARCH), sh4)
	@for i in audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111; do \
		if [ ! -e $(SKEL_ROOT)/boot/$$i.elf ]; then \
			echo -e "\n    ERROR: One or more .elf files are missing in $(SKEL_ROOT)/boot!"; \
			echo "           $$i.elf is one of them"; \
			echo; \
			echo "    Correct this and retry."; \
			echo; \
		fi; \
	done
endif
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

#
# host_pkgconfig
#
HOST_PKGCONFIG_VER = 0.29.2
HOST_PKGCONFIG_SOURCE = pkg-config-$(HOST_PKGCONFIG_VER).tar.gz

$(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE):
	$(DOWNLOAD) https://pkgconfig.freedesktop.org/releases/$(HOST_PKGCONFIG_SOURCE)

$(D)/host_pkgconfig: $(D)/directories $(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(UNTAR)/$(HOST_PKGCONFIG_SOURCE)
	$(CHDIR)/pkg-config-$(HOST_PKGCONFIG_VER); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--program-prefix=$(TARGET)- \
			--disable-host-tool \
			--with-pc_path=$(PKG_CONFIG_PATH) \
		; \
		$(MAKE); \
		$(MAKE) install
	ln -sf $(TARGET)-pkg-config $(HOST_DIR)/bin/pkg-config
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(TOUCH)

#
# host_module_init_tools
#
HOST_MODULE_INIT_TOOLS_VER = $(MODULE_INIT_TOOLS_VER)
HOST_MODULE_INIT_TOOLS_SOURCE = $(MODULE_INIT_TOOLS_SOURCE)
HOST_MODULE_INIT_TOOLS_PATCH = module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER).patch

$(D)/host_module_init_tools: $(D)/directories $(ARCHIVE)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(UNTAR)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(CHDIR)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER); \
		$(call apply_patches,$(HOST_MODULE_INIT_TOOLS_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# host_mtd_utils
#
HOST_MTD_UTILS_VER = $(MTD_UTILS_VER)
HOST_MTD_UTILS_SOURCE = $(MTD_UTILS_SOURCE)
HOST_MTD_UTILS_PATCH = host-mtd-utils-$(HOST_MTD_UTILS_VER).patch
HOST_MTD_UTILS_PATCH += host-mtd-utils-$(HOST_MTD_UTILS_VER)-sysmacros.patch

$(D)/host_mtd_utils: $(D)/directories $(ARCHIVE)/$(HOST_MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(UNTAR)/$(HOST_MTD_UTILS_SOURCE)
	$(CHDIR)/mtd-utils-$(HOST_MTD_UTILS_VER); \
		$(call apply_patches,$(HOST_MTD_UTILS_PATCH)); \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(HOST_DIR); \
		$(MAKE) install DESTDIR=$(HOST_DIR)/bin
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(TOUCH)

#
# host_mkcramfs
#
HOST_MKCRAMFS_VER = 1.1
HOST_MKCRAMFS_SOURCE = cramfs-$(HOST_MKCRAMFS_VER).tar.gz
HOST_MKCRAMFS_PATCH = cramfs-$(HOST_MKCRAMFS_VER)-sysmacros.patch

$(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/cramfs/files/cramfs/$(HOST_MKCRAMFS_VER)/$(HOST_MKCRAMFS_SOURCE)

$(D)/host_mkcramfs: $(D)/directories $(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(UNTAR)/$(HOST_MKCRAMFS_SOURCE)
	$(CHDIR)/cramfs-$(HOST_MKCRAMFS_VER); \
		$(call apply_patches,$(HOST_MKCRAMFS_PATCH)); \
		$(MAKE) all
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/mkcramfs $(HOST_DIR)/bin
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/cramfsck $(HOST_DIR)/bin
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(TOUCH)

#
# host_mksquashfs3
#
HOST_MKSQUASHFS3_VER = 3.3
HOST_MKSQUASHFS3_SOURCE = squashfs$(HOST_MKSQUASHFS3_VER).tar.gz

$(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/squashfs/files/OldFiles/$(HOST_MKSQUASHFS3_SOURCE)

$(D)/host_mksquashfs3: directories $(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE)
	$(START_BUILD)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS3_SOURCE)
	$(CHDIR)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools; \
		$(MAKE) CC=gcc all
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/mksquashfs $(HOST_DIR)/bin/mksquashfs3.3
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/unsquashfs $(HOST_DIR)/bin/unsquashfs3.3
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(TOUCH)

#
# host_mksquashfs with LZMA support
#
HOST_MKSQUASHFS_VER = 4.2
HOST_MKSQUASHFS_SOURCE = squashfs$(HOST_MKSQUASHFS_VER).tar.gz
HOST_MKSQUASHFS_PATCH = squashfs-$(HOST_MKSQUASHFS_VER)-sysmacros.patch
ifeq ($(AUTOCONF_NEW),1)
HOST_MKSQUASHFS_PATCH += squashfs-$(HOST_MKSQUASHFS_VER)-fix.patch
endif

LZMA_VER = 4.65
LZMA_SOURCE = lzma-$(LZMA_VER).tar.bz2

$(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/squashfs/files/squashfs/squashfs$(HOST_MKSQUASHFS_VER)/$(HOST_MKSQUASHFS_SOURCE)

$(ARCHIVE)/$(LZMA_SOURCE):
	$(DOWNLOAD) http://downloads.openwrt.org/sources/$(LZMA_SOURCE)

$(D)/host_mksquashfs: directories $(ARCHIVE)/$(LZMA_SOURCE) $(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lzma-$(LZMA_VER)
	$(UNTAR)/$(LZMA_SOURCE)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS_SOURCE)
	$(CHDIR)/squashfs$(HOST_MKSQUASHFS_VER); \
		$(call apply_patches,$(HOST_MKSQUASHFS_PATCH)); \
		$(MAKE) -C squashfs-tools \
			LZMA_SUPPORT=1 \
			LZMA_DIR=$(BUILD_TMP)/lzma-$(LZMA_VER) \
			XATTR_SUPPORT=0 \
			XATTR_DEFAULT=0 \
			install INSTALL_DIR=$(HOST_DIR)/bin
	$(REMOVE)/lzma-$(LZMA_VER)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(TOUCH)

#
# host_parted
#
HOST_PARTED_VER = $(PARTED_VER)
HOST_PARTED_SOURCE = $(PARTED_SOURCE)
HOST_PARTED_PATCH = $(PARTED_PATCH)

$(D)/host_parted: $(D)/directories $(ARCHIVE)/$(HOST_PARTED_SOURCE)
	$(START_BUILD)
	$(REMOVE)/parted-$(HOST_PARTED_VER)
	$(UNTAR)/$(HOST_PARTED_SOURCE)
	$(CHDIR)/parted-$(HOST_PARTED_VER); \
		$(call apply_patches,$(HOST_PARTED_PATCH)); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
			--disable-device-mapper \
			--without-readline \
		; \
		$(MAKE) install
	$(REMOVE)/parted-$(HOST_PARTED_VER)
	$(TOUCH)

#
# host_resize2fs
#
HOST_E2FSPROGS_VER = $(E2FSPROGS_VER)
HOST_E2FSPROGS_SOURCE = $(E2FSPROGS_SOURCE)

$(D)/host_resize2fs: $(D)/directories $(ARCHIVE)/$(HOST_E2FSPROGS_SOURCE)
	$(START_BUILD)
	$(UNTAR)/$(HOST_E2FSPROGS_SOURCE)
	$(CHDIR)/e2fsprogs-$(HOST_E2FSPROGS_VER); \
		./configure $(SILENT_OPT); \
		$(MAKE)
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/resize/resize2fs $(HOST_DIR)/bin/
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/misc/mke2fs $(HOST_DIR)/bin/
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext2
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext3
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4
	ln -sf mke2fs $(HOST_DIR)/bin/mkfs.ext4dev
	install -D -m 0755 $(BUILD_TMP)/e2fsprogs-$(HOST_E2FSPROGS_VER)/e2fsck/e2fsck $(HOST_DIR)/bin/
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext2
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext3
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4
	ln -sf e2fsck $(HOST_DIR)/bin/fsck.ext4dev
	$(REMOVE)/e2fsprogs-$(HOST_E2FSPROGS_VER)
	$(TOUCH)

#
# host dm buildimage
#
BUILDIMAGE_PATCH = buildimage.patch

$(D)/buildimage: $(D)/bootstrap $(ARCHIVE)/$(BUILDIMAGE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/buildimage
	set -e; if [ -d $(ARCHIVE)/buildimage.git ]; \
		then cd $(ARCHIVE)/buildimage.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/oe-mirrors/buildimage.git buildimage.git; \
		fi
	cp -ra $(ARCHIVE)/buildimage.git $(BUILD_TMP)/buildimage
	$(CHDIR)/buildimage; \
		$(call apply_patches,$(BUILDIMAGE_PATCH)); \
		autoreconf -fi; \
		./configure; \
		$(MAKE); \
	install -m 755 $(BUILD_TMP)/buildimage/src/buildimage $(HOST_DIR)/bin
	$(REMOVE)/buildimage
	$(TOUCH)

#
# dm8000 second stage loader #84
#
DM8000_2ND_SOURCE = secondstage-dm8000-84.bin
#DM8000_2ND_URL = http://sources.dreamboxupdate.com/download/7020/$(DM8000_2ND_SOURCE)
DM8000_2ND_URL = https://github.com/oe-mirrors/dreambox/raw/main/$(DM8000_2ND_SOURCE)

$(ARCHIVE)/$(DM8000_2ND_SOURCE):
	$(DOWNLOAD) $(DM8000_2ND_URL)

$(D)/dm8000_2nd: $(ARCHIVE)/$(DM8000_2ND_SOURCE)
	$(START_BUILD)
	$(TOUCH)

#
# qrencode
#
HOST_QRENCODE_VER = 4.1.1
HOST_QRENCODE_SOURCE = qrencode-$(HOST_QRENCODE_VER).tar.gz

$(ARCHIVE)/$(HOST_QRENCODE_SOURCE):
	$(DOWNLOAD) https://fukuchi.org/works/qrencode/$(HOST_QRENCODE_SOURCE)

$(D)/host_qrencode: $(D)/directories $(ARCHIVE)/$(HOST_QRENCODE_SOURCE)
	$(START_BUILD)
	$(UNTAR)/$(HOST_QRENCODE_SOURCE)
	$(CHDIR)/qrencode-$(HOST_QRENCODE_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		export PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig; \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/qrencode-$(HOST_QRENCODE_VER)
	$(TOUCH)

#
# bootstrap
#
BOOTSTRAP  = $(D)/directories
BOOTSTRAP += $(CROSSTOOL)
BOOTSTRAP += $(D)/ccache
BOOTSTRAP += $(TARGET_DIR)/lib/libc.so.6
BOOTSTRAP += $(D)/host_pkgconfig
ifeq ($(BOXARCH), arm)
BOOTSTRAP += $(D)/host_parted
BOOTSTRAP += $(D)/host_resize2fs
endif
ifeq ($(BOXARCH), sh4)
BOOTSTRAP += $(D)/host_module_init_tools
BOOTSTRAP += $(D)/host_mtd_utils
BOOTSTRAP += $(D)/host_mkcramfs
BOOTSTRAP += $(D)/host_mksquashfs
endif
BOOTSTRAP += $(D)/host_qrencode

$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

#
# system-tools
#
SYSTEM_TOOLS  = $(D)/busybox
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
SYSTEM_TOOLS += $(D)/bash
endif
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
#SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/fbshot
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
SYSTEM_TOOLS += $(D)/ofgwrite
SYSTEM_TOOLS += $(D)/f2fs-tools
endif
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	@touch $@

#
# preqs
#
#
$(DRIVER_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repository'
	@echo '===================================================================='
	if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi

$(TOOLS_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_TOOLS)-tools git repository'
	@echo '===================================================================='
	if [ ! -e $(TOOLS_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_TOOLS)/tools.git tools; \
	fi

$(FLASH_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_FLASH)-flash git repository'
	@echo '===================================================================='
	if [ ! -e $(FLASH_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_FLASH)/flash.git flash; \
	fi
	@echo ''

PREQS  = $(DRIVER_DIR)
PREQS += $(TOOLS_DIR)
PREQS += $(FLASH_DIR)

preqs: $(PREQS)
	@mkdir -p $(OWN_BUILD)/neutrino-hd
	@mkdir -p $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)

#
# directories
#
$(D)/directories:
	$(START_BUILD)
	test -d $(D) || mkdir $(D)
	test -d $(ARCHIVE) || mkdir $(ARCHIVE)
	test -d $(STL_ARCHIVE) || mkdir $(STL_ARCHIVE)
	test -d $(BUILD_TMP) || mkdir $(BUILD_TMP)
	test -d $(SOURCE_DIR) || mkdir $(SOURCE_DIR)
	test -d $(RELEASE_IMAGE_DIR) || mkdir $(RELEASE_IMAGE_DIR)
	install -d $(TARGET_DIR)
	install -d $(CROSS_DIR)
	install -d $(BOOT_DIR)
	install -d $(HOST_DIR)
	install -d $(HOST_DIR)/{bin,lib,share}
	install -d $(TARGET_DIR)/{bin,boot,etc,lib,sbin,usr,var}
	install -d $(TARGET_DIR)/etc/{init.d,mdev,network,rc.d}
	install -d $(TARGET_DIR)/etc/rc.d/{rc0.d,rc6.d}
	ln -sf ../init.d $(TARGET_DIR)/etc/rc.d/init.d
	install -d $(TARGET_DIR)/lib/{lsb,firmware}
	install -d $(TARGET_DIR)/usr/{bin,lib,sbin,share}
	install -d $(TARGET_LIB_DIR)/pkgconfig
	install -d $(TARGET_INCLUDE_DIR)/linux
	install -d $(TARGET_INCLUDE_DIR)/linux/dvb
	install -d $(TARGET_DIR)/var/{etc,lib,run}
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	install -d $(TARGET_DIR)/var/lib/{misc,nfs,opkg}
else
	install -d $(TARGET_DIR)/var/lib/{misc,nfs}
endif
	install -d $(TARGET_DIR)/var/bin
	$(TOUCH)

#
# ccache
#
CCACHE_BINDIR = $(HOST_DIR)/bin
CCACHE_BIN = $(CCACHE)

CCACHE_DIR = $(HOME)/.ccache-bs-$(BOXARCH)-ddt/gcc-$(BS_GCC_VER)-kernel-$(KERNEL_VER)
export CCACHE_DIR

HOST_CCACHE_LINKS = \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/cc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/g++

TARGET_CCACHE_LINKS = \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-g++

CCACHE_ENV = \
	install -d $(CCACHE_BINDIR); \
	$(HOST_CCACHE_LINKS); \
	$(TARGET_CCACHE_LINKS)

$(D)/ccache:
	$(CCACHE_ENV)
	touch $@

# hack to make sure they are always copied
PHONY += ccache
