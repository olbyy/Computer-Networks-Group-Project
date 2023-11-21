#CHANGED PACKET SIZE FORGOT TO DO IT


#This is the base of the program. It creates 8 nodes and moves them around. With UDP when a packet is sent the others trying to send continue to drop since the connection is active.
#When the nodes move out of range of each other whether sender(cbr) or reciever(sink), the packets are dropped.
#You can play around with it a little if you want, I just have it set up to where the cbr agent is sending to all at the same time with them moving a little.
#You can swap sending nodes and recieving nodes if yall want. -Dillon Olbrich

#Define Options
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         1000                       ;# max packet in ifq
set val(nn)             8                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(x)		500
set val(y)		500

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open wireless.tr w]
$ns_ trace-all $tracefd

set namfile [open wireless.nam w]
$ns_ namtrace-all-wireless $namfile $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel #1
set chan_1_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_1_ 

# node_(1) can also be created with the same configuration, or with a different
# channel specified.

for {set i 0} {$i < $val(nn) } {incr i} { # change nn val if you want more nodes when defining options
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;#disable random motion
}

#sets size of nodes to 20
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 20
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
# If adding a node make sure to set its X Y Z
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 30.0
$node_(1) set Y_ 30.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 30.0
$node_(2) set Y_ 10.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 20.0
$node_(3) set Y_ 50.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 20.0
$node_(4) set Y_ 26.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 22.0
$node_(5) set Y_ 19.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 19.0
$node_(6) set Y_ 44.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 40.0
$node_(7) set Y_ 10.0
$node_(7) set Z_ 0.0

#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
$ns_ at 3.0 "$node_(1) setdest 50.0 40.0 25.0"
$ns_ at 3.0 "$node_(0) setdest 48.0 38.0 5.0"


#Nodes then starts to move away from node 0
$ns_ at 10.0 "$node_(1) setdest 490.0 480.0 30.0" 
$ns_ at 20.0 "$node_(2) setdest 400.0 400.0 30.0" 
$ns_ at 30.0 "$node_(3) setdest 300.0 400.0 30.0" 
$ns_ at 40.0 "$node_(4) setdest 225.0 333.0 40.0" 
$ns_ at 50.0 "$node_(5) setdest 111.0 480.0 5.0" 
$ns_ at 60.0 "$node_(6) setdest 333.0 222.0 10.0" 
$ns_ at 70.0 "$node_(7) setdest 444.0 111.0 20.0"

#Nodes move back towards node 0
$ns_ at 45.0 "$node_(1) setdest 50.0 40.0 25.0"
$ns_ at 55.0 "$node_(2) setdest 50.0 40.0 25.0"
$ns_ at 65.0 "$node_(3) setdest 50.0 40.0 25.0"
$ns_ at 75.0 "$node_(4) setdest 50.0 40.0 25.0"
$ns_ at 85.0 "$node_(5) setdest 50.0 40.0 25.0"
$ns_ at 90.0 "$node_(6) setdest 50.0 40.0 25.0"
$ns_ at 90.0 "$node_(7) setdest 50.0 40.0 25.0"


# Setup traffic flow between nodes
# UDP connections between node_(0) and node_(1)

set udp [new Agent/UDP]
$udp set class_ 1
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(1) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"           #change start time if you want
#$ns_ at 3.0 "$cbr stop" 


# UDP connections between node_(0) and node_(2)

set udp [new Agent/UDP]
$udp set class_ 2
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(2) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"          #change start time if you want
#$ns_ at 3.0 "$cbr stop"  

# UDP connections between node_(0) and node_(3)

set udp [new Agent/UDP]
$udp set class_ 3
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(3) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"          #change start time if you want
#$ns_ at 3.0 "$cbr stop"  

## UDP connections between node_(0) and node_(4)

set udp [new Agent/UDP]
$udp set class_ 4
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(4) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"          #change start time if you want
#$ns_ at 3.0 "$cbr stop"  

## UDP connections between node_(0) and node_(5)

set udp [new Agent/UDP]
$udp set class_ 5
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(5) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"           #change start time if you want
#$ns_ at 3.0 "$cbr stop" 

# UDP connections between node_(0) and node_(6)

set udp [new Agent/UDP]
$udp set class_ 6
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(6) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"           #change start time if you want
#$ns_ at 3.0 "$cbr stop" 

# UDP connections between node_(0) and node_(7)

set udp [new Agent/UDP]
$udp set class_ 7
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $udp #sender
$ns_ attach-agent $node_(7) $null #reciever
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 3.0 "$cbr start"           #change start time if you want
#$ns_ at 3.0 "$cbr stop" 

#Remove comments if you want to see interaction between TCP
# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
#set tcp [new Agent/TCP]
#$tcp set class_ 2
#set sink [new Agent/TCPSink]
#$ns_ attach-agent $node_(0) $tcp #sender
#$ns_ attach-agent $node_(1) $sink #reciever
#$ns_ connect $tcp $sink
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#$ns_ at 3.0 "$ftp start" 


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 100.0 "$node_($i) reset";
}
$ns_ at 100.0 "stop"
$ns_ at 100.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namfile
    $ns_ flush-trace
    close $tracefd
    close $namfile
    exit 0
}

puts "Starting Simulation..."
$ns_ run
