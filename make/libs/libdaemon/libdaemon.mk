$(call PKG_INIT_LIB, 0.14)
$(PKG)_LIB_VERSION:=0.5.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=509dc27107c21bcd9fbf2f95f5669563
$(PKG)_SITE:=http://0pointer.de/lennart/projects/libdaemon/

$(PKG)_BINARY:=$($(PKG)_DIR)/libdaemon/.libs/libdaemon.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(STAGING_DIR)/lib/libdaemon.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libdaemon.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_ENV += ac_cv_func_setpgrp_void=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-lynx
$(PKG)_CONFIGURE_OPTIONS += --disable-examples


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDAEMON_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDAEMON_DIR) \
		DESTDIR="$(STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(STAGING_DIR)/usr/lib/libdaemon.la \
		$(STAGING_DIR)/usr/lib/pkgconfig/libdaemon.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r \
		$(STAGING_DIR)/usr/lib/libdaemon* \
		$(STAGING_DIR)/include/libdaemon \
		$(STAGING_DIR)/usr/lib/pkgconfig/libdaemon.pc \
		$(STAGING_DIR)/share/doc/libdaemon

$(pkg)-uninstall:
	$(RM) $(LIBDAEMON_TARGET_DIR)/libdaemon*.so*

$(PKG_FINISH)
