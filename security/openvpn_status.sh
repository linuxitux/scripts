#!/bin/sh
# Title      : openvpn_status.sh
# Description: List OpenVPN clients
# Author     : linuxitux
# Date       : 11-09-2018
# Usage      : ./openvpn_status.sh

#### Configuration #######################################
# WAIT   : Amount of seconds to wait for the client list #
# SYSLOG : OpenVPN daemon logs location                  #
#                                                        #
#  On (most) Linux systems:                              #
#  SYSLOG=/var/log/syslog                                #
#                                                        #
#  On OpenBSD systems:                                   #
#  SYSLOG=/var/log/messages                              #
##########################################################
WAIT=2
SYSLOG=/var/log/syslog

# Get openvpn daemon PID
OPENVPN_PID=$(ps -ax -o pid,command | grep "[o]penvpn --daemon" | cut -d' ' -f1)

if [ -z "$OPENVPN_PID" ]; then
  echo "Server not running?"
  exit 1
fi

# Get current datetime
OPENVPN_STATUS=$(date +%Y%m%d%H%M%S)

# Send starting message (flag) to syslog
logger "OpenVPN Server Status - $OPENVPN_STATUS"

# Signal openvpn daemon
kill -USR2 $OPENVPN_PID

# Wait x seconds
sleep $WAIT

# Recover openvpn log messages
grep -A 1000 $OPENVPN_STATUS $SYSLOG | grep -B 1000 'END'
