set N 8
set B 250
set K 65
set RTT 0.0001

set simulationTime 1.0

set query_flow_interval 0.001
set short_flow_interval 0.01

set startMeasurementTime 0
set stopMeasurementTime 1
set flowClassifyTime 0.001

set sourceAlg DC-TCP-Sack
set switchAlg RED
set lineRate 10Gb
set inputLineRate 11Gb

set DCTCP_g_ [expr [lindex $argv 0]]
set DCTCP_ns_ [expr [lindex $argv 1]]
set DCTCP_nl_ [expr [lindex $argv 2]]
set ackRatio 1 
set packetSize 1460

 
set traceSamplingInterval 0.0001
set throughputSamplingInterval 0.01
set enableNAM 0

set ns [new Simulator]

Agent/TCP set ecn_ 1
Agent/TCP set old_ecn_ 1
Agent/TCP set packetSize_ $packetSize
Agent/TCP/FullTcp set segsize_ $packetSize
Agent/TCP set window_ 1256
Agent/TCP set slow_start_restart_ false
Agent/TCP set tcpTick_ 0.01
Agent/TCP set minrto_ 0.2 ; # minRTO = 200ms
Agent/TCP set windowOption_ 0

Agent/TCPX set ecn_ 1
Agent/TCPX set old_ecn_ 1
Agent/TCPX set packetSize_ $packetSize
Agent/TCPX/FullTcpX set segsize_ $packetSize
Agent/TCPX set window_ 1256
Agent/TCPX set slow_start_restart_ false
Agent/TCPX set tcpTick_ 0.01
Agent/TCPX set minrto_ 0.2 ; # minRTO = 200ms
Agent/TCPX set windowOption_ 0


if {[string compare $sourceAlg "DC-TCP-Sack"] == 0} {
    Agent/TCP set dctcp_ true
    Agent/TCP set dctcp_g_ $DCTCP_g_;
    Agent/TCPX set dctcp_ true
    Agent/TCPX set dctcp_g_ $DCTCP_g_;
    Agent/TCPX set dctcp_ns_ $DCTCP_ns_;
    Agent/TCP set dctcp_nl_ $DCTCP_nl_;
}
Agent/TCP/FullTcp set segsperack_ $ackRatio; 
Agent/TCP/FullTcp set spa_thresh_ 3000;
Agent/TCP/FullTcp set interval_ 0.04 ; #delayed ACK interval = 40ms

Agent/TCPX/FullTcpX set segsperack_ $ackRatio; 
Agent/TCPX/FullTcpX set spa_thresh_ 3000;
Agent/TCPX/FullTcpX set interval_ 0.04 ; #delayed ACK interval = 40ms


Queue set limit_ 1000

Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ true
Queue/RED set mean_pktsize_ $packetSize
Queue/RED set setbit_ true
Queue/RED set gentle_ false
Queue/RED set q_weight_ 1.0
Queue/RED set mark_p_ 1.0
Queue/RED set thresh_ [expr $K]
Queue/RED set maxthresh_ [expr $K]
			 
DelayLink set avoidReordering_ true

if {$enableNAM != 0} {
    set namfile [open out.nam w]
    $ns namtrace-all $namfile
}

set mytracefile [open mytracefile.tr w]
set throughputfile [open thrfile.tr w]
set averagefile [open avgfile.tr w]

puts $averagefile "$DCTCP_g_ $DCTCP_ns_ $DCTCP_nl_"

proc finish {} {
        global ns enableNAM namfile mytracefile throughputfile averagefile
        $ns flush-trace
        classifyFlows
        close $mytracefile
        close $throughputfile
        close $averagefile
        if {$enableNAM != 0} {
	    close $namfile
	    exec nam out.nam &
	}
	exit 0
}

proc myTrace {file} {
    global ns N traceSamplingInterval tcp qfile MainLink nbow nclient packetSize enableBumpOnWire
    
    set now [$ns now]
    
    for {set i 0} {$i < $N} {incr i} {
	set cwnd($i) [$tcp($i) set cwnd_]
	set dctcp_alpha($i) [$tcp($i) set dctcp_alpha_]
    }
    
    $qfile instvar parrivals_ pdepartures_ pdrops_ bdepartures_
  
    puts -nonewline $file "$now $cwnd(0)"
    for {set i 1} {$i < $N} {incr i} {
	puts -nonewline $file " $cwnd($i)"
    }
    #for {set i 0} {$i < $N} {incr i} {
    #	puts -nonewline $file " $dctcp_alpha($i)"
    #}
 
    puts -nonewline $file " [expr $parrivals_-$pdepartures_-$pdrops_]"    
    puts $file " $pdrops_"
     
    $ns at [expr $now+$traceSamplingInterval] "myTrace $file"
}

for {set i 0} {$i < $N} {incr i} {
    set total_bytes_arrived($i) 0
}
proc throughputTrace {file} {
    global ns throughputSamplingInterval qfile flowstats N flowClassifyTime total_bytes_arrived

    set now [$ns now]
    
    $qfile instvar bdepartures_
    
    puts -nonewline $file "$now [expr $bdepartures_*8/$throughputSamplingInterval/1000000]"
    set bdepartures_ 0
    if {$now <= $flowClassifyTime} {
	for {set i 0} {$i < [expr $N-1]} {incr i} {
	    puts -nonewline $file " 0"
	}
	puts $file " 0"
    }

    if {$now > $flowClassifyTime} { 
	for {set i 5} {$i < [expr $N-1]} {incr i} {
	    $flowstats($i) instvar barrivals_
	    puts -nonewline $file " [expr $barrivals_*8/$throughputSamplingInterval/1000000]"
	    set total_bytes_arrived($i) [expr $total_bytes_arrived($i) + $barrivals_]
            set barrivals_ 0
	}
	$flowstats([expr $N-1]) instvar barrivals_
	puts $file " [expr $barrivals_*8/$throughputSamplingInterval/1000000]"
	set total_bytes_arrived(7) [expr $total_bytes_arrived(7) + $barrivals_]
        set barrivals_ 0
    }
    $ns at [expr $now+$throughputSamplingInterval] "throughputTrace $file"
}


$ns color 0 Red
$ns color 1 Orange
$ns color 2 Yellow
$ns color 3 Green
$ns color 4 Blue
$ns color 5 Violet
$ns color 6 Brown
$ns color 7 Black

for {set i 0} {$i < $N} {incr i} {
    set n($i) [$ns node]
}

set nqueue [$ns node]
set nclient [$ns node]


$nqueue color red
$nqueue shape box
$nclient color blue

for {set i 0} {$i < $N} {incr i} {
    $ns duplex-link $n($i) $nqueue $inputLineRate [expr $RTT/4] DropTail
    $ns duplex-link-op $n($i) $nqueue queuePos 0.25
}


$ns simplex-link $nqueue $nclient $lineRate [expr $RTT/4] $switchAlg
$ns simplex-link $nclient $nqueue $lineRate [expr $RTT/4] DropTail
$ns queue-limit $nqueue $nclient $B

$ns duplex-link-op $nqueue $nclient color "green"
$ns duplex-link-op $nqueue $nclient queuePos 0.25
set qfile [$ns monitor-queue $nqueue $nclient [open queue.tr w] $traceSamplingInterval]


for {set i 0} {$i < $N} {incr i} {
    if {[string compare $sourceAlg "Newreno"] == 0 || [string compare $sourceAlg "DC-TCP-Newreno"] == 0} {
	set tcp($i) [new Agent/TCP/Newreno]
	set sink($i) [new Agent/TCPSink]
    }
    if {[string compare $sourceAlg "Sack"] == 0 || [string compare $sourceAlg "DC-TCP-Sack"] == 0} { 
        if {$i < 5} {
        set tcp($i) [new Agent/TCPX/FullTcpX/SackX]
	      
        set sink($i) [new Agent/TCPX/FullTcpX/SackX]
        } else {
        set tcp($i) [new Agent/TCP/FullTcp/Sack]
        
        set sink($i) [new Agent/TCP/FullTcp/Sack]
        }
	$sink($i) listen
    }

    $ns attach-agent $n($i) $tcp($i)
    $ns attach-agent $nclient $sink($i)
    
    $tcp($i) set fid_ [expr $i]
    $sink($i) set fid_ [expr $i]

    $ns connect $tcp($i) $sink($i)       
}

for {set i 0} {$i < $N} {incr i} {
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)    
}

$ns at $traceSamplingInterval "myTrace $mytracefile"
$ns at $throughputSamplingInterval "throughputTrace $throughputfile"

set ru [new RandomVariable/Uniform]
$ru set min_ 0
$ru set max_ 1.0


set s_counter 0
proc short_flow {} {
    global N ftp ns simulationTime short_flow_interval s_counter
    set now [$ns now]
    for {set i 2} {$i < 5} {incr i} {
        $ns at [expr 0.05 + $s_counter * $short_flow_interval + $i * 0.005] "$ftp($i) send 512000"
    }
    incr s_counter
    $ns at [expr $now+$short_flow_interval] "short_flow"
}


set q_counter 0
proc query_flow {} {
    global N ftp ns simulationTime query_flow_interval q_counter
    set now [$ns now]
    for {set i 0} {$i < 2} {incr i} {
        $ns at [expr 0.05 + $q_counter*$query_flow_interval + $i * 0.005] "$ftp($i) send 10240"
    }
    incr q_counter
    $ns at [expr $now+$query_flow_interval] "query_flow"
}

for {set i 0} {$i < 5} {incr i} {
    $ns at 0.0 "$ftp($i) send 10000"
}

for {set i 5} {$i < $N} {incr i} {
    $ns at 0.0 "$ftp($i) send 10000"
    $ns at [expr $simulationTime * $i * 0.01] "$ftp($i) start"     
    $ns at [expr $simulationTime] "$ftp($i) stop"
}

query_flow
short_flow

global flowmon
set flowmon [$ns makeflowmon Fid]
set MainLink [$ns link $nqueue $nclient]

$ns attach-fmon $MainLink $flowmon

set fcl [$flowmon classifier]

$ns at $flowClassifyTime "classifyFlows"


set writeClassify 0
proc classifyFlows {} {
    global N fcl flowstats writeClassify averagefile total_bytes_arrived
    puts "NOW CLASSIFYING FLOWS"

    for {set i 0} {$i < $N} {incr i} {
	set flowstats($i) [$fcl lookup auto 0 0 $i]
        set delay_samples [$flowstats($i) get-delay-samples]
        set mean [$delay_samples mean]
        if {$writeClassify == 1} {
            puts $averagefile " $i $mean [expr $total_bytes_arrived($i)*8.0/1000000 ]"
        }
    }
    set writeClassify 1
} 


set startPacketCount 0
set stopPacketCount 0

proc startMeasurement {} {
global qfile startPacketCount
$qfile instvar pdepartures_   
set startPacketCount $pdepartures_
}

proc stopMeasurement {} {
global qfile startPacketCount stopPacketCount packetSize startMeasurementTime stopMeasurementTime simulationTime
$qfile instvar pdepartures_   
set stopPacketCount $pdepartures_
puts "Throughput = [expr ($stopPacketCount-$startPacketCount)/(1024.0*1024*($stopMeasurementTime-$startMeasurementTime))*$packetSize*8] Mbps"
}

$ns at $startMeasurementTime "startMeasurement"
$ns at $stopMeasurementTime "stopMeasurement"
                      
$ns at $simulationTime "finish"

$ns run
