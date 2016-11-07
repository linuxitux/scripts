#!/bin/sh
# Title      : ip-country.sh
# Description: Find country of an IP address
# Author     : linuxitux
# Date       : 26-05-2015
# Usage      : ./dnsscan.bash A.B.C [DELAY]
# Notes      : -

# List of country codes
CC="cc.txt"
# http://ipinfo.io/developers
IPINFO="ipinfo.io/"

case $# in
1)
  URL="$IPINFO$1"
  ;;
2)
  if [ "$1" = "-v" ]; then
    URL="$IPINFO$2"
  fi
  ;;
*)
  URL=""
  ;;
esac

if [ "$URL" = "" ]; then
  echo "Usage: $0 [OPTIONS] IPADDRESS"
  echo "OPTIONS:"
  echo "  -v: Increase verbosity level."
  exit 1
fi

IPINFO=$(curl $URL 2>/dev/null)
CITY=$(echo "$IPINFO" | grep '"city"' | cut -d'"' -f4)
COUNTRY=$(grep -i ":$(echo "$IPINFO" | grep '"country"' | cut -d'"' -f4)" $CC | cut -d':' -f1)

if [ "$1" = "-v" ]; then
  echo "IP: $2"
  echo "City: $CITY"
  echo "Country: $COUNTRY"
else
  echo "$COUNTRY"
fi
