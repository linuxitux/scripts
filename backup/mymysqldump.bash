#!/bin/bash
# Title      : mymysqldump.bash
# Description: Dump and compress the MySQL database passed as argument
# Author     : linuxitux
# Date       : 14-01-2016
# Usage      : ./mymysqldump.bash DATABASE
# Notes      : Fill USER/PASS variables accordingly

BKP_DIR="/backup"   # Where to place database dumps
TMP_DIR="/tmp"      # Directory for temporary files
MY_USER="backup"    # Valid MySQL user
MY_PASS="****"      # User's Password

ARGS="-u$MY_USER -p$MY_PASS --add-drop-database --add-locks \
--create-options --complete-insert --comments --disable-keys \
--dump-date --extended-insert --quick --routines --triggers"

#--add-drop-database: Write a DROP DATABASE statement before each CREATE DATABASE statement.
#--add-locks: Surround each table dump with LOCK TABLES and UNLOCK TABLES statements.
#--create-options: Include all MySQL-specific table options in the CREATE TABLE statements.
#--complete-insert: Use complete INSERT statements that include column names.
#--comments: Write additional information in the dump file such as program version, server version, and host.
#--disable-keys: For each table, surround the INSERT statements with /*!40000 ALTER TABLE tbl_name DISABLE KEYS */; and /*!40000 ALTER TABLE tbl_name ENABLE KEYS */; statements.
#--dump-date: Date is added to the comment.
#--extended-insert: Write INSERT statements using multiple-row syntax that includes several VALUES lists.
#--quick: It forces mysqldump to retrieve rows for a table from the server a row at a time rather than retrieving the entire row set and buffering it in memory before writing it out.
#--routines: Include stored routines (procedures and functions) for the dumped databases in the output.
#--triggers: Include triggers for each dumped table in the output.

if [ $# -lt 1 ]
then
  echo "Usage: $0 DATABASE"
  exit 1
fi

DB=$1

/usr/bin/mysqldump ${ARGS} $DB > $TMP_DIR/$DB.sql

DATE=$(date +%Y-%m-%d_%H%M%S)

tar cjf $BKP_DIR/${DB}_$DATE.tar.bzip2 $TMP_DIR/$DB.sql 2>/dev/null

rm $TMP_DIR/$DB.sql
