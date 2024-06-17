# Generate compile_commands.json
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1

# Make soong generate a symlink to the compdb file using an env var
# export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

# render special file for AOSP in ls
# binary file: img, bin
LS_COLORS="*.img=00;93:*.bin=00;93:$LS_COLORS"
# makefile: mk, bp
LS_COLORS="*.mk=01;04;35:*.bp=01;04;35:$LS_COLORS"
# patch: patch, diff
LS_COLORS="*.patch=01;90:*.diff=01;90:$LS_COLORS"
# config: json, xml
LS_COLORS="*.json=00;35:*.xml=00;35:$LS_COLORS"

# Prevent compilation error of flex in Ubuntu 18.04
# Fix showing '_' symbols with extension fonts in tmux
if [[ "$(uname)" == "Darwin" ]]; then
    export LANG=C LC_CTYPE=UTF-8
# else
#   FIXME: check whether or not this command is available
#   The original command is `sudo dpkg-reconfigure locales`
#
#   export LC_ALL=C.UTF-8
fi

# Quanta
alias logcat='adb wait-for-device logcat -v color'
alias kmsg='adb wait-for-device shell dmesg -wr'
