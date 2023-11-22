#For right now I just have UDP agents sending through a que to different nodes in the lan.
#Packets are sent from the attached agents through a queue to a node in the lan
#Once the packet is recieved it is sent/broadcasted to entire lan.
#All packets are dropped from the nodes not recieving from agent. Not sure if intended.
#You can change the start/stop time of the cbr agent
#You can add more nodes to lan
#You can increase and decrease the bandwidth, delay and queue size.

#Lan Router set debug_ 1: if we want debug for lan router
LanRouter set debug_ 0

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
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]

#Create a duplex link between the nodes
#sets the bandwidth, delay, and policy	
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 4Mb 100ms DropTail
$ns duplex-link $n6 $n7 1Mb 10ms DropTail
$ns duplex-link $n7 $n3 4Mb 100ms DropTail
$ns duplex-link $n8 $n9 1Mb 10ms DropTail
$ns duplex-link $n9 $n4 4Mb 100ms DropTail

set lan [$ns newLan "$n2 $n3 $n4 $n5" 1Mb 40ms LL Queue/DropTail MAC/CSMA/CD Channel]

#orients the links between nodes format is from -> to
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n6 $n7 orient right
$ns duplex-link-op $n7 $n3 orient right
$ns duplex-link-op $n8 $n9 orient left
$ns duplex-link-op $n9 $n4 orient left

#Monitor the queue for the link between node 1 and node 2
#que limit 20 - increase will stop less packets dropping
$ns queue-limit $n1 $n2 20 
$ns duplex-link-op $n1 $n2 queuePos 0.5

#Monitor the queue for the link between node 7 and node 3
$ns queue-limit $n7 $n3 20 
$ns duplex-link-op $n7 $n3 queuePos 0.5

#Monitor the queue for the link between node 9 and node 4
$ns queue-limit $n9 $n4 20
$ns duplex-link-op $n9 $n4 queuePos 0.5

#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

#Create a UDP agent and attach it to node n6
set udp6 [new Agent/UDP]
$udp6 set class_ 2
$ns attach-agent $n6 $udp6

#Create a UDP agent and attach it to node n8
set udp8 [new Agent/UDP]
$udp8 set class_ 3
$ns attach-agent $n8 $udp8

#Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0
$ns at 0.5 "$cbr0 start"

#Create a CBR traffic source and attach it to udp6
set cbr6 [new Application/Traffic/CBR]
$cbr6 set packetSize_ 1000
$cbr6 set interval_ 0.005
$cbr6 attach-agent $udp6
$ns at 25.5 "$cbr6 start"

#Create a CBR traffic source and attach it to udp8
set cbr8 [new Application/Traffic/CBR]
$cbr8 set packetSize_ 1000
$cbr8 set interval_ 0.005
$cbr8 attach-agent $udp8
$ns at 50.5 "$cbr8 start"

#Create a Null agent (a traffic sink) and attach it to node n5
set null [new Agent/Null]
$ns attach-agent $n5 $null

#Connect the traffic source with the traffic sink
$ns connect $udp0 $null
$ns connect $udp6 $null
$ns connect $udp8 $null

#Schedule events for the CBR agents
$ns at 25.0 "$cbr0 stop"
$ns at 50.0 "$cbr6 stop"
$ns at 99.0 "$cbr8 stop"

#Call the finish procedure after 100 seconds of simulation time
$ns at 100.0 "finish"

#Run the simulation
$ns run
