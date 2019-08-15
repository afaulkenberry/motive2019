#!/bin/bash
for i in `seq 1 $1`; do
    echo "**** RUN $i"
    ./outage_backup5.sh $2
done
