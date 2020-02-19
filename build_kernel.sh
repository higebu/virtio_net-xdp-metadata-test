#!/bin/bash

readonly script_dir="$(cd "$(dirname "$0")"; pwd)"
src_dir=$script_dir/bpf-next

pushd "${src_dir}"

kernel_version=$(make kernelversion)

rm ${src_dir}/custom.config
rm ${src_dir}/.config
make KCONFIG_CONFIG=custom.config defconfig
cat "${script_dir}/config" >> "${src_dir}/custom.config"
make allnoconfig KCONFIG_ALLCONFIG="custom.config"
virtme-configkernel --update

make clean
make -j`nproc` bzImage

mv "arch/x86/boot/bzImage" "${script_dir}/linux-${kernel_version}.bz"
popd
