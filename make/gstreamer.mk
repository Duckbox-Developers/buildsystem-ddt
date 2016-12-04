#
# gstreamer
#
GSTREAMER_VER = 1.10.1
GSTREAMER_PATCH  = gstreamer-$(GSTREAMER_VER)-fix-crash-with-gst-inspect.patch
GSTREAMER_PATCH += gstreamer-$(GSTREAMER_VER)-revert-use-new-gst-adapter-get-buffer.patch

$(ARCHIVE)/gstreamer-$(GSTREAMER_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$(GSTREAMER_VER).tar.xz

$(D)/gstreamer: $(D)/bootstrap $(D)/glib2 $(D)/libxml2_e2 $(D)/glib-networking $(ARCHIVE)/gstreamer-$(GSTREAMER_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(UNTAR)/gstreamer-$(GSTREAMER_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gstreamer-$(GSTREAMER_VER); \
		$(call post_patch,$(GSTREAMER_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--libexecdir=/usr/lib \
			--disable-gtk-doc \
			--disable-docbook \
			--disable-dependency-tracking \
			--disable-check \
			--disable-gst-debug \
			--disable-examples \
			--disable-benchmarks \
			--disable-tests \
			--disable-debug \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			--enable-introspection=no \
			ac_cv_header_valgrind_valgrind_h=no \
			ac_cv_header_sys_poll_h=no \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-base-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-controller-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-net-1.0.pc
	$(REWRITE_LIBTOOL)/libgstreamer-1.0.la
	$(REWRITE_LIBTOOL)/libgstbase-1.0.la
	$(REWRITE_LIBTOOL)/libgstcontroller-1.0.la
	$(REWRITE_LIBTOOL)/libgstnet-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbase-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstcontroller-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstnet-1.0.la
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(TOUCH)

#
# gst_plugins_base
#
GSTREAMER_BASE_VER = $(GSTREAMER_VER)
GSTREAMER_BASE_PATCH  = gst-plugins-base-$(GSTREAMER_BASE_VER)-riff-media-added-fourcc-to-all-mpeg4-video-caps.patch
GSTREAMER_BASE_PATCH += gst-plugins-base-$(GSTREAMER_BASE_VER)-riff-media-added-fourcc-to-all-ffmpeg-mpeg4-video-ca.patch
GSTREAMER_BASE_PATCH += gst-plugins-base-$(GSTREAMER_BASE_VER)-subparse-avoid-false-negatives-dealing-with-UTF-8.patch
GSTREAMER_BASE_PATCH += gst-plugins-base-$(GSTREAMER_BASE_VER)-taglist-not-send-to-down-stream-if-all-the-frame-cor.patch

$(ARCHIVE)/gst-plugins-base-$(GSTREAMER_BASE_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-$(GSTREAMER_BASE_VER).tar.xz

$(D)/gst_plugins_base: $(D)/bootstrap $(D)/glib2 $(D)/orc $(D)/gstreamer $(D)/libogg $(D)/alsa-lib $(ARCHIVE)/gst-plugins-base-$(GSTREAMER_BASE_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gst-plugins-base-$(GSTREAMER_BASE_VER)
	$(UNTAR)/gst-plugins-base-$(GSTREAMER_BASE_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-plugins-base-$(GSTREAMER_BASE_VER); \
		$(call post_patch,$(GSTREAMER_BASE_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-libvisual \
			--disable-valgrind \
			--disable-debug \
			--disable-examples \
			--disable-debug \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-allocators-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-app-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-audio-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-fft-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-pbutils-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-riff-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-rtp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-rtsp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-sdp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-tag-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-video-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-plugins-base-1.0.pc
	$(REWRITE_LIBTOOL)/libgstallocators-1.0.la
	$(REWRITE_LIBTOOL)/libgstapp-1.0.la
	$(REWRITE_LIBTOOL)/libgstaudio-1.0.la
	$(REWRITE_LIBTOOL)/libgstfft-1.0.la
	$(REWRITE_LIBTOOL)/libgstpbutils-1.0.la
	$(REWRITE_LIBTOOL)/libgstriff-1.0.la
	$(REWRITE_LIBTOOL)/libgstrtp-1.0.la
	$(REWRITE_LIBTOOL)/libgstrtsp-1.0.la
	$(REWRITE_LIBTOOL)/libgstsdp-1.0.la
	$(REWRITE_LIBTOOL)/libgsttag-1.0.la
	$(REWRITE_LIBTOOL)/libgstvideo-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstallocators-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstapp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstaudio-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstfft-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstpbutils-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstriff-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstrtp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstrtsp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstsdp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgsttag-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstvideo-1.0.la
	$(REMOVE)/gst-plugins-base-$(GSTREAMER_BASE_VER)
	$(TOUCH)

#
# gst_plugins_good
#
GSTREAMER_GOOD_VER = $(GSTREAMER_VER)
GSTREAMER_GOOD_PATCH  =

$(ARCHIVE)/gst-plugins-good-$(GSTREAMER_GOOD_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-$(GSTREAMER_GOOD_VER).tar.xz

$(D)/gst_plugins_good: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/libsoup $(D)/libflac $(ARCHIVE)/gst-plugins-good-$(GSTREAMER_GOOD_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gst-plugins-good-$(GSTREAMER_GOOD_VER)
	$(UNTAR)/gst-plugins-good-$(GSTREAMER_GOOD_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-plugins-good-$(GSTREAMER_GOOD_VER); \
		$(call post_patch,$(GSTREAMER_GOOD_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-oss \
			--enable-gst_v4l2 \
			--without-libv4l2 \
			--disable-examples \
			--disable-debug \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-good-$(GSTREAMER_GOOD_VER)
	$(TOUCH)

#
# gst_plugins_bad
#
GSTREAMER_BAD_VER = $(GSTREAMER_VER)
GSTREAMER_BAD_PATCH  = gst-plugins-bad-$(GSTREAMER_BAD_VER)-hls-use-max-playlist-quality.patch
GSTREAMER_BAD_PATCH += gst-plugins-bad-$(GSTREAMER_BAD_VER)-rtmp-fix-seeking-and-potential-segfault.patch
GSTREAMER_BAD_PATCH += gst-plugins-bad-$(GSTREAMER_BAD_VER)-mpegtsdemux-only-wait-for-PCR-when-PCR-pid.patch

$(ARCHIVE)/gst-plugins-bad-$(GSTREAMER_BAD_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-$(GSTREAMER_BAD_VER).tar.xz

$(D)/gst_plugins_bad: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/gst-plugins-bad-$(GSTREAMER_BAD_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gst-plugins-bad-$(GSTREAMER_BAD_VER)
	$(UNTAR)/gst-plugins-bad-$(GSTREAMER_BAD_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-plugins-bad-$(GSTREAMER_BAD_VER); \
		$(call post_patch,$(GSTREAMER_BAD_PATCH)); \
		$(BUILDENV) \
		autoreconf --force --install; \
		./configure $(CONFIGURE_SILENT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			--disable-fatal-warnings \
			--enable-dvb \
			--enable-shm \
			--enable-fbdev \
			--enable-decklink \
			--enable-dts \
			--enable-mpegdemux \
			--disable-acm \
			--disable-android_media \
			--disable-apexsink \
			--disable-apple_media \
			--disable-avc \
			--disable-chromaprint \
			--disable-cocoa \
			--disable-daala \
			--disable-dc1394 \
			--disable-direct3d \
			--disable-directsound \
			--disable-gme \
			--disable-gsm \
			--disable-kate \
			--disable-ladspa \
			--disable-linsys \
			--disable-lv2 \
			--disable-mimic \
			--disable-mplex \
			--disable-musepack \
			--disable-nas \
			--disable-ofa \
			--disable-openjpeg \
			--disable-opensles \
			--disable-pvr \
			--disable-resindvd \
			--disable-sdl \
			--disable-sdltest \
			--disable-sndio \
			--disable-soundtouch \
			--disable-spandsp \
			--disable-spc \
			--disable-srtp \
			--disable-teletextdec \
			--disable-timidity \
			--disable-vcd \
			--disable-vdpau \
			--disable-voaacenc \
			--disable-voamrwbenc \
			--disable-wasapi \
			--disable-wildmidi \
			--disable-wininet \
			--disable-winscreencap \
			--disable-x265 \
			--disable-zbar \
			--disable-examples \
			--disable-debug \
			--enable-orc \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-codecparsers-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-audio-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-base-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-video-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-insertbin-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-mpegts-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-player-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-plugins-bad-1.0.pc
	$(REWRITE_LIBTOOL)/libgstbasecamerabinsrc-1.0.la
	$(REWRITE_LIBTOOL)/libgstcodecparsers-1.0.la
	$(REWRITE_LIBTOOL)/libgstphotography-1.0.la
	$(REWRITE_LIBTOOL)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadbase-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadvideo-1.0.la
	$(REWRITE_LIBTOOL)/libgstinsertbin-1.0.la
	$(REWRITE_LIBTOOL)/libgstmpegts-1.0.la
	$(REWRITE_LIBTOOL)/libgstplayer-1.0.la
	$(REWRITE_LIBTOOL)/libgsturidownloader-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadvideo-1.0.la
	$(REMOVE)/gst-plugins-bad-$(GSTREAMER_BAD_VER)
	$(TOUCH)

#
# gst_plugins_ugly
#
GSTREAMER_UGLY_VER = $(GSTREAMER_VER)
GSTREAMER_UGLY_PATCH =

$(ARCHIVE)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-$(GSTREAMER_UGLY_VER).tar.xz

$(D)/gst_plugins_ugly: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER)
	$(UNTAR)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER); \
		$(call post_patch,$(GSTREAMER_UGLY_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-fatal-warnings \
			--disable-amrnb \
			--disable-amrwb \
			--disable-sidplay \
			--disable-twolame \
			--disable-debug \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			--enable-orc \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-ugly-$(GSTREAMER_UGLY_VER)
	$(TOUCH)

#
# gst_libav
#
GSTREAMER_LIBAV_VER = $(GSTREAMER_VER)
GSTREAMER_LIBAV_PATCH  = gst-libav-$(GSTREAMER_LIBAV_VER)-disable-yasm-for-libav-when-disable-yasm.patch
GSTREAMER_LIBAV_PATCH += gst-libav-$(GSTREAMER_LIBAV_VER)-fix-sh4-compile-gcc48.patch

$(ARCHIVE)/gst-libav-$(GSTREAMER_LIBAV_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/gst-libav/gst-libav-$(GSTREAMER_LIBAV_VER).tar.xz

$(D)/gst_libav: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/gst-libav-$(GSTREAMER_LIBAV_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/gst-libav-$(GSTREAMER_LIBAV_VER)
	$(UNTAR)/gst-libav-$(GSTREAMER_LIBAV_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-libav-$(GSTREAMER_LIBAV_VER); \
		$(call post_patch,$(GSTREAMER_LIBAV_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-fatal-warnings \
			\
			--with-libav-extra-configure=" \
			--enable-gpl \
			--enable-static \
			--enable-pic \
			--disable-protocols \
			--disable-devices \
			--disable-network \
			--disable-hwaccels \
			--disable-filters \
			--disable-doc \
			--enable-optimizations \
			--enable-cross-compile \
			--target-os=linux \
			--arch=sh4 \
			--cross-prefix=$(TARGET)- \
			\
			--disable-muxers \
			--disable-encoders \
			--disable-decoders \
			--enable-decoder=ogg \
			--enable-decoder=vorbis \
			--enable-decoder=flac \
			\
			--disable-demuxers \
			--enable-demuxer=ogg \
			--enable-demuxer=vorbis \
			--enable-demuxer=flac \
			--enable-demuxer=mpegts \
			\
			--disable-debug \
			--disable-bsfs \
			--enable-pthreads \
			--enable-bzlib" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/gst-libav-$(GSTREAMER_LIBAV_VER)
	$(TOUCH)

#
# gst_plugins_fluendo_mpegdemux
#
GSTREAMER_FLUENDO_VER = 0.10.71
GSTREAMER_FLUENDO_PATCH = gst-plugins-fluendo-$(GSTREAMER_FLUENDO_VER)-mpegdemux.patch

$(ARCHIVE)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER).tar.gz:
	$(WGET) http://core.fluendo.com/gstreamer/src/gst-fluendo-mpegdemux/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER).tar.gz

$(D)/gst_plugins_fluendo_mpegdemux: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER)
	$(UNTAR)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER); \
		$(call post_patch,$(GSTREAMER_FLUENDO_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-check=no \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/gst-fluendo-mpegdemux-$(GSTREAMER_FLUENDO_VER)
	$(TOUCH)

#
# gmediarender
#
GSTREAMER_GMEDIARENDER_VER = 0.0.6
GSTREAMER_GMEDIARENDER_PATCH = gst-gmediarender-$(GSTREAMER_GMEDIARENDER_VER).patch

$(ARCHIVE)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER).tar.bz2:
	$(WGET) http://savannah.nongnu.org/download/gmrender/gmediarender-$(GSTREAMER_GMEDIARENDER_VER).tar.bz2

$(D)/gst_gmediarender: $(D)/bootstrap $(D)/gst_plugins_dvbmediasink $(D)/libupnp $(ARCHIVE)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER)
	$(UNTAR)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER); \
		$(call post_patch,$(GSTREAMER_GMEDIARENDER_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-libupnp=$(TARGETPREFIX)/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/gmediarender-$(GSTREAMER_GMEDIARENDER_VER)
	$(TOUCH)

#
# orc
#
ORC_VER = 0.4.24
ORC_PATCH =

$(ARCHIVE)/orc-$(ORC_VER).tar.xz:
	$(WGET) http://gstreamer.freedesktop.org/src/orc/orc-$(ORC_VER).tar.xz

$(D)/orc: $(D)/bootstrap $(ARCHIVE)/orc-$(ORC_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/orc-$(ORC_VER)
	$(UNTAR)/orc-$(ORC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/orc-$(ORC_VER); \
		$(call post_patch,$(ORC_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/orc-0.4.pc
	$(REWRITE_LIBTOOL)/liborc-0.4.la
	$(REWRITE_LIBTOOL)/liborc-test-0.4.la
	$(REWRITE_LIBTOOLDEP)/liborc-test-0.4.la
	$(REMOVE)/orc-$(ORC_VER)
	$(TOUCH)

#
# libdca
#
LIBDCA_VER = 0.0.5
LIBDCA_PATCH =

$(ARCHIVE)/libdca-$(LIBDCA_VER).tar.bz2:
	$(WGET) http://download.videolan.org/pub/videolan/libdca/$(LIBDCA_VER)/libdca-$(LIBDCA_VER).tar.bz2

$(D)/libdca: $(D)/bootstrap $(ARCHIVE)/libdca-$(LIBDCA_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(UNTAR)/libdca-$(LIBDCA_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libdca-$(LIBDCA_VER); \
		$(call post_patch,$(LIBDCA_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdca.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdts.pc
	$(REWRITE_LIBTOOL)/libdca.la
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(TOUCH)

#
# gst_plugin_subsink
#
GSTREAMER_SUBSINK_VER = $(GSTREAMER_VER)
GSTREAMER_SUBSINK_PATCH =

$(D)/gst_plugin_subsink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
	$(START_BUILD)
	$(REMOVE)/gstreamer1.0-plugin-subsink
	set -e; if [ -d $(ARCHIVE)/gstreamer1.0-plugin-subsink.git ]; \
		then cd $(ARCHIVE)/gstreamer1.0-plugin-subsink.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/christophecvr/gstreamer1.0-plugin-subsink.git gstreamer1.0-plugin-subsink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer1.0-plugin-subsink.git $(BUILD_TMP)/gstreamer1.0-plugin-subsink
	set -e; cd $(BUILD_TMP)/gstreamer1.0-plugin-subsink; \
		$(call post_patch,$(GSTREAMER_SUBSINK_PATCH)); \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		autoheader --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer1.0-plugin-subsink
	$(TOUCH)

#
# gst_plugins_dvbmediasink
#
GSTREAMER_SUBSINK_VER = $(GSTREAMER_VER)
GSTREAMER_DVBMEDIASINK_PATCH =

$(D)/gst_plugins_dvbmediasink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugin_subsink $(D)/libdca
	$(START_BUILD)
	$(REMOVE)/gstreamer1.0-plugin-multibox-dvbmediasink
	set -e; if [ -d $(ARCHIVE)/gstreamer1.0-plugin-multibox-dvbmediasink.git ]; \
		then cd $(ARCHIVE)/gstreamer1.0-plugin-multibox-dvbmediasink.git; git pull; \
		else cd $(ARCHIVE); git clone -b experimental git://github.com/christophecvr/gstreamer1.0-plugin-multibox-dvbmediasink.git gstreamer1.0-plugin-multibox-dvbmediasink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer1.0-plugin-multibox-dvbmediasink.git $(BUILD_TMP)/gstreamer1.0-plugin-multibox-dvbmediasink
	set -e; cd $(BUILD_TMP)/gstreamer1.0-plugin-multibox-dvbmediasink; \
		$(call post_patch,$(GSTREAMER_DVBMEDIASINK_PATCH)); \
		aclocal --force -I m4; \
		libtoolize --copy --force; \
		autoconf --force; \
		autoheader --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-wma \
			--with-wmv \
			--with-pcm \
			--with-eac3 \
			--with-dtsdownmix \
			--with-mpeg4v2 \
			--with-gstversion=1.0 \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer1.0-plugin-multibox-dvbmediasink
	$(TOUCH)
