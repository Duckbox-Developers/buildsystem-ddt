#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/.version:
	echo "distro=$(FLAVOUR)" > $@
	echo "imagename=`sed -n 's/\#define PACKAGE_NAME "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "imageversion=`sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "homepage=https://github.com/Duckbox-Developers" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=https://github.com/Duckbox-Developers" >> $@
	echo "forum=https://github.com/Duckbox-Developers/neutrino-ddt" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git log | grep "^commit" | wc -l`" >> $@

# -----------------------------------------------------------------------------
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
e2-multiboot:
	touch $(TARGET_DIR)/usr/bin/enigma2
	echo -e "$(FLAVOUR) `sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'` \\\n \\\l\n" > $(TARGET_DIR)/etc/issue
	touch $(TARGET_DIR)/var/lib/opkg/status
	cp -a $(TARGET_DIR)/.version $(TARGET_DIR)/etc/image-version
endif
# -----------------------------------------------------------------------------

AUDIODEC = ffmpeg

NEUTRINO_DEPS  = $(D)/bootstrap $(KERNEL) $(D)/system-tools
NEUTRINO_DEPS += $(D)/ncurses $(LIRC) $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
ifeq ($(BOXARCH), sh4)
NEUTRINO_DEPS += $(D)/alsa_utils $(D)/ffmpeg
else
NEUTRINO_DEPS += $(D)/ffmpeg
endif
NEUTRINO_DEPS += $(D)/libfribidi $(D)/libsigc $(D)/libdvbsi $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml $(D)/libopenthreads
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/luafeedparser $(D)/luasoap $(D)/luajson
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark spark7162 ufs912 ufs913 ufs910 vuduo dm8000))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/mtd_utils
NEUTRINO_DEPS += $(D)/gptfdisk
endif
#NEUTRINO_DEPS +=  $(D)/minidlna
endif

ifeq ($(BOXARCH), arm)
NEUTRINO_DEPS += $(D)/ntfs_3g
NEUTRINO_DEPS += $(D)/gptfdisk
NEUTRINO_DEPS += $(D)/mc
NEUTRINO_DEPS += $(D)/parted
endif

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/flac

N_CFLAGS       = -Wall -W -Wshadow -Wno-psabi -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing -funsigned-char -ffunction-sections -fdata-sections
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 8.5.0 9.5.0 10.4.0 11.3.0 12.1.0))
N_CFLAGS      += -Wno-cast-function-type
endif
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_INCLUDE_DIR)
N_CPPFLAGS    += -ffunction-sections -fdata-sections

ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += -I$(CROSS_BASE)/$(TARGET)/sys-root/usr/include
endif

ifeq ($(BOXARCH), sh4)
N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

LH_CONFIG_OPTS = $(LOCAL_LIBHAL_BUILD_OPTIONS)
LH_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
N_CONFIG_OPTS += --enable-freesatepg
#N_CONFIG_OPTS += --enable-dynamicdemux
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --disable-tangos

ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
N_CONFIG_OPTS += --enable-reschange
#N_CONFIG_OPTS += --disable-arm-acc
#N_CONFIG_OPTS += --disable-mips-acc
endif

ifeq ($(BOXTYPE), dm8000)
N_CONFIG_OPTS += --disable-mips-acc --enable-lcd
endif

ifeq ($(AUDIODEC), ffmpeg)
# enable ffmpeg audio decoder in neutrino
N_CONFIG_OPTS += --enable-ffmpegdec
else
NEUTRINO_DEPS += $(D)/libid3tag
NEUTRINO_DEPS += $(D)/libmad

N_CONFIG_OPTS += --with-tremor
NEUTRINO_DEPS += $(D)/libvorbisidec

N_CONFIG_OPTS += --enable-flac
NEUTRINO_DEPS += $(D)/flac
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k dm8000))
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), graphlcd)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
#NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif

ifeq ($(EXTERNAL_LCD), both)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
endif

ifeq  ($(FLAVOUR), neutrino-tangos)
GIT_URL     ?= https://github.com/TangoCash
NEUTRINO  = neutrino-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_TANGOS_PATCHES)
HAL_PATCHES  = $(NEUTRINO_LIBSTB_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-ddt)
GIT_URL     ?= https://github.com/Duckbox-Developers
NEUTRINO  = neutrino-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_DDT_PATCHES)
HAL_PATCHES  = $(NEUTRINO_LIBSTB_DDT_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-ddt-youtube)
GIT_URL     ?= https://github.com/Duckbox-Developers
NEUTRINO  = neutrino-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= youtube
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_DDT_PATCHES)
HAL_PATCHES  = $(NEUTRINO_LIBSTB_DDT_PATCHES)
endif

N_OBJDIR = $(BUILD_TMP)/$(NEUTRINO)
LH_OBJDIR = $(BUILD_TMP)/$(LIBSTB_HAL)

################################################################################
#
# libstb-hal
#

$(D)/libstb-hal.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] && \
	(cd $(ARCHIVE)/$(LIBSTB_HAL).git; git pull;); \
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] || \
	git clone $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
	cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL);\
	(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(HAL_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	set -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	@touch $@

$(D)/libstb-hal.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			--with-target=cdk \
			--with-targetprefix=/usr \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

hal \
$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

hal-clean \
libstb-hal-clean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

hal-distclean \
libstb-hal-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal*

################################################################################
#
# neutrino
#
$(D)/neutrino-plugins.do_prepare \
$(D)/neutrino.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO).git; git pull;); \
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] || \
	git clone $(GIT_URL)/$(NEUTRINO).git $(ARCHIVE)/$(NEUTRINO).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO); \
	(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(NMP_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).org
	set -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(NMP_PATCHES))
	@touch $@

$(D)/neutrino.config.status \
$(D)/neutrino-plugins.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO)/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--enable-fribidi \
			--enable-giflib \
			--enable-lua \
			--enable-pugixml \
			$(N_CONFIG_OPTS) \
			\
			--with-tremor \
			--with-target=cdk \
			--with-targetprefix=/usr \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
		+make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	@touch $@

$(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h:
	@rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		pushd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/$(NEUTRINO); \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		BS_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "BS-rev'$$BS_REV'_HAL-rev'$$HAL_REV'_N-rev'$$NMP_REV'"' >> $@; \
	fi

$(D)/neutrino-plugins.do_compile \
$(D)/neutrino.do_compile:
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

mp \
neutrino: $(D)/neutrino.do_prepare $(D)/neutrino.config.status $(D)/neutrino.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/.version
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	make e2-multiboot
endif
	touch $(D)/$(notdir $@)
	$(HOST_DIR)/bin/qrencode -o $(TARGET_DIR)/usr/share/tuxbox/neutrino/icons/qr.png "$(GIT_URL)" -m 1 -s 5
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

mp-clean \
neutrino-clean:
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino*

mpp \
neutrino-plugins: $(D)/neutrino-plugins.do_prepare $(D)/neutrino-plugins.config.status $(D)/neutrino-plugins.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/.version
	make $(NEUTRINO_PLUGINS)
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	make e2-multiboot
endif
	touch $(D)/$(notdir $@)
	$(HOST_DIR)/bin/qrencode -o $(TARGET_DIR)/usr/share/tuxbox/neutrino/icons/qr.png "$(GIT_URL)" -m 1 -s 5
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

mpp-clean \
neutrino-plugins-clean:
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugins.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	make neutrino-plugin-clean
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mpp-distclean \
neutrino-plugins-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-plugins*
	make neutrino-plugin-distclean

PHONY += $(TARGET_DIR)/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
