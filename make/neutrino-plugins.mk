#
# Makefile to build NEUTRINO-PLUGINS
#

#
# links
#
LINKS_VER = 2.7
LINKS_PATCH  = links-$(LINKS_VER).patch
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
LINKS_PATCH += links-$(LINKS_VER)-spark-input.patch
endif

$(ARCHIVE)/links-$(LINKS_VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS_VER).tar.bz2

$(D)/links: $(D)/bootstrap $(D)/libpng $(D)/openssl $(ARCHIVE)/links-$(LINKS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/links-$(LINKS_VER)
	$(UNTAR)/links-$(LINKS_VER).tar.bz2
	$(CHDIR)/links-$(LINKS_VER); \
		$(call apply_patches, $(LINKS_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--without-libtiff \
			--without-svgalib \
			--with-fb \
			--without-directfb \
			--without-pmshell \
			--without-atheos \
			--enable-graphics \
			--enable-javascript \
			--with-ssl=$(TARGET_DIR)/usr \
			--without-x \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/tuxbox/plugins $(TARGET_DIR)/var/tuxbox/config/links
	mv $(TARGET_DIR)/bin/links $(TARGET_DIR)/var/tuxbox/plugins/links.so
	echo "name=Links Web Browser"	 > $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGET_DIR)/var/tuxbox/config/bookmarks
	touch $(TARGET_DIR)/var/tuxbox/config/links/links.his
	cp -a $(SKEL_ROOT)/var/tuxbox/config/links/bookmarks.html $(SKEL_ROOT)/var/tuxbox/config/links/tables.tar.gz $(TARGET_DIR)/var/tuxbox/config/links
	$(REMOVE)/links-$(LINKS_VER)
	$(TOUCH)

#
# neutrino-mp-plugins
#
NEUTRINO_PLUGINS  = $(D)/neutrino-mp-plugin
NEUTRINO_PLUGINS += $(D)/neutrino-mp-plugin-scripts-lua
NEUTRINO_PLUGINS += $(D)/neutrino-mp-plugin-mediathek
NEUTRINO_PLUGINS += $(D)/neutrino-mp-plugin-xupnpd
NEUTRINO_PLUGINS += $(LOCAL_NEUTRINO_PLUGINS)

NP_OBJDIR = $(BUILD_TMP)/neutrino-mp-plugins

ifeq ($(BOXARCH), sh4)
EXTRA_CPPFLAGS_MP_PLUGINS = -DMARTII
endif

$(D)/neutrino-mp-plugin.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-mp-plugins
	rm -rf $(SOURCE_DIR)/neutrino-mp-plugins.org
	set -e; if [ -d $(ARCHIVE)/neutrino-mp-plugins.git ]; \
		then cd $(ARCHIVE)/neutrino-mp-plugins.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/neutrino-mp-plugins.git neutrino-mp-plugins.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-mp-plugins.git $(SOURCE_DIR)/neutrino-mp-plugins
ifeq ($(BOXARCH), arm)
	sed -i -e 's#shellexec fx2#shellexec stb-startup#g' $(SOURCE_DIR)/neutrino-mp-plugins/Makefile.am
endif
	cp -ra $(SOURCE_DIR)/neutrino-mp-plugins $(SOURCE_DIR)/neutrino-mp-plugins.org
	@touch $@

$(D)/neutrino-mp-plugin.config.status: $(D)/bootstrap
	rm -rf $(NP_OBJDIR); \
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR); \
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-plugins/autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-plugins/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-silent-rules \
			--with-target=cdk \
			--include=/usr/include \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) $(EXTRA_CPPFLAGS_MP_PLUGINS) -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(NP_OBJDIR)/fx2/lib/.libs"
	@touch $@

$(D)/neutrino-mp-plugin.do_compile: $(D)/neutrino-mp-plugin.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-mp-plugin: $(D)/neutrino-mp-plugin.do_prepare $(D)/neutrino-mp-plugin.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-mp-plugin-clean:
	rm -f $(D)/neutrino-mp-plugins
	rm -f $(D)/neutrino-mp-plugin
	rm -f $(D)/neutrino-mp-plugin.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-mp-plugin-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-mp-plugin*

#
# xupnpd
#
XUPNPD_PATCH = xupnpd.patch

$(D)/xupnpd \
$(D)/neutrino-mp-plugin-xupnpd: $(D)/bootstrap $(D)/lua $(D)/openssl $(D)/neutrino-mp-plugin-scripts-lua
	$(START_BUILD)
	$(REMOVE)/xupnpd
	set -e; if [ -d $(ARCHIVE)/xupnpd.git ]; \
		then cd $(ARCHIVE)/xupnpd.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/clark15b/xupnpd.git xupnpd.git; \
		fi
	cp -ra $(ARCHIVE)/xupnpd.git $(BUILD_TMP)/xupnpd
	$(CHDIR)/xupnpd; \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/xupnpd/src; \
		$(BUILDENV) \
		$(MAKE) embedded TARGET=$(TARGET) PKG_CONFIG=$(PKG_CONFIG) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/xupnpd $(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_DIR)/usr/share/xupnpd/config
	rm $(TARGET_DIR)/usr/share/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_18plus.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_cczwei.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	: install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_coolstream.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_youtube.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(REMOVE)/xupnpd
	$(TOUCH)

#
# neutrino-plugin-scripts-lua
#
$(D)/neutrino-mp-plugin-scripts-lua: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/neutrino-mp-plugin-scripts-lua
	set -e; if [ -d $(ARCHIVE)/plugin-scripts-lua.git ]; \
		then cd $(ARCHIVE)/plugin-scripts-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/plugin-scripts-lua.git plugin-scripts-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugin-scripts-lua.git/plugins $(BUILD_TMP)/neutrino-mp-plugin-scripts-lua
	$(CHDIR)/neutrino-mp-plugin-scripts-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/neutrino-mp-plugin-scripts-lua/ard_mediathek/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-mp-plugin-scripts-lua/mtv/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-mp-plugin-scripts-lua/netzkino/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/neutrino-mp-plugin-scripts-lua
	$(TOUCH)

#
# neutrino-mediathek
#
NEUTRINO_MEDIATHEK_PATCH = neutrino-mediathek.patch

$(D)/neutrino-mp-plugin-mediathek:
	$(START_BUILD)
	$(REMOVE)/plugins-mediathek
	set -e; if [ -d $(ARCHIVE)/plugins-mediathek.git ]; \
		then cd $(ARCHIVE)/plugins-mediathek.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/neutrino-mediathek/mediathek.git plugins-mediathek.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-mediathek.git $(BUILD_TMP)/plugins-mediathek
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CHDIR)/plugins-mediathek; \
		$(call apply_patches, $(NEUTRINO_MEDIATHEK_PATCH))
	$(CHDIR)/plugins-mediathek; \
		cp -a plugins/* $(TARGET_DIR)/var/tuxbox/plugins/; \
		cp -a share $(TARGET_DIR)/usr/
	$(REMOVE)/plugins-mediathek
	$(TOUCH)

#
# neutrino-iptvplayer
#
$(D)/neutrino-mp-plugin-iptvplayer-nightly \
$(D)/neutrino-mp-plugin-iptvplayer: $(D)/librtmp $(D)/python_twisted_small
	$(START_BUILD)
	$(REMOVE)/iptvplayer
	set -e; if [ -d $(ARCHIVE)/iptvplayer.git ]; \
		then cd $(ARCHIVE)/iptvplayer.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/crossplatform_iptvplayer.git iptvplayer.git; \
		fi
	cp -ra $(ARCHIVE)/iptvplayer.git $(BUILD_TMP)/iptvplayer
	@if [ "$@" = "$(D)/neutrino-mp-plugin-iptvplayer-nightly" ]; then \
		$(BUILD_TMP)/iptvplayer/SyncWithGitLab.sh $(BUILD_TMP)/iptvplayer; \
	fi
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	install -d $(TARGET_DIR)/usr/share/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/E2emulator/* $(TARGET_DIR)/usr/share/E2emulator/
	install -d $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer
	cp -R $(BUILD_TMP)/iptvplayer/IPTVplayer/* $(TARGET_DIR)/usr/share/E2emulator//Plugins/Extensions/IPTVPlayer/
	cp -R $(BUILD_TMP)/iptvplayer/IPTVdaemon/* $(TARGET_DIR)/usr/share/E2emulator//Plugins/Extensions/IPTVPlayer/
	chmod 755 $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/cmdlineIPTV.*
	chmod 755 $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/IPTVdaemon.*
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON_DIR) \
	$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) -Wi -t -O $(TARGET_DIR)/$(PYTHON_DIR)/compileall.py \
		-d /usr/share/E2emulator -f -x badsyntax $(TARGET_DIR)/usr/share/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/addon4neutrino/neutrinoIPTV/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/iptvplayer
	$(TOUCH)

#
# neutrino-hd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrino-hd2-plugins.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/plugins $(SOURCE_DIR)/neutrino-hd2-plugins
	set -e; cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		$(call apply_patches, $(NEUTRINO_HD2_PLUGINS_PATCHES))
	@touch $@

$(D)/neutrino-hd2-plugins.config.status: $(D)/bootstrap neutrino-hd2
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--enable-silent-rules \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGET_DIR)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2-plugins.do_compile: $(D)/neutrino-hd2-plugins.config.status
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	@touch $@

$(D)/neutrino-hd2-plugins.build: neutrino-hd2-plugins.do_prepare neutrino-hd2-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins install DESTDIR=$(TARGET_DIR) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	$(TOUCH)

neutrino-hd2-plugins-clean:
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) clean
	rm -f $(D)/neutrino-hd2-plugins.build
	rm -f $(D)/neutrino-hd2-plugins.config.status

neutrino-hd2-plugins-distclean:
	rm -f $(D)/neutrino-hd2-plugins.build
	rm -f $(D)/neutrino-hd2-plugins.config.status
	rm -f $(D)/neutrino-hd2-plugins.do_prepare
	rm -f $(D)/neutrino-hd2-plugins.do_compile
