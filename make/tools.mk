#
# tools
#
tools-clean:
	-$(MAKE) -C $(APPS_DIR)/tools distclean

$(APPS_DIR)/tools/config.status: $(D)/bootstrap $(D)/driver $(D)/bzip2 $(D)/libpng $(D)/libjpeg $(D)/ffmpeg
	set -e; cd $(APPS_DIR)/tools; \
	$(CONFIGURE) \
	--prefix=$(TARGETPREFIX)/usr \
	--with-boxtype=$(BOXTYPE) \
	$(if $(MULTICOM324), --enable-multicom324) \
	$(if $(MULTICOM406), --enable-multicom406) \
	$(if $(EPLAYER3), --enable-eplayer3)

$(D)/tools: $(APPS_DIR)/tools/config.status
	$(MAKE) -C $(APPS_DIR)/tools all prefix=$(TARGETPREFIX) \
	CPPFLAGS="\
	-I$(TARGETPREFIX)/usr/include \
	-I$(DRIVER_DIR)/bpamem \
	-I$(DRIVER_DIR)/include/multicom \
	-I$(DRIVER_DIR)/multicom/mme \
	-I$(DRIVER_DIR)/include/player2 \
	$(if $(PLAYER191), -DPLAYER191) \
	" ; \
	$(MAKE) -C $(APPS_DIR)/tools install prefix=$(TARGETPREFIX)
	touch $@

