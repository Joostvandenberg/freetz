$(call PKG_INIT_LIB, 0.2)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=b7dba580f887d3d10c2df808eed00e69
$(PKG)_SITE:=http://freetz.magenbrot.net

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := openssl
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBAVMHMAC_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LFLAGS="-L$(STAGING_DIR)/usr/lib" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBAVMHMAC_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBAVMHMAC_DIR) clean
	$(RM) $(STAGING_DIR)/lib/libavmhmac*

$(pkg)-uninstall:
	$(RM) $(LIBAVMHMAC_DEST_LIB)/libavmhmac*.so*

$(PKG_FINISH)
