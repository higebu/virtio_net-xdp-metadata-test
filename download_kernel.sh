#!/bin/bash

readonly script_dir="$(cd "$(dirname "$0")"; pwd)"
src_dir=$script_dir/bpf-next

git clone --depth 1 -b virtio_net-xdp-metadata https://github.com/higebu/bpf-next.git ${src_dir}
