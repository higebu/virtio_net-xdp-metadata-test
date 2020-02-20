#!/bin/bash

set +e
set -o pipefail

readonly script_dir=$(realpath "$(dirname $0)")
src_dir=$script_dir/bpf-next
pushd "${src_dir}"
readonly kernel_version=$(make kernelversion)
popd

readonly kernel_image=./linux-${kernel_version}.bz
readonly script=$(realpath $script_dir/test.sh)

mrg_rxbuf="off"
if [[ "${1:-}" = "--receive_mergeable" ]]; then
	shift
	mrg_rxbuf="on"
fi

run_vm()
{
	sudo virtme-run \
		--kimg $kernel_image \
		--show-command \
		--show-boot-console \
		--memory 256M \
		--pwd \
		--rw \
		--qemu-opts -enable-kvm -smp 2 -netdev tap,vhost=on,vnet_hdr=on,queues=4,id=vnet0,ifname=vnet0,script=no,downscript=no -device virtio-net-pci,mrg_rxbuf="${mrg_rxbuf}",csum=off,guest_csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,mq=on,vectors=6,netdev=vnet0
}

run_vm
