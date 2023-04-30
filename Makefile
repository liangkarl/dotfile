all: bash tool config

bash: ## Install configuration for bash
config: ## Install all configurations
kitty: ## Install configuration for kitty
tig: ## Install configuration for tig
git: ## Install configuration for git
nvim: ## Install configuration for nvim
enhancd: ## Install configuration for enhancd
tmux: ## Install configuration for tmux

bash tmux enhancd nvim git tig kitty:
	./config/configure.sh $@

config: bash tmux enhancd nvim git tig kitty

tool: ## Install all tools
	./tool/configure.sh

testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH

help: ## Print available make list
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all tool config
