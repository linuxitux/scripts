#!/bin/bash

SERVER=$(hostname)
MAILTO="seginfo@linuxito.com"
DIGEST=$(/root/scripts/modsec_audit-htmlparser.sh)

if [ "${DIGEST}" == "" ]; then
   exit 0
else
   SUBJECT="Resumen de ModSecurity para ${SERVER}"
   MSG="<p>Se han registrado los siguientes eventos en el log de auditor&iacute;a de ModSecurity en <b>${SERVER}</b>:</p>${DIGEST}"
   echo -e "${MSG}" | /usr/bin/bsd-mailx -a "Content-Type: text/html" -s "${SUBJECT}" ${MAILTO}
fi
