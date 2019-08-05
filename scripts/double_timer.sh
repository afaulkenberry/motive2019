#!/bin/bash

echo "*** Configuring"
NODE1=node1
NODE2=node2
NODE3=node5
NODE4=node6

ssh $NODE1 wpa_cli -iwlan1 flush
ssh $NODE2 wpa_cli -iwlan1 flush
ssh $NODE3 wpa_cli -iwlan1 flush
ssh $NODE4 wpa_cli -iwlan1 flush

ssh $NODE1 wpa_cli -iwlan2 flush
ssh $NODE2 wpa_cli -iwlan2 flush
ssh $NODE3 wpa_cli -iwlan2 flush
ssh $NODE4 wpa_cli -iwlan2 flush

ssh $NODE1 wpa_cli -iwlan1 reconfigure   
ssh $NODE2 wpa_cli -iwlan1 reconfigure 
ssh $NODE3 wpa_cli -iwlan1 reconfigure 
ssh $NODE4 wpa_cli -iwlan1 reconfigure 

ssh $NODE1 wpa_cli -iwlan2 reconfigure 
ssh $NODE2 wpa_cli -iwlan2 reconfigure 
ssh $NODE3 wpa_cli -iwlan2 reconfigure 
ssh $NODE4 wpa_cli -iwlan2 reconfigure 

ssh $NODE1 wpa_cli -iwlan2 p2p_group_add
ssh $NODE2 wpa_cli -iwlan2 p2p_find
ssh $NODE3 wpa_cli -iwlan2 p2p_find
ssh $NODE4 wpa_cli -iwlan2 p2p_find

sleep 10
ssh $NODE1 wpa_cli -iwlan2 wps_pbc
ssh $NODE2 wpa_cli -iwlan2 p2p_connect 00:00:00:00:0b:01 pbc join
sleep 10
ssh $NODE1 wpa_cli -iwlan2 wps_pbc
ssh $NODE3 wpa_cli -iwlan2 p2p_connect 00:00:00:00:0b:01 pbc join
sleep 10
ssh $NODE1 wpa_cli -iwlan2 wps_pbc
ssh $NODE4 wpa_cli -iwlan2 p2p_connect 00:00:00:00:0b:01 pbc join

##################

ssh $NODE3 wpa_cli -iwlan1 p2p_group_add
ssh $NODE1 wpa_cli -iwlan1 p2p_find
ssh $NODE2 wpa_cli -iwlan1 p2p_find
ssh $NODE4 wpa_cli -iwlan1 p2p_find

sleep 10
ssh $NODE3 wpa_cli -iwlan1 wps_pbc
ssh $NODE1 wpa_cli -iwlan1 p2p_connect 00:00:00:00:0a:05 pbc join
sleep 10
ssh $NODE3 wpa_cli -iwlan1 wps_pbc
ssh $NODE2 wpa_cli -iwlan1 p2p_connect 00:00:00:00:0a:05 pbc join
sleep 10
ssh $NODE3 wpa_cli -iwlan1 wps_pbc
ssh $NODE4 wpa_cli -iwlan1 p2p_connect 00:00:00:00:0a:05 pbc join

sleep 10
#################

ssh $NODE1 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan1
ssh $NODE1 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan2

ssh $NODE2 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan1
ssh $NODE2 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan2

ssh $NODE3 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan1
ssh $NODE3 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan2

ssh $NODE4 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan1
ssh $NODE4 route add -net 10.4.4.0 netmask 255.255.255.0 dev wlan2

sleep 10
ssh $NODE2 killall iperf
ssh $NODE2 iperf -u -D -s
sleep 5
ssh $NODE4 iperf -u -b 96K -l 120 -t 20 -c 10.4.4.2 >> $1 &
sleep 10
ssh $NODE1 wpa_cli -iwlan2 p2p_group_remove wlan2
sleep 15
echo DONE
