set ns [new Simulator]
set nf [open o.nam w]
$ns namtrace-all $nf
$ns color 0 blue
$ns color 1 red
$ns color 2 yellow
$ns color 3 green
set f0 [open tcp1.tr w]
set f1 [open tcp2.tr w]
set f2 [open udp1.tr w]
set f3 [open udp2.tr w]

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
$n0 color "Blue"
$n1 color "Blue"
$n7 color "Blue"
$n3 color "Red"
$n4 color "yellow"
$n8 color "Red"
$n9 color "yellow"

$ns duplex-link $n0 $n2 20Mb 10ms DropTail
$ns duplex-link $n1 $n2 20Mb 10ms DropTail
$ns duplex-link $n2 $n6 20Mb 10ms DropTail
$ns duplex-link $n3 $n5 20Mb 10ms DropTail
$ns duplex-link $n4 $n5 20Mb 10ms DropTail
$ns duplex-link $n5 $n6 20Mb 10ms DropTail
$ns duplex-link $n6 $n7 20Mb 10ms DropTail
$ns duplex-link $n6 $n8 20Mb 10ms DropTail
$ns duplex-link $n6 $n9 20Mb 10ms DropTail

set tcpn0 [new Agent/TCP]
$ns attach-agent $n0 $tcpn0
$tcpn0 set fid_ 0
set tcpn1 [new Agent/TCP]
$ns attach-agent $n1 $tcpn1
$tcpn1 set fid_ 1
set ftpn0 [new Application/FTP]
$ftpn0 attach-agent $tcpn0

set ftpn1 [new Application/FTP]
$ftpn1 attach-agent $tcpn1

set nulltcpn0 [new Agent/TCPSink]
$ns attach-agent $n7 $nulltcpn0
set nulltcpn1 [new Agent/TCPSink]
$ns attach-agent $n7 $nulltcpn1

#udp connections
set udpn3 [new Agent/UDP]
$ns attach-agent $n3 $udpn3
$udpn3 set fid_ 2

set udpn4 [new Agent/UDP]
$ns attach-agent $n4 $udpn4
$udpn4 set fid_ 3

set cbrn3 [new Application/Traffic/CBR]
$cbrn3 attach-agent $udpn3
$cbrn3 set packet_size_ 1000
set cbrn4 [new Application/Traffic/CBR]
$cbrn4 attach-agent $udpn4
$cbrn4 set packet_size_ 1000

set nulludpn3 [new Agent/LossMonitor]
$ns attach-agent $n8 $nulludpn3

set nulludpn4 [new Agent/LossMonitor]
$ns attach-agent $n9 $nulludpn4

$ns connect $tcpn0 $nulltcpn0
$ns connect $tcpn1 $nulltcpn1
$ns connect $udpn3 $nulludpn3
$ns connect $udpn4 $nulludpn4

proc traffic {} {
	global nulltcpn0 nulltcpn1 nulludpn3 nulludpn4 f0 f1 f2 f3
	set ns [Simulator instance]
	set time 1.0
	set bw0 [$nulltcpn0 set bytes_]
	set bw1 [$nulltcpn1 set bytes_]
	set bw2 [$nulludpn3 set bytes_]
	set bw3 [$nulludpn4 set bytes_]
	set now [$ns now]
	puts $f0 "$now [expr $bw0/$time*8/1000000]"
	puts $f1 "$now [expr $bw1/$time*8/1000000]"
	puts $f2 "$now [expr $bw2/$time*8/1000000]"
	puts $f3 "$now [expr $bw3/$time*8/1000000]"
	$nulltcpn0 set bytes_ 0
	$nulltcpn1 set bytes_ 0
	$nulludpn3 set bytes_ 0
	$nulludpn4 set bytes_ 0
	$ns at [expr $now+$time] "traffic"
}
proc finish {} {
	global ns nf f0 f1 f2 f3
	close $nf
	close $f0
	close $f1
	close $f2
	close $f3
	exec nam o.nam &
	exec xgraph tcp1.tr tcp2.tr udp1.tr udp2.tr -geometry 700x400 &	
	exit 0
}
$ns at 0.0 "traffic"
$ns at 1.0 "$ftpn0 start"
$ns at 4.0 "$ftpn0 stop"
$ns at 4.1 "$ftpn1 start"
$ns at 8.0 "$ftpn1 stop"
$ns at 8.1 "$cbrn3 start"
$ns at 12.0 "$cbrn3 stop"
$ns at 12.1 "$cbrn4 start"
$ns at 16.0 "$cbrn4 stop"

$ns at 20.0 "finish"
$ns run
