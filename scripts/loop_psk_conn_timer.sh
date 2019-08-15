#!/bin/bash


ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush
ssh node1 wpa_cli -iwlan1 reconfigure
ssh node2 wpa_cli -iwlan1 reconfigure

ssh node1 wpa_cli -iwlan1 p2p_group_add persistent=0
sleep 5
ssh node1 wpa_cli -iwlan1 p2p_find
sleep 20

for i in `seq 1 $1`; do
    ssh node1 wpa_cli -iwlan1 p2p_group_add persistent=0
    sleep 10
    echo "**** RUN $i"
    echo "**** RUN $i" >> $2
    ./psk_conn_timer.sh $i >> $2 
    ssh node1 wpa_cli -iwlan1 flush
    ssh node1 wpa_cli -iwlan1 reconfigure
    echo "" >> $2
    echo "" >> $2
done
