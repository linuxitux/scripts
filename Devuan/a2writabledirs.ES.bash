#!/bin/bash
# Title      : a2writabledirs.bash
# Description: List directories writable by Apache
# Author     : linuxitux
# Date       : 06-11-2014
# Usage      : ./a2writabledirs.bash SOURCE
# Notes      : -

A2USR="www-data"

if [ $# -lt 1 ]
then
  echo "Uso: $0 FUENTE"
  exit 1
fi

# Directorio desde donde comenzar la búsqueda, pasado como parámetro
WWWDIR=$1

echo "Directorios donde Apache tiene escritura:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# Buscar directorios
IFS="$(printf '\n\t')"
for DIR in $(find $WWWDIR -type d)
do
  # Determinar si $A2USR u "other" tienen escritura a través de una ACL
  RW=$(getfacl $DIR 2>/dev/null | grep "$A2USR\|other" | grep "rw" | wc -l)
  # RW > 0 --> $A2USR y/u other tienen escritura
  # RW = 0 --> ni $A2USR ni other tienen escritura
  if [[ $RW -gt 0 ]]
  then
    #echo $DIR [SI]
    echo $DIR
  else
    echo $DIR [NO] > /dev/null
  fi

  # Determinar si $A2USR es el owner y tiene escritura (permisos Unix)
  OWNED=$(getfacl $DIR 2>/dev/null | grep -e "owner.*$A2USR" | wc -l)
  if [[ $OWNED -gt 0 ]]
  then
    RW=$(getfacl $DIR 2>/dev/null | grep -e "user.*rw" | wc -l)
    if [[ $RW -gt 0 ]]
    then
      #echo $DIR [SI]
      echo $DIR
    else
      echo $DIR [NO] > /dev/null
    fi
  fi
done
