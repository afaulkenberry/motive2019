#!/bin/bash

vir1_if=wifi1
vir2_if=wifi2

br_if=br0

node_num=${HOSTNAME:4:1}
br_ip=172.0.0.$node_num

ip link add name $br_if type bridge
ip link set $br_if up

ip link set $vir1_if master $br_if
ip link set $vir2_if master $br_if


ifconfig $br_if $br_ip
