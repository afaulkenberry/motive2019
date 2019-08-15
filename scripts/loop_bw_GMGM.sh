#!/bin/bash


interface=wlan1
goMAC=00:00:00:00:0a:01

ssh node1 wpa_cli -i$interface flush
ssh node2 wpa_cli -i$interface flush
ssh node6 wpa_cli -i$interface flush

ssh node1 wpa_cli -i$interface p2p_group_add
ssh node2 wpa_cli -i$interface p2p_find
ssh node6 wpa_cli -i$interface p2p_find

sleep 10
ssh node1 wpa_cli -i$interface wps_pbc
sleep 2
ssh node2 wpa_cli -i$interface p2p_connect $goMAC pbc join

sleep 10
ssh node1 wpa_cli -i$interface wps_pbc
sleep 2
ssh node6 wpa_cli -i$interface p2p_connect $goMAC pbc join
sleep 10

ssh node1 ifconfig $interface 10.0.0.1/24
ssh node2 ifconfig $interface 10.0.0.2/24
ssh node6 ifconfig $interface 10.0.0.3/24

for i in `seq 1 $1`; do
    echo "**** RUN $i"
    echo "**** RUN $i" >> $2
    ssh node2 iperf -s &
    sleep 2
    ssh node6 iperf -c 10.0.0.2 -t 30  >> $2
    sleep 2
    ssh node2 killall iperf
    sleep 30
    echo "" >> $2
    echo "" >> $2
done
