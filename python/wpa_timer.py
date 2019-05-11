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

MAX_TIME = 20
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
        #wpas.request("P2P_FIND type=social")
        wpas.request("P2P_FIND")
        while True:
            while mon.pending():
                ev = mon.recv()
                if "00:00:00:00:0a" in ev: ## this shouldnt be hard coded in but whatever
                    line=ev.split()[2]
                    line=line.split(':')
                    SSID="DIRECT-" + line[4] + line[5]
                    return SSID

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
        print SSID
        print "client run ", run_number, " ", time.time()

    elif "p2p_find_time_GO" in scheme:
        jitter = float(5)*float(eval("0x" + os.urandom(3).encode('hex'))%1000)/1000
        time.sleep(jitter)
        print "GO run ", run_number, " ", time.time()
        wpas.request("P2P_GROUP_ADD persistent=0")


    else:
        print "unknown scheme" 
        exit(0)
    
    exit(0)

if __name__ == "__main__":
    main()
