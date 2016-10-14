#!/bin/bash
# Title      : mysqlgrants.bash
# Description: Dump MySQL grants for all users
# Author     : linuxitux
# Date       : 13-10-2016
# Usage      : ./mysqlgrants.bash -u USER [OPTIONS]
# Notes      : -

MYSQL_USER=""
MYSQL_PASSWD=""

function print_help {
  echo "Dump MySQL grants for all users."
  echo
  echo "Usage: $0 -u USER [OPTIONS]"
  echo
  echo "  -u USER          User for login."
  echo
  echo "Options:"
  echo
  echo "  -h, --help       Show this help."
  echo "  -p               Ask for pasword."
  echo "  --all-privileges List users with all privileges on some database."
  echo "  --global         List users with some privilege on all databases."
  echo "  --root           List users with all privileges on all databases"
  echo "                   (same as --all-privileges --global)."
  echo
  exit
}

ALL_PRIVILEGES=0
PASSWD=0
GLOBAL=0

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -h|--help)
    HELP="yes"
    print_help
    ;;
    --all-privileges)
    ALL_PRIVILEGES=1
    ;;
    --global)
    GLOBAL=1
    ;;
    --root)
    GLOBAL=1
    ALL_PRIVILEGES=1
    ;;
    -u)
    MYSQL_USER=$2
    shift
    ;;
    -p)
    read -s -p "Enter password: " MYSQL_PASSWD
    echo
    PASSWD=1
    ;;
  esac
  shift
done

if [ "$MYSQL_USER" = "" ]
then
  print_help
fi

if [ $PASSWD -gt 0 ]
then
  ARGS="-u${MYSQL_USER} -p${MYSQL_PASSWD} --silent --skip-column-names --execute"
else
  ARGS="-u${MYSQL_USER} --silent --skip-column-names --execute"
fi

SQL_USERS="select concat('\'',User,'\'@\'',Host,'\'') from mysql.user"

DUMP=$(mysql $ARGS "$SQL_USERS" | sort | \
while read user; do
  SQL_GRANTS="show grants for ${user}"
  mysql $ARGS "$SQL_GRANTS" | sed 's/IDENTIFIED BY PASSWORD.*/IDENTIFIED BY PASSWORD xxxx/'
done)

if [ $ALL_PRIVILEGES -gt 0 ]
then
  DUMP=$((echo "USER#ALL PRIVILEGES ON"; echo "$DUMP" | grep "ALL PRIVILEGES" | awk '{print $7"#"$5}') | column -s "#" -t)
fi

if [ $GLOBAL -gt 0 ]
then
  DUMP=$(echo "$DUMP" | fgrep "*.*")
fi

echo "$DUMP"

