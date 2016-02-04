#!/bin/bash
# Title      : a2writabledirs.bash
# Description: List directories writable by Apache
# Author     : linuxitux
# Date       : 06-11-2014
# Usage      : ./a2writabledirs.bash SOURCE
# Notes      : -

# Apache user
A2USR="www-data"

if [ $# -lt 1 ]
then
  echo "Usage: $0 SOURCE"
  exit 1
fi

# Where to search (directory passes as argument)
WWWDIR=$1

echo "Directories writable by Apache:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# List all subdirectories
IFS="$(printf '\n\t')"
for DIR in $(find $WWWDIR -type d)
do
  # Check if $A2USR or "other" have write permissions through ACLs
  RW=$(getfacl $DIR 2>/dev/null | grep "$A2USR\|other" | grep "rw" | wc -l)
  # RW > 0 --> $A2USR and/or "other" have write access
  # RW = 0 --> neither $A2USR nor "other" have write access
  if [[ $RW -gt 0 ]]
  then
    #echo $DIR [SI]
    echo $DIR
  else
    echo $DIR [NO] > /dev/null
  fi

  # Now check if $A2USR is the owner and has write access through Unix permissions
  OWNED=$(getfacl $DIR 2>/dev/null | grep -e "owner.*$A2USR" | wc -l)
  if [[ $OWNED -gt 0 ]]
  then
    RW=$(getfacl $DIR 2>/dev/null | grep -e "user.*rw" | wc -l)
    if [[ $RW -gt 0 ]]
    then
      #echo $DIR [SI]
      echo $DIR
    else
      echo $DIR [NO] > /dev/null
    fi
  fi
done
