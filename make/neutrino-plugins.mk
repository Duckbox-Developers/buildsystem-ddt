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
BOXEVENT = spark
endif

$(D)/links: $(D)/bootstrap $(D)/libpng $(D)/openssl $(ARCHIVE)/links-$(LINKS-VER).tar.bz2
	$(REMOVE)/links-$(LINKS-VER)
	$(UNTAR)/links-$(LINKS-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/links-$(LINKS-VER); \
		$(PATCH)/links-$(LINKS-VER).patch; \
		export CC="$(TARGET)-gcc -D$(BOXEVENT)"; \
		export SYSROOT=$(TARGETPREFIX); \
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
		./configure  --enable-silent-rules \
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
			PKG_CONFIG=$(HOSTPREFIX)/bin/$(TARGET)-pkg-config \
			PKG_CONFIG_PATH=$(TARGETPREFIX)/usr/lib/pkgconfig \
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
# neutrino-hd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrino-hd2-plugins.do_prepare:
	rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	set -e; if [ -d $(ARCHIVE)/neutrino-hd2-plugins.git ]; \
		then cd $(ARCHIVE)/neutrino-hd2-plugins.git; git pull; \
		else cd $(ARCHIVE); git clone -b plugins https://github.com/mohousch/neutrinohd2.git neutrino-hd2-plugins.git; \
		fi
	cp -ra $(ARCHIVE)/neutrino-hd2-plugins.git $(SOURCE_DIR)/neutrino-hd2-plugins
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
			PKG_CONFIG=$(HOSTPREFIX)/bin/$(TARGET)-pkg-config \
			PKG_CONFIG_PATH=$(TARGETPREFIX)/usr/lib/pkgconfig \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGETPREFIX)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"

$(D)/neutrino-hd2-plugins.do_compile: $(SOURCE_DIR)/neutrino-hd2-plugins/config.status
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE)
	touch $@

$(D)/neutrino-hd2-plugins: neutrino-hd2-plugins.do_prepare neutrino-hd2-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins install DESTDIR=$(TARGETPREFIX)
#	touch $@

neutrino-hd2-plugins-clean:
	rm -f $(D)/neutrino-hd2-plugins
	cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
	$(MAKE) clean
	rm -f $(SOURCE_DIR)/neutrino-hd2-plugins/config.status

neutrino-hd2-plugins-distclean:
	rm -f $(D)/neutrino-hd2-plugins.do_prepare
	rm -f $(D)/neutrino-hd2-plugins.do_compile

