#!/bin/bash

for i in `seq 1 $1`; do
    echo "**** RUN $i"
    echo "**** RUN $i" >> $2
    ./double_timer.sh $2  
    echo "" >> $2
    echo "" >> $2
done
