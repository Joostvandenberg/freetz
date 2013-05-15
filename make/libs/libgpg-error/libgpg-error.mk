$(call PKG_INIT_LIB, 1.10)
$(PKG)_LIB_VERSION:=0.8.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=736a03daa9dc5873047d4eb4a9c22a16
$(PKG)_SITE:=ftp://ftp.gnupg.org/gcrypt/libgpg-error

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBGPG_ERROR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBGPG_ERROR_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libgpg-error.la \
		$(STAGING_DIR)/usr/bin/gpg-error-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBGPG_ERROR_DIR) clean
	$(RM) -r \
		$(STAGING_DIR)/usr/lib/libgpg-error* \
		$(STAGING_DIR)/usr/bin/gpg-error* \
		$(STAGING_DIR)/usr/include/gpg-error* \
		$(STAGING_DIR)/usr/share/aclocal/gpg-error* \
		$(STAGING_DIR)/usr/share/common-lisp/source/gpg-error*

$(pkg)-uninstall:
	$(RM) $(LIBGPG_ERROR_TARGET_DIR)/libgpg-error*.so*

$(PKG_FINISH)
