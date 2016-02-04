#!/bin/bash
# Title      : mysql_check.bash
# Description: Check if mysqld is running and try to start it if not
# Author     : linuxitux
# Date       : 24-08-2015
# Usage      : ./mysqlcheck.bash
# Notes      : For example, you can run this every 10 minutes
#*/10 * * * * root /root/scripts/mysql_check.bash >> /var/log/mysql_check.log 2>&1

DATE=$(date +%Y-%m-%d_%H-%M-%S)
STATUS=$(/etc/init.d/mysql status 2>&1)
if [ $? -ne 0 ]; then
  echo "$DATE - $STATUS"
  echo "$DATE - Restarting MySQL..."
  /etc/init.d/mysql start
fi
