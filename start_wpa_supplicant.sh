#!/bin/bash

vir1_if=wifi1
vir2_if=wifi2

conf1=./wpa1.conf
conf2=./wpa2.conf

killall wpa_supplicant

wpa_supplicant -Dnl80211 -i $vir1_if -c $conf1 -Bd
wpa_supplicant -Dnl80211 -i $vir2_if -c $conf2 -Bd
