#!/bin/bash

./loop_bw_GMGM.sh 100 bw1.txt
sleep 600
./loop_bw_GMGO.sh 100 bw2.txt
sleep 600
./loop_bw_GOGM.sh 100 bw3.txt
