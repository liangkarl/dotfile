XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=pyenv
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)
PYENV_ROOT=${HOME}/.pyenv
PYENV_ENV_LINK=${HOME}/.pyenvrc

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)ln -snf "${CONFIG_DIR}/pyenv.env" "${PYENV_ENV_LINK}"
	$(H)echo "Created ${PYENV_ENV_LINK}. Source it from your shell startup file if needed."

install:
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if ! command -v pyenv >/dev/null 2>&1; then
		if [[ "$(OSTYPE)" == "Darwin" ]]; then
			brew install pyenv
		else
			curl -fsSL https://pyenv.run | bash
		fi
	fi
	$(H)export PYENV_ROOT="${PYENV_ROOT}"
	$(H)export PATH="${PYENV_ROOT}/bin:${PATH}"
	$(H)eval "$(pyenv init -)"
	$(H)LATEST_VERSION="$$(pyenv install --list | awk '/^[[:space:]]*3\.[0-9]+\.[0-9]+$$/ {gsub(/^[[:space:]]+/,"",$$1); print $$1}' | tail -n1)"
	$(H)if [[ -z "$$LATEST_VERSION" ]]; then
		echo "Unable to detect latest Python 3 version from pyenv install list"
		exit 1
	fi
	$(H)IFS='.' read -r PY_MAJOR PY_MINOR PY_PATCH <<< "$$LATEST_VERSION"
	$(H)TARGET_MINOR=$$((PY_MINOR - 2))
	$(H)if [[ $$TARGET_MINOR -lt 0 ]]; then
		echo "Cannot resolve target Python version from latest: $$LATEST_VERSION"
		exit 1
	fi
	$(H)TARGET_PREFIX="$${PY_MAJOR}.$${TARGET_MINOR}."
	$(H)TARGET_VERSION="$$(pyenv install --list | awk '/^[[:space:]]*3\.[0-9]+\.[0-9]+$$/ {gsub(/^[[:space:]]+/,"",$$1); print $$1}' | awk -v prefix="$$TARGET_PREFIX" 'index($$1, prefix) == 1 {print $$1}' | tail -n1)"
	$(H)if [[ -z "$$TARGET_VERSION" ]]; then
		echo "Unable to detect target Python version for prefix $$TARGET_PREFIX"
		exit 1
	fi
	$(H)echo "Latest available Python: $$LATEST_VERSION"
	$(H)echo "Installing default target Python: $$TARGET_VERSION"
	$(H)pyenv install -s "$$TARGET_VERSION"
	$(H)pyenv global "$$TARGET_VERSION"

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config and pyenv --"
	$(H)rm -f "${PYENV_ENV_LINK}"
	$(H)rm -rf "${PYENV_ROOT}"
	$(H)rm -rf "${CONFIG_DIR}"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
		brew uninstall pyenv || true
	fi

.PHONY: config install uninstall
