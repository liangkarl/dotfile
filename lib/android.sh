#!/bin/bash

source $SHELL_CORE_DIR/utils.sh

ANDROID_NAME='android'
ANDROID_CONFIG="$SHELL_CONFIG_DIR/$ANDROID_NAME"

install()
{
        echo "Install $ANDROID_NAME..."
	sudo apt install -y git-core gnupg flex bison build-essential \
		zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
		lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
		libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

	# for newer Android build system
	sudo apt install ninja-build
}

uninstall()
{
        echo "Remove $ANDROID_NAME..."
}

config_package()
{
        echo "Config $ANDROID_NAME..."
}
