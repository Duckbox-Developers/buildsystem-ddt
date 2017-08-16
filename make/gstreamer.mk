#
# gstreamer
#
GSTREAMER_VERSION = 1.11.1
GSTREAMER_SOURCE = gstreamer-$(GSTREAMER_VERSION).tar.xz
GSTREAMER_PATCH  = gstreamer-$(GSTREAMER_VERSION)-fix-crash-with-gst-inspect.patch
GSTREAMER_PATCH += gstreamer-$(GSTREAMER_VERSION)-revert-use-new-gst-adapter-get-buffer.patch

$(ARCHIVE)/$(GSTREAMER_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gstreamer/$(GSTREAMER_SOURCE)

$(D)/gstreamer: $(D)/bootstrap $(D)/libglib2 $(D)/libxml2 $(D)/glib_networking $(ARCHIVE)/$(GSTREAMER_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gstreamer-$(GSTREAMER_VERSION)
	$(UNTAR)/$(GSTREAMER_SOURCE)
	set -e; cd $(BUILD_TMP)/gstreamer-$(GSTREAMER_VERSION); \
		$(call post_patch,$(GSTREAMER_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--libexecdir=/usr/lib \
			--datarootdir=/.remove \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
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
	$(REMOVE)/gstreamer-$(GSTREAMER_VERSION)
	$(TOUCH)

#
# gst_plugins_base
#
GST_PLUGINS_BASE_VERSION = $(GSTREAMER_VERSION)
GST_PLUGINS_BASE_SOURCE = gst-plugins-base-$(GST_PLUGINS_BASE_VERSION).tar.xz
GST_PLUGINS_BASE_PATCH  = gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)-riff-media-added-fourcc-to-all-mpeg4-video-caps.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)-riff-media-added-fourcc-to-all-ffmpeg-mpeg4-video-ca.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)-subparse-avoid-false-negatives-dealing-with-UTF-8.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)-taglist-not-send-to-down-stream-if-all-the-frame-cor.patch

$(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-base/$(GST_PLUGINS_BASE_SOURCE)

$(D)/gst_plugins_base: $(D)/bootstrap $(D)/libglib2 $(D)/orc $(D)/gstreamer $(D)/alsa_lib $(D)/libogg $(D)/libvorbis $(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)
	$(UNTAR)/$(GST_PLUGINS_BASE_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-base-$(GST_PLUGINS_BASE_VERSION); \
		$(call post_patch,$(GST_PLUGINS_BASE_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datarootdir=/.remove \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
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
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VERSION)
	$(TOUCH)

#
# gst_plugins_good
#
GST_PLUGINS_GOOD_VERSION = $(GSTREAMER_VERSION)
GST_PLUGINS_GOOD_SOURCE = gst-plugins-good-$(GST_PLUGINS_GOOD_VERSION).tar.xz
GST_PLUGINS_GOOD_PATCH =

$(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-good/$(GST_PLUGINS_GOOD_SOURCE)

$(D)/gst_plugins_good: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/libsoup $(D)/flac $(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VERSION)
	$(UNTAR)/$(GST_PLUGINS_GOOD_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-good-$(GST_PLUGINS_GOOD_VERSION); \
		$(call post_patch,$(GST_PLUGINS_GOOD_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datarootdir=/.remove \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VERSION)
	$(TOUCH)

#
# gst_plugins_bad
#
GST_PLUGINS_BAD_VERSION = $(GSTREAMER_VERSION)
GST_PLUGINS_BAD_SOURCE = gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION).tar.xz
GST_PLUGINS_BAD_PATCH  = gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)-hls-use-max-playlist-quality.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)-rtmp-fix-seeking-and-potential-segfault.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)-mpegtsdemux-only-wait-for-PCR-when-PCR-pid.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)-dvbapi5-fix-old-kernel.patch

$(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-bad/$(GST_PLUGINS_BAD_SOURCE)

$(D)/gst_plugins_bad: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)
	$(UNTAR)/$(GST_PLUGINS_BAD_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION); \
		$(call post_patch,$(GST_PLUGINS_BAD_PATCH)); \
		$(BUILDENV) \
		autoreconf --force --install; \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--datarootdir=/.remove \
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
			--disable-lv2 \
			--disable-mplex \
			--disable-musepack \
			--disable-ofa \
			--disable-openjpeg \
			--disable-opensles \
			--disable-resindvd \
			--disable-soundtouch \
			--disable-spandsp \
			--disable-spc \
			--disable-srtp \
			--disable-teletextdec \
			--disable-vcd \
			--disable-vdpau \
			--disable-voaacenc \
			--disable-voamrwbenc \
			--disable-wasapi \
			--disable-wayland \
			--disable-wildmidi \
			--disable-winscreencap \
			--disable-x265 \
			--disable-zbar \
			--disable-examples \
			--disable-debug \
			--enable-orc \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
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
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VERSION)
	$(TOUCH)

#
# gst_plugins_ugly
#
GST_PLUGINS_UGLY_VERSION = $(GSTREAMER_VERSION)
GST_PLUGINS_UGLY_SOURCE = gst-plugins-ugly-$(GST_PLUGINS_UGLY_VERSION).tar.xz
GST_PLUGINS_UGLY_PATCH =

$(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-ugly/$(GST_PLUGINS_UGLY_SOURCE)

$(D)/gst_plugins_ugly: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VERSION)
	$(UNTAR)/$(GST_PLUGINS_UGLY_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VERSION); \
		$(call post_patch,$(GST_PLUGINS_UGLY_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--datarootdir=/.remove \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VERSION)
	$(TOUCH)

#
# gst_libav
#
GST_LIBAV_VERSION = $(GSTREAMER_VERSION)
GST_LIBAV_SOURCE = gst-libav-$(GST_LIBAV_VERSION).tar.xz
GST_LIBAV_PATCH  = gst-libav-$(GST_LIBAV_VERSION)-disable-yasm-for-libav-when-disable-yasm.patch
GST_LIBAV_PATCH += gst-libav-$(GST_LIBAV_VERSION)-fix-sh4-compile-gcc48.patch

$(ARCHIVE)/$(GST_LIBAV_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-libav/$(GST_LIBAV_SOURCE)

$(D)/gst_libav: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_LIBAV_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-libav-$(GST_LIBAV_VERSION)
	$(UNTAR)/$(GST_LIBAV_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-libav-$(GST_LIBAV_VERSION); \
		$(call post_patch,$(GST_LIBAV_PATCH)); \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/gst-libav-$(GST_LIBAV_VERSION)
	$(TOUCH)

#
# gst_plugins_fluendo
#
GST_PLUGINS_FLUENDO_VERSION = 0.10.71
GST_PLUGINS_FLUENDO_SOURCE = gst-fluendo-mpegdemux-$(GST_PLUGINS_FLUENDO_VERSION).tar.gz
GST_PLUGINS_FLUENDO_PATCH = gst-plugins-fluendo-$(GST_PLUGINS_FLUENDO_VERSION)-mpegdemux.patch

$(ARCHIVE)/$(GST_PLUGINS_FLUENDO_SOURCE):
	$(WGET) http://core.fluendo.com/gstreamer/src/gst-fluendo-mpegdemux/$(GST_PLUGINS_FLUENDO_SOURCE)

$(D)/gst_plugins_fluendo: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_PLUGINS_FLUENDO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gst-fluendo-mpegdemux-$(GST_PLUGINS_FLUENDO_VERSION)
	$(UNTAR)/$(GST_PLUGINS_FLUENDO_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-fluendo-mpegdemux-$(GST_PLUGINS_FLUENDO_VERSION); \
		$(call post_patch,$(GST_PLUGINS_FLUENDO_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-check=no \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/gst-fluendo-mpegdemux-$(GST_PLUGINS_FLUENDO_VERSION)
	$(TOUCH)

#
# gmediarender
#
GST_GMEDIARENDER_VERSION = 0.0.6
GST_GMEDIARENDER_SOURCE = gmediarender-$(GST_GMEDIARENDER_VERSION).tar.bz2
GST_GMEDIARENDER_PATCH = gst-gmediarender-$(GST_GMEDIARENDER_VERSION).patch

$(ARCHIVE)/$(GST_GMEDIARENDER_SOURCE):
	$(WGET) http://savannah.nongnu.org/download/gmrender/$(GST_GMEDIARENDER_SOURCE)

$(D)/gst_gmediarender: $(D)/bootstrap $(D)/gst_plugins_dvbmediasink $(D)/libupnp $(ARCHIVE)/$(GST_GMEDIARENDER_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gmediarender-$(GST_GMEDIARENDER_VERSION)
	$(UNTAR)/$(GST_GMEDIARENDER_SOURCE)
	set -e; cd $(BUILD_TMP)/gmediarender-$(GST_GMEDIARENDER_VERSION); \
		$(call post_patch,$(GST_GMEDIARENDER_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-libupnp=$(TARGET_DIR)/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/gmediarender-$(GST_GMEDIARENDER_VERSION)
	$(TOUCH)

#
# orc
#
ORC_VERSION = 0.4.24
ORC_SOURCE = orc-$(ORC_VERSION).tar.xz
ORC_PATCH =

$(ARCHIVE)/$(ORC_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/orc/$(ORC_SOURCE)

$(D)/orc: $(D)/bootstrap $(ARCHIVE)/$(ORC_SOURCE)
	$(START_BUILD)
	$(REMOVE)/orc-$(ORC_VERSION)
	$(UNTAR)/$(ORC_SOURCE)
	set -e; cd $(BUILD_TMP)/orc-$(ORC_VERSION); \
		$(call post_patch,$(ORC_PATCH)); \
		$(CONFIGURE) \
			--datarootdir=/.remove \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/orc-0.4.pc
	$(REWRITE_LIBTOOL)/liborc-0.4.la
	$(REWRITE_LIBTOOL)/liborc-test-0.4.la
	$(REWRITE_LIBTOOLDEP)/liborc-test-0.4.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,orc-bugreport orcc)
	$(REMOVE)/orc-$(ORC_VERSION)
	$(TOUCH)

#
# libdca
#
LIBDCA_VERSION = 0.0.5
LIBDCA_SOURCE = libdca-$(LIBDCA_VERSION).tar.bz2
LIBDCA_PATCH =

$(ARCHIVE)/$(LIBDCA_SOURCE):
	$(WGET) http://download.videolan.org/pub/videolan/libdca/$(LIBDCA_VERSION)/$(LIBDCA_SOURCE)

$(D)/libdca: $(D)/bootstrap $(ARCHIVE)/$(LIBDCA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libdca-$(LIBDCA_VERSION)
	$(UNTAR)/$(LIBDCA_SOURCE)
	set -e; cd $(BUILD_TMP)/libdca-$(LIBDCA_VERSION); \
		$(call post_patch,$(LIBDCA_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdca.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdts.pc
	$(REWRITE_LIBTOOL)/libdca.la
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,extract_dca extract_dts)
	$(REMOVE)/libdca-$(LIBDCA_VERSION)
	$(TOUCH)

#
# gst_plugin_subsink
#
GST_PLUGIN_SUBSINK_VERSION = 1.0
GST_PLUGIN_SUBSINK_PATCH =

$(D)/gst_plugin_subsink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
	$(START_BUILD)
	$(REMOVE)/gstreamer-$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink
	set -e; if [ -d $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink.git ]; \
		then cd $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/christophecvr/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink.git gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink.git $(BUILD_TMP)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink
	set -e; cd $(BUILD_TMP)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink; \
		$(call post_patch,$(GST_PLUGIN_SUBSINK_PATCH)); \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		autoheader --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer$(GST_PLUGIN_SUBSINK_VERSION)-plugin-subsink
	$(TOUCH)

#
# gst_plugins_dvbmediasink
#
GST_PLUGINS_DVBMEDIASINK_VERSION = 1.0
GST_PLUGINS_DVBMEDIASINK_PATCH =

$(D)/gst_plugins_dvbmediasink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugin_subsink $(D)/libdca
	$(START_BUILD)
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink
	set -e; if [ -d $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink.git ]; \
		then cd $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink.git; git pull; \
		else cd $(ARCHIVE); git clone -b experimental git://github.com/christophecvr/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink.git gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink.git $(BUILD_TMP)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink
	set -e; cd $(BUILD_TMP)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink; \
		$(call post_patch,$(GST_PLUGINS_DVBMEDIASINK_PATCH)); \
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
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_DIR)/usr/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VERSION)-plugin-multibox-dvbmediasink
	$(TOUCH)
