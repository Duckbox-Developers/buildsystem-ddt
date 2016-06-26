#
# diff helper
#
enigma2-patch \
neutrino-mp-next-patch \
neutrino-mp-tangos-patch \
neutrino-mp-cst-next-patch \
neutrino-mp-cst-next-max-patch \
libstb-hal-next-patch \
libstb-hal-cst-next-patch :
	cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino MP Max from github
NEUTRINO_MP_LIBSTB_CST_NEXT_MAX_PATCHES +=
NEUTRINO_MP_CST_NEXT_MAX_PATCHES +=

# Neutrino MP from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES +=
NEUTRINO_MP_CST_NEXT_PATCHES +=

# Neutrino MP Next from github
NEUTRINO_MP_LIBSTB_NEXT_PATCHES +=
NEUTRINO_MP_NEXT_PATCHES +=

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES +=

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=

