#!/bin/tcsh
# Title      : dnsscan.tcsh
# Description: Get all host names for a class C network	
# Author     : linuxitux
# Date       : 26-05-2015
# Usage      : ./dnsscan.tcsh A.B.C [DELAY]
# Notes      : -

if ( $# < 1 ) then
  echo "Usage: $0 A.B.C [DELAY]"
  echo "  A.B.C: class C network specification"
  echo "  DELAY: seconds between requests (default 1)"
  echo "Examples:"
  echo "  $0 192.168.0 5"
  echo "  $0 10.6.140"
  exit(1)
endif

set NET=$1
set SLEEP=1
if ( $# > 1 ) set SLEEP=$2
set D=1

while ( $D < 255 )
  echo -n "$NET.$D -- "
  host $NET.$D | cut -d' ' -f5
  sleep $SLEEP
  @ D++
end
