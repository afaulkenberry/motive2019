#!/bin/bash

vir1_if=wlan1

node_num=${HOSTNAME:4:1}
echo $node_num

conf1=wpa1.conf
base_conf=example.conf

killall wpa_supplicant

sed "s/0a00/0a0$node_num/g" $base_conf > $conf1
sed -i "s/0a:00/0a:0$node_num/g" $conf1

wpa_supplicant -Dnl80211 -i $vir1_if -c $conf1 -Bd
