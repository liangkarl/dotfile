CONF_HOME:=${XDG_CONFIG_HOME}

LIST:=clang-format editorconfig
ALIAS:=

.ONESHELL:

all.dotfile: $(LIST)

$(LIST):
	$(H)$(eval SRC_DIR:=$(TOP)/misc/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/dotfile/$@)

	$(H)echo "Install dotfile: $@"
	$(H)ln -svf $(DST_DIR)/$@ $(HOME)/.$@
	$(H)echo "-------------------------------"

clean.%:
	$(H)$(eval NAME:=$(strip $(subst clean.,,$@)))
	$(H)$(eval DST_DIR:=$(CONF_HOME)/dotfile/$(NAME))

	$(H)echo "Remove dotfile: $(NAME)"
	$(H)rm -rvf $(DST_DIR)
	$(H)echo "-------------------------------"

.PHONY: $(LIST) $(ALIAS) clean.% clean all.dotfile
