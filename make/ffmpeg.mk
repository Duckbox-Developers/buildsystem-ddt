#
# ffmpeg
#
################################################################################
ifeq ($(BOXARCH), sh4)
FFMPEG_VER = 2.8.10
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz
FFMPEG_PATCH  = ffmpeg-$(FFMPEG_VER)-buffer-size.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-hds-libroxml.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-aac.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-kodi.patch

FFMPEG_DEPS =
FFMPEG_CONF_OPTS = 
FFMPRG_EXTRA_CFLAGS =

$(ARCHIVE)/$(FFMPEG_SOURCE):
	$(WGET) http://www.ffmpeg.org/releases/$(FFMPEG_SOURCE)

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/libass $(D)/libroxml $(FFMPEG_DEPS) $(ARCHIVE)/$(FFMPEG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	$(UNTAR)/$(FFMPEG_SOURCE)
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
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
			--disable-vfp \
			--disable-inline-asm \
			--disable-yasm \
			--disable-mips32r2 \
			--disable-mipsdspr2 \
			--disable-mipsfpu \
			--disable-fast-unaligned \
			--disable-armv5te \
			--disable-armv6 \
			--disable-armv6t2 \
			--disable-neon \
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
			--enable-decoder=aac_latm \
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
			--disable-indevs \
			\
			--disable-outdevs \
			\
			$(FFMPEG_CONF_OPTS) \
			\
			--disable-iconv \
			--disable-xlib \
			--disable-libxcb \
			--disable-postproc \
			--disable-static \
			--disable-debug \
			--disable-runtime-cpudetect \
			\
			--enable-bsfs \
			--enable-bzlib \
			--enable-zlib \
			--enable-libass \
			--enable-openssl \
			--enable-network \
			--enable-small \
			--enable-stripping \
			\
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--extra-cflags="$(TARGET_CFLAGS) $(FFMPRG_EXTRA_CFLAGS)" \
			--extra-ldflags="$(TARGET_LDFLAGS) -lrt" \
			--target-os=linux \
			--arch=$(BOXARCH) \
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

endif

################################################################################

ifeq ($(BOXARCH), arm)
FFMPEG_VER = 3.3
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz
FFMPEG_PATCH  = ffmpeg-$(FFMPEG_VER)-fix-hls.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-buffer-size.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-aac.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-fix-mpegts.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-allow-to-choose-rtmp-impl-at-runtime.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-fix-edit-list-parsing.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-add-dash-demux.patch

FFMPEG_DEPS = $(D)/libxml2 $(D)/librtmpdump
FFMPEG_CONF_OPTS  = --enable-librtmp
FFMPRG_EXTRA_CFLAGS = -fPIC -mfpu=neon-vfpv4 -mfloat-abi=hard

$(ARCHIVE)/$(FFMPEG_SOURCE):
	$(WGET) http://www.ffmpeg.org/releases/$(FFMPEG_SOURCE)

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/freetype $(D)/alsa_lib $(D)/libass $(D)/libroxml $(FFMPEG_DEPS) $(ARCHIVE)/$(FFMPEG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	$(UNTAR)/$(FFMPEG_SOURCE)
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
		$(call post_patch,$(FFMPEG_PATCH)); \
		./configure \
			--disable-ffserver \
			--disable-ffplay \
			--enable-ffprobe \
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
			--disable-xop \
			--disable-fma3 \
			--disable-fma4 \
			--disable-avx2 \
			--disable-armv5te \
			--disable-armv6 \
			--disable-armv6t2 \
			--disable-vfp \
			--disable-neon \
			--disable-inline-asm \
			--disable-yasm \
			--disable-mips32r2 \
			--disable-mipsdsp \
			--disable-mipsdspr2 \
			--disable-fast-unaligned \
			\
			--disable-muxers \
			--enable-muxer=mpeg1video \
			--enable-muxer=h264 \
			--enable-muxer=mp4 \
			--enable-muxer=image2 \
			--enable-muxer=mjpeg \
			--enable-muxer=rawvideo \
			--enable-muxer=mpeg2video \
			--enable-muxer=matroska \
			--enable-muxer=m4v \
			--enable-muxer=image2pipe \
			--enable-muxer=apng \
			--enable-muxer=mpegts \
			\
			--enable-encoders \
			--enable-encoder=mpeg1video \
			--enable-encoder=png \
			--enable-encoder=ljpeg \
			--enable-encoder=mpeg4 \
			--enable-encoder=jpeg2000 \
			--enable-encoder=jpegls \
			--enable-encoder=rawvideo \
			\
			--disable-decoders \
			--enable-decoder=alac \
			--enable-decoder=ape \
			--enable-decoder=atrac1 \
			--enable-decoder=atrac3 \
			--enable-decoder=atrac3p \
			--enable-decoder=cook \
			--enable-decoder=dca \
			--enable-decoder=dsd_lsbf \
			--enable-decoder=dsd_lsbf_planar \
			--enable-decoder=dsd_msbf \
			--enable-decoder=dsd_msbf_planar \
			--enable-decoder=eac3 \
			--enable-decoder=evrc \
			--enable-decoder=h264 \
			--enable-decoder=iac \
			--enable-decoder=imc \
			--enable-decoder=mace3 \
			--enable-decoder=mace6 \
			--enable-decoder=metasound \
			--enable-decoder=mjpeg \
			--enable-decoder=h264 \
			--enable-decoder=mpeg4 \
			--enable-decoder=jpeg2000 \
			--enable-decoder=jpegls \
			--enable-decoder=mlp \
			--enable-decoder=mp1 \
			--enable-decoder=mp3 \
			--enable-decoder=mp3adu \
			--enable-decoder=mp3on4 \
			--enable-decoder=mpeg1video \
			--enable-decoder=nellymoser \
			--enable-decoder=pcm_alaw \
			--enable-decoder=pcm_bluray \
			--enable-decoder=pcm_dvd \
			--enable-decoder=pcm_f32be \
			--enable-decoder=pcm_f32le \
			--enable-decoder=pcm_f64be \
			--enable-decoder=pcm_f64le \
			--enable-decoder=pcm_lxf \
			--enable-decoder=pcm_mulaw \
			--enable-decoder=pcm_s16be \
			--enable-decoder=pcm_s16be_planar \
			--enable-decoder=pcm_s16le \
			--enable-decoder=pcm_s16le_planar \
			--enable-decoder=pcm_s24be \
			--enable-decoder=pcm_s24daud \
			--enable-decoder=pcm_s24le \
			--enable-decoder=pcm_s24le_planar \
			--enable-decoder=pcm_s32be \
			--enable-decoder=pcm_s32le \
			--enable-decoder=pcm_s32le_planar \
			--enable-decoder=pcm_s8 \
			--enable-decoder=pcm_s8_planar \
			--enable-decoder=pcm_u16be \
			--enable-decoder=pcm_u16le \
			--enable-decoder=pcm_u24be \
			--enable-decoder=pcm_u24le \
			--enable-decoder=pcm_u32be \
			--enable-decoder=pcm_u32le \
			--enable-decoder=pcm_u8 \
			--enable-decoder=pcm_zork \
			--enable-decoder=png \
			--enable-decoder=ra_144 \
			--enable-decoder=ra_288 \
			--enable-decoder=ralf \
			--enable-decoder=s302m \
			--enable-decoder=shorten \
			--enable-decoder=sipr \
			--enable-decoder=sonic \
			--enable-decoder=tak \
			--enable-decoder=truehd \
			--enable-decoder=truespeech \
			--enable-decoder=tta \
			--enable-decoder=wmalossless \
			--enable-decoder=wmapro \
			--enable-decoder=wmav1 \
			--enable-decoder=wmav2 \
			--enable-decoder=wmavoice \
			--enable-decoder=aac \
			--enable-decoder=aac_latm \
			--enable-decoder=adpcm_ct \
			--enable-decoder=adpcm_g722 \
			--enable-decoder=adpcm_g726 \
			--enable-decoder=adpcm_g726le \
			--enable-decoder=adpcm_ima_amv \
			--enable-decoder=adpcm_ima_oki \
			--enable-decoder=adpcm_ima_qt \
			--enable-decoder=adpcm_ima_rad \
			--enable-decoder=adpcm_ima_wav \
			--enable-decoder=adpcm_ms \
			--enable-decoder=adpcm_sbpro_2 \
			--enable-decoder=adpcm_sbpro_3 \
			--enable-decoder=adpcm_sbpro_4 \
			--enable-decoder=adpcm_swf \
			--enable-decoder=adpcm_yamaha \
			--enable-decoder=flac \
			--enable-decoder=g723_1 \
			--enable-decoder=g729 \
			--enable-decoder=opus \
			--enable-decoder=qcelp \
			--enable-decoder=qdm2 \
			--enable-decoder=vorbis \
			--enable-decoder=wavpack \
			\
			--disable-demuxer=adp \
			--disable-demuxer=adx \
			--disable-demuxer=afc \
			--disable-demuxer=anm \
			--disable-demuxer=apc \
			--disable-demuxer=ast \
			--disable-demuxer=avs \
			--disable-demuxer=bethsoftvid \
			--disable-demuxer=bfi \
			--disable-demuxer=bink \
			--disable-demuxer=bmv \
			--disable-demuxer=brstm \
			--disable-demuxer=c93 \
			--disable-demuxer=cdg \
			--disable-demuxer=dnxhd \
			--disable-demuxer=dsicin \
			--disable-demuxer=dfa \
			--disable-demuxer=dxa \
			--disable-demuxer=ea \
			--disable-demuxer=ea_cdata \
			--disable-demuxer=frm \
			--disable-demuxer=gsm \
			--disable-demuxer=gxf \
			--disable-demuxer=hnm \
			--disable-demuxer=ico \
			--disable-demuxer=ilbc \
			--disable-demuxer=iss \
			--disable-demuxer=jv \
			--disable-demuxer=mm \
			--disable-demuxer=paf \
			--disable-demuxer=pva \
			--disable-demuxer=qcp \
			--disable-demuxer=redspark \
			--disable-demuxer=rl2 \
			--disable-demuxer=roq \
			--disable-demuxer=rsd \
			--disable-demuxer=rso \
			--disable-demuxer=siff \
			--disable-demuxer=smush \
			--disable-demuxer=sol \
			--disable-demuxer=thp \
			--disable-demuxer=tiertexseq \
			--disable-demuxer=tmv \
			--disable-demuxer=tty \
			--disable-demuxer=txd \
			--disable-demuxer=vqf \
			--disable-demuxer=wsaud \
			--disable-demuxer=wsvqa \
			--disable-demuxer=xa \
			--disable-demuxer=xbin \
			--disable-demuxer=yop \
			--disable-demuxer=ingenient \
			--disable-demuxer=image_dds_pipe \
			--disable-demuxer=image_dpx_pipe \
			--disable-demuxer=image_exr_pipe \
			--disable-demuxer=image_j2k_pipe \
			--disable-demuxer=image_pictor_pipe \
			--disable-demuxer=image_qdraw_pipe \
			--disable-demuxer=image_sgi_pipe \
			--disable-demuxer=image_sunrast_pipe \
			--enable-demuxer=image2 \
			--enable-demuxer=image2pipe \
			--enable-demuxer=m4v \
			--enable-demuxer=mpegts \
			--enable-demuxer=apng \
			--enable-demuxer=image_jpeg_pipe \
			--enable-demuxer=image_jpegls_pipe \
			--enable-demuxer=image_png_pipe \
			--enable-demuxer=realtext \
			--enable-demuxer=rawvideo \
			--enable-demuxer=ffmetadata \
			--enable-demuxer=image_bmp_pipe \
			--enable-demuxer=matroska \
			--enable-demuxer=h264 \
			--enable-demuxer=mpegvideo \
			\
			--enable-parser=h264 \
			--enable-parser=mjpeg \
			--enable-parser=mpeg4video \
			--enable-parser=mpegvideo \
			--enable-parser=png \
			\
			--disable-filters \
			--enable-filter=scale \
			--enable-filter=drawtext \
			\
			--enable-zlib \
			--enable-bzlib \
			\
			$(FFMPEG_CONF_OPTS) \
			\
			--enable-shared \
			--enable-openssl \
			--enable-network \
			--enable-small \
			--enable-stripping \
			--disable-static \
			--disable-debug \
			--disable-runtime-cpudetect \
			--disable-xlib \
			--disable-libxcb \
			--enable-pic \
			--enable-pthreads \
			--enable-hardcoded-tables \
			\
			--pkg-config="pkg-config" \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--extra-cflags="$(TARGET_CFLAGS) $(FFMPRG_EXTRA_CFLAGS)" \
			--extra-ldflags="$(TARGET_LDFLAGS) -lrt" \
			--arch=arm \
			--cpu=cortex-a15 \
			--target-os="linux" \
			--prefix=/usr \
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

endif
