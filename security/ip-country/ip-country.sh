#!/bin/sh
# Title      : ip-country.sh
# Description: Find country of an IP address
# Author     : linuxitux
# Date       : 26-05-2015
# Usage      : ./ipcountry [-v] IPADDRESS
# Notes      : -

# List of country codes
BASEDIR="$HOME/github/scripts/security/ip-country"
CCDB="$BASEDIR/cc.txt"

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
CC=$(echo "$IPINFO" | grep '"country"' | cut -d'"' -f4)
COUNTRY=$(grep -i ":$CC" $CCDB | cut -d':' -f1)

if [ "$1" = "-v" ]; then
  echo "IP: $2"
  echo "City: $CITY"
  echo "Country Code: $CC"
  echo "Country: $COUNTRY"
else
  echo "$COUNTRY"
fi
