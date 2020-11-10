#!/bin/bash

#=============================================================================
# Title       : modsec_audit-parser.sh
# Description : Script to summarize/digest ModSecurity's audit log
# Author      : Emiliano Marini
# Date        : 2015-08-31
# Notes       : Assume section C not present in audit logs. Ignore E, I, J, K.
# Usage       : ./modsec_audit-parser.sh [LOGFILE]
#
# github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual#secauditlogparts
#=============================================================================

# Variables
LOG=/var/log/apache2/modsec_audit.log
LINES[0]=""
REQUESTS[0]=""
#MODSEC_MSG[0]=""
MODSECMSG=""

# Temporary files
TMPFILE0=/tmp/.modsec_audit-parse0.tmp
TMPFILE1=/tmp/.modsec_audit-parse1.tmp
TMPFILE2=/tmp/.modsec_audit-parse2.tmp

# Get today's date in the form "[d/m/Y:" (for example: "[07/Sep/2015:")
TODAY=$(date +\\[%d\\/%b\\/%Y:)
YESTERDAY=$(date --date="1 days ago" +\\[%d\\/%b\\/%Y:)

# Get today's events only
cat $LOG.1 $LOG | awk '/'${YESTERDAY}'/{flag=1}flag' > $TMPFILE0

# Get all event IDs
IDS=$(grep "^--" $TMPFILE0 | cut -d'-' -f3 | uniq)

# Process each ID
for ID in $IDS; do

  # Get lines related to current ID
  cat $TMPFILE0 | awk "/${ID}-A/{flag=1}/${ID}-Z/{flag=0}flag" > $TMPFILE1

  # IMPORTANT: some events can share the same ID

  #=============================#
  # Section A: audit log header #
  #=============================#

  # Extract datetime and source address
  cat $TMPFILE1 | awk "/${ID}-B/{flag=0}flag;/${ID}-A/{flag=1}" > $TMPFILE2

  INDEX=0
  # Print datetime
  for DATE in $(cat $TMPFILE2 | cut -d']' -f1 | cut -d'[' -f2 | cut -d' ' -f1); do
    # Shorten datetime (strip year and second)
    DATE1=$(echo $DATE | cut -d':' -f1 | cut -d'/' -f1,2)
    TIME=$(echo $DATE | cut -d'/' -f3 | cut -d':' -f2,3)
    LINES[$INDEX]=$(echo -n $ID" "$DATE1 $TIME)
    INDEX=$((INDEX+1))
  done

  # Save lines count
  NLINES=$INDEX

  INDEX=0
  # Print source address
  for ADDR in $(cat $TMPFILE2 | cut -d']' -f2 | cut -d' ' -f3); do
    LINES[$INDEX]=$(echo -n ${LINES[$INDEX]}" ["$ADDR"]")
    INDEX=$((INDEX+1))
  done

  # Each item in LINES contains an event for the current ID

  #===========================#
  # Section B: request header #
  #===========================#

  # Extract host header and resource
  cat $TMPFILE1 | awk "/${ID}-F/{flag=0}flag;/${ID}-B/{flag=1}" > $TMPFILE2

  INDEX=0
  # Print host header
  for HOST in $(cat $TMPFILE2 | grep "Host:" | cut -d':' -f2); do
    LINES[$INDEX]=$(echo -n ${LINES[$INDEX]} $HOST)
    INDEX=$((INDEX+1))
  done

  INDEX=0
  # Print resource
  for RES in $(cat $TMPFILE2 | grep "^GET\|^HOST" | cut -d' ' -f2); do
    #LINES[$INDEX]=$(echo -n ${LINES[$INDEX]}$RES)
    REQUESTS[$INDEX]=$RES
    INDEX=$((INDEX+1))
  done

  #===============================#
  # Section C: assume not present #
  #===============================#

  #============================#
  # Section D: not implemented #
  #============================#

  #==========================================================#
  # Section F: response headers (stop at H or E, if present) #
  #==========================================================#

  # Extract HTTP status code
  #cat $TMPFILE1 | awk "/${ID}-H/{flag=0}/${ID}-E/{flag=0}flag;/${ID}-F/{flag=1}" > $TMPFILE2

  # Commented out: pointless
  #INDEX=0
  # Print HTTP status code
  #for RET in $(cat $TMPFILE2 | grep "^HTTP" | cut -d' ' -f2); do
  #  LINES[$INDEX]=$(echo -n ${LINES[$INDEX]} $RET)
  #  INDEX=$((INDEX+1))
  #done

  #============================#
  # Section G: not implemented #
  #============================#

  #======================#
  # Section H: audit log #
  #======================#

  # Extract Apache's error msg and/or ModSecurity audit message (if any)
  cat $TMPFILE1 | awk "/${ID}-I/{flag=0}/${ID}-J/{flag=0}/${ID}-K/{flag=0}/${ID}-Z/{flag=0}flag;/${ID}-H/{flag=1}" | grep "^Message" > $TMPFILE2

  #COUNT=0
  FLAG=""
  MODSECMSG=""
  # Print msg and severity
  while read -r MSG; do
    #MODSEC_MSG[$COUNT]=$(echo $MSG | grep -o -P '(?<=msg ).*' | cut -d']' -f1 | cut -d'"' -f2)
    #SEVERITY=$(echo $MSG | grep -o -P '(?<=severity ).*' | cut -d']' -f1 | cut -d'"' -f2)
    #if [ ! -z "$SEVERITY" ]; then
    #  FLAG="1"
    #  MODSEC_MSG[$COUNT]=$(echo ${MODSEC_MSG[$COUNT]} "("$SEVERITY")")
    #fi
    #COUNT=$((COUNT+1))

    TMPMSG=$(echo $MSG | grep -o -P '(?<=msg ).*' | cut -d']' -f1 | cut -d'"' -f2)

    # If many events share the same ID, in this way (grepping all messages for the current ID)
    # it's not possible to relate messages to events, only messages to IDs

    # This block aggregates all messages in a single line (excluding duplicates)
    if [[ $MODSECMSG == "" ]]; then
      SEVERITY=$(echo $MSG | grep -o -P '(?<=severity ).*' | cut -d']' -f1 | cut -d'"' -f2)
      if [ ! -z "$SEVERITY" ]; then
        FLAG="1"
        MODSECMSG="$TMPMSG ($SEVERITY)"
      fi
    elif [[ $MODSECMSG != *"$TMPMSG"* ]]; then
      SEVERITY=$(echo $MSG | grep -o -P '(?<=severity ).*' | cut -d']' -f1 | cut -d'"' -f2)
      if [ ! -z "$SEVERITY" ]; then
        FLAG="1"
        MODSECMSG="$MODSECMSG / $TMPMSG ($SEVERITY)"
      fi
    fi
  done < $TMPFILE2

  # Print current lines (only if there are ModSecurity messages)
  if [ ! -z "$FLAG" ]; then
    #AUX=0
    #while [ $AUX -lt $NLINES ]; do
    #  echo ${LINES[$AUX]}
    #  AUX=$((AUX+1))
    #done

    # Show only the first event for the current ID
    echo "${LINES[0]]}"

    #AUX=0
    #while [ $AUX -lt $COUNT ]; do
    #  echo "$ID " ${MODSEC_MSG[$AUX]}
    #  AUX=$((AUX+1))
    #done

    # Show all ModSecurity messages for the current ID (every events)
    echo $ID $MODSECMSG

    # Show only the first request for the current ID
    echo $ID ${REQUESTS[0]}

    echo
  fi

  # Forget about LINES and MODSEC_MSG
  unset LINES
  unset REQUESTS
  #unset MODSEC_MSG

done

# Cleanup
rm $TMPFILE0 $TMPFILE1 $TMPFILE2 >/dev/null 2>&1
