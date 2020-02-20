#!/bin/bash

sudo ip addr add 10.0.1.1/24 dev vnet0
sudo ip link set up dev vnet0
ip addr show dev vnet0
