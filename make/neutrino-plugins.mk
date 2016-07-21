#
# Makefile to build NEUTRINO-PLUGINS
#

#
# links
#
LINKS-VER = 2.7

$(ARCHIVE)/links-$(LINKS-VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS-VER).tar.bz2

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
BOXEVENT = $(PATCH)/links-2.7-spark-input.patch;
endif

$(D)/links: $(D)/bootstrap $(D)/libpng $(D)/openssl $(ARCHIVE)/links-$(LINKS-VER).tar.bz2
	$(REMOVE)/links-$(LINKS-VER)
	$(UNTAR)/links-$(LINKS-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/links-$(LINKS-VER); \
		$(PATCH)/links-$(LINKS-VER).patch; \
		$(BOXEVENT) \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--mandir=/.remove \
			--without-svgalib \
			--without-x \
			--without-libtiff \
			--enable-graphics \
			--enable-javascript \
			--with-ssl; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/var/tuxbox/plugins $(TARGETPREFIX)/var/tuxbox/config/links
	mv $(TARGETPREFIX)/bin/links $(TARGETPREFIX)/var/tuxbox/plugins/links.so
	echo "name=Links Web Browser"	 > $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "needfb=1"			>> $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "needrc=1"			>> $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "needoffsets=1"		>> $(TARGETPREFIX)/var/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGETPREFIX)/var/tuxbox/config/bookmarks
	touch $(TARGETPREFIX)/var/tuxbox/config/links/links.his
	cp -a $(SKEL_ROOT)/var/tuxbox/config/links/bookmarks.html $(SKEL_ROOT)/var/tuxbox/config/links/tables.tar.gz $(TARGETPREFIX)/var/tuxbox/config/links
	$(REMOVE)/links-$(LINKS-VER)
	touch $@

#
# neutrino-mp plugins
#
$(D)/neutrino-mp-plugins.do_prepare:
	rm -rf $(SOURCE_DIR)/neutrino-mp-plugins
	set -e; if [ -d $(ARCHIVE)/neutrino-mp-plugins-max.git ]; \
		then cd $(ARCHIVE)/neutrino-mp-plugins-max.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/MaxWiesel/neutrino-mp-plugins-max.git neutrino-mp-plugins-max.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-mp-plugins-max.git $(SOURCE_DIR)/neutrino-mp-plugins
	touch $@

$(SOURCE_DIR)/neutrino-mp-plugins/config.status: $(D)/bootstrap $(D)/xupnpd
	cd $(SOURCE_DIR)/neutrino-mp-plugins; \
		./autogen.sh && automake --add-missing; \
		$(BUILDENV) \
		./configure --enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--oldinclude=$(TARGETPREFIX)/include \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) -DMARTII -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(SOURCE_DIR)/neutrino-mp-plugins/fx2/lib/.libs"

$(D)/neutrino-mp-plugins.do_compile: $(SOURCE_DIR)/neutrino-mp-plugins/config.status
	cd $(SOURCE_DIR)/neutrino-mp-plugins; \
		$(MAKE)
	touch $@

$(D)/neutrino-mp-plugins: neutrino-mp-plugins.do_prepare neutrino-mp-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-mp-plugins install DESTDIR=$(TARGETPREFIX)
#	touch $@

neutrino-mp-plugins-clean:
	rm -f $(D)/neutrino-mp-plugins
	cd $(SOURCE_DIR)/neutrino-mp-plugins; \
		$(MAKE) clean

neutrino-mp-plugins-distclean:
	rm -f $(D)/neutrino-mp-plugins.do_prepare
	rm -f $(D)/neutrino-mp-plugins.do_compile

#
# xupnpd
#
$(D)/xupnpd: $(D)/bootstrap $(D)/plugins-scripts-lua
	$(REMOVE)/xupnpd
	set -e; if [ -d $(ARCHIVE)/xupnpd.git ]; \
		then cd $(ARCHIVE)/xupnpd.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/clark15b/xupnpd.git xupnpd.git; \
		fi
	cp -ra $(ARCHIVE)/xupnpd.git $(BUILD_TMP)/xupnpd
	set -e; cd $(BUILD_TMP)/xupnpd && $(PATCH)/xupnpd.patch
	set -e; cd $(BUILD_TMP)/xupnpd/src; \
		$(BUILDENV) \
		$(MAKE) TARGET=$(TARGET) sh4; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -m 755 $(SKEL_ROOT)/etc/init.d/xupnpd $(TARGETPREFIX)/etc/init.d/
	install -m 644 $(ARCHIVE)/cst-public-plugins-scripts-lua.git/xupnpd/xupnpd_18plus.lua ${TARGETPREFIX}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/cst-public-plugins-scripts-lua.git/xupnpd/xupnpd_cczwei.lua ${TARGETPREFIX}/usr/share/xupnpd/plugins/
	: install -m 644 $(ARCHIVE)/cst-public-plugins-scripts-lua.git/xupnpd/xupnpd_coolstream.lua ${TARGETPREFIX}/usr/share/xupnpd/plugins/
	install -m 644 $(ARCHIVE)/cst-public-plugins-scripts-lua.git/xupnpd/xupnpd_youtube.lua ${TARGETPREFIX}/usr/share/xupnpd/plugins/
	$(REMOVE)/xupnpd
	touch $@

#
# plugins-scripts-lua
#
$(D)/plugins-scripts-lua: $(D)/bootstrap $(D)/xupnpd
	$(REMOVE)/plugins-scripts-lua
	set -e; if [ -d $(ARCHIVE)/cst-public-plugins-scripts-lua.git ]; \
		then cd $(ARCHIVE)/cst-public-plugins-scripts-lua.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/coolstreamtech/cst-public-plugins-scripts-lua.git cst-public-plugins-scripts-lua.git; \
		fi
	cp -ra $(ARCHIVE)/cst-public-plugins-scripts-lua.git/plugins $(BUILD_TMP)/plugins-scripts-lua
	set -e; cd $(BUILD_TMP)/plugins-scripts-lua; \
		install -d $(TARGETPREFIX)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-scripts-lua/ard_mediathek/* $(TARGETPREFIX)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-scripts-lua/favorites2bin/* $(TARGETPREFIX)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-scripts-lua/mtv/* $(TARGETPREFIX)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/plugins-scripts-lua/netzkino/* $(TARGETPREFIX)/var/tuxbox/plugins/
	$(REMOVE)/plugins-scripts-lua
	touch $@

#
# neutrino-hd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrino-hd2-plugins.do_prepare:
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/plugins $(SOURCE_DIR)/neutrino-hd2-plugins
	cd $(SOURCE_DIR)/neutrino-hd2-plugins && find ./ -name "Makefile.am" -exec sed -i -e "s/\/..\/nhd2-exp//g" {} \;
	cd $(SOURCE_DIR)/neutrino-hd2.git && git add --all
	for i in $(NEUTRINO_HD2_PLUGINS_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(SOURCE_DIR)/neutrino-hd2-plugins && patch -p1 -i $$i; \
	done;
	touch $@

$(SOURCE_DIR)/neutrino-hd2-plugins/config.status: $(D)/bootstrap neutrino-hd2
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGETPREFIX)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"

$(D)/neutrino-hd2-plugins.do_compile: $(SOURCE_DIR)/neutrino-hd2-plugins/config.status
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	touch $@

$(D)/neutrino-hd2-plugins: neutrino-hd2-plugins.do_prepare neutrino-hd2-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins install DESTDIR=$(TARGETPREFIX) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
#	touch $@

neutrino-hd2-plugins-clean:
	rm -f $(D)/neutrino-hd2-plugins
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) clean
	rm -f $(SOURCE_DIR)/neutrino-hd2-plugins/config.status

neutrino-hd2-plugins-distclean: neutrino-hd2-plugins-clean
	rm -f $(D)/neutrino-hd2-plugins.do_prepare
	rm -f $(D)/neutrino-hd2-plugins.do_compile

