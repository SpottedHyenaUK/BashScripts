#!/bin/bash

if ! ifconfig | grep ppp0;
then
		#kill any stale pppd sessions
        sudo pkill pppd
        sleep 3
		#call the VPN again as normal
        sudo pppd call MyVPN
		#sleep to allow VPN to start
        sleep 5
fi
#check for route over VPN for local traffic
if ! route | grep 192.168.10.0;
then
		#add the routes required to get to remote netwokrs. 
        sudo route add -net 192.168.10.0 netmask 255.255.255.0 dev ppp0
fi
