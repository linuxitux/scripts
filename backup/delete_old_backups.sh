#!/bin/sh
# Title      : delete_old_backups.sh
# Description: Delete files older than x days
# Author     : linuxitux
# Date       : 10-10-2018
# Usage      : ./delete_old_backups.sh
# Notes      : -

# Directorios donde borrar archivos
DIRS="/backup/files/ /backup/databases/"

# Borrar archivos de más de x días
DAYS=60

echo "[$(date '+%Y-%m-%d %H:%M:%S')] inicio borrado de backups"

# Borrar del directorio local los archivos de más de $DAYS días
for D in $DIRS; do
  for F in $(find $D -type f -mtime +$DAYS 2>/dev/null); do
    echo "rm $F"
    rm $F
  done
done
