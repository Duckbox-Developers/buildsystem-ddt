#master makefile

SHELL = /bin/bash
UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Do not do this, it is dangerous."
	@echo "Aborting the build. Log in as a regular user and retry."
else
LC_ALL:=C
LANG:=C
export TOPDIR LC_ALL LANG

include make/buildenv.mk

PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS))


############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo
	@echo '================================================================================'
	@echo "Build Environment Variables:"
	@echo "PATH              : `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/                  : /;'||echo $(PATH)`"
	@echo "ARCHIVE_DIR       : $(ARCHIVE)"
	@echo "BASE_DIR          : $(BASE_DIR)"
	@echo "CUSTOM_DIR        : $(CUSTOM_DIR)"
	@echo "TOOLS_DIR         : $(TOOLS_DIR)"
	@echo "DRIVER_DIR        : $(DRIVER_DIR)"
	@echo "FLASH_DIR         : $(FLASH_DIR)"
	@echo "CROSS_DIR         : $(CROSS_DIR)"
	@echo "CROSS_BASE        : $(CROSS_BASE)"
	@echo "RELEASE_DIR       : $(RELEASE_DIR)"
	@echo "RELEASE_IMAGE_DIR : $(RELEASE_IMAGE_DIR)"
	@echo "HOST_DIR          : $(HOST_DIR)"
	@echo "TARGET_DIR        : $(TARGET_DIR)"
	@echo "KERNEL_DIR        : $(KERNEL_DIR)"
	@echo "MAINTAINER        : $(MAINTAINER)"
	@echo "BOXARCH           : $(BOXARCH)"
	@echo "BUILD             : $(BUILD)"
	@echo "TARGET            : $(TARGET)"
	@echo "BOXTYPE           : $(BOXTYPE)"
	@echo "KERNEL_VERSION    : $(KERNEL_VER)"
	@echo "EXTERNAL_LCD      : $(EXTERNAL_LCD)"
	@echo "MEDIAFW           : $(MEDIAFW)"
	@echo -e "FLAVOUR           : $(TERM_YELLOW)$(FLAVOUR)$(TERM_NORMAL)"
	@echo "PARALLEL_JOBS     : $(PARALLEL_JOBS)"
	@echo '================================================================================'
ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
	@echo -e "LOCAL_NEUTRINO_BUILD_OPTIONS : $(TERM_GREEN)$(LOCAL_NEUTRINO_BUILD_OPTIONS)$(TERM_NORMAL)"
	@echo -e "LOCAL_NEUTRINO_CFLAGS        : $(TERM_GREEN)$(LOCAL_NEUTRINO_CFLAGS)$(TERM_NORMAL)"
	@echo -e "LOCAL_NEUTRINO_PLUGINS       : $(TERM_GREEN)$(LOCAL_NEUTRINO_PLUGINS)$(TERM_NORMAL)"
	@echo -e "LOCAL_NEUTRINO_DEPS          : $(TERM_GREEN)$(LOCAL_NEUTRINO_DEPS)$(TERM_NORMAL)"
endif
	@echo '================================================================================'
	@make --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif
	@if ! test -e $(BASE_DIR)/config; then \
		echo;echo "If you want to create or modify the configuration, run './make.sh'"; \
		echo; fi

help:
	@echo "a few helpful make targets:"
	@echo "* make crosstool           - build cross toolchain"
	@echo "* make bootstrap           - prepares for building"
	@echo "* make print-targets       - print out all available targets"
	@echo ""
	@echo "later, you might find these useful:"
	@echo "* make update-self         - update the build system"
	@echo "* make update              - update the build system, tools, driver and flash"
	@echo ""
	@echo "cleantargets:"
	@echo "make clean                 - Clears everything except kernel."
	@echo "make distclean             - Clears the whole construction."
	@echo

# define package versions first...
include make/system-libs.mk
include make/system-tools.mk
include make/system-lua.mk
include make/ffmpeg.mk
ifeq ($(BOXARCH), sh4)
include make/linux-kernel-sh4.mk
include make/crosstool-sh4.mk
include make/driver-sh4.mk
endif
ifeq ($(BOXARCH), arm)
include make/linux-kernel-arm.mk
include make/driver-arm.mk
endif
ifeq ($(BOXARCH), mips)
include make/linux-kernel-mips.mk
include make/driver-mips.mk
endif
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
include make/crosstool.mk
endif
include make/gstreamer.mk
include make/root-etc.mk
include make/python.mk
include make/tools.mk
include make/neutrino.mk
include make/neutrino-plugins.mk
include make/neutrino-release.mk
include make/flashimage.mk
include make/cleantargets.mk
include make/patches.mk
include make/bootstrap.mk

update-self:
	git pull

update:
	$(MAKE) distclean
	@if test -d $(BASE_DIR); then \
		cd $(BASE_DIR)/; \
		echo '===================================================================='; \
		echo '      updating $(GIT_NAME)-buildsystem git repository'; \
		echo '===================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-cdk.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(DRIVER_DIR); then \
		cd $(DRIVER_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_DRIVER)-driver git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-driver.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(TOOLS_DIR); then \
		cd $(TOOLS_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_TOOLS)-tools git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-tools.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(FLASH_DIR); then \
		cd $(FLASH_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_FLASH)-flash git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-flash.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

# print all present targets...
print-targets:
	@sed -n 's/^\$$.D.\/\(.*\):.*/\1/p; s/^\([a-z].*\):\( \|$$\).*/\1/p;' \
		`ls -1 make/*.mk|grep -v make/buildenv.mk|grep -v make/neutrino-release.mk` | \
		sort -u | fold -s -w 65

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

# debug target, if you need that, you know it. If you don't know if you need
# that, you don't need it.
.print-phony:
	@echo $(PHONY)

PHONY += everything print-targets
PHONY += all printenv .print-phony
PHONY += update update-self
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:

endif
