#!/usr/bin/python
#
# Based on Test script for wpaspy
# 2013, Jouni Malinen <j@w1.fi>
#
# This software may be distributed under the terms of the BSD license.
# See README for more details.

import os
import time
import random
import wpaspy
import sys
from timeout import timeout
import socket
import subprocess

MAX_TIME = 34.36
NUM_STA = 2
wpas_ctrl = '/var/run/wpa_supplicant'
LOOP_TIME = 0.1
DATA_FILE='data.txt'

def wpas_connect():
    ifaces = []
    if os.path.isdir(wpas_ctrl):
        try:
            ifaces = [os.path.join(wpas_ctrl, i) for i in os.listdir(wpas_ctrl)]
        except OSError, error:
            print "Could not find wpa_supplicant: ", error
            return None

    if len(ifaces) < 1:
        print "No wpa_supplicant control interface found"
        return None

    for ctrl in ifaces:
        if wlan_interface not in ctrl:
            continue
        try:
            wpas = wpaspy.Ctrl(ctrl)
            return wpas
        except Exception, e:
            pass
    return None


def checkStatus(status):
    if "mode=station" in status:
        status = "GM"
        print "I am a group member"
    elif "mode=P2P GO" in status:
        status = "GO"
        print "I am a group owner"
    else:
        status = "DIS"
        print "I am not in a group"


def startGroup(): 
    print "starting group"
    print(wpas.request("P2P_GROUP_ADD persistent=0"))
    status=wpas.request("STATUS").splitlines()
    for my_line in status:
        if "ssid=DIRECT" in my_line:
            GO_SSID=my_line.split("=")[1]
    return "STARTED GROUP " + GO_SSID

def findNetwork2(limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return findNetwork2()
        except:
            return startGroup()
    else:
        wpas.request("P2P_FIND type=social")
        while True:
            while mon.pending():
                ev = mon.recv()
                if "CTRL-EVENT-BSS-ADDED" in ev:
                    if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                        line=ev.split()[2]
                        if "00:00:00:00:0a:01" in  ev: ## Prevent from connecting to the same group again, this should really be done dynamically
                            continue
#                        if "FAIL" in wpas.request("P2P_PEER " + line):
#                            continue
                        line=line.split(':')
                        SSID="DIRECT-" + line[4] + line[5]
                        return SSID

def findNetworkID():
    max_id = 0
    peers_count = 3

    wpas.request("P2P_FLUSH")
    wpas.request("P2P_FIND type=social")
    while True:
        while mon.pending():
            ev = mon.recv()
            if "CTRL-EVENT-BSS-ADDED" in ev:
                if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                    line=ev.split()[2]
                    if "00:00:00:00:0a:01" in  ev: ## Prevent from connecting to the same group again, this should really be done dynamically
                        continue
#                    if "FAIL" in wpas.request("P2P_PEER " + line):
#                        continue
                    line=line.split(':')
                    SSID="DIRECT-" + line[4] + line[5]
                    return SSID
            
            elif "P2P-DEVICE-FOUND 00:00:00:00:0a" in ev:
                if "00:00:00:00:0a:01" in  ev: ## Prevent from connecting to the same group again, this should really be done dynamically
                    continue
                peers_count = peers_count + 1;
                peer_id = int(float(ev.split()[1].split(':')[5]))
                if max_id < peer_id:
                    max_id = peer_id
                if peers_count > num_sta:
                    if max_id < my_id:
                        return startGroup()
                    else:
                        SSID = "DIRECT-" + my_group + "0" + str(max_id) ## should format this as a 2 digit int but whatever
                        print SSID
                        return  SSID

                    

def connectSSID(SSID):
    net_num=wpas.request("ADD_NETWORK").split('\n')[0]
    print(net_num)
    REQUEST = "SET_NETWORK " + net_num + " ssid \"" + SSID + "\""
    print REQUEST
    print wpas.request(REQUEST)
    print wpas.request("SET_NETWORK " + net_num + " psk \"password\"")
    print "network set" 
    print wpas.request("ENABLE_NETWORK " + net_num)
    print "network enabled"
    print wpas.request("RECONNECT")
    waitFor("complete")
    print wpas.request("P2P_FLUSH")
    

def waitFor(line, limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return waitFor(line)
        except:
          #  return False
            return False 
    else: 
        while True:
            time.sleep(LOOP_TIME)
            while mon.pending():
                ev = mon.recv()
                if line in ev:
                    print ev
                    return ev


def main():

    global wlan_interface
    global num_sta 
    
    scheme = sys.argv[1]
    arg_2 = sys.argv[2]
    wlan_interface = sys.argv[3]
    
    max_time = MAX_TIME
    num_sta  = NUM_STA
    
    if len(sys.argv) > 4:
        if "random" in scheme:
            max_time = sys.argv[4]
        if "id" in scheme:
            num_sta = int(sys.argv[4])

    start_go = False
    if "GO" in arg_2:
        print "Im a be a group owner"
        start_go = True
    

    my_time = float(max_time)*float(eval("0x" + os.urandom(3).encode('hex'))%1000)/1000
    
    global mon
    global count
    global peers
    global wpas
    global DATA
    global my_group
    global my_id
    global last_go
   
    wpas = wpas_connect()
    if wpas is None:
        return
    mon = wpas_connect()
    print mon
    
    if mon is None:
        print "Could not open event monitor connection"
        return

    mon.attach()
    my_lines=wpas.request('STATUS').rsplit()
    my_group = '0'
    my_id = 0
    my_ip = "0"
    msg = "nobackup"
    
    for line in my_lines:
        if "p2p_device_address=00:00:00:00" in line:
            my_id = int(float(line.split(':')[5]))
            my_group = line.split(':')[4]
        if "ip_address" in line:
            my_ip = line.split('=')[1] 

    if "start" in scheme:
        print wpas.request('FLUSH')
        print wpas.request('RECONFIGURE')
        if "go" in arg_2:
            startGroup()
        else:
            connectSSID(arg_2)
        exit(0)
    
    if "send_backup" in scheme:
 	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock_addr = (arg_2, 3003)
	sock.connect(sock_addr)
	sock.sendall(b'backup')
	sock.close()
	exit(0)

#        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#        sock_addr = (arg_2, 3003)
#        sent = sock.sendto("backup", sock_addr)
#        sock.close()
#        exit(0)


    elif "send_nobackup" in scheme:
 	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock_addr = (arg_2, 3003)
	sock.connect(sock_addr)
	sock.sendall(b'nobackup')
	sock.close()
	exit(0)
#        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#        sock_addr = (arg_2, 3003)
#        sent = sock.sendto("nobackup", sock_addr)
#        sock.close()
#        exit(0)
    
    elif "listen_backup" in scheme:
 	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_addr = (my_ip, 3003)
	sock.bind(server_addr)
	sock.listen(1)
	conn, addr = sock.accept()
	msg = conn.recv(64)
	print msg	
	conn.close()
	sock.close()

	
	
#        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#        server_addr = (my_ip, 3003)
#        sock.bind(server_addr)
#        msg, addr = sock.recvfrom(64)
#        print msg
#        sock.close()


#AARON   waitFor("CTRL-EVENT-DISCONNECTED")
    dis_time = time.time()
    print wpas.request('FLUSH')
    print wpas.request('RECONFIGURE')

    SSID=""
    DATA=""
    
    if "random" in scheme: 
        SSID=findNetwork2(my_time)
        print SSID
        if "GROUP" in SSID:
            print "I started a group"
            DATA=arg_2 + " " + str(dis_time) + " " + str(my_time) + " 0 0 " + SSID.split()[2] + "\n"
        else:
            found_go_time = time.time()
            connectSSID(SSID)
            con_time = time.time()
            DATA=arg_2 + " " + str(dis_time) + " " + str(my_time) + " " + str(found_go_time) + " " + str(con_time) + " " + SSID + "\n"

    elif "id" in scheme:
        SSID=findNetworkID()
        if "GROUP" in SSID:
            go_time = time.time()
            print "I started a group"
            DATA=arg_2 + " " + str(dis_time) + " " + str(go_time) + " 0 " + SSID.split()[2] + "\n"
        else:
            found_go_time = time.time()
            connectSSID(SSID)
            con_time = time.time()
            DATA=arg_2 + " " + str(dis_time) + " " + str(found_go_time) + " " + str(con_time) + " " + SSID + "\n"
    

    elif "listen_backup" in scheme:
        if "nobackup" in msg:
            SSID=findNetwork2()
            print SSID
            found_go_time = time.time()
            connectSSID(SSID)
            con_time = time.time()
            DATA=arg_2 + " " + str(dis_time) + " " + str(found_go_time) + " " + str(con_time) + " " + SSID + "\n"
        else:
            startGroup()
            SSID="DIRECT-" + my_group + "0" + str(my_id)
            DATA=arg_2 + " " + str(dis_time)  + " " + " 0 0 " + SSID + "\n"


    if "GROUP" in SSID:
#        print "I started a group"
#        DATA=arg_2 + " " + str(dis_time) + " " + str(my_time) + " 0 0 " + SSID.split()[2] + "\n"
        
        my_file=open(DATA_FILE, "a+")
        my_file.write(DATA)
        my_file.close()
        exit(0)
    else:
        found_go_time = time.time()
        connectSSID(SSID) 
        con_time = time.time()
        
        my_file=open(DATA_FILE, "a+")
        my_file.write(DATA)
        my_file.close()
        exit(0)

#
if __name__ == "__main__":
    main()
