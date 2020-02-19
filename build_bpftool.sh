#!/bin/bash

readonly script_dir="$(cd "$(dirname "$0")"; pwd)"
src_dir=$script_dir/bpf-next

pushd $src_dir/tools/bpf/bpftool/
make
cp ./bpftool $script_dir
popd
