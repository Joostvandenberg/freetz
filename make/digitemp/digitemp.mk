$(call PKG_INIT_BIN, 3.6.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.digitemp.com/software/linux
$(PKG)_BINARY:=$($(PKG)_DIR)/digitemp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/digitemp

$(PKG)_MAKE_TARGET:=ds9097

ifeq ($(strip $(FREETZ_PACKAGE_DIGITEMP_DS2490)),y)
$(PKG)_MAKE_TARGET:=ds2490
$(PKG)_DEPENDS_ON += libusb
endif

ifeq ($(strip $(FREETZ_PACKAGE_DIGITEMP_DS9097U)),y)
$(PKG)_MAKE_TARGET:=ds9097u
endif

$(PKG)_MAKE_BINARY:=$($(PKG)_DIR)/digitemp_$(shell echo $($(PKG)_MAKE_TARGET) | tr [:lower:] [:upper:])

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS9097
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS2490
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS9097U


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(DIGITEMP_DIR) \
		CC="$(TARGET_CC)" \
		$(DIGITEMP_MAKE_TARGET)
	cp $(DIGITEMP_MAKE_BINARY) $(DIGITEMP_BINARY)

	
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DIGITEMP_DIR) clean
	$(RM) $(DIGITEMP_TARGET_BINARY)

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
