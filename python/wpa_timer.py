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

def time_find(limit=None):
    if limit:
        try:
            with timeout(seconds=limit):
                return findNetwork2()
        except:
            return "FAIL"
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
                        line=line.split(':')
                        SSID="DIRECT-" + line[4] + line[5]
                        return SSID

def main():

    global wlan_interface
    global mon
    global wpas
    
    scheme = sys.argv[1]
    wlan_interface = sys.argv[2]
    
    if len(sys.argv) < 3:
        print "please use #./python_time.py {scheme} {interface}"
        exit(0)
    
    max_time = float(MAX_TIME)*float(eval("0x" + os.urandom(3).encode('hex'))%1000)/1000
    
   
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
    
    if "p2p_find_time" in scheme:
        SSID=findNetwork2(my_time)
        print SSID
    else:
        print "unknown scheme" 
        exit(0)

if __name__ == "__main__":
    main()
