#
# ncurses
#
NCURSES_VER = 6.0
NCURSES_SOURCE = ncurses-$(NCURSES_VER).tar.gz
NCURSES_PATCH = ncurses-$(NCURSES_VER)-gcc-5.x-MKlib_gen.patch

$(ARCHIVE)/$(NCURSES_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/pub/gnu/ncurses/$(NCURSES_SOURCE)

$(D)/ncurses: $(D)/bootstrap $(ARCHIVE)/$(NCURSES_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ncurses-$(NCURSES_VER)
	$(UNTAR)/$(NCURSES_SOURCE)
	$(CHDIR)/ncurses-$(NCURSES_VER); \
		$(call apply_patches, $(NCURSES_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--enable-pc-files \
			--with-pkg-config \
			--with-pkg-config-libdir=/usr/lib/pkgconfig \
			--with-shared \
			--with-fallbacks='linux vt100 xterm' \
			--without-ada \
			--without-cxx \
			--without-cxx-binding \
			--without-debug \
			--without-manpages \
			--without-profile \
			--without-progs \
			--without-tests \
			--disable-big-core \
			--disable-rpath \
			--disable-rpath-hack \
			--enable-echo \
			--enable-const \
			--enable-overwrite \
			--enable-widec \
		; \
		$(MAKE) libs \
			HOSTCC=gcc \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)"; \
		$(MAKE) install.libs DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/usr/bin/ncursesw6-config $(HOST_DIR)/bin
	rm -f $(addprefix $(TARGET_LIB_DIR)/,libform* libmenu* libpanel*)
	rm -f $(addprefix $(PKG_CONFIG_PATH)/,form.pc menu.pc panel.pc)
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/ncursesw6-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ncursesw.pc
	$(REMOVE)/ncurses-$(NCURSES_VER)
	$(TOUCH)

#
# host_libffi
#
LIBFFI_VER = 3.2.1
LIBFFI_SOURCE = libffi-$(LIBFFI_VER).tar.gz
LIBFFI_PATCH = libffi-$(LIBFFI_VER).patch

$(ARCHIVE)/$(LIBFFI_SOURCE):
	$(DOWNLOAD) ftp://sourceware.org/pub/libffi/$(LIBFFI_SOURCE)

$(D)/host_libffi: $(ARCHIVE)/$(LIBFFI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(UNTAR)/$(LIBFFI_SOURCE)
	$(CHDIR)/libffi-$(LIBFFI_VER); \
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
	$(CHDIR)/libffi-$(LIBFFI_VER); \
		$(call apply_patches, $(LIBFFI_PATCH)); \
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
# host_libglib2_genmarshal
#
LIBGLIB2_VER_MAJOR = 2
LIBGLIB2_VER_MINOR = 57
LIBGLIB2_VER_MICRO = 1
LIBGLIB2_VER = $(LIBGLIB2_VER_MAJOR).$(LIBGLIB2_VER_MINOR).$(LIBGLIB2_VER_MICRO)
LIBGLIB2_SOURCE = glib-$(LIBGLIB2_VER).tar.xz

$(ARCHIVE)/$(LIBGLIB2_SOURCE):
	$(DOWNLOAD) https://ftp.gnome.org/pub/gnome/sources/glib/$(LIBGLIB2_VER_MAJOR).$(LIBGLIB2_VER_MINOR)/$(LIBGLIB2_SOURCE)

$(D)/host_libglib2_genmarshal: $(D)/bootstrap $(D)/host_libffi $(ARCHIVE)/$(LIBGLIB2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(UNTAR)/$(LIBGLIB2_SOURCE)
	$(CHDIR)/glib-$(LIBGLIB2_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		export PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig; \
		./configure $(SILENT_OPT) \
			--prefix=`pwd`/out \
			--enable-static=yes \
			--enable-shared=no \
			--disable-fam \
			--disable-libmount \
			--with-pcre=internal \
			--disable-compile-warnings \
		; \
		$(MAKE) install; \
		cp -a out/bin/glib-* $(HOST_DIR)/bin
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(TOUCH)

#
# libglib2
#
LIBGLIB2_PATCH  = libglib2-$(LIBGLIB2_VER)-disable-tests.patch
LIBGLIB2_PATCH += libglib2-$(LIBGLIB2_VER)-fix-gio-linking.patch

$(D)/libglib2: $(D)/bootstrap $(D)/host_libglib2_genmarshal $(D)/zlib $(D)/libffi $(ARCHIVE)/$(LIBGLIB2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(UNTAR)/$(LIBGLIB2_SOURCE)
	$(CHDIR)/glib-$(LIBGLIB2_VER); \
		echo "glib_cv_va_copy=no" > config.cache; \
		echo "glib_cv___va_copy=yes" >> config.cache; \
		echo "glib_cv_va_val_copy=yes" >> config.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes" >> config.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes" >> config.cache; \
		echo "glib_cv_stack_grows=no" >> config.cache; \
		echo "glib_cv_uscore=no" >> config.cache; \
		echo "ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/bin/glib-genmarshal" >> config.cache; \
		$(call apply_patches, $(LIBGLIB2_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--mandir=/.remove \
			--cache-file=config.cache \
			--disable-fam \
			--disable-libmount \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--with-threads="posix" \
			--with-html-dir=/.remove \
			--with-pcre=internal \
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
	rm -rf $(addprefix $(TARGET_DIR)/usr/share/,bash-completion gettext gdb glib-2.0)
	$(REMOVE)/glib-$(LIBGLIB2_VER)
	$(TOUCH)

#
# host_libarchive
#
LIBARCHIVE_VER = 3.4.0
LIBARCHIVE_SOURCE = libarchive-$(LIBARCHIVE_VER).tar.gz

$(ARCHIVE)/$(LIBARCHIVE_SOURCE):
	$(DOWNLOAD) https://www.libarchive.org/downloads/$(LIBARCHIVE_SOURCE)

$(D)/host_libarchive: $(D)/bootstrap $(ARCHIVE)/$(LIBARCHIVE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libarchive-$(LIBARCHIVE_VER)
	$(UNTAR)/$(LIBARCHIVE_SOURCE)
	$(CHDIR)/libarchive-$(LIBARCHIVE_VER); \
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
	$(CHDIR)/libarchive-$(LIBARCHIVE_VER); \
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
# readline
#
READLINE_VER = 6.2
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz

$(ARCHIVE)/$(READLINE_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/readline/$(READLINE_SOURCE)

$(D)/readline: $(D)/bootstrap $(ARCHIVE)/$(READLINE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/readline-$(READLINE_VER)
	$(UNTAR)/$(READLINE_SOURCE)
	$(CHDIR)/readline-$(READLINE_VER); \
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
OPENSSL_MINOR = u
OPENSSL_VER = $(OPENSSL_MAJOR)$(OPENSSL_MINOR)
OPENSSL_SOURCE = openssl-$(OPENSSL_VER).tar.gz
OPENSSL_PATCH  = openssl-$(OPENSSL_VER)-optimize-for-size.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-makefile-dirs.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-disable_doc_tests.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-fix-parallel-building.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-compat_versioned_symbols-1.patch
OPENSSL_PATCH += openssl-$(OPENSSL_VER)-remove_timestamp_check.patch

ifeq ($(BOXARCH), sh4)
OPENSSL_SED_PATCH = sed -i 's|MAKEDEPPROG=makedepend|MAKEDEPPROG=$(CROSS_DIR)/bin/$$(CC) -M|' Makefile
else
OPENSSL_SED_PATCH = sed -i 's|MAKEDEPPROG=makedepend|MAKEDEPPROG=$(CROSS_BASE)/bin/$$(CC) -M|' Makefile
endif

$(ARCHIVE)/$(OPENSSL_SOURCE):
	$(DOWNLOAD) https://www.openssl.org/source/old/$(OPENSSL_MAJOR)/$(OPENSSL_SOURCE)

$(D)/openssl: $(D)/bootstrap $(ARCHIVE)/$(OPENSSL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/openssl-$(OPENSSL_VER)
	$(UNTAR)/$(OPENSSL_SOURCE)
	$(CHDIR)/openssl-$(OPENSSL_VER); \
		$(call apply_patches, $(OPENSSL_PATCH)); \
		$(BUILDENV) \
		./Configure $(SILENT_OPT) \
			-DL_ENDIAN \
			shared \
			no-hw \
			linux-generic32 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
		; \
		$(OPENSSL_SED_PATCH); \
		$(MAKE) depend; \
		$(MAKE) all; \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGET_DIR)
	chmod 0755 $(TARGET_LIB_DIR)/lib{crypto,ssl}.so.*
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	cd $(TARGET_DIR) && rm -rf etc/ssl/man usr/bin/openssl usr/lib/engines
	ln -sf libcrypto.so.1.0.0 $(TARGET_LIB_DIR)/libcrypto.so.0.9.8
	ln -sf libssl.so.1.0.0 $(TARGET_LIB_DIR)/libssl.so.0.9.8
	$(REMOVE)/openssl-$(OPENSSL_VER)
	$(TOUCH)

#
# libbluray
#
LIBBLURAY_VER = 0.5.0
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VER).tar.bz2
LIBBLURAY_PATCH = libbluray-$(LIBBLURAY_VER).patch

$(ARCHIVE)/$(LIBBLURAY_SOURCE):
	$(DOWNLOAD) ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/$(LIBBLURAY_SOURCE)

$(D)/libbluray: $(D)/bootstrap $(ARCHIVE)/$(LIBBLURAY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(UNTAR)/$(LIBBLURAY_SOURCE)
	$(CHDIR)/libbluray-$(LIBBLURAY_VER); \
		$(call apply_patches, $(LIBBLURAY_PATCH)); \
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
# zlib
#
ZLIB_VER = 1.3.1
ZLIB_SOURCE = zlib-$(ZLIB_VER).tar.xz
ZLIB_Patch = zlib-$(ZLIB_VER).patch

$(ARCHIVE)/$(ZLIB_SOURCE):
	$(DOWNLOAD) https://zlib.net/$(ZLIB_SOURCE)

$(D)/zlib: $(D)/bootstrap $(ARCHIVE)/$(ZLIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(UNTAR)/$(ZLIB_SOURCE)
	$(CHDIR)/zlib-$(ZLIB_VER); \
		$(call apply_patches, $(ZLIB_Patch)); \
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
BZIP2_VER = 1.0.8
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_Patch = bzip2-$(BZIP2_VER).patch

$(ARCHIVE)/$(BZIP2_SOURCE):
	$(DOWNLOAD) https://sourceware.org/pub/bzip2/$(BZIP2_SOURCE)

$(D)/bzip2: $(D)/bootstrap $(ARCHIVE)/$(BZIP2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/bzip2-$(BZIP2_VER)
	$(UNTAR)/$(BZIP2_SOURCE)
	$(CHDIR)/bzip2-$(BZIP2_VER); \
		$(call apply_patches, $(BZIP2_Patch)); \
		mv Makefile-libbz2_so Makefile; \
		$(MAKE) all CC=$(TARGET)-gcc AR=$(TARGET)-ar RANLIB=$(TARGET)-ranlib; \
		$(MAKE) install PREFIX=$(TARGET_DIR)/usr
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra vuduo vuduo2 vuuno vuultimo vuduo4k vuduo4kse vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k dm820 dm7080 dm900 dm920 dm8000 dm7020hd dm800se dm800sev2))
	cd $(TARGET_DIR) && rm -f usr/bin/bzip2
endif
	$(REMOVE)/bzip2-$(BZIP2_VER)
	$(TOUCH)

#
# freetype
#
FREETYPE_VER = 2.11.0
FREETYPE_SOURCE = freetype-$(FREETYPE_VER).tar.xz
FREETYPE_PATCH = freetype-$(FREETYPE_VER).patch

$(ARCHIVE)/$(FREETYPE_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)/$(FREETYPE_SOURCE)

$(D)/freetype: $(D)/bootstrap $(D)/zlib $(D)/libpng $(ARCHIVE)/$(FREETYPE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/freetype-$(FREETYPE_VER)
	$(UNTAR)/$(FREETYPE_SOURCE)
	$(CHDIR)/freetype-$(FREETYPE_VER); \
		$(call apply_patches, $(FREETYPE_PATCH)); \
		sed -r "s:.*(#.*SUBPIXEL_(RENDERING|HINTING  2)) .*:\1:g" \
			-i include/freetype/config/ftoption.h; \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg; \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--disable-static \
			--enable-shared \
			--enable-freetype-config \
			--with-bzip2=no \
			--with-zlib=yes \
			--with-png=yes \
			--with-harfbuzz=no \
			--with-brotli=no \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		if [ ! -e $(TARGET_INCLUDE_DIR)/freetype ] ; then \
			ln -sf freetype2 $(TARGET_INCLUDE_DIR)/freetype; \
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
# harfbuzz
#
HARFBUZZ_VER = 1.8.8
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VER).tar.bz2

$(ARCHIVE)/$(HARFBUZZ_SOURCE):
	$(DOWNLOAD) https://www.freedesktop.org/software/harfbuzz/release/$(HARFBUZZ_SOURCE)

$(D)/harfbuzz: $(D)/bootstrap $(D)/freetype $(D)/libglib2 $(ARCHIVE)/$(HARFBUZZ_SOURCE)
	$(START_BUILD)
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(UNTAR)/$(HARFBUZZ_SOURCE)
	$(CHDIR)/harfbuzz-$(HARFBUZZ_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--infodir=/.remove \
			--localedir=/.remove \
			--mandir=/.remove \
			--docdir=/.remove \
			--htmldir=/.remove \
			--dvidir=/.remove \
			--pdfdir=/.remove \
			--psdir=/.remove \
			--with-freetype \
			--with-glib \
			--without-cairo \
			--without-fontconfig \
			--without-graphite2 \
			--without-icu \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		if [ -d $(TARGET_INCLUDE_DIR)/harfbuzz ]; then \
			cp $(TARGET_INCLUDE_DIR)/harfbuzz/* $(TARGET_INCLUDE_DIR)/glib-2.0; \
		fi;
	$(REWRITE_LIBTOOL)/libharfbuzz.la
	$(REWRITE_LIBTOOL)/libharfbuzz-subset.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/harfbuzz.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/harfbuzz-subset.pc
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(TOUCH)

#
# lirc
#
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd spark spark7162 ufs910))

LIRC_VER = 0.9.0
LIRC_SOURCE = lirc-$(LIRC_VER).tar.bz2
LIRC_PATCH = lirc-$(LIRC_VER).patch
LIRC = $(D)/lirc

$(ARCHIVE)/$(LIRC_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/lirc/files/LIRC/$(LIRC_VER)/$(LIRC_SOURCE)

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
	$(CHDIR)/lirc-$(LIRC_VER); \
		$(call apply_patches, $(LIRC_PATCH)); \
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
JPEG_PATCH += jpeg-$(JPEG_VER)-fix-unknown-type-name-FILE.patch

$(ARCHIVE)/$(JPEG_SOURCE):
	$(DOWNLOAD) http://www.ijg.org/files/$(JPEG_SOURCE)

$(D)/jpeg: $(D)/bootstrap $(ARCHIVE)/$(JPEG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/jpeg-$(JPEG_VER)
	$(UNTAR)/$(JPEG_SOURCE)
	$(CHDIR)/jpeg-$(JPEG_VER); \
		$(call apply_patches, $(JPEG_PATCH)); \
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
# libjpg
#
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922 ipbox55 ipbox99 ipbox9900 cuberevo_250hd cuberevo_2000hd))
$(D)/libjpeg: $(D)/jpeg
	@touch $@
else
$(D)/libjpeg: $(D)/libjpeg_turbo
	@touch $@
endif

#
# libjpeg_turbo2
#
LIBJPEG_TURBO2_VER = 3.0.1
LIBJPEG_TURBO2_SOURCE = libjpeg-turbo-$(LIBJPEG_TURBO2_VER).tar.gz
LIBJPEG_TURBO2_PATCH = libjpeg-turbo-tiff-ojpeg.patch
LIBJPEG_TURBO2_PATCH += libjpeg-turbo-fix-unknown-type-name-FILE.patch

$(ARCHIVE)/$(LIBJPEG_TURBO2_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG_TURBO2_VER)/$(LIBJPEG_TURBO2_SOURCE)

$(D)/libjpeg_turbo2: $(D)/bootstrap $(ARCHIVE)/$(LIBJPEG_TURBO2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG_TURBO2_VER)
	$(UNTAR)/$(LIBJPEG_TURBO2_SOURCE)
	$(CHDIR)/libjpeg-turbo-$(LIBJPEG_TURBO2_VER); \
		$(call apply_patches, $(LIBJPEG_TURBO2_PATCH)); \
		cmake   -DCMAKE_INSTALL_PREFIX=/usr \
			-DCMAKE_C_COMPILER=$(TARGET)-gcc \
			-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
			-DCMAKE_C_FLAGS="-pipe -Os" \
			-DCMAKE_CXX_FLAGS="-pipe -Os" \
			-DCMAKE_SKIP_INSTALL_RPATH=ON \
			-DWITH_SIMD=OFF \
			-DWITH_JAVA=OFF \
			-DWITH_TURBOJPEG=OFF \
			-DCMAKE_INSTALL_DOCDIR=/.remove \
			-DCMAKE_INSTALL_MANDIR=/.remove \
			-DCMAKE_INSTALL_DEFAULT_LIBDIR=lib \
			-DENABLE_STATIC=OFF \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG_TURBO2_VER)
	$(TOUCH)

#
# libjpeg_turbo
#
LIBJPEG_TURBO_VER = 1.5.3
LIBJPEG_TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG_TURBO_VER).tar.gz

$(ARCHIVE)/$(LIBJPEG_TURBO_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG_TURBO_VER)/$(LIBJPEG_TURBO_SOURCE)

$(D)/libjpeg_turbo: $(D)/bootstrap $(ARCHIVE)/$(LIBJPEG_TURBO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG_TURBO_VER)
	$(UNTAR)/$(LIBJPEG_TURBO_SOURCE)
	$(CHDIR)/libjpeg-turbo-$(LIBJPEG_TURBO_VER); \
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
	rm -f $(TARGET_LIB_DIR)/libturbojpeg* $(TARGET_INCLUDE_DIR)/turbojpeg.h $(PKG_CONFIG_PATH)/libturbojpeg.pc
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG_TURBO_VER)
	$(TOUCH)

#
# libpng
#
LIBPNG_VER = 1.6.50
LIBPNG_VER_X = 16
LIBPNG_SOURCE = libpng-$(LIBPNG_VER).tar.xz

$(ARCHIVE)/$(LIBPNG_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/libpng/files/libpng$(LIBPNG_VER_X)/$(LIBPNG_VER)/$(LIBPNG_SOURCE) || \
	$(DOWNLOAD) https://sourceforge.net/projects/libpng/files/libpng$(LIBPNG_VER_X)/older-releases/$(LIBPNG_VER)/$(LIBPNG_SOURCE)

$(D)/libpng: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBPNG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(UNTAR)/$(LIBPNG_SOURCE)
	$(CHDIR)/libpng-$(LIBPNG_VER); \
		$(call apply_patches, $(LIBPNG_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-powerpc-vsx \
			--mandir=/.remove \
			--disable-tests \
			--disable-tools \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		sed -e 's:^prefix=.*:prefix="$(TARGET_DIR)/usr":' -i $(TARGET_DIR)/usr/bin/libpng$(LIBPNG_VER_X)-config; \
		mv $(TARGET_DIR)/usr/bin/libpng*-config $(HOST_DIR)/bin/
	$(REWRITE_LIBTOOL)/libpng16.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libpng$(LIBPNG_VER_X).pc
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,pngfix png-fix-itxt)
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(TOUCH)

#
# giflib
#
GIFLIB_VER = 5.1.4
GIFLIB_SOURCE = giflib-$(GIFLIB_VER).tar.bz2

$(ARCHIVE)/$(GIFLIB_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/giflib/files/$(GIFLIB_SOURCE)

$(D)/giflib: $(D)/bootstrap $(ARCHIVE)/$(GIFLIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/giflib-$(GIFLIB_VER)
	$(UNTAR)/$(GIFLIB_SOURCE)
	$(CHDIR)/giflib-$(GIFLIB_VER); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
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
	$(DOWNLOAD) http://www.hyperrealm.com/packages/$(LIBCONFIG_SOURCE)

$(D)/libconfig: $(D)/bootstrap $(ARCHIVE)/$(LIBCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libconfig-$(LIBCONFIG_VER)
	$(UNTAR)/$(LIBCONFIG_SOURCE)
	$(CHDIR)/libconfig-$(LIBCONFIG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libconfig.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libconfig++.pc
	$(REWRITE_LIBTOOL)/libconfig.la
	$(REWRITE_LIBTOOL)/libconfig++.la
	$(REMOVE)/libconfig-$(LIBCONFIG_VER)
	$(TOUCH)

#
# ca-bundle
#
CA-BUNDLE_SOURCE = cacert.pem
CA-BUNDLE_URL = https://curl.se/ca/$(CA-BUNDLE_SOURCE)

$(ARCHIVE)/$(CA-BUNDLE_SOURCE):
	$(DOWNLOAD) $(CA-BUNDLE_URL)

$(D)/ca-bundle: $(ARCHIVE)/$(CA-BUNDLE_SOURCE)
	$(START_BUILD)
	cd $(ARCHIVE); \
		curl -s --remote-name --remote-time -z $(CA-BUNDLE_SOURCE) $(CA-BUNDLE_URL)
	install -D -m 644 $(ARCHIVE)/$(CA-BUNDLE_SOURCE) $(TARGET_DIR)/$(CA_BUNDLE_DIR)/$(CA_BUNDLE)
	$(TOUCH)

#
# libcurl
#
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 4.8.4 4.9.4))
LIBCURL_VER = 7.61.1
else
LIBCURL_VER = 8.15.0
endif
LIBCURL_SOURCE = curl-$(LIBCURL_VER).tar.bz2
LIBCURL_PATCH = libcurl-$(LIBCURL_VER).patch

$(ARCHIVE)/$(LIBCURL_SOURCE):
	$(DOWNLOAD) https://curl.haxx.se/download/$(LIBCURL_SOURCE)

$(D)/libcurl: $(D)/bootstrap $(D)/zlib $(D)/openssl $(D)/ca-bundle $(ARCHIVE)/$(LIBCURL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(UNTAR)/$(LIBCURL_SOURCE)
	$(CHDIR)/curl-$(LIBCURL_VER); \
		$(call apply_patches, $(LIBCURL_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-silent-rules \
			--disable-debug \
			--disable-curldebug \
			--disable-docs \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-imap \
			--disable-pop3 \
			--disable-smtp \
			--enable-shared \
			--enable-optimize \
			--disable-verbose \
			--disable-ldap \
			--without-libidn \
			--without-libidn2 \
			--without-winidn \
			--without-libpsl \
			--with-ca-bundle=$(CA_BUNDLE_DIR)/$(CA_BUNDLE) \
			--with-random=/dev/urandom \
			--with-ssl=$(TARGET_DIR)/usr \
		; \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGET_DIR)," < curl-config > $(HOST_DIR)/bin/curl-config; \
		chmod 755 $(HOST_DIR)/bin/curl-config; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		rm -f $(TARGET_DIR)/usr/bin/curl-config
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(TOUCH)

#
# libfribidi
#
LIBFRIBIDI_VER = 1.0.16
LIBFRIBIDI_SOURCE = fribidi-$(LIBFRIBIDI_VER).tar.xz
LIBFRIBIDI_PATCH = libfribidi-$(LIBFRIBIDI_VER).patch

$(ARCHIVE)/$(LIBFRIBIDI_SOURCE):
	$(DOWNLOAD) https://github.com/fribidi/fribidi/releases/download/v$(LIBFRIBIDI_VER)/$(LIBFRIBIDI_SOURCE)

$(D)/libfribidi: $(D)/bootstrap $(ARCHIVE)/$(LIBFRIBIDI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fribidi-$(LIBFRIBIDI_VER)
	$(UNTAR)/$(LIBFRIBIDI_SOURCE)
	$(CHDIR)/fribidi-$(LIBFRIBIDI_VER); \
		$(call apply_patches, $(LIBFRIBIDI_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--enable-shared \
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
# libsigc
#
LIBSIGC_VER_MAJOR = 2
LIBSIGC_VER_MINOR = 4
LIBSIGC_VER_MICRO = 1
LIBSIGC_VER = $(LIBSIGC_VER_MAJOR).$(LIBSIGC_VER_MINOR).$(LIBSIGC_VER_MICRO)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VER).tar.xz

$(ARCHIVE)/$(LIBSIGC_SOURCE):
	$(DOWNLOAD) https://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_VER_MAJOR).$(LIBSIGC_VER_MINOR)/$(LIBSIGC_SOURCE)

$(D)/libsigc: $(D)/bootstrap $(ARCHIVE)/$(LIBSIGC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libsigc++-$(LIBSIGC_VER)
	$(UNTAR)/$(LIBSIGC_SOURCE)
	$(CHDIR)/libsigc++-$(LIBSIGC_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-documentation \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		if [ -d $(TARGET_INCLUDE_DIR)/sigc++-2.0/sigc++ ] ; then \
			ln -sf ./sigc++-2.0/sigc++ $(TARGET_INCLUDE_DIR)/sigc++; \
		fi;
		mv $(TARGET_LIB_DIR)/sigc++-2.0/include/sigc++config.h $(TARGET_INCLUDE_DIR); \
		rm -fr $(TARGET_LIB_DIR)/sigc++-2.0
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
	$(DOWNLOAD) https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VER)/$(LIBMAD_SOURCE)

$(D)/libmad: $(D)/bootstrap $(ARCHIVE)/$(LIBMAD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(UNTAR)/$(LIBMAD_SOURCE)
	$(CHDIR)/libmad-$(LIBMAD_VER); \
		$(call apply_patches, $(LIBMAD_PATCH)); \
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
	$(DOWNLOAD) https://sourceforge.net/projects/mad/files/libid3tag/$(LIBID3TAG_VER)/$(LIBID3TAG_SOURCE)

$(D)/libid3tag: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBID3TAG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	$(UNTAR)/$(LIBID3TAG_SOURCE)
	$(CHDIR)/libid3tag-$(LIBID3TAG_VER); \
		$(call apply_patches, $(LIBID3TAG_PATCH)); \
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
# flac
#
FLAC_VER = 1.3.2
FLAC_SOURCE = flac-$(FLAC_VER).tar.xz
FLAC_PATCH = flac-$(FLAC_VER).patch

$(ARCHIVE)/$(FLAC_SOURCE):
	$(DOWNLOAD) https://ftp.osuosl.org/pub/xiph/releases/flac/$(FLAC_SOURCE)

$(D)/flac: $(D)/bootstrap $(ARCHIVE)/$(FLAC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/flac-$(FLAC_VER)
	$(UNTAR)/$(FLAC_SOURCE)
	$(CHDIR)/flac-$(FLAC_VER); \
		$(call apply_patches, $(FLAC_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--datarootdir=/.remove \
			--disable-cpplibs \
			--disable-debug \
			--disable-asm-optimizations \
			--disable-sse \
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
# libogg
#
LIBOGG_VER = 1.3.3
LIBOGG_SOURCE = libogg-$(LIBOGG_VER).tar.gz

$(ARCHIVE)/$(LIBOGG_SOURCE):
	$(DOWNLOAD) https://ftp.osuosl.org/pub/xiph/releases/ogg/$(LIBOGG_SOURCE)

$(D)/libogg: $(D)/bootstrap $(ARCHIVE)/$(LIBOGG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(UNTAR)/$(LIBOGG_SOURCE)
	$(CHDIR)/libogg-$(LIBOGG_VER); \
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
# libvorbis
#
LIBVORBIS_VER = 1.3.6
LIBVORBIS_SOURCE = libvorbis-$(LIBVORBIS_VER).tar.xz

$(ARCHIVE)/$(LIBVORBIS_SOURCE):
	$(DOWNLOAD) https://ftp.osuosl.org/pub/xiph/releases/vorbis/$(LIBVORBIS_SOURCE)

$(D)/libvorbis: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/$(LIBVORBIS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libvorbis-$(LIBVORBIS_VER)
	$(UNTAR)/$(LIBVORBIS_SOURCE)
	$(CHDIR)/libvorbis-$(LIBVORBIS_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
			--mandir=/.remove \
			--disable-docs \
			--disable-examples \
			--disable-oggtest \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) docdir=/.remove
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
LIBVORBISIDEC_VER = 1.2.1+git20180316
LIBVORBISIDEC_VER_APPEND = .orig
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VER)$(LIBVORBISIDEC_VER_APPEND).tar.gz

$(ARCHIVE)/$(LIBVORBISIDEC_SOURCE):
	$(DOWNLOAD) https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/$(LIBVORBISIDEC_SOURCE)

$(D)/libvorbisidec: $(D)/bootstrap $(D)/libogg $(ARCHIVE)/$(LIBVORBISIDEC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(UNTAR)/$(LIBVORBISIDEC_SOURCE)
	$(CHDIR)/libvorbisidec-$(LIBVORBISIDEC_VER); \
		$(call apply_patches, $(LIBVORBISIDEC_PATCH)); \
		ACLOCAL_FLAGS="-I . -I $(TARGET_DIR)/usr/share/aclocal" \
		$(BUILDENV) \
		./autogen.sh $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(TOUCH)

#
# libiconv
#
LIBICONV_VER = 1.18
LIBICONV_SOURCE = libiconv-$(LIBICONV_VER).tar.gz

$(ARCHIVE)/$(LIBICONV_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/libiconv/$(LIBICONV_SOURCE)

$(D)/libiconv: $(D)/bootstrap $(ARCHIVE)/$(LIBICONV_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(UNTAR)/$(LIBICONV_SOURCE)
	$(CHDIR)/libiconv-$(LIBICONV_VER); \
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
	rm -f $(addprefix $(TARGET_LIB_DIR)/,preloadable_libiconv.so)
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(TOUCH)

#
# expat
#
EXPAT_PATCH  = expat-libtool-tag.patch
EXPAT_BRANCH = 4b274f1

$(D)/expat: $(D)/bootstrap $(ARCHIVE)/$(EXPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libexpat
	set -e; if [ -d $(ARCHIVE)/libexpat.git ]; \
		then cd $(ARCHIVE)/libexpat.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/libexpat/libexpat.git libexpat.git; \
		fi
	cp -ra $(ARCHIVE)/libexpat.git $(BUILD_TMP)/libexpat
	$(CHDIR)/libexpat/expat; \
		git checkout $(EXPAT_BRANCH); \
		$(call apply_patches, $(EXPAT_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--bindir=/.remove \
			--without-xmlwf \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/libexpat
	$(TOUCH)

#
# fontconfig
#
FONTCONFIG_VER = 2.11.93
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VER).tar.bz2

$(ARCHIVE)/$(FONTCONFIG_SOURCE):
	$(DOWNLOAD) https://www.freedesktop.org/software/fontconfig/release/$(FONTCONFIG_SOURCE)

$(D)/fontconfig: $(D)/bootstrap $(D)/freetype $(D)/expat $(ARCHIVE)/$(FONTCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/fontconfig-$(FONTCONFIG_VER)
	$(UNTAR)/$(FONTCONFIG_SOURCE)
	$(CHDIR)/fontconfig-$(FONTCONFIG_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
			--with-expat-includes=$(TARGET_INCLUDE_DIR) \
			--with-expat-lib=$(TARGET_LIB_DIR) \
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
	$(DOWNLOAD) https://download.videolan.org/pub/libdvdcss/$(LIBDVDCSS_VER)/$(LIBDVDCSS_SOURCE)

$(D)/libdvdcss: $(D)/bootstrap $(ARCHIVE)/$(LIBDVDCSS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdcss-$(LIBDVDCSS_VER)
	$(UNTAR)/$(LIBDVDCSS_SOURCE)
	$(CHDIR)/libdvdcss-$(LIBDVDCSS_VER); \
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
	$(DOWNLOAD) http://dvdnav.mplayerhq.hu/releases/$(LIBDVDNAV_SOURCE)

$(D)/libdvdnav: $(D)/bootstrap $(D)/libdvdread $(ARCHIVE)/$(LIBDVDNAV_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdnav-$(LIBDVDNAV_VER)
	$(UNTAR)/$(LIBDVDNAV_SOURCE)
	$(CHDIR)/libdvdnav-$(LIBDVDNAV_VER); \
		$(call apply_patches, $(LIBDVDNAV_PATCH)); \
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
	$(DOWNLOAD) http://dvdnav.mplayerhq.hu/releases/$(LIBDVDREAD_SOURCE)

$(D)/libdvdread: $(D)/bootstrap $(ARCHIVE)/$(LIBDVDREAD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvdread-$(LIBDVDREAD_VER)
	$(UNTAR)/$(LIBDVDREAD_SOURCE)
	$(CHDIR)/libdvdread-$(LIBDVDREAD_VER); \
		$(call apply_patches, $(LIBDVDREAD_PATCH)); \
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
		else cd $(ARCHIVE); git clone https://github.com/mirakels/libdreamdvd.git libdreamdvd.git; \
		fi
	cp -ra $(ARCHIVE)/libdreamdvd.git $(BUILD_TMP)/libdreamdvd
	$(CHDIR)/libdreamdvd; \
		$(call apply_patches, $(LIBDREAMDVD_PATCH)); \
		$(BUILDENV) \
		libtoolize --copy --ltdl --force --quiet; \
		autoreconf --verbose --force --install; \
		./configure \
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
# libass
#
LIBASS_VER = 0.14.0
LIBASS_SOURCE = libass-$(LIBASS_VER).tar.xz
LIBASS_PATCH = libass-$(LIBASS_VER).patch

$(ARCHIVE)/$(LIBASS_SOURCE):
	$(DOWNLOAD) https://github.com/libass/libass/releases/download/$(LIBASS_VER)/$(LIBASS_SOURCE)

$(D)/libass: $(D)/bootstrap $(D)/freetype $(D)/libfribidi $(ARCHIVE)/$(LIBASS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libass-$(LIBASS_VER)
	$(UNTAR)/$(LIBASS_SOURCE)
	$(CHDIR)/libass-$(LIBASS_VER); \
		$(call apply_patches, $(LIBASS_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
			--disable-test \
			--disable-fontconfig \
			--disable-harfbuzz \
			--disable-require-system-font-provider \
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
	$(DOWNLOAD) http://www.sqlite.org/2017/$(SQLITE_SOURCE)

$(D)/sqlite: $(D)/bootstrap $(ARCHIVE)/$(SQLITE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(UNTAR)/$(SQLITE_SOURCE)
	$(CHDIR)/sqlite-autoconf-$(SQLITE_VER); \
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
# libxml2
#
LIBXML2_MAJOR = 2.14
LIBXML2_MINOR = 5
LIBXML2_VER = $(LIBXML2_MAJOR).$(LIBXML2_MINOR)
LIBXML2_SOURCE = libxml2-$(LIBXML2_VER).tar.xz
LIBXML2_PATCH = libxml2-$(LIBXML2_VER).patch

$(ARCHIVE)/$(LIBXML2_SOURCE):
	$(DOWNLOAD) https://download.gnome.org/sources/libxml2/$(LIBXML2_MAJOR)/$(LIBXML2_SOURCE)

ifeq ($(BOXARCH), sh4)
LIBXML2_CONF_OPTS += --without-iconv
LIBXML2_CONF_OPTS += --with-minimum
LIBXML2_CONF_OPTS += --with-schematron=yes
endif

$(D)/libxml2: $(D)/bootstrap $(D)/zlib $(ARCHIVE)/$(LIBXML2_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libxml2-$(LIBXML2_VER).tar.gz
	$(UNTAR)/$(LIBXML2_SOURCE)
	$(CHDIR)/libxml2-$(LIBXML2_VER); \
		$(call apply_patches, $(LIBXML2_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
			--datarootdir=/.remove \
			--enable-shared \
			--disable-static \
			--without-python \
			--without-catalog \
			--without-debug \
			--without-legacy \
			--without-docbook \
			--without-mem-debug \
			--without-lzma \
			--with-zlib \
			$(LIBXML2_CONF_OPTS) \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		if [ -d $(TARGET_INCLUDE_DIR)/libxml2/libxml ] ; then \
			ln -sf ./libxml2/libxml $(TARGET_INCLUDE_DIR)/libxml; \
		fi;
	mv $(TARGET_DIR)/usr/bin/xml2-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/xml2-config
	$(REWRITE_LIBTOOL)/libxml2.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,xmlcatalog xmllint)
	rm -rf $(TARGET_LIB_DIR)/xml2Conf.sh
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	$(TOUCH)

#
# libxslt
#
LIBXSLT_VER = 1.1.32
LIBXSLT_SOURCE = libxslt-$(LIBXSLT_VER).tar.gz

$(ARCHIVE)/$(LIBXSLT_SOURCE):
	$(DOWNLOAD) ftp://xmlsoft.org/libxml2/$(LIBXSLT_SOURCE)

$(D)/libxslt: $(D)/bootstrap $(D)/libxml2 $(ARCHIVE)/$(LIBXSLT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libxslt-$(LIBXSLT_VER)
	$(UNTAR)/$(LIBXSLT_SOURCE)
	$(CHDIR)/libxslt-$(LIBXSLT_VER); \
		$(CONFIGURE) \
			CPPFLAGS="$(CPPFLAGS) -I$(TARGET_INCLUDE_DIR)/libxml2" \
			--prefix=/usr \
			--datarootdir=/.remove \
			--enable-shared \
			--disable-static \
			--without-python \
			--without-crypto \
			--without-debug \
			--without-mem-debug \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/usr/bin/xslt-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexslt.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxslt.pc
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/xslt-config
	$(REWRITE_LIBTOOL)/libexslt.la
	$(REWRITE_LIBTOOL)/libxslt.la
	$(REWRITE_LIBTOOLDEP)/libexslt.la
ifeq ($(BOXARCH), sh4)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,xsltproc xslt-config)
endif
	rm -rf $(TARGETLIB)/xsltConf.sh
	rm -rf $(TARGETLIB)/libxslt-plugins/
	$(REMOVE)/libxslt-$(LIBXSLT_VER)
	$(TOUCH)

#
# libpopt
#
LIBPOPT_VER = 1.19
LIBPOPT_SOURCE = popt-$(LIBPOPT_VER).tar.gz

$(ARCHIVE)/$(LIBPOPT_SOURCE):
	$(DOWNLOAD) http://ftp.rpm.org/popt/releases/popt-1.x/$(LIBPOPT_SOURCE)

$(D)/libpopt: $(D)/bootstrap $(ARCHIVE)/$(LIBPOPT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/popt-$(LIBPOPT_VER)
	$(UNTAR)/$(LIBPOPT_SOURCE)
	$(CHDIR)/popt-$(LIBPOPT_VER); \
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
# libroxml
#
LIBROXML_VER = 3.0.2
LIBROXML_SOURCE = libroxml-$(LIBROXML_VER).tar.gz
LIBROXML_PATCH = libroxml-$(LIBROXML_VER)-gcc10.patch

$(ARCHIVE)/$(LIBROXML_SOURCE):
	$(DOWNLOAD) http://download.libroxml.net/pool/v3.x/$(LIBROXML_SOURCE)

$(D)/libroxml: $(D)/bootstrap $(ARCHIVE)/$(LIBROXML_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	$(UNTAR)/$(LIBROXML_SOURCE)
	$(CHDIR)/libroxml-$(LIBROXML_VER); \
		$(call apply_patches, $(LIBROXML_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--disable-roxml \
			--disable-rocat \
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
PUGIXML_VER = b080173
PUGIXML_PATCH = pugixml-config.patch

$(D)/pugixml: $(D)/bootstrap $(ARCHIVE)/$(PUGIXML_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pugixml
	set -e; if [ -d $(ARCHIVE)/pugixml.git ]; \
		then cd $(ARCHIVE)/pugixml.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/zeux/pugixml.git pugixml.git; \
		fi
	cp -ra $(ARCHIVE)/pugixml.git $(BUILD_TMP)/pugixml
	(cd $(BUILD_TMP)/pugixml; git checkout $(PUGIXML_VER);); \
	$(CHDIR)/pugixml; \
		$(call apply_patches, $(PUGIXML_PATCH)); \
		cmake  --no-warn-unused-cli \
			-DCMAKE_INSTALL_PREFIX=/usr \
			-DBUILD_SHARED_LIBS=ON \
			-DCMAKE_BUILD_TYPE=Linux \
			-DCMAKE_C_COMPILER=$(TARGET)-gcc \
			-DCMAKE_CXX_COMPILER=$(TARGET)-g++ \
			-DCMAKE_C_FLAGS="-pipe -Os" \
			-DCMAKE_CXX_FLAGS="-pipe -Os" \
			| tail -n +90 \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/pugixml
	cd $(TARGET_DIR) && rm -rf usr/lib/cmake
	$(TOUCH)

#
# graphlcd
#
GRAPHLCD_VER = 55d4bd8
GRAPHLCD_SOURCE = graphlcd-git-$(GRAPHLCD_VER).tar.bz2
GRAPHLCD_URL = https://github.com/Duckbox-Developers/graphlcd.git
GRAPHLCD_PATCH = graphlcd-git-$(GRAPHLCD_VER).patch
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k))
GRAPHLCD_PATCH += graphlcd-vuplus4k_1.patch
GRAPHLCD_PATCH += graphlcd-vuplus4k_2.patch
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm8000 dm7020hd dm7080))
GRAPHLCD_PATCH += graphlcd-dreambox_grautec.patch
GRAPHLCD_PATCH += graphlcd-dm8000.patch
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm900 dm920))
GRAPHLCD_PATCH += graphlcd-dreambox.patch
GRAPHLCD_PATCH += graphlcd-dm900.patch
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo2))
GRAPHLCD_PATCH += graphlcd-vuplus4k_1.patch
GRAPHLCD_PATCH += graphlcd-vuduo2.patch
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuultimo))
GRAPHLCD_PATCH += graphlcd-vuplus4k_1.patch
GRAPHLCD_PATCH += graphlcd-vuultimo.patch
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), e4hdultra))
GRAPHLCD_PATCH += graphlcd-e4hdultra.patch
GRAPHLCD_PATCH += graphlcd-framebuffer.patch
endif

$(ARCHIVE)/$(GRAPHLCD_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(GRAPHLCD_URL) $(GRAPHLCD_VER) $(notdir $@) $(ARCHIVE)

$(D)/graphlcd: $(D)/bootstrap $(D)/freetype $(D)/libusb $(ARCHIVE)/$(GRAPHLCD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/graphlcd-git-$(GRAPHLCD_VER)
	$(UNTAR)/$(GRAPHLCD_SOURCE)
	$(CHDIR)/graphlcd-git-$(GRAPHLCD_VER); \
		$(call apply_patches, $(GRAPHLCD_PATCH)); \
		$(MAKE) -C glcdgraphics all TARGET=$(TARGET)- DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcddrivers all TARGET=$(TARGET)- DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcdgraphics install DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcddrivers install DESTDIR=$(TARGET_DIR); \
		cp -a graphlcd.conf $(TARGET_DIR)/etc
	$(REMOVE)/graphlcd-git-$(GRAPHLCD_VER)
	$(TOUCH)

#
# libdpf
#
LIBDPF_VER = 62c8fd0
LIBDPF_SOURCE = dpf-ax-git-$(LIBDPF_VER).tar.bz2
LIBDPF_URL = https://github.com/Duckbox-Developers/dpf-ax.git
LIBDPF_PATCH = libdpf-crossbuild.patch

$(ARCHIVE)/$(LIBDPF_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(LIBDPF_URL) $(LIBDPF_VER) $(notdir $@) $(ARCHIVE)

$(D)/libdpf: $(D)/bootstrap $(D)/libusb_compat $(ARCHIVE)/$(LIBDPF_SOURCE)
	$(START_BUILD)
	$(REMOVE)/dpf-ax-git-$(LIBDPF_VER)
	$(UNTAR)/$(LIBDPF_SOURCE)
	$(CHDIR)/dpf-ax-git-$(LIBDPF_VER)/dpflib; \
		$(call apply_patches, $(LIBDPF_PATCH)); \
		make libdpf.a CC=$(TARGET)-gcc PREFIX=$(TARGET_DIR)/usr; \
		mkdir -p $(TARGET_INCLUDE_DIR)/libdpf; \
		cp dpf.h $(TARGET_INCLUDE_DIR)/libdpf/libdpf.h; \
		cp ../include/spiflash.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp ../include/usbuser.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp libdpf.a $(TARGET_LIB_DIR)/
	$(REMOVE)/dpf-ax-git-$(LIBDPF_VER)
	$(TOUCH)

#
# lcd4linux
#
LCD4LINUX_PATCH = lcd4linux.patch
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k vuduo2))
LCD4LINUX_DRV = ,VUPLUS4K
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo2))
LCD4LINUX_DRV += ,VUDUO2
endif
#ifeq ($(BOXTYPE), $(filter $(BOXTYPE), dm8000))
#LCD4LINUX_DRV = ,DM8000
#endif

$(D)/lcd4linux: $(D)/bootstrap $(D)/libusb_compat $(D)/gd $(D)/libusb $(D)/libdpf
	$(START_BUILD)
	$(REMOVE)/lcd4linux
	set -e; if [ -d $(ARCHIVE)/lcd4linux.git ]; \
		then cd $(ARCHIVE)/lcd4linux.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/TangoCash/lcd4linux.git lcd4linux.git; \
		fi
	cp -ra $(ARCHIVE)/lcd4linux.git $(BUILD_TMP)/lcd4linux
	$(CHDIR)/lcd4linux; \
		$(call apply_patches, $(LCD4LINUX_PATCH)); \
		$(BUILDENV) ./bootstrap $(SILENT_OPT); \
		$(BUILDENV) ./configure $(CONFIGURE_OPTS) $(SILENT_OPT) \
			--prefix=/usr \
			--with-drivers='DPF,SamsungSPF$(LCD4LINUX_DRV),PNG' \
			--with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' \
			--without-ncurses \
		; \
		$(MAKE) vcs_version all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo2))
	install -m 755 $(SKEL_ROOT)/etc/init.d/lcd4linux_png $(TARGET_DIR)/etc/init.d/lcd4linux
else
	install -m 755 $(SKEL_ROOT)/etc/init.d/lcd4linux $(TARGET_DIR)/etc/init.d/
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuduo4kse vuuno4kse vuultimo4k vusolo4k))
	install -D -m 0600 $(SKEL_ROOT)/etc/lcd4linux_vu.conf $(TARGET_DIR)/etc/lcd4linux.conf
else
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo2))
	install -D -m 0600 $(SKEL_ROOT)/etc/lcd4linux_png.conf $(TARGET_DIR)/etc/lcd4linux.conf
else
	install -D -m 0600 $(SKEL_ROOT)/etc/lcd4linux.conf $(TARGET_DIR)/etc/lcd4linux.conf
endif
endif
	$(REMOVE)/lcd4linux
	$(TOUCH)

#
# gd
#
GD_VER = 2.3.3
GD_SOURCE = libgd-$(GD_VER).tar.xz

$(ARCHIVE)/$(GD_SOURCE):
	$(DOWNLOAD) https://github.com/libgd/libgd/releases/download/gd-$(GD_VER)/$(GD_SOURCE)

$(D)/gd: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/freetype $(ARCHIVE)/$(GD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libgd-$(GD_VER)
	$(UNTAR)/$(GD_SOURCE)
	$(CHDIR)/libgd-$(GD_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--without-fontconfig \
			--without-xpm \
			--without-x \
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
LIBUSB_VER = 1.0.22
LIBUSB_VER_MAJOR = 1.0
LIBUSB_SOURCE = libusb-$(LIBUSB_VER).tar.bz2
LIBUSB_PATCH = libusb-$(LIBUSB_VER).patch
ifeq ($(BOXARCH), sh4)
LIBUSB_PATCH += libusb-1.0.22-sh4-clock_gettime.patch
endif

$(ARCHIVE)/$(LIBUSB_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/libusb/files/libusb-$(LIBUSB_VER_MAJOR)/libusb-$(LIBUSB_VER)/$(LIBUSB_SOURCE)

$(D)/libusb: $(D)/bootstrap $(ARCHIVE)/$(LIBUSB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(UNTAR)/$(LIBUSB_SOURCE)
	$(CHDIR)/libusb-$(LIBUSB_VER); \
		$(call apply_patches, $(LIBUSB_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--disable-log \
			--disable-debug-log \
			--disable-udev \
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
	$(DOWNLOAD) https://sourceforge.net/projects/libusb/files/libusb-compat-0.1/libusb-compat-$(LIBUSB_COMPAT_VER)/$(LIBUSB_COMPAT_SOURCE)

$(D)/libusb_compat: $(D)/bootstrap $(D)/libusb $(ARCHIVE)/$(LIBUSB_COMPAT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	$(UNTAR)/$(LIBUSB_COMPAT_SOURCE)
	$(CHDIR)/libusb-compat-$(LIBUSB_COMPAT_VER); \
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
# alsa-lib
#
ALSA_LIB_VER = 1.2.14
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VER).tar.bz2
ALSA_LIB_PATCH  = alsa-lib-$(ALSA_LIB_VER).patch
ALSA_LIB_PATCH += alsa-lib-$(ALSA_LIB_VER)-link_fix.patch
ALSA_LIB_PATCH += alsa-lib-$(ALSA_LIB_VER)-header.patch
ifeq ($(BOXARCH), sh4)
ALSA_LIB_PATCH += alsa-lib-$(ALSA_LIB_VER)-sh4_kernel_long_t-fix.patch
endif

$(ARCHIVE)/$(ALSA_LIB_SOURCE):
	$(DOWNLOAD) https://www.alsa-project.org/files/pub/lib/$(ALSA_LIB_SOURCE)

$(D)/alsa_lib: $(D)/bootstrap $(ARCHIVE)/$(ALSA_LIB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VER)
	$(UNTAR)/$(ALSA_LIB_SOURCE)
	$(CHDIR)/alsa-lib-$(ALSA_LIB_VER); \
		$(call apply_patches, $(ALSA_LIB_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-alsa-devdir=/dev/snd/ \
			--with-plugindir=/usr/lib/alsa \
			--without-debug \
			--with-debug=no \
			--with-versioned=no \
			--enable-symbolic-functions \
			--enable-silent-rules \
			--disable-aload \
			--disable-rawmidi \
			--disable-seq \
			--disable-resmgr \
			--disable-old-symbols \
			--disable-alisp \
			--disable-ucm \
			--disable-hwdep \
			--disable-python \
			--disable-topology \
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
ALSA_UTILS_VER = 1.2.14
ALSA_UTILS_SOURCE = alsa-utils-$(ALSA_UTILS_VER).tar.bz2
ALSA_UTILS_PATCH = alsa-utils-$(ALSA_UTILS_VER).patch

$(ARCHIVE)/$(ALSA_UTILS_SOURCE):
	$(DOWNLOAD) https://www.alsa-project.org/files/pub/utils/$(ALSA_UTILS_SOURCE)

$(D)/alsa_utils: $(D)/bootstrap $(D)/alsa_lib $(ARCHIVE)/$(ALSA_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/alsa-utils-$(ALSA_UTILS_VER)
	$(UNTAR)/$(ALSA_UTILS_SOURCE)
	$(CHDIR)/alsa-utils-$(ALSA_UTILS_VER); \
		$(call apply_patches, $(ALSA_UTILS_PATCH)); \
		sed -ir -r "s/(alsamixer|amidi|aplay|iecset|speaker-test|seq|alsactl|alsaucm|topology)//g" Makefile.am ;\
		autoreconf -fi -I $(TARGET_DIR)/usr/share/aclocal $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--with-curses=ncurses \
			--enable-silent-rules \
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
LIBOPENTHREADS_VER = 3.2
LIBOPENTHREADS_SOURCE = OpenThreads-$(LIBOPENTHREADS_VER).tar.gz
LIBOPENTHREADS_PATCH = libopenthreads-$(LIBOPENTHREADS_VER).patch

$(ARCHIVE)/$(LIBOPENTHREADS_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/mxedeps/files/$(LIBOPENTHREADS_SOURCE)

$(D)/libopenthreads: $(D)/bootstrap $(ARCHIVE)/$(LIBOPENTHREADS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VER)
	$(UNTAR)/$(LIBOPENTHREADS_SOURCE)
	$(CHDIR)/OpenThreads-$(LIBOPENTHREADS_VER); \
		$(call apply_patches, $(LIBOPENTHREADS_PATCH)); \
		echo "# dummy file to prevent warning message" > examples/CMakeLists.txt; \
		cmake . -DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX=/usr \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1 \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE__TRYRUN_OUTPUT=1 \
		; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
		sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-$(LIBOPENTHREADS_VER)
	$(TOUCH)

#
# librtmp
#
$(D)/librtmp: $(D)/bootstrap $(D)/zlib $(D)/openssl
	$(START_BUILD)
	$(REMOVE)/rtmpdump
	set -e; if [ -d $(ARCHIVE)/rtmpdump.git ]; \
		then cd $(ARCHIVE)/rtmpdump.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/Duckbox-Developers/rtmpdump.git rtmpdump.git; \
		fi
	cp -ra $(ARCHIVE)/rtmpdump.git $(BUILD_TMP)/rtmpdump
	$(CHDIR)/rtmpdump; \
		$(MAKE) CROSS_COMPILE=$(TARGET)- XCFLAGS="-I$(TARGET_INCLUDE_DIR) -L$(TARGET_LIB_DIR)" LDFLAGS="-L$(TARGET_LIB_DIR)"; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR) MANDIR=$(TARGET_DIR)/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/librtmp.pc
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/,rtmpgw rtmpsrv rtmpsuck)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,rtmpdump)
	$(REMOVE)/rtmpdump
	$(TOUCH)

#
# libdvbsi++
#
LIBDVBSI_VER = f3c40ea
LIBDVBSI_SOURCE = libdvbsi-git-$(LIBDVBSI_VER).tar.bz2
LIBDVBSI_URL = https://github.com/OpenVisionE2/libdvbsi.git
#LIBDVBSI_PATCH = libdvbsi-git-$(LIBDVBSI_VER).patch

$(ARCHIVE)/$(LIBDVBSI_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(LIBDVBSI_URL) $(LIBDVBSI_VER) $(notdir $@) $(ARCHIVE)

$(D)/libdvbsi: $(D)/bootstrap $(ARCHIVE)/$(LIBDVBSI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvbsi-git-$(LIBDVBSI_VER)
	$(UNTAR)/$(LIBDVBSI_SOURCE)
	$(CHDIR)/libdvbsi-git-$(LIBDVBSI_VER); \
		$(call apply_patches, $(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvbsi++.pc
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REMOVE)/libdvbsi-git-$(LIBDVBSI_VER)
	$(TOUCH)

#
# libdvbcsa
#
ifeq ($(BOXARCH), arm)
LIBDVBCSA_CONF_OPTS = $(if $(findstring neon,$(TARGET_MARCH_CFLAGS)),--enable-neon,--disable-neon)
endif
$(D)/libdvbcsa: $(D)/bootstrap $(ARCHIVE)/$(LIBDVBCSA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdvbcsa
	set -e; if [ -d $(ARCHIVE)/libdvbcsa.git ]; \
		then cd $(ARCHIVE)/libdvbcsa.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/oe-mirrors/libdvbcsa.git libdvbcsa.git; \
		fi
	cp -ra $(ARCHIVE)/libdvbcsa.git $(BUILD_TMP)/libdvbcsa
	$(CHDIR)/libdvbcsa; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			$(LIBDVBCSA_CONF_OPTS) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libdvbcsa.la
	$(REMOVE)/libdvbcsa
	$(TOUCH)

#
# lzo
#
LZO_VER = 2.10
LZO_SOURCE = lzo-$(LZO_VER).tar.gz

$(ARCHIVE)/$(LZO_SOURCE):
	$(DOWNLOAD) https://www.oberhumer.com/opensource/lzo/download/$(LZO_SOURCE)

$(D)/lzo: $(D)/bootstrap $(ARCHIVE)/$(LZO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lzo-$(LZO_VER)
	$(UNTAR)/$(LZO_SOURCE)
	$(CHDIR)/lzo-$(LZO_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/lzo2.pc
	$(REWRITE_LIBTOOL)/liblzo2.la
	$(REMOVE)/lzo-$(LZO_VER)
	$(TOUCH)

#
# minidlna
#
MINIDLNA_VER = 1.3.2
MINIDLNA_SOURCE = minidlna-$(MINIDLNA_VER).tar.gz
MINIDLNA_PATCH = minidlna-$(MINIDLNA_VER).patch

$(ARCHIVE)/$(MINIDLNA_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/minidlna/files/minidlna/$(MINIDLNA_VER)/$(MINIDLNA_SOURCE)

$(D)/minidlna: $(D)/bootstrap $(D)/zlib $(D)/sqlite $(D)/libexif $(D)/libjpeg $(D)/libid3tag $(D)/libogg $(D)/libvorbis $(D)/flac $(D)/ffmpeg $(ARCHIVE)/$(MINIDLNA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/minidlna-$(MINIDLNA_VER)
	$(UNTAR)/$(MINIDLNA_SOURCE)
	$(CHDIR)/minidlna-$(MINIDLNA_VER); \
		$(call apply_patches, $(MINIDLNA_PATCH)); \
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
	$(DOWNLOAD) https://sourceforge.net/projects/libexif/files/libexif/$(LIBEXIF_VER)/$(LIBEXIF_SOURCE)

$(D)/libexif: $(D)/bootstrap $(ARCHIVE)/$(LIBEXIF_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libexif-$(LIBEXIF_VER)
	$(UNTAR)/$(LIBEXIF_SOURCE)
	$(CHDIR)/libexif-$(LIBEXIF_VER); \
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
DJMOUNT_PATCH  = djmount-$(DJMOUNT_VER)-fix-hang-with-asset-upnp.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-fix-incorrect-range-when-retrieving-content-via-HTTP.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-fix-new-autotools.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-fixed-crash-when-using-UTF-8-charset.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-fixed-crash.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-support-fstab-mounting.patch
DJMOUNT_PATCH += djmount-$(DJMOUNT_VER)-support-seeking-in-large-2gb-files.patch

$(ARCHIVE)/$(DJMOUNT_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)/$(DJMOUNT_SOURCE)

$(D)/djmount: $(D)/bootstrap $(D)/fuse $(ARCHIVE)/$(DJMOUNT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(UNTAR)/$(DJMOUNT_SOURCE)
	$(CHDIR)/djmount-$(DJMOUNT_VER); \
		touch libupnp/config.aux/config.rpath; \
		$(call apply_patches, $(DJMOUNT_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) -C \
			--prefix=/usr \
			--disable-debug \
		; \
		make; \
		make install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	$(TOUCH)

#
# libupnp
#
LIBUPNP_VER = 1.6.25
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VER).tar.bz2

$(ARCHIVE)/$(LIBUPNP_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/pupnp/files/pupnp/libUPnP\ $(LIBUPNP_VER)/$(LIBUPNP_SOURCE)

$(D)/libupnp: $(D)/bootstrap $(ARCHIVE)/$(LIBUPNP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(UNTAR)/$(LIBUPNP_SOURCE)
	$(CHDIR)/libupnp-$(LIBUPNP_VER); \
		$(CONFIGURE) \
			--prefix=/usr \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
		; \
		$(MAKE) all; \
		$(MAKE) install
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(TOUCH)

#
# howl
#
HOWL_VER = 1.0.0
HOWL_SOURCE = howl-$(HOWL_VER).tar.gz

$(ARCHIVE)/$(HOWL_SOURCE):
	$(DOWNLOAD) https://sourceforge.net/projects/howl/files/howl/$(HOWL_VER)/$(HOWL_SOURCE)

$(D)/howl: $(D)/bootstrap $(ARCHIVE)/$(HOWL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/howl-$(HOWL_VER)
	$(UNTAR)/$(HOWL_SOURCE)
	$(CHDIR)/howl-$(HOWL_VER); \
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
	$(DOWNLOAD) http://0pointer.de/lennart/projects/libdaemon/$(LIBDAEMON_SOURCE)

$(D)/libdaemon: $(D)/bootstrap $(ARCHIVE)/$(LIBDAEMON_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdaemon-$(LIBDAEMON_VER)
	$(UNTAR)/$(LIBDAEMON_SOURCE)
	$(CHDIR)/libdaemon-$(LIBDAEMON_VER); \
		$(CONFIGURE) \
			ac_cv_func_setpgrp_void=yes \
			--prefix=/usr \
			--disable-static \
			--disable-lynx \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdaemon.pc
	$(REWRITE_LIBTOOL)/libdaemon.la
	$(REMOVE)/libdaemon-$(LIBDAEMON_VER)
	$(TOUCH)

#
# libgpg-error
#
LIBGPG_ERROR_VER    = 1.50
LIBGPG_ERROR_DIR    = libgpg-error-$(LIBGPG_ERROR_VER)
LIBGPG_ERROR_SOURCE = libgpg-error-$(LIBGPG_ERROR_VER).tar.bz2
LIBGPG_ERROR_URL    = https://www.gnupg.org/ftp/gcrypt/libgpg-error

$(ARCHIVE)/$(LIBGPG_ERROR_SOURCE):
	$(DOWNLOAD) $(LIBGPG_ERROR_URL)/$(LIBGPG_ERROR_SOURCE)

$(D)/libgpg-error: $(D)/bootstrap $(ARCHIVE)/$(LIBGPG_ERROR_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(LIBGPG_ERROR_DIR)
	$(UNTAR)/$(LIBGPG_ERROR_SOURCE)
	$(CHDIR)/$(LIBGPG_ERROR_DIR); \
		$(CONFIGURE) \
			--prefix=/usr \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--disable-tests \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	cd $(TARGET_DIR)/usr/bin && ln -sf gpgrt-config gpg-error-config
	$(REWRITE_LIBTOOL)/libgpg-error.la
	$(REMOVE)/$(LIBGPG_ERROR_DIR)
	$(TOUCH)

#
# libgcrypt
#
LIBGCRYPT_VER    = 1.8.11
LIBGCRYPT_DIR    = libgcrypt-$(LIBGCRYPT_VER)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VER).tar.bz2
LIBGCRYPT_URL    = https://gnupg.org/ftp/gcrypt/libgcrypt

$(ARCHIVE)/$(LIBGCRYPT_SOURCE):
	$(DOWNLOAD) $(LIBGCRYPT_URL)/$(LIBGCRYPT_SOURCE)

$(D)/libgcrypt: $(D)/bootstrap $(D)/libgpg-error $(ARCHIVE)/$(LIBGCRYPT_SOURCE)
	$(START_BUILD)
	$(REMOVE)/$(LIBGCRYPT_DIR)
	$(UNTAR)/$(LIBGCRYPT_SOURCE)
	$(CHDIR)/$(LIBGCRYPT_DIR); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-tests \
			--with-gpg-error-prefix=$(TARGET_DIR)/usr \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/usr/bin/libgcrypt-config $(HOST_DIR)/bin
	$(REWRITE_LIBTOOL)/libgcrypt.la
	$(REMOVE)/$(LIBGCRYPT_DIR)
	$(TOUCH)
