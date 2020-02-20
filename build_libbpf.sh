#!/bin/bash

readonly script_dir="$(cd "$(dirname "$0")"; pwd)"
src_dir=$script_dir/bpf-next

pushd $src_dir/tools/lib/bpf/
make
popd
