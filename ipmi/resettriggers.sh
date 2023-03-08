#!/bin/bash


# This script will reset the triggers for the numeric triggers
# The low point will be 30% below the current lowest reading
# The high point will be 30% above the current highest reading

sudo -u informix -E sqlcmd -d sysinfo << EOF
	update ipmi_master
	set (trigger_low,trigger_high) = 
		((select min(reading_value)::int, max(reading_value)::int
			from ipmi_readings
			where ipmi_readings.code = ipmi_master.code))
	where ipmi_master.reading_type = 'N';
	update ipmi_master
	set trigger_low = trigger_low * 0.7,
		trigger_high = trigger_high * 1.3
	where ipmi_master.reading_type = 'N';
EOF
