#!/bin/bash

echo "*** Configuring"
ssh node2 wpa_cli -iwlan1 flush
sleep 1
ssh node2 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 reconfigure
sleep 10
echo "*** Starting Run $1"
ssh node2 ./motive2019/python/wpa_timer.py p2p_find2_time_client wlan1 $1 & 
sleep 22
ssh node2 wpa_cli -iwlan1 flush
sleep 10
echo "*** Run Complete"
echo "*** Exiting"
