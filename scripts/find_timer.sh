#!/bin/bash

echo "*** Configuring"
ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush
sleep 1
ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush

ssh node1 wpa_cli -iwlan1 reconfigure
ssh node2 wpa_cli -iwlan1 reconfigure

sleep 5
echo "*** Starting Run $1"

ssh node2 ./motive2019/python/wpa_timer.py p2p_find_time_client wlan1 $1 & 
ssh node1 ./motive2019/python/wpa_timer.py p2p_find_time_GO wlan1 $1 & 

sleep 30
echo "*** Run Complete"

ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush

echo "*** 20 second cooldown"
sleep 20
echo "*** Exiting"
