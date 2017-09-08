# makefile to build crosstools
crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_BASE)
	make crosstool

#
# crosstool-ng
#
CROSSTOOL_NG_VER = 1dbb06f2
CROSSTOOL_NG_SOURCE = crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2
CROSSTOOL_NG_URL = https://github.com/crosstool-ng/crosstool-ng.git

ifeq ($(wildcard $(CROSS_BASE)/build.log.bz2),)
CROSSTOOL = crosstool
crosstool: crosstool-ng

$(ARCHIVE)/$(CROSSTOOL_NG_SOURCE):
	get-git-archive.sh $(CROSSTOOL_NG_URL) $(CROSSTOOL_NG_VER) $(notdir $@) $(ARCHIVE)

crosstool-ng: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
	set -e; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		export CT_ARCHIVE=$(ARCHIVE); \
		export CT_BASE_DIR=$(CROSS_BASE); \
		export LD_LIBRARY_PATH=; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	chmod -R +w $(CROSS_BASE)
	test -e $(CROSS_BASE)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/
	rm -f $(CROSS_BASE)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
endif

crossmenuconfig: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig

