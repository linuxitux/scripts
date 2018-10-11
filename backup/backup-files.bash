#!/bin/bash
# Title      : backup-files.bash
# Description: Backup file/directory passed as argument
# Author     : linuxitux
# Date       : 21-06-2017
# Usage      : ./backup-files.bash FILE/DIR
# Notes      : gzip version of backup_files.bash
# Notes      : Creates backup file on current directory

# Obtener el nombre del directorio/archivo a resguardar
if [ $# -lt 1 ]
then
  echo "uso: $0 DIR"
  exit -1
fi

# Eliminar las barras (/) del nombre
DIR=$1
DIR_C=$(echo $DIR | sed 's/\///g')

# Obtener la fecha y hora actual
DATE=$(date +%Y-%m-%d_%H%M%S)

# Comprimir y resguardar
echo -n "files_${DIR_C}_$DATE.tar.gz... "
tar czf files_${DIR_C}_$DATE.tar.gz $DIR 2>/dev/null
echo "OK."
