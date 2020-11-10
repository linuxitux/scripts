#!/bin/bash

# host to ping
TARGET="www.siteuptime.com"

# log file
LOG="/var/log/net_uptime.log"

# ping 3 packets every 2 seconds, wait 3 seconds maximum
PING=$(ping -n -c 3 -i 2 -W 3 $TARGET 2>&1)

if [[ $? != 0 ]]
then
	if [[ $PING =~ "loss" ]]
	then
		# no reply
		ERROR=$(echo "$PING" | grep 'loss')
	else
		# destination unreachable
		ERROR=$PING
	fi
	echo "$(date +%F\ %T) - Failed check - $ERROR" &>> $LOG
fi
