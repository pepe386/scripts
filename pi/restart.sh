#!/bin/sh

#Script to restart the following services:
#  electrum personal server
#  monero
#  bitcoin
#  openvpn
#  tor service

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#stop services
/bin/sh $SCRIPTPATH/stop.sh
sleep 60

#start services
/bin/sh $SCRIPTPATH/start.sh
