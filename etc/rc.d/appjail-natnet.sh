#!/bin/sh

# PROVIDE: appjail_natnet
# REQUIRE: LOGIN FILESYSTEMS NETWORKING
# KEYWORD: shutdown

# 
# Configuration settings for appjail-natnet in /etc/rc.conf
#
# appjail_natnet_enable (bool):     Enable appjail-natnet. (default=NO)
# appjail_natnet_logfile (bool):    Full path to the log file. (default=/var/log/appjail.log)
#

. /etc/rc.subr

name=appjail_natnet
rcvar=${name}_enable

: ${appjail_natnet_enable:=NO}
: ${appjail_natnet_logfile=/var/log/appjail.log}

command="%%PREFIX%%/bin/appjail"
start_cmd="${name}_start"
start_postcmd="_show_logfile"
stop_cmd="${name}_stop"
stop_postcmd="_show_logfile"
restart_cmd="${name}_restart"
restart_postcmd="_show_logfile"
status_cmd="${name}_status"

precmd()
{
	install -m 640 /dev/null "${appjail_natnet_logfile}"
}

_show_logfile()
{
	echo "AppJail log file (NAT): ${appjail_natnet_logfile}"
}

appjail_natnet_start()
{
	(nohup "${command}" startup start nat networks >> "${appjail_natnet_logfile}" &)
}

appjail_natnet_stop()
{
	(nohup "${command}" startup stop nat networks >> "${appjail_natnet_logfile}" &)
}

appjail_natnet_restart()
{
	(nohup "${command}" startup restart nat networks >> "${appjail_natnet_logfile}" &)
}

appjail_natnet_status()
{
	local nat_info
	nat_info=`mktemp -t appjail`

	"${command}" nat list network > "${nat_info}"

	if [ `cat "${nat_info}" | wc -l` -eq 0 ]; then
		echo "There are no NAT rules yet."
		return 1
	fi

	echo "NAT Information:"
	echo

	cat "${nat_info}"

	echo
	echo "Status:"
	echo

	cat "${nat_info}" | tail -n +2 | awk '{print $2}' | while read -r network_name
	do
		"${command}" nat status network "${network_name}" 2> /dev/null
	done

	rm -f "${nat_info}"
}

load_rc_config ${name}
run_rc_command "$1"
