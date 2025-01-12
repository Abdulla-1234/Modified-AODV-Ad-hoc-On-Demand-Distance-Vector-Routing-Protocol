# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     6                          ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      1028                      ;# X dimension of topography
set val(y)      760                      ;# Y dimension of topography
set val(stop)   10.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open Team19.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open Team19.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
# Create 6 nodes
set n0 [$ns node]
$n0 set X_ 562
$n0 set Y_ 618
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 743
$n1 set Y_ 623
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 928
$n2 set Y_ 618
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 570
$n3 set Y_ 452
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 751
$n4 set Y_ 466
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 917
$n5 set Y_ 471
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20

#===================================
#        Generate movement          
#===================================
$ns at 2 "$n1 setdest 690 530 30"
$ns at 2 "$n5 setdest 780 660 30"

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

#Setup a UDP connection
set udp3 [new Agent/UDP]
$ns attach-agent $n3 $udp3
set null5 [new Agent/Null]
$ns attach-agent $n2 $null5
$ns connect $udp3 $null5
$udp3 set packetSize_ 800


#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

#Setup a CBR Application over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp3
$cbr1 set packetSize_ 800
$cbr1 set rate_ 1.0Mb
$cbr1 set random_ null
$ns at 4.0 "$cbr1 start"
$ns at 10.0 "$cbr1 stop"



#===================================
#        Labeling nodes        
#===================================
$ns at 0.0 "$n0 label Source1"
$ns at 0.0 "$n3 label Source2"
$ns at 0.0 "$n2 label Destination1"

#===================================
#        Set destinations
#===================================
$ns at 100.0 "$n5 setdest 385.0 228.0 5.0"
$ns at 60.0 "$n2 setdest 200.0 20.0 5.0"
$ns at 30.0 "$n3 setdest 115.0 85.0 5.0"
$ns at 45.0 "$n1 setdest 375.0 80.0 5.0"
$ns at 89.0 "$n4 setdest 167.0 351.0 5.0"
$ns at 78.0 "$n0 setdest 50.0 359.0 5.0"

#===================================
#        Color change during movement        
#===================================
$ns at 73.0 "$n2 delete-mark N2"
$ns at 73.0 "$n2 add-mark N2 pink circle"
$ns at 124.0 "$n3 delete-mark N11"
$ns at 124.0 "$n3 add-mark N11 purple circle"
$ns at 87.0 "$n4 delete-mark N26"
$ns at 87.0 "$n4 add-mark N26 yellow circle"
$ns at 92.0 "$n1 delete-mark N14"
$ns at 92.0 "$n1 add-mark N14 green circle"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam Team19.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
