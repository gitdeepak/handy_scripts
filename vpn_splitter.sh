#! /bin/bash

#######################################################
### VPN Splitter ######################################
# Before using change networksetup line below to update 
# your corporate domains which need to go thru your 
# corporate VPN 
# Also if your home subnet is not 192.168. then change
# that below
#######################################################

# find ethernet zone.
OUTPUT=`/usr/sbin/system_profiler SPAirPortDataType | grep "Status: Connected"`
if [ "${OUTPUT}." == "." ]; then
    ETH_ZONE="Ethernet"
else
    ETH_ZONE="Wi-Fi"
fi

# find ethernet adapter.
OUTPUT=`ifconfig en2 | grep "netmask" | awk "{ print $2; }"`
if [ "${OUTPUT}." != "." ]; then
    ADAPTER="en2"
else
    OUTPUT=`ifconfig en1 | grep "netmask" | awk "{ print $2; }"`
    if [ "${OUTPUT}." != "." ]; then
        ADAPTER="en1"
    else
        ADAPTER="en0"
    fi
fi

# add EMC specific domains.
sudo networksetup -setsearchdomains "${ETH_ZONE}" <space separated list of domains corporate domain>

#if VPN from home, split traffic.
OUTPUT=`ifconfig | grep "192.168"`   # Change this if your using other subnet than default 192.168
if [ "$?" = "0" ]; then
    echo "splitting traffic"
   sudo route change default -interface ${ADAPTER}
   sudo route add 128.0.0.0/8 -interface utun0
   sudo route add 10.0.0.0/8 -interface utun0
   sudo route add 152.62.0.0 -interface utun0
   sudo route change 192.168.1.0/24 -interface ${ADAPTER}
   sudo route change 192.168.0.0/16 -interface ${ADAPTER}

    # disable firewall as it is set by cisco anyconnect.
    echo "Disabing firewall"
    sudo ipfw -f flush
    sudo ipfw disable firewall

    # display routing table.
    netstat -nr -f inet
fi

