CONF_HOME:=${XDG_CONFIG_HOME}

LIST:=bash nvim tmux git tig kitty tool procps enhancd
ALIAS:=top

.ONESHELL:

all.package: $(LIST)

$(LIST):
	$(H)$(eval SRC_DIR:=$(TOP)/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)echo "Install configuration: $@"
	$(H)cp -rvf $(SRC_DIR) $(CONF_HOME)/
	$(H)echo "-------------------------------"
	$(H)if [[ -e $(DST_DIR)/Makefile ]]; then
		make -C $(DST_DIR)
	elif [[ -e $(DST_DIR)/configure.sh ]]; then
		eval $(DST_DIR)/configure.sh
	fi

top: procps

# FIXME: this target would override the same one in the package.mk
clean.%:
	$(H)$(eval NAME:=$(strip $(subst clean.,,$@)))
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$(NAME))

	$(H)echo "Remove configuration: $(NAME)"
	$(H)rm -rvf $(DST_DIR)
	$(H)echo "-------------------------------"

.PHONY: $(LIST) $(ALIAS) clean.% clean all.package
