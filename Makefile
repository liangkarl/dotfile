# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
TOP:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

H=@

-include $(TOP)/config/package.mk

tool: ## Install all tools
	./tool/configure.sh

testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH

.PHONY: all tool config
