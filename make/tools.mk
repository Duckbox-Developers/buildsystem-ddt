#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(APPS_DIR)/tools/aio-grab distclean
	-$(MAKE) -C $(APPS_DIR)/tools/devinit distclean
	-$(MAKE) -C $(APPS_DIR)/tools/evremote2 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/fp_control distclean
	-$(MAKE) -C $(APPS_DIR)/tools/hotplug distclean
	-$(MAKE) -C $(APPS_DIR)/tools/ipbox_eeprom distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libeplayer3 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_host distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_image distclean
	-$(MAKE) -C $(APPS_DIR)/tools/showiframe distclean
	-$(MAKE) -C $(APPS_DIR)/tools/spf_tool distclean
	-$(MAKE) -C $(APPS_DIR)/tools/stfbcontrol distclean
	-$(MAKE) -C $(APPS_DIR)/tools/streamproxy distclean
	-$(MAKE) -C $(APPS_DIR)/tools/ustslave distclean
	-$(MAKE) -C $(APPS_DIR)/tools/vfdctl distclean
	-$(MAKE) -C $(APPS_DIR)/tools/wait4button distclean

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/aio-grab; \
		$(CONFIGURE_TOOLS) CPPFLAGS="$(CPPFLAGS) -I$(DRIVER_DIR)/bpamem" \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# devinit
#
$(D)/tools-devinit: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/devinit; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# evremote2
#
$(D)/tools-evremote2: $(D)/bootstrap
	@$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/evremote2; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# fp_control
#
$(D)/tools-fp_control: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/fp_control; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	@$(TOUCH)

#
# hotplug
#
$(D)/tools-hotplug: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/hotplug; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# ipbox_eeprom
#
$(D)/tools-ipbox_eeprom: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/ipbox_eeprom; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# libeplayer3
#
$(D)/tools-libeplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/libeplayer3; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# libmme_host
#
$(D)/tools-libmme_host: $(D)/bootstrap $(D)/driver
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/libmme_host; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			$(if $(MULTICOM324), --enable-multicom324) \
			$(if $(MULTICOM406), --enable-multicom406) \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# libmme_image
#
$(D)/tools-libmme_image: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/libmme_image; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# showiframe
#
$(D)/tools-showiframe: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/showiframe; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# spf_tool
#
$(D)/tools-spf_tool: $(D)/bootstrap $(D)/libusb
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/spf_tool; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# stfbcontrol
#
$(D)/tools-stfbcontrol: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/stfbcontrol; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# streamproxy
#
$(D)/tools-streamproxy: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/streamproxy; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# ustslave
#
$(D)/tools-ustslave: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/ustslave; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# vfdctl
#
ifeq ($(BOXTYPE), spark7162)
EXTRA_CPPFLAGS=-DHAVE_SPARK7162_HARDWARE
endif

$(D)/tools-vfdctl: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/vfdctl; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) CPPFLAGS="$(EXTRA_CPPFLAGS)"; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)

#
# wait4button
#
$(D)/tools-wait4button: $(D)/bootstrap
	$(START_BUILD)
	@set -e; cd $(APPS_DIR)/tools/wait4button; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(TOUCH)


TOOLS  = $(D)/tools-aio-grab
TOOLS += $(D)/tools-devinit
TOOLS += $(D)/tools-evremote2
TOOLS += $(D)/tools-fp_control
TOOLS += $(D)/tools-hotplug
TOOLS += $(D)/tools-ipbox_eeprom
TOOLS += $(D)/tools-showiframe
TOOLS += $(D)/tools-stfbcontrol
TOOLS += $(D)/tools-streamproxy
TOOLS += $(D)/tools-ustslave
TOOLS += $(D)/tools-vfdctl
TOOLS += $(D)/tools-wait4button
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
TOOLS += $(D)/tools-libmme_host
TOOLS += $(D)/tools-libmme_image
endif
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3 gst-eplayer3))
TOOLS += $(D)/tools-libeplayer3
endif

$(D)/tools: $(TOOLS)
	@touch $@
