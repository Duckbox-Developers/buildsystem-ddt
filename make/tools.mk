#
# tools
#
tools-clean:
	-$(MAKE) -C $(APPS_DIR)/tools distclean

$(APPS_DIR)/tools/config.status: $(D)/bootstrap $(D)/driver $(D)/bzip2 $(D)/libpng $(D)/libjpeg $(D)/ffmpeg
	set -e; cd $(APPS_DIR)/tools; \
	./autogen.sh; \
	$(CONFIGURE) \
	--prefix=$(TARGETPREFIX)/usr \
	--with-boxtype=$(BOXTYPE) \
	$(if $(MULTICOM324), --enable-multicom324) \
	$(if $(MULTICOM406), --enable-multicom406) \
	$(if $(EPLAYER3), --enable-eplayer3)

$(D)/tools: $(APPS_DIR)/tools/config.status
	$(MAKE) -C $(APPS_DIR)/tools all prefix=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR) \
	CPPFLAGS="\
	-I$(TARGETPREFIX)/usr/include \
	-I$(DRIVER_DIR)/bpamem \
	-I$(DRIVER_DIR)/include/multicom \
	-I$(DRIVER_DIR)/multicom/mme \
	-I$(DRIVER_DIR)/include/player2 \
	$(if $(PLAYER191), -DPLAYER191) \
	" ; \
	$(MAKE) -C $(APPS_DIR)/tools install prefix=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR)
	touch $@

#
# aio-grab
#
$(D)/aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	set -e; cd $(APPS_DIR)/tools/aio-grab; \
		$(CONFIGURE) CPPFLAGS="-I$(DRIVER_DIR)/bpamem" \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# devinit
#
$(D)/devinit: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/devinit; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# evremote2
#
$(D)/evremote2: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/evremote2; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# fp_control
#
$(D)/fp_control: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/fp_control; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# hotplug
#
$(D)/hotplug: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/hotplug; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# libeplayer3
#
$(D)/libeplayer3: $(D)/bootstrap $(D)/ffmpeg
	set -e; cd $(APPS_DIR)/tools/libeplayer3; \
		$(CONFIGURE) \
			--prefix=$(TARGETPREFIX) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# libmme_host
#
$(D)/libmme_host: $(D)/bootstrap $(D)/driver
	set -e; cd $(APPS_DIR)/tools/libmme_host; \
		$(CONFIGURE) \
			--prefix= \
			$(if $(MULTICOM324), --enable-multicom324) \
			$(if $(MULTICOM406), --enable-multicom406) \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR)
	touch $@

#
# libmme_image
#
$(D)/libmme_image: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/libmme_image; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR)
	touch $@

#
# showiframe
#
$(D)/showiframe: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/showiframe; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# spf_tool
#
$(D)/spf_tool: $(D)/bootstrap $(D)/libusb
	set -e; cd $(APPS_DIR)/tools/spf_tool; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# streamproxy
#
$(D)/streamproxy: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/streamproxy; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# ustslave
#
$(D)/ustslave: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/ustslave; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# vfdctl
#
$(D)/vfdctl: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/vfdctl; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# wait4button
#
$(D)/wait4button: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/wait4button; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

