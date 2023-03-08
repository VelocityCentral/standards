#!/bin/bash

#use ln -s to create a symbolic link in the lbin directory
file=$1
device=$2 ; export device

export email=`{
sudo -u informix -E sqlcmd -d sysinfo << SQL
select 
	case
	when suc_user_email like "%@%"	then suc_user_email
	when suc_user_email = ''	then trim(user_id) || "@" || dbinfo('dbhostname')
	else
	suc_user_email || "@" || dbinfo('dbhostname')
	END
from sysinfo:system_user_control
where user_id = '$USER';
SQL
}`


#echo $file
#echo $device
#echo $email
#cp $file /tmp/lastone.txt
#read ans
cat $file | awk  \
	'BEGIN {
		print "%cpBegin";
		print "%cpSystem:Linux";
		print "%cpUser:" ENVIRON["email"];
		print "%cpParam:-c" ENVIRON["copies"];
		print "%cpEnd";
		}
		{print $0}
		'\ | tee /tmp/processed.txt | lpr -P $device

