#!/bin/bash
SUBNET="10.2.2."
OUTPUT="res/"

for node in "$@"
do
    ssh node$node killall iperf
done

sleep 5

for node in "$@"
do
    ssh node$node iperf -u -D -s
done

sleep 5


for node in "$@"
do
    for peer in "$@"
    do
        if [ "$peer" == "$node" ]; then 
            continue ## skip over use
        else 
            ssh node$node iperf -u -b 96K -l 120 -t 60 -c $SUBNET$peer >> $OUTPUT$node$peer.txt &
        fi 
    done
done 

sleep 70
echo "DONE"
