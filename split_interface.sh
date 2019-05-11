#! /bin/bash

## NEEDS TO BE ROOT

## This script takes a physical interface and breaks it into two virtual interfaces.
## Argument that the script takes is the name of the interface to be split


phy_if=$1

vir1_if=wifi1
vir2_if=wifi2

node_num=${HOSTNAME:4:1}

vir1_mac=00:00:00:00:0a:0$node_num
vir2_mac=00:00:00:00:0b:0$node_num

#vir1_ip=10.0.1.$node_num
#vir2_ip=10.0.2.$node_num


if [ "$1" == "-h" ]; then
    echo "# ./split_interface.sh {interface_name}" 
    exit

elif [ "$#" -ne "1" ]; then
    echo "# ./split_interface.sh {interface_name}" 
    exit 1
fi

ip link set $phy_if down
ip link set $phy_if up

iw dev $phy_if interface add $vir1_if type station
iw dev $phy_if interface add $vir2_if type station

ip link set $phy_if down

ip link set $vir1_if addr $vir1_mac # 4addr on
ip link set $vir2_if addr $vir2_mac # 4addr on
