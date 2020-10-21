#!/bin/sh

#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#start electrum server
pid=$(ps -eo pid,cmd | grep electrum-personal-server | grep -v grep | awk '{print $1;}')
if [ "$pid" = ""  ] ; then
     /home/$PI_USER/.local/bin/electrum-personal-server $ELECTRUM_SERVER_CONFIG > /dev/null 2>&1 &
fi

