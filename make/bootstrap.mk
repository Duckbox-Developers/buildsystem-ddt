TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config
TOOLCHECK += find-cmake find-gperf

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK) preqs
	@echo "All required tools seem to be installed."
	@echo
	@for i in audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111; do \
		if [ ! -e $(SKEL_ROOT)/boot/$$i.elf ]; then \
			echo -e "\n    ERROR: One or more .elf files are missing in $(SKEL_ROOT)/boot!"; \
			echo "           $$i.elf is one of them"; \
			echo; \
			echo "    Correct this and retry."; \
			echo; \
		fi; \
	done
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

BOOTSTRAP  = directories crosstool $(D)/ccache
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-chksvn.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-gitdescribe.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-find-requires.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-find-provides.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-module-deps.sh
BOOTSTRAP += $(D)/host_pkgconfig $(D)/host_module_init_tools $(D)/host_mtd_utils

$(D)/bootstrap: $(BOOTSTRAP)
	touch $@

SYSTEM_TOOLS  = $(D)/module_init_tools
SYSTEM_TOOLS += $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/hd-idle
SYSTEM_TOOLS += $(D)/fbshot
SYSTEM_TOOLS += $(D)/portmap
SYSTEM_TOOLS += $(D)/nfs_utils
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	$(TOUCH)

$(HOSTPREFIX)/bin/opkg%sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOSTPREFIX)/bin

$(HOSTPREFIX)/bin/unpack-rpm.sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOSTPREFIX)/bin

#
STM_RELOCATE     = /opt/STM/STLinux-2.4

# updates / downloads
STL_FTP          = http://archive.stlinux.com/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host
STL_ARCHIVE      = $(ARCHIVE)/stlinux
STL_GET          = $(WGET)/stlinux

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(STL_ARCHIVE)/stlinux24-host-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_HOST)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-host-%.src.rpm:
	$(STL_GET) $(STL_FTP_UPD_SRC)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(STL_ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_SH4)/$(subst $(STL_ARCHIVE)/,"",$@)

#
# install the RPMs
#

# 4.6.3
#BINUTILS_VERSION = 2.22-64
#GCC_VERSION      = 4.6.3-111
#LIBGCC_VERSION   = 4.6.3-111
#GLIBC_VERSION    = 2.10.2-42

# 4.8.4
BINUTILS_VERSION = 2.24.51.0.3-76
GCC_VERSION      = 4.8.4-139
LIBGCC_VERSION   = 4.8.4-148
GLIBC_VERSION    = 2.14.1-59

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VERSION).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VERSION).sh4.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	touch $(D)/$(notdir $@)

crosstool: directories driver-symlink \
$(HOSTPREFIX)/bin/unpack-rpm.sh \
crosstool-rpminstall
	set -e; cd $(CROSS_BASE); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGETPREFIX)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGETPREFIX)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGETPREFIX)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGETPREFIX)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGETPREFIX)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGETPREFIX)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGETPREFIX)/usr/lib; \
		ln -s $(CROSS_DIR)/target/usr/lib/libc.so $(TARGETPREFIX)/usr/lib/libc.so; \
		ln -s $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGETPREFIX)/usr/lib/libc_nonshared.a; \
	fi
	if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGETPREFIX)/lib; \
	fi
	if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGETPREFIX)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGETPREFIX)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGETPREFIX)/etc; \
	fi
	touch $(D)/$(notdir $@)

#
# host_u_boot_tools
#
host_u_boot_tools: \
$(STL_ARCHIVE)/stlinux24-host-u-boot-tools-1.3.1_stm24-9.i386.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOSTPREFIX)/bin \
		$^
	touch $(D)/$(notdir $@)

#
# crosstool-ng
#
CROSSTOOL_NG_VERSION = 1.22.0

$(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz:
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz

crosstool-ng: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz
	make $(BUILD_TMP)
	if [ ! -e $(BASE_DIR)/cross ]; then \
		mkdir -p $(BASE_DIR)/cross; \
	fi;
	$(REMOVE)/crosstool-ng
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export NG_ARCHIVE=$(ARCHIVE); \
		export BS_BASE_DIR=$(BASE_DIR); \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng oldconfig; \
		./ct-ng build

crossmenuconfig: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VERSION)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng menuconfig

PREQS  = $(DRIVER_DIR)
PREQS += $(APPS_DIR)
PREQS += $(FLASH_DIR)

preqs: $(PREQS)

$(DRIVER_DIR):
	@echo '=============================================================='
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repo              '
	@echo '=============================================================='
	if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi

$(APPS_DIR):
	@echo '=============================================================='
	@echo '      Cloning $(GIT_NAME_APPS)-apps git repo                  '
	@echo '=============================================================='
	if [ ! -e $(APPS_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_APPS)/apps.git apps; \
	fi

$(FLASH_DIR):
	@echo '=============================================================='
	@echo '      Cloning $(GIT_NAME_FLASH)-flash git repo                '
	@echo '=============================================================='
	if [ ! -e $(FLASH_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_FLASH)/flash-bs.git flash; \
	fi
	@echo ''

#
# directories
#
directories:
	test -d $(D) || mkdir $(D)
	test -d $(ARCHIVE) || mkdir $(ARCHIVE)
	test -d $(STL_ARCHIVE) || mkdir $(STL_ARCHIVE)
	test -d $(BUILD_TMP) || mkdir $(BUILD_TMP)
	test -d $(SOURCE_DIR) || mkdir $(SOURCE_DIR)
	install -d $(TARGETPREFIX)
	install -d $(CROSS_DIR)
	install -d $(BOOT_DIR)
	install -d $(HOSTPREFIX)
	install -d $(HOSTPREFIX)/{bin,lib,share}
	install -d $(TARGETPREFIX)/{bin,boot,etc,lib,sbin,usr,var}
	install -d $(TARGETPREFIX)/etc/{init.d,mdev,network,rc.d}
	install -d $(TARGETPREFIX)/etc/rc.d/{rc0.d,rc6.d}
	ln -s ../init.d $(TARGETPREFIX)/etc/rc.d/init.d
	install -d $(TARGETPREFIX)/lib/{lsb,firmware}
	install -d $(TARGETPREFIX)/usr/{bin,lib,local,sbin,share}
	install -d $(TARGETPREFIX)/usr/lib/pkgconfig
	install -d $(TARGETPREFIX)/usr/include/linux
	install -d $(TARGETPREFIX)/usr/include/linux/dvb
	install -d $(TARGETPREFIX)/usr/local/{bin,sbin,share}
	install -d $(TARGETPREFIX)/var/{etc,lib,run}
	install -d $(TARGETPREFIX)/var/lib/{misc,nfs}
	install -d $(TARGETPREFIX)/var/bin
	touch $(D)/$(notdir $@)

#
# ccache
#
CCACHE_BINDIR = $(HOSTPREFIX)/bin
CCACHE_BIN = $(CCACHE)

CCACHE_LINKS = \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/cc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/g++; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-g++

CCACHE_ENV = install -d $(CCACHE_BINDIR); \
	$(CCACHE_LINKS)

$(D)/ccache:
	$(CCACHE_ENV)
	touch $@

# hack to make sure they are always copied
PHONY += ccache bootstrap

#
# YAUD NONE
#
yaud-none: \
	$(D)/bootstrap \
	$(D)/linux-kernel \
	$(D)/system-tools
	@touch $(D)/$(notdir $@)
