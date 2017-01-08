#
# libncurses
#
NCURSES_VERSION = 5.9

$(ARCHIVE)/ncurses-$(NCURSES_VERSION).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VERSION).tar.gz

$(D)/libncurses: $(D)/bootstrap $(ARCHIVE)/ncurses-$(NCURSES_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/ncurses-$(NCURSES_VERSION)
	$(UNTAR)/ncurses-$(NCURSES_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/ncurses-$(NCURSES_VERSION); \
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
		$(MAKE) install.libs DESTDIR=$(TARGETPREFIX); \
		install -D -m 0755 misc/ncurses-config $(HOSTPREFIX)/bin/ncurses5-config; \
		rm -f $(TARGETPREFIX)/usr/bin/ncurses5-config
	$(REWRITE_PKGCONF) $(HOSTPREFIX)/bin/ncurses5-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/form.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/menu.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ncurses.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/panel.pc
	$(REMOVE)/ncurses-$(NCURSES_VERSION)
	$(TOUCH)

#
# gmp
#
GMP_VERSION_MAJOR = 6.0.0
GMP_VERSION_MINOR = a
GMP_VERSION = $(GMP_VERSION_MAJOR)$(GMP_VERSION_MINOR)

$(ARCHIVE)/gmp-$(GMP_VERSION)$(GMP_SUBVER).tar.xz:
	$(WGET) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VERSION_MAJOR)/gmp-$(GMP_VERSION).tar.xz

$(D)/gmp: $(D)/bootstrap $(ARCHIVE)/gmp-$(GMP_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/gmp-$(GMP_VERSION_MAJOR)
	$(UNTAR)/gmp-$(GMP_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/gmp-$(GMP_VERSION_MAJOR); \
		$(CONFIGURE) \
			--prefix=/usr \
			--infodir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libgmp.la
	$(REMOVE)/gmp-$(GMP_VERSION_MAJOR)
	$(TOUCH)

#
# host_libffi
#
LIBFFI_VERSION = 3.2.1

$(ARCHIVE)/libffi-$(LIBFFI_VERSION).tar.gz:
	$(WGET) ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VERSION).tar.gz

$(D)/host_libffi: $(ARCHIVE)/libffi-$(LIBFFI_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libffi-$(LIBFFI_VERSION)
	$(UNTAR)/libffi-$(LIBFFI_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VERSION); \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOSTPREFIX) \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libffi-$(LIBFFI_VERSION)
	$(TOUCH)

#
# libffi
#
LIBFFI_PATCH = libffi-$(LIBFFI_VERSION).patch

$(D)/libffi: $(D)/bootstrap $(ARCHIVE)/libffi-$(LIBFFI_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libffi-$(LIBFFI_VERSION)
	$(UNTAR)/libffi-$(LIBFFI_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	$(REMOVE)/libffi-$(LIBFFI_VERSION)
	$(TOUCH)

#
# host_glib2_genmarshal
#
LIBGLIB2_VERSION_MAJOR = 2
LIBGLIB2_VERSION_MINOR = 45
LIBGLIB2_VERSION_MICRO = 4
LIBGLIB2_VERSION = $(LIBGLIB2_VERSION_MAJOR).$(LIBGLIB2_VERSION_MINOR).$(LIBGLIB2_VERSION_MICRO)

$(ARCHIVE)/glib-$(LIBGLIB2_VERSION).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/gnome/sources/glib/$(LIBGLIB2_VERSION_MAJOR).$(LIBGLIB2_VERSION_MINOR)/$(lastword $(subst /, ,$@))

$(D)/host_libglib2_genmarshal: $(D)/host_libffi $(ARCHIVE)/glib-$(LIBGLIB2_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VERSION)
	$(UNTAR)/glib-$(LIBGLIB2_VERSION).tar.xz
	export PKG_CONFIG=/usr/bin/pkg-config; \
	export PKG_CONFIG_PATH=$(HOSTPREFIX)/lib/pkgconfig; \
	set -e; cd $(BUILD_TMP)/glib-$(LIBGLIB2_VERSION); \
		./configure $(CONFIGURE_SILENT) \
			--enable-static=yes \
			--enable-shared=no \
			--prefix=`pwd`/out \
		; \
		$(MAKE) install; \
		cp -a out/bin/glib-* $(HOSTPREFIX)/bin
	$(REMOVE)/glib-$(LIBGLIB2_VERSION)
	$(TOUCH)

#
# libglib2
#
LIBGLIB2_PATCH = libglib2-$(LIBGLIB2_VERSION)-disable-tests.patch

$(D)/libglib2: $(D)/bootstrap $(D)/host_libglib2_genmarshal $(D)/zlib $(D)/libffi $(ARCHIVE)/glib-$(LIBGLIB2_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VERSION)
	$(UNTAR)/glib-$(LIBGLIB2_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/glib-$(LIBGLIB2_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
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
	$(REMOVE)/glib-$(LIBGLIB2_VERSION)
	$(TOUCH)

#
# libpcre
#
LIBPCRE_VERSION = 8.39

$(ARCHIVE)/pcre-$(LIBPCRE_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/pcre/files/pcre/$(LIBPCRE_VERSION)/pcre-$(LIBPCRE_VERSION).tar.bz2

$(D)/libpcre: $(D)/bootstrap $(ARCHIVE)/pcre-$(LIBPCRE_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/pcre-$(LIBPCRE_VERSION)
	$(UNTAR)/pcre-$(LIBPCRE_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/pcre-$(LIBPCRE_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-utf8 \
			--enable-unicode-properties \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		mv $(TARGETPREFIX)/usr/bin/pcre-config $(HOSTPREFIX)/bin/pcre-config
	$(REWRITE_PKGCONF) $(HOSTPREFIX)/bin/pcre-config
	$(REWRITE_LIBTOOL)/libpcre.la
	$(REWRITE_LIBTOOL)/libpcrecpp.la
	$(REWRITE_LIBTOOL)/libpcreposix.la
	$(REWRITE_LIBTOOLDEP)/libpcrecpp.la
	$(REWRITE_LIBTOOLDEP)/libpcreposix.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcre.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcrecpp.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpcreposix.pc
	$(REMOVE)/pcre-$(LIBPCRE_VERSION)
	$(TOUCH)

#
# libarchive
#
LIBARCHIVE_VERSION = 3.1.2

$(ARCHIVE)/libarchive-$(LIBARCHIVE_VERSION).tar.gz:
	$(WGET) http://www.libarchive.org/downloads/libarchive-$(LIBARCHIVE_VERSION).tar.gz

$(D)/host_libarchive: $(D)/bootstrap $(ARCHIVE)/libarchive-$(LIBARCHIVE_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VERSION)
	$(UNTAR)/libarchive-$(LIBARCHIVE_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libarchive-$(LIBARCHIVE_VERSION); \
		./configure \
			--build=$(BUILD) \
			--host=$(BUILD) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOSTPREFIX)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VERSION)
	$(TOUCH)

$(D)/libarchive: $(D)/bootstrap $(ARCHIVE)/libarchive-$(LIBARCHIVE_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VERSION)
	$(UNTAR)/libarchive-$(LIBARCHIVE_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libarchive-$(LIBARCHIVE_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libarchive.pc
	$(REWRITE_LIBTOOL)/libarchive.la
	$(REMOVE)/libarchive-$(LIBARCHIVE_VERSION)
	$(TOUCH)

#
# libreadline
#
READLINE_VERSION = 6.2

$(ARCHIVE)/readline-$(READLINE_VERSION).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/readline/readline-$(READLINE_VERSION).tar.gz

$(D)/libreadline: $(D)/bootstrap $(ARCHIVE)/readline-$(READLINE_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/readline-$(READLINE_VERSION)
	$(UNTAR)/readline-$(READLINE_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/readline-$(READLINE_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/readline-$(READLINE_VERSION)
	$(TOUCH)

#
# openssl
#
OPENSSL_VERSION = 1.0.2
OPENSSL_SUBVER = j
OPENSSL_PATCH  = openssl-$(OPENSSL_VERSION)-optimize-for-size.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VERSION)-makefile-dirs.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VERSION)-disable_doc_tests.patch

$(ARCHIVE)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER).tar.gz

$(D)/openssl: $(D)/bootstrap $(ARCHIVE)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER).tar.gz
	$(START_BUILD)
	$(REMOVE)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER)
	$(UNTAR)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER).tar.gz
	set -e; cd $(BUILD_TMP)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER); \
		$(call post_patch,$(OPENSSL_PATCH)); \
		$(BUILDENV) \
		./Configure \
			-DL_ENDIAN \
			shared \
			no-hw \
			linux-generic32 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
		; \
		sed -i 's|MAKEDEPPROG=makedepend|MAKEDEPPROG=$(CROSS_DIR)/bin/$$(CC) -M|' Makefile; \
		make depend; \
		$(MAKE) all; \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGETPREFIX)
	chmod 0755 $(TARGETPREFIX)/usr/lib/lib{crypto,ssl}.so.*
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	cd $(TARGETPREFIX) && rm -rf etc/ssl/man usr/bin/openssl
	$(REMOVE)/openssl-$(OPENSSL_VERSION)$(OPENSSL_SUBVER)
	$(TOUCH)

#
# libbluray
#
LIBBLURAY_VERSION = 0.5.0
LIBBLURAY_PATCH = libbluray-$(LIBBLURAY_VERSION).patch

$(ARCHIVE)/libbluray-$(LIBBLURAY_VERSION).tar.bz2:
	$(WGET) http://ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VERSION)/libbluray-$(LIBBLURAY_VERSION).tar.bz2

$(D)/libbluray: $(D)/bootstrap $(ARCHIVE)/libbluray-$(LIBBLURAY_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libbluray-$(LIBBLURAY_VERSION)
	$(UNTAR)/libbluray-$(LIBBLURAY_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libbluray-$(LIBBLURAY_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbluray.pc
	$(REWRITE_LIBTOOL)/libbluray.la
	$(REMOVE)/libbluray-$(LIBBLURAY_VERSION)
	$(TOUCH)

#
# lua
#
LUA_VERSION = 5.2.4
LUA_VERSION_SHORT = 5.2
LUAPOSIX_VERSION = 31
LUAPOSIX_PATCH = lua-$(LUA_VERSION)-luaposix-$(LUAPOSIX_VERSION).patch

$(ARCHIVE)/lua-$(LUA_VERSION).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz

$(D)/lua: $(D)/bootstrap $(D)/libncurses $(ARCHIVE)/lua-$(LUA_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/lua-$(LUA_VERSION)
	set -e; if [ ! -d $(ARCHIVE)/luaposix.git ]; \
		then cd $(ARCHIVE); git clone -b release-v$(LUAPOSIX_VERSION) git://github.com/luaposix/luaposix.git luaposix.git; \
		fi
	mkdir -p $(TARGETPREFIX)/usr/share/lua/$(LUA_VERSION_SHORT)
	$(UNTAR)/lua-$(LUA_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VERSION); \
		$(call post_patch,$(LUAPOSIX_PATCH)); \
		cp -r $(ARCHIVE)/luaposix.git .; \
		cd luaposix.git/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		cd luaposix.git/lib; cp *.lua $(TARGETPREFIX)/usr/share/lua/$(LUA_VERSION_SHORT); cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's|man/man1|/.remove|' Makefile; \
		$(MAKE) linux CC=$(TARGET)-gcc CPPFLAGS="$(TARGET_CPPFLAGS)" LDFLAGS="-L$(TARGETPREFIX)/usr/lib" BUILDMODE=dynamic PKG_VERSIONSION=$(LUA_VERSION); \
		$(MAKE) install INSTALL_TOP=$(TARGETPREFIX)/usr INSTALL_MAN=$(TARGETPREFIX)/.remove
	cd $(TARGETPREFIX)/usr && rm bin/lua bin/luac
	$(REMOVE)/lua-$(LUA_VERSION)
	$(TOUCH)

#
# luacurl
#
$(D)/luacurl: $(D)/bootstrap $(D)/libcurl $(D)/lua
	$(START_BUILD)
	$(REMOVE)/luacurl
	set -e; if [ -d $(ARCHIVE)/luacurl.git ]; \
		then cd $(ARCHIVE)/luacurl.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/Lua-cURL/Lua-cURLv3.git luacurl.git; \
		fi
	cp -ra $(ARCHIVE)/luacurl.git $(BUILD_TMP)/luacurl
	set -e; cd $(BUILD_TMP)/luacurl; \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGETPREFIX)/usr/lib" \
			LIBDIR=$(TARGETPREFIX)/usr/lib \
			LUA_INC=$(TARGETPREFIX)/usr/include; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) LUA_CMOD=/usr/lib/lua/$(LUA_VERSION_SHORT) LUA_LMOD=/usr/share/lua/$(LUA_VERSION_SHORT)
	$(REMOVE)/luacurl
	$(TOUCH)

#
# luaexpat
#
LUAEXPAT_VERSION = 1.3.0
LUAEXPAT_PATCH = luaexpat-$(LUAEXPAT_VERSION).patch

$(ARCHIVE)/luaexpat-$(LUAEXPAT_VERSION).tar.gz:
	$(WGET) http://matthewwild.co.uk/projects/luaexpat/luaexpat-$(LUAEXPAT_VERSION).tar.gz

$(D)/luaexpat: $(D)/bootstrap $(D)/lua $(D)/libexpat $(ARCHIVE)/luaexpat-$(LUAEXPAT_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/luaexpat-$(LUAEXPAT_VERSION)
	$(UNTAR)/luaexpat-$(LUAEXPAT_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/luaexpat-$(LUAEXPAT_VERSION); \
		$(call post_patch,$(LUAEXPAT_PATCH)); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="-L$(TARGETPREFIX)/usr/lib" PREFIX=$(TARGETPREFIX)/usr; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)/usr
	$(REMOVE)/luaexpat-$(LUAEXPAT_VERSION)
	$(TOUCH)

#
# luasocket
#
$(D)/luasocket: $(D)/bootstrap $(D)/lua
	$(START_BUILD)
	$(REMOVE)/luasocket
	set -e; if [ -d $(ARCHIVE)/luasocket.git ]; \
		then cd $(ARCHIVE)/luasocket.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/diegonehab/luasocket.git luasocket.git; \
		fi
	cp -ra $(ARCHIVE)/luasocket.git $(BUILD_TMP)/luasocket
	set -e; cd $(BUILD_TMP)/luasocket; \
		sed -i -e "s@LD_linux=gcc@LD_LINUX=$(TARGET)-gcc@" -e "s@CC_linux=gcc@CC_LINUX=$(TARGET)-gcc -L$(TARGETPREFIX)/usr/lib@" -e "s@DESTDIR?=@DESTDIR?=$(TARGETPREFIX)/usr@" src/makefile; \
		$(MAKE) CC=$(TARGET)-gcc LD=$(TARGET)-gcc LUAV=$(LUA_VERSION_SHORT) PLAT=linux COMPAT=COMPAT LUAINC_linux=$(TARGETPREFIX)/usr/include LUAPREFIX_linux=; \
		$(MAKE) install LUAPREFIX_linux= LUAV=$(LUA_VERSION_SHORT)
	$(REMOVE)/luasocket
	$(TOUCH)

#
# lua-feedparser
#
$(D)/lua-feedparser: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat
	$(START_BUILD)
	$(REMOVE)/lua-feedparser
	set -e; if [ -d $(ARCHIVE)/lua-feedparser.git ]; \
		then cd $(ARCHIVE)/lua-feedparser.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/slact/lua-feedparser.git lua-feedparser.git; \
		fi
	cp -ra $(ARCHIVE)/lua-feedparser.git $(BUILD_TMP)/lua-feedparser
	set -e; cd $(BUILD_TMP)/lua-feedparser; \
		sed -i -e "s/^PREFIX.*//" -e "s/^LUA_DIR.*//" Makefile ; \
		$(BUILDENV) $(MAKE) install  LUA_DIR=$(TARGETPREFIX)/usr/share/lua/$(LUA_VERSION_SHORT)
	$(REMOVE)/lua-feedparser
	$(TOUCH)

#
# luasoap
#
LUASOAP_VERSION = 3.0
LUASOAP_PATCH = luasoap-$(LUASOAP_VERSION).patch

$(ARCHIVE)/luasoap-$(LUASOAP_VERSION).tar.gz:
	$(WGET) https://github.com/downloads/tomasguisasola/luasoap/luasoap-$(LUASOAP_VERSION).tar.gz

$(D)/luasoap: $(D)/bootstrap $(D)/lua $(D)/luasocket $(D)/luaexpat $(ARCHIVE)/luasoap-$(LUASOAP_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/luasoap-$(LUASOAP_VERSION)
	$(UNTAR)/luasoap-$(LUASOAP_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/luasoap-$(LUASOAP_VERSION); \
		$(call post_patch,$(LUASOAP_PATCH)); \
		$(MAKE) install LUA_DIR=$(TARGETPREFIX)/usr/share/lua/$(LUA_VERSION_SHORT)
	$(REMOVE)/luasoap-$(LUASOAP_VERSION)
	$(TOUCH)

#
# luajson
#
$(ARCHIVE)/json.lua:
	$(WGET) http://github.com/swiboe/swiboe/raw/master/term_gui/json.lua

$(D)/luajson: $(D)/bootstrap $(D)/lua $(ARCHIVE)/json.lua
	$(START_BUILD)
	cp $(ARCHIVE)/json.lua $(TARGETPREFIX)/usr/share/lua/$(LUA_VERSION_SHORT)/json.lua
	$(TOUCH)

#
# libboost
#
BOOST_VERSION_MAJOR = 1
BOOST_VERSION_MINOR = 61
BOOST_VERSION_MICRO = 0
BOOST_VERSION_ARCHIVE = $(BOOST_VERSION_MAJOR).$(BOOST_VERSION_MINOR).$(BOOST_VERSION_MICRO)
BOOST_VERSION = $(BOOST_VERSION_MAJOR)_$(BOOST_VERSION_MINOR)_$(BOOST_VERSION_MICRO)
BOOST_PATCH = libboost$(BOOST_VERSION).patch

$(ARCHIVE)/boost_$(BOOST_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/boost/files/boost/$(BOOST_VERSION_ARCHIVE)/boost_$(BOOST_VERSION).tar.bz2

$(D)/libboost: $(D)/bootstrap $(ARCHIVE)/boost_$(BOOST_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/boost_$(BOOST_VERSION)
	$(UNTAR)/boost_$(BOOST_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/boost_$(BOOST_VERSION); \
		$(call post_patch,$(BOOST_PATCH)); \
		rm -rf $(TARGETPREFIX)/usr/include/boost; \
		mv $(BUILD_TMP)/boost_$(BOOST_VERSION)/boost $(TARGETPREFIX)/usr/include/boost
	$(REMOVE)/boost_$(BOOST_VERSION)
	$(TOUCH)

#
# zlib
#
ZLIB_VERSION = 1.2.10
ZLIB_Patch = zlib-$(ZLIB_VERSION).patch

$(ARCHIVE)/zlib-$(ZLIB_VERSION).tar.xz:
	$(WGET) http://www.zlib.net/zlib-$(ZLIB_VERSION).tar.xz

$(D)/zlib: $(D)/bootstrap $(ARCHIVE)/zlib-$(ZLIB_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/zlib-$(ZLIB_VERSION)
	$(UNTAR)/zlib-$(ZLIB_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/zlib-$(ZLIB_VERSION); \
		$(call post_patch,$(ZLIB_Patch)); \
		CC=$(TARGET)-gcc mandir=$(TARGETPREFIX)/.remove CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--prefix=/usr \
			--shared \
			--uname=Linux \
		; \
		$(MAKE); \
		ln -sf /bin/true ldconfig; \
		$(MAKE) install prefix=$(TARGETPREFIX)/usr
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VERSION)
	$(TOUCH)

#
# bzip2
#
BZIP2_VERSION = 1.0.6
BZIP2_Patch = bzip2-$(BZIP2_VERSION).patch

$(ARCHIVE)/bzip2-$(BZIP2_VERSION).tar.gz:
	$(WGET) http://www.bzip.org/$(BZIP2_VERSION)/bzip2-$(BZIP2_VERSION).tar.gz

$(D)/bzip2: $(D)/bootstrap $(ARCHIVE)/bzip2-$(BZIP2_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/bzip2-$(BZIP2_VERSION)
	$(UNTAR)/bzip2-$(BZIP2_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/bzip2-$(BZIP2_VERSION); \
		$(call post_patch,$(BZIP2_Patch)); \
		mv Makefile-libbz2_so Makefile; \
		CC=$(TARGET)-gcc AR=$(TARGET)-ar RANLIB=$(TARGET)-ranlib \
		$(MAKE) all; \
		$(MAKE) install PREFIX=$(TARGETPREFIX)/usr
	cd $(TARGETPREFIX) && rm -f usr/bin/bzip2
	$(REMOVE)/bzip2-$(BZIP2_VERSION)
	$(TOUCH)

#
# timezone
#
TZ_VERSION = 2016a
TZDATA_ZONELIST = africa antarctica asia australasia europe northamerica southamerica pacificnew etcetera backward
DEFAULT_TIMEZONE ?= "CET"
#ln -s /usr/share/zoneinfo/<country>/<city> /etc/localtime

$(ARCHIVE)/tzdata$(TZ_VERSION).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(TZ_VERSION).tar.gz

$(D)/timezone: $(D)/bootstrap find-zic $(ARCHIVE)/tzdata$(TZ_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/timezone
	mkdir $(BUILD_TMP)/timezone
	tar -C $(BUILD_TMP)/timezone -xf $(ARCHIVE)/tzdata$(TZ_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/timezone; \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		for zone in $(TZDATA_ZONELIST); do \
			zic -d zoneinfo -L /dev/null -y yearistype.sh $$zone ; \
			: zic -d zoneinfo/posix -L /dev/null -y yearistype.sh $$zone ; \
			: zic -d zoneinfo/right -L leapseconds -y yearistype.sh $$zone ; \
		done; \
		install -d -m 0755 $(TARGETPREFIX)/usr/share $(TARGETPREFIX)/etc; \
		cp -a zoneinfo $(TARGETPREFIX)/usr/share/; \
		cp -v zone.tab iso3166.tab $(TARGETPREFIX)/usr/share/zoneinfo/; \
		# Install default timezone
		if [ -e $(TARGETPREFIX)/usr/share/zoneinfo/$(DEFAULT_TIMEZONE) ]; then \
			echo ${DEFAULT_TIMEZONE} > $(TARGETPREFIX)/etc/timezone; \
		fi; \
	install -m 0644 $(SKEL_ROOT)/etc/timezone.xml $(TARGETPREFIX)/etc/
	$(REMOVE)/timezone
	$(TOUCH)

#
# libfreetype
#
FREETYPE_VERSION = 2.7.1
FREETYPE_PATCH = libfreetype-$(FREETYPE_VERSION).patch

$(ARCHIVE)/freetype-$(FREETYPE_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VERSION)/freetype-$(FREETYPE_VERSION).tar.bz2

$(D)/libfreetype: $(D)/bootstrap $(D)/zlib $(D)/bzip2 $(D)/libpng $(ARCHIVE)/freetype-$(FREETYPE_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/freetype-$(FREETYPE_VERSION)
	$(UNTAR)/freetype-$(FREETYPE_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/freetype-$(FREETYPE_VERSION); \
		$(call post_patch,$(FREETYPE_PATCH)); \
		sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg; \
		sed -r "s:.*(#.*SUBPIXEL_(RENDERING|HINTING  2)) .*:\1:g" \
			-i include/freetype/config/ftoption.h; \
		$(CONFIGURE) \
			--prefix=$(TARGETPREFIX)/usr \
			--mandir=$(TARGETPREFIX)/.remove \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install; \
		if [ ! -e $(TARGETPREFIX)/usr/include/freetype ] ; then \
			ln -sf freetype2 $(TARGETPREFIX)/usr/include/freetype; \
		fi; \
		mv $(TARGETPREFIX)/usr/bin/freetype-config $(HOSTPREFIX)/bin/freetype-config
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-$(FREETYPE_VERSION)
	$(TOUCH)

#
# lirc
#
LIRC_VERSION = 0.9.0
LIRC_PATCH = lirc-$(LIRC_VERSION).patch

$(ARCHIVE)/lirc-$(LIRC_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/lirc/files/LIRC/$(LIRC_VERSION)/lirc-$(LIRC_VERSION).tar.bz2

ifeq ($(IMAGE), $(filter $(IMAGE), neutrino neutrino-wlandriver))
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
LIRC_OPTS = -D__KERNEL_STRICT_NAMES -DUINPUT_NEUTRINO_HACK -DSPARK -I$(DRIVER_DIR)/frontcontroller/aotom_spark
else
LIRC_OPTS = -D__KERNEL_STRICT_NAMES
endif
else
LIRC_OPTS = -D__KERNEL_STRICT_NAMES
endif

$(D)/lirc: $(D)/bootstrap $(ARCHIVE)/lirc-$(LIRC_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/lirc-$(LIRC_VERSION)
	$(UNTAR)/lirc-$(LIRC_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/lirc-$(LIRC_VERSION); \
		$(call post_patch,$(LIRC_PATCH)); \
		$(CONFIGURE) \
		ac_cv_path_LIBUSB_CONFIG= \
		CFLAGS="$(TARGET_CFLAGS) $(LIRC_OPTS)" \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/liblirc_client.la
	$(REMOVE)/lirc-$(LIRC_VERSION)
	$(TOUCH)

#
# libjpeg
#
JPEG_VERSION = 8d
JPEG_PATCH = jpeg-$(JPEG_VERSION).patch

$(ARCHIVE)/jpegsrc.v$(JPEG_VERSION).tar.gz:
	$(WGET) http://www.ijg.org/files/jpegsrc.v$(JPEG_VERSION).tar.gz

$(D)/libjpeg_old: $(D)/bootstrap $(ARCHIVE)/jpegsrc.v$(JPEG_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/jpeg-$(JPEG_VERSION)
	$(UNTAR)/jpegsrc.v$(JPEG_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/jpeg-$(JPEG_VERSION); \
		$(call post_patch,$(JPEG_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REMOVE)/jpeg-$(JPEG_VERSION)
	$(TOUCH)

#
# libjpeg_turbo
#
JPEG_TURBO_VERSION = 1.5.1

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO_VERSION)/libjpeg-turbo-$(JPEG_TURBO_VERSION).tar.gz

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
$(D)/libjpeg: $(D)/libjpeg_old
	@touch $@
else
$(D)/libjpeg: $(D)/libjpeg_turbo
	@touch $@
endif

$(D)/libjpeg_turbo: $(D)/bootstrap $(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO_VERSION)
	$(UNTAR)/libjpeg-turbo-$(JPEG_TURBO_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libjpeg-turbo-$(JPEG_TURBO_VERSION); \
		export CC=$(TARGET)-gcc; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--mandir=/.remove \
			--docdir=/.remove \
			--bindir=/.remove \
			--includedir=/.remove \
			--with-jpeg8 \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
		make clean; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--mandir=/.remove \
			--docdir=/.remove \
			--bindir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libjpeg.pc
	rm -f $(TARGETPREFIX)/usr/lib/libturbojpeg* $(TARGETPREFIX)/usr/include/turbojpeg.h $(PKG_CONFIG_PATH)/libturbojpeg.pc
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO_VERSION)
	$(TOUCH)

#
# libpng
#
PNG_VERSION = 1.6.25
PNG_VERSION_X = 16
PNG_PATCH = libpng-$(PNG_VERSION)-disable-tools.patch

$(ARCHIVE)/libpng-$(PNG_VERSION).tar.xz:
	$(WGET) http://sourceforge.net/projects/libpng/files/libpng$(PNG_VERSION_X)/$(PNG_VERSION)/libpng-$(PNG_VERSION).tar.xz

$(D)/libpng: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/libpng-$(PNG_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libpng-$(PNG_VERSION)
	$(UNTAR)/libpng-$(PNG_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libpng-$(PNG_VERSION); \
		$(call post_patch,$(PNG_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(TARGETPREFIX)/usr \
			--mandir=$(TARGETPREFIX)/.remove \
			--bindir=$(HOSTPREFIX)/bin \
		; \
		ECHO=echo $(MAKE) all; \
		$(MAKE) install
	$(REMOVE)/libpng-$(PNG_VERSION)
	$(TOUCH)

#
# png++
#
PNGPP_VERSION = 0.2.9

$(ARCHIVE)/png++-$(PNGPP_VERSION).tar.gz:
	$(WGET) http://download.savannah.gnu.org/releases/pngpp/png++-$(PNGPP_VERSION).tar.gz

$(D)/png++: $(D)/bootstrap $(D)/libpng $(ARCHIVE)/png++-$(PNGPP_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/png++-$(PNGPP_VERSION)
	$(UNTAR)/png++-$(PNGPP_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/png++-$(PNGPP_VERSION); \
		$(MAKE) install-headers PREFIX=$(TARGETPREFIX)/usr
	$(REMOVE)/png++-$(PNGPP_VERSION)
	$(TOUCH)

#
# libungif
#
UNGIF_VERSION = 4.1.4

$(ARCHIVE)/libungif-$(UNGIF_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/libungif-4.x/libungif-$(UNGIF_VERSION)/libungif-$(UNGIF_VERSION).tar.bz2

$(D)/libungif: $(D)/bootstrap $(ARCHIVE)/libungif-$(UNGIF_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libungif-$(UNGIF_VERSION)
	$(UNTAR)/libungif-$(UNGIF_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libungif-$(UNGIF_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--without-x \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
	$(REWRITE_LIBTOOL)/libungif.la
	$(REMOVE)/libungif-$(UNGIF_VERSION)
	$(TOUCH)

#
# libgif
#
GIFLIB_VERSION = 5.1.4

$(ARCHIVE)/giflib-$(GIFLIB_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/giflib-$(GIFLIB_VERSION).tar.bz2

$(D)/libgif: $(D)/bootstrap $(ARCHIVE)/giflib-$(GIFLIB_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/giflib-$(GIFLIB_VERSION)
	$(UNTAR)/giflib-$(GIFLIB_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/giflib-$(GIFLIB_VERSION); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
	$(REWRITE_LIBTOOL)/libgif.la
	$(REMOVE)/giflib-$(GIFLIB_VERSION)
	$(TOUCH)

#
# libcurl
#
CURL_VERSION = 7.52.1
CURL_PATCH = libcurl-$(CURL_VERSION).patch

$(ARCHIVE)/curl-$(CURL_VERSION).tar.bz2:
	$(WGET) https://curl.haxx.se/download/curl-$(CURL_VERSION).tar.bz2

$(D)/libcurl: $(D)/bootstrap $(D)/openssl $(D)/zlib $(ARCHIVE)/curl-$(CURL_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/curl-$(CURL_VERSION)
	$(UNTAR)/curl-$(CURL_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/curl-$(CURL_VERSION); \
		$(call post_patch,$(CURL_PATCH)); \
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
			--with-ssl=$(TARGETPREFIX) \
		; \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config; \
		chmod 755 $(HOSTPREFIX)/bin/curl-config; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		rm -f $(TARGETPREFIX)/usr/bin/curl-config
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	cd $(TARGETPREFIX) && rm usr/bin/curl
	$(REMOVE)/curl-$(CURL_VERSION)
	$(TOUCH)

#
# libfribidi
#
FRIBIDI_VERSION = 0.19.7

$(ARCHIVE)/fribidi-$(FRIBIDI_VERSION).tar.bz2:
	$(WGET) http://fribidi.org/download/fribidi-$(FRIBIDI_VERSION).tar.bz2

$(D)/libfribidi: $(D)/bootstrap $(ARCHIVE)/fribidi-$(FRIBIDI_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/fribidi-$(FRIBIDI_VERSION)
	$(UNTAR)/fribidi-$(FRIBIDI_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/fribidi-$(FRIBIDI_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fribidi.pc
	$(REWRITE_LIBTOOL)/libfribidi.la
	cd $(TARGETPREFIX) && rm usr/bin/fribidi
	$(REMOVE)/fribidi-$(FRIBIDI_VERSION)
	$(TOUCH)

#
# libsigc++_e2
#
LIBSIGC_VERSION_MAJOR_E2 = 1
LIBSIGC_VERSION_MINOR_E2 = 2
LIBSIGC_VERSION_MICRO_E2 = 7
LIBSIGC_VERSION_E2 = $(LIBSIGC_VERSION_MAJOR_E2).$(LIBSIGC_VERSION_MINOR_E2).$(LIBSIGC_VERSION_MICRO_E2)

$(ARCHIVE)/libsigc++-$(LIBSIGC_VERSION_E2).tar.gz:
	$(WGET) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_VERSION_MAJOR_E2).$(LIBSIGC_VERSION_MINOR_E2)/libsigc++-$(LIBSIGC_VERSION_E2).tar.gz

$(D)/libsigc_e2: $(D)/bootstrap $(ARCHIVE)/libsigc++-$(LIBSIGC_VERSION_E2).tar.gz
	$(START_BUILD)
	$(REMOVE)/libsigc++-$(LIBSIGC_VERSION_E2)
	$(UNTAR)/libsigc++-$(LIBSIGC_VERSION_E2).tar.gz
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGC_VERSION_E2); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-checks \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-1.2.pc
	$(REWRITE_LIBTOOL)/libsigc-1.2.la
	$(REMOVE)/libsigc++-$(LIBSIGC_VERSION_E2)
	$(TOUCH)

#
# libsigc++
#
LIBSIGC_VERSION_MAJOR = 2
LIBSIGC_VERSION_MINOR = 4
LIBSIGC_VERSION_MICRO = 1
LIBSIGC_VERSION = $(LIBSIGC_VERSION_MAJOR).$(LIBSIGC_VERSION_MINOR).$(LIBSIGC_VERSION_MICRO)

$(ARCHIVE)/libsigc++-$(LIBSIGC_VERSION).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_VERSION_MAJOR).$(LIBSIGC_VERSION_MINOR)/libsigc++-$(LIBSIGC_VERSION).tar.xz

$(D)/libsigc: $(D)/bootstrap $(ARCHIVE)/libsigc++-$(LIBSIGC_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libsigc++-$(LIBSIGC_VERSION)
	$(UNTAR)/libsigc++-$(LIBSIGC_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGC_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-documentation \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
		if [ -d $(TARGETPREFIX)/usr/include/sigc++-2.0/sigc++ ] ; then \
			ln -sf ./sigc++-2.0/sigc++ $(TARGETPREFIX)/usr/include/sigc++; \
		fi;
		mv $(TARGETPREFIX)/usr/lib/sigc++-2.0/include/sigc++config.h $(TARGETPREFIX)/usr/include; \
		rm -fr $(TARGETPREFIX)/usr/lib/sigc++-2.0
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-2.0.pc
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	$(REMOVE)/libsigc++-$(LIBSIGC_VERSION)
	$(TOUCH)

#
# libmad
#
MAD_VERSION = 0.15.1b
MAD_PATCH = libmad-$(MAD_VERSION).patch

$(ARCHIVE)/libmad-$(MAD_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/mad/files/libmad/$(MAD_VERSION)/libmad-$(MAD_VERSION).tar.gz

$(D)/libmad: $(D)/bootstrap $(ARCHIVE)/libmad-$(MAD_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libmad-$(MAD_VERSION)
	$(UNTAR)/libmad-$(MAD_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libmad-$(MAD_VERSION); \
		$(call post_patch,$(MAD_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-debugging \
			--enable-shared=yes \
			--enable-speed \
			--enable-sso \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/mad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(MAD_VERSION)
	$(TOUCH)

#
# libid3tag
#
ID3TAG_VERSION = 0.15.1b
ID3TAG_PATCH = libid3tag-$(ID3TAG_VERSION).patch

$(ARCHIVE)/libid3tag-$(ID3TAG_VERSION)$(ID3TAG_SUBVER).tar.gz:
	$(WGET) http://sourceforge.net/projects/mad/files/libid3tag/$(ID3TAG_VERSION)/libid3tag-$(ID3TAG_VERSION).tar.gz

$(D)/libid3tag: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/libid3tag-$(ID3TAG_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libid3tag-$(ID3TAG_VERSION)
	$(UNTAR)/libid3tag-$(ID3TAG_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libid3tag-$(ID3TAG_VERSION); \
		$(call post_patch,$(ID3TAG_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared=yes \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/id3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-$(ID3TAG_VERSION)
	$(TOUCH)

#
# libvorbis
#
VORBIS_VERSION = 1.3.5

$(ARCHIVE)/libvorbis-$(VORBIS_VERSION).tar.xz:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-$(VORBIS_VERSION).tar.xz

$(D)/libvorbis: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/libvorbis-$(VORBIS_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libvorbis-$(VORBIS_VERSION)
	$(UNTAR)/libvorbis-$(VORBIS_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libvorbis-$(VORBIS_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
			--disable-docs \
			--disable-examples \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbis.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisenc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisfile.pc
	$(REWRITE_LIBTOOL)/libvorbis.la
	$(REWRITE_LIBTOOL)/libvorbisenc.la
	$(REWRITE_LIBTOOL)/libvorbisfile.la
	$(REWRITE_LIBTOOLDEP)/libvorbis.la
	$(REWRITE_LIBTOOLDEP)/libvorbisenc.la
	$(REWRITE_LIBTOOLDEP)/libvorbisfile.la
	$(REMOVE)/libvorbis-$(VORBIS_VERSION)
	$(TOUCH)

#
# libvorbisidec
#
VORBISIDEC_SVN = 18153
VORBISIDEC_VERSION = 1.0.2+svn$(VORBISIDEC_SVN)
VORBISIDEC_VERSION_APPEND = .orig
VORBISIDEC_PATCH = libvorbisidec-$(VORBISIDEC_VERSION).patch

$(ARCHIVE)/libvorbisidec_$(VORBISIDEC_VERSION)$(VORBISIDEC_VERSION_APPEND).tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(VORBISIDEC_VERSION)$(VORBISIDEC_VERSION_APPEND).tar.gz

$(D)/libvorbisidec: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/libvorbisidec_$(VORBISIDEC_VERSION)$(VORBISIDEC_VERSION_APPEND).tar.gz
	$(START_BUILD)
	$(REMOVE)/libvorbisidec-$(VORBISIDEC_VERSION)
	$(UNTAR)/libvorbisidec_$(VORBISIDEC_VERSION)$(VORBISIDEC_VERSION_APPEND).tar.gz
	set -e; cd $(BUILD_TMP)/libvorbisidec-$(VORBISIDEC_VERSION); \
		$(call post_patch,$(VORBISIDEC_PATCH)); \
		ACLOCAL_FLAGS="-I . -I $(TARGETPREFIX)/usr/share/aclocal" \
		$(BUILDENV) ./autogen.sh $(CONFIGURE_OPTS) --prefix=/usr; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(REMOVE)/libvorbisidec-$(VORBISIDEC_VERSION)
	$(TOUCH)

#
# libiconv
#
ICONV_VERSION = 1.14

$(ARCHIVE)/libiconv-$(ICONV_VERSION).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(ICONV_VERSION).tar.gz

$(D)/libiconv: $(D)/bootstrap $(ARCHIVE)/libiconv-$(ICONV_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libiconv-$(ICONV_ER)
	$(UNTAR)/libiconv-$(ICONV_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libiconv-$(ICONV_VERSION); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--bindir=/.remove \
			--datarootdir=/.remove \
			--enable-static \
			--disable-shared \
		; \
		$(MAKE); \
		cp ./srcm4/* $(HOSTPREFIX)/share/aclocal/ ; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libiconv.la
	$(REMOVE)/libiconv-$(ICONV_VERSION)
	$(TOUCH)

#
# libexpat
#
EXPAT_VERSION = 2.1.1

$(ARCHIVE)/expat-$(EXPAT_VERSION).tar.bz2:
	$(WGET) https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)/expat-$(EXPAT_VERSION).tar.bz2

$(D)/libexpat: $(D)/bootstrap $(ARCHIVE)/expat-$(EXPAT_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/expat-$(EXPAT_VERSION)
	$(UNTAR)/expat-$(EXPAT_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/expat-$(EXPAT_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--bindir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/expat-$(EXPAT_VERSION)
	$(TOUCH)

#
# fontconfig
#
FONTCONFIG_VERSION = 2.11.93

$(ARCHIVE)/fontconfig-$(FONTCONFIG_VERSION).tar.bz2:
	$(WGET) http://www.freedesktop.org/software/fontconfig/release/fontconfig-$(FONTCONFIG_VERSION).tar.bz2

$(D)/fontconfig: $(D)/bootstrap $(D)/libfreetype $(D)/libexpat $(ARCHIVE)/fontconfig-$(FONTCONFIG_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/fontconfig-$(FONTCONFIG_VERSION)
	$(UNTAR)/fontconfig-$(FONTCONFIG_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/fontconfig-$(FONTCONFIG_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-freetype-config=$(hostprefix)/bin/freetype-config \
			--with-expat-includes=$(TARGETPREFIX)/usr/include \
			--with-expat-lib=$(TARGETPREFIX)/usr/lib \
			--sysconfdir=/etc \
			--disable-docs \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libfontconfig.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fontconfig.pc
	$(REMOVE)/fontconfig-$(FONTCONFIG_VERSION)
	$(TOUCH)

#
# libdvdcss
#
LIBDVDCSS_VERSION = 1.2.13

$(ARCHIVE)/libdvdcss-$(LIBDVDCSS_VERSION).tar.bz2:
	$(WGET) http://download.videolan.org/pub/libdvdcss/$(LIBDVDCSS_VERSION)/$(lastword $(subst /, ,$@))

$(D)/libdvdcss: $(D)/bootstrap $(ARCHIVE)/libdvdcss-$(LIBDVDCSS_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libdvdcss-$(LIBDVDCSS_VERSION)
	$(UNTAR)/libdvdcss-$(LIBDVDCSS_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libdvdcss-$(LIBDVDCSS_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-doc \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvdcss.pc
	$(REWRITE_LIBTOOL)/libdvdcss.la
	$(REMOVE)/libdvdcss-$(LIBDVDCSS_VERSION)
	$(TOUCH)

#
# libdvdnav
#
LIBDVDNAV_VERSION = 4.2.1
LIBDVDNAV_PATCH = libdvdnav-$(LIBDVDNAV_VERSION).patch

$(ARCHIVE)/libdvdnav-$(LIBDVDNAV_VERSION).tar.xz:
	$(WGET) http://dvdnav.mplayerhq.hu/releases/libdvdnav-$(LIBDVDNAV_VERSION).tar.xz

$(D)/libdvdnav: $(D)/bootstrap $(D)/libdvdread $(ARCHIVE)/libdvdnav-$(LIBDVDNAV_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libdvdnav-$(LIBDVDNAV_VERSION)
	$(UNTAR)/libdvdnav-$(LIBDVDNAV_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libdvdnav-$(LIBDVDNAV_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdnav.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdnavmini.pc
	$(REWRITE_LIBTOOL)/libdvdnav.la
	$(REWRITE_LIBTOOL)/libdvdnavmini.la
	$(REMOVE)/libdvdnav-$(LIBDVDNAV_VERSION)
	$(TOUCH)

#
# libdvdread
#
LIBDVDREAD_VERSION = 4.9.9
LIBDVDREAD_PATCH = libdvdread-$(LIBDVDREAD_VERSION).patch

$(ARCHIVE)/libdvdread-$(LIBDVDREAD_VERSION).tar.xz:
	$(WGET) http://dvdnav.mplayerhq.hu/releases/libdvdread-$(LIBDVDREAD_VERSION).tar.xz

$(D)/libdvdread: $(D)/bootstrap $(ARCHIVE)/libdvdread-$(LIBDVDREAD_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libdvdread-$(LIBDVDREAD_VERSION)
	$(UNTAR)/libdvdread-$(LIBDVDREAD_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libdvdread-$(LIBDVDREAD_VERSION); \
		$(call post_patch,$(LIBDVDREAD_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--enable-shared \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdread.pc
	$(REWRITE_LIBTOOL)/libdvdread.la
	$(REMOVE)/libdvdread-$(LIBDVDREAD_VERSION)
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
		./configure $(CONFIGURE_SILENT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdreamdvd.pc
	$(REWRITE_LIBTOOL)/libdreamdvd.la
	$(REMOVE)/libdreamdvd
	$(TOUCH)

#
# ffmpeg
#
FFMPEG_VERSION = 2.8.10
FFMPEG_PATCH  = ffmpeg-buffer-size-$(FFMPEG_VERSION).patch
FFMPEG_PATCH += ffmpeg-hds-libroxml-$(FFMPEG_VERSION).patch
FFMPEG_PATCH += ffmpeg-aac-$(FFMPEG_VERSION).patch
FFMPEG_PATCH += ffmpeg-kodi-$(FFMPEG_VERSION).patch

$(ARCHIVE)/ffmpeg-$(FFMPEG_VERSION).tar.xz:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VERSION).tar.xz

ifeq ($(IMAGE), enigma2)
FFMPEG_EXTRA  = --enable-librtmp
LIBRTMPDUMP = $(D)/librtmpdump
endif

ifeq ($(IMAGE), neutrino)
FFMPEG_EXTRA = --disable-iconv
endif

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/libass $(D)/libroxml $(LIBRTMPDUMP) $(ARCHIVE)/ffmpeg-$(FFMPEG_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/ffmpeg-$(FFMPEG_VERSION)
	$(UNTAR)/ffmpeg-$(FFMPEG_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VERSION); \
		$(call post_patch,$(FFMPEG_PATCH)); \
		./configure \
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
			--enable-decoder=dca \
			--enable-decoder=dvbsub \
			--enable-decoder=dvdsub \
			--enable-decoder=flac \
			--enable-decoder=h261 \
			--enable-decoder=h263 \
			--enable-decoder=h263i \
			--enable-decoder=h264 \
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
			$(FFMPEG_EXTRA) \
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
			--extra-cflags="-I$(TARGETPREFIX)/usr/include -ffunction-sections -fdata-sections" \
			--extra-ldflags="-L$(TARGETPREFIX)/usr/lib -Wl,--gc-sections,-lrt" \
			--target-os=linux \
			--arch=sh4 \
			--prefix=/usr \
			--mandir=/.remove \
			--datadir=/.remove \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavfilter.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswresample.pc
	test -e $(PKG_CONFIG_PATH)/libswscale.pc && $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswscale.pc || true
	$(REMOVE)/ffmpeg-$(FFMPEG_VERSION)
	$(TOUCH)

#
# libass
#
LIBASS_VERSION = 0.12.3
LIBASS_PATCH = libass-$(LIBASS_VERSION).patch

$(ARCHIVE)/libass-$(LIBASS_VERSION).tar.xz:
	$(WGET) https://github.com/libass/libass/releases/download/$(LIBASS_VERSION)/libass-$(LIBASS_VERSION).tar.xz

$(D)/libass: $(D)/bootstrap $(D)/libfreetype $(D)/libfribidi $(ARCHIVE)/libass-$(LIBASS_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libass-$(LIBASS_VERSION)
	$(UNTAR)/libass-$(LIBASS_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libass-$(LIBASS_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libass.pc
	$(REWRITE_LIBTOOL)/libass.la
	$(REMOVE)/libass-$(LIBASS_VERSION)
	$(TOUCH)

#
# sqlite
#
SQLITE_VERSION = 3160100

$(ARCHIVE)/sqlite-autoconf-$(SQLITE_VERSION).tar.gz:
	$(WGET) http://www.sqlite.org/2017/sqlite-autoconf-$(SQLITE_VERSION).tar.gz

$(D)/sqlite: $(D)/bootstrap $(ARCHIVE)/sqlite-autoconf-$(SQLITE_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VERSION)
	$(UNTAR)/sqlite-autoconf-$(SQLITE_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/sqlite-autoconf-$(SQLITE_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sqlite3.pc
	$(REWRITE_LIBTOOL)/libsqlite3.la
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VERSION)
	$(TOUCH)

#
# libsoup
#
LIBSOUP_VERSION_MAJOR = 2.50
LIBSOUP_VERSION_MINOR = 0
LIBSOUP_VERSION = $(LIBSOUP_VERSION_MAJOR).$(LIBSOUP_VERSION_MINOR)

$(ARCHIVE)/libsoup-$(LIBSOUP_VERSION).tar.xz:
	$(WGET) http://download.gnome.org/sources/libsoup/$(LIBSOUP_VERSION_MAJOR)/libsoup-$(LIBSOUP_VERSION).tar.xz

$(D)/libsoup: $(D)/bootstrap $(D)/sqlite $(D)/libxml2_e2 $(D)/libglib2 $(ARCHIVE)/libsoup-$(LIBSOUP_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libsoup-$(LIBSOUP_VERSION)
	$(UNTAR)/libsoup-$(LIBSOUP_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libsoup-$(LIBSOUP_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libsoup-2.4.pc
	$(REWRITE_LIBTOOL)/libsoup-2.4.la
	$(REMOVE)/libsoup-$(LIBSOUP_VERSION)
	$(TOUCH)

#
# libogg
#
OGG_VERSION = 1.3.2

$(ARCHIVE)/libogg-$(OGG_VERSION).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(OGG_VERSION).tar.gz

$(D)/libogg: $(D)/bootstrap $(ARCHIVE)/libogg-$(OGG_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libogg-$(OGG_VERSION)
	$(UNTAR)/libogg-$(OGG_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libogg-$(OGG_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
			--enable-shared \
			--disable-static \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(OGG_VERSION)
	$(TOUCH)

#
# libflac
#
FLAC_VERSION = 1.3.1
FLAC_PATCH = libflac-$(FLAC_VERSION).patch

$(ARCHIVE)/flac-$(FLAC_VERSION).tar.xz:
	$(WGET) http://downloads.xiph.org/releases/flac/flac-$(FLAC_VERSION).tar.xz

$(D)/libflac: $(D)/bootstrap $(ARCHIVE)/flac-$(FLAC_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/flac-$(FLAC_VERSION)
	$(UNTAR)/flac-$(FLAC_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/flac-$(FLAC_VERSION); \
		$(call post_patch,$(FLAC_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX) docdir=/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/flac.pc
	$(REWRITE_LIBTOOL)/libFLAC.la
	$(REMOVE)/flac-$(FLAC_VERSION)
	$(TOUCH)

#
# libxml2_e2
#
LIBXML2_E2_VERSION = 2.9.0
LIBXML2_E2_PATCH = libxml2-$(LIBXML2_E2_VERSION).patch

$(ARCHIVE)/libxml2-$(LIBXML2_E2_VERSION).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_E2_VERSION).tar.gz

$(D)/libxml2_e2: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/libxml2-$(LIBXML2_E2_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libxml2-$(LIBXML2_E2_VERSION).tar.gz
	$(UNTAR)/libxml2-$(LIBXML2_E2_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libxml2-$(LIBXML2_E2_VERSION); \
		$(call post_patch,$(LIBXML2_E2_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--with-python=$(HOSTPREFIX) \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX);
		mv $(TARGETPREFIX)/usr/bin/xml2-config $(HOSTPREFIX)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc $(HOSTPREFIX)/bin/xml2-config
	sed -i 's/^\(Libs:.*\)/\1 -lz/' $(PKG_CONFIG_PATH)/libxml-2.0.pc
		if [ -e "$(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxml2mod.la" ]; then \
			sed -e "/^dependency_libs/ s,/usr/lib/libxml2.la,$(TARGETPREFIX)/usr/lib/libxml2.la,g" -i $(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxml2mod.la; \
			sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(TARGETPREFIX)$(PYTHON_DIR)/site-packages,g" -i $(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxml2mod.la; \
		fi; \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(TARGETPREFIX)/usr/lib,g" -i $(TARGETPREFIX)/usr/lib/xml2Conf.sh; \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(TARGETPREFIX)/usr/include,g" -i $(TARGETPREFIX)/usr/lib/xml2Conf.sh
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REMOVE)/libxml2-$(LIBXML2_E2_VERSION)
	$(TOUCH)

#
# libxslt
#
LIBXSLT_VERSION = 1.1.28

$(ARCHIVE)/libxslt-$(LIBXSLT_VERSION).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxslt-$(LIBXSLT_VERSION).tar.gz

$(D)/libxslt: $(D)/bootstrap $(D)/libxml2_e2 $(ARCHIVE)/libxslt-$(LIBXSLT_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libxslt-$(LIBXSLT_VERSION)
	$(UNTAR)/libxslt-$(LIBXSLT_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libxslt-$(LIBXSLT_VERSION); \
		$(CONFIGURE) \
			CPPFLAGS="$(CPPFLAGS) -I$(TARGETPREFIX)/usr/include/libxml2" \
			--prefix=/usr \
			--with-libxml-prefix="$(HOSTPREFIX)" \
			--with-libxml-include-prefix="$(TARGETPREFIX)/usr/include" \
			--with-libxml-libs-prefix="$(TARGETPREFIX)/usr/lib" \
			--with-python=$(HOSTPREFIX) \
			--without-crypto \
			--without-debug \
			--without-mem-debug \
		; \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < xslt-config > $(HOSTPREFIX)/bin/xslt-config; \
		chmod 755 $(HOSTPREFIX)/bin/xslt-config; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		if [ -e "$(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxsltmod.la" ]; then \
			sed -e "/^dependency_libs/ s,/usr/lib/libexslt.la,$(TARGETPREFIX)/usr/lib/libexslt.la,g" -i $(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^dependency_libs/ s,/usr/lib/libxslt.la,$(TARGETPREFIX)/usr/lib/libxslt.la,g" -i $(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(TARGETPREFIX)$(PYTHON_DIR)/site-packages,g" -i $(TARGETPREFIX)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
		fi; \
		sed -e "/^XSLT_LIBDIR/ s,/usr/lib,$(TARGETPREFIX)/usr/lib,g" -i $(TARGETPREFIX)/usr/lib/xsltConf.sh; \
		sed -e "/^XSLT_INCLUDEDIR/ s,/usr/include,$(TARGETPREFIX)/usr/include,g" -i $(TARGETPREFIX)/usr/lib/xsltConf.sh
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexslt.pc $(HOSTPREFIX)/bin/xslt-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxslt.pc
	$(REWRITE_LIBTOOL)/libexslt.la
	$(REWRITE_LIBTOOL)/libxslt.la
	$(REWRITE_LIBTOOLDEP)/libexslt.la
	$(REMOVE)/libxslt-$(LIBXSLT_VERSION)
	$(TOUCH)

#
# libxml2 neutrino
#
LIBXML2_VERSION = 2.8.0

$(ARCHIVE)/libxml2-$(LIBXML2_VERSION).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_VERSION).tar.gz

$(D)/libxml2: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/libxml2-$(LIBXML2_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libxml2-$(LIBXML2_VERSION).tar.gz
	$(UNTAR)/libxml2-$(LIBXML2_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libxml2-$(LIBXML2_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datarootdir=/.remove \
			--enable-shared \
			--disable-static \
			--without-python \
			--with-minimum \
			--without-iconv \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX);
		mv $(TARGETPREFIX)/usr/bin/xml2-config $(HOSTPREFIX)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc $(HOSTPREFIX)/bin/xml2-config
	sed -i 's/^\(Libs:.*\)/\1 -lz/' $(PKG_CONFIG_PATH)/libxml-2.0.pc
	sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(TARGETPREFIX)/usr/lib,g" -i $(TARGETPREFIX)/usr/lib/xml2Conf.sh
	sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(TARGETPREFIX)/usr/include,g" -i $(TARGETPREFIX)/usr/lib/xml2Conf.sh
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REMOVE)/libxml2-$(LIBXML2_VERSION)
	$(TOUCH)

#
#libroxml
#
LIBROXML_VERSION = 2.3.0

$(ARCHIVE)/libroxml-$(LIBROXML_VERSION).tar.gz:
	$(WGET) http://download.libroxml.net/pool/v2.x/libroxml-$(LIBROXML_VERSION).tar.gz

$(D)/libroxml: $(D)/bootstrap $(ARCHIVE)/libroxml-$(LIBROXML_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libroxml-$(LIBROXML_VERSION)
	$(UNTAR)/libroxml-$(LIBROXML_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libroxml-$(LIBROXML_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--disable-roxml \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libroxml.pc
	$(REWRITE_LIBTOOL)/libroxml.la
	$(REMOVE)/libroxml-$(LIBROXML_VERSION)
	$(TOUCH)

#
# pugixml
#
PUGIXML_VERSION = 1.7

$(ARCHIVE)/pugixml-$(PUGIXML_VERSION).tar.gz:
	$(WGET) http://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VERSION)/pugixml-$(PUGIXML_VERSION).tar.gz

$(D)/pugixml: $(D)/bootstrap $(ARCHIVE)/pugixml-$(PUGIXML_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/pugixml-$(PUGIXML_VERSION)
	$(UNTAR)/pugixml-$(PUGIXML_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/pugixml-$(PUGIXML_VERSION); \
		cmake \
		--no-warn-unused-cli \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=Linux \
		-DCMAKE_C_COMPILER=$(TARGET)-gcc \
		-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
		-DCMAKE_C_FLAGS="-pipe -Os" \
		-DCMAKE_CXX_FLAGS="-pipe -Os" \
		scripts; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/pugixml-$(PUGIXML_VERSION)
	$(TOUCH)

#
# graphlcd
#
GRAPHLCD_PATCH = graphlcd-base-touchcol.patch

$(D)/graphlcd: $(D)/bootstrap $(D)/libfreetype $(D)/libusb
	$(START_BUILD)
	$(REMOVE)/graphlcd
	set -e; if [ -d $(ARCHIVE)/graphlcd-base-touchcol.git ]; \
		then cd $(ARCHIVE)/graphlcd-base-touchcol.git; git pull; \
		else cd $(ARCHIVE); git clone -b touchcol git://projects.vdr-developer.org/graphlcd-base.git graphlcd-base-touchcol.git; \
		fi
	cp -ra $(ARCHIVE)/graphlcd-base-touchcol.git $(BUILD_TMP)/graphlcd
	set -e; cd $(BUILD_TMP)/graphlcd; \
		$(call post_patch,$(GRAPHLCD_PATCH)); \
		export TARGET=$(TARGET)-; \
		$(BUILDENV) \
		$(MAKE) DESTDIR=$(TARGETPREFIX); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/graphlcd
	$(TOUCH)

#
# lcd4linux
#
$(D)/lcd4linux: $(D)/bootstrap $(D)/libusb_compat $(D)/libgd $(D)/libusb
	$(START_BUILD)
	$(REMOVE)/lcd4linux
	set -e; if [ -d $(ARCHIVE)/lcd4linux.git ]; \
		then cd $(ARCHIVE)/lcd4linux.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/lcd4linux.git lcd4linux.git; \
		fi
	cp -ra $(ARCHIVE)/lcd4linux.git $(BUILD_TMP)/lcd4linux
	set -e; cd $(BUILD_TMP)/lcd4linux; \
		$(BUILDENV) ./bootstrap; \
		$(BUILDENV) ./configure $(CONFIGURE_SILENT) $(CONFIGURE_OPTS) \
			--prefix=/usr \
			--with-drivers='DPF,SamsungSPF' \
			--with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' \
			--without-ncurses \
		; \
		$(MAKE) vcs_version all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -m 755 $(SKEL_ROOT)/etc/init.d/lcd4linux $(TARGETPREFIX)/etc/init.d/
	install -D -m 0600 $(SKEL_ROOT)/etc/lcd4linux_ni.conf $(TARGETPREFIX)/etc/lcd4linux.conf
	$(REMOVE)/lcd4linux
	$(TOUCH)

#
# libgd
#
GD_VERSION = 2.2.1

$(ARCHIVE)/libgd-$(GD_VERSION).tar.xz:
	$(WGET) https://github.com/libgd/libgd/releases/download/gd-$(GD_VERSION)/libgd-$(GD_VERSION).tar.xz

$(D)/libgd: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/libfreetype $(ARCHIVE)/libgd-$(GD_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/libgd-$(GD_VERSION)
	$(UNTAR)/libgd-$(GD_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/libgd-$(GD_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--enable-static \
			--disable-shared \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libgd.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gdlib.pc
	$(REMOVE)/libgd-$(GD_VERSION)
	$(TOUCH)

#
# libusb
#
LIBUSB_VERSION_MAJOR = 1.0
LIBUSB_VERSION_MINOR = 9
LIBUSB_VERSION = $(LIBUSB_VERSION_MAJOR).$(LIBUSB_VERSION_MINOR)
LIBUSB_PATCH = libusb-$(LIBUSB_VERSION).patch

$(ARCHIVE)/libusb-$(LIBUSB_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libusb/files/libusb-$(LIBUSB_VERSION_MAJOR)/libusb-$(LIBUSB_VERSION)/libusb-$(LIBUSB_VERSION).tar.bz2

$(D)/libusb: $(D)/bootstrap $(ARCHIVE)/libusb-$(LIBUSB_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libusb-$(LIBUSB_VERSION)
	$(UNTAR)/libusb-$(LIBUSB_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libusb-$(LIBUSB_VERSION); \
		$(call post_patch,$(USB_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--disable-log \
			--disable-debug-log \
			--disable-examples-build \
		; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libusb-1.0.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb-1.0.pc
	$(REMOVE)/libusb-$(LIBUSB_VERSION)
	$(TOUCH)

#
# libus-bcompat
#
LIBUSB_COMPAT_VERSION = 0.1.5

$(ARCHIVE)/libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libusb/files/libusb-compat-0.1/libusb-compat-$(LIBUSB_COMPAT_VERSION)/libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2

$(D)/libusb_compat: $(D)/bootstrap $(D)/libusb $(ARCHIVE)/libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VERSION)
	$(UNTAR)/libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libusb-compat-$(LIBUSB_COMPAT_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-log \
			--disable-debug-log \
			--disable-examples-build \
		; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f $(TARGETPREFIX)/usr/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb.pc
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VERSION)
	$(TOUCH)

#
# alsa-lib
#
ALSA_LIB_VERSION = 1.1.3
ALSA_LIB_PATCH  = alsa-lib-$(ALSA_LIB_VERSION).patch
ALSA_LIB_PATCH += alsa-lib-$(ALSA_LIB_VERSION)-link_fix.patch

$(ARCHIVE)/alsa-lib-$(ALSA_LIB_VERSION).tar.bz2:
	$(WGET) ftp://ftp.alsa-project.org/pub/lib/alsa-lib-$(ALSA_LIB_VERSION).tar.bz2

$(D)/alsa-lib: $(D)/bootstrap $(ARCHIVE)/alsa-lib-$(ALSA_LIB_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VERSION)
	$(UNTAR)/alsa-lib-$(ALSA_LIB_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/alsa-lib-$(ALSA_LIB_VERSION); \
		$(call post_patch,$(ALSA_LIB_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-alsa-devdir=/dev/snd/ \
			--with-plugindir=/usr/lib/alsa \
			--without-debug \
			--with-debug=no \
			--disable-aload \
			--disable-rawmidi \
			--disable-resmgr \
			--disable-old-symbols \
			--disable-alisp \
			--disable-hwdep \
			--disable-python \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/alsa.pc
	$(REWRITE_LIBTOOL)/libasound.la
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VERSION)
	$(TOUCH)

#
# alsa-utils
#
ALSA_UTILS_VERSION = $(ALSA_LIB_VERSION)

$(ARCHIVE)/alsa-utils-$(ALSA_UTILS_VERSION).tar.bz2:
	$(WGET) ftp://ftp.alsa-project.org/pub/utils/alsa-utils-$(ALSA_UTILS_VERSION).tar.bz2

$(D)/alsa-utils: $(D)/bootstrap $(D)/alsa-lib $(ARCHIVE)/alsa-utils-$(ALSA_UTILS_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/alsa-utils-$(ALSA_UTILS_VERSION)
	$(UNTAR)/alsa-utils-$(ALSA_UTILS_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/alsa-utils-$(ALSA_UTILS_VERSION); \
		sed -ir -r "s/(alsamixer|amidi|aplay|iecset|speaker-test|seq|alsactl|alsaucm|topology)//g" Makefile.am ;\
		autoreconf -fi -I $(TARGETPREFIX)/usr/share/aclocal; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/alsa-utils-$(ALSA_UTILS_VERSION)
	install -m 755 $(SKEL_ROOT)/etc/init.d/amixer $(TARGETPREFIX)/etc/init.d/amixer
	install -m 644 $(SKEL_ROOT)/etc/amixer.conf $(TARGETPREFIX)/etc/amixer.conf
	install -m 644 $(SKEL_ROOT)/etc/asound.conf $(TARGETPREFIX)/etc/asound.conf
	cd $(TARGETPREFIX) && rm -f usr/bin/aserver
	$(TOUCH)

#
# libopenthreads
#
LIBOPENTHREADS_VERSION = 2.6.0
LIBOPENTHREADS_PATCH = libopenthreads-$(LIBOPENTHREADS_VERSION).patch

$(ARCHIVE)/OpenThreads-$(LIBOPENTHREADS_VERSION).zip:
	$(WGET) http://trac.openscenegraph.org/downloads/developer_releases/OpenThreads-$(LIBOPENTHREADS_VERSION).zip

$(D)/libopenthreads: $(D)/bootstrap $(ARCHIVE)/OpenThreads-$(LIBOPENTHREADS_VERSION).zip
	$(START_BUILD)
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VERSION)
	unzip -q $(ARCHIVE)/OpenThreads-$(LIBOPENTHREADS_VERSION).zip -d $(BUILD_TMP)
	set -e; cd $(BUILD_TMP)/OpenThreads-$(LIBOPENTHREADS_VERSION); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)/usr
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VERSION)
	$(TOUCH)

#
# librtmpdump
#
LIBRTMPDUMP_PATCH = rtmpdump-2.4.patch

$(D)/librtmpdump: $(D)/bootstrap $(D)/zlib $(D)/openssl
	$(START_BUILD)
	$(REMOVE)/librtmpdump
	set -e; if [ -d $(ARCHIVE)/rtmpdump.git ]; \
		then cd $(ARCHIVE)/rtmpdump.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/oe-alliance/rtmpdump.git rtmpdump.git; \
		fi
	cp -ra $(ARCHIVE)/rtmpdump.git $(BUILD_TMP)/librtmpdump
	set -e; cd $(BUILD_TMP)/librtmpdump; \
		$(call post_patch,$(LIBRTMPDUMP_PATCH)); \
		$(BUILDENV) \
		$(MAKE) CROSS_COMPILE=$(TARGET)- ; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGETPREFIX) MANDIR=$(TARGETPREFIX)/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/librtmp.pc
	$(REMOVE)/librtmpdump
	$(TOUCH)

#
# libdvbsi++
#
LIBDVBSI++_PATCH = libdvbsi++-git.patch

$(D)/libdvbsi++: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/libdvbsi++
	set -e; if [ -d $(ARCHIVE)/libdvbsi++.git ]; \
		then cd $(ARCHIVE)/libdvbsi++.git; git pull; \
		else cd $(ARCHIVE); git clone git://git.opendreambox.org/git/obi/libdvbsi++.git libdvbsi++.git; \
		fi
	cp -ra $(ARCHIVE)/libdvbsi++.git $(BUILD_TMP)/libdvbsi++
	set -e; cd $(BUILD_TMP)/libdvbsi++; \
		$(call post_patch,$(LIBDVBSI++_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(TARGETPREFIX)/usr \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/libdvbsi++
	$(TOUCH)

#
# libmodplug
#
LIBMODPLUG_VERSION = 0.8.8.4

$(ARCHIVE)/libmodplug-$(LIBMODPLUG_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/modplug-xmms/files/libmodplug/$(LIBMODPLUG_VERSION)/libmodplug-$(LIBMODPLUG_VERSION).tar.gz

$(D)/libmodplug: $(D)/bootstrap $(ARCHIVE)/libmodplug-$(LIBMODPLUG_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libmodplug-$(LIBMODPLUG_VERSION)
	$(UNTAR)/libmodplug-$(LIBMODPLUG_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libmodplug-$(LIBMODPLUG_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libmodplug.pc
	$(REWRITE_LIBTOOL)/libmodplug.la
	$(REMOVE)/libmodplug-$(LIBMODPLUG_VERSION)
	$(TOUCH)

#
# lzo
#
LZO_VERSION = 2.09

$(ARCHIVE)/lzo-$(LZO_VERSION).tar.gz:
	$(WGET) http://www.oberhumer.com/opensource/lzo/download/lzo-$(LZO_VERSION).tar.gz

$(D)/lzo: $(D)/bootstrap $(ARCHIVE)/lzo-$(LZO_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/lzo-$(LZO_VERSION)
	$(UNTAR)/lzo-$(LZO_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/lzo-$(LZO_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/liblzo2.la
	$(REMOVE)/lzo-$(LZO_VERSION)
	$(TOUCH)

#
# minidlna
#
MINIDLNA_VERSION = 1.1.5
MINIDLNA_PATCH = minidlna-$(MINIDLNA_VERSION).patch

$(ARCHIVE)/minidlna-$(MINIDLNA_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/minidlna/files/minidlna/$(MINIDLNA_VERSION)/minidlna-$(MINIDLNA_VERSION).tar.gz

$(D)/minidlna: $(D)/bootstrap $(D)/zlib $(D)/sqlite $(D)/libexif $(D)/libjpeg $(D)/libid3tag $(D)/libogg $(D)/libvorbis $(D)/libflac $(D)/ffmpeg $(ARCHIVE)/minidlna-$(MINIDLNA_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/minidlna-$(MINIDLNA_VERSION)
	$(UNTAR)/minidlna-$(MINIDLNA_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/minidlna-$(MINIDLNA_VERSION); \
		$(call post_patch,$(MINIDLNA_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/minidlna-$(MINIDLNA_VERSION)
	$(TOUCH)

#
# libexif
#
LIBEXIF_VERSION = 0.6.21

$(ARCHIVE)/libexif-$(LIBEXIF_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/libexif/files/libexif/$(LIBEXIF_VERSION)/libexif-$(LIBEXIF_VERSION).tar.gz

$(D)/libexif: $(D)/bootstrap $(ARCHIVE)/libexif-$(LIBEXIF_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libexif-$(LIBEXIF_VERSION)
	$(UNTAR)/libexif-$(LIBEXIF_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libexif-$(LIBEXIF_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexif.pc
	$(REWRITE_LIBTOOL)/libexif.la
	$(REMOVE)/libexif-$(LIBEXIF_VERSION)
	$(TOUCH)

#
# djmount
#
DJMOUNT_VERSION = 0.71

$(ARCHIVE)/djmount-$(DJMOUNT_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VERSION)/djmount-$(DJMOUNT_VERSION).tar.gz

$(D)/djmount: $(D)/bootstrap $(D)/fuse $(ARCHIVE)/djmount-$(DJMOUNT_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/djmount-$(DJMOUNT_VERSION)
	$(UNTAR)/djmount-$(DJMOUNT_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/djmount-$(DJMOUNT_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/djmount-$(DJMOUNT_VERSION)
	$(TOUCH)

#
# libupnp
#
LIBUPNP_VERSION = 1.6.19

$(ARCHIVE)/libupnp-$(LIBUPNP_VERSION).tar.bz2:
	$(WGET) http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP\ $(LIBUPNP_VERSION)/libupnp-$(LIBUPNP_VERSION).tar.bz2

$(D)/libupnp: $(D)/bootstrap $(ARCHIVE)/libupnp-$(LIBUPNP_VERSION).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libupnp-$(LIBUPNP_VERSION)
	$(UNTAR)/libupnp-$(LIBUPNP_VERSION).tar.bz2
	set -e; cd $(BUILD_TMP)/libupnp-$(LIBUPNP_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REMOVE)/libupnp-$(LIBUPNP_VERSION)
	$(TOUCH)

#
# rarfs
#
RARFS_VERSION = 0.1.1

$(ARCHIVE)/rarfs-$(RARFS_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/rarfs/files/rarfs/$(RARFS_VERSION)/rarfs-$(RARFS_VERSION).tar.gz

$(D)/rarfs: $(D)/bootstrap $(D)/fuse $(ARCHIVE)/rarfs-$(RARFS_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/rarfs-$(RARFS_VERSION)
	$(UNTAR)/rarfs-$(RARFS_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/rarfs-$(RARFS_VERSION); \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		$(CONFIGURE) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
			--disable-option-checking \
			--includedir=/usr/include/fuse \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/rarfs-$(RARFS_VERSION)
	$(TOUCH)

#
# sshfs
#
SSHFS_VERSION = 2.5

$(ARCHIVE)/sshfs-fuse-$(SSHFS_VERSION).tar.gz:
	$(WGET) https://fossies.org/linux/misc/sshfs-fuse-$(SSHFS_VERSION).tar.gz

$(D)/sshfs: $(D)/bootstrap $(D)/libglib2 $(D)/fuse $(ARCHIVE)/sshfs-fuse-$(SSHFS_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/sshfs-fuse-$(SSHFS_VERSION)
	$(UNTAR)/sshfs-fuse-$(SSHFS_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/sshfs-fuse-$(SSHFS_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/sshfs-fuse-$(SSHFS_VERSION)
	$(TOUCH)

#
# howl
#
HOWL_VERSION = 1.0.0

$(ARCHIVE)/howl-$(HOWL_VERSION).tar.gz:
	$(WGET) http://sourceforge.net/projects/howl/files/howl/$(HOWL_VERSION)/howl-$(HOWL_VERSION).tar.gz

$(D)/howl: $(D)/bootstrap $(ARCHIVE)/howl-$(HOWL_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/howl-$(HOWL_VERSION)
	$(UNTAR)/howl-$(HOWL_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/howl-$(HOWL_VERSION); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/howl.pc
	$(REWRITE_LIBTOOL)/libhowl.la
	$(REMOVE)/howl-$(HOWL_VERSION)
	$(TOUCH)

#
# libdaemon
#
LIBDAEMON_VERSION = 0.14

$(ARCHIVE)/libdaemon-$(LIBDAEMON_VERSION).tar.gz:
	$(WGET) http://0pointer.de/lennart/projects/libdaemon/libdaemon-$(LIBDAEMON_VERSION).tar.gz

$(D)/libdaemon: $(D)/bootstrap $(ARCHIVE)/libdaemon-$(LIBDAEMON_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libdaemon-$(LIBDAEMON_VERSION)
	$(UNTAR)/libdaemon-$(LIBDAEMON_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libdaemon-$(LIBDAEMON_VERSION); \
		$(CONFIGURE) \
			ac_cv_func_setpgrp_void=yes \
			--prefix=/usr \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdaemon.pc
	$(REWRITE_LIBTOOL)/libdaemon.la
	$(REMOVE)/libdaemon-$(LIBDAEMON_VERSION)
	$(TOUCH)

#
# libplist
#
LIBPLIST_VERSION = 1.10

$(ARCHIVE)/libplist-$(LIBPLIST_VERSION).tar.gz:
	$(WGET) http://cgit.sukimashita.com/libplist.git/snapshot/libplist-$(LIBPLIST_VERSION).tar.gz

$(D)/libplist: $(D)/bootstrap $(D)/libxml2_e2 $(ARCHIVE)/libplist-$(LIBPLIST_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libplist-$(LIBPLIST_VERSION)
	$(UNTAR)/libplist-$(LIBPLIST_VERSION).tar.gz
	export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
	set -e; cd $(BUILD_TMP)/libplist-$(LIBPLIST_VERSION); \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake; \
		cmake . -DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="/usr" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-DCMAKE_INCLUDE_PATH="$(TARGETPREFIX)/usr/include" \
		; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
		sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libplist.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libplist++.pc
	$(REMOVE)/libplist-$(LIBPLIST_VERSION)
	$(TOUCH)

#
# libao
#
LIBAO_VERSION = 1.1.0

$(ARCHIVE)/libao-$(LIBAO_VERSION).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ao/libao-$(LIBAO_VERSION).tar.gz

$(D)/libao: $(D)/bootstrap $(D)/alsa-lib $(ARCHIVE)/libao-$(LIBAO_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/libao-$(LIBAO_VERSION)
	$(UNTAR)/libao-$(LIBAO_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/libao-$(LIBAO_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--enable-alsa \
			--enable-alsa-mmap \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ao.pc
	$(REWRITE_LIBTOOL)/libao.la
	$(REMOVE)/libao-$(LIBAO_VERSION)
	$(TOUCH)

#
# nettle
#
NETTLE_VERSION = 3.1
NETTLE_PATCH = nettle-$(NETTLE_VERSION).patch

$(ARCHIVE)/nettle-$(NETTLE_VERSION).tar.gz:
	$(WGET) http://www.lysator.liu.se/~nisse/archive/nettle-$(NETTLE_VERSION).tar.gz

$(D)/nettle: $(D)/bootstrap $(D)/gmp $(ARCHIVE)/nettle-$(NETTLE_VERSION).tar.gz
	$(START_BUILD)
	$(REMOVE)/nettle-$(NETTLE_VERSION)
	$(UNTAR)/nettle-$(NETTLE_VERSION).tar.gz
	set -e; cd $(BUILD_TMP)/nettle-$(NETTLE_VERSION); \
		$(call post_patch,$(NETTLE_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/hogweed.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/nettle.pc
	$(REMOVE)/nettle-$(NETTLE_VERSION)
	$(TOUCH)

#
# gnutls
#
GNUTLS_VERSION_MAJOR = 3.4
GNUTLS_VERSION_MINOR = 3
GNUTLS_VERSION = $(GNUTLS_VERSION_MAJOR).$(GNUTLS_VERSION_MINOR)

$(ARCHIVE)/gnutls-$(GNUTLS_VERSION).tar.xz:
	$(WGET) ftp://ftp.gnutls.org/gcrypt/gnutls/v$(GNUTLS_VERSION_MAJOR)/gnutls-$(GNUTLS_VERSION).tar.xz

$(D)/gnutls: $(D)/bootstrap $(D)/nettle $(ARCHIVE)/gnutls-$(GNUTLS_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/gnutls-$(GNUTLS_VERSION)
	$(UNTAR)/gnutls-$(GNUTLS_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/gnutls-$(GNUTLS_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--disable-rpath \
			--with-included-libtasn1 \
			--enable-local-libopts \
			--with-libpthread-prefix=$(TARGETPREFIX)/usr \
			--with-libz-prefix=$(TARGETPREFIX)/usr \
			--disable-guile \
			--disable-crywrap \
			--without-p11-kit \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gnutls.pc
	$(REWRITE_LIBTOOL)/libgnutls.la
	$(REWRITE_LIBTOOL)/libgnutlsxx.la
	$(REWRITE_LIBTOOLDEP)/libgnutlsxx.la
	$(REMOVE)/gnutls-$(GNUTLS_VERSION)
	$(TOUCH)

#
# glib-networking
#
GLIB_NETWORKING_VERSION_MAJOR = 2.45
GLIB_NETWORKING_VERSION_MINOR = 1
GLIB_NETWORKING_VERSION = $(GLIB_NETWORKING_VERSION_MAJOR).$(GLIB_NETWORKING_VERSION_MINOR)

$(ARCHIVE)/glib-networking-$(GLIB_NETWORKING_VERSION).tar.xz:
	$(WGET) http://ftp.acc.umu.se/pub/GNOME/sources/glib-networking/$(GLIB_NETWORKING_VERSION_MAJOR)/glib-networking-$(GLIB_NETWORKING_VERSION).tar.xz

$(D)/glib-networking: $(D)/bootstrap $(D)/gnutls $(D)/libglib2 $(ARCHIVE)/glib-networking-$(GLIB_NETWORKING_VERSION).tar.xz
	$(START_BUILD)
	$(REMOVE)/glib-networking-$(GLIB_NETWORKING_VERSION)
	$(UNTAR)/glib-networking-$(GLIB_NETWORKING_VERSION).tar.xz
	set -e; cd $(BUILD_TMP)/glib-networking-$(GLIB_NETWORKING_VERSION); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--localedir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGETPREFIX) giomoduledir=$(TARGETPREFIX)/usr/lib/gio/modules
	$(REMOVE)/glib-networking-$(GLIB_NETWORKING_VERSION)
	$(TOUCH)
