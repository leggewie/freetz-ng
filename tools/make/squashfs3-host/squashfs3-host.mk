$(call TOOLS_INIT, 3.4)
$(PKG)_SOURCE:=squashfs$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=2a4d2995ad5aa6840c95a95ffa6b1da6
$(PKG)_SITE:=@SF/squashfs

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$($(PKG)_VERSION)
$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/squashfs-tools

$(PKG)_TOOLS:=mksquashfs unsquashfs
$(PKG)_TOOLS_BUILD_DIR:=$($(PKG)_TOOLS:%=$($(PKG)_BUILD_DIR)/%-multi)
$(PKG)_TOOLS_TARGET_DIR:=$($(PKG)_TOOLS:%=$(TOOLS_DIR)/%3-multi)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_TOOLS_BUILD_DIR): $($(PKG)_DIR)/.unpacked $(LZMA1_HOST_DIR)/liblzma1.a
	$(TOOLS_SUBMAKE) -C $(SQUASHFS3_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) -fcommon" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		LZMA1_SUPPORT=1 \
		LZMA_LIBNAME=lzma1 \
		LZMA_DIR="$(abspath $(LZMA1_HOST_DIR))" \
		$(SQUASHFS3_HOST_TOOLS:%=%-multi)
	touch -c $@

$($(PKG)_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%3-multi: $($(PKG)_BUILD_DIR)/%-multi
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TOOLS_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(SQUASHFS3_HOST_BUILD_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SQUASHFS3_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(SQUASHFS3_HOST_TOOLS_TARGET_DIR)

$(TOOLS_FINISH)
