#!/bin/bash
# Pronto Xi Company Environments.
. $PRONTO/lbin/JJ.env

# ----------------------------------------------------
# Set user specific variables
# ----------------------------------------------------
#create a work file
WRK=/tmp/envvar$$
if [ -f $WRK ] ; then
	rm -f $WRK
fi
# make sure we can access it because the sql is done via sudo
# and we won't be able to otherwise
touch $WRK
chmod 777 $WRK

#we need to be in the right directory because that's how the next bit works.
cd $DATADIR
{
sudo -u informix -E sqlcmd -d sysinfo <<SQL
select 'export ' || rtrim(env_var_name) || '=' || rtrim(env_var_value) from env_vars where user_id='$USER' 
	and company_code = (select sys_comp_code from system_companies where sys_comp_path = '$DATADIR');
SQL
} >> $WRK
# Execute it in the current shell
. $WRK
#remove it
if [ -f $WRK ] ; then
	rm -f $WRK
fi
# ----------------------------------------------------

prospl bmsmenu -go
