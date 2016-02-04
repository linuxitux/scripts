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

SERVIDOR=$(hostname)

/usr/sbin/apt-get update > /dev/null 2>&1

ACTUALIZACIONES=$(/usr/bin/apt-get -s -q -u upgrade | grep -v '\.\.\.' | grep -v ':' | grep -v 'Inst ' | grep -v 'Conf ')

CANTIDAD=$(/usr/bin/apt-get -s -q -u upgrade | grep -v '\.\.\.' | grep -v ':' | grep -v 'Inst ' | grep -v 'Conf ' | grep "upgraded" | cut -d ' ' -f 1)

if [ "${CANTIDAD}" == "0" ]; then
   exit 0
else
  ASUNTO="Actualizaciones disponibles para ${SERVIDOR} (${CANTIDAD})"
  MENSAJE="Se encuentran disponibles las siguientes actualizaciones para el servidor ${SERVIDOR}:\n\n${ACTUALIZACIONES}"
  echo -e "${MENSAJE}" | /usr/bin/mail -s "${ASUNTO}" ${DESTINATARIO}
fi
