# makefile for basic prerequisites

TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config
TOOLCHECK += find-cmake find-gperf

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
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

PREQS =

preqs: $(PREQS)

TOOLS += $(D)/tools-aio-grab
TOOLS += $(D)/tools-devinit
TOOLS += $(D)/tools-evremote2
TOOLS += $(D)/tools-fp_control
TOOLS += $(D)/tools-hotplug
TOOLS += $(D)/tools-showiframe
TOOLS += $(D)/tools-stfbcontrol
TOOLS += $(D)/tools-streamproxy
TOOLS += $(D)/tools-ustslave
TOOLS += $(D)/tools-vfdctl
TOOLS += $(D)/tools-wait4button
#TOOLS += $(D)/tools-libmme_host
#TOOLS += $(D)/tools-libmmeimage
ifeq ($(MEDIAFW), eplayer3)
TOOLS += $(D)/tools-libeplayer3
endif

$(D)/tools: $(TOOLS)
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
	touch $@

#
# YAUD NONE
#
yaud-none: \
	$(D)/bootstrap \
	$(D)/linux-kernel \
	$(D)/system-tools
	touch $(D)/$(notdir $@)
