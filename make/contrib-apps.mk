#
# busybox
#
BUSYBOX_VER = 1.26.0
BUSYBOX_PATCH  = busybox-$(BUSYBOX_VER)-nandwrite.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-unicode.patch
BUSYBOX_PATCH += busybox-$(BUSYBOX_VER)-extra.patch

$(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 ufs912 ufs913))
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VER).config_nandwrite
else
BUSYBOX_CONFIG = busybox-$(BUSYBOX_VER).config
endif

$(D)/busybox: $(D)/bootstrap $(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2 $(PATCHES)/$(BUSYBOX_CONFIG)
	$(START_BUILD)
	$(REMOVE)/busybox-$(BUSYBOX_VER)
	$(UNTAR)/busybox-$(BUSYBOX_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/busybox-$(BUSYBOX_VER); \
		$(call post_patch,$(BUSYBOX_PATCH)); \
		install -m 0644 $(lastword $^) .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGETPREFIX)"#' .config; \
		$(BUILDENV) $(MAKE) busybox CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		$(MAKE) install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" CONFIG_PREFIX=$(TARGETPREFIX)
#	$(REMOVE)/busybox-$(BUSYBOX_VER)
	$(TOUCH)

#
# host_pkgconfig
#
PKGCONFIG_VER = 0.29.1

$(ARCHIVE)/pkg-config-$(PKGCONFIG_VER).tar.gz:
	$(WGET) http://pkgconfig.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz

pkg-config-preqs:
	@PATH=$(subst $(HOSTPREFIX)/bin:,,$(PATH)); \
	if ! pkg-config --exists glib-2.0; then \
		echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
	fi

$(D)/host_pkgconfig: directories $(ARCHIVE)/pkg-config-$(PKGCONFIG_VER).tar.gz | pkg-config-preqs
	$(START_BUILD)
	$(REMOVE)/pkg-config-$(PKGCONFIG_VER)
	$(UNTAR)/pkg-config-$(PKGCONFIG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pkg-config-$(PKGCONFIG_VER); \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOSTPREFIX) \
			--program-prefix=$(TARGET)- \
			--disable-host-tool \
			--with-pc_path=$(PKG_CONFIG_PATH) \
		; \
		$(MAKE); \
		$(MAKE) install
	ln -sf $(TARGET)-pkg-config $(HOSTPREFIX)/bin/pkg-config
	$(REMOVE)/pkg-config-$(PKGCONFIG_VER)
	$(TOUCH)

#
# host_mtd_utils
#
MTD_UTILS_VER = 1.5.2
MTD_UTILS_PATCH =
MTD_UTILS_HOST_PATCH = host-mtd-utils-$(MTD_UTILS_VER).patch

$(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(MTD_UTILS_VER).tar.bz2

$(D)/host_mtd_utils: directories $(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(UNTAR)/mtd-utils-$(MTD_UTILS_VER).tar.bz2; \
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER); \
		$(call post_patch,$(MTD_UTILS_HOST_PATCH)); \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(HOSTPREFIX); \
		$(MAKE) install DESTDIR=$(HOSTPREFIX)/bin
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(TOUCH)

#
# mtd_utils
#
$(D)/mtd_utils: $(D)/bootstrap $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(UNTAR)/mtd-utils-$(MTD_UTILS_VER).tar.bz2 ; \
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER); \
		$(BUILDENV) \
		$(MAKE) PREFIX= CC=$(TARGET)-gcc LD=$(TARGET)-ld STRIP=$(TARGET)-strip WITHOUT_XATTR=1 DESTDIR=$(TARGETPREFIX); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER)
	$(TOUCH)

#
# gdb
#
GDB_VER = 7.8
GDB_PATCH = gdb-$(GDB_VER)-remove-builddate.patch

$(ARCHIVE)/gdb-$(GDB_VER).tar.xz:
	$(WGET) ftp://sourceware.org/pub/gdb/releases/gdb-$(GDB_VER).tar.xz

# gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/gdb-$(GDB_VER).tar.xz | $(TARGETPREFIX)
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/gdb-$(GDB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		./configure $(CONFIGURE_SILENT) \
			--nfp --disable-werror \
			--prefix=$(HOSTPREFIX) \
			--build=$(BUILD) \
			--host=$(BUILD) \
			--target=$(TARGET) \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb; \
	$(REMOVE)/gdb-$(GDB_VER)
	$(TOUCH)

# gdb built for target or local-PC
$(D)/gdb: $(D)/bootstrap $(D)/libncurses $(D)/zlib $(ARCHIVE)/gdb-$(GDB_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gdb-$(GDB_VER)
	$(UNTAR)/gdb-$(GDB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		$(call post_patch,$(GDB_PATCH)); \
		./configure $(CONFIGURE_SILENT) \
			--host=$(BUILD) \
			--build=$(BUILD) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=$(TARGETPREFIX)/.remove \
			--infodir=$(TARGETPREFIX)/.remove \
			--nfp --disable-werror \
		; \
		$(MAKE) all-gdb; \
		$(MAKE) install-gdb prefix=$(TARGETPREFIX)
	$(REMOVE)/gdb-$(GDB_VER)
	$(TOUCH)

#
# opkg
#
OPKG_VER = 0.3.3
OPKG_PATCH = opkg-$(OPKG_VER).patch
OPKG_HOST_PATCH = opkg-$(OPKG_VER).patch

$(ARCHIVE)/opkg-$(OPKG_VER).tar.gz:
	$(WGET) https://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/opkg-$(OPKG_VER).tar.gz

$(D)/opkg_host: directories $(D)/host_libarchive $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		$(call post_patch,$(OPKG_HOST_PATCH)); \
		./autogen.sh; \
		CFLAGS="-I$(HOSTPREFIX)/include" \
		LDFLAGS="-L$(HOSTPREFIX)/lib" \
		./configure $(CONFIGURE_SILENT) \
			PKG_CONFIG_PATH=$(HOSTPREFIX)/lib/pkgconfig \
			--prefix= \
			--disable-curl \
			--disable-gpg \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(HOSTPREFIX)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(TOUCH)

$(D)/opkg: $(D)/bootstrap $(D)/opkg_host $(D)/libarchive $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		$(call post_patch,$(OPKG_PATCH)); \
		LIBARCHIVE_LIBS="-L$(TARGETPREFIX)/usr/lib -larchive" \
		LIBARCHIVE_CFLAGS="-I$(TARGETPREFIX)/usr/include" \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-curl \
			--disable-gpg \
			--mandir=/.remove \
		; \
		$(MAKE) all ; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -d -m 0755 $(TARGETPREFIX)/usr/lib/opkg
	install -d -m 0755 $(TARGETPREFIX)/etc/opkg
	ln -sf opkg $(TARGETPREFIX)/usr/bin/opkg-cl
	$(REWRITE_LIBTOOL)/libopkg.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	$(REMOVE)/opkg-$(OPKG_VER)
	$(TOUCH)

#
# sysvinit
#
SYSVINIT_VER = 2.88dsf

$(ARCHIVE)/sysvinit_$(SYSVINIT_VER).orig.tar.gz:
	$(WGET) ftp://ftp.debian.org/debian/pool/main/s/sysvinit/sysvinit_$(SYSVINIT_VER).orig.tar.gz

$(D)/sysvinit: $(D)/bootstrap $(ARCHIVE)/sysvinit_$(SYSVINIT_VER).orig.tar.gz
	$(START_BUILD)
	$(REMOVE)/sysvinit-$(SYSVINIT_VER)
	$(UNTAR)/sysvinit_$(SYSVINIT_VER).orig.tar.gz
	set -e; cd $(BUILD_TMP)/sysvinit-$(SYSVINIT_VER); \
		sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
		-e '/bootlogd/d' -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile; \
		$(BUILDENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGETPREFIX) MANDIR=/.remove
	cd $(TARGETPREFIX) && rm sbin/fstab-decode sbin/runlevel sbin/telinit
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 cuberevo cuberevo_mini2 cuberevo_2000hd))
	install -m 644 $(SKEL_ROOT)/etc/inittab_ttyAS1 $(TARGETPREFIX)/etc/inittab
else
	install -m 644 $(SKEL_ROOT)/etc/inittab $(TARGETPREFIX)/etc/inittab
endif
	$(REMOVE)/sysvinit-$(SYSVINIT_VER)
	$(TOUCH)

#
# host_module_init_tools
#
MODULE_INIT_TOOLS_VER = 3.15
MODULE_INIT_TOOLS_PATCH = module-init-tools-$(MODULE_INIT_TOOLS_VER).patch
MODULE_INIT_TOOLS_HOST_PATCH = module-init-tools-$(MODULE_INIT_TOOLS_VER).patch

$(ARCHIVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz:
	$(WGET) https://www.kernel.org/pub/linux/utils/kernel/module-init-tools/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz

$(D)/host_module_init_tools: $(ARCHIVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(UNTAR)/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/module-init-tools-$(MODULE_INIT_TOOLS_VER); \
		$(call post_patch,$(MODULE_INIT_TOOLS_HOST_PATCH)); \
		autoreconf -fi; \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOSTPREFIX) \
			--sbindir=$(HOSTPREFIX)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# module_init_tools
#
$(D)/module_init_tools: $(D)/bootstrap $(D)/lsb $(ARCHIVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(UNTAR)/module-init-tools-$(MODULE_INIT_TOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/module-init-tools-$(MODULE_INIT_TOOLS_VER); \
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
		$(MAKE) install sbin_PROGRAMS="depmod modinfo" bin_PROGRAMS= DESTDIR=$(TARGETPREFIX)
	$(call adapted-etc-files,$(MODULE_INIT_TOOLS_ADAPTED_ETC_FILES))
	$(REMOVE)/module-init-tools-$(MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# lsb
#
LSB_MAJOR = 3.2
LSB_MINOR = 20
LSB_VER = $(LSB_MAJOR)-$(LSB_MINOR)

$(ARCHIVE)/lsb_$(LSB_VER)$(LSB_SUBVER).tar.gz:
	$(WGET) http://debian.sdinet.de/etch/sdinet/lsb/lsb_$(LSB_VER).tar.gz

$(D)/lsb: $(D)/bootstrap $(ARCHIVE)/lsb_$(LSB_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(UNTAR)/lsb_$(LSB_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lsb-$(LSB_MAJOR); \
		install -m 0644 init-functions $(TARGETPREFIX)/lib/lsb
	$(REMOVE)/lsb-$(LSB_MAJOR)
	$(TOUCH)

#
# portmap
#
PORTMAP_VER = 6.0.0
PORTMAP_PATCH = portmap-$(PORTMAP_VER).patch

$(ARCHIVE)/portmap_$(PORTMAP_VER).orig.tar.gz:
	$(WGET) https://merges.ubuntu.com/p/portmap/portmap_$(PORTMAP_VER).orig.tar.gz

$(ARCHIVE)/portmap_$(PORTMAP_VER)-2.diff.gz:
	$(WGET) https://merges.ubuntu.com/p/portmap/portmap_$(PORTMAP_VER)-2.diff.gz

$(D)/portmap: $(D)/bootstrap $(ARCHIVE)/portmap_$(PORTMAP_VER).orig.tar.gz $(ARCHIVE)/portmap_$(PORTMAP_VER)-2.diff.gz
	$(START_BUILD)
	$(REMOVE)/portmap-$(PORTMAP_VER)
	$(UNTAR)/portmap_$(PORTMAP_VER).orig.tar.gz
	set -e; cd $(BUILD_TMP)/portmap-$(PORTMAP_VER); \
		gunzip -cd $(lastword $^) | cat > debian.patch; \
		patch -p1 <debian.patch && \
		sed -e 's/### BEGIN INIT INFO/# chkconfig: S 41 10\n### BEGIN INIT INFO/g' -i debian/init.d; \
		$(call post_patch,$(PORTMAP_PATCH)); \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc"; \
		install -m 0755 portmap $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_dump $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_set $(TARGETPREFIX)/sbin; \
		install -m755 debian/init.d $(TARGETPREFIX)/etc/init.d/portmap
	$(REMOVE)/portmap-$(PORTMAP_VER)
	$(TOUCH)

#
# e2fsprogs
#
E2FSPROGS_VER = 1.42.13
E2FSPROGS_PATCH = e2fsprogs-$(E2FSPROGS_VER).patch

$(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz

$(D)/e2fsprogs: $(D)/bootstrap $(D)/utillinux $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER); \
		$(call post_patch,$(E2FSPROGS_PATCH)); \
		PATH=$(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER):$(PATH) \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
		$(MAKE) -C lib/uuid  install DESTDIR=$(TARGETPREFIX); \
		$(MAKE) -C lib/blkid install DESTDIR=$(TARGETPREFIX); \
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	cd $(TARGETPREFIX) && rm sbin/badblocks sbin/dumpe2fs sbin/logsave \
				 sbin/e2undo usr/sbin/filefrag usr/sbin/e2freefrag \
				 usr/bin/chattr usr/bin/lsattr usr/bin/uuidgen
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	$(TOUCH)

#
# dosfstools
#
DOSFSTOOLS_VER = 4.0

$(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz:
	$(WGET) https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)/dosfstools-$(DOSFSTOOLS_VER).tar.xz

$(D)/dosfstools: bootstrap $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(UNTAR)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(TOUCH)

#
# jfsutils
#
JFSUTILS_VER = 1.1.15
JFSUTILS_PATCH = jfsutils-$(JFSUTILS_VER).patch

$(ARCHIVE)/jfsutils-$(JFSUTILS_VER).tar.gz:
	$(WGET) http://jfs.sourceforge.net/project/pub/jfsutils-$(JFSUTILS_VER).tar.gz

$(D)/jfsutils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/jfsutils-$(JFSUTILS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/jfsutils-$(JFSUTILS_VER)
	$(UNTAR)/jfsutils-$(JFSUTILS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/jfsutils-$(JFSUTILS_VER); \
		$(call post_patch,$(JFSUTILS_PATCH)); \
		sed "s@<unistd.h>@&\n#include <sys/types.h>@g" -i fscklog/extract.c; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	cd $(TARGETPREFIX) && rm sbin/jfs_debugfs sbin/jfs_fscklog sbin/jfs_logdump
	$(REMOVE)/jfsutils-$(JFSUTILS_VER)
	$(TOUCH)

#
# utillinux
#
UTIL_LINUX_MAJOR = 2.25
UTIL_LINUX_MINOR = 2
UTIL_LINUX_VER = $(UTIL_LINUX_MAJOR).$(UTIL_LINUX_MINOR)

$(ARCHIVE)/util-linux-$(UTIL_LINUX_VER).tar.xz:
	$(WGET) http://ftp.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_MAJOR)/util-linux-$(UTIL_LINUX_VER).tar.xz

$(D)/utillinux: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/util-linux-$(UTIL_LINUX_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/util-linux-$(UTIL_LINUX_VER)
	$(UNTAR)/util-linux-$(UTIL_LINUX_VER).tar.xz
	set -e; cd $(BUILD_TMP)/util-linux-$(UTIL_LINUX_VER); \
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
		install -D -m 755 sfdisk $(TARGETPREFIX)/sbin/sfdisk; \
		install -D -m 755 mkfs $(TARGETPREFIX)/sbin/mkfs
	$(REMOVE)/util-linux-$(UTIL_LINUX_VER)
	$(TOUCH)

#
# mc
#
MC_VER = 4.8.14

$(ARCHIVE)/mc-$(MC_VER).tar.xz:
	$(WGET) http://ftp.midnight-commander.org/mc-$(MC_VER).tar.xz

$(D)/mc: $(D)/bootstrap $(D)/libncurses $(D)/glib2 $(ARCHIVE)/mc-$(MC_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/mc-$(MC_VER)
	$(UNTAR)/mc-$(MC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/mc-$(MC_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/mc-$(MC_VER)
	$(TOUCH)

#
# nano
#
NANO_VER = 2.2.6

$(ARCHIVE)/nano-$(NANO_VER).tar.gz:
	$(WGET) http://www.nano-editor.org/dist/v2.2/nano-$(NANO_VER).tar.gz

$(D)/nano: $(D)/bootstrap $(ARCHIVE)/nano-$(NANO_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/nano-$(NANO_VER)
	$(UNTAR)/nano-$(NANO_VER).tar.gz
	set -e; cd $(BUILD_TMP)/nano-$(NANO_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--disable-nls \
			--enable-tiny \
			--enable-color \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/nano-$(NANO_VER)
	$(TOUCH)

#
# rsync
#
RSYNC_VER = 3.1.1

$(ARCHIVE)/rsync-$(RSYNC_VER).tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-$(RSYNC_VER).tar.gz

$(D)/rsync: $(D)/bootstrap $(ARCHIVE)/rsync-$(RSYNC_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(UNTAR)/rsync-$(RSYNC_VER).tar.gz
	set -e; cd $(BUILD_TMP)/rsync-$(RSYNC_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--disable-debug \
			--disable-locale \
		; \
		$(MAKE) all; \
		$(MAKE) install-all DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(TOUCH)

#
# fuse
#
FUSE_VER = 2.9.7

$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(WGET) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

$(D)/fuse: $(D)/bootstrap $(ARCHIVE)/fuse-$(FUSE_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/fuse-$(FUSE_VER)
	$(UNTAR)/fuse-$(FUSE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/fuse-$(FUSE_VER); \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		-rm $(TARGETPREFIX)/etc/udev/rules.d/99-fuse.rules
		-rmdir $(TARGETPREFIX)/etc/udev/rules.d
		-rmdir $(TARGETPREFIX)/etc/udev
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REMOVE)/fuse-$(FUSE_VER)
	$(TOUCH)

#
# curlftpfs
#
CURLFTPFS_VER = 0.9.2
CURLFTPFS_PATCH = curlftpfs-$(CURLFTPFS_VER).patch

$(ARCHIVE)/curlftpfs-$(CURLFTPFS_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/curlftpfs/files/latest/download/curlftpfs-$(CURLFTPFS_VER).tar.gz

$(D)/curlftpfs: $(D)/bootstrap $(D)/libcurl $(D)/fuse $(D)/glib2 $(ARCHIVE)/curlftpfs-$(CURLFTPFS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VER)
	$(UNTAR)/curlftpfs-$(CURLFTPFS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/curlftpfs-$(CURLFTPFS_VER); \
		$(call post_patch,$(CURLFTPFS_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes && \
		export ac_cv_func_realloc_0_nonnull=yes && \
		$(CONFIGURE) \
			CFLAGS="$(TARGET_CFLAGS) -I$(KERNEL_DIR)/arch/sh" \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/curlftpfs-$(CURLFTPFS_VER)
	$(TOUCH)

#
# sdparm
#
SDPARM_VER = 1.09

$(ARCHIVE)/sdparm-$(SDPARM_VER).tgz:
	$(WGET) http://sg.danny.cz/sg/p/sdparm-$(SDPARM_VER).tgz

$(D)/sdparm: $(D)/bootstrap $(ARCHIVE)/sdparm-$(SDPARM_VER).tgz
	$(START_BUILD)
	$(REMOVE)/sdparm-$(SDPARM_VER)
	$(UNTAR)/sdparm-$(SDPARM_VER).tgz
	set -e; cd $(BUILD_TMP)/sdparm-$(SDPARM_VER); \
		$(CONFIGURE) \
			--prefix= \
			--exec-prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/sdparm-$(SDPARM_VER)
	$(TOUCH)

#
# hddtemp
#
HDDTEMP_VER = 0.3-beta15

$(ARCHIVE)/hddtemp-$(HDDTEMP_VER).tar.bz2:
	$(WGET) http://savannah.c3sl.ufpr.br/hddtemp/hddtemp-$(HDDTEMP_VER).tar.bz2

$(D)/hddtemp: $(D)/bootstrap $(ARCHIVE)/hddtemp-$(HDDTEMP_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/hddtemp-$(HDPARM_VER)
	$(UNTAR)/hddtemp-$(HDPARM_VER).tar.gz
	set -e; cd $(BUILD_TMP)/hddtemp-$(HDPARM_VER); \
		$(CONFIGURE) \
			--prefix= \
			--with-db_path=/var/hddtemp.db \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		install -d $(TARGETPREFIX)/var/tuxbox/config
		install -m 644 $(SKEL_ROOT)/release/hddtemp.db $(TARGETPREFIX)/var
	$(REMOVE)/hddtemp-$(HDPARM_VER)
	$(TOUCH)

#
# hdparm
#
HDPARM_VER = 9.50

$(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/hdparm/files/hdparm/hdparm-$(HDPARM_VER).tar.gz

$(D)/hdparm: $(D)/bootstrap $(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(UNTAR)/hdparm-$(HDPARM_VER).tar.gz
	set -e; cd $(BUILD_TMP)/hdparm-$(HDPARM_VER); \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/hdparm-$(HDPARM_VER)
	$(TOUCH)

#
# hd-idle
#
HDIDLE_VER = 1.05

$(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz:
	$(WGET) http://sourceforge.net/projects/hd-idle/files/hd-idle-$(HDIDLE_VER).tgz

$(D)/hd-idle: $(D)/bootstrap $(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz
	$(START_BUILD)
	$(REMOVE)/hd-idle
	$(UNTAR)/hd-idle-$(HDIDLE_VER).tgz
	set -e; cd $(BUILD_TMP)/hd-idle; \
		sed -i -e 's/-g root -o root//g' Makefile; \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install TARGET_DIR=$(TARGETPREFIX) install
	$(REMOVE)/hd-idle
	$(TOUCH)

#
# fbshot
#
FBSHOT_VER = 0.3
FBSHOT_PATCH = fbshot-$(FBSHOT_VER).patch

$(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz:
	$(WGET) http://www.sourcefiles.org/Graphics/Tools/Capture/fbshot-$(FBSHOT_VER).tar.gz

$(D)/fbshot: $(TARGETPREFIX)/bin/fbshot
	$(TOUCH)

$(TARGETPREFIX)/bin/fbshot: $(D)/bootstrap $(D)/libpng $(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(UNTAR)/fbshot-$(FBSHOT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/fbshot-$(FBSHOT_VER); \
		$(call post_patch,$(FBSHOT_PATCH)); \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	@touch $@

#
# parted
#
PARTED_VER = 3.2
PARTED_PATCH = parted-$(PARTED_VER)-device-mapper.patch

$(ARCHIVE)/parted-$(PARTED_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz

$(D)/parted: $(D)/bootstrap $(D)/libncurses $(D)/libreadline $(D)/e2fsprogs $(ARCHIVE)/parted-$(PARTED_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/parted-$(PARTED_VER)
	$(UNTAR)/parted-$(PARTED_VER).tar.xz
	set -e; cd $(BUILD_TMP)/parted-$(PARTED_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REMOVE)/parted-$(PARTED_VER)
	$(TOUCH)

#
# sysstat
#
SYSSTAT_VER = 11.3.5

$(ARCHIVE)/sysstat-$(SYSSTAT_VER).tar.bz2:
	$(WGET) http://pagesperso-orange.fr/sebastien.godard/sysstat-$(SYSSTAT_VER).tar.bz2

$(D)/sysstat: $(D)/bootstrap $(ARCHIVE)/sysstat-$(SYSSTAT_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/sysstat-$(SYSSTAT_VER)
	$(UNTAR)/sysstat-$(SYSSTAT_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/sysstat-$(SYSSTAT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/sysstat-$(SYSSTAT_VER)
	$(TOUCH)

#
# autofs
#
AUTOFS_VER = 4.1.4
AUTOFS_PATCH = autofs-$(AUTOFS_VER).patch

$(ARCHIVE)/autofs-$(AUTOFS_VER).tar.gz:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-$(AUTOFS_VER).tar.gz

$(D)/autofs: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/autofs-$(AUTOFS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/autofs-$(AUTOFS_VER)
	$(UNTAR)/autofs-$(AUTOFS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/autofs-$(AUTOFS_VER); \
		$(call post_patch,$(AUTOFS_PATCH)); \
		cp aclocal.m4 acinclude.m4; \
		autoconf; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all CC=$(TARGET)-gcc STRIP=$(TARGET)-strip; \
		$(MAKE) install INSTALLROOT=$(TARGETPREFIX) SUBDIRS="lib daemon modules"
	install -m 755 $(SKEL_ROOT)/etc/init.d/autofs $(TARGETPREFIX)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/auto.hotplug $(TARGETPREFIX)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.master $(TARGETPREFIX)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.misc $(TARGETPREFIX)/etc/
	install -m 644 $(SKEL_ROOT)/etc/auto.network $(TARGETPREFIX)/etc/
	$(REMOVE)/autofs-$(AUTOFS_VER)
	$(TOUCH)

#
# imagemagick
#
IMAGEMAGICK_VER = 6.7.7-7

$(ARCHIVE)/ImageMagick-$(IMAGEMAGICK_VER).tar.gz:
	$(WGET) ftp://ftp.fifi.org/pub/ImageMagick/ImageMagick-$(IMAGEMAGICK_VER).tar.gz

$(D)/imagemagick: $(D)/bootstrap $(ARCHIVE)/ImageMagick-$(IMAGEMAGICK_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/ImageMagick-$(IMAGEMAGICK_VER)
	$(UNTAR)/ImageMagick-$(IMAGEMAGICK_VER).tar.gz
	set -e; cd $(BUILD_TMP)/ImageMagick-$(IMAGEMAGICK_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ImageMagick.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/MagickCore.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/MagickWand.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/Wand.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ImageMagick++.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/Magick++.pc
	$(REWRITE_LIBTOOL)/libMagickCore.la
	$(REWRITE_LIBTOOL)/libMagickWand.la
	$(REWRITE_LIBTOOL)/libMagick++.la
	$(REMOVE)/ImageMagick-$(IMAGEMAGICK_VER)
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
		$(MAKE) install PREFIX=$(TARGETPREFIX)/usr
	$(REMOVE)/shairport
	$(TOUCH)

#
# dbus
#
DBUS_VER = 1.8.0

$(ARCHIVE)/dbus-$(DBUS_VER).tar.gz:
	$(WGET) http://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS_VER).tar.gz

$(D)/dbus: $(D)/bootstrap $(D)/libexpat $(ARCHIVE)/dbus-$(DBUS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/dbus-$(DBUS_VER)
	$(UNTAR)/dbus-$(DBUS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/dbus-$(DBUS_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dbus-1.pc
	$(REWRITE_LIBTOOL)/libdbus-1.la
	$(REMOVE)/dbus-$(DBUS_VER)
	$(TOUCH)

#
# avahi
#
AVAHI_VER = 0.6.31

$(ARCHIVE)/avahi-$(AVAHI_VER).tar.gz:
	$(WGET) http://www.avahi.org/download/avahi-$(AVAHI_VER).tar.gz

$(D)/avahi: $(D)/bootstrap $(D)/libexpat $(D)/libdaemon $(D)/dbus $(ARCHIVE)/avahi-$(AVAHI_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/avahi-$(AVAHI_VER)
	$(UNTAR)/avahi-$(AVAHI_VER).tar.gz
	set -e; cd $(BUILD_TMP)/avahi-$(AVAHI_VER); \
		sed -i 's/\(CFLAGS=.*\)-Werror \(.*\)/\1\2/' configure; \
		sed -i -e 's/-DG_DISABLE_DEPRECATED=1//' -e '/-DGDK_DISABLE_DEPRECATED/d' avahi-ui/Makefile.in; \
		$(CONFIGURE) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--disable-static \
			--disable-mono \
			--disable-monodoc \
			--disable-python \
			--disable-gdbm \
			--disable-gtk \
			--disable-gtk3 \
			--disable-qt3 \
			--disable-qt4 \
			--disable-nls \
			--enable-core-docs \
			--with-distro=none \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/avahi-$(AVAHI_VER)
	$(TOUCH)

#
# wget
#
WGET_VER = 1.18

$(ARCHIVE)/wget-$(WGET_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/wget/wget-$(WGET_VER).tar.xz

$(D)/wget: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/wget-$(WGET_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/wget-$(WGET_VER)
	$(UNTAR)/wget-$(WGET_VER).tar.xz
	set -e; cd $(BUILD_TMP)/wget-$(WGET_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--with-openssl \
			--with-ssl=openssl \
			--with-libssl-prefix=$(TARGETPREFIX) \
			--disable-ipv6 \
			--disable-debug \
			--disable-nls \
			--disable-opie \
			--disable-digest \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/wget-$(WGET_VER)
	$(TOUCH)

#
# coreutils
#
COREUTILS_VER = 8.23
COREUTILS_PATCH = coreutils-$(COREUTILS_VER).patch

$(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VER).tar.xz

$(D)/coreutils: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(UNTAR)/coreutils-$(COREUTILS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/coreutils-$(COREUTILS_VER); \
		$(call post_patch,$(COREUTILS_PATCH)); \
		export fu_cv_sys_stat_statfs2_bsize=yes; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-largefile \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	$(TOUCH)

#
# smartmontools
#
SMARTMONTOOLS_VER = 6.4

$(ARCHIVE)/smartmontools-$(SMARTMONTOOLS_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)/smartmontools-$(SMARTMONTOOLS_VER).tar.gz

$(D)/smartmontools: $(D)/bootstrap $(ARCHIVE)/smartmontools-$(SMARTMONTOOLS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VER)
	$(UNTAR)/smartmontools-$(SMARTMONTOOLS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/smartmontools-$(SMARTMONTOOLS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGETPREFIX)/usr
	$(REMOVE)/smartmontools-$(SMARTMONTOOLS_VER)
	$(TOUCH)

#
# nfs_utils
#
NFSUTILS_VER = 1.3.3
NFSUTILS_PATCH = nfs-utils-$(NFSUTILS_VER).patch

$(ARCHIVE)/nfs-utils-$(NFSUTILS_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/nfs/files/nfs-utils/$(NFSUTILS_VER)/nfs-utils-$(NFSUTILS_VER).tar.bz2

$(D)/nfs_utils: $(D)/bootstrap $(D)/e2fsprogs $(ARCHIVE)/nfs-utils-$(NFSUTILS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/nfs-utils-$(NFSUTILS_VER)
	$(UNTAR)/nfs-utils-$(NFSUTILS_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/nfs-utils-$(NFSUTILS_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -m 755 $(SKEL_ROOT)/etc/init.d/nfs-common $(TARGETPREFIX)/etc/init.d/
	install -m 755 $(SKEL_ROOT)/etc/init.d/nfs-kernel-server $(TARGETPREFIX)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/exports $(TARGETPREFIX)/etc/
	cd $(TARGETPREFIX) && rm -f sbin/mount.nfs sbin/mount.nfs4 sbin/umount.nfs sbin/umount.nfs4 \
				 sbin/osd_login
	$(REMOVE)/nfs-utils-$(NFSUTILS_VER)
	$(TOUCH)

#
# libevent
#
LIBEVENT_VER = 2.0.21-stable

$(ARCHIVE)/libevent-$(LIBEVENT_VER).tar.gz:
	$(WGET) https://github.com/downloads/libevent/libevent/libevent-$(LIBEVENT_VER).tar.gz

$(D)/libevent: $(D)/bootstrap $(ARCHIVE)/libevent-$(LIBEVENT_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/libevent-$(LIBEVENT_VER)
	$(UNTAR)/libevent-$(LIBEVENT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libevent-$(LIBEVENT_VER);\
		$(CONFIGURE) \
			--prefix=$(TARGETPREFIX)/usr \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libevent-$(LIBEVENT_VER)
	$(TOUCH)

#
# libnfsidmap
#
LIBNFSIDMAP_VER = 0.25

$(ARCHIVE)/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz:
	$(WGET) http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz

$(D)/libnfsidmap: $(D)/bootstrap $(ARCHIVE)/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VER)
	$(UNTAR)/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libnfsidmap-$(LIBNFSIDMAP_VER);\
		$(CONFIGURE) \
		ac_cv_func_malloc_0_nonnull=yes \
			--prefix=$(TARGETPREFIX)/usr \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VER)
	$(TOUCH)

#
# vsftpd
#
VSFTPD_VER = 3.0.3
VSFTPD_PATCH = vsftpd-$(VSFTPD_VER).patch

$(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz:
	$(WGET) https://security.appspot.com/downloads/vsftpd-$(VSFTPD_VER).tar.gz

$(D)/vsftpd: $(D)/bootstrap $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	set -e; cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VER); \
		$(call post_patch,$(VSFTPD_PATCH)); \
		$(MAKE) clean; \
		$(MAKE) $(BUILDENV); \
		$(MAKE) install PREFIX=$(TARGETPREFIX)
	install -m 755 $(SKEL_ROOT)/etc/init.d/vsftpd $(TARGETPREFIX)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/vsftpd.conf $(TARGETPREFIX)/etc/
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	$(TOUCH)

#
# ethtool
#
ETHTOOL_VER = 6

$(ARCHIVE)/ethtool-$(ETHTOOL_VER).tar.gz:
	$(WGET) http://downloads.openwrt.org/sources/ethtool-$(ETHTOOL_VER).tar.gz

$(D)/ethtool: $(D)/bootstrap $(ARCHIVE)/ethtool-$(ETHTOOL_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(UNTAR)/ethtool-$(ETHTOOL_VER).tar.gz
	set -e; cd $(BUILD_TMP)/ethtool-$(ETHTOOL_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--libdir=$(TARGETPREFIX)/usr/lib \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(TOUCH)

#
# samba
#
SAMBA_VER = 3.6.25
SAMBA_PATCH = samba-$(SAMBA_VER).patch

$(ARCHIVE)/samba-$(SAMBA_VER).tar.gz:
	$(WGET) http://ftp.samba.org/pub/samba/stable/samba-$(SAMBA_VER).tar.gz

$(D)/samba: $(D)/bootstrap $(ARCHIVE)/samba-$(SAMBA_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/samba-$(SAMBA_VER)
	$(UNTAR)/samba-$(SAMBA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA_VER); \
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
			SBIN_PROGS="bin/smbd bin/nmbd bin/winbindd" DESTDIR=$(TARGETPREFIX) prefix=./. ; \
	install -m 755 $(SKEL_ROOT)/etc/init.d/samba $(TARGETPREFIX)/etc/init.d/
	install -m 644 $(SKEL_ROOT)/etc/smb.conf $(TARGETPREFIX)/etc/samba/
	$(REMOVE)/samba-$(SAMBA_VER)
	$(TOUCH)

#
# ntp
#
NTP_VER = 4.2.8p3
NTP_PATCH = ntp-$(NTP_VER).patch

$(ARCHIVE)/ntp-$(NTP_VER).tar.gz:
	$(WGET) http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-$(NTP_VER).tar.gz

$(D)/ntp: $(D)/bootstrap $(ARCHIVE)/ntp-$(NTP_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/ntp-$(NTP_VER)
	$(UNTAR)/ntp-$(NTP_VER).tar.gz
	set -e; cd $(BUILD_TMP)/ntp-$(NTP_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/ntp-$(NTP_VER)
	$(TOUCH)

#
# wireless_tools
#
WIRELESSTOOLS_VER = 29
WIRELESSTOOLS_PATCH = wireless-tools.$(WIRELESSTOOLS_VER).patch

$(ARCHIVE)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz:
	$(WGET) http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz

$(D)/wireless_tools: $(D)/bootstrap $(ARCHIVE)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/wireless_tools.$(WIRELESSTOOLS_VER)
	$(UNTAR)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/wireless_tools.$(WIRELESSTOOLS_VER); \
		$(call post_patch,$(WIRELESSTOOLS_PATCH)); \
		$(MAKE) CC="$(TARGET)-gcc" CFLAGS="$(TARGET_CFLAGS) -I."; \
		$(MAKE) install PREFIX=$(TARGETPREFIX)/usr INSTALL_MAN=$(TARGETPREFIX)/.remove
	$(REMOVE)/wireless_tools.$(WIRELESSTOOLS_VER)
	$(TOUCH)

#
# libnl
#
LIBNL_VER = 2.0

$(ARCHIVE)/libnl-$(LIBNL_VER).tar.gz:
	$(WGET) http://www.carisma.slowglass.com/~tgr/libnl/files/libnl-$(LIBNL_VER).tar.gz

$(D)/libnl: $(D)/bootstrap $(D)/openssl $(ARCHIVE)/libnl-$(LIBNL_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(UNTAR)/libnl-$(LIBNL_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libnl-$(LIBNL_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--mandir=/.remove \
			--infodir=/.remove \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/libnl-$(LIBNL_VER)
	$(TOUCH)

#
# wpa_supplicant
#
WPA_SUPPLICANT_VER = 0.7.3

$(ARCHIVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz:
	$(WGET) http://hostap.epitest.fi/releases/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz

$(D)/wpa_supplicant: $(D)/bootstrap $(D)/openssl $(D)/wireless_tools $(ARCHIVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	$(UNTAR)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant; \
		cp -f defconfig .config; \
		sed -i 's/#CONFIG_DRIVER_RALINK=y/CONFIG_DRIVER_RALINK=y/' .config; \
		sed -i 's/#CONFIG_IEEE80211W=y/CONFIG_IEEE80211W=y/' .config; \
		sed -i 's/#CONFIG_OS=unix/CONFIG_OS=unix/' .config; \
		sed -i 's/#CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config; \
		sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/' .config; \
		sed -i 's/#CONFIG_INTERWORKING=y/CONFIG_INTERWORKING=y/' .config; \
		export CFLAGS="-pipe -Os -Wall -g0 -I$(TARGETPREFIX)/usr/include"; \
		export CPPFLAGS="-I$(TARGETPREFIX)/usr/include"; \
		export LIBS="-L$(TARGETPREFIX)/usr/lib -Wl,-rpath-link,$(TARGETPREFIX)/usr/lib"; \
		export LDFLAGS="-L$(TARGETPREFIX)/usr/lib"; \
		export DESTDIR=$(TARGETPREFIX); \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install BINDIR=/usr/sbin DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	$(TOUCH)

#
# dvbsnoop
#
$(D)/dvbsnoop: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/dvbsnoop
	set -e; if [ -d $(ARCHIVE)/dvbsnoop.git ]; \
		then cd $(ARCHIVE)/dvbsnoop.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/cotdp/dvbsnoop.git dvbsnoop.git; \
		fi
	cp -ra $(ARCHIVE)/dvbsnoop.git $(BUILD_TMP)/dvbsnoop
	set -e; cd $(BUILD_TMP)/dvbsnoop; \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/dvbsnoop
	$(TOUCH)

#
# udpxy
#
UDPXY_VER = 1.0.23-9
UDPXY_PATCH = udpxy-$(UDPXY_VER).patch

$(ARCHIVE)/udpxy.$(UDPXY_VER)-prod.tar.gz:
	$(WGET) http://www.udpxy.com/download/1_23/udpxy.$(UDPXY_VER)-prod.tar.gz

$(D)/udpxy: $(D)/bootstrap $(ARCHIVE)/udpxy.$(UDPXY_VER)-prod.tar.gz
	$(START_BUILD)
	$(REMOVE)/udpxy-$(UDPXY_VER)
	$(UNTAR)/udpxy.$(UDPXY_VER)-prod.tar.gz
	set -e; cd $(BUILD_TMP)/udpxy-$(UDPXY_VER); \
		$(call post_patch,$(UDPXY_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc CCKIND=gcc; \
		$(MAKE) install INSTALLROOT=$(TARGETPREFIX)/usr MANPAGE_DIR=$(TARGETPREFIX)/.remove
	$(REMOVE)/udpxy-$(UDPXY_VER)
	$(TOUCH)

#
# openvpn
#
OPENVPN_VER = 2.3.14

$(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz:
	$(WGET) http://swupdate.openvpn.org/community/releases/openvpn-$(OPENVPN_VER).tar.xz

$(D)/openvpn: $(D)/bootstrap $(D)/openssl $(D)/lzo $(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(UNTAR)/openvpn-$(OPENVPN_VER).tar.xz
	set -e; cd $(BUILD_TMP)/openvpn-$(OPENVPN_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -m 755 $(SKEL_ROOT)/etc/init.d/openvpn $(TARGETPREFIX)/etc/init.d/
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	$(TOUCH)

#
# openssh
#
OPENSSH_VER = 7.2p2

$(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz:
	$(WGET) http://artfiles.org/openbsd/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz

$(D)/openssh: $(D)/bootstrap $(D)/zlib $(D)/openssl $(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(UNTAR)/openssh-$(OPENSSH_VER).tar.gz
	set -e; cd $(BUILD_TMP)/openssh-$(OPENSSH_VER); \
		CC=$(TARGET)-gcc; \
		./configure $(CONFIGURE_SILENT) \
			$(CONFIGURE_OPTS) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc/ssh \
			--libexecdir=/sbin \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe -Os -I$(TARGETPREFIX)/usr/include" \
			--with-ldflags=-"L$(TARGETPREFIX)/usr/lib" \
		; \
		$(MAKE); \
		$(MAKE) install-nokeys DESTDIR=$(TARGETPREFIX)
	install -m 755 $(BUILD_TMP)/openssh-$(OPENSSH_VER)/opensshd.init $(TARGETPREFIX)/etc/init.d/openssh
	sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' $(TARGETPREFIX)/etc/ssh/sshd_config
	$(REMOVE)/openssh-$(OPENSSH_VER)
	$(TOUCH)

#
# usb-modeswitch-data
#
USB_MODESWITCH_DATA_VER = 20160112
USB_MODESWITCH_DATA_PATCH = usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).patch

$(ARCHIVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2:
	$(WGET) http://www.draisberghof.de/usb_modeswitch/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2

$(D)/usb-modeswitch-data: $(D)/bootstrap $(ARCHIVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER)
	$(UNTAR)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER); \
		$(call post_patch,$(USB_MODESWITCH_DATA_PATCH)); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER)
	$(TOUCH)

#
# usb-modeswitch
#
USB_MODESWITCH_VER = 2.3.0
USB_MODESWITCH_PATCH = usb-modeswitch-$(USB_MODESWITCH_VER).patch

$(ARCHIVE)/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2:
	$(WGET) http://www.draisberghof.de/usb_modeswitch/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2

$(D)/usb-modeswitch: $(D)/bootstrap $(D)/libusb $(D)/usb-modeswitch-data $(ARCHIVE)/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VER)
	$(UNTAR)/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/usb-modeswitch-$(USB_MODESWITCH_VER); \
		$(call post_patch,$(USB_MODESWITCH_PATCH)); \
		sed -i -e "s/= gcc/= $(TARGET)-gcc/" -e "s/-l usb/-lusb -lusb-1.0 -lpthread -lrt/" -e "s/install -D -s/install -D --strip-program=$(TARGET)-strip -s/" Makefile; \
		sed -i -e "s/@CC@/$(TARGET)-gcc/g" jim/Makefile.in; \
		$(BUILDENV) $(MAKE) DESTDIR=$(TARGETPREFIX)  install-static; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VER)
	$(TOUCH)
