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
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

PREQS =

preqs: $(PREQS)


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
SYSTEM_TOOLS += $(D)/aio-grab
SYSTEM_TOOLS += $(D)/devinit
SYSTEM_TOOLS += $(D)/evremote2
SYSTEM_TOOLS += $(D)/fp_control
SYSTEM_TOOLS += $(D)/hotplug
SYSTEM_TOOLS += $(D)/showiframe
SYSTEM_TOOLS += $(D)/streamproxy
SYSTEM_TOOLS += $(D)/ustslave
SYSTEM_TOOLS += $(D)/vfdctl
SYSTEM_TOOLS += $(D)/wait4button
#SYSTEM_TOOLS += $(D)/libmme_host
#SYSTEM_TOOLS += $(D)/libmmeimage
ifeq ($(MEDIAFW), eplayer3)
SYSTEM_TOOLS += $(D)/libeplayer3
endif

$(D)/system-tools: $(SYSTEM_TOOLS)
	touch $@

#
# YAUD NONE
#
yaud-none: \
	$(D)/bootstrap \
	$(D)/linux-kernel \
	$(D)/system-tools
	touch $(D)/$(notdir $@)
