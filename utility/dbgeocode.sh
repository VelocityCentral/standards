#!/bin/bash

export PRONTO=/pro/pronto
. $PRONTO/lib/sh_environs
. $PRONTO/lbin/SAT.env 

cd $DATADIR
echo $DATADIR

su rayb -c "prospl -b utility/dbgeocode.sh -nad"

{
sudo -u informix -E sqlcmd -d ${DATADIR#*/} << EOF
	select
	accountcode,
	na_type,
	only_alpha30_1,
	only_alpha30_2,
	only_alpha4_1
	from name_and_address_master
	where only_alpha30_2 <> ''
	order by accountcode,na_type
EOF
} > $CUS/utility/nadbackup.txt
