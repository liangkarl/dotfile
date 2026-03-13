PM=brew rustup yarn npm pip pip3 pkig nix
OSTYPE=$(shell uname)
BREW=$(shell which brew)

ifeq ($(OSTYPE),Darwin)
PACK_MGR=brew
else ifeq ($(OSTYPE),Linux)
PACK_MGR=apt
else
$(error Unknown OS)
endif

.ONESHELL:

nix:
	curl -L https://nixos.org/nix/install | sh -s -- --daemon

brew: # [Install Guide](https://brew.sh/)
	echo "check brew..."
	if [ -z "$(BREW)" ]; then
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh
	fi
	# wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh --output-document - | sh

rustup cargo: brew # [Install Guide](https://doc.rust-lang.org/cargo/getting-started/installation.html)
	brew install rustup
	# curl https://sh.rustup.rs -sSfL | sh
	# wget https://sh.rustup.rs -O - | sh

npm nvm: brew
	brew install nvm
	# curl https://npmjs.org/install.sh | sh

pipx: brew
	brew install pipx

yarn: npm
	sudo npm -g install yarn

pip:
	sudo $(PACK_MGR) install python-pip

pip3:
	sudo $(PACK_MGR) install python3-pip

pm: $(PM)
	@echo "all package managers installed"

.PHONY: pm $(PM)
