#
# makefile to build oscam
#
# -----------------------------------------------------------------------------

OSCAM_FLAVOUR ?= oscam

ifeq ($(OSCAM_FLAVOUR), oscam)
OSCAM_FLAVOUR_URL = https://repo.or.cz/oscam.git
OSCAM_FLAVOUR_DIR = oscam.git
OSCAM_SOURCE_DIR  = oscam
OSCAM_PULL        = git pull
OSCAM_CLONE       = git clone
else ifeq ($(OSCAM_FLAVOUR), oscam-svn)
OSCAM_FLAVOUR_URL = http://www.streamboard.tv/svn/oscam/trunk
OSCAM_FLAVOUR_DIR = oscam-svn
OSCAM_SOURCE_DIR  = oscam-svn
OSCAM_PULL        = svn up
OSCAM_CLONE       = svn checkout
else ifeq ($(OSCAM_FLAVOUR), oscam-smod)
OSCAM_FLAVOUR_URL = https://github.com/Schimmelreiter/oscam-smod.git
OSCAM_FLAVOUR_DIR = oscam-smod.git
OSCAM_SOURCE_DIR  = oscam-smod
OSCAM_PULL        = git pull
OSCAM_CLONE       = git clone
endif

# -----------------------------------------------------------------------------

#OSCAM_VER = $(OSCAM_FLAVOUR)
#OSCAM_SOURCE = $(OSCAM_FLAVOUR_URL)
OSCAM_CONFIG ?= --enable WEBIF \
		CS_ANTICASC \
		CS_CACHEEX \
		CW_CYCLE_CHECK \
		CLOCKFIX \
		HAVE_DVBAPI \
		IRDETO_GUESSING \
		MODULE_MONITOR \
		READ_SDT_CHARSETS \
		TOUCH \
		WEBIF_JQUERY \
		WEBIF_LIVELOG \
		WITH_DEBUG \
		WITH_EMU \
		WITH_LB \
		WITH_NEUTRINO \
		WITH_SSL \
		\
		MODULE_CAMD35 \
		MODULE_CAMD35_TCP \
		MODULE_CCCAM \
		MODULE_CCCSHARE \
		MODULE_CONSTCW \
		MODULE_GBOX \
		MODULE_NEWCAMD \
		\
		READER_CONAX \
		READER_CRYPTOWORKS \
		READER_IRDETO \
		READER_NAGRA \
		READER_NAGRA_MERLIN \
		READER_SECA \
		READER_VIACCESS \
		READER_VIDEOGUARD \
		\
		CARDREADER_INTERNAL \
		CARDREADER_PHOENIX \
		CARDREADER_SMARGO \
		CARDREADER_SC8IN1

OSCAM_PATCH = $(OSCAM_LOCAL_PATCH)

$(D)/oscam.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR)
	rm -rf $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR).org
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/$(OSCAM_FLAVOUR_DIR)" ] && \
	(cd $(ARCHIVE)/$(OSCAM_FLAVOUR_DIR); $(OSCAM_PULL);); \
	[ -d "$(ARCHIVE)/$(OSCAM_FLAVOUR_DIR)" ] || \
	$(OSCAM_CLONE) $(OSCAM_FLAVOUR_URL) $(ARCHIVE)/$(OSCAM_FLAVOUR_DIR);
	cp -ra $(ARCHIVE)/$(OSCAM_FLAVOUR_DIR) $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
	cp -ra $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR) $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR).org
	set -e; cd $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
		$(call apply_patches, $(OSCAM_PATCH)); \
		 $(SHELL) ./config.sh --disable all \
			$(OSCAM_CONFIG)
	@touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- USE_LIBCRYPTO=1 USE_LIBUSB=1 \
		PLUS_TARGET="-rezap" \
		CONF_DIR=/var/keys \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		CC_OPTS=" -Os -pipe "
	@touch $@

$(D)/oscam: $(D)/bootstrap $(D)/openssl $(D)/libusb oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR)/Distribution/* $(TARGET_DIR)/../OScam/
	$(REMOVE)/oscam
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam.do_compile
	$(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
		$(MAKE) distclean

# -----------------------------------------------------------------------------

oscam-distclean:
	rm -f $(D)/oscam*
