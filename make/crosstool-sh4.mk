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
#BINUTILS_VER = 2.22-64
#GCC_VER      = 4.6.3-111
#LIBGCC_VER   = 4.6.3-111
#GLIBC_VER    = 2.10.2-42

# 4.8.4
BINUTILS_VER = 2.24.51.0.3-76
GCC_VER      = 4.8.4-139
LIBGCC_VER   = 4.8.4-148
GLIBC_VER    = 2.14.1-59

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VER).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	touch $(D)/$(notdir $@)

crosstool: directories driver-symlink \
$(HOST_DIR)/bin/unpack-rpm.sh \
crosstool-rpminstall
	set -e; cd $(CROSS_DIR); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGET_DIR)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGET_DIR)/usr/lib; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc.so $(TARGET_DIR)/usr/lib/libc.so; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGET_DIR)/usr/lib/libc_nonshared.a; \
	fi
	if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGET_DIR)/lib; \
	fi
	if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGET_DIR)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGET_DIR)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGET_DIR)/etc; \
	fi
	@touch $(D)/$(notdir $@)

#
# host_u_boot_tools
#
HOST_U_BOOT_TOOLS_VER = 1.3.1_stm24-9

host_u_boot_tools: \
$(STL_ARCHIVE)/stlinux24-host-u-boot-tools-$(HOST_U_BOOT_TOOLS_VER).i386.rpm
	$(START_BUILD)
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOST_DIR)/bin \
		$^
	@touch $(D)/$(notdir $@)
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(PKG_VER) $(TERM_NORMAL)completed."; echo

#
# crosstool-ng
#
CROSSTOOL_NG_VER = 1.22.0
CROSSTOOL_NG_SOURCE = crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz

$(ARCHIVE)/$(CROSSTOOL_NG_SOURCE):
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/$(CROSSTOOL_NG_SOURCE)

crosstool-ng: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi;
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export NG_ARCHIVE=$(ARCHIVE); \
		export NG_BASE_DIR=$(CROSS_BASE); \
		export LD_LIBRARY_PATH= ; \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng oldconfig; \
		./ct-ng build
	chmod -R +w $(CROSS_BASE)
	test -e $(CROSS_BASE)/sh4-unknown-linux-gnu/lib || ln -sf sys-root/lib $(CROSS_BASE)/sh4-unknown-linux-gnu/
	rm -f $(CROSS_BASE)/sh4-unknown-linux-gnu/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

crossmenuconfig: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig

