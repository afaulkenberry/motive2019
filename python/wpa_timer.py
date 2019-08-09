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

MAX_TIME = 28
DATA_FILE='data.txt'
wpas_ctrl = '/var/run/wpa_supplicant'

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


def timeFind(limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return timeFind()
        except:
            return "FAIL"
    else:
        wpas.request("P2P_FIND")
        while True:
            while mon.pending():
                ev = mon.recv()
                if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                    line=ev.split()[2]
                    line=line.split(':')
                    SSID="DIRECT-" + line[4] + line[5]
                    return SSID

def timeFindSocial(limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return timeFindSocial()
        except:
            return "FAIL"
    else:
        wpas.request("P2P_FIND type=social")
        while True:
            while mon.pending():
                ev = mon.recv()
                if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                    line=ev.split()[2]
                    line=line.split(':')
                    SSID="DIRECT-" + line[4] + line[5]
                    return SSID


def startGroup(): 
    print "starting group"
    print(wpas.request("P2P_GROUP_ADD persistent=0"))
    return "STARTED GROUP"

def findNetwork2(limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return findNetwork2()
        except:
            return startGroup()
    else:
        wpas.request("P2P_FIND type=social")
        wpas.request("P2P_FIND type=social")
        while True:
            while mon.pending():
                ev = mon.recv()
                if "group_capab=0x" in ev:
                    if "group_capab=0x0" in ev:
                        continue
                    if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                        line=ev.split()[2]
                        if "00:00:00:00:0a:01" in  ev: ## Prevent from connecting to the same group again, this should really be done dynamically
                            continue
                        line=line.split(':')
                        SSID="DIRECT-" + line[4] + line[5]
                        return SSID

def addNetwork(ssid):
    network_id=wpas.request("ADD_NETWORK").rstrip()
    command="SET_NETWORK " + network_id + " psk \"password\""
    print command
    print wpas.request(command)
    command="SET_NETWORK " + network_id + " ssid \"" + ssid + "\""
    print command
    print wpas.request(command)

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
            return False 
    else: 
        while True:
            while mon.pending():
                ev = mon.recv()
                if line in ev:
                    return ev

def main():

    global wlan_interface
    global mon
    global wpas
    
    scheme = sys.argv[1]
    wlan_interface = sys.argv[2]
    run_number = sys.argv[3]
    
    if len(sys.argv) < 4:
        print "please use #./wpa_timer.py {scheme} {interface}"
        exit(0)
    
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
    
    if "p2p_find_time_client" in scheme:
        SSID=timeFind(MAX_TIME)
        stopwatch = time.time()
        print run_number, "p2p_find_time_client", stopwatch, SSID
    
    elif "p2p_find_social_time_client" in scheme:
        SSID=timeFindSocial(MAX_TIME)
        stopwatch = time.time()
        print run_number, "p2p_find_social_time_client", stopwatch, SSID
    
    elif "p2p_find2_time_client" in scheme:
        startwatch = time.time()
        SSID=timeFind(MAX_TIME)
        stopwatch = time.time()
        print run_number, "p2p_find2_time_client", startwatch, stopwatch, SSID
    
    elif "p2p_find2_social_time_client" in scheme:
        startwatch = time.time()
        SSID=timeFindSocial(MAX_TIME)
        stopwatch = time.time()
        print run_number, "p2p_find2_social_time_client", startwatch, stopwatch, SSID

    elif "p2p_find_time_GO" in scheme:
        jitter = float(10)*float(eval("0x" + os.urandom(3).encode('hex'))%1000)/1000
        time.sleep(jitter)
        stopwatch = time.time()
        wpas.request("P2P_GROUP_ADD persistent=0")
        print run_number, "p2p_find_time_GO", stopwatch, jitter

    elif "wps_pbc" in scheme:
        mac_addr = sys.argv[4]
        my_command = "P2P_CONNECT " + mac_addr + " pbc join"
        print my_command
        tic = time.time()
        wpas.request(my_command)
        result = waitFor("CTRL-EVENT-CONNECTED", 10)
        if result:
            toc = time.time()
            print result
            stopwatch = toc-tic
            print run_number, "wps_pbc", stopwatch
    
    elif "psk_conn" in scheme:
        ssid = sys.argv[4]
        my_command = "SET_NETWORK 1 ssid \"" + ssid + "\""
        wpas.request("ADD_NETWORK")
        wpas.request("SET_NETWORK 1 psk \"password\"")
        wpas.request(my_command)
        print my_command 
        tic = time.time()
        wpas.request("ENABLE_NETWORK 1")
        wpas.request("RECONNECT")
        result = waitFor("CTRL-EVENT-CONNECTED", 10)
        if result:
            toc = time.time()
            print result
            stopwatch = toc-tic
            print run_number, "psk_conn", stopwatch
    
    elif "add_network" in scheme:
        print "adding network"
        addNetwork(run_number)
        exit(0)

#### Single interface recon schemes
    elif "random" in scheme:
        waitFor("CTRL-EVENT-DISCONNECTED")
        my_time = float(MAX_TIME)*float(eval("0x" + os.urandom(3).encode('hex'))%1000)/1000
        print "My time", my_time
        SSID=findNetwork2(my_time)
        if "GROUP" in SSID:
            print "I started a group"
        else:
            connectSSID(SSID)
        exit(0)
    
    elif "backup-go" in scheme:
        waitFor("CTRL-EVENT-DISCONNECTED")
        startGroup()
        exit(0)

    elif "backup-gm" in scheme:
        SSID=findNetwork2()
        connectSSID(SSID)
        exit(0)

    else:
        print "unknown scheme" 
        exit(0)
    
    exit(0)

if __name__ == "__main__":
    main()
