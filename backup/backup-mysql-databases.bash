#!/bin/bash
# Title      : backup-mysql-databases.bash
# Description: Dump and tar in a single file all MySQL databases
# Author     : linuxitux
# Date       : 21-06-2017
# Usage      : ./backup-mysql-databases.bash
# Notes      : -

MYUSER=backup
MYPASS=1234

ARGS="-u"$MYUSER" -p"$MYPASS" \
  --add-drop-database \
  --add-locks \
  --create-options \
  --complete-insert \
  --comments \
  --disable-keys \
  --dump-date \
  --extended-insert \
  --quick \
  --routines \
  --triggers \
  --ignore-table=mysql.event"

mysql -u$MYUSER -p$MYPASS -e 'show databases' | grep -Ev "(Database|information_schema|performance_schema)" > databases.list

while read DB
do
        DUMP="dump_"$DB".sql"
        echo -n $DUMP"... "
        mysqldump ${ARGS} $DB > $DUMP
        echo "OK."
done < databases.list

rm databases.list

tar czf databases.tar.gz dump_*.sql && rm dump_*.sql

