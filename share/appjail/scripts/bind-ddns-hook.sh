#!/bin/sh
# Author: Bruno Schwander
# parameter 1 passed by ajdns.sh is the host file with jails ip and names
#
# Configuration settings for bind-ddns-hook.sh in /etc/rc.conf
# appjail_dns_enable="YES"
# appjail_dns_hook="/usr/local/share/appjail/scripts/bind-ddns-hook.sh"
#
# appjail_dns_bind_ddns_keyfile (str)   : the full path to the DDNS key file for authenticating updates
#
# make sure to set parameters AUTO_NETWORK_NAME and HOST_DOMAIN in appjail.conf

. /etc/rc.subr
load_rc_config ${appjail_dns}

: ${appjail_dns_bind_ddns_keyfile:=/usr/local/etc/namedb/ddns-key}
: ${appjail_dns_hosts:=$1}

if [ ! -f ${appjail_dns_hosts}.prev ]
then
    touch ${appjail_dns_hosts}.prev
fi

# do nothing if host file has not changed
difflines=`diff -U0 ${appjail_dns_hosts}.prev ${appjail_dns_hosts}`
if [ -z "$difflines" ]
then
    exit 0
fi

deleted_lines=`diff -U0 ${appjail_dns_hosts}.prev ${appjail_dns_hosts} | grep -v '^---'| grep '^-' | sed 's/^-//' `
added_lines=`diff -U0 ${appjail_dns_hosts}.prev ${appjail_dns_hosts} | grep -v '^+++' | grep '^+' | sed 's/^+//' `

reverse_ip(){
    local jailip=$1
    local reverseip=${jailip##*.}
    local tmpip=$jailip
    for i in 1 2 3
    do
	    tmpip=${tmpip%.*}
	    reverseip=$reverseip.${tmpip##*.}
    done
    echo "$reverseip"
}

if [ "$deleted_lines" ]
then
    echo "$deleted_lines" | while read jailip jailname jailnamefqdn; do

        if [ $jailnamefqdn ]
        then
            jailname=$jailnamefqdn
        fi

        if [ "$jailip" ] && [ "$jailname" ]
        then
            reverseip=`reverse_ip $jailip`

            printf '%s\n' \
	               "update delete $jailname" \
	               "send" \
	               "update delete $reverseip.in-addr.arpa." \
	               "send" \
    	        | nsupdate -k $appjail_dns_bind_ddns_keyfile
        fi
    done
fi

if [ "$added_lines" ]
then
    echo "$added_lines" | while read jailip jailname jailnamefqdn; do

        if [ $jailnamefqdn ]
        then
            jailname=$jailnamefqdn
        fi

        if [ "$jailip" ] && [ "$jailname" ]
        then
            reverseip=`reverse_ip $jailip`

            printf '%s\n' \
	               "update add $jailname 3600 in a $jailip" \
	               "send" \
	               "update add $reverseip.in-addr.arpa. 3600 PTR $jailname" \
	               "send" \
                | nsupdate -k $appjail_dns_bind_ddns_keyfile
        fi
    done
fi

cp ${appjail_dns_hosts} ${appjail_dns_hosts}.prev
