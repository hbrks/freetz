$(call PKG_INIT_BIN, 2.3.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://vsftpd.beasts.org/users/cevans
$(PKG)_BINARY:=$($(PKG)_DIR)/vsftpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/vsftpd
$(PKG)_SOURCE_MD5:=90ea878fcfba32f764cce4dc264a3d68

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VSFTPD_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VSFTPD_WITH_SSL

ifeq ($(strip $(FREETZ_PACKAGE_VSFTPD_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_CFLAGS := -DFREETZ_PACKAGE_VSFTPD_WITH_SSL
$(PKG)_LDFLAGS := -lssl -lcrypto -ldl
endif

ifeq ($(strip $(FREETZ_PACKAGE_VSFTPD_STATIC)),y)
$(PKG)_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VSFTPD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(VSFTPD_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(VSFTPD_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VSFTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VSFTPD_TARGET_BINARY)

$(PKG_FINISH)
