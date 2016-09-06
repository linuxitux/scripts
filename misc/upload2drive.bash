#!/bin/bash
# Title      : upload2drive.bash
# Description: Upload your backup files to Google Drive
# Author     : linuxitux
# Date       : 14-07-2016
# Usage      : ./upload2drive.bash
# Notes      : Install drive first, see: github.com/odeke-em/drive
# Notes      : Run this script once a day.
#0 4 * * * sysadmin /home/sysadmin/bin/upload2drive.sh

# Configuration
# DAYS:
#  Number of days of backups to save in the cloud.
#  Google Drive gives you 15 GB of free storage currently.
#  Adjust this variable according to your backup daily size.
DAYS=60

# Working dirs
BACKUP_DIR="/backup"         # Where your backup files are stored
DRIVE_BASE_DIR="~/drive"     # Drive homedir location
DRIVE_BACKUP_DIR="backup"    # Drive folder for backups
DRIVE_DIR="$DRIVE_BASE_DIR/$DRIVE_BACKUP_DIR"

# Get current date (just in case needed)
DATE=$(date +%Y-%m-%d_%H%M%S)

# Copy backups from today/yesterday to Drive folder
for F in $(find $BACKUP_DIR -type f -mtime -1 2>/dev/null); do
        cp -n $F $DRIVE_DIR
done

# Delete backup copies older than $DAYS days
for F in $(find $DRIVE_DIR -type f -mtime +$DAYS 2>/dev/null); do
        rm $F
done

# Push changes to Google Drive quietly
cd $DRIVE_BASE_DIR
drive push -files -quiet $DRIVE_BACKUP_DIR
