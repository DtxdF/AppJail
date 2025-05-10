#!/bin/sh
#
# Copyright (c) 2025, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_appjail()
{
	_APPJAIL_JAILS_=
	_APPJAIL_RELEASES_ARCH_=
	_APPJAIL_RELEASES_VERSION_=
	_APPJAIL_RELEASES_NAME_=
	_APPJAIL_DEVFS_RULESETS_=
	_APPJAIL_NETWORKS_=
	_APPJAIL_INTERFACES_=
	_APPJAIL_ADDRESSES_=
	_APPJAIL_DEBOOTSTRAP_SCRIPTS_=
	_APPJAIL_SIGNALS_=
	_APPJAIL_IMAGES_=
	_APPJAIL_LOGS_=
	_APPJAIL_MAKEJAILS_=
	_APPJAIL_BRIDGES_=
	_APPJAIL_JAIL_EPAIRS_=
	_APPJAIL_OCI_IMAGES_=
	_APPJAIL_OCI_CONTAINERS_=

	_APPJAIL_COMPLETION_="\
apply \
checkOld \
cmd \
cpuset \
deleteOld \
devfs \
disable \
enable \
enabled \
etcupdate \
expose \
fetch \
fstab \
healthcheck \
help \
image \
jail \
label \
limits \
login \
logs \
makejail \
nat \
network \
oci \
pkg \
quick \
restart \
rstop \
run \
service \
start \
startup \
status \
stop \
sysrc \
update \
upgrade \
usage \
version \
volume \
zfs"
	_APPJAIL_KEYWORDS_LIMITS_="\
action \
enabled \
name \
per \
resource \
rule"
	_APPJAIL_KEYWORDS_LABEL_="\
name \
value"
	_APPJAIL_KEYWORDS_JAIL_="\
alt_name \
appjail_version \
arch \
boot \
container \
container_boot \
container_image \
container_pid \
created \
devfs_ruleset \
dirty \
hostname \
inet \
inet6 \
ip4 \
ip6 \
is_container \
locked \
name \
network_ip4 \
networks \
path \
priority \
ports \
release_name \
status \
type \
version \
version_extra"
	_APPJAIL_KEYWORDS_IMAGE_METADATA_="\
arch \
name \
tags \
maintainer \
comment \
url \
description \
sum: \
source: \
size: \
maintenance \
entrypoint \
ajspec"
	_APPJAIL_KEYWORDS_IMAGE_="\
name \
has_metadata"
	_APPJAIL_KEYWORDS_HEALTHCHECK_="\
nro \
enabled \
health_cmd \
health_type \
interval \
kill_after \
name \
recover_cmd \
recover_kill_after \
recover_timeout \
recover_timeout_signal \
recover_total \
recover_type \
retries \
start_period \
status \
timeout \
timeout_signal"
	_APPJAIL_KEYWORDS_FSTAB_="enabled nro name device mountpoint type options dump pass"
	_APPJAIL_KEYWORDS_EXPOSE_="enabled name hport jport ext_if on_if network_name nro ports protocol rule"
	_APPJAIL_KEYWORDS_DEVFS_="nro enabled name rule"
	_APPJAIL_KEYWORDS_LIMITS_RESOURCES_="\
cputime \
datasize \
stacksize \
coredumpsize \
memoryuse \
memorylocked \
maxproc \
openfiles \
vmemoryuse \
pseudoterminals \
swapuse \
nthr \
msgqqueued \
msgqsize \
nmsgq \
nsem \
nsemop \
nshm \
shmsize \
wallclock \
pcpu \
readbps \
writebps \
readiops \
writeiops"
	_APPJAIL_KEYWORDS_LIMITS_ACTIONS_="deny log throttle"
	_APPJAIL_KEYWORDS_NAT_="name rule"
	_APPJAIL_KEYWORDS_NAT_JAIL_="network"
	_APPJAIL_KEYWORDS_NAT_NETWORK_="boot"
	_APPJAIL_KEYWORDS_NETWORK_="name network cidr broadcast gateway minaddr maxaddr addresses description mtu"
	_APPJAIL_KEYWORDS_VOLUME_="name mountpoint type uid gid perm"

	COMPREPLY=()

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 1 ]; then
		COMPREPLY=($(compgen -W "${_APPJAIL_COMPLETION_}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 2 ]; then
		local state
		state="${COMP_WORDS[1]}"

		case "${state}" in 
			apply|checkOld|cmd|cpuset|deleteOld|devfs|disable|enable|enabled|etcupdate|expose|fetch|fstab|healthcheck|help|image|jail|label|limits|login|logs|makejail|nat|network|oci|pkg|restart|rstop|run|service|start|startup|status|stop|sysrc|update|upgrade|usage|volume|zfs) _appjail_${state} ;;
		esac
	fi
}

_appjail_zfs()
{
	local completion
	completion="clone-dst clone-src create destroy get inherit list recv send set snapshot"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			clone-dst|clone-src|create|destroy|get|inherit|list|recv|send|set|snapshot) _appjail_zfs_${state} ;;
		esac
	fi
}

_appjail_zfs_snapshot()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_set()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_send()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_recv()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_list()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_inherit()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_get()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_destroy()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_create()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_clone-src()
{
	_appjail_zfs_clone-dst
}

_appjail_zfs_clone-dst()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_volume()
{
	local completion
	completion="add get list remove"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			add|get|list|remove) _appjail_volume_${state} ;;
		esac
	fi
}

_appjail_volume_remove()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_volumes "${prev}")" -- "${cur}"))
	fi
}

_appjail_volume_list()
{
	_appjail_volume_get
}

_appjail_volume_get()
{
	local completion
	completion="-e -H -I -p -t -v $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_VOLUME_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_volume_add()
{
	local completion
	completion="-g -m -o -p -t $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_usage()
{
	_appjail_help
}

_appjail_upgrade()
{
	local completion
	completion="jail release"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			jail|release) _appjail_upgrade_${state} ;;
		esac
	fi
}

_appjail_upgrade_release()
{
	local completion
	completion="-i -n -I -f -a -v $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_upgrade_jail()
{
	local completion
	completion="-i -f -u -n $(_func_appjail_get_releases_name) $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_update()
{
	local completion
	completion="jail release"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			jail|release) _appjail_update_${state} ;;
		esac
	fi
}

_appjail_update_release()
{
	local completion
	completion="-f -a -v $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_update_jail()
{
	local completion
	completion="-b -f -K -k -j $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_sysrc()
{
	local completion
	completion="all local jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			all|local|jail) _appjail_sysrc_${state} ;;
		esac
	fi
}

_appjail_sysrc_all()
{
	local completion
	completion="-e local jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			local|jail) _appjail_sysrc_${state} ;;
		esac
	fi
}

_appjail_sysrc_local()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "sysrc" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_sysrc_jail()
{
	_appjail_sysrc_local
}

_appjail_stop()
{
	local completion
	completion="-f -I -i -p -V $(_func_appjail_get_jails)"
	
	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_status()
{
	local completion
	completion="-q $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 3 ]; then
		if [ "${prev}" = "-q" ]; then
			COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
		fi
	fi
}

_appjail_startup()
{
	local completion
	completion="start stop restart"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			start|stop|restart) _appjail_startup_${state} ;;
		esac
	fi
}

_appjail_startup_restart()
{
	_appjail_startup_stop
}

_appjail_startup_stop()
{
	local completion
	completion="jails nat"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			nat) completion="networks" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_startup_start()
{
	local completion
	completion="healthcheckers jails nat"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			nat) completion="networks" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_start()
{
	local completion
	completion="-I -t -i -c -s -V $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_service()
{
	local completion
	completion="all jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			all|jail) _appjail_service_${state} ;;
		esac
	fi
}

_appjail_service_all()
{
	local completion
	completion="-e -i"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_service_jail()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_run()
{
	local completion
	completion="-i -p -V -s $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_rstop()
{
	_appjail_restart
}

_appjail_restart()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_pkg()
{
	local completion
	completion="all chroot jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			all|chroot|jail) _appjail_pkg_${state} ;;
		esac
	fi
}

_appjail_pkg_all()
{
	local completion
	completion="-e -i chroot jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			chroot|jail) _appjail_pkg_${state} ;;
		esac
	fi
}

_appjail_pkg_chroot()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "pkg" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_pkg_jail()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "pkg" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	else
		local completion
		completion="-j"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_oci()
{
	local completion
	completion="\
del-env \
del-user \
del-workdir \
exec \
from \
get-container-name \
get-env \
get-pid \
get-user \
get-workdir \
kill \
ls-env \
mount \
run \
set-boot \
set-container-name \
set-env \
set-user \
set-workdir \
umount"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			del-env|del-user|del-workdir|exec|from|get-container-name|get-env|get-pid|get-user|get-workdir|kill|ls-env|mount|run|set-boot|set-container-name|set-env|set-user|set-workdir|umount) _appjail_oci_${state} ;;
		esac
	fi
}

_appjail_oci_umount()
{
	_appjail_oci_del-user
}

_appjail_oci_set-workdir()
{
	_appjail_oci_del-user
}

_appjail_oci_set-user()
{
	_appjail_oci_del-user
}

_appjail_oci_set-env()
{
	_appjail_oci_del-env
}

_appjail_oci_set-container-name()
{
	local completion
	completion="$(_func_appjail_get_oci_containers)"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_oci_set-boot()
{
	local completion
	completion="on off"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_oci_run()
{
	local completion
	completion="-d -e -o -u -w $(_func_appjail_get_oci_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_oci_mount()
{
	_appjail_oci_del-user
}

_appjail_oci_ls-env()
{
	_appjail_oci_del-user
}

_appjail_oci_kill()
{
	local completion
	completion="-s $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-s) completion="$(_func_appjail_get_signals)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_oci_get-workdir()
{
	_appjail_oci_del-user
}

_appjail_oci_get-user()
{
	_appjail_oci_del-user
}

_appjail_oci_get-pid()
{
	_appjail_oci_del-user
}

_appjail_oci_get-env()
{
	_appjail_oci_del-env
}

_appjail_oci_get-container-name()
{
	_appjail_oci_del-user
}

_appjail_oci_from()
{
	local completion
	completion="$(_func_appjail_get_oci_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_oci_exec()
{
	local completion
	completion="-d -e -u -w $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_oci_del-workdir()
{
	_appjail_oci_del-user
}

_appjail_oci_del-user()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_oci_del-env()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion="$(appjail oci ls-env "${prev}" 2> /dev/null)"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network()
{
	local completion
	completion="add assign attach auto-create detach fix get hosts list plug remove reserve unplug"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			add|assign|attach|detach|fix|get|hosts|list|plug|remove|reserve|unplug) _appjail_network_${state} ;;
		esac
	fi
}

_appjail_network_unplug()
{
	local completion
	completion="$(_func_appjail_get_networks)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jail_epairs)" -- "${cur}"))
	fi
}

_appjail_network_reserve()
{
	local completion
	completion="-j -n -a"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-j) completion="$(_func_appjail_get_jails)" ;;
			-n) completion="$(_func_appjail_get_networks)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network_remove()
{
	local completion
	completion="-d -f $(_func_appjail_get_networks)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_network_plug()
{
	local completion
	completion="-e -n -d"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-e) completion="$(_func_appjail_get_jail_epairs)" ;;
			-n) completion="$(_func_appjail_get_networks)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network_list()
{
	local completion
	completion="-e -H -I -p -t -n $(_func_appjail_get_networks) ${_APPJAIL_KEYWORDS_NETWORK_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_network_hosts()
{
	local completion
	completion="-a -n -d -e -j -l -R -E -r -H -N -s"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-n) completion="$(_func_appjail_get_networks)" ;;
			-j) completion="$(_func_appjail_get_jails)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network_get()
{
	local completion
	completion="-e -H -I -p -t $(_func_appjail_get_networks) ${_APPJAIL_KEYWORDS_NETWORK_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_network_fix()
{
	local completion
	completion="all dup addr"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "-n" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 5 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_networks)" -- "${cur}"))
	fi
}

_appjail_network_attach()
{
	local completion
	completion="-b epair: iface:"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-b) completion="$(_func_appjail_get_bridges)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network_assign()
{
	local completion
	completion="-e -j -n -d"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		case "${prev}" in
			-j) completion="$(_func_appjail_get_jails)" ;;
			-n) completion="$(_func_appjail_get_networks)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_network_add()
{
	local completion
	completion="-O -d -m"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_nat()
{
	local completion
	completion="add get list off on remove status boot"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			add|get|list|off|on|remove|status|boot) _appjail_nat_${state} ;;
		esac
	fi
}

_appjail_nat_boot()
{
	local completion
	completion="off on"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_networks)" -- "${cur}"))
	fi
}

_appjail_nat_status()
{
	local completion
	completion="jail network"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion=

		if [ "${COMP_WORDS[3]}" = "jail" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ "${COMP_WORDS[3]}" = "network" ]; then
			completion="$(_func_appjail_get_networks)"
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_nat_remove()
{
	local completion
	completion="jail network"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion=

		if [ "${COMP_WORDS[3]}" = "jail" ]; then
			if [ ${COMP_CWORD} -eq 4 ]; then
				completion="-n"
			elif [ ${COMP_CWORD} -eq 5 ]; then
				completion="$(_func_appjail_get_networks)"
			elif [ ${COMP_CWORD} -eq 6 ]; then
				completion="$(_func_appjail_get_jails)"
			fi
		elif [ "${COMP_WORDS[3]}" = "network" ]; then
			if [ ${COMP_CWORD} -eq 4 ]; then
				completion="$(_func_appjail_get_networks)"
			fi
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_nat_on()
{
	_appjail_nat_off
}

_appjail_nat_off()
{
	local completion
	completion="jail network"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion=

		if [ ${COMP_CWORD} -eq 5 ]; then
			return
		fi

		if [ "${COMP_WORDS[3]}" = "jail" ]; then
			case "${prev}" in
				*) completion="$(_func_appjail_get_jails)" ;;
			esac
		elif [ "${COMP_WORDS[3]}" = "network" ]; then
			case "${prev}" in
				*) completion="$(_func_appjail_get_networks)" ;;
			esac
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_nat_list()
{
	_appjail_nat_get
}

_appjail_nat_get()
{
	local completion
	completion="jail network"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion=

		if [ "${COMP_WORDS[3]}" = "jail" ]; then
			case "${prev}" in
				-n) completion="$(_func_appjail_get_networks)" ;;
				*) completion="-e -H -I -p -t -n $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_NAT_} ${_APPJAIL_KEYWORDS_NAT_JAIL_}" ;;
			esac
		elif [ "${COMP_WORDS[3]}" = "network" ]; then
			case "${prev}" in
				*) completion="-e -H -I -p -t $(_func_appjail_get_networks) ${_APPJAIL_KEYWORDS_NAT_} ${_APPJAIL_KEYWORDS_NAT_NETWORK_}" ;;
			esac
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_nat_add()
{
	local completion
	completion="jail network"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		completion=

		if [ "${COMP_WORDS[3]}" = "jail" ]; then
			case "${prev}" in
				-n) completion="$(_func_appjail_get_networks)" ;;
				-e|-o) completion="$(_func_appjail_get_interfaces)" ;;
				-I) completion="$(_func_appjail_get_addresses)" ;;
				*) completion="-N -n -e -I -l -o $(_func_appjail_get_jails)" ;;
			esac
		elif [ "${COMP_WORDS[3]}" = "network" ]; then
			case "${prev}" in
				-e|-o) completion="$(_func_appjail_get_interfaces)" ;;
				-I) completion="$(_func_appjail_get_addresses)" ;;
				*) completion="-e -I -l -o $(_func_appjail_get_networks)" ;;
			esac
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_makejail()
{
	local completion
	completion="-c -e -V -a -B -b -f -j -o -V -A -d -E -u -l"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		case "${prev}" in
			-d|-u) completion="$(_func_appjail_get_makejails)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_logs()
{
	local completion
	completion="list read remove tail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			list|read|remove|tail) _appjail_logs_${state} ;;
		esac
	fi
}

_appjail_logs_tail()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_logs_remove()
{
	local completion
	completion="all -g $(_func_appjail_get_logs)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		if [ "${prev}" = "-g" ]; then
			COMPREPLY=($(compgen -W "$(_func_appjail_get_logs)" -- "${cur}"))
		elif [ ${COMP_CWORD} -eq 6 ]; then
			COMPREPLY=($(compgen -W "-g $(_func_appjail_get_logs)" -- "${cur}"))
		fi
	fi
}

_appjail_logs_read()
{
	local completion
	completion="$(_func_appjail_get_logs)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_logs_list()
{
	local completion
	completion="-e -H -p $(_func_appjail_get_logs)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_login()
{
	local completion
	completion="-u $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -le 4 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_limits()
{
	local completion
	completion="get list off on remove set stats"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			get|list|off|on|remove|set|stats) _appjail_limits_${state} ;;
		esac
	fi
}

_appjail_limits_stats()
{
	local completion
	completion="-e -H -h -I -p -t $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_LIMITS_RESOURCES_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_limits_set()
{
	local completion
	completion="-E -e -N -n $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local resource
	for resource in ${_APPJAIL_KEYWORDS_LIMITS_RESOURCES_}; do
		local action
		for action in ${_APPJAIL_KEYWORDS_LIMITS_ACTIONS_}; do
			completion="${completion} ${resource}:${action}="
		done
	done

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_limits_remove()
{
	local completion
	completion="all nro keyword"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local completion=

		if [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[3]}" = "all" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -eq 5 ] && [ "${COMP_WORDS[3]}" = "nro" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[3]}" = "keyword" ]; then
			completion="-n"
		elif [ ${COMP_CWORD} -eq 6 ] && [ "${COMP_WORDS[3]}" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -ge 7 ] && [ "${COMP_WORDS[3]}" ]; then
			completion="${_APPJAIL_KEYWORDS_LIMITS_}"
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_limits_on()
{
	_appjail_limits_off
}

_appjail_limits_off()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_limits_list()
{
	_appjail_limits_get
}

_appjail_limits_get()
{
	local completion
	completion="-e -H -I -i -p -t -n $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_LIMITS_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_label()
{
	local completion
	completion="add get list remove"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			add|get|list|remove) _appjail_label_${state} ;;
		esac
	fi
}

_appjail_label_remove()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_labels "${prev}")" -- "${cur}"))
	fi
}

_appjail_label_list()
{
	_appjail_label_get
}

_appjail_label_get()
{
	local completion
	completion="-e -H -I -p -t -l $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_LABEL_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_label_add()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_jail()
{
	local completion
	completion="boot clean create destroy get list mark priority rename"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			boot|create|destroy|get|list|mark|priority|rename) _appjail_jail_${state} ;;
		esac
	fi
}

_appjail_jail_rename()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_jail_priority()
{
	local completion
	completion="-p"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 5 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_jail_mark()
{
	local completion
	completion="clean dirty locked unlocked"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_jail_list()
{
	local completion
	completion="-e -H -I -p -t -j ${_APPJAIL_KEYWORDS_JAIL_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} ]; then
		case "${prev}" in
			-j) completion="$(_func_appjail_get_jails)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_jail_get()
{
	local completion
	completion="-e -H -I -p -t $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_JAIL_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_jail_destroy()
{
	local completion
	completion="-f -R $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_jail_create()
{
	local completion
	completion="-a -I -i -r -T -t -v"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-I) completion="clone+jail= clone+release= copy= empty export+jail= export+root= import+jail= import+root= standard tiny+export= tiny+import= zfs+export+jail= zfs+export+root= zfs+import+jail= zfs+import+root=" ;;
			-r) completion="$(_func_appjail_get_releases_name)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_jail_boot()
{
	local completion
	completion="off on"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
	fi
}

_appjail_image()
{
	local completion
	completion="export get import jail list remove update metadata"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			export|get|import|jail|list|remove|update|metadata) _appjail_image_${state} ;;
		esac
	fi
}

_appjail_image_metadata()
{
	local completion
	completion="del edit get info set"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			del|edit|get|info|set) _appjail_image_metadata_${state} ;;
		esac
	fi
}

_appjail_image_metadata_info()
{
	local completion
	completion="$(_func_appjail_get_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_image_metadata_get()
{
	local completion
	completion="-f -I -i -t $(_func_appjail_get_images) ${_APPJAIL_KEYWORDS_IMAGE_METADATA_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_image_metadata_edit()
{
	local completion
	completion="-f -I $(_func_appjail_get_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_image_metadata_del()
{
	local completion
	completion="-f -I -i -t $(_func_appjail_get_images) ${_APPJAIL_KEYWORDS_IMAGE_METADATA_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_image_update()
{
	local completion
	completion="$(_func_appjail_get_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_image_remove()
{
	local completion
	completion="-a -t $(_func_appjail_get_images)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_image_export()
{
	local completion
	completion="-f -c -n -t $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-c) completion="bzip gzip lrzip lz4 lzma lzop xz zstd" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_image_get()
{
	local completion
	completion="-e -H -I -p -t $(_func_appjail_get_images) ${_APPJAIL_KEYWORDS_IMAGE_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_image_list()
{
	local completion
	completion="-e -H -I -i -p -t $(_func_appjail_get_images) ${_APPJAIL_KEYWORDS_IMAGE_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_help()
{
	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${_APPJAIL_COMPLETION_}" -- "${cur}"))
	fi
}

_appjail_healthcheck()
{
	local completion
	completion="get list remove run set"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			get|list|remove|run|set) _appjail_healthcheck_${state} ;;
		esac
	fi
}

_appjail_healthcheck_get()
{
	local completion
	completion="-e -H -I -i -p -t -n $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_HEALTHCHECK_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_healthcheck_list()
{
	_appjail_healthcheck_get
}

_appjail_healthcheck_remove()
{
	local completion
	completion="all nro"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local completion=

		if [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[3]}" = "all" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -eq 5 ] && [ "${COMP_WORDS[3]}" = "nro" ]; then
			completion="$(_func_appjail_get_jails)"
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_healthcheck_run()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_healthcheck_set()
{
	local completion
	completion="-E -e -h -i -K -k -l -N -n -R -r -S -s -T -t -u $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-l|-S) completion="$(_func_appjail_get_signals)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_fstab()
{
	local completion
	completion="all jail"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			all|jail) _appjail_fstab_${state} ;;
		esac
	fi
}

_appjail_fstab_all()
{
	local completion
	completion="-e compile get list mounted mount remove set umount"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			get|list|remove|set) _appjail_fstab_${state} ;;
		esac
	fi
}

_appjail_fstab_jail()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		local completion
		completion="compile get list mounted mount remove set umount"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 5 ]; then
		local state
		state="${COMP_WORDS[4]}"

		case "${state}" in
			get|list|remove|set) _appjail_fstab_${state} ;;
		esac
	fi
}

_appjail_fstab_get()
{
	local completion
	completion="-e -H -I -p -t -n ${_APPJAIL_KEYWORDS_FSTAB_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_fstab_list()
{
	_appjail_fstab_get
}

_appjail_fstab_remove()
{
	local completion
	completion="all nro"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[2]}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -eq 5 ] && [ "${COMP_WORDS[2]}" = "nro" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_fstab_set()
{
	local completion
	completion="-d -m -E -e -p -D -N -n -o -P -t"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_fetch()
{
	local completion
	completion="debootstrap destroy empty list local src www"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			debootstrap|destroy|empty|list|local|src|www) _appjail_fetch_${state} ;;
		esac
	fi
}

_appjail_fetch_debootstrap()
{
	local completion
	completion="-A -a -c -m -r -S $(_func_appjail_get_debootstrap_scripts)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_fetch_destroy()
{
	local completion
	completion="-f -R -a -v $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_fetch_empty()
{
	local completion
	completion="-a -v"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_fetch_list()
{
	local completion
	completion="$(appjail fetch list | tail -n +2 | awk '{print $1"/"$2}' | sort | uniq)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_fetch_local()
{
	local completion
	completion="-C -a -r -u -v"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_fetch_src()
{
	local completion
	completion="-b -D -I -k -N -R -a -j -K -s"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_fetch_www()
{
	local completion
	completion="-C -a -r -u -v"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_expose()
{
	local completion
	completion="get list off on remove set status"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			get|list|off|on|remove|set|status) _appjail_expose_${state} ;;
		esac
	fi
}

_appjail_expose_get()
{
	local completion
	completion="-e -H -I -i -p -t -n $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_EXPOSE_}"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_expose_list()
{
	_appjail_expose_get
}

_appjail_expose_off()
{
	_appjail_expose_on
}

_appjail_expose_on()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_expose_remove()
{
	local completion
	completion="all nro"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local completion=

		if [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[3]}" = "all" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -eq 5 ] && [ "${COMP_WORDS[3]}" = "nro" ]; then
			completion="$(_func_appjail_get_jails)"
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_expose_set()
{
	local completion
	completion="-k -p -E -e -t -u -I -i -l -N -n -o $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-k) completion="$(_func_appjail_get_networks)" ;;
			-I) completion="$(_func_appjail_get_addresses)" ;;
			-i|-o) completion="$(_func_appjail_get_interfaces)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_expose_status()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_etcupdate()
{
	local completion
	completion="jail release"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			jail|release) _appjail_etcupdate_${state} ;;
		esac
	fi
}

_appjail_etcupdate_jail()
{
	local completion
	completion="-m $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-m) completion="build diff extract resolve revert status" ;;
			*) completion="$(_func_appjail_get_jails)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_etcupdate_release()
{
	local completion
	completion="-a -v -m $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
			-m) completion="build diff extract resolve revert status" ;;
		esac
		
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_enabled()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 3 ]; then
		local completion
		completion="start stop run"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		local completion

		case "${prev}" in
			start) completion="-c -I -i -s -t -V" ;;
			stop) completion="-I -i -p -V" ;;
			run) completion="-i -p -V" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_enable()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 3 ]; then
		local completion
		completion="start stop run"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local completion

		case "${COMP_WORDS[3]}" in
			start) completion="-c -I -i -s -t -V" ;;
			stop) completion="-I -i -p -V" ;;
			run) completion="-i -p -V" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_disable()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 3 ]; then
		local completion
		completion="start stop run"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -eq 4 ]; then
		local completion

		case "${prev}" in
			start) completion="-c -I -i -s -t -V" ;;
			stop) completion="-I -i -p -V" ;;
			run) completion="-i -p -V" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_devfs()
{
	local completion
	completion="append apply applyset del delset get list load remove ruleset set show showsets status"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			append|apply|applyset|del|delset|get|list|load|remove|ruleset|set|show|status) _appjail_devfs_${state} ;;
		esac
	fi
}

_appjail_devfs_append()
{
	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${COMP_WORDS[3]}")) 
	fi
}

_appjail_devfs_apply()
{
	local completion
	completion="-r $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	else
		if [ "${COMP_WORDS[3]}" = "-r" ]; then
			if [ ${COMP_CWORD} -eq 4 ] && [ "${prev}" = "-r" ]; then
				COMPREPLY=($(compgen -W "auto $(_func_appjail_get_rulesets)" -- "${cur}"))
			elif [ ${COMP_CWORD} -eq 5 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
			elif [ ${COMP_CWORD} -eq 6 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_rulenum "${prev}" -- "${cur}")"))
			fi
		else
			if [ ${COMP_CWORD} -eq 4 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_rulenum "${prev}" -- "${cur}")"))
			fi
		fi
	fi
}

_appjail_devfs_applyset()
{
	local completion
	completion="-r $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	else
		if [ "${COMP_WORDS[3]}" = "-r" ]; then
			if [ ${COMP_CWORD} -eq 4 ] && [ "${prev}" = "-r" ]; then
				COMPREPLY=($(compgen -W "auto $(_func_appjail_get_rulesets)" -- "${cur}"))
			elif [ ${COMP_CWORD} -eq 5 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
			fi
		fi
	fi
}

_appjail_devfs_del()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${COMP_WORDS[3]}")) 
	elif [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_rulenum "${prev}" -- "${cur}")"))
	fi
}

_appjail_devfs_delset()
{
	local completion
	completion="-q $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -eq 4 ]; then
		if [ "${prev}" = "-q" ]; then
			COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}")) 
		fi
	fi
}

_appjail_devfs_get()
{
	local completion
	completion="-e -H -I -i -p -t -n $(_func_appjail_get_jails) ${_APPJAIL_KEYWORDS_DEVFS_}"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
}

_appjail_devfs_list()
{
	_appjail_devfs_get
}

_appjail_devfs_load()
{
	local completion
	completion="-r $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	else
		if [ "${COMP_WORDS[3]}" = "-r" ]; then
			if [ ${COMP_CWORD} -eq 4 ] && [ "${prev}" = "-r" ]; then
				COMPREPLY=($(compgen -W "auto $(_func_appjail_get_rulesets)" -- "${cur}"))
			elif [ ${COMP_CWORD} -eq 5 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
			fi
		fi
	fi
}

_appjail_devfs_remove()
{
	local completion
	completion="all nro"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local completion=

		if [ ${COMP_CWORD} -eq 4 ] && [ "${COMP_WORDS[3]}" = "all" ]; then
			completion="$(_func_appjail_get_jails)"
		elif [ ${COMP_CWORD} -eq 5 ] && [ "${COMP_WORDS[3]}" = "nro" ]; then
			completion="$(_func_appjail_get_jails)"
		fi

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	fi
}

_appjail_devfs_ruleset()
{
	local completion
	completion="assign get remove"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			assign|get|remove) _appjail_devfs_ruleset_${state} ;;
		esac
	fi
}

_appjail_devfs_ruleset_assign()
{
	local completion
	completion="-r $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	else
		if [ "${COMP_WORDS[4]}" = "-r" ]; then
			if [ ${COMP_CWORD} -eq 5 ] && [ "${prev}" = "-r" ]; then
				COMPREPLY=($(compgen -W "auto $(_func_appjail_get_rulesets)" -- "${cur}"))
			elif [ ${COMP_CWORD} -eq 6 ]; then
				COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${cur}"))
			fi
		fi
	fi
}

_appjail_devfs_ruleset_get()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	if [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_devfs_ruleset_remove()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	if [ ${COMP_CWORD} -eq 4 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_devfs_set()
{
	local completion
	completion="-E -e -N -n $(_func_appjail_get_jails)"

	COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
}

_appjail_devfs_show()
{
	local completion
	completion="-N -r $(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
	else
		if [ "${prev}" = "-r" ]; then
			COMPREPLY=($(compgen -W "auto $(_func_appjail_get_rulesets)" -- "${cur}"))
		else
			COMPREPLY=($(compgen -W "${completion}" -- "${cur}")) 
		fi
	fi
}

_appjail_devfs_status()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_deleteOld()
{
	local completion
	completion="jail release"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			jail|release) _appjail_deleteOld_${state} ;;
		esac
	fi
}

_appjail_deleteOld_jail()
{
	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${COMP_WORDS[3]}")) 
	fi
}

_appjail_deleteOld_release()
{
	local completion
	completion="-a -v $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_cpuset()
{
	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${COMP_WORDS[2]}")) 
	fi
}

_appjail_cmd()
{
	local completion
	completion="all chroot jaildir jexec local"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			all|chroot|jexec|local) _appjail_cmd_${state} ;;
		esac
	fi
}

_appjail_cmd_all()
{
	local completion
	completion="-e -i chroot jaildir jexec local"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		local state
		state="${COMP_WORDS[3]}"

		case "${state}" in
			chroot|jexec|local) _appjail_cmd_${state} ;;
		esac
	fi
}

_appjail_cmd_chroot()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "cmd" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_cmd_jexec()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "cmd" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	else
		local completion
		completion="-l -U -u"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_cmd_local()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local from
	from="${COMP_WORDS[COMP_CWORD-2]}"

	if [ ${COMP_CWORD} -eq 3 -o ${COMP_CWORD} -eq 4 ] && [ "${from}" = "cmd" -o "${from}" = "all" ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	else
		local completion
		completion="-j -r"

		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_appjail_checkOld()
{
	local completion
	completion="jail release"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	elif [ ${COMP_CWORD} -ge 3 ]; then
		local state
		state="${COMP_WORDS[2]}"

		case "${state}" in
			jail|release) _appjail_checkOld_${state} ;;
		esac
	fi
}

_appjail_checkOld_jail()
{
	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "$(_func_appjail_get_jails)" -- "${COMP_WORDS[3]}")) 
	fi
}

_appjail_checkOld_release()
{
	local completion
	completion="-a -v $(_func_appjail_get_releases_name)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	local prev
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ${COMP_CWORD} -eq 3 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	elif [ ${COMP_CWORD} -ge 4 ]; then
		case "${prev}" in
			-a) completion="$(_func_appjail_get_releases_arch)" ;;
			-v) completion="$(_func_appjail_get_releases_version)" ;;
		esac

		COMPREPLY=($(compgen -W "${completion}" -- ${cur}))
	fi
}

_appjail_apply()
{
	local completion
	completion="$(_func_appjail_get_jails)"

	local cur
	cur="${COMP_WORDS[COMP_CWORD]}"

	if [ ${COMP_CWORD} -eq 2 ]; then
		COMPREPLY=($(compgen -W "${completion}" -- "${cur}"))
	fi
}

_func_appjail_get_releases_arch()
{
	if [ -z "${_APPJAIL_RELEASES_ARCH_}" ]; then
		_APPJAIL_RELEASES_ARCH_=$(appjail fetch list | awk '{print $1}' | tail -n +2 | sort | uniq)
	fi

	echo ${_APPJAIL_RELEASES_ARCH_}
}

_func_appjail_get_releases_version()
{
	if [ -z "${_APPJAIL_RELEASES_VERSION_}" ]; then
		_APPJAIL_RELEASES_VERSION_=$(appjail fetch list | awk '{print $2}' | tail -n +2 | sort | uniq)
	fi

	echo ${_APPJAIL_RELEASES_VERSION_}
}

_func_appjail_get_releases_name()
{
	if [ -z "${_APPJAIL_RELEASES_NAME_}" ]; then
		_APPJAIL_RELEASES_NAME_=$(appjail fetch list | awk '{print $3}' | tail -n +2 | sort | uniq)
	fi

	echo ${_APPJAIL_RELEASES_NAME_}
}

_func_appjail_get_jails()
{
	if [ -z "${_APPJAIL_JAILS_}" ]; then
		_APPJAIL_JAILS_=$(appjail jail list -eHIpt name)
	fi

	echo ${_APPJAIL_JAILS_}
}

_func_appjail_get_rulenum()
{
	local ruleset
	ruleset=$(_func_appjail_get_ruleset "${1}")

	appjail cmd jaildir devfs rule -s "${ruleset}" show 2> /dev/null | cut -d' ' -f1
}

_func_appjail_get_ruleset()
{
	local ruleset
	ruleset=$(appjail devfs ruleset get "${1}" 2> /dev/null)

	if [ -z "${ruleset}" ]; then
		return 0
	fi

	echo ${ruleset}
}

_func_appjail_get_rulesets()
{
	if [ -z "${_APPJAIL_DEVFS_RULESETS_}" ]; then
		_APPJAIL_DEVFS_RULESETS_=$(appjail devfs showsets)
	fi

	echo ${_APPJAIL_DEVFS_RULESETS_}
}

_func_appjail_get_networks()
{
	if [ -z "${_APPJAIL_NETWORKS_}" ]; then
		_APPJAIL_NETWORKS_=$(appjail network list -eHIpt name)
	fi

	echo ${_APPJAIL_NETWORKS_}
}

_func_appjail_get_interfaces()
{
	if [ -z "${_APPJAIL_INTERFACES_}" ]; then
		_APPJAIL_INTERFACES_=$(ifconfig -l)
	fi

	echo ${_APPJAIL_INTERFACES_}
}

_func_appjail_get_addresses()
{
	if [ -z "${_APPJAIL_ADDRESSES_}" ]; then
		_APPJAIL_ADDRESSES_=$(ifconfig | grep -Ee 'inet ' -e 'inet6 ' | cut -d' ' -f2)
	fi

	echo ${_APPJAIL_ADDRESSES_}
}

_func_appjail_get_debootstrap_scripts()
{
	if [ -z "${_APPJAIL_DEBOOTSTRAP_SCRIPTS_}" ]; then
		_APPJAIL_DEBOOTSTRAP_SCRIPTS_=$(pkg info -l debootstrap 2> /dev/null | grep -Ee 'share/debootstrap/scripts/[^/]+$' | cut -d$'\t' -f2 | sed -Ee 's/.+\/([^/]+)$/\1/')
	fi

	echo ${_APPJAIL_DEBOOTSTRAP_SCRIPTS_}
}

_func_appjail_get_signals()
{
	if [ -z "${_APPJAIL_SIGNALS_}" ]; then
		_APPJAIL_SIGNALS_=$(kill -l | grep -oEe 'SIG[A-Z]+')
	fi

	echo ${_APPJAIL_SIGNALS_}
}

_func_appjail_get_images()
{
	if [ -z "${_APPJAIL_IMAGES_}" ]; then
		_APPJAIL_IMAGES_=$(appjail image list -eHIpt name)
	fi

	echo ${_APPJAIL_IMAGES_}
}

_func_appjail_get_labels()
{
	appjail label list -H "$1" name 2> /dev/null
}

_func_appjail_get_logs()
{
	if [ -z "${_APPJAIL_LOGS_}" ]; then
		_APPJAIL_LOGS_=$(appjail logs | tail -n +2 | awk '{print $1"/"$2"/"$3"/"$4}')
	fi

	echo ${_APPJAIL_LOGS_}
}

_func_appjail_get_makejails()
{
	if [ -z "${_APPJAIL_MAKEJAILS_}" ]; then
		_APPJAIL_MAKEJAILS_=$(appjail makejail -l | tail -n +2 | awk '{print $1}')
	fi

	echo ${_APPJAIL_MAKEJAILS_}
}

_func_appjail_get_bridges()
{
	if [ -z "${_APPJAIL_BRIDGES_}" ]; then
		_APPJAIL_BRIDGES_=$(ifconfig -g bridge)
	fi

	echo ${_APPJAIL_BRIDGES_}
}

_func_appjail_get_jail_epairs()
{
	if [ -z "${_APPJAIL_JAIL_EPAIRS_}" ]; then
		_APPJAIL_JAIL_EPAIRS_=$(ifconfig -g appjail_epair | sed -Ee 's/^e[ab]_(.+)/\1/')
	fi

	echo ${_APPJAIL_JAIL_EPAIRS_}
}

_func_appjail_get_oci_images()
{
	if [ -z "${_APPJAIL_OCI_IMAGES_}" ]; then
		_APPJAIL_OCI_IMAGES_=$(appjail cmd jaildir buildah images 2> /dev/null | tail -n +2 | awk '{print $3}')
	fi

	echo ${_APPJAIL_OCI_IMAGES_}
}

_func_appjail_get_oci_containers()
{
	if [ -z "${_APPJAIL_OCI_CONTAINERS_}" ]; then
		_APPJAIL_OCI_CONTAINERS_=$(appjail cmd jaildir buildah containers --notruncate 2> /dev/null | tail -n +2 | awk '{print $5}')
	fi

	echo ${_APPJAIL_OCI_CONTAINERS_}
}

_func_appjail_get_volumes()
{
	appjail volume list -H "$1" name 2> /dev/null
}

complete -F _appjail -o nospace -o bashdefault -o default -o nosort appjail
