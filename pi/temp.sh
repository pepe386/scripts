#!/bin/sh

#load variables in .env file
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

#get pi temperature and store it in temp.txt file
vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*' > /home/$PI_USER/temp.txt
