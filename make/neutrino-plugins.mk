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
	$(DOWNLOAD) http://links.twibright.com/download/links-$(LINKS_VER).tar.bz2

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
# neutrino-plugins
#
NEUTRINO_PLUGINS  = $(D)/neutrino-plugin
NEUTRINO_PLUGINS += $(D)/neutrino-plugin-scripts-lua
NEUTRINO_PLUGINS += $(D)/neutrino-plugin-mediathek
NEUTRINO_PLUGINS += $(D)/neutrino-plugin-xupnpd
#NEUTRINO_PLUGINS += $(D)/neutrino-plugin-settings-update
NEUTRINO_PLUGINS += $(LOCAL_NEUTRINO_PLUGINS)
NMPP_PATCHES  = $(NEUTRINO_PLUGINS_PATCHES)

NP_OBJDIR = $(BUILD_TMP)/neutrino-plugins

ifeq ($(BOXARCH), sh4)
EXTRA_CPPFLAGS_MP_PLUGINS = -DMARTII
endif

$(D)/neutrino-plugin.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-plugins
	rm -rf $(SOURCE_DIR)/neutrino-plugins.org
	set -e; if [ -d $(ARCHIVE)/neutrino-plugins.git ]; \
		then cd $(ARCHIVE)/neutrino-plugins.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/neutrino-ddt-plugins.git neutrino-plugins.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-plugins.git $(SOURCE_DIR)/neutrino-plugins
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
	sed -i -e 's#shellexec fx2#shellexec#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
endif
	cp -ra $(SOURCE_DIR)/neutrino-plugins $(SOURCE_DIR)/neutrino-plugins.org
	set -e; cd $(SOURCE_DIR)/neutrino-plugins; \
		$(call apply_patches, $(NMPP_PATCHES))
	@touch $@

$(D)/neutrino-plugin.config.status: $(D)/bootstrap
	rm -rf $(NP_OBJDIR); \
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR); \
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/neutrino-plugins/autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-plugins/configure $(SILENT_OPT) \
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

$(D)/neutrino-plugin.do_compile: $(D)/neutrino-plugin.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-plugin: $(D)/neutrino-plugin.do_prepare $(D)/neutrino-plugin.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-plugin-clean:
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugin
	rm -f $(D)/neutrino-plugin.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-plugin-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-plugin*

#
# xupnpd
#
XUPNPD_BRANCH = 25d6d44c045
XUPNPD_PATCH = xupnpd.patch

$(D)/xupnpd \
$(D)/neutrino-plugin-xupnpd: $(D)/bootstrap $(D)/lua $(D)/openssl $(D)/neutrino-plugin-scripts-lua
	$(START_BUILD)
	$(REMOVE)/xupnpd
	set -e; if [ -d $(ARCHIVE)/xupnpd.git ]; \
		then cd $(ARCHIVE)/xupnpd.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/clark15b/xupnpd.git xupnpd.git; \
		fi
	cp -ra $(ARCHIVE)/xupnpd.git $(BUILD_TMP)/xupnpd
	($(CHDIR)/xupnpd; git checkout -q $(XUPNPD_BRANCH);)
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
$(D)/neutrino-plugin-scripts-lua: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/neutrino-plugin-scripts-lua
	set -e; if [ -d $(ARCHIVE)/plugin-scripts-lua.git ]; \
		then cd $(ARCHIVE)/plugin-scripts-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/plugin-scripts-lua.git plugin-scripts-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugin-scripts-lua.git/plugins $(BUILD_TMP)/neutrino-plugin-scripts-lua
	$(CHDIR)/neutrino-plugin-scripts-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
#		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/favorites2bin/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/ard_mediathek/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/mtv/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/netzkino/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/neutrino-plugin-scripts-lua
	$(TOUCH)
#
# neutrino-mediathek
#
$(D)/neutrino-plugin-mediathek:
	$(START_BUILD)
	$(REMOVE)/plugins-mediathek
	set -e; if [ -d $(ARCHIVE)/plugins-mediathek.git ]; \
		then cd $(ARCHIVE)/plugins-mediathek.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/mediathek.git plugins-mediathek.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-mediathek.git $(BUILD_TMP)/plugins-mediathek
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CHDIR)/plugins-mediathek; \
		cp -a plugins/* $(TARGET_DIR)/var/tuxbox/plugins/; \
#		cp -a share $(TARGET_DIR)/usr/
		rm -f $(TARGET_DIR)/var/tuxbox/plugins/neutrino-mediathek/livestream.lua
	$(REMOVE)/plugins-mediathek
	$(TOUCH)

#
# neutrino-iptvplayer
#
$(D)/neutrino-plugin-iptvplayer-nightly \
$(D)/neutrino-plugin-iptvplayer: $(D)/librtmp $(D)/python_twisted_small
	$(START_BUILD)
	$(REMOVE)/iptvplayer
	set -e; if [ -d $(ARCHIVE)/iptvplayer.git ]; \
		then cd $(ARCHIVE)/iptvplayer.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/crossplatform_iptvplayer.git iptvplayer.git; \
		fi
	cp -ra $(ARCHIVE)/iptvplayer.git $(BUILD_TMP)/iptvplayer
	@if [ "$@" = "$(D)/neutrino-plugin-iptvplayer-nightly" ]; then \
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
# annie's settingsupdater
#
$(D)/neutrino-plugin-settings-update:
	$(START_BUILD)
	$(REMOVE)/settings-update
	set -e; if [ -d $(ARCHIVE)/settings-update.git ]; \
		then cd $(ARCHIVE)/settings-update.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/horsti58/lua-data.git settings-update.git; \
		fi
	cp -ra $(ARCHIVE)/settings-update.git $(BUILD_TMP)/settings-update
	cp -R $(BUILD_TMP)/settings-update/lua/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/settings-update
	$(TOUCH)

#
# spiegel
#
$(D)/spiegel:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/spiegel/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -rf $(TARGET_DIR)/var/tuxbox/plugins/SpiegelTV.png
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# tierwelt
#
$(D)/tierwelt:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/tierwelt/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -rf $(TARGET_DIR)/var/tuxbox/plugins/Tierwelt\ TV.png
	$(REMOVE)/plugins-lua
	$(TOUCH)
