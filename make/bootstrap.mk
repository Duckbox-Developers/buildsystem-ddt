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

BOOTSTRAP  = directories
BOOTSTRAP += crosstool
BOOTSTRAP += $(D)/ccache
BOOTSTRAP += $(HOST_DIR)/bin/opkg.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-chksvn.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-gitdescribe.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-find-requires.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-find-provides.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-module-deps.sh
BOOTSTRAP += $(HOST_DIR)/bin/get-git-archive.sh
BOOTSTRAP += $(D)/host_pkgconfig
BOOTSTRAP += $(D)/host_module_init_tools
BOOTSTRAP += $(D)/host_mtd_utils
BOOTSTRAP += $(D)/host_mkcramfs
BOOTSTRAP += $(D)/host_mksquashfs

$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

SYSTEM_TOOLS  = $(D)/module_init_tools
SYSTEM_TOOLS += $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/fbshot
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs922))
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	@touch $@

#
# YAUD NONE
#
YAUD_NONE     = $(D)/bootstrap
YAUD_NONE    += $(D)/kernel
YAUD_NONE    += $(D)/system-tools

yaud-none: $(YAUD_NONE)
	@touch $(D)/$(notdir $@)

$(HOST_DIR)/bin/unpack%.sh \
$(HOST_DIR)/bin/get%.sh \
$(HOST_DIR)/bin/opkg%sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOST_DIR)/bin

#
#
#
$(DRIVER_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repository'
	@echo '===================================================================='
	if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi

$(APPS_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_APPS)-apps git repository'
	@echo '===================================================================='
	if [ ! -e $(APPS_DIR)/.git ]; then \
		git clone $(GITHUB)/$(GIT_NAME_APPS)/apps.git apps; \
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
PREQS += $(APPS_DIR)
PREQS += $(FLASH_DIR)

preqs: $(PREQS)

#
# directories
#
directories:
	test -d $(D) || mkdir $(D)
	test -d $(ARCHIVE) || mkdir $(ARCHIVE)
	test -d $(STL_ARCHIVE) || mkdir $(STL_ARCHIVE)
	test -d $(BUILD_TMP) || mkdir $(BUILD_TMP)
	test -d $(SOURCE_DIR) || mkdir $(SOURCE_DIR)
	install -d $(TARGET_DIR)
	install -d $(CROSS_DIR)
	install -d $(BOOT_DIR)
	install -d $(IMAGE_DIR)
	install -d $(HOST_DIR)
	install -d $(HOST_DIR)/{bin,lib,share}
	install -d $(TARGET_DIR)/{bin,boot,etc,lib,sbin,usr,var}
	install -d $(TARGET_DIR)/etc/{init.d,mdev,network,rc.d}
	install -d $(TARGET_DIR)/etc/rc.d/{rc0.d,rc6.d}
	ln -sf ../init.d $(TARGET_DIR)/etc/rc.d/init.d
	install -d $(TARGET_DIR)/lib/{lsb,firmware}
	install -d $(TARGET_DIR)/usr/{bin,lib,local,sbin,share}
	install -d $(TARGET_DIR)/usr/lib/pkgconfig
	install -d $(TARGET_DIR)/usr/include/linux
	install -d $(TARGET_DIR)/usr/include/linux/dvb
	install -d $(TARGET_DIR)/usr/local/{bin,sbin,share}
	install -d $(TARGET_DIR)/var/{etc,lib,run}
	install -d $(TARGET_DIR)/var/lib/{misc,nfs}
	install -d $(TARGET_DIR)/var/bin
	touch $(D)/$(notdir $@)

#
# ccache
#
CCACHE_BINDIR = $(HOST_DIR)/bin
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
PHONY += ccache

