#
# diff helper
#
enigma2-patch \
neutrino-hd2-patch \
neutrino-mp-next-patch \
neutrino-mp-tangos-patch \
neutrino-mp-cst-next-patch \
neutrino-mp-cst-next-ni-patch \
libstb-hal-next-patch \
libstb-hal-cst-next-patch \
libstb-hal-cst-next-tangos-patch:
	cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#

# LIB-STB-Hal for MP CST Next / NI from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES +=

# Neutrino MP CST Next from github
NEUTRINO_MP_CST_NEXT_PATCHES +=

# Neutrino MP CST Next NI from github
NEUTRINO_MP_CST_NEXT_NI_PATCHES +=

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES +=

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=

