depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean: depsclean
	@printf "$(TERM_YELLOW)---> cleaning system build directories and files .. $(TERM_NORMAL)"
	@-$(MAKE) kernel-clean
	@-$(MAKE) tools-clean
	@-$(MAKE) driver-clean
	@-rm -rf $(BASE_DIR)/tufsbox
	@-rm -rf $(D)/kernel
	@-rm -rf $(D)/kernel.do_compile
	@printf "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

distclean:
	@printf "$(TERM_YELLOW)---> cleaning system build directories and files .. $(TERM_NORMAL)"
	@-$(MAKE) tools-clean
	@-$(MAKE) driver-clean
	@-rm -rf $(BASE_DIR)/tufsbox
	@-rm -rf $(BUILD_TMP)
	@-rm -rf $(SOURCE_DIR)
	@-rm -rf $(D)
	@test -d $(D) || mkdir $(D)
	@printf "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

%-clean:
	( cd $(D) && find . -name $(subst -clean,,$@) -delete )
