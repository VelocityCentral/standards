#!/bin/bash
# executed from cron

export PRONTO=/pro/pronto
. /pro/pronto/lib/sh_environs

cd /tmp

# Use the following if ipmi is working on the localhost or if it is not available.
su psd -c "prospl -b ipmi/addreading 2>/dev/null"	
#su psd -c "prospl -b ipmi/addreading -interface lanplus -user Administrator -password 3T4H94H5 -host 192.168.110.166 -port 623 >/dev/null"
# Use the following if ipmi is available on an attached IMM interface (esp useful for a virtualised environment)
# to check use this command:
# ipmitool -Uroot -Pma$ter -H192.168.110.whatever -c sdr list
#su psd -c "prospl -b ipmi/addreading -host 192.168.110.101 -user USERID -password PASSW0RD 2>/dev/null"
