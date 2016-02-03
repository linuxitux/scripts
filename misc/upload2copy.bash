#!/bin/bash
# Title      : upload2copy.bash
# Description: Upload files to your copy.com account
# Author     : linuxitux
# Date       : 10-11-2015
# Usage      : ./upload2copy.bash SOURCE ...
# Notes      : Fill USER/PASS variables and edit COPY_BIN as needed

COPY_BIN="/usr/local/copy/x86_64/CopyCmd"
USER=""
PASS=""

if [ $# -lt 1 ]; then
  echo "Usage: $0 SOURCE ..."
  exit 1
fi

for F in "$@"; do
  $COPY_BIN Cloud -username=$USER -password=$PASS put $F /
done
