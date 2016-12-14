#master makefile

SHELL = /bin/bash
UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Do not do this, it is dangerous."
	@echo "Aborting the build. Goodbye."
else

include make/buildenv.mk

############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	clear
	@echo '================================================================================'
	@echo "Build Environment Variables:"
	@echo "MAINTAINER       : $(MAINTAINER)"
	@echo "ARCHIVE_DIR      : $(ARCHIVE)"
	@echo "BASE_DIR         : $(BASE_DIR)"
	@echo "CUSTOM_DIR       : $(CUSTOM_DIR)"
	@echo "APPS_DIR         : $(APPS_DIR)"
	@echo "DRIVER_DIR       : $(DRIVER_DIR)"
	@echo "FLASH_DIR        : $(FLASH_DIR)"
	@echo "CROSS_DIR        : $(CROSS_DIR)"
	@echo "CROSS_BASE       : $(CROSS_BASE)"
	@echo "RELEASE_DIR      : $(RELEASE_DIR)"
	@echo "HOSTPREFIX       : $(HOSTPREFIX)"
	@echo "TARGETPREFIX     : $(TARGETPREFIX)"
	@echo "PATH             : `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/                 : /;'||echo $(PATH)`"
	@echo "BOXARCH          : $(BOXARCH)"
	@echo "BUILD            : $(BUILD)"
	@echo "TARGET           : $(TARGET)"
	@echo "PLATFORM         : $(PLATFORM)"
	@echo "BOXTYPE          : $(BOXTYPE)"
	@echo "KERNEL_VERSION   : $(KERNEL_VERSION)"
	@echo "MULTICOM_VERSION : $(MULTICOM_VER)"
	@echo "PLAYER_VERSION   : $(PLAYER_VER)"
	@echo "MEDIAFW          : $(MEDIAFW)"
	@echo "EXTERNAL_LCD     : $(EXTERNAL_LCD)"
	@echo "IMAGE            : $(IMAGE)"
	@echo '================================================================================'
ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
	@echo "LOCAL_NEUTRINO_BUILD_OPTIONS : $(LOCAL_NEUTRINO_BUILD_OPTIONS)"
	@echo "LOCAL_NEUTRINO_CFLAGS        : $(LOCAL_NEUTRINO_CFLAGS)"
	@echo "LOCAL_NEUTRINO_DEPS          : $(LOCAL_NEUTRINO_DEPS)"
else ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
	@echo "LOCAL_ENIGMA2_BUILD_OPTIONS  : $(LOCAL_ENIGMA2_BUILD_OPTIONS)"
	@echo "LOCAL_ENIGMA2_CPPFLAGS       : $(LOCAL_ENIGMA2_CPPFLAGS)"
	@echo "LOCAL_ENIGMA2_DEPS           : $(LOCAL_ENIGMA2_DEPS)"
endif
	@echo '================================================================================'
	@echo ""
	@$(MAKE) --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif

help:
	@echo "a few helpful make targets:"
	@echo "* make crosstool           - build cross toolchain"
	@echo "* make bootstrap           - prepares for building"
	@echo

# define package versions first...
include make/contrib-libs.mk
include make/contrib-apps.mk
include make/linux-kernel.mk
include make/driver.mk
include make/tools.mk
include make/root-etc.mk
include make/python.mk
include make/gstreamer.mk
include make/enigma2.mk
include make/enigma2-plugins.mk
include make/enigma2-release.mk
include make/neutrino.mk
include make/neutrino-plugins.mk
include make/neutrino-release.mk
include make/cleantargets.mk
include make/patches.mk
include make/bootstrap.mk

update:
	@if test -d $(BASE_DIR); then \
		cd $(BASE_DIR)/; \
		echo '=============================================================='; \
		echo '      updating $(GIT_NAME)-cdk git repo                       '; \
		echo '=============================================================='; \
		echo; \
		$(GIT_PULL); fi
		@echo;
	@if test -d $(DRIVER_DIR); then \
		cd $(DRIVER_DIR)/; \
		echo '=============================================================='; \
		echo '      updating $(GIT_NAME_DRIVER)-driver git repo             '; \
		echo '=============================================================='; \
		echo; \
		$(GIT_PULL); fi
		@echo;
	@if test -d $(APPS_DIR); then \
		cd $(APPS_DIR)/; \
		echo '=============================================================='; \
		echo '      updating $(GIT_NAME_APPS)-apps git repo                 '; \
		echo '=============================================================='; \
		echo; \
		$(GIT_PULL); fi
		@echo;
	@if test -d $(FLASH_DIR); then \
		cd $(FLASH_DIR)/; \
		echo '=============================================================='; \
		echo '      updating $(GIT_NAME_FLASH)-flash git repo               '; \
		echo '=============================================================='; \
		echo; \
		$(GIT_PULL); fi
		@echo;

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
