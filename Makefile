#master makefile

SHELL = /bin/bash
UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Don't do this, it's dangerous."
	@echo "Refusing to build. Good bye."
else

include make/buildenv.mk

############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo '============================================================================== '
	@echo "Build Environment Varibles:"
	@echo "MAINTAINER     : $(MAINTAINER)"
	@echo "ARCHIVE_DIR    : $(ARCHIVE)"
	@echo "BASE_DIR       : $(BASE_DIR)"
	@echo "CDK_DIR        : $(CDK_DIR)"
	@echo "CUSTOM_DIR     : $(CUSTOM_DIR)"
	@echo "APPS_DIR       : $(APPS_DIR)"
	@echo "DRIVER_DIR     : $(DRIVER_DIR)"
	@echo "FLASH_DIR      : $(FLASH_DIR)"
	@echo "CROSS_DIR      : $(CROSS_DIR)"
	@echo "CROSS_BASE     : $(CROSS_BASE)"
	@echo "HOSTPREFIX     : $(HOSTPREFIX)"
	@echo "TARGETPREFIX   : $(TARGETPREFIX)"
	@echo "PATH           : `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/               : /;'||echo $(PATH)`"
	@echo "BOXARCH        : $(BOXARCH)"
	@echo "BUILD          : $(BUILD)"
	@echo "TARGET         : $(TARGET)"
	@echo "PLATFORM       : $(PLATFORM)"
	@echo "BOXTYPE        : $(BOXTYPE)"
	@echo "KERNEL_VERSION : $(KERNEL_VERSION)"
	@echo "GITSOURCE      : $(GITSOURCE)"
	@echo "N_HD_SOURCE    : $(N_HD_SOURCE)"
	@echo '============================================================================== '
	@echo "LOCAL_NEUTRINO_BUILD_OPTIONS:  $(LOCAL_NEUTRINO_BUILD_OPTIONS)"
	@echo "LOCAL_NEUTRINO_CFLAGS:  $(LOCAL_NEUTRINO_CFLAGS)"
	@echo ""
	@make --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif
#	@LC_ALL=C make -n preqs|grep -q "Nothing to be done" && P=false || P=true; \
#	test -d $(TARGETPREFIX) && T=false || T=true; \
#	type -p $(TARGET)-pkg-config >/dev/null 2>&1 || T=true; \
#	PATH=$(PATH):$(CROSS_DIR)/bin; \
#	type -p $(TARGET)-gcc >/dev/null 2>&1 && C=false || C=true; \
#	if $$P || $$T || $$C; then \
#		echo "Your next steps are most likely (in this order):"; \
#		$$P && echo "	* 'make preqs'		for prerequisites"; \
#		$$C && echo "	* 'make crosstool'	for the cross compiler"; \
#		$$T && echo "	* 'make bootstrap'	to prepare the target root"; \
#		echo; \
#	fi

help:
	@echo "a few helpful make targets:"
	@echo "* make crosstool           - build cross toolchain"
	@echo "* make bootstrap           - prepares for building"
	@echo

# define package versions first...
include make/yaud.mk
include make/bootstrap.mk
include make/contrib-libs.mk
include make/contrib-apps.mk
include make/linux-kernel.mk
include make/driver.mk
include make/tools.mk
include make/root-etc.mk
include make/python.mk
include make/gstreamer.mk
include make/enigma2-plugins.mk
include make/enigma2-pli-nightly.mk
include make/neutrino.mk
include make/neutrino-plugins.mk
include make/cleantargets.mk
include make/enigma2-release.mk
include make/neutrino-release.mk
include make/patches.mk

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

# print all present targets...
print-targets:
	sed -n 's/^\$$.D.\/\(.*\):.*/\1/p; s/^\([a-z].*\):\( \|$$\).*/\1/p;' \
		`ls -1 make/*.mk|grep -v make/unmaintained.mk` Makefile | \
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
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:
endif
