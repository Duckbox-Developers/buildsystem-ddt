#
# DIVERSE STUFF / TOOLS
#
$(D)/diverse-tools:
	$(START_BUILD)
	( cd root/etc && for i in $(DIVERSE_TOOLS_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; done ) ; \
	( cd root/etc && for i in $(INITSCRIPTS_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; done ) || true ; \
	( cd root/etc && for i in $(BASE_FILES_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; done ) ; \
	( cd root/etc && for i in $(BASE_PASSWD_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; done ) ; \
	( cd root/etc && for i in $(NETBASE_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; done ) ; \
	ln -sf /usr/share/zoneinfo/CET $(TARGET_DIR)/etc/localtime
	$(TOUCH)

#
# Adapted etc files and etc read-write files
#
DIVERSE_TOOLS_ADAPTED_ETC_FILES =
#init.d/swap

OPENRDATE_ADAPTED_ETC_FILES = \
	init.d/rdate.sh

MODULE_INIT_TOOLS_ADAPTED_ETC_FILES = \
	modules
#init.d/module-init-tools

FUSE_ADAPTED_ETC_FILES = \
	init.d/fuse

BASE_FILES_ADAPTED_ETC_FILES = \
	timezone.xml \
	hosts \
	fstab \
	profile \
	resolv.conf \
	shells \
	shells.conf \
	host.conf \
	nsswitch.conf

BASE_PASSWD_ADAPTED_ETC_FILES = \
	passwd \
	group

NETBASE_ADAPTED_ETC_FILES = \
	protocols \
	services \
	network/interfaces \
	network/options

INITSCRIPTS_ADAPTED_ETC_FILES = \
	hostname \
	vdstandby.cfg \
	init.d/bootclean.sh \
	init.d/hostname \
	init.d/mountall \
	init.d/network \
	init.d/networking \
	init.d/rc \
	init.d/reboot \
	init.d/sendsigs \
	init.d/udhcpc \
	init.d/umountfs

ifeq ($(BOXARCH), sh4)
INITSCRIPTS_ADAPTED_ETC_FILES += \
	init.d/getfb.awk \
	init.d/makedev \
	init.d/mountvirtfs \
endif

#
# Functions for copying customized etc files from cdk/root/etc into yaud targets and
# for updating init scripts in runlevel for yaud targets
#
define adapted-etc-files
	cd root/etc && \
	for i in $(1); do \
		[ -f $$i ] && install -m 644 $$i $(TARGET_DIR)/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(TARGET_DIR)/etc/$$i || true; \
	done
endef
