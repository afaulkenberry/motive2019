#!/bin/bash
INTERFACE=wlan1
SSID=DIRECT-0a01

NODE1=node1
NODE2=node2
NODE3=node3
NODE4=node4
NODE5=node5
NODE6=node6


rm -r old_res
mv res old_res
mkdir res

echo "*** Configuring"
ssh $NODE1 systemctl stop networking
ssh $NODE2 systemctl stop networking
ssh $NODE3 systemctl stop networking
ssh $NODE4 systemctl stop networking
ssh $NODE5 systemctl stop networking
ssh $NODE6 systemctl stop networking

ssh $NODE1 wpa_cli -i$INTERFACE flush
ssh $NODE2 wpa_cli -i$INTERFACE flush
ssh $NODE3 wpa_cli -i$INTERFACE flush
ssh $NODE4 wpa_cli -i$INTERFACE flush
ssh $NODE5 wpa_cli -i$INTERFACE flush
ssh $NODE6 wpa_cli -i$INTERFACE flush

ssh $NODE1 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE2 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE3 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE4 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE5 wpa_cli -i$INTERFACE reconfigure 
ssh $NODE6 wpa_cli -i$INTERFACE reconfigure 

ssh $NODE1 ifconfig $INTERFACE 10.2.2.1
ssh $NODE2 ifconfig $INTERFACE 10.2.2.2
ssh $NODE3 ifconfig $INTERFACE 10.2.2.3
ssh $NODE4 ifconfig $INTERFACE 10.2.2.4
ssh $NODE5 ifconfig $INTERFACE 10.2.2.5
ssh $NODE6 ifconfig $INTERFACE 10.2.2.6


sleep 5

echo "** Starting Run $1"

ssh $NODE1 wpa_cli -i$INTERFACE p2p_group_add persistent=0
sleep 3

ssh $NODE2 ./motive2019/python/wpa_timer.py add_network $INTERFACE $SSID
ssh $NODE2 wpa_cli -i$INTERFACE enable_network 1
ssh $NODE2 wpa_cli -i$INTERFACE reconnect


ssh $NODE3 ./motive2019/python/wpa_timer.py add_network $INTERFACE $SSID
ssh $NODE3 wpa_cli -i$INTERFACE enable_network 1
ssh $NODE3 wpa_cli -i$INTERFACE reconnect

ssh $NODE4 ./motive2019/python/wpa_timer.py add_network $INTERFACE $SSID
ssh $NODE4 wpa_cli -i$INTERFACE enable_network 1
ssh $NODE4 wpa_cli -i$INTERFACE reconnect

ssh $NODE5 ./motive2019/python/wpa_timer.py add_network $INTERFACE $SSID
ssh $NODE5 wpa_cli -i$INTERFACE enable_network 1
ssh $NODE5 wpa_cli -i$INTERFACE reconnect

ssh $NODE6 ./motive2019/python/wpa_timer.py add_network $INTERFACE $SSID
ssh $NODE6 wpa_cli -i$INTERFACE enable_network 1
ssh $NODE6 wpa_cli -i$INTERFACE reconnect
sleep 10
./outage_timer_short.sh 1 2 3 4 5 6 &
sleep 5
ssh node2 ./motive2019/python/wpa_timer.py backup-gm wlan1 1 &
ssh node4 ./motive2019/python/wpa_timer.py backup-gm wlan1 1 &
ssh node5 ./motive2019/python/wpa_timer.py backup-gm wlan1 1 &
ssh node6 ./motive2019/python/wpa_timer.py backup-gm wlan1 1 &
ssh node3 ./motive2019/python/wpa_timer.py backup-go wlan1 1 &
sleep 10
echo "removing node 1"
ssh node1 wpa_cli -iwlan1 p2p_group_remove wlan1

#ssh $NODE1 wpa_cli -i$INTERFACE p2p_group_remove $INTERFACE
sleep 40
echo "**Cleaning Up**"
cat res/* | grep -A1 Server | grep sec | rev | cut -d ' ' -f 3 | cut -d '/' -f 2 | rev | xargs | sed -e 's/ / /g' >> $1
ssh $NODE1 killall iperf
ssh $NODE2 killall iperf
ssh $NODE3 killall iperf
ssh $NODE4 killall iperf
ssh $NODE5 killall iperf
ssh $NODE6 killall iperf
