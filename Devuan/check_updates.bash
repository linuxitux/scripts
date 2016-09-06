#!/bin/bash
# Title      : check_updates.bash
# Description: Notify about available updates
# Author     : linuxitux
# Date       : 11-12-2012
# Usage      : ./check_updates.bash
# Notes      : Edit mailto
# Notes      : Run this script every day if you want
#17 2 * * * root /root/scripts/check_updates.bash >> /var/log/check_updates.log 2>&1

LANG=C

MAILTO="sysadmin@linuxito.com"

HOST=$(hostname)

/usr/sbin/apt-get update > /dev/null 2>&1

UPDATES=$(/usr/bin/apt-get -s -q -u upgrade | grep Inst 2>/dev/null | sed -e 's/Inst //')

COUNT=$(echo "$UPDATES" | wc -l)

if [ "${COUNT}" == "0" ]; then
  exit 0
else
  SUBJECT="Updates available for ${HOST} (${COUNT})"
  MESSAGE="The following updates are available for ${HOST}:\n\n${UPDATES}"
  echo -e "${MESSAGE}" | /usr/bin/mail -s "${SUBJECT}" ${MAILTO}
fi
