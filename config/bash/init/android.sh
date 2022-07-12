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

# For Ubuntu 18.04, prevent compliant error from flex
export LC_ALL=C
