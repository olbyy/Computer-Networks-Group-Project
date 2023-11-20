#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file
set ntrace [open out.tr w]
$ns trace-all $ntrace
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
	global ns ntrace nf
	$ns flush-trace
	#Close the trace file
	close $ntrace
	close $nf
	#Execute nam on the trace file
	exec nam out.nam &
	exit 0
}

#Create two nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Create a duplex link between the nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

set lan [$ns newLan "$n2 $n3 $n4 $n5" 1Mb 40ms LL Queue/DropTail MAC/CSMA/CD Channel]

$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n1 $n2 orient right


#Monitor the queue for the link between node 2 and node 3
$ns queue-limit $n1 $n2 20
$ns duplex-link-op $n1 $n2 queuePos 0.5

#Create a UDP agent and attach it to node n0
set udp [new Agent/UDP]
$udp set class_ 1
$ns attach-agent $n0 $udp

#Create a CBR traffic source and attach it to udp
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000
$cbr set interval_ 0.005
$cbr attach-agent $udp

#Create a Null agent (a traffic sink) and attach it to node n5
set null [new Agent/Null]
$ns attach-agent $n5 $null

#Connect the traffic source with the traffic sink
$ns connect $udp $null

#Schedule events for the CBR agent
$ns at 0.5 "$cbr start"
$ns at 1.0 "$udp start"
$ns at 99.5 "$udp stop"
$ns at 100.0 "$cbr stop"

#Call the finish procedure after 100 seconds of simulation time
$ns at 100.0 "finish"

#Run the simulation
$ns run
