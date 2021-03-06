#!/bin/bash

# script to run the simulation in simpleSimulation.tcl for various values of (g, dctcp_ns_, dctcp_nl_) triplets

q=2
s=5

cd sim1_1203
mkdir $q\_$s\_avg 
mkdir $q\_$s\_mytrace 
mkdir $q\_$s\_thr 
cd -
for g in 0.05 0.055 0.06 0.0625 0.065 0.07 0.075 0.08 0.085 0.09 0.095 0.1 0.105 0.11
do
    for ns in 0.1 0.2 0.3 0.4 0.5
    do
        for nl in 0.5 0.6 0.7 0.8 0.9 1.0
        do
            ns simpleSimulation.tcl $g $ns $nl $q $s 
            #mv queue.tr sim1_1123/queue\_$g\_$ns\_$nl.tr
            mv thrfile.tr sim1_1203/$q\_$s\_thr/thrfile\_$g\_$ns\_$nl.tr
            mv mytracefile.tr sim1_1203/$q\_$s\_mytrace/mytracefile\_$g\_$ns\_$nl.tr
            mv avgfile.tr sim1_1203/$q\_$s\_avg/avgfile\_$g\_$ns\_$nl.tr
        done
    done
done

