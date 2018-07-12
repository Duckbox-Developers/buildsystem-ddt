#
# python helpers
#
PYTHON_DIR         = usr/lib/python$(PYTHON_VER_MAJOR)
PYTHON_INCLUDE_DIR = usr/include/python$(PYTHON_VER_MAJOR)

PYTHON_BUILD = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)" \
	$(HOST_DIR)/bin/python ./setup.py -q build --executable=/usr/bin/python

PYTHON_INSTALL = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGET_DIR)/$(PYTHON_INCLUDE_DIR)" \
	$(HOST_DIR)/bin/python ./setup.py -q install --root=$(TARGET_DIR) --prefix=/usr

#
# host_python
#
PYTHON_VER_MAJOR = 2.7
PYTHON_VER_MINOR = 13
PYTHON_VER = $(PYTHON_VER_MAJOR).$(PYTHON_VER_MINOR)
PYTHON_SOURCE = Python-$(PYTHON_VER).tar.xz
HOST_PYTHON_PATCH = python-$(PYTHON_VER).patch

$(ARCHIVE)/$(PYTHON_SOURCE):
	$(WGET) https://www.python.org/ftp/python/$(PYTHON_VER)/$(PYTHON_SOURCE)

$(D)/host_python: $(ARCHIVE)/$(PYTHON_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/$(PYTHON_SOURCE)
	set -e; cd $(BUILD_TMP)/Python-$(PYTHON_VER); \
		$(call apply_patches,$(HOST_PYTHON_PATCH)); \
		autoconf; \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure $(SILENT_OPT) \
			--without-cxx-main \
			--with-threads \
		; \
		$(MAKE) python Parser/pgen; \
		mv python ./hostpython; \
		mv Parser/pgen ./hostpgen; \
		\
		$(MAKE) distclean; \
		./configure $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--sysconfdir=$(HOST_DIR)/etc \
			--without-cxx-main \
			--with-threads \
		; \
		$(MAKE) all install; \
		cp ./hostpgen $(HOST_DIR)/bin/pgen
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

#
# python
#
PYTHON_PATCH  = python-$(PYTHON_VER).patch
PYTHON_PATCH += python-$(PYTHON_VER)-xcompile.patch
PYTHON_PATCH += python-$(PYTHON_VER)-revert_use_of_sysconfigdata.patch
PYTHON_PATCH += python-$(PYTHON_VER)-pgettext.patch

$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/ncurses $(D)/zlib $(D)/openssl $(D)/libffi $(D)/bzip2 $(D)/readline $(D)/sqlite $(ARCHIVE)/$(PYTHON_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/$(PYTHON_SOURCE)
	set -e; cd $(BUILD_TMP)/Python-$(PYTHON_VER); \
		$(call apply_patches,$(PYTHON_PATCH)); \
		CONFIG_SITE= \
		$(BUILDENV) \
		autoreconf -fiv Modules/_ctypes/libffi; \
		autoconf $(SILENT_OPT); \
		./configure $(SILENT_OPT) \
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
			ac_cv_have_long_long_format=yes \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) \
		; \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON_MODULES_INCLUDE="$(TARGET_DIR)/usr/include" \
			PYTHON_MODULES_LIB="$(TARGET_DIR)/usr/lib" \
			PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="$(TARGET_DIR)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(TARGET) \
			MACHDEP=linux2 \
			HOSTARCH=$(TARGET) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(TARGET)-gcc" \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) \
			HOSTPGEN=$(HOST_DIR)/bin/pgen \
			all DESTDIR=$(TARGET_DIR) \
		; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf ../../libpython$(PYTHON_VER_MAJOR).so.1.0 $(TARGET_DIR)/$(PYTHON_DIR)/config/libpython$(PYTHON_VER_MAJOR).so; \
	ln -sf $(TARGET_DIR)/$(PYTHON_INCLUDE_DIR) $(TARGET_DIR)/usr/include/python
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/python-2.7.pc
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

#
# python_setuptools
#
PYTHON_SETUPTOOLS_VER = 5.2
PYTHON_SETUPTOOLS_SOURCE = setuptools-$(PYTHON_SETUPTOOLS_VER).tar.gz

$(ARCHIVE)/$(PYTHON_SETUPTOOLS_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/s/setuptools/$(PYTHON_SETUPTOOLS_SOURCE)

$(D)/python_setuptools: $(D)/bootstrap $(D)/python $(ARCHIVE)/$(PYTHON_SETUPTOOLS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(UNTAR)/$(PYTHON_SETUPTOOLS_SOURCE)
	set -e; cd $(BUILD_TMP)/setuptools-$(PYTHON_SETUPTOOLS_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/setuptools-$(PYTHON_SETUPTOOLS_VER)
	$(TOUCH)

#
# libxmlccwrap
#
LIBXMLCCWRAP_VER = 0.0.12
LIBXMLCCWRAP_SOURCE = libxmlccwrap-$(LIBXMLCCWRAP_VER).tar.gz

$(ARCHIVE)/$(LIBXMLCCWRAP_SOURCE):
	$(WGET) http://www.ant.uni-bremen.de/whomes/rinas/libxmlccwrap/download/$(LIBXMLCCWRAP_SOURCE)

$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2 $(D)/libxslt $(ARCHIVE)/$(LIBXMLCCWRAP_SOURCE)
	$(START_BUILD)
	$(REMOVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER)
	$(UNTAR)/$(LIBXMLCCWRAP_SOURCE)
	set -e; cd $(BUILD_TMP)/libxmlccwrap-$(LIBXMLCCWRAP_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libxmlccwrap.la
	$(REMOVE)/libxmlccwrap-$(LIBXMLCCWRAP_VER)
	$(TOUCH)

#
# python_lxml
#
PYTHON_LXML_MAJOR = 2.2
PYTHON_LXML_MINOR = 8
PYTHON_LXML_VER = $(PYTHON_LXML_MAJOR).$(PYTHON_LXML_MINOR)
PYTHON_LXML_SOURCE = lxml-$(PYTHON_LXML_VER).tgz

$(ARCHIVE)/$(PYTHON_LXML_SOURCE):
	$(WGET) http://launchpad.net/lxml/$(PYTHON_LXML_MAJOR)/$(PYTHON_LXML_VER)/+download/$(PYTHON_LXML_SOURCE)

$(D)/python_lxml: $(D)/bootstrap $(D)/python $(D)/libxslt $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_LXML_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lxml-$(PYTHON_LXML_VER)
	$(UNTAR)/$(PYTHON_LXML_SOURCE)
	set -e; cd $(BUILD_TMP)/lxml-$(PYTHON_LXML_VER); \
		$(PYTHON_BUILD) \
			--with-xml2-config=$(HOST_DIR)/bin/xml2-config \
			--with-xslt-config=$(HOST_DIR)/bin/xslt-config; \
		$(PYTHON_INSTALL)
	$(REMOVE)/lxml-$(PYTHON_LXML_VER)
	$(TOUCH)

#
# python_twisted
#
PYTHON_TWISTED_VER = 16.4.0
PYTHON_TWISTED_SOURCE = Twisted-$(PYTHON_TWISTED_VER).tar.bz2

$(ARCHIVE)/$(PYTHON_TWISTED_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/T/Twisted/$(PYTHON_TWISTED_SOURCE)

$(D)/python_twisted: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_zope_interface $(D)/python_pyopenssl $(D)/python_service_identity $(ARCHIVE)/$(PYTHON_TWISTED_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(UNTAR)/$(PYTHON_TWISTED_SOURCE)
	set -e; cd $(BUILD_TMP)/Twisted-$(PYTHON_TWISTED_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Twisted-$(PYTHON_TWISTED_VER)
	$(TOUCH)

#
# python_imaging
#
PYTHON_IMAGING_VER = 1.1.7
PYTHON_IMAGING_SOURCE = Imaging-$(PYTHON_IMAGING_VER).tar.gz
PYTHON_IMAGING_PATCH = python-imaging-$(PYTHON_IMAGING_VER).patch

$(ARCHIVE)/$(PYTHON_IMAGING_SOURCE):
	$(WGET) http://effbot.org/downloads/$(PYTHON_IMAGING_SOURCE)

$(D)/python_imaging: $(D)/bootstrap $(D)/libjpeg $(D)/freetype $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_IMAGING_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Imaging-$(PYTHON_IMAGING_VER)
	$(UNTAR)/$(PYTHON_IMAGING_SOURCE)
	set -e; cd $(BUILD_TMP)/Imaging-$(PYTHON_IMAGING_VER); \
		$(call apply_patches,$(PYTHON_IMAGING_PATCH)); \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${TARGET_DIR}/usr\")|" "setup.py"; \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Imaging-$(PYTHON_IMAGING_VER)
	$(TOUCH)

#
# python_pycrypto
#
PYTHON_PYCRYPTO_VER = 2.6.1
PYTHON_PYCRYPTO_SOURCE = pycrypto-$(PYTHON_PYCRYPTO_VER).tar.gz
PYTHON_PYCRYPTO_PATCH = python-pycrypto-$(PYTHON_PYCRYPTO_VER).patch

$(ARCHIVE)/$(PYTHON_PYCRYPTO_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pycrypto/$(PYTHON_PYCRYPTO_SOURCE)

$(D)/python_pycrypto: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_PYCRYPTO_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pycrypto-$(PYTHON_PYCRYPTO_VER)
	$(UNTAR)/$(PYTHON_PYCRYPTO_SOURCE)
	set -e; cd $(BUILD_TMP)/pycrypto-$(PYTHON_PYCRYPTO_VER); \
		$(call apply_patches,$(PYTHON_PYCRYPTO_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pycrypto-$(PYTHON_PYCRYPTO_VER)
	$(TOUCH)

#
# python_pyusb
#
PYTHON_PYUSB_VER = 1.0.0a3
PYTHON_PYUSB_SOURCE = pyusb-$(PYTHON_PYUSB_VER).tar.gz

$(ARCHIVE)/$(PYTHON_PYUSB_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pyusb/$(PYTHON_PYUSB_SOURCE)

$(D)/python_pyusb: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_PYUSB_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pyusb-$(PYTHON_PYUSB_VER)
	$(UNTAR)/$(PYTHON_PYUSB_SOURCE)
	set -e; cd $(BUILD_TMP)/pyusb-$(PYTHON_PYUSB_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyusb-$(PYTHON_PYUSB_VER)
	$(TOUCH)

#
# python_ipaddress
#
PYTHON_IPADDRESS_VER = 1.0.18
PYTHON_IPADDRESS_SOURCE = ipaddress-$(PYTHON_IPADDRESS_VER).tar.gz

$(ARCHIVE)/$(PYTHON_IPADDRESS_SOURCE):
	$(WGET) https://distfiles.macports.org/py-ipaddress/$(PYTHON_IPADDRESS_SOURCE)

$(D)/python_ipaddress: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_IPADDRESS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/ipaddress-$(PYTHON_IPADDRESS_VER)
	$(UNTAR)/$(PYTHON_IPADDRESS_SOURCE)
	set -e; cd $(BUILD_TMP)/ipaddress-$(PYTHON_IPADDRESS_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/ipaddress-$(PYTHON_IPADDRESS_VER)
	$(TOUCH)

#
# python_six
#
PYTHON_SIX_VER = 1.9.0
PYTHON_SIX_SOURCE = six-$(PYTHON_SIX_VER).tar.gz

$(ARCHIVE)/$(PYTHON_SIX_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/s/six/$(PYTHON_SIX_SOURCE)

$(D)/python_six: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_SIX_SOURCE)
	$(START_BUILD)
	$(REMOVE)/six-$(PYTHON_SIX_VER)
	$(UNTAR)/$(PYTHON_SIX_SOURCE)
	set -e; cd $(BUILD_TMP)/six-$(PYTHON_SIX_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/six-$(PYTHON_SIX_VER)
	$(TOUCH)

#
# python_cffi
#
PYTHON_CFFI_VER = 1.2.1
PYTHON_CFFI_SOURCE = cffi-$(PYTHON_CFFI_VER).tar.gz

$(ARCHIVE)/$(PYTHON_CFFI_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/c/cffi/$(PYTHON_CFFI_SOURCE)

$(D)/python_cffi: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_CFFI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/cffi-$(PYTHON_CFFI_VER)
	$(UNTAR)/$(PYTHON_CFFI_SOURCE)
	set -e; cd $(BUILD_TMP)/cffi-$(PYTHON_CFFI_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/cffi-$(PYTHON_CFFI_VER)
	$(TOUCH)

#
# python_enum34
#
PYTHON_ENUM34_VER = 1.0.4
PYTHON_ENUM34_SOURCE = enum34-$(PYTHON_ENUM34_VER).tar.gz

$(ARCHIVE)/$(PYTHON_ENUM34_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/e/enum34/$(PYTHON_ENUM34_SOURCE)

$(D)/python_enum34: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_ENUM34_SOURCE)
	$(START_BUILD)
	$(REMOVE)/enum34-$(PYTHON_ENUM34_VER)
	$(UNTAR)/$(PYTHON_ENUM34_SOURCE)
	set -e; cd $(BUILD_TMP)/enum34-$(PYTHON_ENUM34_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/enum34-$(PYTHON_ENUM34_VER)
	$(TOUCH)

#
# python_pyasn1_modules
#
PYTHON_PYASN1_MODULES_VER = 0.0.7
PYTHON_PYASN1_MODULES_SOURCE = pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER).tar.gz

$(ARCHIVE)/$(PYTHON_PYASN1_MODULES_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pyasn1-modules/$(PYTHON_PYASN1_MODULES_SOURCE)

$(D)/python_pyasn1_modules: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_PYASN1_MODULES_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER)
	$(UNTAR)/$(PYTHON_PYASN1_MODULES_SOURCE)
	set -e; cd $(BUILD_TMP)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyasn1-modules-$(PYTHON_PYASN1_MODULES_VER)
	$(TOUCH)

#
# python_pyasn1
#
PYTHON_PYASN1_VER = 0.1.8
PYTHON_PYASN1_SOURCE = pyasn1-$(PYTHON_PYASN1_VER).tar.gz

$(ARCHIVE)/$(PYTHON_PYASN1_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pyasn1/$(PYTHON_PYASN1_SOURCE)

$(D)/python_pyasn1: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1_modules $(ARCHIVE)/$(PYTHON_PYASN1_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pyasn1-$(PYTHON_PYASN1_VER)
	$(UNTAR)/$(PYTHON_PYASN1_SOURCE)
	set -e; cd $(BUILD_TMP)/pyasn1-$(PYTHON_PYASN1_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyasn1-$(PYTHON_PYASN1_VER)
	$(TOUCH)

#
# python_pycparser
#
PYTHON_PYCPARSER_VER = 2.14
PYTHON_PYCPARSER_SOURCE = pycparser-$(PYTHON_PYCPARSER_VER).tar.gz

$(ARCHIVE)/$(PYTHON_PYCPARSER_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pycparser/$(PYTHON_PYCPARSER_SOURCE)

$(D)/python_pycparser: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1 $(ARCHIVE)/$(PYTHON_PYCPARSER_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pycparser-$(PYTHON_PYCPARSER_VER)
	$(UNTAR)/$(PYTHON_PYCPARSER_SOURCE)
	set -e; cd $(BUILD_TMP)/pycparser-$(PYTHON_PYCPARSER_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pycparser-$(PYTHON_PYCPARSER_VER)
	$(TOUCH)

#
# python_cryptography
#
PYTHON_CRYPTOGRAPHY_VER = 0.8.1
PYTHON_CRYPTOGRAPHY_SOURCE = cryptography-$(PYTHON_CRYPTOGRAPHY_VER).tar.gz

$(ARCHIVE)/$(PYTHON_CRYPTOGRAPHY_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/c/cryptography/$(PYTHON_CRYPTOGRAPHY_SOURCE)

$(D)/python_cryptography: $(D)/bootstrap $(D)/libffi $(D)/python $(D)/python_setuptools $(D)/python_pyopenssl $(D)/python_six $(D)/python_pycparser $(ARCHIVE)/$(PYTHON_CRYPTOGRAPHY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER)
	$(UNTAR)/$(PYTHON_CRYPTOGRAPHY_SOURCE)
	set -e; cd $(BUILD_TMP)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/cryptography-$(PYTHON_CRYPTOGRAPHY_VER)
	$(TOUCH)

#
# python_pyopenssl
#
PYTHON_PYOPENSSL_VER = 0.13.1
PYTHON_PYOPENSSL_SOURCE = pyOpenSSL-$(PYTHON_PYOPENSSL_VER).tar.gz
PYTHON_PYOPENSSL_PATCH = python-pyopenssl-$(PYTHON_PYOPENSSL_VER).patch

$(ARCHIVE)/$(PYTHON_PYOPENSSL_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/p/pyOpenSSL/$(PYTHON_PYOPENSSL_SOURCE)

$(D)/python_pyopenssl: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_PYOPENSSL_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER)
	$(UNTAR)/$(PYTHON_PYOPENSSL_SOURCE)
	set -e; cd $(BUILD_TMP)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER); \
		$(call apply_patches,$(PYTHON_PYOPENSSL_PATCH)); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/pyOpenSSL-$(PYTHON_PYOPENSSL_VER)
	$(TOUCH)

#
# python_service_identity
#
PYTHON_SERVICE_IDENTITY_VER = 16.0.0
PYTHON_SERVICE_IDENTITY_SOURCE = service_identity-$(PYTHON_SERVICE_IDENTITY_VER).tar.gz
PYTHON_SERVICE_IDENTITY_PATCH =

$(ARCHIVE)/$(PYTHON_SERVICE_IDENTITY_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/s/service_identity/$(PYTHON_SERVICE_IDENTITY_SOURCE)

$(D)/python_service_identity: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_attr $(D)/python_attrs $(D)/python_pyasn1 $(ARCHIVE)/$(PYTHON_SERVICE_IDENTITY_SOURCE)
	$(START_BUILD)
	$(REMOVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER)
	$(UNTAR)/$(PYTHON_SERVICE_IDENTITY_SOURCE)
	set -e; cd $(BUILD_TMP)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER); \
		$(call apply_patches,$(PYTHON_SERVICE_IDENTITY_PATCH)); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/service_identity-$(PYTHON_SERVICE_IDENTITY_VER)
	$(TOUCH)

#
# python_attr
#
PYTHON_ATTR_VER = 0.1.0
PYTHON_ATTR_SOURCE = attr-$(PYTHON_ATTR_VER).tar.gz
PYTHON_ATTR_PATCH =

$(ARCHIVE)/$(PYTHON_ATTR_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/a/attr/$(PYTHON_ATTR_SOURCE)

$(D)/python_attr: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_ATTR_SOURCE)
	$(START_BUILD)
	$(REMOVE)/attr-$(PYTHON_ATTR_VER)
	$(UNTAR)/$(PYTHON_ATTR_SOURCE)
	set -e; cd $(BUILD_TMP)/attr-$(PYTHON_ATTR_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/attr-$(PYTHON_ATTR_VER)
	$(TOUCH)

#
# python_attrs
#
PYTHON_ATTRS_VER = 16.3.0
PYTHON_ATTRS_SOURCE = attrs-$(PYTHON_ATTRS_VER).tar.gz
PYTHON_ATTRS_PARCH =

$(ARCHIVE)/$(PYTHON_ATTRS_SOURCE):
	$(WGET) https://pypi.io/packages/source/a/attrs/$(PYTHON_ATTRS_SOURCE)

$(D)/python_attrs: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_ATTRS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/attrs-$(PYTHON_ATTRS_VER)
	$(UNTAR)/$(PYTHON_ATTRS_SOURCE)
	set -e; cd $(BUILD_TMP)/attrs-$(PYTHON_ATTRS_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/attrs-$(PYTHON_ATTRS_VER)
	$(TOUCH)

#
# python_elementtree
#
PYTHON_ELEMENTTREE_VER = 1.2.6-20050316
PYTHON_ELEMENTTREE_SOURCE = elementtree-$(PYTHON_ELEMENTTREE_VER).tar.gz

$(ARCHIVE)/$(PYTHON_ELEMENTTREE_SOURCE):
	$(WGET) http://effbot.org/media/downloads/$(PYTHON_ELEMENTTREE_SOURCE)

$(D)/python_elementtree: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_ELEMENTTREE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/elementtree-$(PYTHON_ELEMENTTREE_VER)
	$(UNTAR)/$(PYTHON_ELEMENTTREE_SOURCE)
	set -e; cd $(BUILD_TMP)/elementtree-$(PYTHON_ELEMENTTREE_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/elementtree-$(PYTHON_ELEMENTTREE_VER)
	$(TOUCH)

#
# python_wifi
#
PYTHON_WIFI_VER = 0.5.0
PYTHON_WIFI_SOURCE = pythonwifi-$(PYTHON_WIFI_VER).tar.bz2

$(ARCHIVE)/$(PYTHON_WIFI_SOURCE):
	$(WGET) https://git.tuxfamily.org/pythonwifi/pythonwifi.git/snapshot/$(PYTHON_WIFI_SOURCE)

$(D)/python_wifi: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_WIFI_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pythonwifi-$(PYTHON_WIFI_VER)
	$(UNTAR)/$(PYTHON_WIFI_SOURCE)
	set -e; cd $(BUILD_TMP)/pythonwifi-$(PYTHON_WIFI_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL) --install-data=/.remove
	$(REMOVE)/pythonwifi-$(PYTHON_WIFI_VER)
	$(TOUCH)

#
# python_cheetah
#
PYTHON_CHEETAH_VER = 2.4.4
PYTHON_CHEETAH_SOURCE = Cheetah-$(PYTHON_CHEETAH_VER).tar.gz

$(ARCHIVE)/$(PYTHON_CHEETAH_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/C/Cheetah/$(PYTHON_CHEETAH_SOURCE)

$(D)/python_cheetah: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_CHEETAH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Cheetah-$(PYTHON_CHEETAH_VER)
	$(UNTAR)/$(PYTHON_CHEETAH_SOURCE)
	set -e; cd $(BUILD_TMP)/Cheetah-$(PYTHON_CHEETAH_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/Cheetah-$(PYTHON_CHEETAH_VER)
	$(TOUCH)

#
# python_mechanize
#
PYTHON_MECHANIZE_VER = 0.2.5
PYTHON_MECHANIZE_SOURCE = mechanize-$(PYTHON_MECHANIZE_VER).tar.gz

$(ARCHIVE)/$(PYTHON_MECHANIZE_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/m/mechanize/$(PYTHON_MECHANIZE_SOURCE)

$(D)/python_mechanize: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_MECHANIZE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mechanize-$(PYTHON_MECHANIZE_VER)
	$(UNTAR)/$(PYTHON_MECHANIZE_SOURCE)
	set -e; cd $(BUILD_TMP)/mechanize-$(PYTHON_MECHANIZE_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/mechanize-$(PYTHON_MECHANIZE_VER)
	$(TOUCH)

#
# python_gdata
#
PYTHON_GDATA_VER = 2.0.18
PYTHON_GDATA_SOURCE = gdata-$(PYTHON_GDATA_VER).tar.gz

$(ARCHIVE)/$(PYTHON_GDATA_SOURCE):
	$(WGET) https://gdata-python-client.googlecode.com/files/$(PYTHON_GDATA_SOURCE)

$(D)/python_gdata: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_GDATA_SOURCE)
	$(START_BUILD)
	$(REMOVE)/gdata-$(PYTHON_GDATA_VER)
	$(UNTAR)/$(PYTHON_GDATA_SOURCE)
	set -e; cd $(BUILD_TMP)/gdata-$(PYTHON_GDATA_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/gdata-$(PYTHON_GDATA_VER)
	$(TOUCH)

#
# python_zope_interface
#
PYTHON_ZOPE_INTERFACE_VER = 4.1.1
PYTHON_ZOPE_INTERFACE_SOURCE = zope.interface-$(PYTHON_ZOPE_INTERFACE_VER).tar.gz

$(ARCHIVE)/$(PYTHON_ZOPE_INTERFACE_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/z/zope.interface/$(PYTHON_ZOPE_INTERFACE_SOURCE)

$(D)/python_zope_interface: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_ZOPE_INTERFACE_SOURCE)
	$(START_BUILD)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(UNTAR)/$(PYTHON_ZOPE_INTERFACE_SOURCE)
	set -e; cd $(BUILD_TMP)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/zope.interface-$(PYTHON_ZOPE_INTERFACE_VER)
	$(TOUCH)

#
# python_requests
#
PYTHON_REQUESTS_VER = 2.7.0
PYTHON_REQUESTS_SOURCE = requests-$(PYTHON_REQUESTS_VER).tar.gz

$(ARCHIVE)/$(PYTHON_REQUESTS_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/r/requests/$(PYTHON_REQUESTS_SOURCE)

$(D)/python_requests: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_REQUESTS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/requests-$(PYTHON_REQUESTS_VER)
	$(UNTAR)/$(PYTHON_REQUESTS_SOURCE)
	set -e; cd $(BUILD_TMP)/requests-$(PYTHON_REQUESTS_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/requests-$(PYTHON_REQUESTS_VER)
	$(TOUCH)

#
# python_futures
#
PYTHON_FUTURES_VER = 2.1.6
PYTHON_FUTURES_SOURCE = futures-$(PYTHON_FUTURES_VER).tar.gz

$(ARCHIVE)/$(PYTHON_FUTURES_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/f/futures/$(PYTHON_FUTURES_SOURCE)

$(D)/python_futures: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_FUTURES_SOURCE)
	$(START_BUILD)
	$(REMOVE)/futures-$(PYTHON_FUTURES_VER)
	$(UNTAR)/$(PYTHON_FUTURES_SOURCE)
	set -e; cd $(BUILD_TMP)/futures-$(PYTHON_FUTURES_VER); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/futures-$(PYTHON_FUTURES_VER)
	$(TOUCH)

#
# python_singledispatch
#
PYTHON_SINGLEDISPATCH_VER = 3.4.0.3
PYTHON_SINGLEDISPATCH_SOURCE = singledispatch-$(PYTHON_SINGLEDISPATCH_VER).tar.gz

$(ARCHIVE)/$(PYTHON_SINGLEDISPATCH_SOURCE):
	$(WGET) https://pypi.python.org/packages/source/s/singledispatch/$(PYTHON_SINGLEDISPATCH_SOURCE)

$(D)/python_singledispatch: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(ARCHIVE)/$(PYTHON_SINGLEDISPATCH_SOURCE)
	$(START_BUILD)
	$(REMOVE)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER)
	$(UNTAR)/$(PYTHON_SINGLEDISPATCH_SOURCE)
	set -e; cd $(BUILD_TMP)/singledispatch-$(PYTHON_SINGLEDISPATCH_VER); \
		$(PYTHON_BUILD); \
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
		$(PYTHON_BUILD); \
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
		cp -rd livestreamersrv $(TARGET_DIR)/usr/sbin; \
		cp -rd offline.mp4 $(TARGET_DIR)/usr/share
	$(REMOVE)/livestreamersrv
	$(TOUCH)

PYTHON_DEPS  = $(D)/host_python
PYTHON_DEPS += $(D)/python
PYTHON_DEPS += $(D)/python_elementtree
PYTHON_DEPS += $(D)/python_lxml
PYTHON_DEPS += $(D)/python_zope_interface
PYTHON_DEPS += $(D)/python_pyopenssl
PYTHON_DEPS += $(D)/python_twisted
PYTHON_DEPS += $(D)/python_wifi
PYTHON_DEPS += $(D)/python_imaging
PYTHON_DEPS += $(D)/python_pyusb
PYTHON_DEPS += $(D)/python_pycrypto
PYTHON_DEPS += $(D)/python_pyasn1
PYTHON_DEPS += $(D)/python_mechanize
PYTHON_DEPS += $(D)/python_six
PYTHON_DEPS += $(D)/python_requests
PYTHON_DEPS += $(D)/python_futures
PYTHON_DEPS += $(D)/python_singledispatch
PYTHON_DEPS += $(D)/python_ipaddress
PYTHON_DEPS += $(D)/python_livestreamer
PYTHON_DEPS += $(D)/python_livestreamersrv

python-all: $(PYTHON_DEPS)

PHONY += python-all
