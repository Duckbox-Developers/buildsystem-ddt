#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/var/etc/.version:
	echo "imagename=Neutrino MP" > $@
	echo "homepage=https://github.com/Duckbox-Developers" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=https://github.com/Duckbox-Developers" >> $@
	echo "forum=https://github.com/Duckbox-Developers/neutrino-mp-cst-next" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git log | grep "^commit" | wc -l`" >> $@

NEUTRINO_DEPS  = $(D)/bootstrap $(D)/ncurses $(LIRC) $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
NEUTRINO_DEPS += $(D)/alsa_utils $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libfribidi $(D)/libsigc $(D)/libdvbsi $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml $(D)/libopenthreads
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/luafeedparser $(D)/luasoap $(D)/luajson
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark spark7162 ufs912 ufs913 ufs910))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/mtd_utils $(D)/parted
endif
#NEUTRINO_DEPS +=  $(D)/minidlna
endif

ifeq ($(BOXARCH), arm)
NEUTRINO_DEPS += $(D)/gst_plugins_dvbmediasink
NEUTRINO_DEPS += $(D)/ntfs_3g
NEUTRINO_DEPS += $(D)/aio-grab
endif

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/flac

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing -funsigned-char -ffunction-sections -fdata-sections
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_DIR)/usr/include
ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
N_CPPFLAGS    += -I$(CROSS_BASE)/$(TARGET)/sys-root/usr/include
endif
ifeq ($(BOXARCH), sh4)
N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
endif
N_CPPFLAGS    += -ffunction-sections -fdata-sections

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-lua
N_CONFIG_OPTS += --enable-giflib
N_CONFIG_OPTS += --enable-ffmpegdec
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --disable-webif
#N_CONFIG_OPTS += --disable-tangos
N_CONFIG_OPTS += --enable-pugixml
ifeq ($(BOXARCH), arm)
N_CONFIG_OPTS += --enable-reschange
endif

OBJDIR = $(BUILD_TMP)
N_OBJDIR = $(OBJDIR)/neutrino-mp
LH_OBJDIR = $(OBJDIR)/libstb-hal

################################################################################
#
# libstb-hal-cst-next
#
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES =

$(D)/libstb-hal-cst-next.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(ARCHIVE)/libstb-hal-cst-next.git" ] && \
	(cd $(ARCHIVE)/libstb-hal-cst-next.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/libstb-hal-cst-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/libstb-hal-cst-next.git $(ARCHIVE)/libstb-hal-cst-next.git; \
	cp -ra $(ARCHIVE)/libstb-hal-cst-next.git $(SOURCE_DIR)/libstb-hal-cst-next;\
	cp -ra $(SOURCE_DIR)/libstb-hal-cst-next $(SOURCE_DIR)/libstb-hal-cst-next.org
	set -e; cd $(SOURCE_DIR)/libstb-hal-cst-next; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES))
	@touch $@

$(D)/libstb-hal-cst-next.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR); \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR); \
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/libstb-hal-cst-next/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-cst-next/configure --enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--enable-silent-rules \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal-cst-next.do_compile: $(D)/libstb-hal-cst-next.config.status
	cd $(SOURCE_DIR)/libstb-hal-cst-next; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-cst-next: $(D)/libstb-hal-cst-next.do_prepare $(D)/libstb-hal-cst-next.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-cst-next-clean:
	rm -f $(D)/libstb-hal-cst-next
	rm -f $(D)/libstb-hal-cst-next.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-cst-next-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-cst-next*

################################################################################
#
# neutrino-mp-cst-next
#
yaud-neutrino-mp-cst-next: yaud-none \
		neutrino-mp-cst-next $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

mp \
yaud-neutrino-mp-cst-next-plugins: yaud-none \
		$(D)/neutrino-mp-cst-next $(D)/neutrino-plugins $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

NEUTRINO_MP_CST_NEXT_PATCHES =

$(D)/neutrino-mp-cst-next.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-cst-next
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/neutrino-mp-cst-next.git" ] && \
	(cd $(ARCHIVE)/neutrino-mp-cst-next.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/neutrino-mp-cst-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-cst-next.git $(ARCHIVE)/neutrino-mp-cst-next.git; \
	cp -ra $(ARCHIVE)/neutrino-mp-cst-next.git $(SOURCE_DIR)/neutrino-mp-cst-next; \
	cp -ra $(SOURCE_DIR)/neutrino-mp-cst-next $(SOURCE_DIR)/neutrino-mp-cst-next.org
	set -e; cd $(SOURCE_DIR)/neutrino-mp-cst-next; \
		$(call post_patch,$(NEUTRINO_MP_CST_NEXT_PATCHES))
	@touch $@

$(D)/neutrino-mp-cst-next.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR); \
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-cst-next/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-cst-next/configure --enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-iconsdir_var=/var/tuxbox/icons \
			--with-luaplugindir=/var/tuxbox/plugins \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-localedir_var=/var/tuxbox/locale \
			--with-plugindir=/var/tuxbox/plugins \
			--with-plugindir_var=/var/tuxbox/plugins \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-themesdir_var=/var/tuxbox/themes \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(SOURCE_DIR)/neutrino-mp-cst-next/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/libstb-hal-cst-next ; then \
		pushd $(SOURCE_DIR)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(SOURCE_DIR)/neutrino-mp-cst-next ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(BASE_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next.do_compile: $(D)/neutrino-mp-cst-next.config.status $(SOURCE_DIR)/neutrino-mp-cst-next/src/gui/version.h
	cd $(SOURCE_DIR)/neutrino-mp-cst-next; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

$(D)/neutrino-mp-cst-next: $(D)/neutrino-mp-cst-next.do_prepare $(D)/neutrino-mp-cst-next.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR); \
	rm -f $(TARGET_DIR)/var/etc/.version
	make $(TARGET_DIR)/var/etc/.version
	$(TOUCH)

mp-clean \
neutrino-mp-cst-next-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-mp-cst-next
	rm -f $(D)/neutrino-mp-cst-next.config.status
	rm -f $(SOURCE_DIR)/neutrino-mp-cst-next/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-mp-cst-next-distclean: neutrino-cdkroot-clean
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next*

################################################################################
#
# neutrino-mp-cst-next-ni
#
yaud-neutrino-mp-cst-next-ni: yaud-none \
		neutrino-mp-cst-next-ni $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-cst-next-ni-plugins: yaud-none \
		$(D)/neutrino-mp-cst-next-ni $(D)/neutrino-plugins $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

NEUTRINO_MP_CST_NEXT_NI_PATCHES =

$(D)/neutrino-mp-cst-next-ni.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-cst-next
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next-ni
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next-ni.org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/neutrino-mp-cst-next-ni.git" ] && \
	(cd $(ARCHIVE)/neutrino-mp-cst-next-ni.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/neutrino-mp-cst-next-ni.git" ] || \
	git clone -b ni https://github.com/Duckbox-Developers/neutrino-mp-cst-next.git $(ARCHIVE)/neutrino-mp-cst-next-ni.git; \
	cp -ra $(ARCHIVE)/neutrino-mp-cst-next-ni.git $(SOURCE_DIR)/neutrino-mp-cst-next-ni; \
	cp -ra $(SOURCE_DIR)/neutrino-mp-cst-next-ni $(SOURCE_DIR)/neutrino-mp-cst-next-ni.org
	set -e; cd $(SOURCE_DIR)/neutrino-mp-cst-next-ni; \
		$(call post_patch,$(NEUTRINO_MP_CST_NEXT_NI_PATCHES))
	@touch $@

$(D)/neutrino-mp-cst-next-ni.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR); \
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-cst-next-ni/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-cst-next-ni/configure --enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-iconsdir_var=/var/tuxbox/icons \
			--with-luaplugindir=/var/tuxbox/plugins \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-localedir_var=/var/tuxbox/locale \
			--with-plugindir=/var/tuxbox/plugins \
			--with-plugindir_var=/var/tuxbox/plugins \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-themesdir_var=/var/tuxbox/themes \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(SOURCE_DIR)/neutrino-mp-cst-next-ni/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/libstb-hal-cst-next ; then \
		pushd $(SOURCE_DIR)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(SOURCE_DIR)/neutrino-mp-cst-next-ni ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(BASE_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next-ni.do_compile: $(D)/neutrino-mp-cst-next-ni.config.status $(SOURCE_DIR)/neutrino-mp-cst-next-ni/src/gui/version.h
	cd $(SOURCE_DIR)/neutrino-mp-cst-next-ni; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

$(D)/neutrino-mp-cst-next-ni: $(D)/neutrino-mp-cst-next-ni.do_prepare $(D)/neutrino-mp-cst-next-ni.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR); \
	rm -f $(TARGET_DIR)/var/etc/.version
	make $(TARGET_DIR)/var/etc/.version
	$(TOUCH)

neutrino-mp-cst-next-ni-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-mp-cst-next-ni
	rm -f $(D)/neutrino-mp-cst-next-ni.config.status
	rm -f $(SOURCE_DIR)/neutrino-mp-cst-next-ni/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-ni-distclean: neutrino-cdkroot-clean
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next-ni*

################################################################################
neutrino-cdkroot-clean:
	[ -e $(TARGET_DIR)/usr/local/bin ] && cd $(TARGET_DIR)/usr/local/bin && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/local/share/iso-codes ] && cd $(TARGET_DIR)/usr/local/share/iso-codes && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/neutrino ] && cd $(TARGET_DIR)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/fonts ] && cd $(TARGET_DIR)/usr/share/fonts && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/var/tuxbox ] && cd $(TARGET_DIR)/var/tuxbox && find -name '*' -delete || true

dual:
	make nhd2
	make neutrino-cdkroot-clean
	make mp

dual-clean:
	make nhd2-clean
	make mp-clean

dual-distclean:
	make nhd2-distclean
	make mp-distclean

################################################################################
#
# yaud-neutrino-hd2
#
yaud-neutrino-hd2: yaud-none \
		$(D)/neutrino-hd2 $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

nhd2 \
yaud-neutrino-hd2-plugins: yaud-none \
		$(D)/neutrino-hd2 $(D)/neutrino-hd2-plugins $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

ifeq ($(BOXTYPE), spark)
NHD2_OPTS = --enable-4digits
else ifeq ($(BOXTYPE), spark7162)
NHD2_OPTS =
else
NHD2_OPTS = --enable-ci
endif

#
# neutrino-hd2
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2
	rm -rf $(SOURCE_DIR)/neutrino-hd2.org
	rm -rf $(SOURCE_DIR)/neutrino-hd2.git
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] && \
	(cd $(ARCHIVE)/neutrino-hd2.git; git pull;); \
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(ARCHIVE)/neutrino-hd2.git; \
	cp -ra $(ARCHIVE)/neutrino-hd2.git $(SOURCE_DIR)/neutrino-hd2.git; \
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2;\
	cp -ra $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2.org
	set -e; cd $(SOURCE_DIR)/neutrino-hd2; \
		$(call post_patch,$(NEUTRINO_HD2_PATCHES))
	@touch $@

$(SOURCE_DIR)/neutrino-hd2/config.status:
	cd $(SOURCE_DIR)/neutrino-hd2; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/local/share/iso-codes \
			$(NHD2_OPTS) \
			--enable-scart \
			--enable-silent-rules \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2.do_compile: $(SOURCE_DIR)/neutrino-hd2/config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) all
	@touch $@

$(D)/neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR); \
	rm -f $(TARGET_DIR)/var/etc/.version
	make $(TARGET_DIR)/var/etc/.version
	$(TOUCH)

nhd2-clean \
neutrino-hd2-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) clean

nhd2-distclean \
neutrino-hd2-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.do_compile
	rm -f $(D)/neutrino-hd2.do_prepare
	rm -f $(D)/neutrino-hd2-plugins*

################################################################################
#
# libstb-hal-cst-next-tangos
#
NEUTRINO_MP_LIBSTB_CST_NEXT_TANGOS_PATCHES =

$(D)/libstb-hal-cst-next-tangos.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next-tangos
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next-tangos.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(ARCHIVE)/libstb-hal-cst-next-tangos.git" ] && \
	(cd $(ARCHIVE)/libstb-hal-cst-next-tangos.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/libstb-hal-cst-next-tangos.git" ] || \
	git clone https://github.com/TangoCash/libstb-hal-cst-next.git $(ARCHIVE)/libstb-hal-cst-next-tangos.git; \
	cp -ra $(ARCHIVE)/libstb-hal-cst-next-tangos.git $(SOURCE_DIR)/libstb-hal-cst-next-tangos;\
	cp -ra $(SOURCE_DIR)/libstb-hal-cst-next-tangos $(SOURCE_DIR)/libstb-hal-cst-next-tangos.org
	set -e; cd $(SOURCE_DIR)/libstb-hal-cst-next-tangos; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES))
	@touch $@

$(D)/libstb-hal-cst-next-tangos.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR); \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR); \
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/libstb-hal-cst-next-tangos/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-cst-next-tangos/configure --enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-cst-next-tangos.do_compile: $(D)/libstb-hal-cst-next-tangos.config.status
	cd $(SOURCE_DIR)/libstb-hal-cst-next-tangos; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-cst-next-tangos: $(D)/libstb-hal-cst-next-tangos.do_prepare $(D)/libstb-hal-cst-next-tangos.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-cst-next-tangos-clean:
	rm -f $(D)/libstb-hal-cst-next-tangos
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-cst-next-tangos-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-cst-next-tangos*

################################################################################
#
# yaud-neutrino-mp-tangos
#
yaud-neutrino-mp-tangos: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-tangos-plugins: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/neutrino-plugins $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-tangos-all: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/neutrino-plugins $(D)/shairport $(D)/neutrino_release
	$(TUXBOX_YAUD_CUSTOMIZE)

#
# neutrino-mp-tangos
#
NEUTRINO_MP_TANGOS_PATCHES =

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-cst-next-tangos
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-mp-tangos
	rm -rf $(SOURCE_DIR)/neutrino-mp-tangos.org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/neutrino-mp-tangos.git" ] && \
	(cd $(ARCHIVE)/neutrino-mp-tangos.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/neutrino-mp-tangos.git" ] || \
	git clone https://github.com/TangoCash/neutrino-mp-cst-next.git $(ARCHIVE)/neutrino-mp-tangos.git; \
	cp -ra $(ARCHIVE)/neutrino-mp-tangos.git $(SOURCE_DIR)/neutrino-mp-tangos; \
	cp -ra $(SOURCE_DIR)/neutrino-mp-tangos $(SOURCE_DIR)/neutrino-mp-tangos.org
	set -e; cd $(SOURCE_DIR)/neutrino-mp-tangos; \
		$(call post_patch,$(NEUTRINO_MP_TANGOS_PATCHES))
	@touch $@

$(D)/neutrino-mp-tangos.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR); \
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-tangos/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-tangos/configure --enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--disable-upnp \
			--with-boxtype=$(BOXTYPE) \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-iconsdir_var=/var/tuxbox/icons \
			--with-luaplugindir=/var/tuxbox/plugins \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-localedir_var=/var/tuxbox/locale \
			--with-plugindir=/var/tuxbox/plugins \
			--with-plugindir_var=/var/tuxbox/plugins \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-themesdir_var=/var/tuxbox/themes \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-cst-next-tangos/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/libstb-hal-cst-next-tangos ; then \
		pushd $(SOURCE_DIR)/libstb-hal-cst-next-tangos ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(SOURCE_DIR)/neutrino-mp-tangos ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(BASE_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-tangos"' >> $@ ; \
	fi


$(D)/neutrino-mp-tangos.do_compile: $(D)/neutrino-mp-tangos.config.status $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	cd $(SOURCE_DIR)/neutrino-mp-tangos; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

$(D)/neutrino-mp-tangos: $(D)/neutrino-mp-tangos.do_prepare $(D)/neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR); \
	rm -f $(TARGET_DIR)/var/etc/.version
	make $(TARGET_DIR)/var/etc/.version
	$(TOUCH)

neutrino-mp-tangos-clean:
	rm -f $(D)/neutrino-mp-tangos
	rm -f $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-tangos*
