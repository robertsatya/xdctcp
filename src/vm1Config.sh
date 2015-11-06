#!/bin/bash
#configure vm1 for ecn and dctcp
ifconfig eth0 192.168.0.100 up
sysctl net.ipv4.tcp_ecn=1
sysctl net.ipv4.tcp_congestion_control=dctcp

