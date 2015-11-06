#!/bin/bash

#enable ECN and DCTCP
sysctl net.ipv4.tcp_ecn=1
sysctl net.ipv4.tcp_congestion_control=dctcp

#Create and configure a bridge with two virtual interfaces
ovs-vsctl add-br mybridge
ifconfig mybridge up
ifconfig wlan0 0
ovs-vsctl add-port mybridge wlan0
dhclient mybridge
ip tuntap add mode tap vport1
ip tuntap add mode tap vport2
ifconfig vport1 up
ifconfig vport2 up
ovs-vsctl add-port mybridge vport1
ovs-vsctl add-port mybridge vport2

#configure openVswitch ports for RED and ECN
tc qdisc add dev vport2 root handle 1:0 htb default 1
tc qdisc add dev vport1 root handle 1:0 htb default 1
tc class add dev vport1 parent 1:0 classid 1:1 htb rate 75Mbit burst 15k
tc class add dev vport2 parent 1:0 classid 1:1 htb rate 75Mbit burst 15k
tc qdisc add dev vport1 parent 1:1 handle 10: red limit 1000000 min 3000 max 3001 avpkt 1500 burst 2 bandwidth 75mbit probability 1 ecn
tc qdisc add dev vport2 parent 1:1 handle 10: red limit 1000000 min 3000 max 3001 avpkt 1500 burst 2 bandwidth 75mbit probability 1 ecn
tc qdisc add dev vport1 parent 10:1 handle 11: netem delay 0 limit 100000
tc qdisc add dev vport2 parent 10:1 handle 11: netem delay 0 limit 100000

