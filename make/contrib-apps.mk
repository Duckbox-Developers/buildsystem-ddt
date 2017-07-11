#
# busybox
#
BUSYBOX_VERSION = 1.27.0
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_PATCH  = busybox-$(BUSYBOX_VERSION)-nandwrite.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VERSION)-unicode.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VERSION)-extra.patch

$(ARCHIVE)/$(BUSYBOX_SOURCE):
	$(WGET) http://busybox.net/downloads/$(BUSYBOX_SOURCE)

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 ufs912 ufs913))
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VERSION).config_nandwrite
else
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VERSION).config
endif

$(D)/busybox: $(D)/bootstrap $(D)/module_init_tools $(ARCHIVE)/$(BUSYBOX_SOURCE) $(PATCHES)/$(BUSYBOX_CONFIG)
	$(START_BUILD)
	$(REMOVE)/busybox-$(BUSYBOX_VERSION)
	$(UNTAR)/$(BUSYBOX_SOURCE)
	set -e; cd $(BUILD_TMP)/busybox-$(BUSYBOX_VERSION); \
		$(call post_patch,$(BUSYBOX_PATCH)); \
		install -m 0644 $(lastword $^) .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGET_DIR)"#' .config; \
		$(BUILDENV) $(MAKE) busybox CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		$(MAKE) install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" CONFIG_PREFIX=$(TARGET_DIR)
	$(REMOVE)/busybox-$(BUSYBOX_VERSION)
	$(TOUCH)

#
# host_pkgconfig
#
PKGCONFIG_VERSION = 0.29.1
PKGCONFIG_SOURCE = pkg-config-$(PKGCONFIG_VERSION).tar.gz

$(ARCHIVE)/$(PKGCONFIG_SOURCE):
	$(WGET) https://pkgconfig.freedesktop.org/releases/$(PKGCONFIG_SOURCE)

pkg-config-preqs:
	@PATH=$(subst $(HOST_DIR)/bin:,,$(PATH)); \
	if ! pkg-config --exists glib-2.0; then \
		echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
	fi

$(D)/host_pkgconfig: directories $(ARCHIVE)/$(PKGCONFIG_SOURCE) | pkg-config-preqs
	$(START_BUILD)
	$(REMOVE)/pkg-config-$(PKGCONFIG_VERSION)
	$(UNTAR)/$(PKGCONFIG_SOURCE)
	set -e; cd $(BUILD_TMP)/pkg-config-$(PKGCONFIG_VERSION); \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOST_DIR) \
			--program-prefix=$(TARGET)- \
			--disable-host-tool \
			--with-pc_path=$(PKG_CONFIG_PATH) \
		; \
		$(MAKE); \
		$(MAKE) install
	ln -sf $(TARGET)-pkg-config $(HOST_DIR)/bin/pkg-config
	$(REMOVE)/pkg-config-$(PKGCONFIG_VERSION)
	$(TOUCH)

#
# host_mtd_utils
#
MTD_UTILS_VERSION = 1.5.2
MTD_UTILS_SOURCE = mtd-utils-$(MTD_UTILS_VERSION).tar.bz2
MTD_UTILS_HOST_PATCH = host-mtd-utils-$(MTD_UTILS_VERSION).patch

$(ARCHIVE)/$(MTD_UTILS_SOURCE):
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/$(MTD_UTILS_SOURCE)

$(D)/host_mtd_utils: directories $(ARCHIVE)/$(MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VERSION)
	$(UNTAR)/$(MTD_UTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VERSION); \
		$(call post_patch,$(MTD_UTILS_HOST_PATCH)); \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(HOST_DIR); \
		$(MAKE) install DESTDIR=$(HOST_DIR)/bin
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VERSION)
	$(TOUCH)

#
# mtd_utils
#
$(D)/mtd_utils: $(D)/bootstrap $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/$(MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VERSION)
	$(UNTAR)/$(MTD_UTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VERSION); \
		$(BUILDENV) \
		$(MAKE) PREFIX= CC=$(TARGET)-gcc LD=$(TARGET)-ld STRIP=$(TARGET)-strip WITHOUT_XATTR=1 DESTDIR=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VERSION)
	$(TOUCH)

#
# gdb-remote
#
GDB_VERSION = 7.8
GDB_SOURCE = gdb-$(GDB_VERSION).tar.xz
GDB_PATCH = gdb-$(GDB_VERSION)-remove-builddate.patch

$(ARCHIVE)/$(GDB_SOURCE):
	$(WGET) ftp://sourceware.org/pub/gdb/releases/$(GDB_SOURCE)

# gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VERSION)
	$(UNTAR)/$(GDB_SOURCE)
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VERSION); \
		./configure $(CONFIGURE_SILENT) \
			--nfp --disable-werror \
			--prefix=$(HOST_DIR) \
			--build=$(BUILD) \
			--host=$(BUILD) \
			--target=$(TARGET) \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb; \
	$(REMOVE)/gdb-$(GDB_VERSION)
	$(TOUCH)

#
# gdb
#

# gdb built for target or local-PC
$(D)/gdb: $(D)/bootstrap $(D)/libncurses $(D)/zlib $(ARCHIVE)/$(GDB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VERSION)
	$(UNTAR)/$(GDB_SOURCE)
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VERSION); \
		$(call post_patch,$(GDB_PATCH)); \
		./configure $(CONFIGURE_SILENT) \
			--host=$(BUILD) \
			--build=$(BUILD) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=$(TARGET_DIR)/.remove \
			--infodir=$(TARGET_DIR)/.remove \
			--nfp --disable-werror \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb prefix=$(TARGET_DIR)
	$(REMOVE)/gdb-$(GDB_VERSION)
	$(TOUCH)

#
# host_opkg
#
OPKG_VERSION = 0.3.3
OPKG_SOURCE = opkg-$(OPKG_VERSION).tar.gz
OPKG_PATCH = opkg-$(OPKG_VERSION).patch
OPKG_HOST_PATCH = opkg-$(OPKG_VERSION).patch

$(ARCHIVE)/$(OPKG_SOURCE):
	$(WGET) https://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/$(OPKG_SOURCE)

$(D)/host_opkg: directories $(D)/host_libarchive $(ARCHIVE)/$(OPKG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VERSION)
	$(UNTAR)/$(OPKG_SOURCE)
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VERSION); \
		$(call post_patch,$(OPKG_HOST_PATCH)); \
		./autogen.sh; \
		CFLAGS="-I$(HOST_DIR)/include" \
		LDFLAGS="-L$(HOST_DIR)/lib" \
		./configure $(CONFIGURE_SILENT) \
			PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig \
			--prefix= \
			--disable-curl \
			--disable-gpg \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/opkg-$(OPKG_VERSION)
	$(TOUCH)

#
# opkg
#
$(D)/opkg: $(D)/bootstrap $(D)/host_opkg $(D)/libarchive $(ARCHIVE)/$(OPKG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VERSION)
	$(UNTAR)/$(OPKG_SOURCE)
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VERSION); \
		$(call post_patch,$(OPKG_PATCH)); \
		LIBARCHIVE_LIBS="-L$(TARGET_DIR)/usr/lib -larchive" \
		LIBARCHIVE_CFLAGS="-I$(TARGET_DIR)/usr/include" \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-curl \
			--disable-gpg \
			--mandir=/.remove \
		; \
		$(MAKE) all ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -d -m 0755 $(TARGET_DIR)/usr/lib/opkg
	install -d -m 0755 $(TARGET_DIR)/etc/opkg
	ln -sf opkg $(TARGET_DIR)/usr/bin/opkg-cl
	$(REWRITE_LIBTOOL)/libopkg.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	$(REMOVE)/opkg-$(OPKG_VERSION)
	$(TOUCH)

#
# sysvinit
#
SYSVINIT_VERSION = 2.88dsf
SYSVINIT_SOURCE = sysvinit_$(SYSVINIT_VERSION).orig.tar.gz

$(ARCHIVE)/$(SYSVINIT_SOURCE):
	$(WGET) ftp://ftp.debian.org/debian/pool/main/s/sysvinit/$(SYSVINIT_SOURCE)

$(D)/sysvinit: $(D)/bootstrap $(ARCHIVE)/$(SYSVINIT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sysvinit-$(SYSVINIT_VERSION)
	$(UNTAR)/$(SYSVINIT_SOURCE)
	set -e; cd $(BUILD_TMP)/sysvinit-$(SYSVINIT_VERSION); \
		sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
		-e '/bootlogd/d' -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile; \
		$(BUILDENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGET_DIR) MANDIR=/.remove
	rm -f $(addprefix $(TARGET_DIR)/sbin/,fstab-decode runlevel telinit)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,lastb)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 cuberevo cuberevo_mini2 cuberevo_2000hd))
	install -m 644 $(SKEL_ROOT)/etc/inittab_ttyAS1 $(TARGET_DIR)/etc/inittab
else
	install -m 644 $(SKEL_ROOT)/etc/inittab $(TARGET_DIR)/etc/inittab
endif
	$(REMOVE)/sysvinit-$(SYSVINIT_VERSION)
	$(TOUCH)

#
# host_module_init_tools
#
MODULE_INIT_TOOLS_VERSION = 3.15
MODULE_INIT_TOOLS_SOURCE = module-init-tools-$(MODULE_INIT_TOOLS_VERSION).tar.xz
MODULE_INIT_TOOLS_PATCH = module-init-tools-$(MODULE_INIT_TOOLS_VERSION).patch
MODULE_INIT_TOOLS_HOST_PATCH = module-init-tools-$(MODULE_INIT_TOOLS_VERSION).patch

$(ARCHIVE)/$(MODULE_INIT_TOOLS_SOURCE):
	$(WGET) https://www.kernel.org/pub/linux/utils/kernel/module-init-tools/$(MODULE_INIT_TOOLS_SOURCE)

$(D)/host_module_init_tools: $(ARCHIVE)/$(MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION)
	$(UNTAR)/$(MODULE_INIT_TOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION); \
		$(call post_patch,$(MODULE_INIT_TOOLS_HOST_PATCH)); \
		autoreconf -fi; \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION)
	$(TOUCH)

#
# module_init_tools
#
$(D)/module_init_tools: $(D)/bootstrap $(D)/lsb $(ARCHIVE)/$(MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION)
	$(UNTAR)/$(MODULE_INIT_TOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION); \
		$(call post_patch,$(MODULE_INIT_TOOLS_PATCH)); \
		autoreconf -fi; \
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
	$(call adapted-etc-files,$(MODULE_INIT_TOOLS_ADAPTED_ETC_FILES))
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION)
	$(TOUCH)

#
# lsb
#
LSB_MAJOR = 3.2
LSB_MINOR = 20
LSB_VERSION = $(LSB_MAJOR)-$(LSB_MINOR)
LSB_SOURCE = lsb_$(LSB_VERSION).tar.gz

$(ARCHIVE)/$(LSB_SOURCE):
	$(WGET) http://debian.sdinet.de/etch/sdinet/lsb/$(LSB_SOURCE)

$(D)/lsb: $(D)/bootstrap $(ARCHIVE)/$(LSB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(UNTAR)/$(LSB_SOURCE)
	set -e; cd $(BUILD_TMP)/lsb-$(LSB_MAJOR); \
		install -m 0644 init-functions $(TARGET_DIR)/lib/lsb
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(TOUCH)

#
# portmap
#
PORTMAP_VERSION = 6.0.0
PORTMAP_SOURCE = portmap_$(PORTMAP_VERSION).orig.tar.gz
PORTMAP_PATCH = portmap-$(PORTMAP_VERSION).patch

$(ARCHIVE)/$(PORTMAP_SOURCE):
	$(WGET) https://merges.ubuntu.com/p/portmap/$(PORTMAP_SOURCE)

$(ARCHIVE)/portmap_$(PORTMAP_VERSION)-2.diff.gz:
	$(WGET) https://merges.ubuntu.com/p/portmap/portmap_$(PORTMAP_VERSION)-2.diff.gz

$(D)/portmap: $(D)/bootstrap $(ARCHIVE)/$(PORTMAP_SOURCE) $(ARCHIVE)/portmap_$(PORTMAP_VERSION)-2.diff.gz
	$(START_BUILD)
	$(REMOVE)/portmap-$(PORTMAP_VERSION)
	$(UNTAR)/$(PORTMAP_SOURCE)
	set -e; cd $(BUILD_TMP)/portmap-$(PORTMAP_VERSION); \
		gunzip -cd $(lastword $^) | cat > debian.patch; \
		patch -p1 <debian.patch && \
		sed -e 's/### BEGIN INIT INFO/# chkconfig: S 41 10\n### BEGIN INIT INFO/g' -i debian/init.d; \
		$(call post_patch,$(PORTMAP_PATCH)); \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc"; \
		install -m 0755 portmap $(TARGET_DIR)/sbin; \
		install -m 0755 pmap_dump $(TARGET_DIR)/sbin; \
		install -m 0755 pmap_set $(TARGET_DIR)/sbin; \
		install -m755 debian/init.d $(TARGET_DIR)/etc/init.d/portmap
	$(REMOVE)/portmap-$(PORTMAP_VERSION)
	$(TOUCH)

#
# e2fsprogs
#
E2FSPROGS_VERSION = 1.42.13
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_PATCH = e2fsprogs-$(E2FSPROGS_VERSION).patch

$(ARCHIVE)/$(E2FSPROGS_SOURCE):
	$(WGET) https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VERSION)/$(E2FSPROGS_SOURCE)

$(D)/e2fsprogs: $(D)/bootstrap $(D)/util-linux $(ARCHIVE)/$(E2FSPROGS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VERSION)
	$(UNTAR)/$(E2FSPROGS_SOURCE)
	set -e; cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VERSION); \
		$(call post_patch,$(E2FSPROGS_PATCH)); \
		PATH=$(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VERSION):$(PATH) \
		$(CONFIGURE) \
			--prefix=/usr \
			--libdir=/usr/lib \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-rpath \
			--disable-quota \
			--disable-testio-debug \
			--disable-defrag \
			--disable-nls \
			--disable-jbd-debug \
			--disable-blkid-debug \
			--disable-testio-debug \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--enable-elf-shlibs \
			--enable-fsck \
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
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,filefrag e2freefrag mklost+found uuidd)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,chattr lsattr uuidgen)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VERSION)
	$(TOUCH)

#
# dosfstools
#
DOSFSTOOLS_VERSION = 4.1
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VERSION).tar.xz

$(ARCHIVE)/$(DOSFSTOOLS_SOURCE):
	$(WGET) https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)/$(DOSFSTOOLS_SOURCE)

$(D)/dosfstools: bootstrap $(ARCHIVE)/$(DOSFSTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VERSION)
	$(UNTAR)/$(DOSFSTOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VERSION); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VERSION)
	$(TOUCH)

#
# jfsutils
#
JFSUTILS_VERSION = 1.1.15
JFSUTILS_SOURCE = jfsutils-$(JFSUTILS_VERSION).tar.gz
JFSUTILS_PATCH = jfsutils-$(JFSUTILS_VERSION).patch

$(ARCHIVE)/$(JFSUTILS_SOURCE):
	$(WGET) http://jfs.sourceforge.net/project/pub/$(JFSUTILS_SOURCE)

$(D)/jfsutils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(JFSUTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/jfsutils-$(JFSUTILS_VERSION)
	$(UNTAR)/$(JFSUTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/jfsutils-$(JFSUTILS_VERSION); \
		$(call post_patch,$(JFSUTILS_PATCH)); \
		sed "s@<unistd.h>@&\n#include <sys/types.h>@g" -i fscklog/extract.c; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,jfs_debugfs jfs_fscklog jfs_logdump)
	$(REMOVE)/jfsutils-$(JFSUTILS_VERSION)
	$(TOUCH)

#
# ntfs-3g
#
NTFS_3G_VERSION = 2017.3.23
NTFS_3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION).tgz

$(ARCHIVE)/$(NTFS_3G_SOURCE):
	$(WGET) http://tuxera.com/opensource/$(NTFS_3G_SOURCE)

$(D)/ntfs-3g: $(D)/bootstrap $(ARCHIVE)/$(NTFS_3G_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION)
	$(UNTAR)/$(NTFS_3G_SOURCE)
	set -e; cd $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION); \
		CFLAGS="-pipe -Os" ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ldconfig \
			--disable-ntfsprogs \
			--disable-static \
			--enable-silent-rules \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libntfs-3g.pc
	$(REWRITE_LIBTOOL)/libntfs-3g.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,lowntfs-3g ntfs-3g.probe)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,mount.lowntfs-3g)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION)
	$(TOUCH)

#
# util-linux
#
UTIL_LINUX_MAJOR = 2.25
UTIL_LINUX_MINOR = 2
UTIL_LINUX_VERSION = $(UTIL_LINUX_MAJOR).$(UTIL_LINUX_MINOR)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VERSION).tar.xz

$(ARCHIVE)/$(UTIL_LINUX_SOURCE):
	$(WGET) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_MAJOR)/$(UTIL_LINUX_SOURCE)

$(D)/util-linux: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(UTIL_LINUX_SOURCE)
	$(START_BUILD)
	$(REMOVE)/util-linux-$(UTIL_LINUX_VERSION)
	$(UNTAR)/$(UTIL_LINUX_SOURCE)
	set -e; cd $(BUILD_TMP)/util-linux-$(UTIL_LINUX_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-static \
			--disable-gtk-doc \
			--disable-nls \
			--disable-rpath \
			--disable-libuuid \
			--disable-libblkid \
			--disable-libmount \
			--disable-libsmartcols \
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
			--disable-reset \
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
			--without-slang \
			--without-utempter \
			--disable-wall \
			--without-python \
			--disable-makeinstall-chown \
			--without-systemdsystemunitdir \
		; \
		$(MAKE); \
		install -D -m 755 sfdisk $(TARGET_DIR)/sbin/sfdisk; \
		install -D -m 755 mkfs $(TARGET_DIR)/sbin/mkfs
	$(REMOVE)/util-linux-$(UTIL_LINUX_VERSION)
	$(TOUCH)

#
# mc
#
MC_VERSION = 4.8.14
MC_SOURCE = mc-$(MC_VERSION).tar.xz

$(ARCHIVE)/$(MC_SOURCE):
	$(WGET) http://ftp.midnight-commander.org/$(MC_SOURCE)

$(D)/mc: $(D)/bootstrap $(D)/libncurses $(D)/libglib2 $(ARCHIVE)/$(MC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mc-$(MC_VERSION)
	$(UNTAR)/$(MC_SOURCE)
	set -e; cd $(BUILD_TMP)/mc-$(MC_VERSION); \
		autoreconf -fi; \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=$(DEFAULT_PREFIX) \
			--mandir=/.remove \
			--without-gpm-mouse \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--enable-charset \
			--with-screen=ncurses \
			--sysconfdir=/etc \
			--with-homedir=/var/tuxbox/config/mc \
			--without-x \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/mc-$(MC_VERSION)
	$(TOUCH)

#
# nano
#
NANO_VERSION = 2.2.6
NANO_SOURCE = nano-$(NANO_VERSION).tar.gz

$(ARCHIVE)/$(NANO_SOURCE):
	$(WGET) http://www.nano-editor.org/dist/v2.2/$(NANO_SOURCE)

$(D)/nano: $(D)/bootstrap $(ARCHIVE)/$(NANO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/nano-$(NANO_VERSION)
	$(UNTAR)/$(NANO_SOURCE)
	set -e; cd $(BUILD_TMP)/nano-$(NANO_VERSION); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-nls \
			--enable-tiny \
			--enable-color \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/nano-$(NANO_VERSION)
	$(TOUCH)

#
# rsync
#
RSYNC_VERSION = 3.1.2
RSYNC_SOURCE = rsync-$(RSYNC_VERSION).tar.gz

$(ARCHIVE)/$(RSYNC_SOURCE):
	$(WGET) https://ftp.samba.org/pub/rsync/$(RSYNC_SOURCE)

$(D)/rsync: $(D)/bootstrap $(ARCHIVE)/$(RSYNC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/rsync-$(RSYNC_VERSION)
	$(UNTAR)/$(RSYNC_SOURCE)
	set -e; cd $(BUILD_TMP)/rsync-$(RSYNC_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--disable-debug \
			--disable-locale \
		; \
		$(MAKE) all; \
		$(MAKE) install-all DESTDIR=$(TARGET_DIR)
	$(REMOVE)/rsync-$(RSYNC_VERSION)
	$(TOUCH)

#
# fuse
#
FUSE_VERSION = 2.9.7
FUSE_SOURCE = fuse-$(FUSE_VERSION).tar.gz

$(ARCHIVE)/$(FUSE_SOURCE):
	$(WGET) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VERSION)/$(FUSE_SOURCE)

$(D)/fuse: $(D)/bootstrap $(ARCHIVE)/$(FUSE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fuse-$(FUSE_VERSION)
	$(UNTAR)/$(FUSE_SOURCE)
	set -e; cd $(BUILD_TMP)/fuse-$(FUSE_VERSION); \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		-rm $(TARGET_DIR)/etc/udev/rules.d/99-fuse.rules
		-rmdir $(TARGET_DIR)/etc/udev/rules.d
		-rmdir $(TARGET_DIR)/etc/udev
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REMOVE)/fuse-$(FUSE_VERSION)
	$(TOUCH)

#
# curlftpfs
#
CURLFTPFS_VERSION = 0.9.2
CURLFTPFS_SOURCE = curlftpfs-$(CURLFTPFS_VERSION).tar.gz
CURLFTPFS_PATCH = curlftpfs-$(CURLFTPFS_VERSION).patch

$(ARCHIVE)/$(CURLFTPFS_SOURCE):
	$(WGET) https://sourceforge.net/projects/curlftpfs/files/latest/download/$(CURLFTPFS_SOURCE)

$(D)/curlftpfs: $(D)/bootstrap $(D)/libcurl $(D)/fuse $(D)/libglib2 $(ARCHIVE)/$(CURLFTPFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VERSION)
	$(UNTAR)/$(CURLFTPFS_SOURCE)
	set -e; cd $(BUILD_TMP)/curlftpfs-$(CURLFTPFS_VERSION); \
		$(call post_patch,$(CURLFTPFS_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes && \
		export ac_cv_func_realloc_0_nonnull=yes && \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VERSION)
	$(TOUCH)

#
# sdparm
#
SDPARM_VERSION = 1.10
SDPARM_SOURCE = sdparm-$(SDPARM_VERSION).tgz

$(ARCHIVE)/$(SDPARM_SOURCE):
	$(WGET) http://sg.danny.cz/sg/p/$(SDPARM_SOURCE)

$(D)/sdparm: $(D)/bootstrap $(ARCHIVE)/$(SDPARM_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sdparm-$(SDPARM_VERSION)
	$(UNTAR)/$(SDPARM_SOURCE)
	set -e; cd $(BUILD_TMP)/sdparm-$(SDPARM_VERSION); \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/sbin \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/sbin/,sas_disk_blink scsi_ch_swp)
	$(REMOVE)/sdparm-$(SDPARM_VERSION)
	$(TOUCH)

#
# hddtemp
#
HDDTEMP_VERSION = 0.3-beta15
HDDTEMP_SOURCE = hddtemp-$(HDDTEMP_VERSION).tar.bz2

$(ARCHIVE)/$(HDDTEMP_SOURCE):
	$(WGET) http://savannah.c3sl.ufpr.br/hddtemp/$(HDDTEMP_SOURCE)

$(D)/hddtemp: $(D)/bootstrap $(ARCHIVE)/$(HDDTEMP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hddtemp-$(HDDTEMP_VERSION)
	$(UNTAR)/$(HDDTEMP_SOURCE)
	set -e; cd $(BUILD_TMP)/hddtemp-$(HDDTEMP_VERSION); \
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
	$(REMOVE)/hddtemp-$(HDDTEMP_VERSION)
	$(TOUCH)

#
# hdparm
#
HDPARM_VERSION = 9.52
HDPARM_SOURCE = hdparm-$(HDPARM_VERSION).tar.gz

$(ARCHIVE)/$(HDPARM_SOURCE):
	$(WGET) https://sourceforge.net/projects/hdparm/files/hdparm/$(HDPARM_SOURCE)

$(D)/hdparm: $(D)/bootstrap $(ARCHIVE)/$(HDPARM_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hdparm-$(HDPARM_VERSION)
	$(UNTAR)/$(HDPARM_SOURCE)
	set -e; cd $(BUILD_TMP)/hdparm-$(HDPARM_VERSION); \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/hdparm-$(HDPARM_VERSION)
	$(TOUCH)

#
# hd-idle
#
HDIDLE_VERSION = 1.05
HDIDLE_SOURCE = hd-idle-$(HDIDLE_VERSION).tgz

$(ARCHIVE)/$(HDIDLE_SOURCE):
	$(WGET) https://sourceforge.net/projects/hd-idle/files/$(HDIDLE_SOURCE)

$(D)/hd-idle: $(D)/bootstrap $(ARCHIVE)/$(HDIDLE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/hd-idle
	$(UNTAR)/$(HDIDLE_SOURCE)
	set -e; cd $(BUILD_TMP)/hd-idle; \
		sed -i -e 's/-g root -o root//g' Makefile; \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install TARGET_DIR=$(TARGET_DIR) install
	$(REMOVE)/hd-idle
	$(TOUCH)

#
# fbshot
#
FBSHOT_VERSION = 0.3
FBSHOT_SOURCE = fbshot-$(FBSHOT_VERSION).tar.gz
FBSHOT_PATCH = fbshot-$(FBSHOT_VERSION).patch

$(ARCHIVE)/$(FBSHOT_SOURCE):
	$(WGET) http://www.sourcefiles.org/Graphics/Tools/Capture/$(FBSHOT_SOURCE)

$(D)/fbshot: $(TARGET_DIR)/bin/fbshot
	$(TOUCH)

$(TARGET_DIR)/bin/fbshot: $(D)/bootstrap $(D)/libpng $(ARCHIVE)/$(FBSHOT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fbshot-$(FBSHOT_VERSION)
	$(UNTAR)/$(FBSHOT_SOURCE)
	set -e; cd $(BUILD_TMP)/fbshot-$(FBSHOT_VERSION); \
		$(call post_patch,$(FBSHOT_PATCH)); \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT_VERSION)
	@touch $@

#
# parted
#
PARTED_VERSION = 3.2
PARTED_SOURCE = parted-$(PARTED_VERSION).tar.xz
PARTED_PATCH = parted-$(PARTED_VERSION)-device-mapper.patch

$(ARCHIVE)/$(PARTED_SOURCE):
	$(WGET) http://ftp.gnu.org/gnu/parted/$(PARTED_SOURCE)

$(D)/parted: $(D)/bootstrap $(D)/libncurses $(D)/libreadline $(D)/e2fsprogs $(ARCHIVE)/$(PARTED_SOURCE)
	$(START_BUILD)
	$(REMOVE)/parted-$(PARTED_VERSION)
	$(UNTAR)/$(PARTED_SOURCE)
	set -e; cd $(BUILD_TMP)/parted-$(PARTED_VERSION); \
		$(call post_patch,$(PARTED_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-device-mapper \
			--disable-nls \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REMOVE)/parted-$(PARTED_VERSION)
	$(TOUCH)

#
# sysstat
#
SYSSTAT_VERSION = 11.3.5
SYSSTAT_SOURCE = sysstat-$(SYSSTAT_VERSION).tar.bz2

$(ARCHIVE)/$(SYSSTAT_SOURCE):
	$(WGET) http://pagesperso-orange.fr/sebastien.godard/$(SYSSTAT_SOURCE)

$(D)/sysstat: $(D)/bootstrap $(ARCHIVE)/$(SYSSTAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sysstat-$(SYSSTAT_VERSION)
	$(UNTAR)/$(SYSSTAT_SOURCE)
	set -e; cd $(BUILD_TMP)/sysstat-$(SYSSTAT_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/sysstat-$(SYSSTAT_VERSION)
	$(TOUCH)

#
# autofs
#
AUTOFS_VERSION = 4.1.4
AUTOFS_SOURCE = autofs-$(AUTOFS_VERSION).tar.gz
AUTOFS_PATCH = autofs-$(AUTOFS_VERSION).patch

$(ARCHIVE)/$(AUTOFS_SOURCE):
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/$(AUTOFS_SOURCE)

$(D)/autofs: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(AUTOFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/autofs-$(AUTOFS_VERSION)
	$(UNTAR)/$(AUTOFS_SOURCE)
	set -e; cd $(BUILD_TMP)/autofs-$(AUTOFS_VERSION); \
		$(call post_patch,$(AUTOFS_PATCH)); \
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
	$(REMOVE)/autofs-$(AUTOFS_VERSION)
	$(TOUCH)

#
# imagemagick
#
IMAGEMAGICK_VERSION = 6.7.7-7
IMAGEMAGICK_SOURCE = ImageMagick-$(IMAGEMAGICK_VERSION).tar.gz

$(ARCHIVE)/$(IMAGEMAGICK_SOURCE):
	$(WGET) ftp://ftp.fifi.org/pub/ImageMagick/$(IMAGEMAGICK_SOURCE)

$(D)/imagemagick: $(D)/bootstrap $(ARCHIVE)/$(IMAGEMAGICK_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ImageMagick-$(IMAGEMAGICK_VERSION)
	$(UNTAR)/$(IMAGEMAGICK_SOURCE)
	set -e; cd $(BUILD_TMP)/ImageMagick-$(IMAGEMAGICK_VERSION); \
		$(BUILDENV) \
		CFLAGS="-O1" \
		PKG_CONFIG=$(PKG_CONFIG) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--without-dps \
			--without-fpx \
			--without-gslib \
			--without-jbig \
			--without-jp2 \
			--without-lcms \
			--without-tiff \
			--without-xml \
			--without-perl \
			--disable-openmp \
			--disable-opencl \
			--without-zlib \
			--enable-shared \
			--enable-static \
			--without-x \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ImageMagick.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/MagickCore.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/MagickWand.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/Wand.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ImageMagick++.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/Magick++.pc
	$(REWRITE_LIBTOOL)/libMagickCore.la
	$(REWRITE_LIBTOOL)/libMagickWand.la
	$(REWRITE_LIBTOOL)/libMagick++.la
	$(REMOVE)/ImageMagick-$(IMAGEMAGICK_VERSION)
	$(TOUCH)

#
# shairport
#
$(D)/shairport: $(D)/bootstrap $(D)/openssl $(D)/howl $(D)/alsa-lib
	$(START_BUILD)
	$(REMOVE)/shairport
	set -e; if [ -d $(ARCHIVE)/shairport.git ]; \
		then cd $(ARCHIVE)/shairport.git; git pull; \
		else cd $(ARCHIVE); git clone -b 1.0-dev git://github.com/abrasive/shairport.git shairport.git; \
		fi
	cp -ra $(ARCHIVE)/shairport.git $(BUILD_TMP)/shairport
	set -e; cd $(BUILD_TMP)/shairport; \
		sed -i 's|pkg-config|$$PKG_CONFIG|g' configure; \
		PKG_CONFIG=$(PKG_CONFIG) \
		$(BUILDENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr
	$(REMOVE)/shairport
	$(TOUCH)

#
# dbus
#
DBUS_VERSION = 1.8.0
DBUS_SOURCE = dbus-$(DBUS_VERSION).tar.gz

$(ARCHIVE)/$(DBUS_SOURCE):
	$(WGET) http://dbus.freedesktop.org/releases/dbus/$(DBUS_SOURCE)

$(D)/dbus: $(D)/bootstrap $(D)/libexpat $(ARCHIVE)/$(DBUS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dbus-$(DBUS_VERSION)
	$(UNTAR)/$(DBUS_SOURCE)
	set -e; cd $(BUILD_TMP)/dbus-$(DBUS_VERSION); \
		$(CONFIGURE) \
		CFLAGS="$(TARGET_CFLAGS) -Wno-cast-align" \
			--without-x \
			--prefix=/usr \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--with-console-auth-dir=/run/console/ \
			--without-systemdsystemunitdir \
			--enable-abstract-sockets \
			--disable-systemd \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dbus-1.pc
	$(REWRITE_LIBTOOL)/libdbus-1.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,dbus-cleanup-sockets dbus-daemon dbus-launch dbus-monitor)
	$(REMOVE)/dbus-$(DBUS_VERSION)
	$(TOUCH)

#
# avahi
#
AVAHI_VERSION = 0.6.32
AVAHI_SOURCE = avahi-$(AVAHI_VERSION).tar.gz

$(ARCHIVE)/$(AVAHI_SOURCE):
	$(WGET) https://github.com/lathiat/avahi/releases/download/v$(AVAHI_VERSION)/$(AVAHI_SOURCE)

$(D)/avahi: $(D)/bootstrap $(D)/libexpat $(D)/libdaemon $(D)/dbus $(ARCHIVE)/$(AVAHI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/avahi-$(AVAHI_VERSION)
	$(UNTAR)/$(AVAHI_SOURCE)
	set -e; cd $(BUILD_TMP)/avahi-$(AVAHI_VERSION); \
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
	$(REMOVE)/avahi-$(AVAHI_VERSION)
	$(TOUCH)

#
# wget
#
WGET_VERSION = 1.19.1
WGET_SOURCE = wget-$(WGET_VERSION).tar.xz

$(ARCHIVE)/$(WGET_SOURCE):
	$(WGET) http://ftp.gnu.org/gnu/wget/$(WGET_SOURCE)

$(D)/wget: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(WGET_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wget-$(WGET_VERSION)
	$(UNTAR)/$(WGET_SOURCE)
	set -e; cd $(BUILD_TMP)/wget-$(WGET_VERSION); \
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
	$(REMOVE)/wget-$(WGET_VERSION)
	$(TOUCH)

#
# coreutils
#
COREUTILS_VERSION = 8.23
COREUTILS_SOURCE = coreutils-$(COREUTILS_VERSION).tar.xz
COREUTILS_PATCH = coreutils-$(COREUTILS_VERSION).patch

$(ARCHIVE)/$(COREUTILS_SOURCE):
	$(WGET) http://ftp.gnu.org/gnu/coreutils/$(COREUTILS_SOURCE)

$(D)/coreutils: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(COREUTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/coreutils-$(COREUTILS_VERSION)
	$(UNTAR)/$(COREUTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/coreutils-$(COREUTILS_VERSION); \
		$(call post_patch,$(COREUTILS_PATCH)); \
		export fu_cv_sys_stat_statfs2_bsize=yes; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-largefile \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/coreutils-$(COREUTILS_VERSION)
	$(TOUCH)

#
# smartmontools
#
SMARTMONTOOLS_VERSION = 6.4
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VERSION).tar.gz

$(ARCHIVE)/$(SMARTMONTOOLS_SOURCE):
	$(WGET) https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VERSION)/$(SMARTMONTOOLS_SOURCE)

$(D)/smartmontools: $(D)/bootstrap $(ARCHIVE)/$(SMARTMONTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VERSION)
	$(UNTAR)/$(SMARTMONTOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/smartmontools-$(SMARTMONTOOLS_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGET_DIR)/usr
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VERSION)
	$(TOUCH)

#
# nfs_utils
#
NFSUTILS_VERSION = 1.3.3
NFSUTILS_SOURCE = nfs-utils-$(NFSUTILS_VERSION).tar.bz2
NFSUTILS_PATCH = nfs-utils-$(NFSUTILS_VERSION).patch

$(ARCHIVE)/$(NFSUTILS_SOURCE):
	$(WGET) https://sourceforge.net/projects/nfs/files/nfs-utils/$(NFSUTILS_VERSION)/$(NFSUTILS_SOURCE)

$(D)/nfs_utils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/$(NFSUTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/nfs-utils-$(NFSUTILS_VERSION)
	$(UNTAR)/$(NFSUTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/nfs-utils-$(NFSUTILS_VERSION); \
		$(call post_patch,$(NFSUTILS_PATCH)); \
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
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,mountstats nfsiostat nfsstat rpcdebug showmount sm-notify start-statd)
	$(REMOVE)/nfs-utils-$(NFSUTILS_VERSION)
	$(TOUCH)

#
# libevent
#
LIBEVENT_VERSION = 2.0.21-stable
LIBEVENT_SOURCE = libevent-$(LIBEVENT_VERSION).tar.gz

$(ARCHIVE)/$(LIBEVENT_SOURCE):
	$(WGET) https://github.com/downloads/libevent/libevent/$(LIBEVENT_SOURCE)

$(D)/libevent: $(D)/bootstrap $(ARCHIVE)/$(LIBEVENT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libevent-$(LIBEVENT_VERSION)
	$(UNTAR)/$(LIBEVENT_SOURCE)
	set -e; cd $(BUILD_TMP)/libevent-$(LIBEVENT_VERSION);\
		$(CONFIGURE) \
			--prefix=$(TARGET_DIR)/usr \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libevent-$(LIBEVENT_VERSION)
	$(TOUCH)

#
# libnfsidmap
#
LIBNFSIDMAP_VERSION = 0.25
LIBNFSIDMAP_SOURCE = libnfsidmap-$(LIBNFSIDMAP_VERSION).tar.gz

$(ARCHIVE)/$(LIBNFSIDMAP_SOURCE):
	$(WGET) http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/$(LIBNFSIDMAP_SOURCE)

$(D)/libnfsidmap: $(D)/bootstrap $(ARCHIVE)/$(LIBNFSIDMAP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VERSION)
	$(UNTAR)/$(LIBNFSIDMAP_SOURCE)
	set -e; cd $(BUILD_TMP)/libnfsidmap-$(LIBNFSIDMAP_VERSION);\
		$(CONFIGURE) \
		ac_cv_func_malloc_0_nonnull=yes \
			--prefix=$(TARGET_DIR)/usr \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VERSION)
	$(TOUCH)

#
# vsftpd
#
VSFTPD_VERSION = 3.0.3
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_PATCH = vsftpd-$(VSFTPD_VERSION).patch

$(ARCHIVE)/$(VSFTPD_SOURCE):
	$(WGET) https://security.appspot.com/downloads/$(VSFTPD_SOURCE)

$(D)/vsftpd: $(D)/bootstrap $(ARCHIVE)/$(VSFTPD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/vsftpd-$(VSFTPD_VERSION)
	$(UNTAR)/$(VSFTPD_SOURCE)
	set -e; cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VERSION); \
		$(call post_patch,$(VSFTPD_PATCH)); \
		$(MAKE) clean; \
		$(MAKE) $(BUILDENV); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/vsftpd $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/vsftpd.conf $(TARGET_DIR)/etc/
	$(REMOVE)/vsftpd-$(VSFTPD_VERSION)
	$(TOUCH)

#
# ethtool
#
ETHTOOL_VERSION = 6
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VERSION).tar.gz

$(ARCHIVE)/$(ETHTOOL_SOURCE):
	$(WGET) http://downloads.openwrt.org/sources/$(ETHTOOL_SOURCE)

$(D)/ethtool: $(D)/bootstrap $(ARCHIVE)/$(ETHTOOL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ethtool-$(ETHTOOL_VERSION)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	set -e; cd $(BUILD_TMP)/ethtool-$(ETHTOOL_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--libdir=$(TARGET_DIR)/usr/lib \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VERSION)
	$(TOUCH)

#
# samba
#
SAMBA_VERSION = 3.6.25
SAMBA_SOURCE = samba-$(SAMBA_VERSION).tar.gz
SAMBA_PATCH = samba-$(SAMBA_VERSION).patch

$(ARCHIVE)/$(SAMBA_SOURCE):
	$(WGET) https://ftp.samba.org/pub/samba/stable/$(SAMBA_SOURCE)

$(D)/samba: $(D)/bootstrap $(ARCHIVE)/$(SAMBA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/samba-$(SAMBA_VERSION)
	$(UNTAR)/$(SAMBA_SOURCE)
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA_VERSION); \
		$(call post_patch,$(SAMBA_PATCH)); \
		cd source3; \
		./autogen.sh; \
		$(BUILDENV) \
		libreplace_cv_HAVE_GETADDRINFO=no \
		libreplace_cv_READDIR_NEEDED=no \
		./configure $(CONFIGURE_SILENT) \
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
		; \
		$(MAKE) $(MAKE_OPTS); \
		$(MAKE) $(MAKE_OPTS) installservers installbin installscripts installdat installmodules \
			SBIN_PROGS="bin/smbd bin/nmbd bin/winbindd" DESTDIR=$(TARGET_DIR) prefix=./. ; \
	install -m 755 $(SKEL_ROOT)/etc/init.d/samba $(TARGET_DIR)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/samba/smb.conf $(TARGET_DIR)/etc/samba/
	$(REMOVE)/samba-$(SAMBA_VERSION)
	$(TOUCH)

#
# ntp
#
NTP_VERSION = 4.2.8p3
NTP_SOURCE = ntp-$(NTP_VERSION).tar.gz
NTP_PATCH = ntp-$(NTP_VERSION).patch

$(ARCHIVE)/$(NTP_SOURCE):
	$(WGET) https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/$(NTP_SOURCE)

$(D)/ntp: $(D)/bootstrap $(ARCHIVE)/$(NTP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ntp-$(NTP_VERSION)
	$(UNTAR)/$(NTP_SOURCE)
	set -e; cd $(BUILD_TMP)/ntp-$(NTP_VERSION); \
		$(call post_patch,$(NTP_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-tick \
			--disable-tickadj \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			--disable-debugging \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ntp-$(NTP_VERSION)
	$(TOUCH)

#
# wireless_tools
#
WIRELESS_TOOLS_VERSION = 29
WIRELESS_TOOLS_SOURCE = wireless_tools.$(WIRELESS_TOOLS_VERSION).tar.gz
WIRELESS_TOOLS_PATCH = wireless-tools.$(WIRELESS_TOOLS_VERSION).patch

$(ARCHIVE)/$(WIRELESS_TOOLS_SOURCE):
	$(WGET) http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/$(WIRELESS_TOOLS_SOURCE)

$(D)/wireless_tools: $(D)/bootstrap $(ARCHIVE)/$(WIRELESS_TOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wireless_tools.$(WIRELESS_TOOLS_VERSION)
	$(UNTAR)/$(WIRELESS_TOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/wireless_tools.$(WIRELESS_TOOLS_VERSION); \
		$(call post_patch,$(WIRELESS_TOOLS_PATCH)); \
		$(MAKE) CC="$(TARGET)-gcc" CFLAGS="$(TARGET_CFLAGS) -I."; \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr INSTALL_MAN=$(TARGET_DIR)/.remove
	$(REMOVE)/wireless_tools.$(WIRELESS_TOOLS_VERSION)
	$(TOUCH)

#
# libnl
#
LIBNL_VERSION = 2.0
LIBNL_SOURCE = libnl-$(LIBNL_VERSION).tar.gz

$(ARCHIVE)/$(LIBNL_SOURCE):
	$(WGET) http://www.carisma.slowglass.com/~tgr/libnl/files/$(LIBNL_SOURCE)

$(D)/libnl: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/$(LIBNL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libnl-$(LIBNL_VERSION)
	$(UNTAR)/$(LIBNL_SOURCE)
	set -e; cd $(BUILD_TMP)/libnl-$(LIBNL_VERSION); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--mandir=/.remove \
			--infodir=/.remove \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/libnl-$(LIBNL_VERSION)
	$(TOUCH)

#
# wpa_supplicant
#
WPA_SUPPLICANT_VERSION = 0.7.3
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz

$(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE):
	$(WGET) http://hostap.epitest.fi/releases/$(WPA_SUPPLICANT_SOURCE)

$(D)/wpa_supplicant: $(D)/bootstrap $(D)/openssl $(D)/wireless_tools $(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
	$(UNTAR)/$(WPA_SUPPLICANT_SOURCE)
	set -e; cd $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VERSION)/wpa_supplicant; \
		cp -f defconfig .config; \
		sed -i 's/#CONFIG_DRIVER_RALINK=y/CONFIG_DRIVER_RALINK=y/' .config; \
		sed -i 's/#CONFIG_IEEE80211W=y/CONFIG_IEEE80211W=y/' .config; \
		sed -i 's/#CONFIG_OS=unix/CONFIG_OS=unix/' .config; \
		sed -i 's/#CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config; \
		sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/' .config; \
		sed -i 's/#CONFIG_INTERWORKING=y/CONFIG_INTERWORKING=y/' .config; \
		export CFLAGS="-pipe -Os -Wall -g0 -I$(TARGET_DIR)/usr/include"; \
		export CPPFLAGS="-I$(TARGET_DIR)/usr/include"; \
		export LIBS="-L$(TARGET_DIR)/usr/lib -Wl,-rpath-link,$(TARGET_DIR)/usr/lib"; \
		export LDFLAGS="-L$(TARGET_DIR)/usr/lib"; \
		export DESTDIR=$(TARGET_DIR); \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install BINDIR=/usr/sbin DESTDIR=$(TARGET_DIR)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
	$(TOUCH)

#
# dvbsnoop
#
DVBSNOOP_VERSION = 42f98ff
DVBSNOOP_SOURCE = dvbsnoop-$(DVBSNOOP_VERSION).tar.bz2
DVBSNOOP_URL = https://github.com/cotdp/dvbsnoop.git

$(ARCHIVE)/$(DVBSNOOP_SOURCE):
	get-git-archive.sh $(DVBSNOOP_URL) $(DVBSNOOP_VERSION) $(notdir $@) $(ARCHIVE)

$(D)/dvbsnoop: $(D)/bootstrap $(ARCHIVE)/$(DVBSNOOP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dvbsnoop-$(DVBSNOOP_VERSION)
	$(UNTAR)/$(DVBSNOOP_SOURCE)
	set -e; cd $(BUILD_TMP)/dvbsnoop-$(DVBSNOOP_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dvbsnoop-$(DVBSNOOP_VERSION)
	$(TOUCH)

#
# udpxy
#
UDPXY_VERSION = 1.0.23-9
UDPXY_SOURCE = udpxy.$(UDPXY_VERSION)-prod.tar.gz
UDPXY_PATCH = udpxy-$(UDPXY_VERSION).patch

$(ARCHIVE)/$(UDPXY_SOURCE):
	$(WGET) http://www.udpxy.com/download/1_23/$(UDPXY_SOURCE)

$(D)/udpxy: $(D)/bootstrap $(ARCHIVE)/$(UDPXY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/udpxy-$(UDPXY_VERSION)
	$(UNTAR)/$(UDPXY_SOURCE)
	set -e; cd $(BUILD_TMP)/udpxy-$(UDPXY_VERSION); \
		$(call post_patch,$(UDPXY_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc CCKIND=gcc; \
		$(MAKE) install INSTALLROOT=$(TARGET_DIR)/usr MANPAGE_DIR=$(TARGET_DIR)/.remove
	$(REMOVE)/udpxy-$(UDPXY_VERSION)
	$(TOUCH)

#
# openvpn
#
OPENVPN_VERSION = 2.4.3
OPENVPN_SOURCE = openvpn-$(OPENVPN_VERSION).tar.xz

$(ARCHIVE)/$(OPENVPN_SOURCE):
	$(WGET) http://swupdate.openvpn.org/community/releases/$(OPENVPN_SOURCE)

$(D)/openvpn: $(D)/bootstrap $(D)/openssl $(D)/lzo $(ARCHIVE)/$(OPENVPN_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openvpn-$(OPENVPN_VERSION)
	$(UNTAR)/$(OPENVPN_SOURCE)
	set -e; cd $(BUILD_TMP)/openvpn-$(OPENVPN_VERSION); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-selinux \
			--disable-systemd \
			--disable-plugins \
			--disable-debug \
			--disable-pkcs11 \
			--enable-small \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/openvpn $(TARGET_DIR)/etc/init.d/
	install -d $(TARGET_DIR)/etc/openvpn
	$(REMOVE)/openvpn-$(OPENVPN_VERSION)
	$(TOUCH)

#
# openssh
#
OPENSSH_VERSION = 7.5p1
OPENSSH_SOURCE = openssh-$(OPENSSH_VERSION).tar.gz

$(ARCHIVE)/$(OPENSSH_SOURCE):
	$(WGET) http://artfiles.org/openbsd/OpenSSH/portable/$(OPENSSH_SOURCE)

$(D)/openssh: $(D)/bootstrap $(D)/zlib $(D)/openssl $(ARCHIVE)/$(OPENSSH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openssh-$(OPENSSH_VERSION)
	$(UNTAR)/$(OPENSSH_SOURCE)
	set -e; cd $(BUILD_TMP)/openssh-$(OPENSSH_VERSION); \
		CC=$(TARGET)-gcc; \
		./configure $(CONFIGURE_SILENT) \
			$(CONFIGURE_OPTS) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc/ssh \
			--libexecdir=/sbin \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe -Os -I$(TARGET_DIR)/usr/include" \
			--with-ldflags=-"L$(TARGET_DIR)/usr/lib" \
		; \
		$(MAKE); \
		$(MAKE) install-nokeys DESTDIR=$(TARGET_DIR)
	install -m 755 $(BUILD_TMP)/openssh-$(OPENSSH_VERSION)/opensshd.init $(TARGET_DIR)/etc/init.d/openssh
	sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' $(TARGET_DIR)/etc/ssh/sshd_config
	$(REMOVE)/openssh-$(OPENSSH_VERSION)
	$(TOUCH)

#
# usb-modeswitch-data
#
USB_MODESWITCH_DATA_VERSION = 20160112
USB_MODESWITCH_DATA_SOURCE = usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION).tar.bz2
USB_MODESWITCH_DATA_PATCH = usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION).patch

$(ARCHIVE)/$(USB_MODESWITCH_DATA_SOURCE):
	$(WGET) http://www.draisberghof.de/usb_modeswitch/$(USB_MODESWITCH_DATA_SOURCE)

$(D)/usb-modeswitch-data: $(D)/bootstrap $(ARCHIVE)/$(USB_MODESWITCH_DATA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION)
	$(UNTAR)/$(USB_MODESWITCH_DATA_SOURCE)
	set -e; cd $(BUILD_TMP)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION); \
		$(call post_patch,$(USB_MODESWITCH_DATA_PATCH)); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION)
	$(TOUCH)

#
# usb-modeswitch
#
USB_MODESWITCH_VERSION = 2.3.0
USB_MODESWITCH_SOURCE = usb-modeswitch-$(USB_MODESWITCH_VERSION).tar.bz2
USB_MODESWITCH_PATCH = usb-modeswitch-$(USB_MODESWITCH_VERSION).patch

$(ARCHIVE)/$(USB_MODESWITCH_SOURCE):
	$(WGET) http://www.draisberghof.de/usb_modeswitch/$(USB_MODESWITCH_SOURCE)

$(D)/usb-modeswitch: $(D)/bootstrap $(D)/libusb $(D)/usb-modeswitch-data $(ARCHIVE)/$(USB_MODESWITCH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VERSION)
	$(UNTAR)/$(USB_MODESWITCH_SOURCE)
	set -e; cd $(BUILD_TMP)/usb-modeswitch-$(USB_MODESWITCH_VERSION); \
		$(call post_patch,$(USB_MODESWITCH_PATCH)); \
		sed -i -e "s/= gcc/= $(TARGET)-gcc/" -e "s/-l usb/-lusb -lusb-1.0 -lpthread -lrt/" -e "s/install -D -s/install -D --strip-program=$(TARGET)-strip -s/" Makefile; \
		sed -i -e "s/@CC@/$(TARGET)-gcc/g" jim/Makefile.in; \
		$(BUILDENV) $(MAKE) DESTDIR=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VERSION)
	$(TOUCH)
