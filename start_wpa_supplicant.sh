#!/bin/bash

vir1_if=wifi1
vir2_if=wifi2

node_num=${HOSTNAME:4:1}

conf1=./wpa1.conf
conf2=./wpa2.conf

killall wpa_supplicant

sed "s/0a00/0a0$node_num/ ./$conf1"
sed "s/0a:00/0a:0$node_num/ ./$conf1"

sed "s/0b00/0b0$node_num/ ./$conf2"
sed "s/0b:00/0b:0$node_num/ ./$conf2"

wpa_supplicant -Dnl80211 -i $vir1_if -c $conf1 -Bd
wpa_supplicant -Dnl80211 -i $vir2_if -c $conf2 -Bd
