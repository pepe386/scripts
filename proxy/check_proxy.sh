#!/bin/bash

#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#check ipv6 address
zm_ipv6=$(cat $HOME/zm_ipv6.txt)
#echo $zm_ipv6

#if ipv6 changed, kill socat and restart
zm_ipv6_new=$(dig +short -6 $URL aaaa @resolver1.opendns.com)
#echo $zm_ipv6_new
if [ $zm_ipv6 != $zm_ipv6_new ]
then
    #echo "Restarting socat"
    killall socat
    nohup socat TCP4-LISTEN:80,fork,su=nobody TCP6:[$zm_ipv6_new]:80 > /dev/null 2>&1 &
    nohup socat TCP4-LISTEN:443,fork,su=nobody TCP6:[$zm_ipv6_new]:443 > /dev/null 2>&1 &
    echo $zm_ipv6_new > $HOME/zm_ipv6.txt
    sleep 5
fi

#if proxy is dead, restart it
if  nc -zv 127.0.0.1 80 &> /dev/null
then
    echo "Port 80 open"
else
    #echo "Nothing listening on port 80..."
    #restart socat proxy
    nohup socat TCP4-LISTEN:80,fork,su=nobody TCP6:[$zm_ipv6_new]:80 > /dev/null 2>&1 &
fi

if nc -zv 127.0.0.1 443 &> /dev/null
then
    echo "Port 443 open"
else
    #echo "Nothing listening on port 443..."
    #restart socat proxy
    nohup socat TCP4-LISTEN:443,fork,su=nobody TCP6:[$zm_ipv6_new]:443 > /dev/null 2>&1 &
fi
