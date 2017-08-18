#!/bin/bash
# Title      : mailgun-mta.bash
# Description: Send mail through Mailgun API
# Author     : linuxitux
# Date       : 04-08-2017
# Usage      : ./mailgun-mta.bash
# Notes      : This script reads mail headers and message body from stdin using -t

APIKEY="api:key-XXXX" # YOUR MAILGUN API KEY
URL="https://api.mailgun.net/v3/XXXX/messages" # YOUR MAILGUN URL
LOG="/var/log/mailgun-mta.log"

MAILFROM="Linuxito <root@localhost.localdomain>"
MAILTO=""
SUBJECT=""
MIMETYPE="html"
HEADERS="no"
PLAINTEXT="no"

# If no arguments passed
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [-t] [-s SUBJECT] [-r FROM-ADDR] TO-ADDR"
  echo "Options: "
  echo "  -t The message to be sent is expected to contain message headers (To:, From:, or Subject:)."
  echo "  -s Message subject."
  echo "  -r From address."
  exit 1
fi

# Parse arguments
#
while [[ $# -gt 1 ]]; do
  KEY="$1"

  case $KEY in
    -s|--subject)
    SUBJECT="$2"
    shift # past argument
    ;;
    -r|--from-addr)
    MAILFROM="$2"
    shift # past argument
    ;;
    -t)
    HEADERS="yes"
    ;;
    --text)
    PLAINTEXT="yes"
    ;;
    *)
    # unknown option
    ;;
  esac
  shift # past argument or value
done

# Last argument is recipient (or -t if it's the only argument)
if [[ $# -gt 0 ]]; then
  MAILTO=$1
else
  if [[ "$HEADERS" = "no" ]]; then
    echo "Send options without primary recipient specified."
    echo "Usage: $0 [-t] [-s SUBJECT] [-r FROM-ADDR] TO-ADDR"
    exit 1
  fi
fi
if [[ "$MAILTO" = "-t" ]]; then
  HEADERS="yes"
fi

# If -t is set, read headers first
#
# To:
# From:
# Subject:
# (discard anything else)
#
if [[ "$HEADERS" = "yes" ]]; then

  while read LINE
  do
    # Check if empty line (end of mail headers)
    [[ -z $LINE ]] && break

    # Test for "To:" header
    if [[ "$LINE" =~ "To:" ]]; then
      MAILTO=$(echo $LINE | cut -d':' -f2)
    fi

    # Test for "From:" header
    if [[ "$LINE" =~ "From:" ]]; then
      MAILFROM=$(echo $LINE | cut -d':' -f2)
    fi

    # Test for "Subject:" header
    if [[ "$LINE" =~ "Subject:" ]]; then
      SUBJECT=$(echo $LINE | cut -d':' -f2)
    fi
  done

fi

# Now comes the message body

# Send mail through Mailgun API
if [[ "$PLAINTEXT" = "yes" ]]; then
  curl -s --user $APIKEY $URL \
    -F from="$MAILFROM" \
    -F to="$MAILTO" \
    -F subject="$SUBJECT" \
    -F text="<-" >> $LOG 2>&1
else
  curl -s --user $APIKEY $URL \
    -F from="$MAILFROM" \
    -F to="$MAILTO" \
    -F subject="$SUBJECT" \
    -F html="<-;type=$MIMETYPE" >> $LOG 2>&1
fi

