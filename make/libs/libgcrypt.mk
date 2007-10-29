PACKAGE_LC:=libgcrypt
PACKAGE_UC:=LIBGCRYPT
$(PACKAGE_UC)_VERSION:=1.2.2
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=11.2.1
$(PACKAGE_UC)_SOURCE:=libgcrypt-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://ftp.gnupg.org/gcrypt/libgcrypt
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/src/.libs/libgcrypt.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libgcrypt.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-asm
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-gpg-error-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGCRYPT_DIR)

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGCRYPT_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgcrypt.la

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*.so* $($(PACKAGE_UC)_TARGET_DIR)/
	$(TARGET_STRIP) $@

libgcrypt: $($(PACKAGE_UC)_STAGING_BINARY)

libgcrypt-precompiled: uclibc libgpg-error-precompiled libgcrypt $($(PACKAGE_UC)_TARGET_BINARY)

libgcrypt-clean:
	-$(MAKE) -C $(LIBGCRYPT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*

libgcrypt-uninstall:
	rm -f $(LIBGCRYPT_TARGET_DIR)/libgcrypt*.so*

$(PACKAGE_FINI)
