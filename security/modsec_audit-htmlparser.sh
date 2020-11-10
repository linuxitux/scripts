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
ID=""
DATE1=""
ADDRESS=""
HOST=""
REQUEST=""
MODSECMSG=""
PRINTHEADER="yes"
PRINTENDING="no"

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

  # Get datetime
  for DATE in $(cat $TMPFILE2 | cut -d']' -f1 | cut -d'[' -f2 | cut -d' ' -f1); do
    # Shorten datetime (strip year and second)
    DATE1=$(echo $DATE | cut -d':' -f1 | cut -d'/' -f1,2)
    TIME=$(echo $DATE | cut -d'/' -f3 | cut -d':' -f2,3)
    break
  done

  # Get source address
  for ADDR in $(cat $TMPFILE2 | cut -d']' -f2 | cut -d' ' -f3); do
    SOURCE=$ADDR
    break
  done

  #===========================#
  # Section B: request header #
  #===========================#

  # Extract host header and resource
  cat $TMPFILE1 | awk "/${ID}-F/{flag=0}flag;/${ID}-B/{flag=1}" > $TMPFILE2

  # Get host header
  for H in $(cat $TMPFILE2 | grep "Host:" | cut -d':' -f2); do
    HOST=$H
    break
  done

  # Get resource
  for RES in $(cat $TMPFILE2 | grep "^GET\|^HOST" | cut -d' ' -f2); do
    REQUEST=$RES
    break
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

  ### Commented out: pointless

  # Extract HTTP status code
  #cat $TMPFILE1 | awk "/${ID}-H/{flag=0}/${ID}-E/{flag=0}flag;/${ID}-F/{flag=1}" > $TMPFILE2

  # Get HTTP status code
  #for R in $(cat $TMPFILE2 | grep "^HTTP" | cut -d' ' -f2); do
  #  RET=$R
  #  break
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
  # Get msg and severity
  while read -r MSG; do

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
        MODSECMSG="$MODSECMSG<br>$TMPMSG ($SEVERITY)"
      fi
    fi
  done < $TMPFILE2

  # Print current lines (only if there are ModSecurity messages)

  if [ ! -z "$FLAG" ]; then

    if [ "$PRINTHEADER" == "yes" ]; then
      # Print table header
      echo -n '<table style="border:1px solid #666;border-collapse:collapse;width:100%;">'
      PRINTHEADER="no"
    else
      echo -n '<tr style="height: 10px;"></tr>'
    fi

    # Print event ID
    echo -n '<tr style="border:1px solid #666;"><td width="80px" style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Event ID</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$ID'</td></tr>'

    # Print event details
    echo -n '<tr style="border:1px solid #666;"><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Date</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$DATE1 $TIME'</td></tr>'
    echo -n '<tr style="border:1px solid #666;"><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Source IP</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$SOURCE'</td></tr>'
    echo -n '<tr style="border:1px solid #666;"><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Host</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$HOST'</td></tr>'
    echo -n '<tr style="border:1px solid #666;"><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Request</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$REQUEST'</td></tr>'

    # Print ModSecurity message
    echo -n '<tr style="border:1px solid #666;"><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">Message</td><td style="border:1px solid #666;text-align:left;vertical-align:top;background-color:#efefef;">'$MODSECMSG'</td></tr>'

    PRINTENDING="yes"

  fi

done

if [ "$PRINTENDING" == "yes" ]; then
  # Print table ending
  echo "</table><br>"
fi

# Cleanup
rm $TMPFILE0 $TMPFILE1 $TMPFILE2 >/dev/null 2>&1
