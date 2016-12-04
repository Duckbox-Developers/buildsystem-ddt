#
# Makefile to build NEUTRINO
#
$(TARGETPREFIX)/var/etc/.version:
	echo "imagename=Neutrino MP" > $@
	echo "homepage=https://github.com/Duckbox-Developers" >> $@
	echo "creator=`id -un`" >> $@
	echo "docs=https://github.com/Duckbox-Developers" >> $@
	echo "forum=https://github.com/Duckbox-Developers/neutrino-mp-cst-next" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git describe`" >> $@

NEUTRINO_DEPS  = $(D)/bootstrap $(D)/libncurses $(D)/lirc $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng $(D)/libjpeg $(D)/libgif $(D)/libfreetype
NEUTRINO_DEPS += $(D)/alsa-utils $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libfribidi  $(D)/libsigc++ $(D)/libdvbsi++ $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml $(D)/libopenthreads
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/lua-feedparser $(D)/luasoap $(D)/luajson
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/libflac

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os -fno-strict-aliasing
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(TARGETPREFIX)/usr/include
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
N_CPPFLAGS    += -D__STDC_CONSTANT_MACROS

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-lua
N_CONFIG_OPTS += --enable-giflib
N_CONFIG_OPTS += --enable-ffmpegdec
#N_CONFIG_OPTS += --enable-pip
N_CONFIG_OPTS += --enable-pugixml

ifeq ($(EXTERNAL_LCD), externallcd)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
NEUTRINO_DEPS += $(D)/lcd4linux
endif

OBJDIR = $(BUILD_TMP)
N_OBJDIR = $(OBJDIR)/neutrino-mp
LH_OBJDIR = $(OBJDIR)/libstb-hal

################################################################################
#
# libstb-hal-cst-next-max
#
NEUTRINO_MP_LIBSTB_CST_NEXT_MAX_PATCHES =

$(D)/libstb-hal-cst-next-max.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next-max
	rm -rf $(SOURCE_DIR)/libstb-hal-cst-next-max.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(ARCHIVE)/libstb-hal-cst-next-max.git" ] && \
	(cd $(ARCHIVE)/libstb-hal-cst-next-max.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/libstb-hal-cst-next-max.git" ] || \
	git clone git://github.com/MaxWiesel/libstb-hal-cst-next-max.git $(ARCHIVE)/libstb-hal-cst-next-max.git; \
	cp -ra $(ARCHIVE)/libstb-hal-cst-next-max.git $(SOURCE_DIR)/libstb-hal-cst-next-max;\
	cp -ra $(SOURCE_DIR)/libstb-hal-cst-next-max $(SOURCE_DIR)/libstb-hal-cst-next-max.org
	set -e; cd $(SOURCE_DIR)/libstb-hal-cst-next-max; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_CST_NEXT_MAX_PATCHES))
	$(TOUCH)

$(D)/libstb-hal-cst-next-max.config.status: | $(NEUTRINO_DEPS)
	$(START_BUILD)
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR); \
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/libstb-hal-cst-next-max/autogen.sh; \
		export PKG_CONFIG=$(PKG_CONFIG); \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-cst-next-max/configure --enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-cst-next-max.do_compile: $(D)/libstb-hal-cst-next-max.config.status
	$(START_BUILD)
	cd $(SOURCE_DIR)/libstb-hal-cst-next-max; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

$(D)/libstb-hal-cst-next-max: $(D)/libstb-hal-cst-next-max.do_prepare $(D)/libstb-hal-cst-next-max.do_compile
	$(START_BUILD)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

libstb-hal-cst-next-max-clean:
	rm -f $(D)/libstb-hal-cst-next-max
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-cst-next-max-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-cst-next-max*

################################################################################
#
# neutrino-mp-cst-next-max
#
NEUTRINO_MP_CST_NEXT_MAX_PATCHES =

yaud-neutrino-mp-cst-next-max: yaud-none \
		$(D)/neutrino-mp-cst-next-max $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-cst-next-max-plugins: yaud-none \
		$(D)/neutrino-mp-cst-next-max $(D)/neutrino-mp-plugins $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

$(D)/neutrino-mp-cst-next-max.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-cst-next-max
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next-max
	rm -rf $(SOURCE_DIR)/neutrino-mp-cst-next-max.org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/cst-public-gui-neutrino-max.git" ] && \
	(cd $(ARCHIVE)/cst-public-gui-neutrino-max.git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/cst-public-gui-neutrino-max.git" ] || \
	git clone -b duckbox git://github.com/MaxWiesel/cst-public-gui-neutrino.git $(ARCHIVE)/cst-public-gui-neutrino-max.git; \
	cp -ra $(ARCHIVE)/cst-public-gui-neutrino-max.git $(SOURCE_DIR)/neutrino-mp-cst-next-max; \
	cp -ra $(SOURCE_DIR)/neutrino-mp-cst-next-max $(SOURCE_DIR)/neutrino-mp-cst-next-max.org
	set -e; cd $(SOURCE_DIR)/neutrino-mp-cst-next-max; \
		$(call post_patch,$(NEUTRINO_MP_CST_NEXT_MAX_PATCHES))
	$(TOUCH)

$(D)/neutrino-mp-cst-next-max.config.status:
	$(START_BUILD)
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR); \
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-cst-next-max/autogen.sh; \
		export PKG_CONFIG=$(PKG_CONFIG); \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-cst-next-max/configure --enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
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
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-cst-next-max/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(SOURCE_DIR)/neutrino-mp-cst-next-max/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/libstb-hal-cst-next-max ; then \
		pushd $(SOURCE_DIR)/libstb-hal-cst-next-max ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(SOURCE_DIR)/neutrino-mp-cst-next-max ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(CDK_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next-max.do_compile: $(D)/neutrino-mp-cst-next-max.config.status $(SOURCE_DIR)/neutrino-mp-cst-next-max/src/gui/version.h
	$(START_BUILD)
	cd $(SOURCE_DIR)/neutrino-mp-cst-next-max; \
		$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

$(D)/neutrino-mp-cst-next-max: $(D)/neutrino-mp-cst-next-max.do_prepare $(D)/neutrino-mp-cst-next-max.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX); \
	rm -f $(TARGETPREFIX)/var/etc/.version
	make $(TARGETPREFIX)/var/etc/.version
	$(TOUCH)

neutrino-mp-cst-next-max-clean:
	rm -f $(D)/neutrino-mp-cst-next-max
	rm -f $(SOURCE_DIR)/neutrino-mp-cst-next-max/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-max-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next-max*

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
	$(TOUCH)

$(D)/libstb-hal-cst-next.config.status: | $(NEUTRINO_DEPS)
	$(START_BUILD)
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
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-cst-next.do_compile: $(D)/libstb-hal-cst-next.config.status
	$(START_BUILD)
	cd $(SOURCE_DIR)/libstb-hal-cst-next; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

$(D)/libstb-hal-cst-next: $(D)/libstb-hal-cst-next.do_prepare $(D)/libstb-hal-cst-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

libstb-hal-cst-next-clean:
	rm -f $(D)/libstb-hal-cst-next
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
		neutrino-mp-cst-next $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-cst-next-plugins: yaud-none \
		$(D)/neutrino-mp-cst-next $(D)/neutrino-mp-plugins $(D)/release_neutrino
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
	$(TOUCH)

$(D)/neutrino-mp-cst-next.config.status:
	$(START_BUILD)
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
		pushd $(CDK_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next.do_compile: $(D)/neutrino-mp-cst-next.config.status $(SOURCE_DIR)/neutrino-mp-cst-next/src/gui/version.h
	$(START_BUILD)
	cd $(SOURCE_DIR)/neutrino-mp-cst-next; \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-cst-next: $(D)/neutrino-mp-cst-next.do_prepare $(D)/neutrino-mp-cst-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX); \
	rm -f $(TARGETPREFIX)/var/etc/.version
	make $(TARGETPREFIX)/var/etc/.version
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/neutrino
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/pzapit
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/sectionsdcontrol
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-cst-next-clean:
	rm -f $(D)/neutrino-mp-cst-next
	rm -f $(SOURCE_DIR)/neutrino-mp-cst-next/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next*

################################################################################
#
# neutrino-mp-cst-next
#
yaud-neutrino-mp-cst-next-ni: yaud-none \
		neutrino-mp-cst-next-ni $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-cst-next-ni-plugins: yaud-none \
		$(D)/neutrino-mp-cst-next-ni $(D)/neutrino-mp-plugins $(D)/release_neutrino
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
	$(TOUCH)

$(D)/neutrino-mp-cst-next-ni.config.status:
	$(START_BUILD)
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
		pushd $(CDK_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next-ni.do_compile: $(D)/neutrino-mp-cst-next-ni.config.status $(SOURCE_DIR)/neutrino-mp-cst-next-ni/src/gui/version.h
	$(START_BUILD)
	cd $(SOURCE_DIR)/neutrino-mp-cst-next-ni; \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-cst-next-ni: $(D)/neutrino-mp-cst-next-ni.do_prepare $(D)/neutrino-mp-cst-next-ni.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX); \
	rm -f $(TARGETPREFIX)/var/etc/.version
	make $(TARGETPREFIX)/var/etc/.version
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/neutrino
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/pzapit
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/sectionsdcontrol
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-cst-next-ni-clean:
	rm -f $(D)/neutrino-mp-cst-next-ni
	rm -f $(SOURCE_DIR)/neutrino-mp-cst-next-ni/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-ni-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next-ni*

################################################################################
neutrino-cdkroot-clean:
	[ -e $(TARGETPREFIX)/usr/local/bin ] && cd $(TARGETPREFIX)/usr/local/bin && find -name '*' -delete || true
	[ -e $(TARGETPREFIX)/usr/local/share/iso-codes ] && cd $(TARGETPREFIX)/usr/local/share/iso-codes && find -name '*' -delete || true
	[ -e $(TARGETPREFIX)/usr/share/tuxbox/neutrino ] && cd $(TARGETPREFIX)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(TARGETPREFIX)/usr/share/fonts ] && cd $(TARGETPREFIX)/usr/share/fonts && find -name '*' -delete || true
	[ -e $(TARGETPREFIX)/var/tuxbox ] && cd $(TARGETPREFIX)/var/tuxbox && find -name '*' -delete || true
################################################################################
#
# yaud-neutrino-hd2
#
yaud-neutrino-hd2: yaud-none \
		$(D)/neutrino-hd2 $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-hd2-plugins: yaud-none \
		$(D)/neutrino-hd2 $(D)/neutrino-hd2-plugins $(D)/release_neutrino
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
	$(TOUCH)

$(SOURCE_DIR)/neutrino-hd2/config.status:
	$(START_BUILD)
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
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	$(TOUCH)

$(D)/neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGETPREFIX); \
	rm -f $(TARGETPREFIX)/var/etc/.version
	make $(TARGETPREFIX)/var/etc/.version
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/neutrino
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/pzapit
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/sectionsdcontrol
	$(TOUCH)

$(D)/neutrino-hd2.do_compile: $(SOURCE_DIR)/neutrino-hd2/config.status
	$(START_BUILD)
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) all
	$(TOUCH)

neutrino-hd2-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) clean

neutrino-hd2-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.do_compile
	rm -f $(D)/neutrino-hd2.do_prepare
	rm -f $(D)/neutrino-hd2-plugins*

################################################################################
#
# yaud-neutrino-mp-tangos
#
yaud-neutrino-mp-tangos: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-tangos-plugins: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/neutrino-mp-plugins $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

yaud-neutrino-mp-tangos-all: yaud-none \
		$(D)/neutrino-mp-tangos $(D)/neutrino-mp-plugins shairport $(D)/release_neutrino
	$(TUXBOX_YAUD_CUSTOMIZE)

#
# neutrino-mp-tangos
#
NEUTRINO_MP_TANGOS_PATCHES =

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-cst-next
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
	$(TOUCH)

$(D)/neutrino-mp-tangos.config.status:
	$(START_BUILD)
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
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)"

$(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/libstb-hal-cst-next ; then \
		pushd $(SOURCE_DIR)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(SOURCE_DIR)/neutrino-mp-tangos ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(CDK_DIR) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-tangos"' >> $@ ; \
	fi


$(D)/neutrino-mp-tangos.do_compile: $(D)/neutrino-mp-tangos.config.status $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	$(START_BUILD)
	cd $(SOURCE_DIR)/neutrino-mp-tangos; \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-tangos: $(D)/neutrino-mp-tangos.do_prepare $(D)/neutrino-mp-tangos.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX); \
	rm -f $(TARGETPREFIX)/var/etc/.version
	make $(TARGETPREFIX)/var/etc/.version
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/neutrino
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/pzapit
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/sectionsdcontrol
	$(TARGET)-strip $(TARGETPREFIX)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-tangos-clean:
	rm -f $(D)/neutrino-mp-tangos
	rm -f $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-tangos*
