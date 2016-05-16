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

$(HOSTPREFIX)/bin/opkg%sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOSTPREFIX)/bin

$(HOSTPREFIX)/bin/unpack-rpm.sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOSTPREFIX)/bin

#
STM_RELOCATE = /opt/STM/STLinux-2.4

# updates / downloads
STL_FTP = http://ftp.stlinux.com/pub/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(ARCHIVE)/stlinux24-host-%.i386.rpm \
$(ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(WGET) $(STL_FTP_UPD_HOST)/$(subst $(ARCHIVE)/,"",$@)

$(ARCHIVE)/stlinux24-host-%.src.rpm:
	$(WGET) $(STL_FTP_UPD_SRC)/$(subst $(ARCHIVE)/,"",$@)

$(ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(WGET) $(STL_FTP_UPD_SH4)/$(subst $(ARCHIVE)/,"",$@)

ifeq ($(KERNEL), $(filter $(KERNEL), p0211 p0214 p0215 p0217))
STM_KERNEL_HEADERS_VER = 2.6.32.46-48
else
STM_KERNEL_HEADERS_VER = 2.6.32.46-47
endif

# 4.6.3
#BINUTILS_VER  = 2.22-64
#GCC_VER       = 4.6.3-111
#LIBGCC_VER    = 4.6.3-111
#GLIBC_VER     = 2.10.2-42

# 4.8.4
BINUTILS_VER  = 2.24.51.0.3-76
GCC_VER       = 4.8.4-139
LIBGCC_VER    = 4.8.4-148
GLIBC_VER     = 2.14.1-59

crosstool-rpminstall: \
$(ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VER).noarch.rpm \
$(ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	touch $(D)/$(notdir $@)

#
# crosstool-ng
#
CROSSTOOL_NG_VER = 1.22.0

$(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz:
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz

crosstool-ng: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	make $(BUILD_TMP)
	if [ ! -e $(BASE_DIR)/cross ]; then \
		mkdir -p $(BASE_DIR)/cross; \
	fi;
	$(REMOVE)/crosstool-ng
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER).config .config; \
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

crossmenuconfig: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng menuconfig

# install the RPMs
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
$(ARCHIVE)/stlinux24-host-u-boot-tools-1.3.1_stm24-9.i386.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOSTPREFIX)/bin \
		$^
	touch $(D)/$(notdir $@)

#
# directories
#
directories:
	test -d $(D) || mkdir $(D)
	test -d $(ARCHIVE) || mkdir $(ARCHIVE)
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

