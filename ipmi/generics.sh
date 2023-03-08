# !/bin/bash

#This procedure outputs a bunch of stuff in the same format
# for input into ipmi

#disk use  - the only problem with this is is questions is the transfer rate is 
# since when?  It may tbe the average transfer rate per second since the machine was
# booted - need to clarify and understand this

#KB read per second and KB write per second
iostat -dkN | sed '1,3d' | awk '
{ if ($1 != "") {
		print strftime("%d/%m/%y|%H:%M:%S") "|dev_" $1 "_kbrps|" $3 "|Kb/s"
		print strftime("%d/%m/%y|%H:%M:%S") "|dev_" $1 "_kbwps|" $4 "|Kb/s"
	}
}
'
sar -u 1 1 | grep Average | awk '
{ print strftime("%d/%m/%y|%H:%M:%S") "|cpu_busy" "|" $3 + $4 + $5 "|percent"
 print strftime("%d/%m/%y|%H:%M:%S") "|cpu_idle" "|" $8 "|percent"
 print strftime("%d/%m/%y|%H:%M:%S") "|cpu_user" "|" $3 "|percent"
 print strftime("%d/%m/%y|%H:%M:%S") "|cpu_nice" "|" $4 "|percent"
 print strftime("%d/%m/%y|%H:%M:%S") "|cpu_sys" "|" $5 "|percent"
 print strftime("%d/%m/%y|%H:%M:%S") "|cpu_iowait" "|" $6  "|percent"
}
'

#uptime lists the load average.  Three numbers are listed are the past 1,5 and 15 minute averages.
# As a general rule the load average should next exceed the number of processors and should be quite low.
# the number of processors can be found by : cat /proc/cpuinfo | grep -i "^processor" | wc -l


uptime | awk '
	{ split($0,line," ");
		for (i=1;i<=NF; i++)
			{ if (line[i] == "users,") usercount=line[i - 1];
			  if (line[i] == "average:") av15min=line[i + 3];
			}
	}
END { 
	 print strftime("%d/%m/%y|%H:%M:%S") "|usercount|" usercount  "|count"
	 print strftime("%d/%m/%y|%H:%M:%S") "|15minloadav|" av15min  "|Avg"
 }
'

#Note that used memory includes memory that is allocated to filesystem swap space
#The actual free memory is free + buffer memory + swap cache.  the O/S automatically
#allocates free memory to the swap cache but will release it if it is needed for 
# something else.
#Pages swapped in / out should be kept to a minimum
vmstat -s -S M |  awk '
BEGIN { actfree = 0; totalswap = 0;}
/total memory/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_Total" "|" $1 "|Mbytes" }
/used memory/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_used" "|" $1 "|Mbytes" }
/ active memory/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_active" "|" $1 "|Mbytes" }
/free memory/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_free" "|" $1 "|Mbytes" ;
				actfree = actfree + $1; }
/used swap/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_swap_used" "|" $1 "|Mbytes" }
/free swap/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_swap_free" "|" $1 "|Mbytes" }
/ buffer memory/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_buffer" "|" $1 "|Mbytes" ;
				actfree = actfree + $1; }
/ swap cache/{ print strftime("%d/%m/%y|%H:%M:%S") "|Mem_swap_cache" "|" $1 "|Mbytes" ;
				actfree = actfree + $1; }
/ pages swapped in/{ print strftime("%d/%m/%y|%H:%M:%S") "|pages_swapped_in" "|" $1 "|Mbytes" ;
		totalswap = totalswap + $1}
/ pages swapped out/{ print strftime("%d/%m/%y|%H:%M:%S") "|pages_swapped_out" "|" $1 "|Mbytes" ;
		totalswap = totalswap + $1}
END { print strftime("%d/%m/%y|%H:%M:%S") "|Mem_actual_free" "|" actfree "|Mbytes"; 
	 print strftime("%d/%m/%y|%H:%M:%S") "|pages_swapped_total" "|" totalswap "|pages"; }
' 

sqlcmd -d sysmaster -c "select count(*) from syslogs where is_backed_up = 0 and is_current = 0 and is_used = 1" | awk '
{ print strftime("%d/%m/%y|%H:%M:%S") "|open_logs" "|" $1 "|count" }
'

echo  `date +'%d/%m/%y|%T'` "|pronto_users|" `prowho -s | sed "1d" | wc -l` "|count"
echo  `date +'%d/%m/%y|%T'` "|pronto_sessions|" `prowho -a | sed "1d" | grep -v "<batched>" | wc -l` "|count"
echo  `date +'%d/%m/%y|%T'` "|zombies|" `ps axo stat= | grep Z | wc -l` "|count"

# the following adds up the total cpu percentage and the total memory percentage
# for the top 5 processes.

top -bc -n 1 | sed "1,7d" | head -5 | awk '
{
	totcpu=totcpu+$9;
	totmem=totmem+$10;
}
END {
	 print strftime("%d/%m/%y|%H:%M:%S") "|top5_cpu" "|" totcpu "|percent"; 
	 print strftime("%d/%m/%y|%H:%M:%S") "|top5_mem" "|" totmem "|percent"; 
 }
 '

# make sure the command is installed first.
command -v lsblk > /dev/null
if [ $? = 0 ] ; then
#  The next bit is an absolute doozy.
#  the purpose is capture the disk statistics that occurred in the last 30 second window.
#  This is done by the command :  iostat -xd  30 2
# What complicates the issue is that the device names in the iostat don't match anything
# else we have and therefore we have to tie it up to lsblk.  lsblk lists the block devices
# on the system but has quite un unfriendly output (especially when you need to see it over
# multiple systems).
#
# The first step is to combine the lsblk and iostat commands into a single stream that
# can be handled by awk.

{
lsblk -l -o NAME,KNAME,FSTYPE,MOUNTPOINT,TYPE 
echo "***Break***" 
iostat -xd  30 2
} | awk '
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }
BEGIN { iostat = 0 #false
		lsblk = 1 #true
		iostat_count = 0
		}
/^Device/ && iostat { iostat_col_bound = split($0,io)
				# now build an array where the indices are the headings 
				# and the values are the indices (we will need this in the detail
				# 
					for (h in io) iohead_pos[io[h]] = h
					# for (x in iohead_pos) print "IOHEAD_POS:" x ":" iohead_pos[x] ":"
					iostat_count += 1
					next
					}

/^***Break***/ { lsblk = 0
				 iostat = 1
				 next
				 }

NR == 1	{
# First record - split the headings into a headings text (ht) array
		bound=split($0,ht)
# To add additional complexity: the word "TYPE" appears twice.
# so we need to search for SPACE<word> and then add one to get the position.
		for (i in ht)
			hp[i] = index($0," "ht[i]) + 1
		next # do nothing else
	}

NR != 1 && lsblk {
# Detail records
	# break up the record based on the column positions found in the header
	# and put these into an array called dtl
	for (i = 1; i<=bound ; i++)
		if (i == bound) dtl[i] = substr($0,hp[i])
		else
			dtl[i] = substr($0,hp[i],(hp[i+1]-1) - hp[i])
	#now add an element to each array that matches the columns and the index is
	# the KNAME entry (because this is what we will have when processing iostat.
	for (i in dtl) 
		{ 
#		print "DTL:" i ":" dtl[i]
		this_kname = trim(dtl[2])
		name[this_kname] = trim(dtl[1])
		mountpoint[this_kname] = trim(dtl[4])
		fstype[this_kname] = dtl[3]
		type[this_kname] = dtl[5]
		}
	# now test it:
	# for (i in name) { print "blkdevices:" i "|" name[i] "|" mountpoint[i] "|" fstype[i] "|" type[i] }
	}

iostat && iostat_count == 2 { 
	this_line_bound = split($0,cols)
	if (this_line_bound > 1) 
		{
		# this is where the guts are.  We now have a series of array from lsblk that match
		# the column and are indexed by the device name in the iostat output.
		# The line above created an array of columns for cols[1] is the device name
		# and we can now pull it altogether:
		# for (c in cols) print "COLS ARRAY:"  c ":" cols[c]
		# 
		#print "Debug: IOSTAT device:" cols[iohead_pos["Device:"]] \
		#	" is called " name[cols[iohead_pos["Device:"]]] \
		#	" is mounted at " mountpoint[cols[iohead_pos["Device:"]]] \
		#	" and is of type " type[cols[iohead_pos["Device:"]]] \
		#	" has average queue size of " cols[iohead_pos["avgqu-sz"]]
		# Finally the output for IPMI
		split("r/s|w/s|avgqu-sz|await",vars,"|")
		for (i in vars)
			{
			print strftime("%d/%m/%y|%H:%M:%S") "|dev_" name[cols[iohead_pos["Device:"]]]  "_" vars[i] "|" cols[iohead_pos[vars[i]]] "|stat"

			}

		}
	}


'
fi # lsblk installed and working.
