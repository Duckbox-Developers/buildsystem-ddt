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


SYSTEM_TOOLS  = $(D)/module_init_tools $(D)/busybox $(D)/zlib $(D)/sysvinit $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs $(D)/jfsutils
SYSTEM_TOOLS += $(D)/portmap $(D)/nfs_utils $(D)/vsftpd $(D)/autofs
SYSTEM_TOOLS += $(D)/driver $(D)/tools

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
