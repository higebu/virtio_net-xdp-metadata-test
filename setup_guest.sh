#!/bin/bash

set +e

dir=$(dirname $0)
dev="enp0s4"

ip addr add 10.0.1.2/24 dev $dev
ip link set up dev $dev
ip route add default dev $dev

ip link set dev $dev xdpdrv obj src/test_xdp_meta.o sec tx
