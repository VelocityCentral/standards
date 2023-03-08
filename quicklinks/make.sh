#!/bin/bash

#
# Use this make compiling easier.
# It will delete the clib in cus then re-compile all the code then
# recomile the cus clib.
# This avoids all the problems with pronto's clib compile sequence.
#

LOG=/tmp/make$$.log

if [ -f $CUS/clib/clibvqlauto.op7 ] ; then
	rm -f $CUS/clib/clibvqlauto.op7
fi

cd $CUS

if [ -f $CORE/clib/clibvqlauto.spl ] ; then
	pmcompile.sh --file $CORE/clib/clibvqlauto.spl --log $LOG --switches -l
fi
for f in $CUS/quicklinks/vql*.spl
do
	echo $f
	pmcompile.sh --file $f --log $LOG --switches -l
done
if [ -f $CUS/clib/clibvqlauto.spl ] ; then
	pmcompile.sh --file $CUS/clib/clibvqlauto.spl --log $LOG --switches -l
fi

if [ `grep -i "^\*\*\*" $LOG | wc -l ` -ne 0 ] ; then
	echo "************************************************************"
	echo "*    ERRORS - PRESS ENTER TO REVIEW                        *"
	echo "************************************************************"
	read ans
	vi $LOG
fi

rm -f $LOG
