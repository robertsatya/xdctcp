#!/bin/bash
#configure vm2 for ecn and dctcp
ifconfig eth0 192.168.0.200 up
sysctl net.ipv4.tcp_ecn=1
sysctl net.ipv4.tcp_congestion_control=dctcp
