#!/bin/bash
# Title      : check_disk_space.bash
# Description: Send alert by email if disk is filling up
# Author     : linuxitux
# Date       : 27-05-2014
# Usage      : ./check_disk_space.bash
# Notes      : Edit limit & mailto
# Notes      : Run this script every hour if you want
#33 * * * * root /root/scripts/check_disk_space.bash >> /var/log/check_disk_space.log 2>&1

# Maximum allowed disk utilisation (in percentage)
LIMIT="90"

# Email address for the alerts
MAILTO="sysadmin@linuxito.com"
MAILER="/usr/bin/mail"

# Host name
HOST=$(hostname)

# Temp files
DF="/tmp/df.tmp"
MAIL="/tmp/mail.tmp"

# Disk usage on each device/partition (excluding temp filesystems)
df -P | grep "/dev" | grep -v "udev" | grep -v "tmpfs" > $DF

WARNING="no"

# Check if some value it's over the limit
while read DEV
do
  PERCENT=$(echo $DEV | awk '{print $5}' | sed -e 's/\%//')

  if [ $PERCENT -gt $LIMIT ]
  then
    # If some value it's over the limit, send an email alert
    WARNING="yes"
    echo $DEV | awk '{print "Device: "$1", mounted on: "$6", usage: "$5", available: "$4}' >> $MAIL
  fi
done < "$DF"

if [ $WARNING == "yes" ]
then
  SUBJECT="Disk filling up in ${HOST}"
  DETAIL=$(cat $MAIL)
  MESSAGE="There isn't enough free space in the following filesystems:\n\n${DETAIL}"
  echo -e "${MESSAGE}" | $MAILER -s "${SUBJECT}" ${MAILTO}
fi

# Delete temp files
rm $DF > /dev/null 2>&1
if [ $WARNING == "yes" ]; then rm $MAIL > /dev/null 2>&1; fi
