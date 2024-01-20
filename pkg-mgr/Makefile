PM=brew rustup yarn npm pip pip3 pkig nix
OSTYPE=$(shell uname)

ifeq ($(OSTYPE),Darwin)
PACK_MGR=brew
else ifeq ($(OSTYPE),Linux)
PACK_MGR=apt
else
$(error Unknown OS)
endif

brew: # [Install Guide](https://brew.sh/)
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh
	# wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh --output-document - | sh

rustup: # [Install Guide](https://doc.rust-lang.org/cargo/getting-started/installation.html)
	curl https://sh.rustup.rs -sSfL | sh
	# wget https://sh.rustup.rs -O - | sh

yarn: npm
	sudo npm -g install yarn

npm:
	curl https://npmjs.org/install.sh | sh

pip:
	sudo $(PACK_MGR) install python-pip

pip3:
	sudo $(PACK_MGR) install python3-pip

pkig:

nix:
	curl -L https://nixos.org/nix/install | sh -s -- --daemon

pm: $(PM)
	@echo "all package managers installed"

.PHONY: pm $(PM)
