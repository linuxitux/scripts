#!/bin/bash
# Title      : backup_files.bash
# Description: Backup file/directory passed as argument
# Author     : linuxitux
# Date       : 14-01-2016
# Usage      : ./backup_files.bash SOURCE
# Notes      : -

BKP_DIR="/backup"   # Where to place backups

if [ $# -lt 1 ]
then
  echo "Usage: $0 SOURCE"
  exit 1
fi

F=$(echo $1 | sed 's/\///g') # Strip slashes

DATE=$(date +%Y-%m-%d_%H%M%S)

tar cjf $BKP_DIR/${F}_$DATE.tar.bzip2 $1 2>/dev/null
