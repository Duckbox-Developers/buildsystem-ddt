#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(TOOLS_DIR)/aio-grab-$(BOXARCH) distclean
	-$(MAKE) -C $(TOOLS_DIR)/gitVCInfo distclean
	-$(MAKE) -C $(TOOLS_DIR)/minimon-$(BOXARCH) distclean
	-$(MAKE) -C $(TOOLS_DIR)/msgbox distclean
	-$(MAKE) -C $(TOOLS_DIR)/satfind distclean
	-$(MAKE) -C $(TOOLS_DIR)/showiframe-$(BOXARCH) distclean
	-$(MAKE) -C $(TOOLS_DIR)/spf_tool distclean
	-$(MAKE) -C $(TOOLS_DIR)/tuxcom distclean
	-$(MAKE) -C $(TOOLS_DIR)/read-edid distclean
ifeq ($(BOXARCH), sh4)
	-$(MAKE) -C $(TOOLS_DIR)/devinit distclean
	-$(MAKE) -C $(TOOLS_DIR)/evremote2 distclean
	-$(MAKE) -C $(TOOLS_DIR)/fp_control distclean
	-$(MAKE) -C $(TOOLS_DIR)/flashtool-fup distclean
	-$(MAKE) -C $(TOOLS_DIR)/flashtool-mup distclean
	-$(MAKE) -C $(TOOLS_DIR)/flashtool_mup distclean
	-$(MAKE) -C $(TOOLS_DIR)/flashtool-pad distclean
	-$(MAKE) -C $(TOOLS_DIR)/hotplug distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	-$(MAKE) -C $(TOOLS_DIR)/ipbox_eeprom distclean
endif
	-$(MAKE) -C $(TOOLS_DIR)/stfbcontrol distclean
	-$(MAKE) -C $(TOOLS_DIR)/streamproxy distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
	-$(MAKE) -C $(TOOLS_DIR)/tfd2mtd distclean
	-$(MAKE) -C $(TOOLS_DIR)/tffpctl distclean
endif
	-$(MAKE) -C $(TOOLS_DIR)/ustslave distclean
	-$(MAKE) -C $(TOOLS_DIR)/vfdctl distclean
	-$(MAKE) -C $(TOOLS_DIR)/wait4button distclean
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuuno4kse vuultimo4k vusolo4k))
	-$(MAKE) -C $(TOOLS_DIR)/oled_ctrl distclean
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo4k vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
	-$(MAKE) -C $(TOOLS_DIR)/initfb distclean
	-$(MAKE) -C $(TOOLS_DIR)/turnoff_power distclean
endif
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
	-$(MAKE) -C $(TOOLS_DIR)/own-tools distclean
endif

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/aio-grab-$(BOXARCH); \
		$(CONFIGURE_TOOLS) CPPFLAGS="$(CPPFLAGS) -I$(DRIVER_DIR)/bpamem" \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# devinit
#
$(D)/tools-devinit: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/devinit; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# evremote2
#
$(D)/tools-evremote2: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/evremote2; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# fp_control
#
$(D)/tools-fp_control: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/fp_control; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# flashtool-fup
#
$(D)/tools-flashtool-fup: $(D)/directories
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/flashtool-fup; \
		./autogen.sh; \
		./configure \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(TOUCH)

#
# flashtool-mup
#
$(D)/tools-flashtool-mup: $(D)/directories
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/flashtool-mup; \
		./autogen.sh; \
		./configure \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(TOUCH)

#
# flashtool_mup-box
#
$(D)/tools_flashtool_mup:
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/flashtool_mup; \
		$(CONFIGURE_TOOLS) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# flashtool-pad
#
$(D)/tools-flashtool-pad: $(D)/directories
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/flashtool-pad; \
		./autogen.sh; \
		./configure \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(HOST_DIR)
	$(TOUCH)

#
# gitVCInfo
#
$(D)/tools-gitVCInfo: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/gitVCInfo; \
		$(CONFIGURE_TOOLS) CPPFLAGS="$(CPPFLAGS)" \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# hotplug
#
$(D)/tools-hotplug: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/hotplug; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# initfb
#
$(D)/tools-initfb: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/initfb; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# ipbox_eeprom
#
$(D)/tools-ipbox_eeprom: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/ipbox_eeprom; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libeplayer3
#
$(D)/tools-libeplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/libeplayer3; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libmme_host
#
$(D)/tools-libmme_host: $(D)/bootstrap $(D)/driver
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/libmme_host; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# libmme_image
#
$(D)/tools-libmme_image: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/libmme_image; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# minimon
#
$(D)/tools-minimon: $(D)/bootstrap $(D)/libjpeg_turbo
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/minimon-$(BOXARCH); \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR); \
		$(MAKE) install KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR) DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# msgbox
#
$(D)/tools-msgbox: $(D)/bootstrap $(D)/libpng $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/msgbox; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# oled_ctrl
#
$(D)/tools-oled_ctrl: $(D)/bootstrap $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/oled_ctrl; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# read-edid
#
$(D)/tools-read-edid: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/read-edid; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# satfind
#
$(D)/tools-satfind: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/satfind; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# showiframe
#
$(D)/tools-showiframe: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/showiframe-$(BOXARCH); \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# spf_tool
#
$(D)/tools-spf_tool: $(D)/bootstrap $(D)/libusb
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/spf_tool; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# stfbcontrol
#
$(D)/tools-stfbcontrol: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/stfbcontrol; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# streamproxy
#
$(D)/tools-streamproxy: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/streamproxy; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tfd2mtd
#
$(D)/tools-tfd2mtd: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/tfd2mtd; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tffpctl
#
$(D)/tools-tffpctl: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/tffpctl; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# turnoff_power
#
$(D)/tools-turnoff_power: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/turnoff_power; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tuxcom
#
$(D)/tools-tuxcom: $(D)/bootstrap $(D)/freetype
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/tuxcom; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# ustslave
#
$(D)/tools-ustslave: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/ustslave; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# vfdctl
#
ifeq ($(BOXTYPE), spark7162)
EXTRA_CPPFLAGS=-DHAVE_SPARK7162_HARDWARE
endif

$(D)/tools-vfdctl: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/vfdctl; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) CPPFLAGS="$(EXTRA_CPPFLAGS)"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# wait4button
#
$(D)/tools-wait4button: $(D)/bootstrap
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/wait4button; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# own-tools
#
$(D)/tools-own-tools: $(D)/bootstrap $(D)/libcurl
	$(START_BUILD)
	set -e; cd $(TOOLS_DIR)/own-tools; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

TOOLS  = $(D)/tools-aio-grab
TOOLS += $(D)/tools-msgbox
TOOLS += $(D)/tools-satfind
TOOLS += $(D)/tools-showiframe
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
TOOLS += $(D)/tools-tuxcom
endif
ifeq ($(BOXARCH), sh4)
TOOLS += $(D)/tools-devinit
TOOLS += $(D)/tools-evremote2
TOOLS += $(D)/tools-fp_control
TOOLS += $(D)/tools-flashtool-fup
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs912))
TOOLS += $(D)/tools_flashtool_mup
endif
TOOLS += $(D)/tools-flashtool-mup
TOOLS += $(D)/tools-flashtool-pad
#TOOLS += $(D)/tools-gitVCInfo
#TOOLS += $(D)/tools-hotplug
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
TOOLS += $(D)/tools-ipbox_eeprom
endif
TOOLS += $(D)/tools-stfbcontrol
TOOLS += $(D)/tools-streamproxy
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
TOOLS += $(D)/tools-tfd2mtd
TOOLS += $(D)/tools-tffpctl
endif
TOOLS += $(D)/tools-ustslave
TOOLS += $(D)/tools-vfdctl
TOOLS += $(D)/tools-wait4button
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k vuuno4kse vuultimo4k vusolo4k))
TOOLS += $(D)/tools-oled_ctrl
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo4k vuuno4kse vuzero4k vuultimo4k vuuno4k vusolo4k))
TOOLS += $(D)/tools-initfb
TOOLS += $(D)/tools-turnoff_power
endif
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
TOOLS += $(D)/tools-own-tools
endif

$(D)/tools: $(TOOLS)
	@touch $@
