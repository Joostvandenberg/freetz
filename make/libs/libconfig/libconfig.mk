$(call PKG_INIT_LIB, 1.4.9)
$(PKG)_LIB_VERSION:=9.1.3
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b6ee0ce2b3ef844bad7cac2803a90634
$(PKG)_SITE:=http://www.hyperrealm.com/libconfig

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCONFIG_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBCONFIG_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libconfig.la \
		$(STAGING_DIR)/usr/lib/pkgconfig/libconfig.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCONFIG_DIR) clean
	$(RM) \
		$(STAGING_DIR)/usr/lib/libconfig* \
		$(STAGING_DIR)/usr/include/libconfig.h \
		$(STAGING_DIR)/usr/lib/pkgconfig/libconfig.pc \
		$(STAGING_DIR)/share/info/libconfig.info

$(pkg)-uninstall:
	$(RM) $(LIBCONFIG_TARGET_DIR)/libconfig*.so*

$(PKG_FINISH)
