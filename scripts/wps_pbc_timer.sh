#!/bin/bash

echo "*** Configuring"
ssh node2 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 p2p_find
ssh node1 wpa_cli -iwlan1 wps_pbc
sleep 5

ssh node2 wpa_cli -iwlan1 p2p_stop_find
sleep 2
echo "*** Starting Run $1"

ssh node2 ./motive2019/python/wpa_timer.py wps_pbc wlan1 $1 00:00:00:00:0a:01 
sleep 11
echo "*** Run Complete"

ssh node2 wpa_cli -iwlan1 flush
echo "*** 5 second cooldown"
sleep 5
echo "*** Exiting"
