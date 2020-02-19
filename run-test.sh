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

run_test()
{
	sudo virtme-run \
		--kimg $kernel_image \
		--show-command \
		--show-boot-console \
		--memory 256M \
		--pwd \
		--rw \
		--script-sh $script \
		--qemu-opts -enable-kvm -smp 2 -netdev tap,vhost=on,vnet_hdr=on,queues=4,id=vnet0,ifname=vnet0,script=no,downscript=no -device virtio-net-pci,mrg_rxbuf="${mrg_rxbuf}",csum=off,guest_csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,mq=on,vectors=6,netdev=vnet0
}

host_setup()
{
	echo "start host_setup" > host.log
	while true; do
		sudo ip addr add 10.0.1.1/24 dev vnet0
		if [[ $? == 0 ]]; then
			break
		fi
		sleep 1
	done
	sudo ip link set up dev vnet0
	ip addr show dev vnet0 &>> host.log
	echo "end host_setup" >> host.log
}

run_test &
host_setup &
wait
