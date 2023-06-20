#!/bin/sh

# PROVIDE: appjail_health
# REQUIRE: appjail
# KEYWORD: shutdown

# 
# Configuration settings for appjail-health in /etc/rc.conf
#
# appjail_health_enable (bool):     Enable appjail-health. (default=NO)
# appjail_health_logfile (bool):    Full path to the log file. (default=/var/log/appjail.log)
#

. /etc/rc.subr

name=appjail_health
rcvar=${name}_enable

start_precmd="appjail_health_precmd"

: ${appjail_health_enable:=NO}
: ${appjail_health_logfile=/var/log/appjail.log}
: ${appjail_health_path=${PATH}:%%PREFIX%%/bin}

appjail_health_env="PATH=${appjail_health_path}"

pidfile="/var/run/${name}.pid"
procname="%%PREFIX%%/bin/appjail"
command="/usr/sbin/daemon"
command_args="-c -p ${pidfile} -o ${appjail_health_logfile} ${procname} startup start healthcheckers"
command_interpreter="/bin/sh"

appjail_health_precmd()
{
	if [ ! -f "${appjail_health_logfile}" ]; then
		install -m 640 /dev/null "${appjail_health_logfile}"
	fi
	echo "AppJail log file (Health): ${appjail_health_logfile}"
}

load_rc_config ${name}
run_rc_command "$1"
