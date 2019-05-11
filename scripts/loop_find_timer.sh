#!/bin/bash


ssh node1 wpa_cli -iwlan1 flush
ssh node2 wpa_cli -iwlan1 flush
sleep 20

for i in `seq 1 $1`; do
    echo "**** RUN $i"
    echo "**** RUN $i" >> $2
    ./find_timer.sh $i >> $2 
    echo "" >> $2
    echo "" >> $2
done
