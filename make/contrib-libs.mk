#
# ncurses
#
NCURSES_VER = 5.9
NCURSES_SOURCE = ncurses-$(NCURSES_VER).tar.gz

$(ARCHIVE)/$(NCURSES_SOURCE):
	$(WGET) https://ftp.gnu.org/pub/gnu/ncurses/$(NCURSES_SOURCE)

$(D)/ncurses: $(D)/bootstrap $(ARCHIVE)/$(NCURSES_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ncurses-$(NCURSES_VER)
	$(UNTAR)/$(NCURSES_SOURCE)
	set -e; cd $(BUILD_TMP)/ncurses-$(NCURSES_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--with-terminfo-dirs=/usr/share/terminfo \
			--with-pkg-config=/usr/lib/pkgconfig \
			--with-shared \
			--without-cxx \
			--without-cxx-binding \
			--without-ada \
			--without-progs \
			--without-tests \
			--disable-big-core \
			--without-profile \
			--disable-rpath \
			--disable-rpath-hack \
			--enable-echo \
			--enable-const \
			--enable-overwrite \
			--enable-pc-files \
			--without-manpages \
			--with-fallbacks='linux vt100 xterm' \
		; \
		$(MAKE) libs \
			HOSTCC=gcc \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)"; \
		$(MAKE) install.libs DESTDIR=$(TARGET_DIR); \
		install -D -m 0755 misc/ncurses-config $(HOST_DIR)/bin/ncurses5-config; \
		rm -f $(TARGET_DIR)/usr/bin/ncurses5-config
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/ncurses5-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/form.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/menu.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ncurses.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/panel.pc
	$(REMOVE)/ncurses-$(NCURSES_VER)
	$(TOUCH)

#
# gmp
#
GMP_VER_MAJOR = 6.0.0
GMP_VER_MINOR = a
GMP_VER = $(GMP_VER_MAJOR)$(GMP_VER_MINOR)
GMP_SOURCE = gmp-$(GMP_VER).tar.xz

$(ARCHIVE)/$(GMP_SOURCE):
	$(WGET) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER_MAJOR)/$(GMP_SOURCE)

$(D)/gmp: $(D)/bootstrap $(ARCHIVE)/$(GMP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gmp-$(GMP_VER_MAJOR)
	$(UNTAR)/$(GMP_SOURCE)
	set -e; cd $(BUILD_TMP)/gmp-$(GMP_VER_MAJOR); \
		$(CONFIGURE) \
			--prefix=/usr \
			--infodir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgmp.la
	$(REMOVE)/gmp-$(GMP_VER_MAJOR)
	$(TOUCH)

#
# host_libffi
#
LIBFFI_VER = 3.2.1
LIBFFI_SOURCE = libffi-$(LIBFFI_VER).tar.gz
LIBFFI_PATCH = libffi-$(LIBFFI_VER).patch

$(ARCHIVE)/$(LIBFFI_SOURCE):
	$(WGET) ftp://sourceware.org/pub/libffi/$(LIBFFI_SOURCE)

$(D)/host_libffi: $(ARCHIVE)/$(LIBFFI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(UNTAR)/$(LIBFFI_SOURCE)
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VER); \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(TOUCH)

#
# libffi
#
$(D)/libffi: $(D)/bootstrap $(ARCHIVE)/$(LIBFFI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(UNTAR)/$(LIBFFI_SOURCE)
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VER); \
		$(call post_patch,$(LIBFFI_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-static \
			--enable-builddir=libffi \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(TOUCH)

#
# host_glib2_genmarshal
#
LIBGLIB2_VER_MAJOR = 2
LIBGLIB2_VER_MINOR = 45
LIBGLIB2_VER_MICRO = 4
LIBGLIB2_VER = $(LIBGLIB2_VER_MAJOR).$(LIBGLIB2_VER_MINOR).$(LIBGLIB2_VER_MICRO)
LIBGLIB2_SOURCE = glib-$(LIBGLIB2_VER).tar.xz
LIBGLIB2_HOST_PATCH = libglib2-host-$(LIBGLIB2_VER)-gdate-suppress-string-format-literal-warning.patch
LIBGLIB2_PATCH = libglib2-$(LIBGLIB2_VER)-disable-tests.patch

$(ARCHIVE)/$(LIBGLIB2_SOURCE):
	$(WGET) https://ftp.gnome.org/pub/gnome/sources/glib/$(LIBGLIB2_VER_MAJOR).$(LIBGLIB2_VER_MINOR)/$(LIBGLIB2_SOURCE)

$(D)/host_libglib2_genmarshal: $(D)/bootstrap $(D)/host_libffi $(ARCHIVE)/$(LIBGLIB2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(UNTAR)/$(LIBGLIB2_SOURCE)
	set -e; cd $(BUILD_TMP)/glib-$(LIBGLIB2_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		export PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig; \
		$(call post_patch,$(LIBGLIB2_HOST_PATCH)); \
		./configure $(SILENT_OPT) \
			--enable-static=yes \
			--enable-shared=no \
			--disable-fam \
			--prefix=`pwd`/out \
		; \
		$(MAKE) install; \
		cp -a out/bin/glib-* $(HOST_DIR)/bin
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(TOUCH)

#
# libglib2
#
$(D)/libglib2: $(D)/bootstrap $(D)/host_libglib2_genmarshal $(D)/zlib $(D)/libffi $(ARCHIVE)/$(LIBGLIB2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(UNTAR)/$(LIBGLIB2_SOURCE)
	set -e; cd $(BUILD_TMP)/glib-$(LIBGLIB2_VER); \
		echo "glib_cv_va_copy=no" > config.cache; \
		echo "glib_cv___va_copy=yes" >> config.cache; \
		echo "glib_cv_va_val_copy=yes" >> config.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes" >> config.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes" >> config.cache; \
		echo "glib_cv_stack_grows=no" >> config.cache; \
		echo "glib_cv_uscore=no" >> config.cache; \
		$(call post_patch,$(LIBGLIB2_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--with-threads="posix" \
			--enable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glib-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gio-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gio-unix-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-export-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-no-export-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gobject-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gthread-2.0.pc
	$(REWRITE_LIBTOOL)/libglib-2.0.la
	$(REWRITE_LIBTOOL)/libgmodule-2.0.la
	$(REWRITE_LIBTOOL)/libgio-2.0.la
	$(REWRITE_LIBTOOL)/libgobject-2.0.la
	$(REWRITE_LIBTOOL)/libgthread-2.0.la
	$(REWRITE_LIBTOOLDEP)/libglib-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgmodule-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgio-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgobject-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgthread-2.0.la
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(TOUCH)

#
# libpcre
#
LIBPCRE_VER = 8.39
LIBPCRE_SOURCE = pcre-$(LIBPCRE_VER).tar.bz2

$(ARCHIVE)/$(LIBPCRE_SOURCE):
	$(WGET) https://sourceforge.net/projects/pcre/files/pcre/$(LIBPCRE_VER)/$(LIBPCRE_SOURCE)

$(D)/libpcre: $(D)/bootstrap $(ARCHIVE)/$(LIBPCRE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pcre-$(LIBPCRE_VER)
	$(UNTAR)/$(LIBPCRE_SOURCE)
	set -e; cd $(BUILD_TMP)/pcre-$(LIBPCRE_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-utf8 \
			--enable-unicode-properties \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		mv $(TARGET_DIR)/usr/bin/pcre-config $(HOST_DIR)/bin/pcre-config
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/pcre-config
	$(REWRITE_LIBTOOL)/libpcre.la
	$(REWRITE_LIBTOOL)/libpcrecpp.la
	$(REWRITE_LIBTOOL)/libpcreposix.la
	$(REWRITE_LIBTOOLDEP)/libpcrecpp.la
	$(REWRITE_LIBTOOLDEP)/libpcreposix.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcre.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcrecpp.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcreposix.pc
	$(REMOVE)/pcre-$(LIBPCRE_VER)
	$(TOUCH)

#
# host_libarchive
#
LIBARCHIVE_VER = 3.1.2
LIBARCHIVE_SOURCE = libarchive-$(LIBARCHIVE_VER).tar.gz

$(ARCHIVE)/$(LIBARCHIVE_SOURCE):
	$(WGET) https://www.libarchive.org/downloads/$(LIBARCHIVE_SOURCE)

$(D)/host_libarchive: $(D)/bootstrap $(ARCHIVE)/$(LIBARCHIVE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VER)
	$(UNTAR)/$(LIBARCHIVE_SOURCE)
	set -e; cd $(BUILD_TMP)/libarchive-$(LIBARCHIVE_VER); \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(BUILD) \
			--prefix= \
			--without-xml2 \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VER)
	$(TOUCH)

#
# libarchive
#
$(D)/libarchive: $(D)/bootstrap $(ARCHIVE)/$(LIBARCHIVE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VER)
	$(UNTAR)/$(LIBARCHIVE_SOURCE)
	set -e; cd $(BUILD_TMP)/libarchive-$(LIBARCHIVE_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-static=no \
			--disable-bsdtar \
			--disable-bsdcpio \
			--without-iconv \
			--without-libiconv-prefix \
			--without-lzo2 \
			--without-nettle \
			--without-xml2 \
			--without-expat \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libarchive.pc
	$(REWRITE_LIBTOOL)/libarchive.la
	$(REMOVE)/libarchive-$(LIBARCHIVE_VER)
	$(TOUCH)

#
# libreadline
#
READLINE_VER = 6.2
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz

$(ARCHIVE)/$(READLINE_SOURCE):
	$(WGET) https://ftp.gnu.org/gnu/readline/$(READLINE_SOURCE)

$(D)/readline: $(D)/bootstrap $(ARCHIVE)/$(READLINE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/readline-$(READLINE_VER)
	$(UNTAR)/$(READLINE_SOURCE)
	set -e; cd $(BUILD_TMP)/readline-$(READLINE_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--datadir=/.remove \
			bash_cv_must_reinstall_sighandlers=no \
			bash_cv_func_sigsetjmp=present \
			bash_cv_func_strcoll_broken=no \
			bash_cv_have_mbstate_t=yes \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/readline-$(READLINE_VER)
	$(TOUCH)

#
# openssl
#
OPENSSL_MAJOR = 1.0.2
OPENSSL_MINOR = k
OPENSSL_VER = $(OPENSSL_MAJOR)$(OPENSSL_MINOR)
OPENSSL_SOURCE = openssl-$(OPENSSL_VER).tar.gz
OPENSSL_PATCH  = openssl-$(OPENSSL_VER)-optimize-for-size.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-makefile-dirs.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-disable_doc_tests.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-fix-parallel-building.patch

$(ARCHIVE)/$(OPENSSL_SOURCE):
	$(WGET) https://www.openssl.org/source/$(OPENSSL_SOURCE)

$(D)/openssl: $(D)/bootstrap $(ARCHIVE)/$(OPENSSL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openssl-$(OPENSSL_VER)
	$(UNTAR)/$(OPENSSL_SOURCE)
	set -e; cd $(BUILD_TMP)/openssl-$(OPENSSL_VER); \
		$(call post_patch,$(OPENSSL_PATCH)); \
		$(BUILDENV) \
		./Configure $(SILENT_OPT) \
			-DL_ENDIAN \
			shared \
			no-hw \
			linux-generic32 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
		; \
		sed -i 's|MAKEDEPPROG=makedepend|MAKEDEPPROG=$(CROSS_DIR)/bin/$$(CC) -M|' Makefile; \
		$(MAKE) depend; \
		$(MAKE) all; \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGET_DIR)
	chmod 0755 $(TARGET_DIR)/usr/lib/lib{crypto,ssl}.so.*
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	cd $(TARGET_DIR) && rm -rf etc/ssl/man usr/bin/openssl usr/lib/engines
	ln -sf libcrypto.so.1.0.0 $(TARGET_DIR)/usr/lib/libcrypto.so.0.9.8
	ln -sf libssl.so.1.0.0 $(TARGET_DIR)/usr/lib/libssl.so.0.9.8
	$(REMOVE)/openssl-$(OPENSSL_VER)
	$(TOUCH)

#
# libbluray
#
LIBBLURAY_VER = 0.5.0
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VER).tar.bz2
LIBBLURAY_PATCH = libbluray-$(LIBBLURAY_VER).patch

$(ARCHIVE)/$(LIBBLURAY_SOURCE):
	$(WGET) ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/$(LIBBLURAY_SOURCE)

$(D)/libbluray: $(D)/bootstrap $(ARCHIVE)/$(LIBBLURAY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(UNTAR)/$(LIBBLURAY_SOURCE)
	set -e; cd $(BUILD_TMP)/libbluray-$(LIBBLURAY_VER); \
		$(call post_patch,$(LIBBLURAY_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--disable-extra-warnings \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--disable-doxygen-html \
			--disable-doxygen-ps \
			--disable-doxygen-pdf \
			--disable-examples \
			--without-libxml2 \
			--without-freetype \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbluray.pc
	$(REWRITE_LIBTOOL)/libbluray.la
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(TOUCH)

#
# lua
#
LUA_VER = 5.2.4
LUA_VER_SHORT = 5.2
LUA_SOURCE = lua-$(LUA_VER).tar.gz

LUAPOSIX_VER = 31
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VER).tar.bz2
LUAPOSIX_URL = git://github.com/luaposix/luaposix.git
LUAPOSIX_PATCH = lua-$(LUA_VER)-luaposix-$(LUAPOSIX_VER).patch

$(ARCHIVE)/$(LUA_SOURCE):
	$(WGET) https://www.lua.org/ftp/$(LUA_SOURCE)

$(ARCHIVE)/$(LUAPOSIX_SOURCE):
	get-git-archive.sh $(LUAPOSIX_URL) release-v$(LUAPOSIX_VER) $(notdir $@) $(ARCHIVE)

$(D)/lua: $(D)/bootstrap $(D)/ncurses $(ARCHIVE)/$(LUAPOSIX_SOURCE) $(ARCHIVE)/$(LUA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lua-$(LUA_VER)
	mkdir -p $(TARGET_DIR)/usr/share/lua/$(LUA_VER_SHORT)
	$(UNTAR)/$(LUA_SOURCE)
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VER); \
		$(call post_patch,$(LUAPOSIX_PATCH)); \
		tar xf $(ARCHIVE)/$(LUAPOSIX_SOURCE); \
		cd luaposix-$(LUAPOSIX_VER)/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		cd luaposix-$(LUAPOSIX_VER)/lib; cp *.lua $(TARGET_DIR)/usr/share/lua/$(LUA_VER_SHORT); cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's|man/man1|/.remove|' Makefile; \
		$(MAKE) linux CC=$(TARGET)-gcc CPPFLAGS="$(TARGET_CPPFLAGS)" LDFLAGS="-L$(TARGET_DIR)/usr/lib" BUILDMODE=dynamic PKG_VERSION=$(LUA_VER); \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR)/usr INSTALL_MAN=$(TARGET_DIR)/.remove
	cd $(TARGET_DIR)/usr && rm bin/lua bin/luac
	$(REMOVE)/lua-$(LUA_VER)
	$(TOUCH)

#
# luacurl
#
LUACURL_VER = 9ac72c7
LUACURL_SOURCE = luacurl-$(LUACURL_VER).tar.bz2
LUACURL_URL = git://github.com/Lua-cURL/Lua-cURLv3.git

$(ARCHIVE)/$(LUACURL_SOURCE):
	get-git-archive.sh $(LUACURL_URL) $(LUACURL_VER) $(notdir $@) $(ARCHIVE)

$(D)/luacurl: $(D)/bootstrap $(D)/libcurl $(D)/lua $(ARCHIVE)/$(LUACURL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luacurl-$(LUACURL_VER)
	$(UNTAR)/$(LUACURL_SOURCE)
	set -e; cd $(BUILD_TMP)/luacurl-$(LUACURL_VER); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGET_DIR)/usr/lib" \
			LIBDIR=$(TARGET_DIR)/usr/lib \
			LUA_INC=$(TARGET_DIR)/usr/include; \
		$(MAKE) install DESTDIR=$(TARGET_DIR) LUA_CMOD=/usr/lib/lua/$(LUA_VER_SHORT) LUA_LMOD=/usr/share/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luacurl-$(LUACURL_VER)
	$(TOUCH)

#
# luaexpat
#
LUAEXPAT_VER = 1.3.0
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VER).tar.gz
LUAEXPAT_PATCH = luaexpat-$(LUAEXPAT_VER).patch

$(ARCHIVE)/$(LUAEXPAT_SOURCE):
	$(WGET) https://matthewwild.co.uk/projects/luaexpat/$(LUAEXPAT_SOURCE)

$(D)/luaexpat: $(D)/bootstrap $(D)/lua $(D)/expat $(ARCHIVE)/$(LUAEXPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luaexpat-$(LUAEXPAT_VER)
	$(UNTAR)/$(LUAEXPAT_SOURCE)
	set -e; cd $(BUILD_TMP)/luaexpat-$(LUAEXPAT_VER); \
		$(call post_patch,$(LUAEXPAT_PATCH)); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGET_DIR)/usr/lib" PREFIX=$(TARGET_DIR)/usr; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)/usr
	$(REMOVE)/luaexpat-$(LUAEXPAT_VER)
	$(TOUCH)

#
# luasocket
#
LUASOCKET_VER = 5a17f79
LUASOCKET_SOURCE = luasocket-$(LUASOCKET_VER).tar.bz2
LUASOCKET_URL = git://github.com/diegonehab/luasocket.git

$(ARCHIVE)/$(LUASOCKET_SOURCE):
	get-git-archive.sh $(LUASOCKET_URL) $(LUASOCKET_VER) $(notdir $@) $(ARCHIVE)

$(D)/luasocket: $(D)/bootstrap $(D)/lua $(ARCHIVE)/$(LUASOCKET_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luasocket-$(LUASOCKET_VER)
	$(UNTAR)/$(LUASOCKET_SOURCE)
	set -e; cd $(BUILD_TMP)/luasocket-$(LUASOCKET_VER); \
		sed -i -e "s@LD_linux=gcc@LD_LINUX=$(TARGET)-gcc@" -e "s@CC_linux=gcc@CC_LINUX=$(TARGET)-gcc -L$(TARGET_DIR)/usr/lib@" -e "s@DESTDIR?=@DESTDIR?=$(TARGET_DIR)/usr@" src/makefile; \
		$(MAKE) CC=$(TARGET)-gcc LD=$(TARGET)-gcc LUAV=$(LUA_VER_SHORT) PLAT=linux COMPAT=COMPAT LUAINC_linux=$(TARGET_DIR)/usr/include LUAPREFIX_linux=; \
		$(MAKE) install LUAPREFIX_linux= LUAV=$(LUA_VER_SHORT)
	$(REMOVE)/luasocket-$(LUASOCKET_VER)
	$(TOUCH)

#
# luafeedparser
#
LUAFEEDPARSER_VER = 9b284bc
LUAFEEDPARSER_SOURCE = luafeedparser-$(LUAFEEDPARSER_VER).tar.bz2
LUAFEEDPARSER_URL = git://github.com/slact/lua-feedparser.git

$(ARCHIVE)/$(LUAFEEDPARSER_SOURCE):
	get-git-archive.sh $(LUAFEEDPARSER_URL) $(LUAFEEDPARSER_VER) $(notdir $@) $(ARCHIVE)

$(D)/luafeedparser: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat $(ARCHIVE)/$(LUAFEEDPARSER_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luafeedparser-$(LUAFEEDPARSER_VER)
	$(UNTAR)/$(LUAFEEDPARSER_SOURCE)
	set -e; cd $(BUILD_TMP)/luafeedparser-$(LUAFEEDPARSER_VER); \
		sed -i -e "s/^PREFIX.*//" -e "s/^LUA_DIR.*//" Makefile ; \
		$(BUILDENV) $(MAKE) install  LUA_DIR=$(TARGET_DIR)/usr/share/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luafeedparser-$(LUAFEEDPARSER_VER)
	$(TOUCH)

#
# luasoap
#
LUASOAP_VER = 3.0
LUASOAP_SOURCE = luasoap-$(LUASOAP_VER).tar.gz
LUASOAP_PATCH = luasoap-$(LUASOAP_VER).patch

$(ARCHIVE)/$(LUASOAP_SOURCE):
	$(WGET) https://github.com/downloads/tomasguisasola/luasoap/$(LUASOAP_SOURCE)

$(D)/luasoap: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat $(ARCHIVE)/$(LUASOAP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/luasoap-$(LUASOAP_VER)
	$(UNTAR)/$(LUASOAP_SOURCE)
	set -e; cd $(BUILD_TMP)/luasoap-$(LUASOAP_VER); \
		$(call post_patch,$(LUASOAP_PATCH)); \
		$(MAKE) install LUA_DIR=$(TARGET_DIR)/usr/share/lua/$(LUA_VER_SHORT)
	$(REMOVE)/luasoap-$(LUASOAP_VER)
	$(TOUCH)

#
# luajson
#
$(ARCHIVE)/json.lua:
	$(WGET) https://github.com/swiboe/swiboe/raw/master/term_gui/json.lua

$(D)/luajson: $(D)/bootstrap $(D)/lua $(ARCHIVE)/json.lua
	$(START_BUILD)
	cp $(ARCHIVE)/json.lua $(TARGET_DIR)/usr/share/lua/$(LUA_VER_SHORT)/json.lua
	$(TOUCH)

#
# libboost
#
BOOST_VER_MAJOR = 1
BOOST_VER_MINOR = 61
BOOST_VER_MICRO = 0
BOOST_VER_ARCHIVE = $(BOOST_VER_MAJOR).$(BOOST_VER_MINOR).$(BOOST_VER_MICRO)
BOOST_VER = $(BOOST_VER_MAJOR)_$(BOOST_VER_MINOR)_$(BOOST_VER_MICRO)
BOOST_SOURCE = boost_$(BOOST_VER).tar.bz2
BOOST_PATCH = boost-$(BOOST_VER).patch

$(ARCHIVE)/$(BOOST_SOURCE):
	$(WGET) https://sourceforge.net/projects/boost/files/boost/$(BOOST_VER_ARCHIVE)/$(BOOST_SOURCE)

$(D)/boost: $(D)/bootstrap $(ARCHIVE)/$(BOOST_SOURCE)
	$(START_BUILD)
	$(REMOVE)/boost_$(BOOST_VER)
	$(UNTAR)/$(BOOST_SOURCE)
	set -e; cd $(BUILD_TMP)/boost_$(BOOST_VER); \
		$(call post_patch,$(BOOST_PATCH)); \
		rm -rf $(TARGET_DIR)/usr/include/boost; \
		mv $(BUILD_TMP)/boost_$(BOOST_VER)/boost $(TARGET_DIR)/usr/include/boost
	$(REMOVE)/boost_$(BOOST_VER)
	$(TOUCH)

#
# zlib
#
ZLIB_VER = 1.2.11
ZLIB_SOURCE = zlib-$(ZLIB_VER).tar.xz
ZLIB_Patch = zlib-$(ZLIB_VER).patch

$(ARCHIVE)/$(ZLIB_SOURCE):
	$(WGET) https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VER)/$(ZLIB_SOURCE)

$(D)/zlib: $(D)/bootstrap $(ARCHIVE)/$(ZLIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(UNTAR)/$(ZLIB_SOURCE)
	set -e; cd $(BUILD_TMP)/zlib-$(ZLIB_VER); \
		$(call post_patch,$(ZLIB_Patch)); \
		CC=$(TARGET)-gcc mandir=$(TARGET_DIR)/.remove CFLAGS="$(TARGET_CFLAGS)" \
		./configure $(SILENT_OPT) \
			--prefix=/usr \
			--shared \
			--uname=Linux \
		; \
		$(MAKE); \
		ln -sf /bin/true ldconfig; \
		$(MAKE) install prefix=$(TARGET_DIR)/usr
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(TOUCH)

#
# bzip2
#
BZIP2_VER = 1.0.6
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_Patch = bzip2-$(BZIP2_VER).patch

$(ARCHIVE)/$(BZIP2_SOURCE):
	$(WGET) http://www.bzip.org/$(BZIP2_VER)/$(BZIP2_SOURCE)

$(D)/bzip2: $(D)/bootstrap $(ARCHIVE)/$(BZIP2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/bzip2-$(BZIP2_VER)
	$(UNTAR)/$(BZIP2_SOURCE)
	set -e; cd $(BUILD_TMP)/bzip2-$(BZIP2_VER); \
		$(call post_patch,$(BZIP2_Patch)); \
		mv Makefile-libbz2_so Makefile; \
		$(MAKE) all CC=$(TARGET)-gcc AR=$(TARGET)-ar RANLIB=$(TARGET)-ranlib; \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr
	cd $(TARGET_DIR) && rm -f usr/bin/bzip2
	$(REMOVE)/bzip2-$(BZIP2_VER)
	$(TOUCH)

#
# timezone
#
TZDATA_VER = 2016a
TZDATA_SOURCE = tzdata$(TZDATA_VER).tar.gz
TZDATA_ZONELIST = africa antarctica asia australasia europe northamerica southamerica pacificnew etcetera backward
DEFAULT_TIMEZONE ?= "CET"
#ln -s /usr/share/zoneinfo/<country>/<city> /etc/localtime

$(ARCHIVE)/$(TZDATA_SOURCE):
	$(WGET) ftp://ftp.iana.org/tz/releases/$(TZDATA_SOURCE)

$(D)/timezone: $(D)/bootstrap find-zic $(ARCHIVE)/$(TZDATA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/timezone
	mkdir $(BUILD_TMP)/timezone
	tar -C $(BUILD_TMP)/timezone -xf $(ARCHIVE)/$(TZDATA_SOURCE)
	set -e; cd $(BUILD_TMP)/timezone; \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		for zone in $(TZDATA_ZONELIST); do \
			zic -d zoneinfo -L /dev/null -y yearistype.sh $$zone ; \
			: zic -d zoneinfo/posix -L /dev/null -y yearistype.sh $$zone ; \
			: zic -d zoneinfo/right -L leapseconds -y yearistype.sh $$zone ; \
		done; \
		install -d -m 0755 $(TARGET_DIR)/usr/share $(TARGET_DIR)/etc; \
		cp -a zoneinfo $(TARGET_DIR)/usr/share/; \
		cp -v zone.tab iso3166.tab $(TARGET_DIR)/usr/share/zoneinfo/; \
		# Install default timezone
		if [ -e $(TARGET_DIR)/usr/share/zoneinfo/$(DEFAULT_TIMEZONE) ]; then \
			echo ${DEFAULT_TIMEZONE} > $(TARGET_DIR)/etc/timezone; \
		fi; \
	install -m 0644 $(SKEL_ROOT)/etc/timezone.xml $(TARGET_DIR)/etc/
	$(REMOVE)/timezone
	$(TOUCH)

#
# freetype
#
FREETYPE_VER = 2.7.1
FREETYPE_SOURCE = freetype-$(FREETYPE_VER).tar.bz2
FREETYPE_PATCH = freetype-$(FREETYPE_VER).patch

$(ARCHIVE)/$(FREETYPE_SOURCE):
	$(WGET) https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)/$(FREETYPE_SOURCE)

$(D)/freetype: $(D)/bootstrap $(D)/zlib $(D)/libpng $(ARCHIVE)/$(FREETYPE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/freetype-$(FREETYPE_VER)
	$(UNTAR)/$(FREETYPE_SOURCE)
	set -e; cd $(BUILD_TMP)/freetype-$(FREETYPE_VER); \
		$(call post_patch,$(FREETYPE_PATCH)); \
		sed -r "s:.*(#.*SUBPIXEL_(RENDERING|HINTING  2)) .*:\1:g" \
			-i include/freetype/config/ftoption.h; \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg; \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-static \
			--enable-shared \
			--with-png \
			--with-zlib \
			--without-harfbuzz \
			--without-bzip2 \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		if [ ! -e $(TARGET_DIR)/usr/include/freetype ] ; then \
			ln -sf freetype2 $(TARGET_DIR)/usr/include/freetype; \
		fi; \
		sed -e 's:^prefix=.*:prefix="$(TARGET_DIR)/usr":' \
		    -e 's:^exec_prefix=.*:exec_prefix="$${prefix}":' \
		    -e 's:^includedir=.*:includedir="$${prefix}/include":' \
		    -e 's:^libdir=.*:libdir="$${exec_prefix}/lib":' \
		    -i $(TARGET_DIR)/usr/bin/freetype-config; \
		mv $(TARGET_DIR)/usr/bin/freetype-config $(HOST_DIR)/bin/freetype-config
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-$(FREETYPE_VER)
	$(TOUCH)

#
# lirc
#
ifeq ($(BOXTYPE), $(filter $(BOXTYPE),adb_box arivalink200 ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd hl101 sagemcom88 spark spark7162 ufs910 vitamin_hd5000))

LIRC_VER = 0.9.0
LIRC_SOURCE = lirc-$(LIRC_VER).tar.bz2
LIRC_PATCH = lirc-$(LIRC_VER).patch
LIRC = $(D)/lirc

$(ARCHIVE)/$(LIRC_SOURCE):
	$(WGET) https://sourceforge.net/projects/lirc/files/LIRC/$(LIRC_VER)/$(LIRC_SOURCE)

ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
LIRC_OPTS = -D__KERNEL_STRICT_NAMES -DUINPUT_NEUTRINO_HACK -DSPARK -I$(DRIVER_DIR)/frontcontroller/aotom_spark
else
LIRC_OPTS = -D__KERNEL_STRICT_NAMES
endif
else
LIRC_OPTS = -D__KERNEL_STRICT_NAMES
endif

$(D)/lirc: $(D)/bootstrap $(ARCHIVE)/$(LIRC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lirc-$(LIRC_VER)
	$(UNTAR)/$(LIRC_SOURCE)
	set -e; cd $(BUILD_TMP)/lirc-$(LIRC_VER); \
		$(call post_patch,$(LIRC_PATCH)); \
		$(CONFIGURE) \
		ac_cv_path_LIBUSB_CONFIG= \
		CFLAGS="$(TARGET_CFLAGS) $(LIRC_OPTS)" \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--sbindir=/usr/bin \
			--mandir=/.remove \
			--with-kerneldir=$(KERNEL_DIR) \
			--without-x \
			--with-devdir=/dev \
			--with-moduledir=/lib/modules \
			--with-major=61 \
			--with-driver=userspace \
			--enable-debug \
			--with-syslog=LOG_DAEMON \
			--enable-sandboxed \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/liblirc_client.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,lircmd ircat irpty irrecord irsend irw lircrcd mode2 pronto2lirc)
	$(REMOVE)/lirc-$(LIRC_VER)
	$(TOUCH)
endif

#
# jpeg
#
JPEG_VER = 8d
JPEG_SOURCE = jpegsrc.v$(JPEG_VER).tar.gz
JPEG_PATCH = jpeg-$(JPEG_VER).patch

$(ARCHIVE)/$(JPEG_SOURCE):
	$(WGET) http://www.ijg.org/files/$(JPEG_SOURCE)

$(D)/jpeg: $(D)/bootstrap $(ARCHIVE)/$(JPEG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/jpeg-$(JPEG_VER)
	$(UNTAR)/$(JPEG_SOURCE)
	set -e; cd $(BUILD_TMP)/jpeg-$(JPEG_VER); \
		$(call post_patch,$(JPEG_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libjpeg.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cjpeg djpeg jpegtran rdjpgcom wrjpgcom)
	$(REMOVE)/jpeg-$(JPEG_VER)
	$(TOUCH)

#
# jpeg_turbo
#
JPEG_TURBO_VER = 1.5.1
JPEG_TURBO_SOURCE = libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz

$(ARCHIVE)/$(JPEG_TURBO_SOURCE):
	$(WGET) https://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO_VER)/$(JPEG_TURBO_SOURCE)

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 ufs910 ufs922 ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
$(D)/libjpeg: $(D)/jpeg
	@touch $@
else
$(D)/libjpeg: $(D)/jpeg_turbo
	@touch $@
endif

$(D)/jpeg_turbo: $(D)/bootstrap $(ARCHIVE)/$(JPEG_TURBO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO_VER)
	$(UNTAR)/$(JPEG_TURBO_SOURCE)
	set -e; cd $(BUILD_TMP)/libjpeg-turbo-$(JPEG_TURBO_VER); \
		export CC=$(TARGET)-gcc; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--mandir=/.remove \
			--docdir=/.remove \
			--includedir=/.remove \
			--with-jpeg8 \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		make clean; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--mandir=/.remove \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libjpeg.pc
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cjpeg djpeg jpegtran rdjpgcom wrjpgcom tjbench)
	rm -f $(TARGET_DIR)/usr/lib/libturbojpeg* $(TARGET_DIR)/usr/include/turbojpeg.h $(PKG_CONFIG_PATH)/libturbojpeg.pc
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO_VER)
	$(TOUCH)

#
# libpng
#
LIBPNG_VER = 1.6.29
LIBPNG_VER_X = 16
LIBPNG_SOURCE = libpng-$(LIBPNG_VER).tar.xz
LIBPNG_PATCH = libpng-$(LIBPNG_VER)-disable-tools.patch

$(ARCHIVE)/$(LIBPNG_SOURCE):
	$(WGET) https://sourceforge.net/projects/libpng/files/libpng$(LIBPNG_VER_X)/older-releases/$(LIBPNG_VER)/$(LIBPNG_SOURCE)

$(D)/libpng: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBPNG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(UNTAR)/$(LIBPNG_SOURCE)
	set -e; cd $(BUILD_TMP)/libpng-$(LIBPNG_VER); \
		$(call post_patch,$(PNG_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-mips-msa \
			--disable-powerpc-vsx \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		sed -e 's:^prefix=.*:prefix="$(TARGET_DIR)/usr":' -i $(TARGET_DIR)/usr/bin/libpng$(LIBPNG_VER_X)-config; \
		mv $(TARGET_DIR)/usr/bin/libpng*-config $(HOST_DIR)/bin/
	$(REWRITE_LIBTOOL)/libpng16.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpng$(LIBPNG_VER_X).pc
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(TOUCH)

#
# png++
#
PNGPP_VER = 0.2.9
PNGPP_SOURCE = png++-$(PNGPP_VER).tar.gz

$(ARCHIVE)/$(PNGPP_SOURCE):
	$(WGET) https://download.savannah.gnu.org/releases/pngpp/$(PNGPP_SOURCE)

$(D)/pngpp: $(D)/bootstrap $(D)/libpng $(ARCHIVE)/$(PNGPP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/png++-$(PNGPP_VER)
	$(UNTAR)/$(PNGPP_SOURCE)
	set -e; cd $(BUILD_TMP)/png++-$(PNGPP_VER); \
		$(MAKE) install-headers PREFIX=$(TARGET_DIR)/usr
	$(REMOVE)/png++-$(PNGPP_VER)
	$(TOUCH)

#
# giflib
#
GIFLIB_VER = 5.1.4
GIFLIB_SOURCE = giflib-$(GIFLIB_VER).tar.bz2

$(ARCHIVE)/$(GIFLIB_SOURCE):
	$(WGET) https://sourceforge.net/projects/giflib/files/$(GIFLIB_SOURCE)

$(D)/giflib: $(D)/bootstrap $(ARCHIVE)/$(GIFLIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/giflib-$(GIFLIB_VER)
	$(UNTAR)/$(GIFLIB_SOURCE)
	set -e; cd $(BUILD_TMP)/giflib-$(GIFLIB_VER); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgif.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,gif2rgb gifbuild gifclrmp gifecho giffix gifinto giftext giftool)
	$(REMOVE)/giflib-$(GIFLIB_VER)
	$(TOUCH)

#
# libconfig
#
LIBCONFIG_VER = 1.4.10
LIBCONFIG_SOURCE = libconfig-$(LIBCONFIG_VER).tar.gz

$(ARCHIVE)/$(LIBCONFIG_SOURCE):
	$(WGET) http://www.hyperrealm.com/packages/$(LIBCONFIG_SOURCE)

$(D)/libconfig: $(D)/bootstrap $(ARCHIVE)/$(LIBCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libconfig-$(LIBCONFIG_VER)
	$(UNTAR)/$(LIBCONFIG_SOURCE)
	set -e; cd $(BUILD_TMP)/libconfig-$(LIBCONFIG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libconfig.pc
	$(REWRITE_LIBTOOL)/libconfig.la
	$(REMOVE)/libconfig-$(LIBCONFIG_VER)
	$(TOUCH)

#
# libcurl
#
LIBCURL_VER = 7.54.1
LIBCURL_SOURCE = curl-$(LIBCURL_VER).tar.bz2
LIBCURL_PATCH = libcurl-$(LIBCURL_VER).patch

$(ARCHIVE)/$(LIBCURL_SOURCE):
	$(WGET) https://curl.haxx.se/download/$(LIBCURL_SOURCE)

$(D)/libcurl: $(D)/bootstrap $(D)/openssl $(D)/zlib $(ARCHIVE)/$(LIBCURL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(UNTAR)/$(LIBCURL_SOURCE)
	set -e; cd $(BUILD_TMP)/curl-$(LIBCURL_VER); \
		$(call post_patch,$(LIBCURL_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-silent-rules \
			--disable-debug \
			--disable-curldebug \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-imap \
			--disable-pop3 \
			--disable-smtp \
			--enable-shared \
			--disable-ldap \
			--without-libidn \
			--without-libpsl \
			--with-random \
			--with-ssl=$(TARGET_DIR) \
		; \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGET_DIR)," < curl-config > $(HOST_DIR)/bin/curl-config; \
		chmod 755 $(HOST_DIR)/bin/curl-config; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		rm -f $(TARGET_DIR)/usr/bin/curl-config
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,curl)
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(TOUCH)

#
# libfribidi
#
LIBFRIBIDI_VER = 0.19.7
LIBFRIBIDI_SOURCE = fribidi-$(LIBFRIBIDI_VER).tar.bz2
LIBFRIBIDI_PATCH = libfribidi-$(LIBFRIBIDI_VER).patch

$(ARCHIVE)/$(LIBFRIBIDI_SOURCE):
	$(WGET) https://fribidi.org/download/$(LIBFRIBIDI_SOURCE)

$(D)/libfribidi: $(D)/bootstrap $(ARCHIVE)/$(LIBFRIBIDI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fribidi-$(LIBFRIBIDI_VER)
	$(UNTAR)/$(LIBFRIBIDI_SOURCE)
	set -e; cd $(BUILD_TMP)/fribidi-$(LIBFRIBIDI_VER); \
		$(call post_patch,$(LIBFRIBIDI_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-shared \
			--enable-static \
			--disable-debug \
			--disable-deprecated \
			--enable-charsets \
			--with-glib=no \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fribidi.pc
	$(REWRITE_LIBTOOL)/libfribidi.la
	cd $(TARGET_DIR) && rm usr/bin/fribidi
	$(REMOVE)/fribidi-$(LIBFRIBIDI_VER)
	$(TOUCH)

#
# libsigc++_e2
#
LIBSIGC_E2_VER_MAJOR = 1
LIBSIGC_E2_VER_MINOR = 2
LIBSIGC_E2_VER_MICRO = 7
LIBSIGC_E2_VER = $(LIBSIGC_E2_VER_MAJOR).$(LIBSIGC_E2_VER_MINOR).$(LIBSIGC_E2_VER_MICRO)
LIBSIGC_E2_SOURCE = libsigc++-$(LIBSIGC_E2_VER).tar.gz

$(ARCHIVE)/$(LIBSIGC_E2_SOURCE):
	$(WGET) https://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_E2_VER_MAJOR).$(LIBSIGC_E2_VER_MINOR)/$(LIBSIGC_E2_SOURCE)

$(D)/libsigc_e2: $(D)/bootstrap $(ARCHIVE)/$(LIBSIGC_E2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libsigc++-$(LIBSIGC_E2_VER)
	$(UNTAR)/$(LIBSIGC_E2_SOURCE)
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGC_E2_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-checks \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-1.2.pc
	$(REWRITE_LIBTOOL)/libsigc-1.2.la
	$(REMOVE)/libsigc++-$(LIBSIGC_E2_VER)
	$(TOUCH)

#
# libsigc
#
LIBSIGC_VER_MAJOR = 2
LIBSIGC_VER_MINOR = 4
LIBSIGC_VER_MICRO = 1
LIBSIGC_VER = $(LIBSIGC_VER_MAJOR).$(LIBSIGC_VER_MINOR).$(LIBSIGC_VER_MICRO)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VER).tar.xz

$(ARCHIVE)/$(LIBSIGC_SOURCE):
	$(WGET) https://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_VER_MAJOR).$(LIBSIGC_VER_MINOR)/$(LIBSIGC_SOURCE)

$(D)/libsigc: $(D)/bootstrap $(ARCHIVE)/$(LIBSIGC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libsigc++-$(LIBSIGC_VER)
	$(UNTAR)/$(LIBSIGC_SOURCE)
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGC_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-documentation \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		if [ -d $(TARGET_DIR)/usr/include/sigc++-2.0/sigc++ ] ; then \
			ln -sf ./sigc++-2.0/sigc++ $(TARGET_DIR)/usr/include/sigc++; \
		fi;
		mv $(TARGET_DIR)/usr/lib/sigc++-2.0/include/sigc++config.h $(TARGET_DIR)/usr/include; \
		rm -fr $(TARGET_DIR)/usr/lib/sigc++-2.0
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-2.0.pc
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	$(REMOVE)/libsigc++-$(LIBSIGC_VER)
	$(TOUCH)

#
# libmad
#
LIBMAD_VER = 0.15.1b
LIBMAD_SOURCE = libmad-$(LIBMAD_VER).tar.gz
LIBMAD_PATCH = libmad-$(LIBMAD_VER).patch

$(ARCHIVE)/$(LIBMAD_SOURCE):
	$(WGET) https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VER)/$(LIBMAD_SOURCE)

$(D)/libmad: $(D)/bootstrap $(ARCHIVE)/$(LIBMAD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(UNTAR)/$(LIBMAD_SOURCE)
	set -e; cd $(BUILD_TMP)/libmad-$(LIBMAD_VER); \
		$(call post_patch,$(LIBMAD_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-debugging \
			--enable-shared=yes \
			--enable-speed \
			--enable-sso \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/mad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(TOUCH)

#
# libid3tag
#
LIBID3TAG_VER = 0.15.1b
LIBID3TAG_SOURCE = libid3tag-$(LIBID3TAG_VER).tar.gz
LIBID3TAG_PATCH = libid3tag-$(LIBID3TAG_VER).patch

$(ARCHIVE)/$(LIBID3TAG_SOURCE):
	$(WGET) https://sourceforge.net/projects/mad/files/libid3tag/$(LIBID3TAG_VER)/$(LIBID3TAG_SOURCE)

$(D)/libid3tag: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBID3TAG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	$(UNTAR)/$(LIBID3TAG_SOURCE)
	set -e; cd $(BUILD_TMP)/libid3tag-$(LIBID3TAG_VER); \
		$(call post_patch,$(LIBID3TAG_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared=yes \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/id3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	$(TOUCH)

#
# libvorbis
#
LIBVORBIS_VER = 1.3.5
LIBVORBIS_SOURCE = libvorbis-$(LIBVORBIS_VER).tar.xz

$(ARCHIVE)/$(LIBVORBIS_SOURCE):
	$(WGET) https://ftp.osuosl.org/pub/xiph/releases/vorbis/$(LIBVORBIS_SOURCE)

$(D)/libvorbis: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/$(LIBVORBIS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libvorbis-$(LIBVORBIS_VER)
	$(UNTAR)/$(LIBVORBIS_SOURCE)
	set -e; cd $(BUILD_TMP)/libvorbis-$(LIBVORBIS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
			--disable-docs \
			--disable-examples \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbis.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisenc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisfile.pc
	$(REWRITE_LIBTOOL)/libvorbis.la
	$(REWRITE_LIBTOOL)/libvorbisenc.la
	$(REWRITE_LIBTOOL)/libvorbisfile.la
	$(REWRITE_LIBTOOLDEP)/libvorbis.la
	$(REWRITE_LIBTOOLDEP)/libvorbisenc.la
	$(REWRITE_LIBTOOLDEP)/libvorbisfile.la
	$(REMOVE)/libvorbis-$(LIBVORBIS_VER)
	$(TOUCH)

#
# libvorbisidec
#
LIBVORBISIDEC_SVN = 18153
LIBVORBISIDEC_VER = 1.0.2+svn$(LIBVORBISIDEC_SVN)
LIBVORBISIDEC_VER_APPEND = .orig
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VER)$(LIBVORBISIDEC_VER_APPEND).tar.gz
LIBVORBISIDEC_PATCH = libvorbisidec-$(LIBVORBISIDEC_VER).patch

$(ARCHIVE)/$(LIBVORBISIDEC_SOURCE):
	$(WGET) https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/$(LIBVORBISIDEC_SOURCE)

$(D)/libvorbisidec: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/$(LIBVORBISIDEC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(UNTAR)/$(LIBVORBISIDEC_SOURCE)
	set -e; cd $(BUILD_TMP)/libvorbisidec-$(LIBVORBISIDEC_VER); \
		$(call post_patch,$(LIBVORBISIDEC_PATCH)); \
		ACLOCAL_FLAGS="-I . -I $(TARGET_DIR)/usr/share/aclocal" \
		$(BUILDENV) ./autogen.sh $(CONFIGURE_OPTS) --prefix=/usr; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(TOUCH)

#
# libiconv
#
LIBICONV_VER = 1.15
LIBICONV_SOURCE = libiconv-$(LIBICONV_VER).tar.gz

$(ARCHIVE)/$(LIBICONV_SOURCE):
	$(WGET) https://ftp.gnu.org/gnu/libiconv/$(LIBICONV_SOURCE)

$(D)/libiconv: $(D)/bootstrap $(ARCHIVE)/$(LIBICONV_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(UNTAR)/$(LIBICONV_SOURCE)
	set -e; cd $(BUILD_TMP)/libiconv-$(LIBICONV_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--datarootdir=/.remove \
			--disable-static \
			--enable-shared \
		; \
		$(MAKE); \
		cp ./srcm4/* $(HOST_DIR)/share/aclocal/ ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libcharset.la
	$(REWRITE_LIBTOOL)/libiconv.la
	rm -f $(addprefix $(TARGET_DIR)/usr/lib/,preloadable_libiconv.so)
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(TOUCH)

#
# expat
#
EXPAT_VER = 2.2.0
EXPAT_SOURCE = expat-$(EXPAT_VER).tar.bz2

$(ARCHIVE)/$(EXPAT_SOURCE):
	$(WGET) https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/$(EXPAT_SOURCE)

$(D)/expat: $(D)/bootstrap $(ARCHIVE)/$(EXPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/expat-$(EXPAT_VER)
	$(UNTAR)/$(EXPAT_SOURCE)
	set -e; cd $(BUILD_TMP)/expat-$(EXPAT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--bindir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/expat-$(EXPAT_VER)
	$(TOUCH)

#
# fontconfig
#
FONTCONFIG_VER = 2.11.93
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VER).tar.bz2

$(ARCHIVE)/$(FONTCONFIG_SOURCE):
	$(WGET) https://www.freedesktop.org/software/fontconfig/release/$(FONTCONFIG_SOURCE)

$(D)/fontconfig: $(D)/bootstrap $(D)/freetype $(D)/expat $(ARCHIVE)/$(FONTCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fontconfig-$(FONTCONFIG_VER)
	$(UNTAR)/$(FONTCONFIG_SOURCE)
	set -e; cd $(BUILD_TMP)/fontconfig-$(FONTCONFIG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
			--with-expat-includes=$(TARGET_DIR)/usr/include \
			--with-expat-lib=$(TARGET_DIR)/usr/lib \
			--sysconfdir=/etc \
			--disable-docs \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libfontconfig.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fontconfig.pc
	$(REMOVE)/fontconfig-$(FONTCONFIG_VER)
	$(TOUCH)

#
# libdvdcss
#
LIBDVDCSS_VER = 1.2.13
LIBDVDCSS_SOURCE = libdvdcss-$(LIBDVDCSS_VER).tar.bz2

$(ARCHIVE)/$(LIBDVDCSS_SOURCE):
	$(WGET) https://download.videolan.org/pub/libdvdcss/$(LIBDVDCSS_VER)/$(LIBDVDCSS_SOURCE)

$(D)/libdvdcss: $(D)/bootstrap $(ARCHIVE)/$(LIBDVDCSS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdcss-$(LIBDVDCSS_VER)
	$(UNTAR)/$(LIBDVDCSS_SOURCE)
	set -e; cd $(BUILD_TMP)/libdvdcss-$(LIBDVDCSS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-doc \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvdcss.pc
	$(REWRITE_LIBTOOL)/libdvdcss.la
	$(REMOVE)/libdvdcss-$(LIBDVDCSS_VER)
	$(TOUCH)

#
# libdvdnav
#
LIBDVDNAV_VER = 4.2.1
LIBDVDNAV_SOURCE = libdvdnav-$(LIBDVDNAV_VER).tar.xz
LIBDVDNAV_PATCH = libdvdnav-$(LIBDVDNAV_VER).patch

$(ARCHIVE)/$(LIBDVDNAV_SOURCE):
	$(WGET) http://dvdnav.mplayerhq.hu/releases/$(LIBDVDNAV_SOURCE)

$(D)/libdvdnav: $(D)/bootstrap $(D)/libdvdread $(ARCHIVE)/$(LIBDVDNAV_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdnav-$(LIBDVDNAV_VER)
	$(UNTAR)/$(LIBDVDNAV_SOURCE)
	set -e; cd $(BUILD_TMP)/libdvdnav-$(LIBDVDNAV_VER); \
		$(call post_patch,$(LIBDVDNAV_PATCH)); \
		$(BUILDENV) \
		libtoolize --copy --force --quiet --ltdl; \
		./autogen.sh \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--enable-static \
			--enable-shared \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdnav.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdnavmini.pc
	$(REWRITE_LIBTOOL)/libdvdnav.la
	$(REWRITE_LIBTOOL)/libdvdnavmini.la
	$(REMOVE)/libdvdnav-$(LIBDVDNAV_VER)
	$(TOUCH)

#
# libdvdread
#
LIBDVDREAD_VER = 4.9.9
LIBDVDREAD_SOURCE = libdvdread-$(LIBDVDREAD_VER).tar.xz
LIBDVDREAD_PATCH = libdvdread-$(LIBDVDREAD_VER).patch

$(ARCHIVE)/$(LIBDVDREAD_SOURCE):
	$(WGET) http://dvdnav.mplayerhq.hu/releases/$(LIBDVDREAD_SOURCE)

$(D)/libdvdread: $(D)/bootstrap $(ARCHIVE)/$(LIBDVDREAD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdread-$(LIBDVDREAD_VER)
	$(UNTAR)/$(LIBDVDREAD_SOURCE)
	set -e; cd $(BUILD_TMP)/libdvdread-$(LIBDVDREAD_VER); \
		$(call post_patch,$(LIBDVDREAD_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--enable-shared \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdread.pc
	$(REWRITE_LIBTOOL)/libdvdread.la
	$(REMOVE)/libdvdread-$(LIBDVDREAD_VER)
	$(TOUCH)

#
# libdreamdvd
#
LIBDREAMDVD_PATCH = libdreamdvd-1.0-sh4-support.patch

$(D)/libdreamdvd: $(D)/bootstrap $(D)/libdvdnav
	$(START_BUILD)
	$(REMOVE)/libdreamdvd
	set -e; if [ -d $(ARCHIVE)/libdreamdvd.git ]; \
		then cd $(ARCHIVE)/libdreamdvd.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/mirakels/libdreamdvd.git libdreamdvd.git; \
		fi
	cp -ra $(ARCHIVE)/libdreamdvd.git $(BUILD_TMP)/libdreamdvd
	set -e; cd $(BUILD_TMP)/libdreamdvd; \
		$(call post_patch,$(LIBDREAMDVD_PATCH)); \
		$(BUILDENV) \
		libtoolize --copy --ltdl --force --quiet; \
		autoreconf --verbose --force --install; \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdreamdvd.pc
	$(REWRITE_LIBTOOL)/libdreamdvd.la
	$(REMOVE)/libdreamdvd
	$(TOUCH)

#
# ffmpeg
#
FFMPEG_VER = 2.8.10
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz
FFMPEG_PATCH  = ffmpeg-buffer-size-$(FFMPEG_VER).patch
FFMPEG_PATCH += ffmpeg-hds-libroxml-$(FFMPEG_VER).patch
FFMPEG_PATCH += ffmpeg-aac-$(FFMPEG_VER).patch
FFMPEG_PATCH += ffmpeg-kodi-$(FFMPEG_VER).patch

$(ARCHIVE)/$(FFMPEG_SOURCE):
	$(WGET) http://www.ffmpeg.org/releases/$(FFMPEG_SOURCE)

ifeq ($(IMAGE), enigma2)
FFMPEG_CONF_OPTS  = --enable-librtmp
LIBRTMPDUMP = $(D)/librtmpdump
endif

ifeq ($(IMAGE), neutrino)
FFMPEG_CONF_OPTS = --disable-iconv
endif

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/libass $(D)/libroxml $(LIBRTMPDUMP) $(ARCHIVE)/$(FFMPEG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	$(UNTAR)/$(FFMPEG_SOURCE)
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
		$(call post_patch,$(FFMPEG_PATCH)); \
		./configure $(SILENT_OPT) \
			--disable-ffserver \
			--disable-ffplay \
			--disable-ffprobe \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-altivec \
			--disable-amd3dnow \
			--disable-amd3dnowext \
			--disable-mmx \
			--disable-mmxext \
			--disable-sse \
			--disable-sse2 \
			--disable-sse3 \
			--disable-ssse3 \
			--disable-sse4 \
			--disable-sse42 \
			--disable-avx \
			--disable-fma4 \
			--disable-armv5te \
			--disable-armv6 \
			--disable-armv6t2 \
			--disable-vfp \
			--disable-neon \
			--disable-inline-asm \
			--disable-yasm \
			--disable-mips32r2 \
			--disable-mipsdspr2 \
			--disable-mipsfpu \
			--disable-fast-unaligned \
			\
			--disable-dxva2 \
			--disable-vaapi \
			--disable-vdpau \
			\
			--disable-muxers \
			--enable-muxer=flac \
			--enable-muxer=mp3 \
			--enable-muxer=h261 \
			--enable-muxer=h263 \
			--enable-muxer=h264 \
			--enable-muxer=hevc \
			--enable-muxer=image2 \
			--enable-muxer=mpeg1video \
			--enable-muxer=mpeg2video \
			--enable-muxer=mpegts \
			--enable-muxer=ogg \
			\
			--disable-parsers \
			--enable-parser=aac \
			--enable-parser=aac_latm \
			--enable-parser=ac3 \
			--enable-parser=dca \
			--enable-parser=dvbsub \
			--enable-parser=dvdsub \
			--enable-parser=flac \
			--enable-parser=h264 \
			--enable-parser=hevc \
			--enable-parser=mjpeg \
			--enable-parser=mpeg4video \
			--enable-parser=mpegvideo \
			--enable-parser=mpegaudio \
			--enable-parser=vc1 \
			--enable-parser=vorbis \
			\
			--disable-encoders \
			--enable-encoder=aac \
			--enable-encoder=h261 \
			--enable-encoder=h263 \
			--enable-encoder=h263p \
			--enable-encoder=ljpeg \
			--enable-encoder=mjpeg \
			--enable-encoder=mpeg1video \
			--enable-encoder=mpeg2video \
			--enable-encoder=png \
			\
			--disable-decoders \
			--enable-decoder=aac \
			--enable-decoder=aac_latm \
			--enable-decoder=dca \
			--enable-decoder=dvbsub \
			--enable-decoder=dvdsub \
			--enable-decoder=flac \
			--enable-decoder=h261 \
			--enable-decoder=h263 \
			--enable-decoder=h263i \
			--enable-decoder=h264 \
			--enable-decoder=hevc \
			--enable-decoder=mjpeg \
			--enable-decoder=mp3 \
			--enable-decoder=movtext \
			--enable-decoder=mpeg1video \
			--enable-decoder=mpeg2video \
			--enable-decoder=msmpeg4v1 \
			--enable-decoder=msmpeg4v2 \
			--enable-decoder=msmpeg4v3 \
			--enable-decoder=pcm_s16le \
			--enable-decoder=pcm_s16be \
			--enable-decoder=pcm_s16le_planar \
			--enable-decoder=pcm_s16be_planar \
			--enable-decoder=pgssub \
			--enable-decoder=png \
			--enable-decoder=srt \
			--enable-decoder=subrip \
			--enable-decoder=subviewer \
			--enable-decoder=subviewer1 \
			--enable-decoder=text \
			--enable-decoder=theora \
			--enable-decoder=vorbis \
			--enable-decoder=wmv3 \
			--enable-decoder=xsub \
			\
			--disable-demuxers \
			--enable-demuxer=aac \
			--enable-demuxer=ac3 \
			--enable-demuxer=avi \
			--enable-demuxer=dts \
			--enable-demuxer=flac \
			--enable-demuxer=flv \
			--enable-demuxer=hds \
			--enable-demuxer=hls \
			--enable-demuxer=image2 \
			--enable-demuxer=image2pipe \
			--enable-demuxer=image_jpeg_pipe \
			--enable-demuxer=image_png_pipe \
			--enable-demuxer=matroska \
			--enable-demuxer=mjpeg \
			--enable-demuxer=mov \
			--enable-demuxer=mp3 \
			--enable-demuxer=mpegts \
			--enable-demuxer=mpegtsraw \
			--enable-demuxer=mpegps \
			--enable-demuxer=mpegvideo \
			--enable-demuxer=ogg \
			--enable-demuxer=pcm_s16be \
			--enable-demuxer=pcm_s16le \
			--enable-demuxer=rm \
			--enable-demuxer=rtp \
			--enable-demuxer=rtsp \
			--enable-demuxer=srt \
			--enable-demuxer=vc1 \
			--enable-demuxer=wav \
			\
			--disable-protocol=cache \
			--disable-protocol=concat \
			--disable-protocol=crypto \
			--disable-protocol=data \
			--disable-protocol=ftp \
			--disable-protocol=gopher \
			--disable-protocol=hls \
			--disable-protocol=httpproxy \
			--disable-protocol=md5 \
			--disable-protocol=pipe \
			--disable-protocol=sctp \
			--disable-protocol=srtp \
			--disable-protocol=subfile \
			--disable-protocol=unix \
			\
			--disable-filters \
			--enable-filter=scale \
			\
			--disable-xlib \
			--disable-libxcb \
			--disable-postproc \
			--enable-bsfs \
			--disable-indevs \
			--disable-outdevs \
			--enable-bzlib \
			--enable-zlib \
			$(FFMPEG_CONF_OPTS) \
			--disable-static \
			--enable-openssl \
			--enable-network \
			--enable-shared \
			--enable-small \
			--enable-stripping \
			--disable-debug \
			--disable-runtime-cpudetect \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--extra-cflags="-I$(TARGET_DIR)/usr/include -ffunction-sections -fdata-sections" \
			--extra-ldflags="-L$(TARGET_DIR)/usr/lib -Wl,--gc-sections,-lrt" \
			--target-os=linux \
			--arch=sh4 \
			--prefix=/usr \
			--bindir=/sbin \
			--mandir=/.remove \
			--datadir=/.remove \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavfilter.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswresample.pc
	test -e $(PKG_CONFIG_PATH)/libswscale.pc && $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswscale.pc || true
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	$(TOUCH)

#
# libass
#
LIBASS_VER = 0.12.3
LIBASS_SOURCE = libass-$(LIBASS_VER).tar.xz
LIBASS_PATCH = libass-$(LIBASS_VER).patch

$(ARCHIVE)/$(LIBASS_SOURCE):
	$(WGET) https://github.com/libass/libass/releases/download/$(LIBASS_VER)/$(LIBASS_SOURCE)

$(D)/libass: $(D)/bootstrap $(D)/freetype $(D)/libfribidi $(ARCHIVE)/$(LIBASS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libass-$(LIBASS_VER)
	$(UNTAR)/$(LIBASS_SOURCE)
	set -e; cd $(BUILD_TMP)/libass-$(LIBASS_VER); \
		$(call post_patch,$(LIBASS_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
			--disable-test \
			--disable-fontconfig \
			--disable-harfbuzz \
			--disable-enca \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libass.pc
	$(REWRITE_LIBTOOL)/libass.la
	$(REMOVE)/libass-$(LIBASS_VER)
	$(TOUCH)

#
# sqlite
#
SQLITE_VER = 3160100
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VER).tar.gz

$(ARCHIVE)/$(SQLITE_SOURCE):
	$(WGET) http://www.sqlite.org/2017/$(SQLITE_SOURCE)

$(D)/sqlite: $(D)/bootstrap $(ARCHIVE)/$(SQLITE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(UNTAR)/$(SQLITE_SOURCE)
	set -e; cd $(BUILD_TMP)/sqlite-autoconf-$(SQLITE_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sqlite3.pc
	$(REWRITE_LIBTOOL)/libsqlite3.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,sqlite3)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(TOUCH)

#
# libsoup
#
LIBSOUP_VER_MAJOR = 2.50
LIBSOUP_VER_MINOR = 0
LIBSOUP_VER = $(LIBSOUP_VER_MAJOR).$(LIBSOUP_VER_MINOR)
LIBSOUP_SOURCE = libsoup-$(LIBSOUP_VER).tar.xz

$(ARCHIVE)/$(LIBSOUP_SOURCE):
	$(WGET) https://download.gnome.org/sources/libsoup/$(LIBSOUP_VER_MAJOR)/$(LIBSOUP_SOURCE)

$(D)/libsoup: $(D)/bootstrap $(D)/sqlite $(D)/libxml2 $(D)/libglib2 $(ARCHIVE)/$(LIBSOUP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(UNTAR)/$(LIBSOUP_SOURCE)
	set -e; cd $(BUILD_TMP)/libsoup-$(LIBSOUP_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datarootdir=/.remove \
			--disable-more-warnings \
			--without-gnome \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libsoup-2.4.pc
	$(REWRITE_LIBTOOL)/libsoup-2.4.la
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(TOUCH)

#
# libogg
#
LIBOGG_VER = 1.3.2
LIBOGG_SOURCE = libogg-$(LIBOGG_VER).tar.gz

$(ARCHIVE)/$(LIBOGG_SOURCE):
	$(WGET) https://ftp.osuosl.org/pub/xiph/releases/ogg/$(LIBOGG_SOURCE)

$(D)/libogg: $(D)/bootstrap $(ARCHIVE)/$(LIBOGG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(UNTAR)/$(LIBOGG_SOURCE)
	set -e; cd $(BUILD_TMP)/libogg-$(LIBOGG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
			--enable-shared \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(TOUCH)

#
# flac
#
FLAC_VER = 1.3.1
FLAC_SOURCE = flac-$(FLAC_VER).tar.xz
FLAC_PATCH = flac-$(FLAC_VER).patch

$(ARCHIVE)/$(FLAC_SOURCE):
	$(WGET) https://ftp.osuosl.org/pub/xiph/releases/flac/$(FLAC_SOURCE)

$(D)/flac: $(D)/bootstrap $(ARCHIVE)/$(FLAC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/flac-$(FLAC_VER)
	$(UNTAR)/$(FLAC_SOURCE)
	set -e; cd $(BUILD_TMP)/flac-$(FLAC_VER); \
		$(call post_patch,$(FLAC_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-cpplibs \
			--disable-debug \
			--disable-asm-optimizations \
			--disable-sse \
			--disable-3dnow \
			--disable-altivec \
			--disable-doxygen-docs \
			--disable-thorough-tests \
			--disable-exhaustive-tests \
			--disable-valgrind-testing \
			--disable-ogg \
			--disable-oggtest \
			--disable-local-xmms-plugin \
			--disable-xmms-plugin \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) docdir=/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/flac.pc
	$(REWRITE_LIBTOOL)/libFLAC.la
	$(REMOVE)/flac-$(FLAC_VER)
	$(TOUCH)

#
# libxml2
#
LIBXML2_VER = 2.9.4
LIBXML2_SOURCE = libxml2-$(LIBXML2_VER).tar.gz
LIBXML2_PATCH = libxml2-$(LIBXML2_VER).patch

$(ARCHIVE)/$(LIBXML2_SOURCE):
	$(WGET) ftp://xmlsoft.org/libxml2/$(LIBXML2_SOURCE)

ifeq ($(IMAGE), enigma2)
LIBXML2_CONF_OPTS  = --with-python=$(HOST_DIR)
LIBXML2_CONF_OPTS += --with-python-install-dir=/$(PYTHON_DIR)/site-packages
endif

ifeq ($(IMAGE), neutrino)
LIBXML2_CONF_OPTS  = --without-python
LIBXML2_CONF_OPTS += --without-iconv
LIBXML2_CONF_OPTS += --with-minimum
endif

$(D)/libxml2: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBXML2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libxml2-$(LIBXML2_VER).tar.gz
	$(UNTAR)/$(LIBXML2_SOURCE)
	set -e; cd $(BUILD_TMP)/libxml2-$(LIBXML2_VER); \
		$(call post_patch,$(LIBXML2_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--datarootdir=/.remove \
			--enable-shared \
			--disable-static \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
			$(LIBXML2_CONF_OPTS) \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR);
		mv $(TARGET_DIR)/usr/bin/xml2-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc $(HOST_DIR)/bin/xml2-config
	sed -i 's/^\(Libs:.*\)/\1 -lz/' $(PKG_CONFIG_PATH)/libxml-2.0.pc
	if [ -e "$(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxml2mod.la" ]; then \
		sed -e "/^dependency_libs/ s,/usr/lib/libxml2.la,$(TARGET_DIR)/usr/lib/libxml2.la,g" -i $(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxml2mod.la; \
		sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(TARGET_DIR)/$(PYTHON_DIR)/site-packages,g" -i $(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxml2mod.la; \
	fi; \
	sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(TARGET_DIR)/usr/lib,g" -i $(TARGET_DIR)/usr/lib/xml2Conf.sh; \
	sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(TARGET_DIR)/usr/include,g" -i $(TARGET_DIR)/usr/lib/xml2Conf.sh
	$(REWRITE_LIBTOOL)/libxml2.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,xmlcatalog xmllint)
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	$(TOUCH)

#
# libxslt
#
LIBXSLT_VER = 1.1.28
LIBXSLT_SOURCE = libxslt-$(LIBXSLT_VER).tar.gz

$(ARCHIVE)/$(LIBXSLT_SOURCE):
	$(WGET) ftp://xmlsoft.org/libxml2/$(LIBXSLT_SOURCE)

$(D)/libxslt: $(D)/bootstrap $(D)/libxml2 $(ARCHIVE)/$(LIBXSLT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libxslt-$(LIBXSLT_VER)
	$(UNTAR)/$(LIBXSLT_SOURCE)
	set -e; cd $(BUILD_TMP)/libxslt-$(LIBXSLT_VER); \
		$(CONFIGURE) \
			CPPFLAGS="$(CPPFLAGS) -I$(TARGET_DIR)/usr/include/libxml2" \
			--prefix=/usr \
			--with-libxml-prefix="$(HOST_DIR)" \
			--with-libxml-include-prefix="$(TARGET_DIR)/usr/include" \
			--with-libxml-libs-prefix="$(TARGET_DIR)/usr/lib" \
			--with-python=$(HOST_DIR) \
			--without-crypto \
			--without-debug \
			--without-mem-debug \
		; \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGET_DIR)," < xslt-config > $(HOST_DIR)/bin/xslt-config; \
		chmod 755 $(HOST_DIR)/bin/xslt-config; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		if [ -e "$(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.la" ]; then \
			sed -e "/^dependency_libs/ s,/usr/lib/libexslt.la,$(TARGET_DIR)/usr/lib/libexslt.la,g" -i $(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^dependency_libs/ s,/usr/lib/libxslt.la,$(TARGET_DIR)/usr/lib/libxslt.la,g" -i $(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(TARGET_DIR)/$(PYTHON_DIR)/site-packages,g" -i $(TARGET_DIR)/$(PYTHON_DIR)/site-packages/libxsltmod.la; \
		fi; \
		sed -e "/^XSLT_LIBDIR/ s,/usr/lib,$(TARGET_DIR)/usr/lib,g" -i $(TARGET_DIR)/usr/lib/xsltConf.sh; \
		sed -e "/^XSLT_INCLUDEDIR/ s,/usr/include,$(TARGET_DIR)/usr/include,g" -i $(TARGET_DIR)/usr/lib/xsltConf.sh
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexslt.pc $(HOST_DIR)/bin/xslt-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxslt.pc
	$(REWRITE_LIBTOOL)/libexslt.la
	$(REWRITE_LIBTOOL)/libxslt.la
	$(REWRITE_LIBTOOLDEP)/libexslt.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,xsltproc xslt-config)
	$(REMOVE)/libxslt-$(LIBXSLT_VER)
	$(TOUCH)

#
#libpopt
#
LIBPOPT_VER = 1.16
LIBPOPT_SOURCE = popt-$(LIBPOPT_VER).tar.gz

$(ARCHIVE)/$(LIBPOPT_SOURCE):
	$(WGET) ftp://anduin.linuxfromscratch.org/BLFS/popt/$(LIBPOPT_SOURCE)

$(D)/libpopt: $(D)/bootstrap $(ARCHIVE)/$(LIBPOPT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/popt-$(LIBPOPT_VER)
	$(UNTAR)/$(LIBPOPT_SOURCE)
	set -e; cd $(BUILD_TMP)/popt-$(LIBPOPT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/popt.pc
	$(REWRITE_LIBTOOL)/libpopt.la
	$(REMOVE)/popt-$(LIBPOPT_VER)
	$(TOUCH)

#
#libroxml
#
LIBROXML_VER = 2.3.0
LIBROXML_SOURCE = libroxml-$(LIBROXML_VER).tar.gz

$(ARCHIVE)/$(LIBROXML_SOURCE):
	$(WGET) http://download.libroxml.net/pool/v2.x/$(LIBROXML_SOURCE)

$(D)/libroxml: $(D)/bootstrap $(ARCHIVE)/$(LIBROXML_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	$(UNTAR)/$(LIBROXML_SOURCE)
	set -e; cd $(BUILD_TMP)/libroxml-$(LIBROXML_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--disable-roxml \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libroxml.pc
	$(REWRITE_LIBTOOL)/libroxml.la
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	$(TOUCH)

#
# pugixml
#
PUGIXML_VER = 1.8
PUGIXML_SOURCE = pugixml-$(PUGIXML_VER).tar.gz
PUGIXML_PATCH = pugixml-1.8-config.patch

$(ARCHIVE)/$(PUGIXML_SOURCE):
	$(WGET) https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)/$(PUGIXML_SOURCE)

$(D)/pugixml: $(D)/bootstrap $(ARCHIVE)/$(PUGIXML_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	$(UNTAR)/$(PUGIXML_SOURCE)
	set -e; cd $(BUILD_TMP)/pugixml-$(PUGIXML_VER); \
		$(call post_patch,$(PUGIXML_PATCH)); \
		cmake \
		--no-warn-unused-cli \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=Linux \
		-DCMAKE_C_COMPILER=$(TARGET)-gcc \
		-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
		-DCMAKE_C_FLAGS="-pipe -Os" \
		-DCMAKE_CXX_FLAGS="-pipe -Os" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	$(TOUCH)

#
# graphlcd
#
GRAPHLCD_VER = 7958e1b
GRAPHLCD_SOURCE = graphlcd-$(GRAPHLCD_VER).tar.bz2
GRAPHLCD_URL = git://projects.vdr-developer.org/graphlcd-base.git
GRAPHLCD_PATCH = graphlcd-base-touchcol.patch

$(ARCHIVE)/$(GRAPHLCD_SOURCE):
	get-git-archive.sh $(GRAPHLCD_URL) $(GRAPHLCD_VER) $(notdir $@) $(ARCHIVE)

$(D)/graphlcd: $(D)/bootstrap $(D)/freetype $(D)/libusb $(ARCHIVE)/$(GRAPHLCD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/graphlcd-$(GRAPHLCD_VER)
	$(UNTAR)/$(GRAPHLCD_SOURCE)
	set -e; cd $(BUILD_TMP)/graphlcd-$(GRAPHLCD_VER); \
		$(call post_patch,$(GRAPHLCD_PATCH)); \
		export TARGET=$(TARGET)-; \
		$(BUILDENV) \
		$(MAKE) DESTDIR=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,convpic crtfont genfont showpic showtext lcdtestpattern skintest)
	$(REMOVE)/graphlcd-$(GRAPHLCD_VER)
	$(TOUCH)

#
# lcd4linux
#
$(D)/lcd4linux: $(D)/bootstrap $(D)/libusb_compat $(D)/gd $(D)/libusb
	$(START_BUILD)
	$(REMOVE)/lcd4linux
	set -e; if [ -d $(ARCHIVE)/lcd4linux.git ]; \
		then cd $(ARCHIVE)/lcd4linux.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/lcd4linux.git lcd4linux.git; \
		fi
	cp -ra $(ARCHIVE)/lcd4linux.git $(BUILD_TMP)/lcd4linux
	set -e; cd $(BUILD_TMP)/lcd4linux; \
		$(BUILDENV) ./bootstrap; \
		$(BUILDENV) ./configure $(SILENT_OPT) $(CONFIGURE_OPTS) \
			--prefix=/usr \
			--with-drivers='DPF,SamsungSPF' \
			--with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' \
			--without-ncurses \
		; \
		$(MAKE) vcs_version all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 755 $(SKEL_ROOT)/etc/init.d/lcd4linux $(TARGET_DIR)/etc/init.d/
	install -D -m 0600 $(SKEL_ROOT)/etc/lcd4linux_ni.conf $(TARGET_DIR)/etc/lcd4linux.conf
	$(REMOVE)/lcd4linux
	$(TOUCH)

#
# gd
#
GD_VER = 2.2.1
GD_SOURCE = libgd-$(GD_VER).tar.xz

$(ARCHIVE)/$(GD_SOURCE):
	$(WGET) https://github.com/libgd/libgd/releases/download/gd-$(GD_VER)/$(GD_SOURCE)

$(D)/gd: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/freetype $(ARCHIVE)/$(GD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libgd-$(GD_VER)
	$(UNTAR)/$(GD_SOURCE)
	set -e; cd $(BUILD_TMP)/libgd-$(GD_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--enable-static \
			--disable-shared \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgd.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gdlib.pc
	$(REMOVE)/libgd-$(GD_VER)
	$(TOUCH)

#
# libusb
#
LIBUSB_VER_MAJOR = 1.0
LIBUSB_VER_MINOR = 9
LIBUSB_VER = $(LIBUSB_VER_MAJOR).$(LIBUSB_VER_MINOR)
LIBUSB_SOURCE = libusb-$(LIBUSB_VER).tar.bz2
LIBUSB_PATCH = libusb-$(LIBUSB_VER).patch

$(ARCHIVE)/$(LIBUSB_SOURCE):
	$(WGET) https://sourceforge.net/projects/libusb/files/libusb-$(LIBUSB_VER_MAJOR)/libusb-$(LIBUSB_VER)/$(LIBUSB_SOURCE)

$(D)/libusb: $(D)/bootstrap $(ARCHIVE)/$(LIBUSB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(UNTAR)/$(LIBUSB_SOURCE)
	set -e; cd $(BUILD_TMP)/libusb-$(LIBUSB_VER); \
		$(call post_patch,$(LIBUSB_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--disable-log \
			--disable-debug-log \
			--disable-examples-build \
		; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libusb-1.0.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb-1.0.pc
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(TOUCH)

#
# libus_bcompat
#
LIBUSB_COMPAT_VER = 0.1.5
LIBUSB_COMPAT_SOURCE = libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2

$(ARCHIVE)/$(LIBUSB_COMPAT_SOURCE):
	$(WGET) https://sourceforge.net/projects/libusb/files/libusb-compat-0.1/libusb-compat-$(LIBUSB_COMPAT_VER)/$(LIBUSB_COMPAT_SOURCE)

$(D)/libusb_compat: $(D)/bootstrap $(D)/libusb $(ARCHIVE)/$(LIBUSB_COMPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	$(UNTAR)/$(LIBUSB_COMPAT_SOURCE)
	set -e; cd $(BUILD_TMP)/libusb-compat-$(LIBUSB_COMPAT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-log \
			--disable-debug-log \
			--disable-examples-build \
		; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(TARGET_DIR)/usr/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb.pc
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	$(TOUCH)

#
# alsa_lib
#
ALSA_LIB_VER = 1.1.4.1
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VER).tar.bz2
ALSA_LIB_PATCH  = alsa-lib-$(ALSA_LIB_VER).patch
ALSA_LIB_PATCH += alsa-lib-$(ALSA_LIB_VER)-link_fix.patch

$(ARCHIVE)/$(ALSA_LIB_SOURCE):
	$(WGET) ftp://ftp.alsa-project.org/pub/lib/$(ALSA_LIB_SOURCE)

$(D)/alsa_lib: $(D)/bootstrap $(ARCHIVE)/$(ALSA_LIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VER)
	$(UNTAR)/$(ALSA_LIB_SOURCE)
	set -e; cd $(BUILD_TMP)/alsa-lib-$(ALSA_LIB_VER); \
		$(call post_patch,$(ALSA_LIB_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-alsa-devdir=/dev/snd/ \
			--with-plugindir=/usr/lib/alsa \
			--without-debug \
			--with-debug=no \
			--with-versioned=no \
			--enable-symbolic-functions \
			--disable-aload \
			--disable-rawmidi \
			--disable-resmgr \
			--disable-old-symbols \
			--disable-alisp \
			--disable-hwdep \
			--disable-python \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/alsa.pc
	$(REWRITE_LIBTOOL)/libasound.la
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VER)
	$(TOUCH)

#
# alsa-utils
#
ALSA_UTILS_VER = 1.1.4
ALSA_UTILS_SOURCE = alsa-utils-$(ALSA_UTILS_VER).tar.bz2

$(ARCHIVE)/$(ALSA_UTILS_SOURCE):
	$(WGET) ftp://ftp.alsa-project.org/pub/utils/$(ALSA_UTILS_SOURCE)

$(D)/alsa_utils: $(D)/bootstrap $(D)/alsa_lib $(ARCHIVE)/$(ALSA_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/alsa-utils-$(ALSA_UTILS_VER)
	$(UNTAR)/$(ALSA_UTILS_SOURCE)
	set -e; cd $(BUILD_TMP)/alsa-utils-$(ALSA_UTILS_VER); \
		sed -ir -r "s/(alsamixer|amidi|aplay|iecset|speaker-test|seq|alsactl|alsaucm|topology)//g" Makefile.am ;\
		autoreconf -fi -I $(TARGET_DIR)/usr/share/aclocal $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--with-curses=ncursesw \
			--disable-bat \
			--disable-nls \
			--disable-alsatest \
			--disable-alsaconf \
			--disable-alsaloop \
			--disable-alsamixer \
			--disable-xmlto \
			--disable-rst2man \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/alsa-utils-$(ALSA_UTILS_VER)
	install -m 755 $(SKEL_ROOT)/etc/init.d/amixer $(TARGET_DIR)/etc/init.d/amixer
	install -m 644 $(SKEL_ROOT)/etc/amixer.conf $(TARGET_DIR)/etc/amixer.conf
	install -m 644 $(SKEL_ROOT)/etc/asound.conf $(TARGET_DIR)/etc/asound.conf
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,aserver)
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,alsa-info.sh)
	$(TOUCH)

#
# libopenthreads
#
LIBOPENTHREADS_VER = 2.6.0
LIBOPENTHREADS_SOURCE = OpenThreads-$(LIBOPENTHREADS_VER).zip
LIBOPENTHREADS_PATCH = libopenthreads-$(LIBOPENTHREADS_VER).patch

$(ARCHIVE)/$(LIBOPENTHREADS_SOURCE):
	$(WGET) https://trac.openscenegraph.org/downloads/developer_releases/$(LIBOPENTHREADS_SOURCE)

$(D)/libopenthreads: $(D)/bootstrap $(ARCHIVE)/$(LIBOPENTHREADS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VER)
	unzip -q $(ARCHIVE)/$(LIBOPENTHREADS_SOURCE) -d $(BUILD_TMP)
	set -e; cd $(BUILD_TMP)/OpenThreads-$(LIBOPENTHREADS_VER); \
		$(call post_patch,$(LIBOPENTHREADS_PATCH)); \
		echo "# dummy file to prevent warning message" > examples/CMakeLists.txt; \
		cmake . -DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1 \
		; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
		sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)/usr
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VER)
	$(TOUCH)

#
# librtmpdump
#
LIBRTMPDUMP_VER = ad70c64
LIBRTMPDUMP_SOURCE = librtmpdump-$(LIBRTMPDUMP_VER).tar.bz2
LIBRTMPDUMP_URL = git://github.com/oe-alliance/rtmpdump.git
LIBRTMPDUMP_PATCH = rtmpdump-2.4.patch

$(ARCHIVE)/$(LIBRTMPDUMP_SOURCE):
	get-git-archive.sh $(LIBRTMPDUMP_URL) $(LIBRTMPDUMP_VER) $(notdir $@) $(ARCHIVE)

$(D)/librtmpdump: $(D)/bootstrap $(D)/zlib $(D)/openssl $(ARCHIVE)/$(LIBRTMPDUMP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/librtmpdump-$(LIBRTMPDUMP_VER)
	$(UNTAR)/$(LIBRTMPDUMP_SOURCE)
	set -e; cd $(BUILD_TMP)/librtmpdump-$(LIBRTMPDUMP_VER); \
		$(call post_patch,$(LIBRTMPDUMP_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CROSS_COMPILE=$(TARGET)- ; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR) MANDIR=$(TARGET_DIR)/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/librtmp.pc
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,rtmpgw rtmpsrv rtmpsuck)
	$(REMOVE)/librtmpdump-$(LIBRTMPDUMP_VER)
	$(TOUCH)

#
# libdvbsi++
#
LIBDVBSI_VER = ff57e58
LIBDVBSI_SOURCE = libdvbsi-$(LIBDVBSI_VER).tar.bz2
LIBDVBSI_URL = git://git.opendreambox.org/git/obi/libdvbsi++.git
LIBDVBSI_PATCH = libdvbsi-git.patch

$(ARCHIVE)/$(LIBDVBSI_SOURCE):
	get-git-archive.sh $(LIBDVBSI_URL) $(LIBDVBSI_VER) $(notdir $@) $(ARCHIVE)

$(D)/libdvbsi: $(D)/bootstrap $(ARCHIVE)/$(LIBDVBSI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvbsi-$(LIBDVBSI_VER)
	$(UNTAR)/$(LIBDVBSI_SOURCE)
	set -e; cd $(BUILD_TMP)/libdvbsi-$(LIBDVBSI_VER); \
		$(call post_patch,$(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvbsi++.pc
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REMOVE)/libdvbsi-$(LIBDVBSI_VER)
	$(TOUCH)

#
# libmodplug
#
LIBMODPLUG_VER = 0.8.8.4
LIBMODPLUG_SOURCE = libmodplug-$(LIBMODPLUG_VER).tar.gz

$(ARCHIVE)/$(LIBMODPLUG_SOURCE):
	$(WGET) https://sourceforge.net/projects/modplug-xmms/files/libmodplug/$(LIBMODPLUG_VER)/$(LIBMODPLUG_SOURCE)

$(D)/libmodplug: $(D)/bootstrap $(ARCHIVE)/$(LIBMODPLUG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libmodplug-$(LIBMODPLUG_VER)
	$(UNTAR)/$(LIBMODPLUG_SOURCE)
	set -e; cd $(BUILD_TMP)/libmodplug-$(LIBMODPLUG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libmodplug.pc
	$(REWRITE_LIBTOOL)/libmodplug.la
	$(REMOVE)/libmodplug-$(LIBMODPLUG_VER)
	$(TOUCH)

#
# lzo
#
LZO_VER = 2.10
LZO_SOURCE = lzo-$(LZO_VER).tar.gz

$(ARCHIVE)/$(LZO_SOURCE):
	$(WGET) https://www.oberhumer.com/opensource/lzo/download/$(LZO_SOURCE)

$(D)/lzo: $(D)/bootstrap $(ARCHIVE)/$(LZO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lzo-$(LZO_VER)
	$(UNTAR)/$(LZO_SOURCE)
	set -e; cd $(BUILD_TMP)/lzo-$(LZO_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/liblzo2.la
	$(REMOVE)/lzo-$(LZO_VER)
	$(TOUCH)

#
# minidlna
#
MINIDLNA_VER = 1.1.5
MINIDLNA_SOURCE = minidlna-$(MINIDLNA_VER).tar.gz
MINIDLNA_PATCH = minidlna-$(MINIDLNA_VER).patch

$(ARCHIVE)/$(MINIDLNA_SOURCE):
	$(WGET) https://sourceforge.net/projects/minidlna/files/minidlna/$(MINIDLNA_VER)/$(MINIDLNA_SOURCE)

$(D)/minidlna: $(D)/bootstrap $(D)/zlib $(D)/sqlite $(D)/libexif $(D)/libjpeg $(D)/libid3tag $(D)/libogg $(D)/libvorbis $(D)/flac $(D)/ffmpeg $(ARCHIVE)/$(MINIDLNA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/minidlna-$(MINIDLNA_VER)
	$(UNTAR)/$(MINIDLNA_SOURCE)
	set -e; cd $(BUILD_TMP)/minidlna-$(MINIDLNA_VER); \
		$(call post_patch,$(MINIDLNA_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REMOVE)/minidlna-$(MINIDLNA_VER)
	$(TOUCH)

#
# libexif
#
LIBEXIF_VER = 0.6.21
LIBEXIF_SOURCE = libexif-$(LIBEXIF_VER).tar.gz

$(ARCHIVE)/$(LIBEXIF_SOURCE):
	$(WGET) https://sourceforge.net/projects/libexif/files/libexif/$(LIBEXIF_VER)/$(LIBEXIF_SOURCE)

$(D)/libexif: $(D)/bootstrap $(ARCHIVE)/$(LIBEXIF_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libexif-$(LIBEXIF_VER)
	$(UNTAR)/$(LIBEXIF_SOURCE)
	set -e; cd $(BUILD_TMP)/libexif-$(LIBEXIF_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexif.pc
	$(REWRITE_LIBTOOL)/libexif.la
	$(REMOVE)/libexif-$(LIBEXIF_VER)
	$(TOUCH)

#
# djmount
#
DJMOUNT_VER = 0.71
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VER).tar.gz

$(ARCHIVE)/$(DJMOUNT_SOURCE):
	$(WGET) https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)/$(DJMOUNT_SOURCE)

$(D)/djmount: $(D)/bootstrap $(D)/fuse $(ARCHIVE)/$(DJMOUNT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(UNTAR)/$(DJMOUNT_SOURCE)
	set -e; cd $(BUILD_TMP)/djmount-$(DJMOUNT_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(TOUCH)

#
# libupnp
#
LIBUPNP_VER = 1.6.22
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VER).tar.bz2

$(ARCHIVE)/$(LIBUPNP_SOURCE):
	$(WGET) https://sourceforge.net/projects/pupnp/files/pupnp/libUPnP\ $(LIBUPNP_VER)/$(LIBUPNP_SOURCE)

$(D)/libupnp: $(D)/bootstrap $(ARCHIVE)/$(LIBUPNP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(UNTAR)/$(LIBUPNP_SOURCE)
	set -e; cd $(BUILD_TMP)/libupnp-$(LIBUPNP_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(TOUCH)

#
# rarfs
#
RARFS_VER = 0.1.1
RARFS_SOURCE = rarfs-$(RARFS_VER).tar.gz

$(ARCHIVE)/$(RARFS_SOURCE):
	$(WGET) https://sourceforge.net/projects/rarfs/files/rarfs/$(RARFS_VER)/$(RARFS_SOURCE)

$(D)/rarfs: $(D)/bootstrap $(D)/fuse $(ARCHIVE)/$(RARFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/rarfs-$(RARFS_VER)
	$(UNTAR)/$(RARFS_SOURCE)
	set -e; cd $(BUILD_TMP)/rarfs-$(RARFS_VER); \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		$(CONFIGURE) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
			--disable-option-checking \
			--includedir=/usr/include/fuse \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/rarfs-$(RARFS_VER)
	$(TOUCH)

#
# sshfs
#
SSHFS_VER = 2.9
SSHFS_SOURCE = sshfs-$(SSHFS_VER).tar.gz

$(ARCHIVE)/$(SSHFS_SOURCE):
	$(WGET) https://github.com/libfuse/sshfs/releases/download/sshfs-$(SSHFS_VER)/$(SSHFS_SOURCE)

$(D)/sshfs: $(D)/bootstrap $(D)/libglib2 $(D)/fuse $(ARCHIVE)/$(SSHFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sshfs-$(SSHFS_VER)
	$(UNTAR)/$(SSHFS_SOURCE)
	set -e; cd $(BUILD_TMP)/sshfs-$(SSHFS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/sshfs-$(SSHFS_VER)
	$(TOUCH)

#
# howl
#
HOWL_VER = 1.0.0
HOWL_SOURCE = howl-$(HOWL_VER).tar.gz

$(ARCHIVE)/$(HOWL_SOURCE):
	$(WGET) https://sourceforge.net/projects/howl/files/howl/$(HOWL_VER)/$(HOWL_SOURCE)

$(D)/howl: $(D)/bootstrap $(ARCHIVE)/$(HOWL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/howl-$(HOWL_VER)
	$(UNTAR)/$(HOWL_SOURCE)
	set -e; cd $(BUILD_TMP)/howl-$(HOWL_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/howl.pc
	$(REWRITE_LIBTOOL)/libhowl.la
	$(REMOVE)/howl-$(HOWL_VER)
	$(TOUCH)

#
# libdaemon
#
LIBDAEMON_VER = 0.14
LIBDAEMON_SOURCE = libdaemon-$(LIBDAEMON_VER).tar.gz

$(ARCHIVE)/$(LIBDAEMON_SOURCE):
	$(WGET) http://0pointer.de/lennart/projects/libdaemon/$(LIBDAEMON_SOURCE)

$(D)/libdaemon: $(D)/bootstrap $(ARCHIVE)/$(LIBDAEMON_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdaemon-$(LIBDAEMON_VER)
	$(UNTAR)/$(LIBDAEMON_SOURCE)
	set -e; cd $(BUILD_TMP)/libdaemon-$(LIBDAEMON_VER); \
		$(CONFIGURE) \
			ac_cv_func_setpgrp_void=yes \
			--prefix=/usr \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdaemon.pc
	$(REWRITE_LIBTOOL)/libdaemon.la
	$(REMOVE)/libdaemon-$(LIBDAEMON_VER)
	$(TOUCH)

#
# libplist
#
LIBPLIST_VER = 1.10
LIBPLIST_SOURCE = libplist-$(LIBPLIST_VER).tar.gz

$(ARCHIVE)/$(LIBPLIST_SOURCE):
	$(WGET) https://cgit.sukimashita.com/libplist.git/snapshot/$(LIBPLIST_SOURCE)

$(D)/libplist: $(D)/bootstrap $(D)/libxml2 $(ARCHIVE)/$(LIBPLIST_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libplist-$(LIBPLIST_VER)
	$(UNTAR)/$(LIBPLIST_SOURCE)
	export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
	set -e; cd $(BUILD_TMP)/libplist-$(LIBPLIST_VER); \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake; \
		cmake . -DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="/usr" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-DCMAKE_INCLUDE_PATH="$(TARGET_DIR)/usr/include" \
		; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
		sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libplist.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libplist++.pc
	$(REMOVE)/libplist-$(LIBPLIST_VER)
	$(TOUCH)

#
# libao
#
LIBAO_VER = 1.1.0
LIBAO_SOURCE = libao-$(LIBAO_VER).tar.gz

$(ARCHIVE)/$(LIBAO_SOURCE):
	$(WGET) https://ftp.osuosl.org/pub/xiph/releases/ao/$(LIBAO_SOURCE)

$(D)/libao: $(D)/bootstrap $(D)/alsa_lib $(ARCHIVE)/$(LIBAO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libao-$(LIBAO_VER)
	$(UNTAR)/$(LIBAO_SOURCE)
	set -e; cd $(BUILD_TMP)/libao-$(LIBAO_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--enable-alsa \
			--enable-alsa-mmap \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ao.pc
	$(REWRITE_LIBTOOL)/libao.la
	$(REMOVE)/libao-$(LIBAO_VER)
	$(TOUCH)

#
# nettle
#
NETTLE_VER = 3.1
NETTLE_SOURCE = nettle-$(NETTLE_VER).tar.gz
NETTLE_PATCH = nettle-$(NETTLE_VER).patch

$(ARCHIVE)/$(NETTLE_SOURCE):
	$(WGET) https://ftp.gnu.org/gnu/nettle/$(NETTLE_SOURCE)

$(D)/nettle: $(D)/bootstrap $(D)/gmp $(ARCHIVE)/$(NETTLE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/nettle-$(NETTLE_VER)
	$(UNTAR)/$(NETTLE_SOURCE)
	set -e; cd $(BUILD_TMP)/nettle-$(NETTLE_VER); \
		$(call post_patch,$(NETTLE_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/hogweed.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/nettle.pc
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,sexp-conv nettle-hash nettle-pbkdf2 nettle-lfib-stream pkcs1-conv)
	$(REMOVE)/nettle-$(NETTLE_VER)
	$(TOUCH)

#
# gnutls
#
GNUTLS_VER_MAJOR = 3.4
GNUTLS_VER_MINOR = 3
GNUTLS_VER = $(GNUTLS_VER_MAJOR).$(GNUTLS_VER_MINOR)
GNUTLS_SOURCE = gnutls-$(GNUTLS_VER).tar.xz

$(ARCHIVE)/$(GNUTLS_SOURCE):
	$(WGET) ftp://ftp.gnutls.org/gcrypt/gnutls/v$(GNUTLS_VER_MAJOR)/$(GNUTLS_SOURCE)

$(D)/gnutls: $(D)/bootstrap $(D)/nettle $(ARCHIVE)/$(GNUTLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(UNTAR)/$(GNUTLS_SOURCE)
	set -e; cd $(BUILD_TMP)/gnutls-$(GNUTLS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-rpath \
			--with-included-libtasn1 \
			--enable-local-libopts \
			--with-libpthread-prefix=$(TARGET_DIR)/usr \
			--with-libz-prefix=$(TARGET_DIR)/usr \
			--disable-guile \
			--disable-crywrap \
			--without-p11-kit \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gnutls.pc
	$(REWRITE_LIBTOOL)/libgnutls.la
	$(REWRITE_LIBTOOL)/libgnutlsxx.la
	$(REWRITE_LIBTOOLDEP)/libgnutlsxx.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,psktool gnutls-cli-debug certtool srptool ocsptool gnutls-serv gnutls-cli)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(TOUCH)

#
# glib-networking
#
GLIB_NETWORKING_VER_MAJOR = 2.45
GLIB_NETWORKING_VER_MINOR = 1
GLIB_NETWORKING_VER = $(GLIB_NETWORKING_VER_MAJOR).$(GLIB_NETWORKING_VER_MINOR)
GLIB_NETWORKING_SOURCE = glib-networking-$(GLIB_NETWORKING_VER).tar.xz

$(ARCHIVE)/$(GLIB_NETWORKING_SOURCE):
	$(WGET) https://ftp.acc.umu.se/pub/GNOME/sources/glib-networking/$(GLIB_NETWORKING_VER_MAJOR)/$(GLIB_NETWORKING_SOURCE)

$(D)/glib_networking: $(D)/bootstrap $(D)/gnutls $(D)/libglib2 $(ARCHIVE)/$(GLIB_NETWORKING_SOURCE)
	$(START_BUILD)
	$(REMOVE)/glib-networking-$(GLIB_NETWORKING_VER)
	$(UNTAR)/$(GLIB_NETWORKING_SOURCE)
	set -e; cd $(BUILD_TMP)/glib-networking-$(GLIB_NETWORKING_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--localedir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGET_DIR) giomoduledir=$(TARGET_DIR)/usr/lib/gio/modules
	$(REMOVE)/glib-networking-$(GLIB_NETWORKING_VER)
	$(TOUCH)
