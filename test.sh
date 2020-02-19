#!/bin/bash

set +e

dir=$(dirname $0)
dev="enp0s5"
logfile=test.log

echo "start test" > $logfile

while true; do
	ip addr add 10.0.1.2/24 dev $dev
	if [[ $? == 0 ]]; then
		break
	fi
	sleep 1
done
ip link set up dev $dev &>> $logfile
ip route add default dev $dev &>> $logfile
ip addr &>> $logfile

tc qdisc add dev $dev clsact &>> $logfile

tc filter add dev $dev ingress bpf da obj src/test_xdp_meta.o sec t &>> $logfile

ip link set dev $dev xdpdrv obj src/test_xdp_meta.o sec pass &>> $logfile

ping -q -c1 -w1 10.0.1.1 &>> $logfile
if [[ $? == 0 ]]; then
	exit 0
fi
exit 1
