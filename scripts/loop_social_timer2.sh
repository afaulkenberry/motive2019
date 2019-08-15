#!/bin/bash

ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush
ssh node1 wpa_cli -iwlan1 reconfigure
ssh node1 wpa_cli -iwlan1 p2p_group_add
sleep 20

for i in `seq 1 $1`; do
    echo "**** RUN $i"
    echo "**** RUN $i" >> $2
    ./find_timer2_social.sh $i >> $2 
    echo "" >> $2
    echo "" >> $2
done
