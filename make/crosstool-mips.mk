# makefile to build crosstools
crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_BASE)
	make crosstool

$(TARGET_DIR)/lib/libc.so.6:
	if test -e $(CROSS_BASE)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_BASE)/$(TARGET)/sys-root/lib/*so* $(TARGET_DIR)/lib; \
	else \
		cp -a $(CROSS_BASE)/$(TARGET)/lib/*so* $(TARGET_DIR)/lib; \
	fi

#
# crosstool-ng
#
CROSSTOOL_NG_VER = 872341e3
CROSSTOOL_NG_SOURCE = crosstool-ng-git-$(CROSSTOOL_NG_VER).tar.bz2
CROSSTOOL_NG_URL = https://github.com/crosstool-ng/crosstool-ng.git
CROSSTOOL_NG_BACKUP = $(ARCHIVE)/crosstool-ng-git-$(BOXARCH)-$(BOXCPU)-$(CROSSTOOL_NG_VER)-backup.tar.gz

ifeq ($(BOXTYPE), vuduo)
CROSSTOOL_BOXTYPE_PATCH = $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-vuduo.patch
endif

$(ARCHIVE)/$(CROSSTOOL_NG_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(CROSSTOOL_NG_URL) $(CROSSTOOL_NG_VER) $(notdir $@) $(ARCHIVE)

CUSTOM_KERNEL = $(ARCHIVE)/$(KERNEL_SRC)

ifeq ($(BOXTYPE), vuduo)
CUSTOM_KERNEL_VER = 3.9.6
endif

ifeq ($(wildcard $(CROSS_BASE)/build.log.bz2),)
CROSSTOOL = crosstool
crosstool:
	make MAKEFLAGS=--no-print-directory crosstool-ng
	if [ ! -e $(CROSSTOOL_NG_BACKUP) ]; then \
		make crosstool-backup; \
	fi;

crosstool-ng: $(D)/directories $(ARCHIVE)/$(KERNEL_SRC) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
	$(CHDIR)/crosstool-ng-git-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH)-$(BOXCPU).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		$(call apply_patches, $(CROSSTOOL_BOXTYPE_PATCH)); \
		\
		export CT_NG_ARCHIVE=$(ARCHIVE); \
		export CT_NG_BASE_DIR=$(CROSS_BASE); \
		export CT_NG_CUSTOM_KERNEL=$(CUSTOM_KERNEL); \
		export CT_NG_CUSTOM_KERNEL_VER=$(CUSTOM_KERNEL_VER); \
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
	$(REMOVE)/crosstool-ng-git-$(CROSSTOOL_NG_VER)
endif

crosstool-backup:
	if [ -e $(CROSSTOOL_NG_BACKUP) ]; then \
		mv $(CROSSTOOL_NG_BACKUP) $(CROSSTOOL_NG_BACKUP).old; \
	fi; \
	cd $(CROSS_BASE); \
	tar czvf $(CROSSTOOL_NG_BACKUP) *

crosstool-restore: $(CROSSTOOL_NG_BACKUP)
	rm -rf $(CROSS_BASE) ; \
	if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi;
	tar xzvf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_BASE)

crossmenuconfig: $(D)/directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng-git-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-git-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH)-$(BOXCPU).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig
