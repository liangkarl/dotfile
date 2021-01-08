#!/bin/bash

source $SHELL_CORE_DIR/utils.sh
# source $SHELL_CORE_DIR/sign.sh

OTHERS_NAME='others'
OTHERS_CONFIG="$SHELL_CONFIG_DIR/$OTHERS_NAME"

APT_LIST="
	curl
	bears
	tree
	tig
	python3-pip
"

CUST_LIST="
	install_llvm_clang
	install_ccls
	install_gcc
	install_nodejs
	install_python
"

install()
{
	echo "Install: $PACKAGE_LIST"

	pushd $HOME &>-
	for CMD in $PACKAGE_LIST; do
		echo "==== Prepare $CMD ===="
		sudo apt install -y $CMD
		echo "==== Finish $CMD ===="
	done
	popd &>-
        config_package
}

install_llvm_clang()
{
	pushd $HOME
	mkdir .tmp
	pushd .tmp

	wget https://apt.llvm.org/llvm.sh
	chmod +x llvm.sh

	sudo ./llvm.sh 10
	# libc++
	sudo apt install libc++-10-dev libc++abi-10-dev
	# Clang and co
	sudo apt install clang-10 clang-tools-10 clang-10-doc \
		libclang-common-10-dev libclang-10-dev libclang1-10 \
		clang-format-10 python3-clang-10 clangd-10

	sudo apt install libclang-10-dev
	popd # leave .tmp
	rm -rf .tmp
	popd # leave $HOME

	# FIXME: only support clang-X
	setup_version "/usr/bin/clang" "clang" "$(ls /usr/bin/clang-[0-9])"
}

install_ccls()
{
	echo "Prepare ccls installization..."

	echo "Install ccls with snap."
	# Reference https://github.com/MaskRay/ccls/issues/609
	# sudo apt install -y snapd

	# Check status
	# systemctl status snapd.service
	# Run snapd, if not yet active
	# systemctl start snapd.service
	# install ccls by snap
	sudo snap install ccls --classic \
			&& return

	echo "Try to build ccls"
	install_llvm_clang

	sudo apt install -y zlib1g-dev libncurses-dev
	sudo apt install -y cmake

	pushd $HOME
	mkdir .tmp
	pushd .tmp

	git clone --depth=1 --recursive https://github.com/MaskRay/ccls
	cd ccls
	echo "*** Make sure you have workable version for ccls ***"
	echo "g++: $(g++ --version)" | awk 'NR==1'
	echo "gcc: $(gcc --version)" | awk 'NR==1'
	echo "clang: $(clang --version)" | awk 'NR==1'
	echo "cmake: $(cmake --version)" | awk 'NR==1'
	echo "****************************************************"
	cmake -H. -BRelease \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_PREFIX_PATH=/usr/lib/llvm-10 \
		-DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include \
		-DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10
	cmake --build Release
	sudo make install -C ./Release

	popd # leave .tmp
	rm -rf .tmp
	popd # leave $HOME
}

install_gcc()
{
	add_ppa_repo ppa:ubuntu-toolchain-r/test
	sudo apt install gcc-7 gcc-8 gcc-9
	setup_version "/usr/bin/gcc" "gcc" "$(ls /usr/bin/gcc-[0-9])"

	sudo apt install g++-7 g++-8 g++-9
	setup_version "/usr/bin/g++" "g++" "$(ls /usr/bin/g++-[0-9])"
}

install_python()
{
	add_ppa_repo ppa:deadsnakes/ppa
	sudo apt install python3.6 python3.9
	# FIXME: only matched regex: pythonX.Y
	setup_version "/usr/bin/python" "python" "$(ls /usr/bin/python[0-9].[0-9])"
	setup_version "/usr/bin/python3" "python3" "$(ls /usr/bin/python3.[0-9])"
}

uninstall()
{
        echo "Remove $OTHERS_NAME..."
}

config_package()
{
        echo "Config $OTHERS_NAME..."
}
