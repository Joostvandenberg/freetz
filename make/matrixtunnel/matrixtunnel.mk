$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=matrixtunnel-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=af169751efc7d87d500716a48d74ddc5
$(PKG)_SITE:=http://znerol.ch/files/OLDSTUFF-PLEASE-DONT-USE
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/matrixtunnel
$(PKG)_BINARY:=$($(PKG)_DIR)/src/matrixtunnel
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/matrixtunnel

$(PKG)_DEPENDS_ON := matrixssl

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-matrixssl-src="$(FREETZ_BASE_DIR)/$(MATRIXSSL_DIR)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MATRIXTUNNEL_DIR)/src all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MATRIXTUNNEL_DIR)/src clean

$(pkg)-uninstall:
	$(RM) $(MATRIXTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
