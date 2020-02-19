#!/bin/bash

readonly script_dir="$(cd "$(dirname "$0")"; pwd)"
src_dir=$script_dir/bpf-next

pushd "${src_dir}"

kernel_version=$(make kernelversion)

make -j`nproc` bzImage

mv "arch/x86/boot/bzImage" "${script_dir}/linux-${kernel_version}.bz"
popd
