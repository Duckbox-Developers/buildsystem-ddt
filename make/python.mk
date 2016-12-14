#
# python helpers
#
PYTHON_BUILD = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGETPREFIX)$(PYTHON_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGETPREFIX)/usr/include/python$(PYTHON_VERSION)" \
	$(HOSTPREFIX)/bin/python ./setup.py build --executable=/usr/bin/python

PYTHON_INSTALL = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGETPREFIX)$(PYTHON_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGETPREFIX)/usr/include/python$(PYTHON_VERSION)" \
	$(HOSTPREFIX)/bin/python ./setup.py install --root=$(TARGETPREFIX) --prefix=/usr

#
# host_python
#
PYTHON_MAJOR = 2.7
PYTHON_MINOR = 12
PYTHON_VER = $(PYTHON_MAJOR).$(PYTHON_MINOR)
PYTHON_PATCH  = python-$(PYTHON_VER)-xcompile.patch
PYTHON_PATCH += python-$(PYTHON_VER)-revert_use_of_sysconfigdata.patch
PYTHON_PATCH += python-$(PYTHON_VER).patch
PYTHON_PATCH += python-$(PYTHON_VER)-pgettext.patch

# backwards compatibility
PYTHON_VERSION = $(PYTHON_MAJOR)
PYTHON_DIR = /usr/lib/python$(PYTHON_VERSION)
PYTHON_INCLUDE_DIR = /usr/include/python$(PYTHON_VERSION)

$(ARCHIVE)/Python-$(PYTHON_VER).tar.xz:
	$(WGET) http://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tar.xz

$(D)/host_python: $(ARCHIVE)/Python-$(PYTHON_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/Python-$(PYTHON_VER).tar.xz
	set -e; cd $(BUILD_TMP)/Python-$(PYTHON_VER); \
		$(call post_patch,$(PYTHON_PATCH)); \
		autoconf; \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure $(CONFIGURE_SILENT) \
			--without-cxx-main \
			--with-threads \
		; \
		$(MAKE) python Parser/pgen; \
		mv python ./hostpython; \
		mv Parser/pgen ./hostpgen; \
		\
		$(MAKE) distclean; \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(HOSTPREFIX) \
			--sysconfdir=$(HOSTPREFIX)/etc \
			--without-cxx-main \
			--with-threads \
		; \
		$(MAKE) all install; \
		cp ./hostpgen $(HOSTPREFIX)/bin/pgen
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

#
# python
#
$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/libncurses $(D)/zlib $(D)/openssl $(D)/libffi $(D)/bzip2 $(D)/libreadline $(D)/sqlite $(ARCHIVE)/Python-$(PYTHON_VER).tar.xz
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/Python-$(PYTHON_VER).tar.xz
	set -e; cd $(BUILD_TMP)/Python-$(PYTHON_VER); \
		$(call post_patch,$(PYTHON_PATCH)); \
		CONFIG_SITE= \
		$(BUILDENV) \
		autoreconf --verbose --install --force Modules/_ctypes/libffi; \
		autoconf; \
		./configure $(CONFIGURE_SILENT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--enable-shared \
			--with-lto \
			--enable-ipv6 \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			ac_sys_system=Linux \
			ac_sys_release=2 \
			ac_cv_file__dev_ptmx=no \
			ac_cv_file__dev_ptc=no \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(HOSTPREFIX)/bin/python \
		; \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON_MODULES_INCLUDE="$(TARGETPREFIX)/usr/include" \
			PYTHON_MODULES_LIB="$(TARGETPREFIX)/usr/lib" \
			PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="$(TARGETPREFIX)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(TARGET) \
			MACHDEP=linux2 \
			HOSTARCH=$(TARGET) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(TARGET)-gcc" \
			HOSTPYTHON=$(HOSTPREFIX)/bin/python \
			HOSTPGEN=$(HOSTPREFIX)/bin/pgen \
			all install DESTDIR=$(TARGETPREFIX) \
		; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	ln -sf ../../libpython$(PYTHON_VERSION).so.1.0 $(TARGETPREFIX)/$(PYTHON_DIR)/config/libpython$(PYTHON_VERSION).so; \
	ln -sf $(TARGETPREFIX)/$(PYTHON_INCLUDE_DIR) $(TARGETPREFIX)/usr/include/python
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/python-2.7.pc
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

#
# python_setuptools
#
PYTHON_SETUPTOOLS_VER = 5.2

$(ARCHIVE)/setuptools-$(PYTHON_SETUPTOOLS_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/s/setuptools/setuptools-$(PYTHON_SETUPTOOLS_VER).tar.gz

$(D)/python_setuptools: $(D)/bootstrap $(D)/python $(ARCHIVE)/setuptools-$(PYTHON_SETUPTOOLS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(UNTAR)/setuptools-$(PYTHON_SETUPTOOLS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/setuptools-$(PYTHON_SETUPTOOLS_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(TOUCH)

#
# libxmlccwrap
#
LIBXMLCCWRAP_VER = 0.0.12

$(ARCHIVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER).tar.gz:
	$(WGET) http://www.ant.uni-bremen.de/whomes/rinas/libxmlccwrap/download/libxmlccwrap-$(PYTHON_IMAGING_VER).tar.gz

$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2_e2 $(D)/libxslt $(ARCHIVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER)
	$(UNTAR)/libxmlccwrap-$(LIBXMLCCWRAP_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libxmlccwrap-$(LIBXMLCCWRAP_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libxmlccwrap.la
	$(REMOVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER)
	$(TOUCH)

#
# python_lxml
#
PYTHON_LXML_MAJOR = 2.2
PYTHON_LXML_MINOR = 8
PYTHON_LXML_VER = $(PYTHON_LXML_MAJOR).$(PYTHON_LXML_MINOR)

$(ARCHIVE)/lxml-$(PYTHON_LXML_VER).tgz:
	$(WGET) http://launchpad.net/lxml/$(PYTHON_LXML_MAJOR)/$(PYTHON_LXML_VER)/+download/lxml-$(PYTHON_LXML_VER).tgz

$(D)/python_lxml: $(D)/bootstrap $(D)/python $(D)/libxslt $(D)/python_setuptools $(ARCHIVE)/lxml-$(PYTHON_LXML_VER).tgz
	$(START_BUILD)
	$(REMOVE)/lxml-$(PYTHON_LXML_VER)
	$(UNTAR)/lxml-$(PYTHON_LXML_VER).tgz
	set -e; cd $(BUILD_TMP)/lxml-$(PYTHON_LXML_VER); \
		$(PYTHON_BUILD) \
			--with-xml2-config=$(HOSTPREFIX)/bin/xml2-config \
			--with-xslt-config=$(HOSTPREFIX)/bin/xslt-config; \
		$(PYTHON_INSTALL)
	$(REMOVE)/lxml-$(PYTHON_LXML_VER)
	$(TOUCH)

#
# python_twisted
#
PYTHON_TWISTED_VER = 16.0.0

$(ARCHIVE)/Twisted-$(PYTHON_TWISTED_VER).tar.bz2:
	$(WGET) http://pypi.python.org/packages/source/T/Twisted/Twisted-$(PYTHON_TWISTED_VER).tar.bz2

$(D)/python_twisted: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_zope_interface $(D)/python_pyopenssl $(D)/python_service_identity $(ARCHIVE)/Twisted-$(PYTHON_TWISTED_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(UNTAR)/Twisted-$(PYTHON_TWISTED_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/Twisted-$(PYTHON_TWISTED_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(TOUCH)

#
# python_imaging
#
PYTHON_IMAGING_VER = 1.1.7
PYTHON_IMAGING_PATCH = python-imaging-$(PYTHON_IMAGING_VER).patch

$(ARCHIVE)/Imaging-$(PYTHON_IMAGING_VER).tar.gz:
	$(WGET) http://effbot.org/downloads/Imaging-$(PYTHON_IMAGING_VER).tar.gz

$(D)/python_imaging: $(D)/bootstrap $(D)/libjpeg $(D)/libfreetype $(D)/python $(D)/python_setuptools $(ARCHIVE)/Imaging-$(PYTHON_IMAGING_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/Imaging-$(PYTHON_IMAGING_VER)
	$(UNTAR)/Imaging-$(PYTHON_IMAGING_VER).tar.gz
	set -e; cd $(BUILD_TMP)/Imaging-$(PYTHON_IMAGING_VER); \
		$(call post_patch,$(PYTHON_IMAGING_PATCH)); \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${TARGETPREFIX}/usr\")|" "setup.py"; \
		$(PYTHON_INSTALL)
	$(REMOVE)/Imaging-$(PYTHON_IMAGING_VER)
	$(TOUCH)

#
# python_pycrypto
#
PYTHON_PYCRYPTO_VER = 2.6.1
PYTHON_PYCRYPTO_PATCH = python-pycrypto-$(PYTHON_PYCRYPTO_VER).patch

$(ARCHIVE)/pycrypto-$(PYTHON_PYCRYPTO_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/p/pycrypto/pycrypto-$(PYTHON_PYCRYPTO_VER).tar.gz

$(D)/python_pycrypto: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/pycrypto-$(PYTHON_PYCRYPTO_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pycrypto-$(PYTHON_PYCRYPTO_VER)
	$(UNTAR)/pycrypto-$(PYTHON_PYCRYPTO_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pycrypto-$(PYTHON_PYCRYPTO_VER); \
		$(call post_patch,$(PYTHON_PYCRYPTO_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(PYTHON_INSTALL)
	$(REMOVE)/pycrypto-$(PYTHON_PYCRYPTO_VER)
	$(TOUCH)

#
# python_pyusb
#
PYTHON_PYUSB_VER = 1.0.0a3

$(ARCHIVE)/pyusb-$(PYTHON_PYUSB_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/p/pyusb/pyusb-$(PYTHON_PYUSB_VER).tar.gz

$(D)/python_pyusb: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/pyusb-$(PYTHON_PYUSB_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pyusb-$(PYTHON_PYUSB_VER)
	$(UNTAR)/pyusb-$(PYTHON_PYUSB_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pyusb-$(PYTHON_PYUSB_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyusb-$(PYTHON_PYUSB_VER)
	$(TOUCH)

#
# python_six
#
PYTHON_SIX_VER = 1.9.0

$(ARCHIVE)/six-$(PYTHON_SIX_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/s/six/six-$(PYTHON_SIX_VER).tar.gz

$(D)/python_six: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/six-$(PYTHON_SIX_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/six-$(PYTHON_SIX_VER)
	$(UNTAR)/six-$(PYTHON_SIX_VER).tar.gz
	set -e; cd $(BUILD_TMP)/six-$(PYTHON_SIX_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/six-$(PYTHON_SIX_VER)
	$(TOUCH)

#
# python_cffi
#
PYTHON_CFFI_VER = 1.2.1

$(ARCHIVE)/cffi-$(PYTHON_CFFI_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/c/cffi/cffi-$(PYTHON_CFFI_VER).tar.gz

$(D)/python_cffi: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/cffi-$(PYTHON_CFFI_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/cffi-$(PYTHON_CFFI_VER)
	$(UNTAR)/cffi-$(PYTHON_CFFI_VER).tar.gz
	set -e; cd $(BUILD_TMP)/cffi-$(PYTHON_CFFI_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/cffi-$(PYTHON_CFFI_VER)
	$(TOUCH)

#
# python_enum34
#
PYTHON_ENUM34_VER = 1.0.4

$(ARCHIVE)/enum34-$(PYTHON_ENUM34_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/e/enum34/enum34-$(PYTHON_ENUM34_VER).tar.gz

$(D)/python_enum34: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/enum34-$(PYTHON_ENUM34_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/enum34-$(PYTHON_ENUM34_VER)
	$(UNTAR)/enum34-$(PYTHON_ENUM34_VER).tar.gz
	set -e; cd $(BUILD_TMP)/enum34-$(PYTHON_ENUM34_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/enum34-$(PYTHON_ENUM34_VER)
	$(TOUCH)

#
# python_pyasn1_modules
#
PYTHON_PYASN1_MODULES_VER = 0.0.7

$(ARCHIVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/p/pyasn1-modules/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER).tar.gz

$(D)/python_pyasn1_modules: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER)
	$(UNTAR)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER)
	$(TOUCH)

#
# python_pyasn1
#
PYTHON_PYASN1_VER = 0.1.8

$(ARCHIVE)/pyasn1-$(PYTHON_PYASN1_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/p/pyasn1/pyasn1-$(PYTHON_PYASN1_VER).tar.gz

$(D)/python_pyasn1: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1_modules $(ARCHIVE)/pyasn1-$(PYTHON_PYASN1_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pyasn1-$(PYTHON_PYASN1_VER)
	$(UNTAR)/pyasn1-$(PYTHON_PYASN1_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pyasn1-$(PYTHON_PYASN1_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyasn1-$(PYTHON_PYASN1_VER)
	$(TOUCH)

#
# python_pycparser
#
PYTHON_PYCPARSER_VER = 2.14

$(ARCHIVE)/pycparser-$(PYTHON_PYCPARSER_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/p/pycparser/pycparser-$(PYTHON_PYCPARSER_VER).tar.gz

$(D)/python_pycparser: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1 $(ARCHIVE)/pycparser-$(PYTHON_PYCPARSER_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pycparser-$(PYTHON_PYCPARSER_VER)
	$(UNTAR)/pycparser-$(PYTHON_PYCPARSER_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pycparser-$(PYTHON_PYCPARSER_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pycparser-$(PYTHON_PYCPARSER_VER)
	$(TOUCH)

#
# python_cryptography
#
PYTHON_CRYPTOGRAPHY_VER = 0.8.1

$(ARCHIVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/c/cryptography/cryptography-$(PYTHON_PYOPENSSL_VER).tar.gz

$(D)/python_cryptography: $(D)/bootstrap $(D)/libffi $(D)/python $(D)/python_setuptools $(D)/python_pyopenssl $(D)/python_six $(D)/python_pycparser $(ARCHIVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER)
	$(UNTAR)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER).tar.gz
	set -e; cd $(BUILD_TMP)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER)
	$(TOUCH)

#
# python_pyopenssl
#
PYTHON_PYOPENSSL_VER = 0.13.1
PYTHON_PYOPENSSL_PATCH = python-pyopenssl-$(PYTHON_PYOPENSSL_VER).patch

$(ARCHIVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-$(PYTHON_PYOPENSSL_VER).tar.gz

$(D)/python_pyopenssl: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER)
	$(UNTAR)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER); \
		$(call post_patch,$(PYTHON_PYOPENSSL_PATCH)); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER)
	$(TOUCH)

#
# python_service_identity
#
PYTHON_SERVICE_IDENTITY_VER = 16.0.0
PYTHON_SERVICE_IDENTITY_PATCH =

$(ARCHIVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/s/service_identity/service_identity-$(PYTHON_SERVICE_IDENTITY_VER).tar.gz

$(D)/python_service_identity: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_attr $(D)/python_attrs $(D)/python_pyasn1 $(ARCHIVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER)
	$(UNTAR)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER).tar.gz
	set -e; cd $(BUILD_TMP)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER); \
		$(call post_patch,$(PYTHON_SERVICE_IDENTITY_PATCH)); \
		$(PYTHON_INSTALL)
	$(REMOVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER)
	$(TOUCH)

#
# python_attr
#
PYTHON_ATTR_VER = 0.1.0
PYTHON_ATTR_PATCH =

$(ARCHIVE)/attr-$(PYTHON_ATTR_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/a/attr/attr-$(PYTHON_ATTR_VER).tar.gz

$(D)/python_attr: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/attr-$(PYTHON_ATTR_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/attr-$(PYTHON_ATTR_VER)
	$(UNTAR)/attr-$(PYTHON_ATTR_VER).tar.gz
	set -e; cd $(BUILD_TMP)/attr-$(PYTHON_ATTR_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/attr-$(PYTHON_ATTR_VER)
	$(TOUCH)

#
# python_attrs
#
PYTHON_ATTRS_VER = 16.3.0
PYTHON_ATTRS_PARCH =

$(ARCHIVE)/attrs-$(PYTHON_ATTRS_VER).tar.gz:
	$(WGET) https://pypi.io/packages/source/a/attrs/attrs-$(PYTHON_ATTRS_VER).tar.gz

$(D)/python_attrs: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/attrs-$(PYTHON_ATTRS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/attrs-$(PYTHON_ATTRS_VER)
	$(UNTAR)/attrs-$(PYTHON_ATTRS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/attrs-$(PYTHON_ATTRS_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/attrs-$(PYTHON_ATTRS_VER)
	$(TOUCH)

#
# python_elementtree
#
PYTHON_ELEMENTTREE_VER = 1.2.6-20050316

$(ARCHIVE)/elementtree-$(PYTHON_ELEMENTTREE_VER).tar.gz:
	$(WGET) http://effbot.org/media/downloads/elementtree-$(PYTHON_ELEMENTTREE_VER).tar.gz

$(D)/python_elementtree: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/elementtree-$(PYTHON_ELEMENTTREE_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/elementtree-$(PYTHON_ELEMENTTREE_VER)
	$(UNTAR)/elementtree-$(PYTHON_ELEMENTTREE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/elementtree-$(PYTHON_ELEMENTTREE_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/elementtree-$(PYTHON_ELEMENTTREE_VER)
	$(TOUCH)

#
# python_wifi
#
PYTHON_WIFI_VER = 0.5.0

$(ARCHIVE)/pythonwifi-$(PYTHON_WIFI_VER).tar.bz2:
	$(WGET) https://git.tuxfamily.org/pythonwifi/pythonwifi.git/snapshot/pythonwifi-$(PYTHON_WIFI_VER).tar.bz2

$(D)/python_wifi: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/pythonwifi-$(PYTHON_WIFI_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/pythonwifi-$(PYTHON_WIFI_VER)
	$(UNTAR)/pythonwifi-$(PYTHON_WIFI_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/pythonwifi-$(PYTHON_WIFI_VER); \
		$(PYTHON_INSTALL) --install-data=/.remove
	$(REMOVE)/pythonwifi-$(PYTHON_WIFI_VER)
	$(TOUCH)

#
# python_cheetah
#
PYTHON_CHEETAH_VER = 2.4.4

$(ARCHIVE)/Cheetah-$(PYTHON_CHEETAH_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/C/Cheetah/Cheetah-$(PYTHON_CHEETAH_VER).tar.gz

$(D)/python_cheetah: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/Cheetah-$(PYTHON_CHEETAH_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/Cheetah-$(PYTHON_CHEETAH_VER)
	$(UNTAR)/Cheetah-$(PYTHON_CHEETAH_VER).tar.gz
	set -e; cd $(BUILD_TMP)/Cheetah-$(PYTHON_CHEETAH_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Cheetah-$(PYTHON_CHEETAH_VER)
	$(TOUCH)

#
# python_mechanize
#
PYTHON_MECHANIZE_VER = 0.2.5

$(ARCHIVE)/mechanize-$(PYTHON_MECHANIZE_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/m/mechanize/mechanize-$(PYTHON_MECHANIZE_VER).tar.gz

$(D)/python_mechanize: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/mechanize-$(PYTHON_MECHANIZE_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/mechanize-$(PYTHON_MECHANIZE_VER)
	$(UNTAR)/mechanize-$(PYTHON_MECHANIZE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/mechanize-$(PYTHON_MECHANIZE_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/mechanize-$(PYTHON_MECHANIZE_VER)
	$(TOUCH)

#
# python_gdata
#
PYTHON_GDATA_VER = 2.0.18

$(ARCHIVE)/gdata-$(PYTHON_GDATA_VER).tar.gz:
	$(WGET) https://gdata-python-client.googlecode.com/files/gdata-$(PYTHON_GDATA_VER).tar.gz

$(D)/python_gdata: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/gdata-$(PYTHON_GDATA_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/gdata-$(PYTHON_GDATA_VER)
	$(UNTAR)/gdata-$(PYTHON_GDATA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/gdata-$(PYTHON_GDATA_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/gdata-$(PYTHON_GDATA_VER)
	$(TOUCH)

#
# python_zope_interface
#
PYTHON_ZOPE_INTERFACE_VER = 4.1.1

$(ARCHIVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER).tar.gz:
	$(WGET) http://pypi.python.org/packages/source/z/zope.interface/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER).tar.gz

$(D)/python_zope_interface: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(UNTAR)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(TOUCH)

#
# python_requests
#
PYTHON_REQUESTS_VER = 2.7.0

$(ARCHIVE)/requests-$(PYTHON_REQUESTS_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/r/requests/requests-$(PYTHON_REQUESTS_VER).tar.gz

$(D)/python_requests: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/requests-$(PYTHON_REQUESTS_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/requests-$(PYTHON_REQUESTS_VER)
	$(UNTAR)/requests-$(PYTHON_REQUESTS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/requests-$(PYTHON_REQUESTS_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/requests-$(PYTHON_REQUESTS_VER)
	$(TOUCH)

#
# python_futures
#
PYTHON_FUTURES_VER = 2.1.6

$(ARCHIVE)/futures-$(PYTHON_FUTURES_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/f/futures/futures-$(PYTHON_FUTURES_VER).tar.gz

$(D)/python_futures: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/futures-$(PYTHON_FUTURES_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/futures-$(PYTHON_FUTURES_VER)
	$(UNTAR)/futures-$(PYTHON_FUTURES_VER).tar.gz
	set -e; cd $(BUILD_TMP)/futures-$(PYTHON_FUTURES_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/futures-$(PYTHON_FUTURES_VER)
	$(TOUCH)

#
# python_singledispatch
#
PYTHON_SINGLEDISPATCH_VER = 3.4.0.3

$(ARCHIVE)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER).tar.gz:
	$(WGET) https://pypi.python.org/packages/source/s/singledispatch/singledispatch-$(PYTHON_SINGLEDISPATCH_VER).tar.gz

$(D)/python_singledispatch: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER).tar.gz
	$(START_BUILD)
	$(REMOVE)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER)
	$(UNTAR)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER).tar.gz
	set -e; cd $(BUILD_TMP)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER); \
		$(PYTHON_INSTALL)
	$(REMOVE)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER)
	$(TOUCH)

#
# python_livestreamer
#
$(D)/python_livestreamer: $(D)/bootstrap $(D)/python $(D)/python_setuptools
	$(START_BUILD)
	$(REMOVE)/livestreamer
	set -e; if [ -d $(ARCHIVE)/livestreamer.git ]; \
		then cd $(ARCHIVE)/livestreamer.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/chrippa/livestreamer.git livestreamer.git; \
		fi
	cp -ra $(ARCHIVE)/livestreamer.git $(BUILD_TMP)/livestreamer
	set -e; cd $(BUILD_TMP)/livestreamer; \
		$(PYTHON_INSTALL)
	$(REMOVE)/livestreamer
	$(TOUCH)

#
# python_livestreamersrv
#
$(D)/python_livestreamersrv: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_livestreamer
	$(START_BUILD)
	$(REMOVE)/livestreamersrv
	set -e; if [ -d $(ARCHIVE)/livestreamersrv.git ]; \
		then cd $(ARCHIVE)/livestreamersrv.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/athoik/livestreamersrv.git livestreamersrv.git; \
		fi
	cp -ra $(ARCHIVE)/livestreamersrv.git $(BUILD_TMP)/livestreamersrv
	set -e; cd $(BUILD_TMP)/livestreamersrv; \
		cp -rd livestreamersrv $(TARGETPREFIX)/usr/sbin; \
		cp -rd offline.mp4 $(TARGETPREFIX)/usr/share
	$(REMOVE)/livestreamersrv
	$(TOUCH)

PYTHON_DEPS  = $(D)/host_python $(D)/python $(D)/python_elementtree $(D)/python_lxml $(D)/python_zope_interface $(D)/python_pyopenssl $(D)/python_twisted
PYTHON_DEPS += $(D)/python_wifi $(D)/python_imaging $(D)/python_pyusb $(D)/python_pycrypto $(D)/python_pyasn1 $(D)/python_mechanize
PYTHON_DEPS += $(D)/python_six $(D)/python_requests $(D)/python_futures $(D)/python_singledispatch
PYTHON_DEPS += $(D)/python_livestreamer $(D)/python_livestreamersrv

python-all: $(PYTHON_DEPS)

PHONY += python-all

