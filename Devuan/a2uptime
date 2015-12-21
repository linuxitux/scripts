#!/bin/bash
# Title      : a2uptime.bash
# Description: Dump apache2 uptime
# Author     : linuxitux
# Date       : 21-12-2015
# Usage      : ./a2uptime.bash
# Notes      : -

A2PID=$(ps axo pid,cmd,user | grep apache2 | grep root | grep -v $0 | grep -v grep | head -n 1 | cut -d' ' -f1)
A2SECONDS=$(ls -od --time-style=+%s /proc/$A2PID | cut -d' ' -f5)
A2DATE=$(ls -od --time-style=+%Y-%m-%d_%H-%M /proc/$A2PID | cut -d' ' -f5)
A2CHILDS=$(ps aux | grep apache | grep -v root | grep -v grep | wc -l)
A2PCPU=$(ps axo %cpu,cmd | grep apache2 | grep -v $0 | grep -v grep | sed -e 's/^ //' | cut -d' ' -f1 | sed -e 's/\.//')
A2PMEM=$(ps axo %mem,cmd | grep apache2 | grep -v $0 | grep -v grep | sed -e 's/^ //' | cut -d' ' -f1 | sed -e 's/\.//')

A2CPU=0
for i in $A2PCPU; do
  A2CPU=$((A2CPU + i))
done

A2CPUI=$((A2CPU / 10))
A2CPUD=$((A2CPU % 10))

A2MEM=0
for i in $A2PMEM; do
  A2MEM=$((A2MEM + i))
done

A2MEMI=$((A2MEM / 10))
A2MEMD=$((A2MEM % 10))

DATE=$(date +%s)
TIME=$(date +%H:%M:%S)

UPTIME=$((DATE - A2SECONDS))
DAYS=$((UPTIME / 86400))
UPTIME=$((UPTIME - DAYS * 86400))
HOURS=$((UPTIME / 3600))
UPTIME=$((UPTIME - HOURS * 3600))
MINUTES=$((UPTIME / 60))

echo " $TIME up $DAYS days, $HOURS:$MINUTES, $A2CHILDS child processes, $A2CPUI.$A2CPUD, $A2MEMI.$A2MEMD"
