#!/bin/sh

# PROVIDE: appjail
# REQUIRE: LOGIN FILESYSTEMS NETWORKING devfs
# KEYWORD: shutdown

# 
# Configuration settings for appjail in /etc/rc.conf
#
# appjail_enable (bool):     Enable appjail. (default=NO)
# appjail_logfile (bool):    Full path to the log file. (default=/var/log/appjail.log)
#

. /etc/rc.subr

name=appjail
rcvar=${name}_enable

load_rc_config ${name}

: ${appjail_enable:=NO}
: ${appjail_logfile=/var/log/appjail.log}
: ${appjail_path=${PATH}:%%PREFIX%%/bin}

command="%%PREFIX%%/bin/${name}"
start_cmd="${name}_start"
start_precmd="precmd"
stop_cmd="${name}_stop"
stop_precmd="precmd"
restart_cmd="${name}_restart"
restart_precmd="precmd"
status_cmd="${name}_status"

precmd()
{
	if [ ! -f "${appjail_logfile}" ]; then
		install -m 640 /dev/null "${appjail_logfile}"
	fi
	echo "AppJail log file (Jails): ${appjail_logfile}"
}

appjail_start()
{
	env PATH="${appjail_path}" \
		daemon -o "${appjail_logfile}" "${command}" startup start jails
}

appjail_stop()
{
	env PATH="${appjail_path}" \
		"${command}" startup stop jails >> "${appjail_logfile}" 2>&1
}

appjail_restart()
{
	env PATH="${appjail_path}" \
		"${command}" startup restart jails >> "${appjail_logfile}" 2>&1
}

appjail_status()
{
	env PATH="${appjail_path}" "${command}" jail list | grep -e '^UP' -e '^STATUS'
}

run_rc_command "$1"
