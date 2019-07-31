#!/bin/bash

if [ $3 -eq 1 ]
then
	route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan$2
elif [ $3 -eq 2 ]
then
	route del -net 10.4.4.0 gw 0.0.0.0 netmask 255.255.255.0 dev wlan$2
fi
route
