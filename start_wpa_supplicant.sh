#!/bin/bash

vir1_if=wifi1
vir2_if=wifi2

node_num=${HOSTNAME:4:1}
echo $node_num

conf1=wpa1.conf
conf2=wpa2.conf
base_conf=example.conf

killall wpa_supplicant

sed "s/0a00/0a0$node_num/g" $base_conf > $conf1
sed -i "s/0a:00/0a:0$node_num/g" $conf1

sed "s/0a00/0b0$node_num/g" $base_conf > $conf2
sed -i "s/0a:00/0b:0$node_num/g" $conf2

wpa_supplicant -Dnl80211 -i $vir1_if -c $conf1 -Bd
wpa_supplicant -Dnl80211 -i $vir2_if -c $conf2 -Bd
