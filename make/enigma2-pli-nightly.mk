#
# enigma2-pli-nightly
#
ENIGMA2_DEPS  = $(D)/bootstrap $(D)/opkg $(D)/libncurses $(D)/libcurl $(D)/libid3tag $(D)/libmad $(D)/libpng $(D)/libjpeg $(D)/libgif
ENIGMA2_DEPS += $(D)/libfreetype $(D)/libfribidi $(D)/libsigc++_e2 $(D)/libexpat $(D)/libdvbsi++ $(D)/sdparm $(D)/minidlna $(D)/ethtool
ENIGMA2_DEPS += python-all
ENIGMA2_DEPS += $(D)/libdreamdvd $(D)/tuxtxt32bpp $(D)/hotplug_e2 $(D)/wpa_supplicant $(D)/wireless_tools

E_CPPFLAGS    = -I$(DRIVER_DIR)/include
E_CPPFLAGS   += -I$(TARGETPREFIX)/usr/include
E_CPPFLAGS   += -I$(KERNEL_DIR)/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools/libeplayer3/include

ifeq ($(EXTERNAL_LCD), externallcd)
ENIGMA2_DEPS  += $(D)/graphlcd
E_CONFIG_OPTS += --with-graphlcd
endif

ifeq ($(MEDIAFW), gstreamer)
E_CONFIG_OPTS += --enable-mediafwgstreamer
endif

ifeq ($(MEDIAFW), eplayer3)
E_CONFIG_OPTS += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gst-eplayer3)
ENIGMA2_DEPS  += $(D)/gst_plugins_dvbmediasink
E_CONFIG_OPTS += --enable-libeplayer3 --enable-mediafwgstreamer
endif

#
# yaud-enigma2-pli-nightly
#
yaud-enigma2-pli-nightly: yaud-none $(D)/host_python $(D)/lirc \
		$(D)/enigma2-pli-nightly $(D)/enigma2-plugins $(D)/release_enigma2
	$(TUXBOX_YAUD_CUSTOMIZE)

#
# enigma2-pli-nightly
#
$(D)/enigma2-pli-nightly.do_prepare: | $(ENIGMA2_DEPS)
	REVISION=""; \
	HEAD="master"; \
	DIFF="0"; \
	clear; \
	echo ""; \
	echo "Choose between the following revisions:"; \
	echo "========================================================================================================"; \
	echo " 0) Newest                 - E2 OpenPli gstreamer / libplayer3    (Can fail due to outdated patch)     "; \
	echo "========================================================================================================"; \
	echo " 1) Use your own e2 git dir without patchfile"; \
	echo "========================================================================================================"; \
	echo " 2) Mon, 17 Aug 2015 07:08 - E2 OpenPli gstreamer / libplayer3 cd5505a4b8aba823334032bb6fd7901557575455"; \
	echo "========================================================================================================"; \
	echo "Media Framework : $(MEDIAFW)"; \
	echo "External LCD    : $(EXTERNALLCD)"; \
	read -p "Select          : "; \
	[ "$$REPLY" == "0" ] && DIFF="0"; \
	[ "$$REPLY" == "1" ] && DIFF="1" && REVISION=""; \
	[ "$$REPLY" == "2" ] && DIFF="2" && REVISION="cd5505a4b8aba823334032bb6fd7901557575455"; \
	echo "Revision        : "$$REVISION; \
	echo "Selection       : "$$REPLY; \
	echo ""; \
	if [ "$$REPLY" != "1" ]; then \
		REPO="https://github.com/OpenPLi/enigma2.git"; \
		rm -rf $(SOURCE_DIR)/enigma2-nightly; \
		rm -rf $(SOURCE_DIR)/enigma2-nightly.org; \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] && \
		(cd $(ARCHIVE)/enigma2-pli-nightly.git; git pull; git checkout HEAD; cd "$(BUILD_TMP)";); \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] || \
		git clone -b $$HEAD $$REPO $(ARCHIVE)/enigma2-pli-nightly.git; \
		cp -ra $(ARCHIVE)/enigma2-pli-nightly.git $(SOURCE_DIR)/enigma2-nightly; \
		[ "$$REVISION" == "" ] || (cd $(SOURCE_DIR)/enigma2-nightly; git checkout "$$REVISION"; cd "$(BUILD_TMP)";); \
		cp -ra $(SOURCE_DIR)/enigma2-nightly $(SOURCE_DIR)/enigma2-nightly.org; \
		set -e; cd $(SOURCE_DIR)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-pli-nightly.$$DIFF.diff"; \
	fi
	touch $@

$(SOURCE_DIR)/enigma2-pli-nightly/config.status:
	cd $(SOURCE_DIR)/enigma2-nightly && \
		./autogen.sh && \
		export PKG_CONFIG=$(HOSTPREFIX)/bin/$(TARGET)-pkg-config && \
		export PKG_CONFIG_PATH=$(TARGETPREFIX)/usr/lib/pkgconfig && \
		sed -e 's|#!/usr/bin/python|#!$(HOSTPREFIX)/bin/python|' -i po/xml2po.py && \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--with-libsdl=no \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=none \
			--with-gstversion=1.0 \
			PY_PATH=$(TARGETPREFIX)/usr \
			$(PLATFORM_CPPFLAGS) \
			$(E_CONFIG_OPTS)

$(D)/enigma2-pli-nightly.do_compile: $(SOURCE_DIR)/enigma2-pli-nightly/config.status
	cd $(SOURCE_DIR)/enigma2-nightly && \
		$(MAKE) all
	touch $@

$(D)/enigma2-pli-nightly: $(D)/enigma2-pli-nightly.do_prepare $(D)/enigma2-pli-nightly.do_compile
	$(MAKE) -C $(SOURCE_DIR)/enigma2-nightly install DESTDIR=$(TARGETPREFIX)
	if [ -e $(TARGETPREFIX)/usr/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGETPREFIX)/usr/bin/enigma2; \
	fi
	if [ -e $(TARGETPREFIX)/usr/local/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGETPREFIX)/usr/local/bin/enigma2; \
	fi
	touch $@

enigma2-pli-nightly-clean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	cd $(SOURCE_DIR)/enigma2-nightly && \
		$(MAKE) distclean

enigma2-pli-nightly-distclean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	rm -f $(D)/enigma2-pli-nightly.do_prepare
	rm -rf $(SOURCE_DIR)/enigma2-nightly
	rm -rf $(SOURCE_DIR)/enigma2-nightly.org
