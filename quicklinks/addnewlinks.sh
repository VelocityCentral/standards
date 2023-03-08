#!/bin/bash

export DB=sat
export FOLDER=/pro/data/winfiles/quicklinks
export WORKFILE=/tmp/folder_contexts_$$.csv

touch $WORKFILE
chmod 666 $WORKFILE
cat /dev/null > $WORKFILE

# Note that $FOLDER must be a full path if %P is to make much sense
# Note 2 - use -daystart and -mtime +1 to limit to files created today 
#     to speed up the process
find $FOLDER -printf "%p|%P\n" > $WORKFILE

sudo -u informix -E sqlcmd -d sat <<EOF
drop temp table if exists folder_contents;
create temp table folder_contents(
	filename varchar(128),
	fullpath varchar(256),
	) with no log;
insert

select * from folder_contents;

EOF
