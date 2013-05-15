$(call PKG_INIT_LIB, 1.5.2)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_LIB_VERSION:=0.5.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=89c1348aa79e898d7c34a6206311c9c2
$(PKG)_SITE:=@APACHE/apr

$(PKG)_MAJOR_LIBNAME=libaprutil-$(APR_UTIL_MAJOR_VERSION)
$(PKG)_LIBNAME=$($(PKG)_MAJOR_LIBNAME).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)
$(PKG)_INCLUDE_DIR:=/usr/include/apr-util-$(APR_UTIL_MAJOR_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libaprutil_WITH_LIBDB

$(PKG)_DEPENDS_ON := apr
ifeq ($(strip $(FREETZ_LIB_libaprutil_WITH_LIBDB)),y)
$(PKG)_DEPENDS_ON += db
endif
$(PKG)_DEPENDS_ON += expat
$(PKG)_DEPENDS_ON += sqlite

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_file_dbd_apr_dbd_mysql_c=no
$(PKG)_CONFIGURE_ENV += APR_BUILD_DIR="$(STAGING_DIR)/usr/share/apr-$(APR_UTIL_MAJOR_VERSION)/build"

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(STAGING_DIR)/usr/bin/apr-$(APR_UTIL_MAJOR_VERSION)-config"
$(PKG)_CONFIGURE_OPTIONS += --with-berkeley-db=$(if $(FREETZ_LIB_libaprutil_WITH_LIBDB),"$(STAGING_DIR)/usr",no)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libaprutil_WITH_LIBDB),--with-dbm=db48)
$(PKG)_CONFIGURE_OPTIONS += --with-expat="$(STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-pgsql=no
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite2
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --includedir=$(APR_UTIL_INCLUDE_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=no
$(PKG)_CONFIGURE_OPTIONS += --with-openssl=no
$(PKG)_CONFIGURE_OPTIONS += --with-nss=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(APR_UTIL_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(APR_UTIL_DIR)\
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/$(APR_UTIL_MAJOR_LIBNAME).la \
		$(STAGING_DIR)/usr/lib/pkgconfig/apr-util-$(APR_UTIL_MAJOR_VERSION).pc \
		$(STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config
	# additional fixes not covered by default version of $(PKG_FIX_LIBTOOL_LA)
	$(call PKG_FIX_LIBTOOL_LA,bindir datarootdir datadir) \
		$(STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config
	# fixes taken from openwrt
	sed -i -e 's|-[LR][$$]libdir||g' $(STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APR_UTIL_DIR) clean
	$(RM) -r \
		$(STAGING_DIR)/usr/lib/$(APR_UTIL_MAJOR_LIBNAME)* \
		$(STAGING_DIR)/usr/lib/apr-util-$(APR_UTIL_MAJOR_VERSION) \
		$(STAGING_DIR)/usr/lib/pkgconfig/apr-util-$(APR_UTIL_MAJOR_VERSION).pc \
		$(STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config \
		$(STAGING_DIR)/usr/lib/aprutil.exp \
		$(STAGING_DIR)/$(APR_UTIL_INCLUDE_DIR)/

$(pkg)-uninstall:
	$(RM) $(APR_UTIL_TARGET_DIR)/$(APR_UTIL_MAJOR_LIBNAME).so*

$(PKG_FINISH)
