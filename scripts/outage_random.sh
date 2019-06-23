#!/bin/bash
INTERFACE=wlan1

NODE1=node1
NODE2=node2
NODE3=node3

mv res old_res
mkdir res

echo "*** Configuring"
ssh $NODE1 systemctl stop networking
ssh $NODE2 systemctl stop networking
ssh $NODE3 systemctl stop networking

ssh $NODE1 wpa_cli -i$INTERFACE flush
ssh $NODE2 wpa_cli -i$INTERFACE flush
ssh $NODE3 wpa_cli -i$INTERFACE flush

ssh $NODE1 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE2 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE3 wpa_cli -i$INTERFACE reconfigure 

ssh $NODE1 ifconfig $INTERFACE 10.2.2.4
ssh $NODE2 ifconfig $INTERFACE 10.2.2.5
ssh $NODE3 ifconfig $INTERFACE 10.2.2.6


sleep 5

echo "** Starting Run $1"

ssh $NODE1 wpa_cli -i$INTERFACE p2p_group_add persistent=0
sleep 3

ssh $NODE2 wpa_cli -i$INTERFACE add_network
ssh $NODE2 wpa_cli -i$INTERFACE set_network 1 psk "password"
ssh $NODE2 wpa_cli -i$INTERFACE set_network 1 ssid "DIRECT-0a01"
ssh $NODE2 enable_network 1


ssh $NODE3 wpa_cli -i$INTERFACE add_network
ssh $NODE3 wpa_cli -i$INTERFACE set_network 1 psk "password"
ssh $NODE3 wpa_cli -i$INTERFACE set_network 1 ssid "DIRECT-0a01"
ssh $NODE3 enable_network 1

sleep 5
./outage_timer.sh 1 2 3 &
sleep 30
ssh $NODE1 wpa_cli -i$INTERFACE p2p_group_remove $INTERFACE
