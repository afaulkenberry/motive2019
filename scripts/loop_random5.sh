#!/bin/bash
for i in `seq 1 $1`; do
    echo "**** RUN $i"
    ./outage_random5.sh $2
done
