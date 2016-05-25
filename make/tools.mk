#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(APPS_DIR)/tools/aio-grab clean
	-$(MAKE) -C $(APPS_DIR)/tools/devinit clean
	-$(MAKE) -C $(APPS_DIR)/tools/evremote2 clean
	-$(MAKE) -C $(APPS_DIR)/tools/fp_control clean
	-$(MAKE) -C $(APPS_DIR)/tools/hotplug clean
	-$(MAKE) -C $(APPS_DIR)/tools/libeplayer3 clean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_host clean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_image clean
	-$(MAKE) -C $(APPS_DIR)/tools/showiframe clean
	-$(MAKE) -C $(APPS_DIR)/tools/spf_tool clean
	-$(MAKE) -C $(APPS_DIR)/tools/stfbcontrol clean
	-$(MAKE) -C $(APPS_DIR)/tools/streamproxy clean
	-$(MAKE) -C $(APPS_DIR)/tools/ustslave clean
	-$(MAKE) -C $(APPS_DIR)/tools/vfdctl clean
	-$(MAKE) -C $(APPS_DIR)/tools/wait4button clean

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
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
$(D)/tools-devinit: $(D)/bootstrap
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
$(D)/tools-evremote2: $(D)/bootstrap
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
$(D)/tools-fp_control: $(D)/bootstrap
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
$(D)/tools-hotplug: $(D)/bootstrap
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
$(D)/tools-libeplayer3: $(D)/bootstrap $(D)/ffmpeg
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
$(D)/tools-libmme_host: $(D)/bootstrap $(D)/driver
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
$(D)/tools-libmme_image: $(D)/bootstrap
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
$(D)/tools-showiframe: $(D)/bootstrap
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
$(D)/tools-spf_tool: $(D)/bootstrap $(D)/libusb
	set -e; cd $(APPS_DIR)/tools/spf_tool; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# stfbcontrol
#
$(D)/tools-stfbcontrol: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/stfbcontrol; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

#
# streamproxy
#
$(D)/tools-streamproxy: $(D)/bootstrap
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
$(D)/tools-ustslave: $(D)/bootstrap
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
$(D)/tools-vfdctl: $(D)/bootstrap
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
$(D)/tools-wait4button: $(D)/bootstrap
	set -e; cd $(APPS_DIR)/tools/wait4button; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	touch $@

