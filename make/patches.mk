#
# patch helper
#
patch:
	@make neutrino-patch
	@make libstb-hal-patch
	@make neutrino-plugins-patch

neutrino-patch:
	@printf "$(TERM_YELLOW)---> create $(NEUTRINO).patch ... $(TERM_NORMAL)"
	$(shell cd $(SOURCE_DIR)/$(NEUTRINO) && git diff > $(BASE_DIR)/$(NEUTRINO).patch)
	@printf "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

libstb-hal-patch:
	@printf "$(TERM_YELLOW)---> create $(LIBSTB_HAL).patch ... $(TERM_NORMAL)"
	$(shell cd $(SOURCE_DIR)/$(LIBSTB_HAL) && git diff > $(BASE_DIR)/$(LIBSTB_HAL).patch)
	@printf "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

neutrino-plugins-patch:
	@printf "$(TERM_YELLOW)---> create neutrino-plugins.patch ... $(TERM_NORMAL)"
	$(shell cd $(SOURCE_DIR)/neutrino-plugins && git diff > $(BASE_DIR)/neutrino-plugins.patch)
	@printf "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino DDT
NEUTRINO_DDT_PATCHES =
NEUTRINO_LIBSTB_DDT_PATCHES =
NEUTRINO_PLUGINS_PATCHES =

# Neutrino Tango
NEUTRINO_TANGOS_PATCHES =
NEUTRINO_LIBSTB_TANGOS_PATCHES =

# Oscam patch
OSCAM_LOCAL_PATCH =
