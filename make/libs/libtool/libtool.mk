$(call PKG_INIT_LIB, 1.5.26)
$(PKG)_LIB_VERSION:=3.1.6
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=aa9c5107f3ec9ef4200eb6556f3b3c29
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/libltdl/.libs/libltdl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/usr/lib/libltdl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libltdl.so.$($(PKG)_LIB_VERSION)

TARGET_CONFIGURE_ENV += GLOBAL_LIBDIR=$(STAGING_DIR)/usr/lib

# touch some patched files to ensure no file except for ltmain.sh gets regenerated
$(PKG)_CONFIGURE_PRE_CMDS += \
	for i in $$$$(find $(abspath $(LIBTOOL_DIR)) -type f \( \( -name "*.m4" -o -name "*.am" \) -a ! -name "aclocal.m4" \)); do \
		touch -t 200001010000.00 $$$$i; \
	done;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBTOOL_DIR)/libltdl

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBTOOL_DIR)/libltdl \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libltdl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBTOOL_DIR) clean
	$(RM) $(STAGING_DIR)/usr/lib/libltdl.* $(STAGING_DIR)/usr/include/ltdl.h

$(pkg)-uninstall:
	$(RM) $(LIBTOOL_TARGET_DIR)/libltdl*.so*

$(PKG_FINISH)
