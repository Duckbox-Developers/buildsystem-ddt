#
# busybox
#
ifeq ($(BUSYBOX_SNAPSHOT), 1)
BUSYBOX_VER = snapshot
BB_SNAPSHOT =
else
BUSYBOX_VER = 1.35.0
BB_SNAPSHOT = -$(BUSYBOX_VER)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VER).tar.bz2
endif
BUSYBOX_PATCH  = busybox-$(BUSYBOX_VER)-nandwrite.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-unicode.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-extra.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-extra2.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-flashcp-small-output.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-block-telnet-internet.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-recursive_action-fix.patch
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4 mips))
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-sh4-mips-revert_ifa_flags.patch
endif

ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VER).config_arm
else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 ufs912 ufs913))
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VER).config_nandwrite
else
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VER).config
endif

ifeq ($(BUSYBOX_SNAPSHOT), 1)
#BUSYBOX_PATCH += busybox-snapshot-tar-fix.patch
#BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-changed_FreeBSD_fix.patch
$(D)/busybox: $(D)/bootstrap $(PATCHES)/$(BUSYBOX_CONFIG)
	$(START_BUILD)
	$(REMOVE)/busybox$(BB_SNAPSHOT)
	set -e; if [ -d $(ARCHIVE)/busybox.git ]; \
		then cd $(ARCHIVE)/busybox.git; git pull || true; \
		else cd $(ARCHIVE); git clone git://git.busybox.net/busybox.git busybox.git; \
		fi
	cp -ra $(ARCHIVE)/busybox.git $(BUILD_TMP)/busybox$(BB_SNAPSHOT)
else
$(ARCHIVE)/$(BUSYBOX_SOURCE):
	$(DOWNLOAD) https://busybox.net/downloads/$(BUSYBOX_SOURCE)

$(D)/busybox: $(D)/bootstrap $(ARCHIVE)/$(BUSYBOX_SOURCE) $(PATCHES)/$(BUSYBOX_CONFIG)
	$(START_BUILD)
	$(REMOVE)/busybox$(BB_SNAPSHOT)
	$(UNTAR)/$(BUSYBOX_SOURCE)
endif
	$(CHDIR)/busybox$(BB_SNAPSHOT); \
		$(call apply_patches, $(BUSYBOX_PATCH)); \
		install -m 0644 $(lastword $^) .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGET_DIR)"#' .config; \
		$(BUILDENV) \
		$(MAKE) busybox ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		$(MAKE) install ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" CONFIG_PREFIX=$(TARGET_DIR)
	$(REMOVE)/busybox$(BB_SNAPSHOT)
	$(TOUCH)

#
# bash
#
BASH_VER = 5.0
BASH_SOURCE = bash-$(BASH_VER).tar.gz
BASH_PATCH = $(PATCHES)/bash

$(ARCHIVE)/$(BASH_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/bash/$(BASH_SOURCE)

$(D)/bash: $(D)/bootstrap $(ARCHIVE)/$(BASH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/bash-$(BASH_VER)
	$(UNTAR)/$(BASH_SOURCE)
	$(CHDIR)/bash-$(BASH_VER); \
		$(call apply_patches, $(BASH_PATCH),p0); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--docdir=/.remove \
			--localedir=/.remove \
			--htmldir=/.remove \
			--disable-nls \
			--disable-rpath \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		cd $(TARGET_DIR)/bin && rm -f bash && ln -sf /usr/bin/bash bash
		rm -f $(TARGET_DIR)/usr/bin/bashbug
		rm -f $(TARGET_LIB_DIR)/bash/{loadables.h,Makefile.inc}
	$(REMOVE)/bash-$(BASH_VER)
	$(TOUCH)

#
# mtd_utils
#
MTD_UTILS_VER = 1.5.2
MTD_UTILS_SOURCE = mtd-utils-$(MTD_UTILS_VER).tar.bz2
MTD_UTILS_PATCH = host-mtd-utils-$(MTD_UTILS_VER).patch
MTD_UTILS_PATCH += host-mtd-utils-$(MTD_UTILS_VER)-sysmacros.patch

$(ARCHIVE)/$(MTD_UTILS_SOURCE):
	$(DOWNLOAD) ftp://ftp.infradead.org/pub/mtd-utils/$(MTD_UTILS_SOURCE)

$(D)/mtd_utils: $(D)/bootstrap $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/$(MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(UNTAR)/$(MTD_UTILS_SOURCE)
	$(CHDIR)/mtd-utils-$(MTD_UTILS_VER); \
		$(call apply_patches, $(MTD_UTILS_PATCH)); \
		$(BUILDENV) \
		$(MAKE) PREFIX= CC=$(TARGET)-gcc LD=$(TARGET)-ld STRIP=$(TARGET)-strip WITHOUT_XATTR=1 DESTDIR=$(TARGET_DIR); \
		cp -a $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER)/mkfs.jffs2 $(TARGET_DIR)/usr/sbin
		cp -a $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER)/sumtool $(TARGET_DIR)/usr/sbin
#		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(TOUCH)

#
# module_init_tools
#
MODULE_INIT_TOOLS_VER = 3.16
MODULE_INIT_TOOLS_SOURCE = module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.bz2
MODULE_INIT_TOOLS_PATCH = module-init-tools-$(MODULE_INIT_TOOLS_VER).patch

$(ARCHIVE)/$(MODULE_INIT_TOOLS_SOURCE):
	$(DOWNLOAD) ftp.be.debian.org/pub/linux/utils/kernel/module-init-tools/$(MODULE_INIT_TOOLS_SOURCE)

$(D)/module_init_tools: $(D)/bootstrap $(D)/lsb $(ARCHIVE)/$(MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(UNTAR)/$(MODULE_INIT_TOOLS_SOURCE)
	$(CHDIR)/module-init-tools-$(MODULE_INIT_TOOLS_VER); \
		$(call apply_patches, $(MODULE_INIT_TOOLS_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--program-suffix="" \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-builddir \
		; \
		$(MAKE); \
		$(MAKE) install sbin_PROGRAMS="depmod modinfo" bin_PROGRAMS= DESTDIR=$(TARGET_DIR)
	$(call adapted-etc-files, $(MODULE_INIT_TOOLS_ADAPTED_ETC_FILES))
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# sysvinit
#
SYSVINIT_VER = 3.04
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VER).tar.xz
SYSVINIT_PATCH  = sysvinit-$(SYSVINIT_VER)-crypt-lib.patch
SYSVINIT_PATCH += sysvinit-$(SYSVINIT_VER)-change-INIT_FIFO.patch
SYSVINIT_PATCH += sysvinit-$(SYSVINIT_VER)-remove-killall5.patch

$(ARCHIVE)/$(SYSVINIT_SOURCE):
	$(DOWNLOAD) https://download.savannah.gnu.org/releases/sysvinit/$(SYSVINIT_SOURCE)

$(D)/sysvinit: $(D)/bootstrap $(ARCHIVE)/$(SYSVINIT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sysvinit-$(SYSVINIT_VER)
	$(UNTAR)/$(SYSVINIT_SOURCE)
	$(CHDIR)/sysvinit-$(SYSVINIT_VER); \
		$(call apply_patches, $(SYSVINIT_PATCH)); \
		sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
		-e '/bootlogd/d' -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile; \
		$(BUILDENV) \
		$(MAKE) SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGET_DIR) MANDIR=/.remove
	rm -f $(addprefix $(TARGET_DIR)/sbin/,fstab-decode runlevel telinit)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,lastb)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 cuberevo cuberevo_mini2 cuberevo_2000hd cuberevo_3000hd))
	install -m 644 $(SKEL_ROOT)/etc/inittab_ttyAS1 $(TARGET_DIR)/etc/inittab
else
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 vuduo vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k dm8000))
	install -m 644 $(SKEL_ROOT)/etc/inittab_ttyS0 $(TARGET_DIR)/etc/inittab
else
	install -m 644 $(SKEL_ROOT)/etc/inittab $(TARGET_DIR)/etc/inittab
endif
endif
	$(REMOVE)/sysvinit-$(SYSVINIT_VER)
	$(TOUCH)

#
# gdb-remote
#
GDB_VER = 7.8
GDB_SOURCE = gdb-$(GDB_VER).tar.xz
GDB_PATCH = gdb-$(GDB_VER)-remove-builddate.patch

$(ARCHIVE)/$(GDB_SOURCE):
	$(DOWNLOAD) ftp://sourceware.org/pub/gdb/releases/$(GDB_SOURCE)

# gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/gdb-$(GDB_VER); \
		./configure \
			--nfp --disable-werror \
			--prefix=$(HOST_DIR) \
			--build=$(BUILD) \
			--host=$(BUILD) \
			--target=$(TARGET) \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb
	$(REMOVE)/gdb-$(GDB_VER)
	$(TOUCH)

#
# gdb
#
# gdb built for target or local-PC
$(D)/gdb: $(D)/bootstrap $(D)/ncurses $(D)/zlib $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/$(GDB_SOURCE)
	$(CHDIR)/gdb-$(GDB_VER); \
		$(call apply_patches, $(GDB_PATCH)); \
		./configure \
			--host=$(BUILD) \
			--build=$(BUILD) \
			--target=$(TARGET) \
			--prefix=/usr \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--mandir=$(TARGET_DIR)/.remove \
			--infodir=$(TARGET_DIR)/.remove \
			--datarootdir=$(TARGET_DIR)/.remove \
			--nfp \
			--disable-werror \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb prefix=$(TARGET_DIR)
	$(REMOVE)/gdb-$(GDB_VER)
	$(TOUCH)

#
# valgrind
#
VALGRIND_VER = 3.13.0
VALGRIND_SOURCE = valgrind-$(VALGRIND_VER).tar.bz2

$(ARCHIVE)/$(VALGRIND_SOURCE):
	$(DOWNLOAD) ftp://sourceware.org/pub/valgrind/$(VALGRIND_SOURCE)

$(D)/valgrind: $(D)/bootstrap $(ARCHIVE)/$(VALGRIND_SOURCE)
	$(START_BUILD)
	$(REMOVE)/valgrind-$(VALGRIND_VER)
	$(UNTAR)/$(VALGRIND_SOURCE)
	$(CHDIR)/valgrind-$(VALGRIND_VER); \
		sed -i -e "s#armv7#arm#g" configure; \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--datadir=/.remove \
			-enable-only32bit \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_LIB_DIR)/valgrind/,*.a *.xml)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cg_* callgrind_* ms_print)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/valgrind.pc
	$(REMOVE)/valgrind-$(VALGRIND_VER)
	$(TOUCH)

#
# host_opkg
#
OPKG_VER = 0.3.3
OPKG_SOURCE = opkg-$(OPKG_VER).tar.gz
OPKG_PATCH = opkg-$(OPKG_VER).patch
OPKG_HOST_PATCH = opkg-$(OPKG_VER).patch

$(ARCHIVE)/$(OPKG_SOURCE):
	$(DOWNLOAD) https://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/$(OPKG_SOURCE)

$(D)/host_opkg: directories $(D)/host_libarchive $(ARCHIVE)/$(OPKG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/$(OPKG_SOURCE)
	$(CHDIR)/opkg-$(OPKG_VER); \
		$(call apply_patches, $(OPKG_HOST_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		CFLAGS="-I$(HOST_DIR)/include" \
		LDFLAGS="-L$(HOST_DIR)/lib" \
		./configure $(SILENT_OPT) \
			PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
			--prefix= \
			--disable-curl \
			--disable-gpg \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(TOUCH)

#
# opkg
#
$(D)/opkg: $(D)/bootstrap $(D)/host_opkg $(D)/libarchive $(ARCHIVE)/$(OPKG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/$(OPKG_SOURCE)
	$(CHDIR)/opkg-$(OPKG_VER); \
		$(call apply_patches, $(OPKG_PATCH)); \
		LIBARCHIVE_LIBS="-L$(TARGET_LIB_DIR) -larchive" \
		LIBARCHIVE_CFLAGS="-I$(TARGET_INCLUDE_DIR)" \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-curl \
			--disable-gpg \
			--mandir=/.remove \
		; \
		$(MAKE) all ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -d -m 0755 $(TARGET_LIB_DIR)/opkg
	install -d -m 0755 $(TARGET_DIR)/etc/opkg
	ln -sf opkg $(TARGET_DIR)/usr/bin/opkg-cl
	$(REWRITE_LIBTOOL)/libopkg.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	$(REMOVE)/opkg-$(OPKG_VER)
	$(TOUCH)

#
# lsb
#
LSB_MAJOR = 3.2
LSB_MINOR = 20
LSB_VER = $(LSB_MAJOR)-$(LSB_MINOR)
LSB_SOURCE = lsb_$(LSB_VER).tar.gz

$(ARCHIVE)/$(LSB_SOURCE):
	$(DOWNLOAD) https://debian.sdinet.de/etch/sdinet/lsb/$(LSB_SOURCE)

$(D)/lsb: $(D)/bootstrap $(ARCHIVE)/$(LSB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(UNTAR)/$(LSB_SOURCE)
	$(CHDIR)/lsb-$(LSB_MAJOR); \
		install -m 0644 init-functions $(TARGET_DIR)/lib/lsb
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(TOUCH)

#
# portmap
#
PORTMAP_VER = 6.0.0
PORTMAP_SOURCE = portmap_$(PORTMAP_VER).orig.tar.gz
PORTMAP_PATCH = portmap-$(PORTMAP_VER).patch

$(ARCHIVE)/$(PORTMAP_SOURCE):
	$(DOWNLOAD) https://merges.ubuntu.com/p/portmap/$(PORTMAP_SOURCE)

$(ARCHIVE)/portmap_$(PORTMAP_VER)-3.diff.gz:
	$(DOWNLOAD) https://merges.ubuntu.com/p/portmap/portmap_$(PORTMAP_VER)-3.diff.gz

$(D)/portmap: $(D)/bootstrap $(D)/lsb $(ARCHIVE)/$(PORTMAP_SOURCE) $(ARCHIVE)/portmap_$(PORTMAP_VER)-3.diff.gz
	$(START_BUILD)
	$(REMOVE)/portmap-$(PORTMAP_VER)
	$(UNTAR)/$(PORTMAP_SOURCE)
	$(CHDIR)/portmap-$(PORTMAP_VER); \
		gunzip -cd $(lastword $^) | cat > debian.patch; \
		patch -p1 $(SILENT_PATCH) <debian.patch && \
		sed -e 's/### BEGIN INIT INFO/# chkconfig: S 41 10\n### BEGIN INIT INFO/g' -i debian/init.d; \
		$(call apply_patches, $(PORTMAP_PATCH)); \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc"; \
		install -m 0755 portmap $(TARGET_DIR)/sbin; \
		install -m 0755 pmap_dump $(TARGET_DIR)/sbin; \
		install -m 0755 pmap_set $(TARGET_DIR)/sbin; \
		install -m755 debian/init.d $(TARGET_DIR)/etc/init.d/portmap
	$(REMOVE)/portmap-$(PORTMAP_VER)
	$(TOUCH)

#
# e2fsprogs
#
E2FSPROGS_VER = 1.46.5
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VER).tar.gz
E2FSPROGS_PATCH = e2fsprogs-$(E2FSPROGS_VER).patch

ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
E2FSPROGS_ARGS = --enable-resizer
else
E2FSPROGS_ARGS = --disable-resizer
endif

$(ARCHIVE)/$(E2FSPROGS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)/$(E2FSPROGS_SOURCE)

$(D)/e2fsprogs: $(D)/bootstrap $(D)/util_linux $(ARCHIVE)/$(E2FSPROGS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	$(UNTAR)/$(E2FSPROGS_SOURCE)
	$(CHDIR)/e2fsprogs-$(E2FSPROGS_VER); \
		$(call apply_patches, $(E2FSPROGS_PATCH)); \
		PATH=$(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER):$(PATH) \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--libdir=/usr/lib \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-rpath \
			--disable-testio-debug \
			--disable-defrag \
			--disable-nls \
			--disable-jbd-debug \
			--disable-blkid-debug \
			--disable-testio-debug \
			--disable-debugfs \
			--disable-imager \
			$(E2FSPROGS_ARGS) \
			--disable-backtrace \
			--disable-mmp \
			--disable-tdb \
			--disable-bmap-stats \
			--disable-fuse2fs \
			--disable-bmap-stats \
			--disable-bmap-stats-ops \
			--enable-elf-shlibs \
			--enable-fsck \
			--enable-libblkid \
			--enable-libuuid \
			--enable-verbose-makecmds \
			--enable-symlink-install \
			--without-libintl-prefix \
			--without-libiconv-prefix \
			--with-root-prefix="" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C lib/uuid  install DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C lib/blkid install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	rm -f $(addprefix $(TARGET_DIR)/sbin/,badblocks dumpe2fs logsave e2undo)
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,filefrag e2freefrag mklost+found uuidd e4crypt)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,chattr lsattr uuidgen)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	$(TOUCH)

#
# util_linux
#
ifeq ($(BOXARCH), sh4)
UTIL_LINUX_MAJOR = 2.36
UTIL_LINUX_MINOR = .2
else
UTIL_LINUX_MAJOR = 2.38
UTIL_LINUX_MINOR = .1
endif
UTIL_LINUX_VER = $(UTIL_LINUX_MAJOR)$(UTIL_LINUX_MINOR)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VER).tar.xz

$(ARCHIVE)/$(UTIL_LINUX_SOURCE):
	$(DOWNLOAD) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_MAJOR)/$(UTIL_LINUX_SOURCE)

$(D)/util_linux: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(UTIL_LINUX_SOURCE)
	$(START_BUILD)
	$(REMOVE)/util-linux-$(UTIL_LINUX_VER)
	$(UNTAR)/$(UTIL_LINUX_SOURCE)
	$(CHDIR)/util-linux-$(UTIL_LINUX_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-shared \
			--disable-gtk-doc \
			--disable-nls \
			--disable-rpath \
			--enable-libuuid \
			--disable-libblkid \
			--disable-libmount \
			--enable-libsmartcols \
			--disable-mount \
			--disable-partx \
			--disable-mountpoint \
			--disable-fallocate \
			--disable-unshare \
			--disable-nsenter \
			--disable-setpriv \
			--disable-eject \
			--disable-agetty \
			--disable-cramfs \
			--disable-bfs \
			--disable-minix \
			--disable-fdformat \
			--disable-hwclock \
			--disable-wdctl \
			--disable-switch_root \
			--disable-pivot_root \
			--enable-tunelp \
			--disable-kill \
			--disable-last \
			--disable-utmpdump \
			--disable-line \
			--disable-mesg \
			--disable-raw \
			--disable-rename \
			--disable-vipw \
			--disable-newgrp \
			--disable-chfn-chsh \
			--disable-login \
			--disable-login-chown-vcs \
			--disable-login-stat-mail \
			--disable-nologin \
			--disable-sulogin \
			--disable-su \
			--disable-runuser \
			--disable-ul \
			--disable-more \
			--disable-pg \
			--disable-setterm \
			--disable-schedutils \
			--disable-tunelp \
			--disable-wall \
			--disable-write \
			--disable-bash-completion \
			--disable-pylibmount \
			--disable-pg-bell \
			--disable-use-tty-group \
			--disable-makeinstall-chown \
			--disable-makeinstall-setuid \
			--without-audit \
			--without-ncurses \
			--without-ncursesw \
			--without-slang \
			--without-utempter \
			--disable-wall \
			--without-python \
			--disable-makeinstall-chown \
			--without-systemdsystemunitdir \
		; \
		$(MAKE) sfdisk mkfs; \
		install -D -m 755 sfdisk $(TARGET_DIR)/sbin/sfdisk; \
		install -D -m 755 mkfs $(TARGET_DIR)/sbin/mkfs
	$(REMOVE)/util-linux-$(UTIL_LINUX_VER)
	$(TOUCH)

#
# gptfdisk
#
GPTFDISK_VER = 1.0.9
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VER).tar.gz

$(ARCHIVE)/$(GPTFDISK_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VER)/$(GPTFDISK_SOURCE)

$(D)/gptfdisk: $(D)/bootstrap $(D)/e2fsprogs $(D)/ncurses $(D)/libpopt $(ARCHIVE)/$(GPTFDISK_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gptfdisk-$(GPTFDISK_VER)
	$(UNTAR)/$(GPTFDISK_SOURCE)
	$(CHDIR)/gptfdisk-$(GPTFDISK_VER); \
		$(BUILDENV) \
		$(MAKE) sgdisk; \
		install -m755 sgdisk $(TARGET_DIR)/usr/sbin/sgdisk
	$(REMOVE)/gptfdisk-$(GPTFDISK_VER)
	$(TOUCH)

#
# parted
#
PARTED_VER = 3.2
PARTED_SOURCE = parted-$(PARTED_VER).tar.xz
PARTED_PATCH = parted-$(PARTED_VER)-device-mapper.patch

$(ARCHIVE)/$(PARTED_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/parted/$(PARTED_SOURCE)

$(D)/parted: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(PARTED_SOURCE)
	$(START_BUILD)
	$(REMOVE)/parted-$(PARTED_VER)
	$(UNTAR)/$(PARTED_SOURCE)
	$(CHDIR)/parted-$(PARTED_VER); \
		$(call apply_patches, $(PARTED_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--without-readline \
			--disable-shared \
			--disable-dynamic-loading \
			--disable-debug \
			--disable-device-mapper \
			--disable-nls \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REMOVE)/parted-$(PARTED_VER)
	$(TOUCH)

#
# dosfstools
#
DOSFSTOOLS_VER = 4.2
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VER).tar.gz

$(ARCHIVE)/$(DOSFSTOOLS_SOURCE):
	$(DOWNLOAD) https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)/$(DOSFSTOOLS_SOURCE)

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -fomit-frame-pointer -D_FILE_OFFSET_BITS=64

$(D)/dosfstools: bootstrap $(ARCHIVE)/$(DOSFSTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(UNTAR)/$(DOSFSTOOLS_SOURCE)
	$(CHDIR)/dosfstools-$(DOSFSTOOLS_VER); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(TOUCH)

#
# jfsutils
#
JFSUTILS_VER = 1.1.15
JFSUTILS_SOURCE = jfsutils-$(JFSUTILS_VER).tar.gz
JFSUTILS_PATCH = jfsutils-$(JFSUTILS_VER).patch
JFSUTILS_PATCH += jfsutils-$(JFSUTILS_VER)-gcc10_fix.patch

$(ARCHIVE)/$(JFSUTILS_SOURCE):
	$(DOWNLOAD) http://jfs.sourceforge.net/project/pub/$(JFSUTILS_SOURCE)

$(D)/jfsutils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(JFSUTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/jfsutils-$(JFSUTILS_VER)
	$(UNTAR)/$(JFSUTILS_SOURCE)
	$(CHDIR)/jfsutils-$(JFSUTILS_VER); \
		$(call apply_patches, $(JFSUTILS_PATCH)); \
		sed "s@<unistd.h>@&\n#include <sys/types.h>@g" -i fscklog/extract.c; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,jfs_debugfs jfs_fscklog jfs_logdump)
	$(REMOVE)/jfsutils-$(JFSUTILS_VER)
	$(TOUCH)

#
# f2fs-tools
#

F2FS-TOOLS_VER = 1.15.0
F2FS-TOOLS_SOURCE = f2fs-tools-$(F2FS-TOOLS_VER).tar.gz
F2FS-TOOLS_PATCH = f2fs-tools-$(F2FS-TOOLS_VER).patch

$(ARCHIVE)/$(F2FS-TOOLS_SOURCE):
	$(DOWNLOAD) https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/$(F2FS-TOOLS_SOURCE)

$(D)/f2fs-tools: $(D)/bootstrap $(D)/util_linux $(ARCHIVE)/$(F2FS-TOOLS_SOURCE)
	$(REMOVE)/f2fs-tools-$(F2FS-TOOLS_VER)
	$(UNTAR)/$(F2FS-TOOLS_SOURCE)
	$(CHDIR)/f2fs-tools-$(F2FS-TOOLS_VER); \
		$(call apply_patches, $(F2FS-TOOLS_PATCH)); \
		autoreconf -fi; \
		ac_cv_file__git=no \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--without-selinux \
			--without-blkid \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/f2fs-tools-$(F2FS-TOOLS_VER)
	$(TOUCH)

#
# ntfs-3g
#
NTFS_3G_VER = 2017.3.23
NTFS_3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz
NTFS_3G_PATCH = ntfs-3g-fuseint-fix-path-mounted-on-musl.patch
NTFS_3G_PATCH += ntfs-3g-sysmacros.patch

$(ARCHIVE)/$(NTFS_3G_SOURCE):
	$(DOWNLOAD) https://tuxera.com/opensource/$(NTFS_3G_SOURCE)

$(D)/ntfs_3g: $(D)/bootstrap $(ARCHIVE)/$(NTFS_3G_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER)
	$(UNTAR)/$(NTFS_3G_SOURCE)
	$(CHDIR)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER); \
		$(call apply_patches, $(NTFS_3G_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ldconfig \
			--disable-static \
			--disable-ntfsprogs \
			--enable-silent-rules \
			--with-fuse=internal \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libntfs-3g.pc
	$(REWRITE_LIBTOOL)/libntfs-3g.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,lowntfs-3g ntfs-3g.probe)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,mount.lowntfs-3g)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER)
	$(TOUCH)

#
# mc
#
MC_VER = 4.8.28
MC_SOURCE = mc-$(MC_VER).tar.xz
MC_PATCH  = mc-$(MC_VER).patch
ifeq ($(BOXARCH), sh4)
MC_PATCH += mc-$(MC_VER)_sh4.patch
endif

$(ARCHIVE)/$(MC_SOURCE):
	$(DOWNLOAD) ftp.midnight-commander.org/$(MC_SOURCE)

$(D)/mc: $(D)/bootstrap $(D)/ncurses $(D)/libglib2 $(ARCHIVE)/$(MC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mc-$(MC_VER)
	$(UNTAR)/$(MC_SOURCE)
	$(CHDIR)/mc-$(MC_VER); \
		$(call apply_patches, $(MC_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--with-homedir=/var/tuxbox/config/mc \
			--without-gpm-mouse \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--disable-doxygen-html \
			--enable-charset \
			--disable-nls \
			--disable-maintainer-mode \
			--disable-dependency-tracking \
			AWK=awk \
			--disable-rpath \
			--disable-static \
			--disable-silent-rules \
			--with-screen=ncurses \
			--without-x \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/usr/share/mc/examples
	find $(TARGET_DIR)/usr/share/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/mc-$(MC_VER)
	$(TOUCH)

#
# socat
#
SOCAT_VER = 1.7.4.3
SOCAT_SOURCE = socat-$(SOCAT_VER).tar.gz
SOCAT_PATCH = socat-$(SOCAT_VER).patch

$(ARCHIVE)/$(SOCAT_SOURCE):
	$(DOWNLOAD) http://www.dest-unreach.org/socat/download/$(SOCAT_SOURCE)

$(D)/socat: $(D)/bootstrap $(ARCHIVE)/$(SOCAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/socat-$(SOCAT_VER)
	$(UNTAR)/$(SOCAT_SOURCE)
	$(CHDIR)/socat-$(SOCAT_VER); \
		$(call apply_patches, $(SOCAT_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-ip6 \
			--disable-openssl \
			--disable-tun \
			--disable-libwrap \
			--disable-filan \
			--disable-sycls \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/socat-$(SOCAT_VER)
	$(TOUCH)

#
# nano
#
NANO_VER = 2.2.6
NANO_SOURCE = nano-$(NANO_VER).tar.gz

$(ARCHIVE)/$(NANO_SOURCE):
	$(DOWNLOAD) https://www.nano-editor.org/dist/v2.2/$(NANO_SOURCE)

$(D)/nano: $(D)/bootstrap $(ARCHIVE)/$(NANO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/nano-$(NANO_VER)
	$(UNTAR)/$(NANO_SOURCE)
	$(CHDIR)/nano-$(NANO_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-nls \
			--enable-tiny \
			--enable-color \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/nano-$(NANO_VER)
	$(TOUCH)

#
# rsync
#
RSYNC_VER = 3.1.3
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz

$(ARCHIVE)/$(RSYNC_SOURCE):
	$(DOWNLOAD) https://rsync.samba.org/ftp/rsync/src/$(RSYNC_SOURCE)

$(D)/rsync: $(D)/bootstrap $(ARCHIVE)/$(RSYNC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(UNTAR)/$(RSYNC_SOURCE)
	$(CHDIR)/rsync-$(RSYNC_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--disable-debug \
			--disable-locale \
		; \
		$(MAKE) all; \
		$(MAKE) install-all DESTDIR=$(TARGET_DIR)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(TOUCH)

#
# fuse
#
FUSE_VER = 2.9.9
FUSE_SOURCE = fuse-$(FUSE_VER).tar.gz

$(ARCHIVE)/$(FUSE_SOURCE):
	$(DOWNLOAD) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)/$(FUSE_SOURCE)

$(D)/fuse: $(D)/bootstrap $(ARCHIVE)/$(FUSE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fuse-$(FUSE_VER)
	$(UNTAR)/$(FUSE_SOURCE)
	$(CHDIR)/fuse-$(FUSE_VER); \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--disable-static \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		-rm $(TARGET_DIR)/etc/udev/rules.d/99-fuse.rules
		-rmdir $(TARGET_DIR)/etc/udev/rules.d
		-rmdir $(TARGET_DIR)/etc/udev
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REWRITE_LIBTOOL)/libulockmgr.la
	$(REMOVE)/fuse-$(FUSE_VER)
	$(TOUCH)

#
# curlftpfs
#
CURLFTPFS_VER = 0.9.2
CURLFTPFS_SOURCE = curlftpfs-$(CURLFTPFS_VER).tar.gz
CURLFTPFS_PATCH = curlftpfs-$(CURLFTPFS_VER).patch

$(ARCHIVE)/$(CURLFTPFS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/curlftpfs/files/latest/download/$(CURLFTPFS_SOURCE)

$(D)/curlftpfs: $(D)/bootstrap $(D)/libcurl $(D)/fuse $(D)/libglib2 $(ARCHIVE)/$(CURLFTPFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VER)
	$(UNTAR)/$(CURLFTPFS_SOURCE)
	$(CHDIR)/curlftpfs-$(CURLFTPFS_VER); \
		$(call apply_patches, $(CURLFTPFS_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		export ac_cv_func_realloc_0_nonnull=yes; \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VER)
	$(TOUCH)

#
# sdparm
#
SDPARM_VER = 1.12
SDPARM_SOURCE = sdparm-$(SDPARM_VER).tgz
SDPARM_PATCH = sdparm-$(SDPARM_VER).patch

$(ARCHIVE)/$(SDPARM_SOURCE):
	$(DOWNLOAD) http://sg.danny.cz/sg/p/$(SDPARM_SOURCE)

$(D)/sdparm: $(D)/bootstrap $(ARCHIVE)/$(SDPARM_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sdparm-$(SDPARM_VER)
	$(UNTAR)/$(SDPARM_SOURCE)
	$(CHDIR)/sdparm-$(SDPARM_VER); \
		$(call apply_patches, $(SDPARM_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/sbin \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,sas_disk_blink scsi_ch_swp)
	$(REMOVE)/sdparm-$(SDPARM_VER)
	$(TOUCH)

#
# hddtemp
#
HDDTEMP_VER = 0.3-beta15
HDDTEMP_SOURCE = hddtemp-$(HDDTEMP_VER).tar.bz2

$(ARCHIVE)/$(HDDTEMP_SOURCE):
	$(DOWNLOAD) http://savannah.c3sl.ufpr.br/hddtemp/$(HDDTEMP_SOURCE)

$(D)/hddtemp: $(D)/bootstrap $(ARCHIVE)/$(HDDTEMP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hddtemp-$(HDDTEMP_VER)
	$(UNTAR)/$(HDDTEMP_SOURCE)
	$(CHDIR)/hddtemp-$(HDDTEMP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--datadir=/.remove \
			--with-db_path=/var/hddtemp.db \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		install -d $(TARGET_DIR)/var/tuxbox/config
		install -m 644 $(SKEL_ROOT)/release/hddtemp.db $(TARGET_DIR)/var
	$(REMOVE)/hddtemp-$(HDDTEMP_VER)
	$(TOUCH)

#
# hdparm
#
HDPARM_VER = 9.64
HDPARM_SOURCE = hdparm-$(HDPARM_VER).tar.gz

$(ARCHIVE)/$(HDPARM_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/hdparm/files/hdparm/$(HDPARM_SOURCE)

$(D)/hdparm: $(D)/bootstrap $(ARCHIVE)/$(HDPARM_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(UNTAR)/$(HDPARM_SOURCE)
	$(CHDIR)/hdparm-$(HDPARM_VER); \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR) mandir=/.remove
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(TOUCH)

#
# hdidle
#
HDIDLE_VER = 1.05
HDIDLE_SOURCE = hd-idle-$(HDIDLE_VER).tgz
HDIDLE_PATCH = hd-idle-$(HDIDLE_VER).patch

$(ARCHIVE)/$(HDIDLE_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/hd-idle/files/$(HDIDLE_SOURCE)

$(D)/hdidle: $(D)/bootstrap $(ARCHIVE)/$(HDIDLE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hd-idle
	$(UNTAR)/$(HDIDLE_SOURCE)
	$(CHDIR)/hd-idle; \
		$(call apply_patches, $(HDIDLE_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install TARGET_DIR=$(TARGET_DIR) install
	$(REMOVE)/hd-idle
	$(TOUCH)

#
# fbshot
#
FBSHOT_VER = 0.3
FBSHOT_SOURCE = fbshot-$(FBSHOT_VER).tar.gz
FBSHOT_PATCH = fbshot-$(FBSHOT_VER)-$(BOXARCH).patch

$(ARCHIVE)/$(FBSHOT_SOURCE):
	$(DOWNLOAD) http://distro.ibiblio.org/amigolinux/download/Utils/fbshot/$(FBSHOT_SOURCE)

$(D)/fbshot: $(D)/bootstrap $(D)/libpng $(ARCHIVE)/$(FBSHOT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(UNTAR)/$(FBSHOT_SOURCE)
	$(CHDIR)/fbshot-$(FBSHOT_VER); \
		$(call apply_patches, $(FBSHOT_PATCH)); \
		sed -i s~'gcc'~"$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS)"~ Makefile; \
		sed -i 's/strip fbshot/$(TARGET)-strip fbshot/' Makefile; \
		$(MAKE) all; \
		install -D -m 755 fbshot $(TARGET_DIR)/bin/fbshot
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(TOUCH)

#
# sysstat
#
SYSSTAT_VER = 12.6.0
SYSSTAT_SOURCE = sysstat-$(SYSSTAT_VER).tar.bz2

$(ARCHIVE)/$(SYSSTAT_SOURCE):
	$(DOWNLOAD) http://pagesperso-orange.fr/sebastien.godard/$(SYSSTAT_SOURCE)

$(D)/sysstat: $(D)/bootstrap $(ARCHIVE)/$(SYSSTAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sysstat-$(SYSSTAT_VER)
	$(UNTAR)/$(SYSSTAT_SOURCE)
	$(CHDIR)/sysstat-$(SYSSTAT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/sysstat-$(SYSSTAT_VER)
	$(TOUCH)

#
# libnsl
#
LIBNSL_VER    = 2.0.0
LIBNSL_SOURCE = libnsl-$(LIBNSL_VER).tar.gz

$(ARCHIVE)/$(LIBNSL_SOURCE):
	$(DOWNLOAD) https://github.com/thkukuk/libnsl/archive/v$(LIBNSL_VER)/$(LIBNSL_SOURCE)

$(D)/libnsl: $(D)/bootstrap $(ARCHIVE)/$(LIBNSL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnsl-$(LIBNSL_VER)
	$(UNTAR)/$(LIBNSL_SOURCE)
	$(CHDIR)/libnsl-$(LIBNSL_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(CROSS_BASE)/$(TARGET)/sys-root
		cp -a $(CROSS_BASE)/$(TARGET)/sys-root/usr/lib/libnsl.so* $(TARGET_LIB_DIR)
	$(REMOVE)/libnsl-$(LIBNSL_VER)
	$(TOUCH)

#
# autofs
#
AUTOFS_VER = 4.1.4
AUTOFS_SOURCE = autofs-$(AUTOFS_VER).tar.gz
AUTOFS_PATCH = autofs-$(AUTOFS_VER).patch

$(ARCHIVE)/$(AUTOFS_SOURCE):
	$(DOWNLOAD) https://www.kernel.org/pub/linux/daemons/autofs/v4/$(AUTOFS_SOURCE)

ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
AUTOFS_LIBNSL = $(D)/libnsl
endif

$(D)/autofs: $(D)/bootstrap $(D)/e2fsprogs $(AUTOFS_LIBNSL) $(ARCHIVE)/$(AUTOFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/autofs-$(AUTOFS_VER)
	$(UNTAR)/$(AUTOFS_SOURCE)
	$(CHDIR)/autofs-$(AUTOFS_VER); \
		$(call apply_patches, $(AUTOFS_PATCH)); \
		cp aclocal.m4 acinclude.m4; \
		autoconf; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all CC=$(TARGET)-gcc STRIP=$(TARGET)-strip; \
		$(MAKE) install INSTALLROOT=$(TARGET_DIR) SUBDIRS="lib daemon modules"
	install -m 755 $(SKEL_ROOT)/etc/init.d/autofs $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/auto.hotplug $(TARGET_DIR)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.master $(TARGET_DIR)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.misc $(TARGET_DIR)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.network $(TARGET_DIR)/etc/
	ln -sf ../usr/sbin/automount $(TARGET_DIR)/sbin/automount
	$(REMOVE)/autofs-$(AUTOFS_VER)
	$(TOUCH)

#
# shairport
#
$(D)/shairport: $(D)/bootstrap $(D)/openssl $(D)/howl $(D)/alsa_lib
	$(START_BUILD)
	$(REMOVE)/shairport
	set -e; if [ -d $(ARCHIVE)/shairport.git ]; \
		then cd $(ARCHIVE)/shairport.git; git pull; \
		else cd $(ARCHIVE); git clone -b 1.0-dev https://github.com/abrasive/shairport.git shairport.git; \
		fi
	cp -ra $(ARCHIVE)/shairport.git $(BUILD_TMP)/shairport
	$(CHDIR)/shairport; \
		sed -i 's|pkg-config|$$PKG_CONFIG|g' configure; \
		PKG_CONFIG=$(PKG_CONFIG) \
		$(BUILDENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr
	$(REMOVE)/shairport
	$(TOUCH)

#
# shairport-sync
#
$(D)/shairport-sync: $(D)/bootstrap $(D)/libdaemon $(D)/libpopt $(D)/libconfig $(D)/openssl $(D)/alsa_lib
	$(START_BUILD)
	$(REMOVE)/shairport-sync
	set -e; if [ -d $(ARCHIVE)/shairport-sync.git ]; \
		then cd $(ARCHIVE)/shairport-sync.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/mikebrady/shairport-sync.git shairport-sync.git; \
		fi
	cp -ra $(ARCHIVE)/shairport-sync.git $(BUILD_TMP)/shairport-sync
	$(CHDIR)/shairport-sync; \
		autoreconf -fi $(SILENT_OPT); \
		PKG_CONFIG=$(PKG_CONFIG) \
		$(BUILDENV) \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-alsa \
			--with-ssl=openssl \
			--with-metadata \
			--with-tinysvcmdns \
			--with-pipe \
			--with-stdout \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/shairport-sync
	$(TOUCH)

#
# dbus
#
DBUS_VER = 1.12.6
DBUS_SOURCE = dbus-$(DBUS_VER).tar.gz

$(ARCHIVE)/$(DBUS_SOURCE):
	$(DOWNLOAD) https://dbus.freedesktop.org/releases/dbus/$(DBUS_SOURCE)

$(D)/dbus: $(D)/bootstrap $(D)/expat $(ARCHIVE)/$(DBUS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dbus-$(DBUS_VER)
	$(UNTAR)/$(DBUS_SOURCE)
	$(CHDIR)/dbus-$(DBUS_VER); \
		$(CONFIGURE) \
		CFLAGS="$(TARGET_CFLAGS) -Wno-cast-align" \
			--without-x \
			--prefix=/usr \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--with-console-auth-dir=/run/console/ \
			--without-systemdsystemunitdir \
			--disable-systemd \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dbus-1.pc
	$(REWRITE_LIBTOOL)/libdbus-1.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,dbus-cleanup-sockets dbus-daemon dbus-launch dbus-monitor)
	$(REMOVE)/dbus-$(DBUS_VER)
	$(TOUCH)

#
# avahi
#
AVAHI_VER = 0.7
AVAHI_SOURCE = avahi-$(AVAHI_VER).tar.gz

$(ARCHIVE)/$(AVAHI_SOURCE):
	$(DOWNLOAD) https://github.com/lathiat/avahi/releases/download/v$(AVAHI_VER)/$(AVAHI_SOURCE)

$(D)/avahi: $(D)/bootstrap $(D)/expat $(D)/libdaemon $(D)/dbus $(ARCHIVE)/$(AVAHI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/avahi-$(AVAHI_VER)
	$(UNTAR)/$(AVAHI_SOURCE)
	$(CHDIR)/avahi-$(AVAHI_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--target=$(TARGET) \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--with-distro=none \
			--with-avahi-user=nobody \
			--with-avahi-group=nogroup \
			--with-autoipd-user=nobody \
			--with-autoipd-group=nogroup \
			--with-xml=expat \
			--enable-libdaemon \
			--disable-nls \
			--disable-glib \
			--disable-gobject \
			--disable-qt3 \
			--disable-qt4 \
			--disable-gtk \
			--disable-gtk3 \
			--disable-dbm \
			--disable-gdbm \
			--disable-python \
			--disable-pygtk \
			--disable-python-dbus \
			--disable-mono \
			--disable-monodoc \
			--disable-autoipd \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--disable-doxygen-man \
			--disable-doxygen-rtf \
			--disable-doxygen-xml \
			--disable-doxygen-chm \
			--disable-doxygen-chi \
			--disable-doxygen-html \
			--disable-doxygen-ps \
			--disable-doxygen-pdf \
			--disable-core-docs \
			--disable-manpages \
			--disable-xmltoman \
			--disable-tests \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/avahi-core.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/avahi-client.pc
	$(REWRITE_LIBTOOL)/libavahi-common.la
	$(REWRITE_LIBTOOL)/libavahi-core.la
	$(REWRITE_LIBTOOL)/libavahi-client.la
	$(REMOVE)/avahi-$(AVAHI_VER)
	$(TOUCH)

#
# wget
#
WGET_VER = 1.21.3
WGET_SOURCE = wget-$(WGET_VER).tar.gz
WGET_PATCH = wget-$(WGET_VER).patch

$(ARCHIVE)/$(WGET_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/wget/$(WGET_SOURCE)

$(D)/wget: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(WGET_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wget-$(WGET_VER)
	$(UNTAR)/$(WGET_SOURCE)
	$(CHDIR)/wget-$(WGET_VER); \
		$(call apply_patches, $(WGET_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--with-openssl \
			--with-ssl=openssl \
			--with-libssl-prefix=$(TARGET_DIR) \
			--disable-ipv6 \
			--disable-debug \
			--disable-nls \
			--disable-opie \
			--disable-digest \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/wget-$(WGET_VER)
	$(TOUCH)

#
# coreutils
#
COREUTILS_VER = 8.23
COREUTILS_SOURCE = coreutils-$(COREUTILS_VER).tar.xz
COREUTILS_PATCH = coreutils-$(COREUTILS_VER).patch

$(ARCHIVE)/$(COREUTILS_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/coreutils/$(COREUTILS_SOURCE)

$(D)/coreutils: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(COREUTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(UNTAR)/$(COREUTILS_SOURCE)
	$(CHDIR)/coreutils-$(COREUTILS_VER); \
		$(call apply_patches, $(COREUTILS_PATCH)); \
		export fu_cv_sys_stat_statfs2_bsize=yes; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-largefile \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(TOUCH)

#
# smartmontools
#
SMARTMONTOOLS_VER = 7.3
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VER).tar.gz

$(ARCHIVE)/$(SMARTMONTOOLS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)/$(SMARTMONTOOLS_SOURCE)

$(D)/smartmontools: $(D)/bootstrap $(ARCHIVE)/$(SMARTMONTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VER)
	$(UNTAR)/$(SMARTMONTOOLS_SOURCE)
	$(CHDIR)/smartmontools-$(SMARTMONTOOLS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGET_DIR)/usr mandir=./remove
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VER)
	$(TOUCH)

#
# nfs_utils
#
NFS_UTILS_VER = 2.5.3
NFS_UTILS_SOURCE = nfs-utils-$(NFS_UTILS_VER).tar.bz2
NFS_UTILS_PATCH = nfs-utils-$(NFS_UTILS_VER).patch

$(ARCHIVE)/$(NFS_UTILS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/nfs/files/nfs-utils/$(NFS_UTILS_VER)/$(NFS_UTILS_SOURCE)

$(D)/nfs_utils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(NFS_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/nfs-utils-$(NFS_UTILS_VER)
	$(UNTAR)/$(NFS_UTILS_SOURCE)
	$(CHDIR)/nfs-utils-$(NFS_UTILS_VER); \
		$(call apply_patches, $(NFS_UTILS_PATCH)); \
		$(CONFIGURE) \
			CC_FOR_BUILD=$(TARGET)-gcc \
			--prefix=/usr \
			--exec-prefix=/usr \
			--mandir=/.remove \
			--disable-gss \
			--enable-ipv6=no \
			--disable-tirpc \
			--disable-nfsv4 \
			--without-tcp-wrappers \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/nfs-common $(TARGET_DIR)/etc/init.d/
	install -m 755 $(SKEL_ROOT)/etc/init.d/nfs-kernel-server $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/exports $(TARGET_DIR)/etc/
	rm -f $(addprefix $(TARGET_DIR)/sbin/,mount.nfs mount.nfs4 umount.nfs umount.nfs4 osd_login)
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,mountstats nfsiostat sm-notify start-statd)
	$(REMOVE)/nfs-utils-$(NFS_UTILS_VER)
	$(TOUCH)

#
# libevent
#
LIBEVENT_VER = 2.0.21-stable
LIBEVENT_SOURCE = libevent-$(LIBEVENT_VER).tar.gz

$(ARCHIVE)/$(LIBEVENT_SOURCE):
	$(DOWNLOAD) https://github.com/downloads/libevent/libevent/$(LIBEVENT_SOURCE)

$(D)/libevent: $(D)/bootstrap $(ARCHIVE)/$(LIBEVENT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libevent-$(LIBEVENT_VER)
	$(UNTAR)/$(LIBEVENT_SOURCE)
	$(CHDIR)/libevent-$(LIBEVENT_VER);\
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libevent.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libevent_openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libevent_pthreads.pc
	$(REWRITE_LIBTOOL)/libevent_core.la
	$(REWRITE_LIBTOOL)/libevent_extra.la
	$(REWRITE_LIBTOOL)/libevent.la
	$(REWRITE_LIBTOOL)/libevent_openssl.la
	$(REWRITE_LIBTOOL)/libevent_pthreads.la
	$(REMOVE)/libevent-$(LIBEVENT_VER)
	$(TOUCH)

#
# libnfsidmap
#
LIBNFSIDMAP_VER = 0.25
LIBNFSIDMAP_SOURCE = libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz

$(ARCHIVE)/$(LIBNFSIDMAP_SOURCE):
	$(DOWNLOAD) http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/$(LIBNFSIDMAP_SOURCE)

$(D)/libnfsidmap: $(D)/bootstrap $(ARCHIVE)/$(LIBNFSIDMAP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VER)
	$(UNTAR)/$(LIBNFSIDMAP_SOURCE)
	$(CHDIR)/libnfsidmap-$(LIBNFSIDMAP_VER);\
		$(CONFIGURE) \
		ac_cv_func_malloc_0_nonnull=yes \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnfsidmap.pc
	$(REWRITE_LIBTOOL)/libnfsidmap.la
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VER)
	$(TOUCH)

#
# vsftpd
#
VSFTPD_VER = 3.0.5
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VER).tar.gz
VSFTPD_PATCH = vsftpd-$(VSFTPD_VER).patch
VSFTPD_PATCH += vsftpd-$(VSFTPD_VER)-find_libs.patch

$(ARCHIVE)/$(VSFTPD_SOURCE):
	$(DOWNLOAD) https://security.appspot.com/downloads/$(VSFTPD_SOURCE)

$(D)/vsftpd: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(VSFTPD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(UNTAR)/$(VSFTPD_SOURCE)
	$(CHDIR)/vsftpd-$(VSFTPD_VER); \
		$(call apply_patches, $(VSFTPD_PATCH)); \
		$(MAKE) clean; \
		$(MAKE) $(BUILDENV); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
#	install -m 755 $(SKEL_ROOT)/etc/init.d/vsftpd $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/vsftpd.conf $(TARGET_DIR)/etc/
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(TOUCH)

#
# procps_ng
#
PROCPS_NG_VER = 3.3.16
PROCPS_NG_SOURCE = procps-ng-$(PROCPS_NG_VER).tar.xz

$(ARCHIVE)/$(PROCPS_NG_SOURCE):
	$(DOWNLOAD) http://sourceforge.net/projects/procps-ng/files/Production/$(PROCPS_NG_SOURCE)

$(D)/procps_ng: $(D)/bootstrap $(D)/ncurses $(ARCHIVE)/$(PROCPS_NG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/procps-ng-$(PROCPS_NG_VER)
	$(UNTAR)/$(PROCPS_NG_SOURCE)
	cd $(BUILD_TMP)/procps-ng-$(PROCPS_NG_VER); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		export ac_cv_func_realloc_0_nonnull=yes; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
		; \
		$(MAKE); \
		install -D -m 755 top/.libs/top $(TARGET_DIR)/usr/bin/top; \
		install -D -m 755 ps/.libs/pscommand $(TARGET_DIR)/bin/ps; \
		cp -a proc/.libs/libprocps.so* $(TARGET_LIB_DIR)
	$(REMOVE)/procps-ng-$(PROCPS_NG_VER)
	$(TOUCH)

#
# htop
#
HTOP_VER = 2.2.0
HTOP_SOURCE = htop-$(HTOP_VER).tar.gz
HTOP_PATCH = htop-$(HTOP_VER).patch

$(ARCHIVE)/$(HTOP_SOURCE):
	$(DOWNLOAD) http://hisham.hm/htop/releases/$(HTOP_VER)/$(HTOP_SOURCE)

$(D)/htop: $(D)/bootstrap $(D)/ncurses $(ARCHIVE)/$(HTOP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/htop-$(HTOP_VER)
	$(UNTAR)/$(HTOP_SOURCE)
	$(CHDIR)/htop-$(HTOP_VER); \
		$(call apply_patches, $(HTOP_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--disable-unicode \
			ac_cv_func_malloc_0_nonnull=yes \
			ac_cv_func_realloc_0_nonnull=yes \
			ac_cv_file__proc_stat=yes \
			ac_cv_file__proc_meminfo=yes \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(addprefix $(TARGET_DIR)/usr/share/,pixmaps applications)
	$(REMOVE)/htop-$(HTOP_VER)
	$(TOUCH)

#
# ethtool
#
ETHTOOL_VER = 5.18
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VER).tar.xz
ETHTOOL_PATCH = ethtool-$(ETHTOOL_VER).patch

$(ARCHIVE)/$(ETHTOOL_SOURCE):
	$(DOWNLOAD) https://www.kernel.org/pub/software/network/ethtool/$(ETHTOOL_SOURCE)

$(D)/ethtool: $(D)/bootstrap $(ARCHIVE)/$(ETHTOOL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	$(CHDIR)/ethtool-$(ETHTOOL_VER); \
		$(call apply_patches, $(ETHTOOL_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-pretty-dump \
			--disable-netlink \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(TOUCH)

#
# samba
#
SAMBA_VER = 3.6.25
SAMBA_SOURCE = samba-$(SAMBA_VER).tar.gz
SAMBA_PATCH = $(PATCHES)/samba
ifeq ($(AUTOCONF_NEW),1)
	SAMBA2_PATCH = samba-autoconf.patch
endif

ifeq ($(SAMBA_SMALL_INSTALL), 1)
SAMBA_INSTALL = \
		$(MAKE) $(MAKE_OPTS) \
			installservers installbin installdat installmodules \
			SBIN_PROGS="bin/samba_multicall" \
			BIN_PROGS="bin/testparm" \
			DESTDIR=$(TARGET_DIR) prefix=./. ;
else
SAMBA_INSTALL = \
		$(MAKE) $(MAKE_OPTS) \
			installservers installbin installscripts installdat installmodules \
			SBIN_PROGS="bin/samba_multicall" \
			DESTDIR=$(TARGET_DIR) prefix=./. ;
endif

$(ARCHIVE)/$(SAMBA_SOURCE):
	$(DOWNLOAD) https://ftp.samba.org/pub/samba/stable/$(SAMBA_SOURCE)

$(D)/samba: $(D)/bootstrap $(ARCHIVE)/$(SAMBA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/samba-$(SAMBA_VER)
	$(UNTAR)/$(SAMBA_SOURCE)
	$(CHDIR)/samba-$(SAMBA_VER); \
		$(call apply_patches, $(SAMBA_PATCH)); \
		cd source3; \
		./autogen.sh; \
		$(call apply_patches, $(SAMBA2_PATCH)); \
		$(BUILDENV) \
		ac_cv_lib_attr_getxattr=no \
		ac_cv_search_getxattr=no \
		ac_cv_file__proc_sys_kernel_core_pattern=yes \
		libreplace_cv_HAVE_C99_VSNPRINTF=yes \
		libreplace_cv_HAVE_GETADDRINFO=yes \
		libreplace_cv_HAVE_IFACE_IFCONF=yes \
		LINUX_LFS_SUPPORT=no \
		samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
		samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
		samba_cv_HAVE_IFACE_IFCONF=yes \
		samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
		samba_cv_HAVE_SECURE_MKSTEMP=yes \
		libreplace_cv_HAVE_SECURE_MKSTEMP=yes \
		samba_cv_HAVE_WRFILE_KEYTAB=no \
		samba_cv_USE_SETREUID=yes \
		samba_cv_USE_SETRESUID=yes \
		samba_cv_have_setreuid=yes \
		samba_cv_have_setresuid=yes \
		samba_cv_optimize_out_funcation_calls=no \
		ac_cv_header_zlib_h=no \
		samba_cv_zlib_1_2_3=no \
		ac_cv_path_PYTHON="" \
		ac_cv_path_PYTHON_CONFIG="" \
		libreplace_cv_HAVE_GETADDRINFO=no \
		libreplace_cv_READDIR_NEEDED=no \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--includedir=/usr/include \
			--exec-prefix=/usr \
			--disable-pie \
			--disable-avahi \
			--disable-cups \
			--disable-relro \
			--disable-swat \
			--disable-shared-libs \
			--disable-socket-wrapper \
			--disable-nss-wrapper \
			--disable-smbtorture4 \
			--disable-fam \
			--disable-iprint \
			--disable-dnssd \
			--disable-pthreadpool \
			--disable-dmalloc \
			--with-included-iniparser \
			--with-included-popt \
			--with-sendfile-support \
			--without-aio-support \
			--without-cluster-support \
			--without-ads \
			--without-krb5 \
			--without-dnsupdate \
			--without-automount \
			--without-ldap \
			--without-pam \
			--without-pam_smbpass \
			--without-winbind \
			--without-wbclient \
			--without-syslog \
			--without-nisplus-home \
			--without-quotas \
			--without-sys-quotas \
			--without-utmp \
			--without-acl-support \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-mandir=no \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log \
			--with-lockdir=/var/lock \
			--with-swatdir=/usr/share/swat \
			--disable-cups \
			--without-winbind \
			--without-libtdb \
			--without-libtalloc \
			--without-libnetapi \
			--without-libsmbclient \
			--without-libsmbsharemodes \
			--without-libtevent \
			--without-libaddns \
		; \
		$(MAKE) $(MAKE_OPTS); \
		$(SAMBA_INSTALL)
			ln -sf samba_multicall $(TARGET_DIR)/usr/sbin/nmbd
			ln -sf samba_multicall $(TARGET_DIR)/usr/sbin/smbd
			ln -sf samba_multicall $(TARGET_DIR)/usr/sbin/smbpasswd
	install -m 755 $(SKEL_ROOT)/etc/init.d/samba $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/samba/smb.conf $(TARGET_DIR)/etc/samba/
	rm -rf $(TARGET_LIB_DIR)/pdb
	rm -rf $(TARGET_LIB_DIR)/perfcount
	rm -rf $(TARGET_LIB_DIR)/nss_info
	rm -rf $(TARGET_LIB_DIR)/gpext
	$(REMOVE)/samba-$(SAMBA_VER)
	$(TOUCH)

#
# ntp
#
NTP_VER = 4.2.8p15
NTP_SOURCE = ntp-$(NTP_VER).tar.gz
NTP_PATCH = ntp-$(NTP_VER).patch

$(ARCHIVE)/$(NTP_SOURCE):
	$(DOWNLOAD) https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/$(NTP_SOURCE)

$(D)/ntp: $(D)/bootstrap $(ARCHIVE)/$(NTP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ntp-$(NTP_VER)
	$(UNTAR)/$(NTP_SOURCE)
	$(CHDIR)/ntp-$(NTP_VER); \
		$(call apply_patches, $(NTP_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--docdir=/.remove \
			--localedir=/.remove \
			--htmldir=/.remove \
			--disable-tick \
			--disable-tickadj \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			--disable-debugging \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ntp-$(NTP_VER)
	$(TOUCH)

#
# wireless_tools
#
WIRELESS_TOOLS_VER = 29
WIRELESS_TOOLS_SOURCE = wireless_tools.$(WIRELESS_TOOLS_VER).tar.gz
WIRELESS_TOOLS_PATCH = wireless-tools.$(WIRELESS_TOOLS_VER).patch

$(ARCHIVE)/$(WIRELESS_TOOLS_SOURCE):
	$(DOWNLOAD) http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/$(WIRELESS_TOOLS_SOURCE)

$(D)/wireless_tools: $(D)/bootstrap $(ARCHIVE)/$(WIRELESS_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wireless_tools.$(WIRELESS_TOOLS_VER)
	$(UNTAR)/$(WIRELESS_TOOLS_SOURCE)
	$(CHDIR)/wireless_tools.$(WIRELESS_TOOLS_VER); \
		$(call apply_patches, $(WIRELESS_TOOLS_PATCH)); \
		$(MAKE) CC="$(TARGET)-gcc" CFLAGS="$(TARGET_CFLAGS) -I."; \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr INSTALL_MAN=$(TARGET_DIR)/.remove
	$(REMOVE)/wireless_tools.$(WIRELESS_TOOLS_VER)
	$(TOUCH)

#
# libnl
#
LIBNL_VER = 3.2.25
LIBNL_SOURCE = libnl-$(LIBNL_VER).tar.gz

$(ARCHIVE)/$(LIBNL_SOURCE):
	$(DOWNLOAD) https://www.infradead.org/~tgr/libnl/files/$(LIBNL_SOURCE)

$(D)/libnl: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(LIBNL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(UNTAR)/$(LIBNL_SOURCE)
	$(CHDIR)/libnl-$(LIBNL_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--mandir=/.remove \
			--infodir=/.remove \
		make; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnl-3.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnl-cli-3.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnl-genl-3.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnl-nf-3.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libnl-route-3.0.pc
	$(REWRITE_LIBTOOL)/libnl-3.la
	$(REWRITE_LIBTOOL)/libnl-cli-3.la
	$(REWRITE_LIBTOOL)/libnl-genl-3.la
	$(REWRITE_LIBTOOL)/libnl-idiag-3.la
	$(REWRITE_LIBTOOL)/libnl-nf-3.la
	$(REWRITE_LIBTOOL)/libnl-route-3.la
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(TOUCH)

#
# wpa_supplicant
#
WPA_SUPPLICANT_VER = 0.7.3
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz

$(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE):
	$(DOWNLOAD) https://w1.fi/releases/$(WPA_SUPPLICANT_SOURCE)

$(D)/wpa_supplicant: $(D)/bootstrap $(D)/openssl $(D)/wireless_tools $(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	$(UNTAR)/$(WPA_SUPPLICANT_SOURCE)
	$(CHDIR)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant; \
		cp -f defconfig .config; \
		sed -i 's/#CONFIG_DRIVER_RALINK=y/CONFIG_DRIVER_RALINK=y/' .config; \
		sed -i 's/#CONFIG_IEEE80211W=y/CONFIG_IEEE80211W=y/' .config; \
		sed -i 's/#CONFIG_OS=unix/CONFIG_OS=unix/' .config; \
		sed -i 's/#CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config; \
		sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/' .config; \
		sed -i 's/#CONFIG_INTERWORKING=y/CONFIG_INTERWORKING=y/' .config; \
		export CFLAGS="-pipe -Os -Wall -g0 -I$(TARGET_INCLUDE_DIR)"; \
		export CPPFLAGS="-I$(TARGET_INCLUDE_DIR)"; \
		export LIBS="-L$(TARGET_LIB_DIR) -Wl,-rpath-link,$(TARGET_LIB_DIR)"; \
		export LDFLAGS="-L$(TARGET_LIB_DIR)"; \
		export DESTDIR=$(TARGET_DIR); \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install BINDIR=/usr/sbin DESTDIR=$(TARGET_DIR)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	$(TOUCH)

#
# dvbsnoop
#
ifeq ($(BOXARCH), sh4)
DVBSNOOP_CONF_OPTS = --with-dvbincludes=$(KERNEL_DIR)/include
endif

$(D)/dvbsnoop: $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	$(REMOVE)/dvbsnoop
	set -e; if [ -d $(ARCHIVE)/dvbsnoop.git ]; \
		then cd $(ARCHIVE)/dvbsnoop.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/dvbsnoop.git dvbsnoop.git; \
		fi
	cp -ra $(ARCHIVE)/dvbsnoop.git $(BUILD_TMP)/dvbsnoop
	$(CHDIR)/dvbsnoop; \
		$(CONFIGURE) \
			--enable-silent-rules \
			--prefix=/usr \
			--mandir=/.remove \
			$(DVBSNOOP_CONF_OPTS) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dvbsnoop
	$(TOUCH)

#
# udpxy
#
UDPXY_VER    = 612d227
UDPXY_SOURCE = udpxy-git-$(UDPXY_VER).tar.bz2
UDPXY_URL    = https://github.com/pcherenkov/udpxy.git
UDPXY_PATCH  = udpxy-git-$(UDPXY_VER).patch
UDPXY_PATCH += udpxy-git-$(UDPXY_VER)-fix-build-with-gcc8.patch
UDPXY_PATCH += udpxy-git-$(UDPXY_VER)-fix-build-with-gcc9.patch

$(ARCHIVE)/$(UDPXY_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(UDPXY_URL) $(UDPXY_VER) $(notdir $@) $(ARCHIVE)

$(D)/udpxy: $(D)/bootstrap $(ARCHIVE)/$(UDPXY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/udpxy-git-$(UDPXY_VER)
	$(UNTAR)/$(UDPXY_SOURCE)
	$(CHDIR)/udpxy-git-$(UDPXY_VER)/chipmunk; \
		$(call apply_patches, $(UDPXY_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc CCKIND=gcc; \
		$(MAKE) install INSTALLROOT=$(TARGET_DIR)/usr MANPAGE_DIR=$(TARGET_DIR)/.remove
	$(REMOVE)/udpxy-git-$(UDPXY_VER)
	$(TOUCH)

#
# openvpn
#
OPENVPN_VER = 2.5.7
OPENVPN_SOURCE = openvpn-$(OPENVPN_VER).tar.xz

$(ARCHIVE)/$(OPENVPN_SOURCE):
	$(DOWNLOAD) http://swupdate.openvpn.org/community/releases/$(OPENVPN_SOURCE) || \
	$(DOWNLOAD) http://build.openvpn.net/downloads/releases/$(OPENVPN_SOURCE)

$(D)/openvpn: $(D)/bootstrap $(D)/openssl $(D)/lzo $(ARCHIVE)/$(OPENVPN_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(UNTAR)/$(OPENVPN_SOURCE)
	$(CHDIR)/openvpn-$(OPENVPN_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-lz4 \
			--disable-selinux \
			--disable-systemd \
			--disable-plugins \
			--disable-debug \
			--disable-pkcs11 \
			--enable-small \
			NETSTAT="/bin/netstat" \
			IFCONFIG="/sbin/ifconfig" \
			IPROUTE="/sbin/ip" \
			ROUTE="/sbin/route" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/openvpn $(TARGET_DIR)/etc/init.d/
	install -d $(TARGET_DIR)/etc/openvpn
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(TOUCH)

#
# vpnc
#
VPNC_VER = 0.5.3r550-2jnpr1
VPNC_DIR = vpnc-$(VPNC_VER)
VPNC_SOURCE = vpnc-$(VPNC_VER).tar.gz
VPNC_URL = https://github.com/ndpgroup/vpnc/archive

VPNC_PATCH = \
	vpnc-fix-build.patch \
	vpnc-nomanual.patch \
	vpnc-susv3-legacy.patch \
	vpnc-conf.patch

VPNC_CPPFLAGS = -DVERSION=\\\"$(VPNC_VER)\\\"

$(ARCHIVE)/$(VPNC_SOURCE):
	$(DOWNLOAD) $(VPNC_URL)/$(VPNC_VER).tar.gz -O $(@)

$(D)/vpnc: $(D)/bootstrap $(D)/openssl $(D)/lzo $(D)/libgcrypt $(ARCHIVE)/$(VPNC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/vpnc-$(VPNC_VER)
	$(UNTAR)/$(VPNC_SOURCE)
	$(CHDIR)/vpnc-$(VPNC_VER); \
		$(call apply_patches, $(VPNC_PATCH)); \
		$(BUILDENV) \
		$(MAKE) \
			CPPFLAGS="$(CPPFLAGS) $(VPNC_CPPFLAGS)"; \
		$(MAKE) \
			CPPFLAGS="$(CPPFLAGS) $(VPNC_CPPFLAGS)" \
			install-strip DESTDIR=$(TARGET_DIR) \
			PREFIX=/usr \
			MANDIR=$(TARGET_DIR)/.remove \
			DOCDIR=$(TARGET_DIR)/.remove
	$(REMOVE)/vpnc-$(VPNC_VER)
	$(TOUCH)

#
# openssh
#
OPENSSH_VER = 9.0p1
OPENSSH_SOURCE = openssh-$(OPENSSH_VER).tar.gz

$(ARCHIVE)/$(OPENSSH_SOURCE):
	$(DOWNLOAD) https://artfiles.org/openbsd/OpenSSH/portable/$(OPENSSH_SOURCE)

$(D)/openssh: $(D)/bootstrap $(D)/zlib $(D)/openssl $(ARCHIVE)/$(OPENSSH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(UNTAR)/$(OPENSSH_SOURCE)
	$(CHDIR)/openssh-$(OPENSSH_VER); \
		CC=$(TARGET)-gcc; \
		./configure $(SILENT_OPT) \
			$(CONFIGURE_OPTS) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc/ssh \
			--libexecdir=/sbin \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe -Os -I$(TARGET_INCLUDE_DIR)" \
			--with-ldflags=-"L$(TARGET_LIB_DIR)" \
		; \
		$(MAKE); \
		$(MAKE) install-nokeys DESTDIR=$(TARGET_DIR)
	install -m 755 $(BUILD_TMP)/openssh-$(OPENSSH_VER)/opensshd.init $(TARGET_DIR)/etc/init.d/openssh
	sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' $(TARGET_DIR)/etc/ssh/sshd_config
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(TOUCH)

#
# dropbear
#
DROPBEAR_VER = 2018.76
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VER).tar.bz2

$(ARCHIVE)/$(DROPBEAR_SOURCE):
	$(DOWNLOAD) http://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR_SOURCE)

$(D)/dropbear: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(DROPBEAR_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	$(UNTAR)/$(DROPBEAR_SOURCE)
	$(CHDIR)/dropbear-$(DROPBEAR_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-pututxline \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pam \
		; \
		sed -i 's|^\(#define DROPBEAR_SMALL_CODE\).*|\1 0|' default_options.h; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/dropbear $(TARGET_DIR)/etc/init.d/
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	$(TOUCH)

#
# dropbearmulti
#
DROPBEARMULTI_VER = 17e02fe
#DROPBEARMULTI_VER = 808bc39
DROPBEARMULTI_SOURCE = dropbearmulti-git-$(DROPBEARMULTI_VER).tar.bz2
DROPBEARMULTI_URL = https://github.com/mkj/dropbear.git

$(ARCHIVE)/$(DROPBEARMULTI_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(DROPBEARMULTI_URL) $(DROPBEARMULTI_VER) $(notdir $@) $(ARCHIVE)

$(D)/dropbearmulti: $(D)/bootstrap $(ARCHIVE)/$(DROPBEARMULTI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dropbearmulti-git-$(DROPBEARMULTI_VER)
	$(UNTAR)/$(DROPBEARMULTI_SOURCE)
	$(CHDIR)/dropbearmulti-git-$(DROPBEARMULTI_VER); \
		$(BUILDENV) \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-syslog \
			--disable-lastlog \
			--infodir=/.remove \
			--localedir=/.remove \
			--mandir=/.remove \
			--docdir=/.remove \
			--htmldir=/.remove \
			--dvidir=/.remove \
			--pdfdir=/.remove \
			--psdir=/.remove \
			--disable-shadow \
			--disable-zlib \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pututline \
			--disable-pututxline \
		; \
		$(MAKE) PROGRAMS="dropbear scp" MULTI=1; \
		$(MAKE) PROGRAMS="dropbear scp" MULTI=1 install DESTDIR=$(TARGET_DIR)
	cd $(TARGET_DIR)/usr/bin && ln -sf /usr/bin/dropbearmulti dropbear
	install -m 755 $(SKEL_ROOT)/etc/init.d/dropbear $(TARGET_DIR)/etc/init.d/
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	$(REMOVE)/dropbearmulti-git-$(DROPBEARMULTI_VER)
	$(TOUCH)

#
# usb_modeswitch_data
#
USB_MODESWITCH_DATA_VER = 20160112
USB_MODESWITCH_DATA_SOURCE = usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2
USB_MODESWITCH_DATA_PATCH = usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).patch

$(ARCHIVE)/$(USB_MODESWITCH_DATA_SOURCE):
	$(DOWNLOAD) http://www.draisberghof.de/usb_modeswitch/$(USB_MODESWITCH_DATA_SOURCE)

$(D)/usb_modeswitch_data: $(D)/bootstrap $(ARCHIVE)/$(USB_MODESWITCH_DATA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER)
	$(UNTAR)/$(USB_MODESWITCH_DATA_SOURCE)
	$(CHDIR)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER); \
		$(call apply_patches, $(USB_MODESWITCH_DATA_PATCH)); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER)
	$(TOUCH)

#
# usb_modeswitch
#
USB_MODESWITCH_VER = 2.3.0
USB_MODESWITCH_SOURCE = usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2
USB_MODESWITCH_PATCH = usb-modeswitch-$(USB_MODESWITCH_VER).patch

$(ARCHIVE)/$(USB_MODESWITCH_SOURCE):
	$(DOWNLOAD) http://www.draisberghof.de/usb_modeswitch/$(USB_MODESWITCH_SOURCE)

$(D)/usb_modeswitch: $(D)/bootstrap $(D)/libusb $(D)/usb_modeswitch_data $(ARCHIVE)/$(USB_MODESWITCH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VER)
	$(UNTAR)/$(USB_MODESWITCH_SOURCE)
	$(CHDIR)/usb-modeswitch-$(USB_MODESWITCH_VER); \
		$(call apply_patches, $(USB_MODESWITCH_PATCH)); \
		sed -i -e "s/= gcc/= $(TARGET)-gcc/" -e "s/-l usb/-lusb -lusb-1.0 -lpthread -lrt/" -e "s/install -D -s/install -D --strip-program=$(TARGET)-strip -s/" Makefile; \
		sed -i -e "s/@CC@/$(TARGET)-gcc/g" jim/Makefile.in; \
		$(BUILDENV) $(MAKE) DESTDIR=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VER)
	$(TOUCH)

#
# dvb-apps
#
DVB_APPS_PATCH = dvb-apps.patch

$(D)/dvb-apps: $(D)/bootstrap $(ARCHIVE)/$(DVB_APPS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dvb-apps
	set -e; if [ -d $(ARCHIVE)/dvb-apps.git ]; \
		then cd $(ARCHIVE)/dvb-apps.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/openpli-arm/dvb-apps.git dvb-apps.git; \
		fi
	cp -ra $(ARCHIVE)/dvb-apps.git $(BUILD_TMP)/dvb-apps
	$(CHDIR)/dvb-apps; \
		$(call apply_patches,$(DVB_APPS_PATCH)); \
		$(BUILDENV) \
		$(BUILDENV) $(MAKE) DESTDIR=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dvb-apps
	$(TOUCH)

#
# minisatip
#
MINISATIP_PATCH = minisatip.patch

$(D)/minisatip: $(D)/bootstrap $(D)/openssl $(D)/libdvbcsa $(ARCHIVE)/$(MINISATIP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/minisatip
	set -e; if [ -d $(ARCHIVE)/minisatip.git ]; \
		then cd $(ARCHIVE)/minisatip.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/catalinii/minisatip.git minisatip.git; \
		fi
	cp -ra $(ARCHIVE)/minisatip.git $(BUILD_TMP)/minisatip
	$(CHDIR)/minisatip; \
		$(call apply_patches,$(MINISATIP_PATCH)); \
		$(BUILDENV) \
		export CFLAGS="-pipe -Os -Wall -g0 -ldl -I$(TARGET_INCLUDE_DIR)"; \
		export CPPFLAGS="-I$(TARGET_INCLUDE_DIR)"; \
		export LDFLAGS="-L$(TARGET_LIB_DIR)"; \
		./configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--enable-static \
		; \
		$(MAKE); \
	install -m 755 $(BUILD_TMP)/minisatip/minisatip $(TARGET_DIR)/usr/bin
	install -d $(TARGET_DIR)/usr/share/minisatip
	cp -a $(BUILD_TMP)/minisatip/html $(TARGET_DIR)/usr/share/minisatip
	$(REMOVE)/minisatip
	$(TOUCH)

#
# ofgwrite
#
#OFGWRITE_PATCH = ofgwrite.patch

$(D)/ofgwrite: $(D)/bootstrap $(ARCHIVE)/$(OFGWRITE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ofgwrite-ddt
	set -e; if [ -d $(ARCHIVE)/ofgwrite-ddt.git ]; \
		then cd $(ARCHIVE)/ofgwrite-ddt.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/ofgwrite-ddt.git ofgwrite-ddt.git; \
		fi
	cp -ra $(ARCHIVE)/ofgwrite-ddt.git $(BUILD_TMP)/ofgwrite-ddt
	$(CHDIR)/ofgwrite-ddt; \
		$(call apply_patches,$(OFGWRITE_PATCH)); \
		$(BUILDENV) \
		$(MAKE); \
	install -m 755 $(BUILD_TMP)/ofgwrite-ddt/ofgwrite_bin $(TARGET_DIR)/usr/bin
	install -m 755 $(BUILD_TMP)/ofgwrite-ddt/ofgwrite_caller $(TARGET_DIR)/usr/bin
	install -m 755 $(BUILD_TMP)/ofgwrite-ddt/ofgwrite $(TARGET_DIR)/usr/bin
	$(REMOVE)/ofgwrite-ddt
	$(TOUCH)

#
# iptables
#
IPTABLES_VER = 1.8.7
IPTABLES_SOURCE = iptables-$(IPTABLES_VER).tar.bz2

$(ARCHIVE)/$(IPTABLES_SOURCE):
	$(DOWNLOAD) https://netfilter.org/pub/iptables/$(IPTABLES_SOURCE)

$(D)/iptables: $(D)/bootstrap $(ARCHIVE)/$(IPTABLES_SOURCE)
	$(START_BUILD)
	$(REMOVE)/iptables-$(IPTABLES_VER)
	$(UNTAR)/$(IPTABLES_SOURCE)
	$(CHDIR)/iptables-$(IPTABLES_VER); \
		$(BUILDENV) \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--infodir=/.remove \
			--localedir=/.remove \
			--mandir=/.remove \
			--docdir=/.remove \
			--htmldir=/.remove \
			--dvidir=/.remove \
			--pdfdir=/.remove \
			--psdir=/.remove \
			--disable-nftables \
			--disable-devel \
			--disable-connlabel \
			--disable-ipv6 \
			--enable-shared=no \
			--without-pkgconfigdir \
			--without-xtlibdir \
			--without-xt-lock-name \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/iptables-$(IPTABLES_VER)
	$(TOUCH)
