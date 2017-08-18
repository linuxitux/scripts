#!/bin/bash
# Title      : check_updates.bash
# Description: Notify about available updates
# Author     : linuxitux
# Date       : 11-12-2012
# Usage      : ./check_updates.bash
# Notes      : Edit mailto
# Notes      : Run this script every day if you want
#17 2 * * * root /root/scripts/check_updates.bash >> /var/log/check_updates.log 2>&1

DESTINATARIO="sysadmin@linuxito.com"
REMITENTE="Linuxito <root@linuxito.com>"
CLIENTE="/usr/bin/mail"
#CLIENTE="/root/scripts/mailgun-mta.sh --text"

SERVIDOR=$(hostname)

/usr/sbin/apt-get update > /dev/null 2>&1

ACTUALIZACIONES=$(/usr/bin/apt-get -s -q -u upgrade | grep Inst 2>/dev/null | sed -e 's/Inst //')

CANTIDAD=$(echo -n "$ACTUALIZACIONES" | wc -m)

if [ "$CANTIDAD" -gt 0 ]; then
  CANTIDAD=$(echo "$ACTUALIZACIONES" | wc -l)
  ASUNTO="Actualizaciones disponibles para ${SERVIDOR} (${CANTIDAD})"
  MENSAJE="Se encuentran disponibles las siguientes actualizaciones para el servidor ${SERVIDOR}:\n\n${ACTUALIZACIONES}"
  echo -e "${MENSAJE}" | $CLIENTE -s "${ASUNTO}" -r "${REMITENTE}" ${DESTINATARIO}
fi
