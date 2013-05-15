$(call PKG_INIT_BIN, 7.1a)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-source.tar.gz
$(PKG)_SOURCE_MD5:=102d9652681db11c813610882332ae48
$(PKG)_SITE:=http://freetz.magenbrot.net

$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)-source

$(PKG)_BINARY := $($(PKG)_DIR)/Main/$(pkg)
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := $(STDCXXLIB) fuse wxWidgets pkcs11

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRUECRYPT_STATIC

# strip lfs flags
$(PKG)_CFLAGS := $(subst $(CFLAGS_LARGEFILE),,$(TARGET_CFLAGS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRUECRYPT_DIR) \
		NOGUI=1 \
		NOTEST=1 \
		VERBOSE=1 \
		DISABLE_PRECOMPILED_HEADERS=1 \
		\
		ARCH=$(TARGET_ARCH) \
		\
		LFS_FLAGS="$(CFLAGS_LFS_ENABLED)" \
		\
		CC="$(TARGET_CC)" \
		TC_EXTRA_CFLAGS="$(TRUECRYPT_CFLAGS)" \
		\
		CXX="$(TARGET_CXX)" \
		TC_EXTRA_CXXFLAGS="$(TRUECRYPT_CFLAGS)" \
		\
		LDFLAGS="$(TARGET_LDFLAGS)" \
		\
		PKCS11_INC="$(STAGING_DIR)/usr/include/pkcs11" \
		\
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
		WX_CONFIG="$(STAGING_DIR)/usr/bin/wx-config" \
		AR="$(TARGET_AR)" \
		LD="$(TARGET_LD)" \
		RANLIB="$(TARGET_RANLIB)" \
		STRIP="$(TARGET_STRIP)" \
		\
		$(if $(FREETZ_PACKAGE_TRUECRYPT_STATIC),EXTRA_LDFLAGS="-static")

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TRUECRYPT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TRUECRYPT_TARGET_BINARY)

$(PKG_FINISH)
