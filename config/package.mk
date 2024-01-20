CONF_HOME:=${XDG_CONFIG_HOME}

LIST:=bash nvim tmux git tig kitty

.ONESHELL:

all.package: $(LIST)

$(LIST):
	$(H)$(eval SRC_DIR:=$(TOP)/config/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)echo "Install configuration: $@"
	$(H)cp -rvf $(SRC_DIR) $(CONF_HOME)/
	$(H)echo "-------------------------------"
	$(H)if [[ -e $(DST_DIR)/configure.sh ]]; then
		eval $(DST_DIR)/configure.sh
	fi

clean.%:
	$(H)$(eval NAME:=$(strip $(subst clean.,,$@)))
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$(NAME))

	$(H)echo "Remove configuration: $(NAME)"
	$(H)rm -rvf $(DST_DIR)
	$(H)echo "-------------------------------"

.PHONY: $(LIST) clean.% clean all.package
