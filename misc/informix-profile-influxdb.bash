#!/bin/bash
# Title      : informix-profile-influxdb.bash
# Description: Write onstat -p metrics into InfluxDB database
# Author     : linuxitux
# Date       : 01-11-2018
# Usage      : ./informix-profile-influxdb.bash
# Notes      : Run this script periodically.
#* * * * * /usr/local/bin/informix-profile-influxdb.bash

INFLUXDB_USER="informix"
INFLUXDB_PASS="1234"
INFLUXDB_URL="http://192.168.140.65:8086/write?db=collectd"

HOST=$(hostname)
MEASUREMENT="informix_value"

TAG="$MEASUREMENT,host=$HOST,type=profile"

ONSTAT_PROFILE=$(onstat -p | grep -v "^$" | awk '/Profile/{y=1;next}y' | sed 's/[[:space:]]*$//' | sed 's/ \{1,\}/,/g')

while read -r L1 && read -r L2; do
  IFS=',' read -r -a A1 <<< "$L1"
  IFS=',' read -r -a A2 <<< "$L2"

  for (( I=0; I<${#A1[@]}; I++ ));
  do
    echo "$TAG,type_instance=${A1[I]} value=${A2[I]}"
  done

done <<< "$ONSTAT_PROFILE" | curl -u $INFLUXDB_USER:$INFLUXDB_PASS -i -XPOST "$INFLUXDB_URL" --data-binary @- >/dev/null 2>&1 || exit 1

