#!/bin/bash

./loop_bw_GMGM.sh 50 bw1.txt
sleep 200
./loop_bw_GMGO.sh 50 bw2.txt
sleep 200
./loop_bw_GOGM.sh 50 bw3.txt
