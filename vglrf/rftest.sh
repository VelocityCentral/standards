#!/bin/bash
TERM=vt220; export TERM
TERMINFO=/usr/pronto/terminfo ; export TERMINFO
. $PRONTO/lib/sat.env
export COLUMNS=30
export LINES=15
cd /pro/data/sat
prospl vglrf/vglrftest 
exit


