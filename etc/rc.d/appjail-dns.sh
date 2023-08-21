#!/bin/sh

# PROVIDE: appjail_dns
# REQUIRE: LOGIN FILESYSTEMS NETWORKING
# KEYWORD: shutdown

#
# Configuration settings for appjail-dns in /etc/rc.conf
#
# appjail_dns_enable (bool):     Enable appjail-dns. (default=NO)
# appjail_dns_logfile (bool):    Full path to the log file. (default=/var/log/appjail.log)
# appjail_dns_interval (str):    Interval to check if the hosts have been changed before executing the hook. (default=60)
# appjail_dns_hosts (str):       Full path to the hosts file. (default=/var/tmp/appjail-hosts)
# appjail_dns_hook (str):        Full path to the DNS hook. (default=%%PREFIX%%/share/appjail/scripts/dnsmasq-hook.sh)
#

. /etc/rc.subr

name=appjail_dns
rcvar=${name}_enable

start_precmd="appjail_dns_precmd"

load_rc_config ${name}

: ${appjail_dns_enable:=NO}
: ${appjail_dns_logfile=/var/log/appjail.log}
: ${appjail_dns_path=${PATH}:%%PREFIX%%/bin}
: ${appjail_dns_interval=60}
: ${appjail_dns_hosts=/var/tmp/appjail-hosts}
: ${appjail_dns_hook=%%PREFIX%%/share/appjail/scripts/dnsmasq-hook.sh}

appjail_dns_env="PATH=${appjail_dns_path}"

pidfile="/var/run/${name}.pid"
procname="%%PREFIX%%/share/appjail/scripts/ajdns.sh"
command="/usr/sbin/daemon"
command_args="-c -p ${pidfile} -o ${appjail_dns_logfile} ${procname} -i ${appjail_dns_interval} -h ${appjail_dns_hosts} -H ${appjail_dns_hook}"
command_interpreter="/bin/sh"

appjail_dns_precmd()
{
	if [ ! -f "${appjail_dns_logfile}" ]; then
		install -m 640 /dev/null "${appjail_dns_logfile}"
	fi
	echo "AppJail log file (DNS): ${appjail_dns_logfile}"
}

run_rc_command "$1"
