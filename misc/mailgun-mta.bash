#!/bin/bash
# Title      : mailgun-mta.bash
# Description: Send mail through Mailgun API like "sendmail -t"
# Author     : linuxitux
# Date       : 04-08-2017
# Usage      : ./mailgun-mta.bash
# Notes      : This script reads mail headers and message body from stdin

APIKEY="api:key-XXXX" # YOUR MAILGUN API KEY
URL="https://api.mailgun.net/v3/XXXX/messages" # YOUR MAILGUN URL
LOG="/var/log/mailgun-mta.log"

MAILFROM="Linuxito <root@localhost.localdomain>"
MAILTO=""
SUBJECT="Default subject"
MIMETYPE="html"

# Parse arguments
#
#
#TODO

# If -t is set, read headers first
#
# To:
# From:
# Subject:
# (discard anything else)
#
while read LINE
do
  # Check if empty line (end of mail headers)
  [[ -z $LINE ]] && break

  # Test for "To:" header
  if [[ "$LINE" =~ "To:" ]]; then
    MAILTO=$(echo $LINE | cut -d':' -f2)
  fi

#  # Test for "From:" header
#  if [[ "$LINE" =~ "From:" ]]; then
#    MAILFROM=$(echo $LINE | cut -d':' -f2)
#  fi

  # Test for "Subject:" header
  if [[ "$LINE" =~ "Subject:" ]]; then
    SUBJECT=$(echo $LINE | cut -d':' -f2)
  fi
done

# Now comes the message body

# Send mail through Mailgun
curl -s --user $APIKEY $URL \
  -F from="$MAILFROM" \
  -F to="$MAILTO" \
  -F subject="$SUBJECT" \
  -F html="<-;type=$MIMETYPE" >> $LOG 2>&1
