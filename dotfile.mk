CONF_HOME:=${XDG_CONFIG_HOME}

LIST:=clang-format editorconfig
ALIAS:=

.ONESHELL:

all.dotfile: $(LIST)


$(LIST): __check_dotfile
	$(H)$(eval DST_DIR:=$(CONF_HOME)/dotfile/$@)
	$(H)$(eval SRC_DIR:=$(TOP)/misc/$@)

	$(H)if [[ ! -d $(DST_DIR) ]]; then
		mkdir $(shell dirname ${DST_DIR})
	fi

	$(H)cp -v $(SRC_DIR) $(DST_DIR)
	$(H)ln -svf $(DST_DIR) $(HOME)/.$@
	$(H)echo "Install dotfile: $@"

.PHONY: $(LIST) $(ALIAS) all.dotfile __check_dotfile
