#!/bin/sh

#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#get free disk space of hd with blockchains
df -k --output=avail,target | grep blkchains | awk '{print $1;}' > /home/$PI_USER/disk_space.txt
