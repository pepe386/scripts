#!/bin/sh

#Script to stop the following services:
#  electrum personal server
#  monero
#  bitcoin
#  openvpn
#  delete dns server from /etc/resolv.conf
#  tor service

#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#stop electrum server
sudo kill $(ps -eo pid,cmd | grep electrum-personal-server | grep -v grep | awk '{print $1;}')

#stop monero node
cd /home/$PI_USER
cd monero*
./monerod --rpc-bind-port $MONERO_RPC_PORT --rpc-bind-ip 0.0.0.0 --rpc-login $MONERO_RPC_USER:$MONERO_RPC_PASS exit

#stop bitcoin node
cd /home/$PI_USER
cd bitcoin*
cd bin
./bitcoin-cli -rpcport=$BITCOIN_RPC_PORT -rpcuser=$BITCOIN_RPC_USER -rpcpassword=$BITCOIN_RPC_PASS stop

#stop openvpn
sudo /etc/init.d/openvpn stop

#reset dns
sudo rm -f /etc/resolv.conf

#stop tor
sudo systemctl stop tor
