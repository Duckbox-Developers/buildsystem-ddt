depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean: depsclean
	-$(MAKE) kernel-clean
	-$(MAKE) tools-clean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(D)/kernel
	-rm -rf $(D)/kernel.do_compile

distclean:
	-$(MAKE) tools-clean
	-$(MAKE) driver-clean
	-rm -rf $(BASE_DIR)/tufsbox
	-rm -rf $(BUILD_TMP)
	-rm -rf $(SOURCE_DIR)
	-rm -rf $(D)
	test -d $(D) || mkdir $(D)

%-clean:
	( cd $(D) && find . -name $(subst -clean,,$@) -delete )
