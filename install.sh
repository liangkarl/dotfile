#!/bin/bash
#
set -x

## Load environment variables
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $ROOT/core/env.sh

# prepare basic functions
init_env $ROOT

## Install packages
# Load package libraries
source $LIB_DIR/installer.sh

# Install package
install_packages

set +x
