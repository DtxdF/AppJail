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
start_postcmd="_show_logfile"
stop_cmd="${name}_stop"
stop_postcmd="_show_logfile"
restart_cmd="${name}_restart"
restart_postcmd="_show_logfile"
status_cmd="${name}_status"

precmd()
{
	if [ ! -f "${appjail_logfile}" ]; then
		install -m 640 /dev/null "${appjail_logfile}"
	fi
}

_show_logfile()
{
	echo "AppJail log file (Jails): ${appjail_logfile}"
}

appjail_start()
{
	(nohup env PATH="${appjail_path}" "${command}" startup start jails >> "${appjail_logfile}" &)

}

appjail_stop()
{
	(nohup env PATH="${appjail_path}" "${command}" startup stop jails >> "${appjail_logfile}" &)
}

appjail_restart()
{
	(nohup env PATH="${appjail_path}" "${command}" startup restart jails >> "${appjail_logfile}" &)
}

appjail_status()
{
	env PATH="${appjail_path}" "${command}" jail list | grep -e '^UP' -e '^STATUS'
}

run_rc_command "$1"
