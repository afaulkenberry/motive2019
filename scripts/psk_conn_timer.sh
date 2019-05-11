#!/bin/bash

echo "*** Configuring"
ssh node2 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 reconfigure

ssh node2 wpa_cli -iwlan1 p2p_find
sleep 5
ssh node2 wpa_cli -iwlan1 p2p_stop_find
sleep 2
echo "*** Starting Run $1"

ssh node2 ./motive2019/python/wpa_timer.py psk_conn wlan1 $1 DIRECT-0a01 
sleep 11
echo "*** Run Complete"

ssh node2 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 reconfigure
echo "*** 5 second cooldown"
sleep 5
echo "*** Exiting"
