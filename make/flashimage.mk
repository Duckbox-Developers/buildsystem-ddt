#
#
#
ifneq ($(SUDOPASSWD),)

flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 ufs910 ufs922 ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	cd $(BASE_DIR)/flash/nor_flash && echo "$(SUDOPASSWD)" | sudo -S ./make_flash.sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs912))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs913))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufc960))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && echo "$(SUDOPASSWD)" | sudo -S ./$(BOXTYPE).sh
endif

endif

