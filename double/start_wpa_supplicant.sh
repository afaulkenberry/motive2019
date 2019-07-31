#!/bin/bash

interface=wlan1

node_num=${HOSTNAME:4:1}
mac_addr=00:00:00:00:0a:0$node_num

conf1=wpa1.conf
base_conf=example.conf


ip link set $interface down
ip link set $interface addr $mac_addr
ip link set $interface up

killall wpa_supplicant

sed "s/0a00/0a0$node_num/g" $base_conf > $conf1
sed -i "s/0a:00/0a:0$node_num/g" $conf1

wpa_supplicant -Dnl80211 -i $interface -c $conf1 -Bd

interface=wlan2

node_num=${HOSTNAME:4:1}
mac_addr=00:00:00:00:0b:0$node_num

conf2=wpa2.conf
base_conf=example.conf


ip link set $interface down
ip link set $interface addr $mac_addr
ip link set $interface up

sed "s/0a00/0b0$node_num/g" $base_conf > $conf2
sed -i "s/0a:00/0b:0$node_num/g" $conf2

wpa_supplicant -Dnl80211 -i $interface -c $conf2 -Bd
