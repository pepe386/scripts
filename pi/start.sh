#!/bin/sh

#script to start the following services:
#  openvpn (rotate vpn servers)
#  set dns server in /etc/resolv.conf
#  iptables setup to only allow outgoing connections to vpn server
#  tor
#  monero
#  bitcoin
#  electrum personal server


#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#get info of vpn server to use
VPNS=$VPN_LIST
NUMBVPNS=$VPN_LIST_SIZE
i="$(cat /home/$PI_USER/VPN)"
VPN="$(echo ${VPNS} | cut -d',' -f$i)"
j=$(($i+1))
max=$(($NUMBVPNS+1))
if [ $j -eq $max ] ; then
     j=1
fi
echo $j > /home/$PI_USER/VPN

#start openvpn
sudo find /etc/openvpn/ -maxdepth 1 -type f -name "*.conf" -delete
sudo cp /etc/openvpn/$VPN.ovpn.to.ovpn /etc/openvpn/$VPN.ovpn.to.conf
sudo systemctl daemon-reload
sudo /etc/init.d/openvpn start
sleep 5
while ( ! ping -q -c 1 -W 1 8.8.8.8 >/dev/null ) ; do
     echo "IPv4 is down"
     i="$(cat /home/$PI_USER/VPN)"
     VPN="$(echo ${VPNS} | cut -d',' -f$i)"
     sudo find /etc/openvpn/ -maxdepth 1 -type f -name "*.conf" -delete
     sudo cp /etc/openvpn/$VPN.ovpn.to.ovpn /etc/openvpn/$VPN.ovpn.to.conf
     sudo systemctl daemon-reload
     sudo /etc/init.d/openvpn start
     j=$(($i+1))
     if [ $j -eq $max ] ; then
          j=1
     fi
     echo $j > /home/$PI_USER/VPN
     sleep 5
done

#start dns server and firewall setup
sudo rm -f /etc/resolv.conf
printf "nameserver 172.16.32.1\n" | sudo tee -a /etc/resolv.conf
sudo /root/iptables.sh
cat /etc/resolv.conf

#start tor
sudo systemctl stop tor
sudo systemctl start tor

#start monero daemon
sudo rm -f $BLOCKCHAINS_HDD/monero/$MONERO_P2P_PORT/p2pstate.bin
cd /home/$PI_USER
cd monero*
./monerod --block-sync-size 5 --data-dir $BLOCKCHAINS_HDD/monero --p2p-bind-port $MONERO_P2P_PORT --add-peer opennode.xmr-tw.org:18080 --p2p-external-port $MONERO_P2P_PORT --in-peers 8 --out-peers 8 --rpc-bind-port $MONERO_RPC_PORT --zmq-rpc-bind-port $MONERO_ZMQ_PORT --rpc-login $MONERO_RPC_USER:$MONERO_RPC_PASS --rpc-bind-ip 0.0.0.0 --confirm-external-bind --detach

#start bitcoin daemon
cd /home/$PI_USER
cd bitcoin*
cd bin
sg debian-tor -c 'sudo ./bitcoind -datadir=$BLOCKCHAINS_HDD/bitcoin -listenonion'

#start electrum server
sleep 60
pid=$(ps -eo pid,cmd | grep electrum-personal-server | grep -v grep | awk '{print $1;}')
if [ "$pid" = ""  ] ; then
     /home/$PI_USER/.local/bin/electrum-personal-server $ELECTRUM_SERVER_CONFIG > /dev/null 2>&1 &
fi
