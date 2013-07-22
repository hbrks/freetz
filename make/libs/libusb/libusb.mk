$(call PKG_INIT_LIB,$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),0.1.5,0.1.12))
$(PKG)_DIR_COMPONENT:=$(pkg)$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),-compat)-$($(PKG)_VERSION)
$(PKG)_SHORT_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_LIB_VERSION:=4.4.4
$(PKG)_SOURCE:=$($(PKG)_DIR_COMPONENT).tar.$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),bz2,gz)
$(PKG)_SOURCE_MD5:=$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),2780b6a758a1e2c2943bdbf7faf740e4,caf182cbc7565dac0fd72155919672e6)
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$($(PKG)_DIR_COMPONENT)

$(PKG)_CONDITIONAL_PATCHES+=$(pkg)$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),-compat)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),$(pkg)/).libs/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libusb_0_WITH_LEGACY
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libusb_0_WITH_COMPAT

$(PKG)_DEPENDS_ON := $(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),libusb1)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libusb_0_WITH_COMPAT),--disable-examples-build)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBUSB_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUSB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libusb.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBUSB_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libusb-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/usb.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb-$(LIBUSB_SHORT_VERSION)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb.{a,la,so} \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libusb.pc

$(pkg)-uninstall:
	$(RM) $(LIBUSB_TARGET_DIR)/libusb-$(LIBUSB_SHORT_VERSION).so*

$(PKG_FINISH)
