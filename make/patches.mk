#
# patch helper
#
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#

# Neutrino MP DDT
NEUTRINO_MP_DDT_PATCHES +=
NEUTRINO_MP_LIBSTB_DDT_PATCHES +=

# Neutrino MP NI
NEUTRINO_MP_NI_PATCHES +=
NEUTRINO_MP_LIBSTB_NI_PATCHES +=

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES +=
NEUTRINO_MP_LIBSTB_TANGOS_PATCHES +=

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=

