YOURFRITZ_HOST_VERSION:=524e3fb883
YOURFRITZ_HOST_SOURCE:=yourfritz-$(YOURFRITZ_HOST_VERSION).tar.xz
YOURFRITZ_HOST_SITE:=git@https://github.com/PeterPawn/YourFritz.git

YOURFRITZ_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/yourfritz-host
YOURFRITZ_HOST_DIR:=$(TOOLS_SOURCE_DIR)/yourfritz-$(YOURFRITZ_HOST_VERSION)

# AKC stands for AVM_KERNEL_CONFIG
YOURFRITZ_HOST_AKC_BUILD_DIR:=$(YOURFRITZ_HOST_DIR)/avm_kernel_config
YOURFRITZ_HOST_AKC_TOOLS:=extract gen
YOURFRITZ_HOST_AKC_TOOLS_BUILD_DIR:=$(YOURFRITZ_HOST_AKC_TOOLS:%=$(YOURFRITZ_HOST_AKC_BUILD_DIR)/%_avm_kernel_config)
YOURFRITZ_HOST_AKC_TOOLS_TARGET_DIR:=$(YOURFRITZ_HOST_AKC_TOOLS:%=$(TOOLS_DIR)/avm_kernel_config.%)

yourfritz-host-source: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
$(DL_DIR)/$(YOURFRITZ_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(YOURFRITZ_HOST_SOURCE) $(YOURFRITZ_HOST_SITE) $(YOURFRITZ_HOST_SOURCE_MD5)

yourfritz-host-unpacked: $(YOURFRITZ_HOST_DIR)/.unpacked
$(YOURFRITZ_HOST_DIR)/.unpacked: $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(TAR) -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(YOURFRITZ_HOST_SOURCE)
	$(call APPLY_PATCHES,$(YOURFRITZ_HOST_MAKE_DIR)/patches,$(YOURFRITZ_HOST_DIR))
	touch $@

$(YOURFRITZ_HOST_DIR)/.symlinked: | $(YOURFRITZ_HOST_DIR)/.unpacked
	@ln -Tsf ../$(YOURFRITZ_HOST_DIR:$(FREETZ_BASE_DIR)/%=%) $(TOOLS_DIR)/yf
	touch $@

$(YOURFRITZ_HOST_AKC_TOOLS_BUILD_DIR): $(YOURFRITZ_HOST_DIR)/.unpacked $(DTC_LIBFDT_HOST_DIR)/libfdt.a
	$(MAKE) -f Makefile.freetz -C $(YOURFRITZ_HOST_AKC_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		LIBFDT_DIR=$(DTC_LIBFDT_HOST_DIR) \
		$(YOURFRITZ_HOST_AKC_TOOLS:%=%_avm_kernel_config)
	touch -c $@

$(YOURFRITZ_HOST_AKC_TOOLS_TARGET_DIR): $(TOOLS_DIR)/avm_kernel_config.%: $(YOURFRITZ_HOST_AKC_BUILD_DIR)/%_avm_kernel_config
	$(INSTALL_FILE)

yourfritz-host: $(YOURFRITZ_HOST_DIR)/.symlinked $(YOURFRITZ_HOST_AKC_TOOLS_TARGET_DIR)

yourfritz-host-clean:
	-$(MAKE) -f Makefile.freetz -C $(YOURFRITZ_HOST_AKC_BUILD_DIR) clean

yourfritz-host-dirclean:
	$(RM) -r $(YOURFRITZ_HOST_DIR)

yourfritz-host-distclean: yourfritz-host-dirclean
	$(RM) $(TOOLS_DIR)/yf $(YOURFRITZ_HOST_AKC_TOOLS_TARGET_DIR)
