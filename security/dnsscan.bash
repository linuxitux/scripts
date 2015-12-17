#!/bin/bash
# Title      : dnsscan.bash
# Description: Get all host names for a class C network
# Author     : linuxitux
# Date       : 26-05-2015
# Usage      : ./dnsscan.bash A.B.C [DELAY]
# Notes      : -

if [ $# -lt 1 ]; then
  echo "Usage: $0 A.B.C [DELAY]"
  echo "  A.B.C: class C network specification"
  echo "  DELAY: seconds between requests (default 1)"
  echo "Examples:"
  echo "  $0 192.168.0 5"
  echo "  $0 10.6.140"
  exit 1
fi

NET=$1
SLEEP=1
if [ $# -gt 1 ]; then SLEEP=$2; fi
D=1

while [ $D -lt 255 ]; do
  echo -n "$NET.$D -- "
  host $NET.$D | cut -d' ' -f5
  sleep $SLEEP
  D=$((D+1))
done
