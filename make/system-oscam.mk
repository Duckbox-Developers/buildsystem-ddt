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
else ifeq ($(OSCAM_FLAVOUR), oscam-git)
OSCAM_FLAVOUR_URL = https://git.streamboard.tv/common/oscam.git
OSCAM_FLAVOUR_DIR = oscam.git
OSCAM_SOURCE_DIR  = oscam
OSCAM_PULL        = git pull
OSCAM_CLONE       = git clone
else ifeq ($(OSCAM_FLAVOUR), oscam-smod)
OSCAM_FLAVOUR_URL = https://github.com/Schimmelreiter/oscam-smod.git
OSCAM_FLAVOUR_DIR = oscam-smod.git
OSCAM_SOURCE_DIR  = oscam-smod
OSCAM_PULL        = git pull
OSCAM_CLONE       = git clone
endif

ST_LIBCRYPTO ?= 0
ST_LIBDVBCSA ?= 1
ST_LIBSSL ?= 0
ST_LIBUSB ?= 0

ifeq ($(ST_LIBCRYPTO), 1)
	ST_CRYPTO = LIBCRYPTO_LIB=$(TARGET_LIB_DIR)/libcrypto.a
endif
ifneq ($(BOXARCH), sh4)
ifeq ($(ST_LIBDVBCSA), 1)
	ST_DVBCSA = USE_LIBDVBCSA=1 LIBDVBCSA_LIB=$(TARGET_LIB_DIR)/libdvbcsa.a
endif
endif
ifeq ($(ST_LIBSSL), 1)
	ST_SSL = SSL_LIB=$(TARGET_LIB_DIR)/libssl.a
endif
ifeq ($(ST_LIBUSB), 1)
	ST_USB = LIBUSB_LIB=$(TARGET_LIB_DIR)/libusb-1.0.a
endif

ifneq ($(BOXARCH), sh4)
	STREAMRELAY = MODULE_STREAMRELAY
endif

# -----------------------------------------------------------------------------

#OSCAM_VER = $(OSCAM_FLAVOUR)
#OSCAM_SOURCE = $(OSCAM_FLAVOUR_URL)
OSCAM_CONFIG ?= --enable \
		CARDREADER_INTERNAL \
		CARDREADER_INTERNAL_SCI \
		CARDREADER_PHOENIX \
		CARDREADER_SC8IN1 \
		CARDREADER_SMARGO \
		CARDREADER_SMART \
		\
		CLOCKFIX \
		CS_ANTICASC \
		CS_CACHEEX \
		CW_CYCLE_CHECK \
		HAVE_DVBAPI \
		IRDETO_GUESSING \
		\
		MODULE_CAMD35 \
		MODULE_CAMD35_TCP \
		MODULE_CCCAM \
		MODULE_CCCSHARE \
		MODULE_CONSTCW \
		MODULE_GBOX \
		MODULE_MONITOR \
		MODULE_NEWCAMD \
		MODULE_SCAM \
		$(STREAMRELAY) \
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
		READ_SDT_CHARSETS \
		WEBIF \
		WEBIF_JQUERY \
		WEBIF_LIVELOG \
		\
		WITH_CARDREADER \
		WITH_DEBUG \
		WITH_EMU \
		WITH_LB \
		WITH_NEUTRINO \
		WITH_SSL

OSCAM_VER = 527d8e1a
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
		git checkout $(OSCAM_VER); \
		$(call apply_patches, $(OSCAM_PATCH)); \
		 $(SHELL) ./config.sh --disable all \
			$(OSCAM_CONFIG)
	@touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- USE_LIBCRYPTO=1 $(ST_CRYPTO) $(ST_DVBCSA) USE_LIBSSL=1 $(ST_SSL) USE_LIBUSB=1 $(ST_USB) \
		PLUS_TARGET="-rezap" \
		CONF_DIR=/var/keys \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		CC_OPTS=" -Os -pipe "
	@touch $@

ifneq ($(BOXARCH), sh4)
$(D)/oscam: $(D)/bootstrap $(D)/openssl $(D)/libusb $(D)/libdvbcsa oscam.do_prepare oscam.do_compile
else
$(D)/oscam: $(D)/bootstrap $(D)/openssl $(D)/libusb oscam.do_prepare oscam.do_compile
endif
	rm -rf $(TARGET_DIR)/../$(OSCAM_FLAVOUR)
	mkdir $(TARGET_DIR)/../$(OSCAM_FLAVOUR)
	cp -pR $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR)/Distribution/* $(TARGET_DIR)/../$(OSCAM_FLAVOUR)/
	$(REMOVE)/oscam
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam.do_compile
	cd $(SOURCE_DIR)/$(OSCAM_SOURCE_DIR); \
		$(MAKE) distclean

# -----------------------------------------------------------------------------

oscam-distclean:
	rm -f $(D)/oscam*
