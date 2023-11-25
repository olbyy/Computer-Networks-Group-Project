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
$ns color 3 Orange
$ns color 4 Black
$ns color 5 Green
$ns color 6 Purple

#Open the nam trace file
set ntrace [open csmacd.tr w]
$ns trace-all $ntrace
set nf [open csmacd.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
	global ns ntrace nf
	$ns flush-trace
	#Close the trace file
	close $ntrace
	close $nf
	#Execute nam on the trace file
	exec nam csmacd.nam &
	exit 0
}

#Create two nodes
#n0
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
set n10 [$ns node]
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]


#Create a simplex link between the nodes
#sets the bandwidth, delay, and policy	
$ns simplex-link $n1 $n0 4Mb 100ms DropTail
$ns simplex-link $n3 $n2 4Mb 100ms DropTail
$ns simplex-link $n5 $n4 4Mb 100ms DropTail
$ns simplex-link $n7 $n6 4Mb 100ms DropTail
$ns simplex-link $n9 $n8 4Mb 100ms DropTail
$ns simplex-link $n11 $n10 4Mb 100ms DropTail


set lan [$ns newLan "$n0 $n2 $n4 $n6 $n8 $n10 $n12 $n13 $n14" 1Mb 40ms LL Queue/DropTail MAC/CSMA/CD Channel]

#orients the links between nodes format is from -> to
$ns simplex-link-op $n1 $n0 orient right
$ns simplex-link-op $n3 $n2 orient right
$ns simplex-link-op $n5 $n4 orient down-left
$ns simplex-link-op $n7 $n6 orient up-right
$ns simplex-link-op $n9 $n8 orient down-left
$ns simplex-link-op $n11 $n10 orient up-left

$ns simplex-link-op $n1 $n0 queuePos 0.5
$ns simplex-link-op $n3 $n2 queuePos 0.5
$ns simplex-link-op $n5 $n4 queuePos 0.5
$ns simplex-link-op $n7 $n6 queuePos 0.5
$ns simplex-link-op $n9 $n8 queuePos 0.5
$ns simplex-link-op $n11 $n10 queuePos 0.5

#Create a UDP agent and attach it to node n1
set udp1 [new Agent/UDP]
$udp1 set class_ 1
$ns attach-agent $n1 $udp1

#Create a UDP agent and attach it to node n3
set udp3 [new Agent/UDP]
$udp3 set class_ 2
$ns attach-agent $n3 $udp3

#Create a UDP agent and attach it to node n5
set udp5 [new Agent/UDP]
$udp5 set class_ 3
$ns attach-agent $n5 $udp5

#Create a UDP agent and attach it to node n7
set udp7 [new Agent/UDP]
$udp7 set class_ 4
$ns attach-agent $n7 $udp7

#Create a UDP agent and attach it to node n9
set udp9 [new Agent/UDP]
$udp9 set class_ 5
$ns attach-agent $n9 $udp9

#Create a UDP agent and attach it to node n11
set udp11 [new Agent/UDP]
$udp11 set class_ 6
$ns attach-agent $n11 $udp11

#Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set interval_ .05
$cbr1 attach-agent $udp1
$ns at 0.5 "$cbr1 start"

#Create a CBR traffic source and attach it to udp3
set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 1000
$cbr3 set interval_ .05
$cbr3 attach-agent $udp3
$ns at 10.5 "$cbr3 start"

#Create a CBR traffic source and attach it to udp5
set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 1000
$cbr5 set interval_ .05
$cbr5 attach-agent $udp5
$ns at 30.5 "$cbr5 start"

#Create a CBR traffic source and attach it to udp7
set cbr7 [new Application/Traffic/CBR]
$cbr7 set packetSize_ 1000
$cbr7 set interval_ .05
$cbr7 attach-agent $udp7
$ns at 45.5 "$cbr7 start"

#Create a CBR traffic source and attach it to udp9
set cbr9 [new Application/Traffic/CBR]
$cbr9 set packetSize_ 1000
$cbr9 set interval_ .05
$cbr9 attach-agent $udp9
$ns at 60.5 "$cbr9 start"

#Create a CBR traffic source and attach it to udp11
set cbr11 [new Application/Traffic/CBR]
$cbr11 set packetSize_ 1000
$cbr11 set interval_ .05
$cbr11 attach-agent $udp11
$ns at 75.5 "$cbr11 start"

#Create a Null agent (a traffic sink) and attach it to node n5
set null0 [new Agent/Null]
$ns attach-agent $n12 $null0

set null1 [new Agent/Null]
$ns attach-agent $n13 $null1

set null2 [new Agent/Null]
$ns attach-agent $n14 $null2

#Connect the traffic source with the traffic sink
$ns connect $udp1 $null0
$ns connect $udp3 $null1
$ns connect $udp5 $null2
$ns connect $udp7 $null0
$ns connect $udp9 $null1
$ns connect $udp11 $null2

#Schedule events for the CBR agents
$ns at 99.5 "$cbr1 stop"
$ns at 99.5 "$cbr3 stop"
$ns at 99.5 "$cbr5 stop"
$ns at 99.5 "$cbr7 stop"
$ns at 99.5 "$cbr9 stop"
$ns at 99.5 "$cbr11 stop"

#Call the finish procedure after 100 seconds of simulation time
$ns at 100.0 "finish"

#Run the simulation
$ns run
