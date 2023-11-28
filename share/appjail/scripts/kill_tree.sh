#!/bin/sh
#
# Copyright (c) 2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
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

main()
{
	local _o
	local config
	local pid

	if [ $# -eq 0 ]; then
		usage
		exit ${EX_USAGE}
	fi

	while getopts ":c:p:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			p)
				pid="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done

	if [ -z "${config}" -o -z "${pid}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/log"
	lib_load "${LIBDIR}/check_func"
	lib_load "${LIBDIR}/random"

	if ! lib_check_number "${pid}"; then
		lib_err ${EX_DATAERR} -- "${pid}: invalid PID."
	fi

	# Kill process tree.
	get_proc_tree ${pid} | tail -r | while read pid
	do
		safe_kill ${pid}
	done
}

safe_kill()
{
	local pid

	pid=$1

	if [ -z "${pid}" ]; then
		echo "safe_kill pid"
		exit ${EX_USAGE}
	fi

	local retry=1 total=3

	while [ ${retry} -le ${total} ]; do
		lib_debug "Sending SIGTERM (${retry}/${total}) -> ${pid}"

		kill ${pid} > /dev/null 2>&1

		if ! check_proc ${pid}; then
			return 0
		fi

		sleep `random_number 1 3`.`random_number 3 9`

		retry=$((retry+1))
	done

	if check_proc ${pid}; then
		lib_debug "Sending SIGKILL -> ${pid}"

		kill -KILL ${pid} > /dev/null 2>&1
	fi
}

check_proc()
{
	local pid

	pid=$1

	if [ -z "${pid}" ]; then
		echo "check_proc pid"
		exit ${EX_USAGE}
	fi

	if [ `ps -o pid -p ${pid} | wc -l | tr -d ' '` -eq 2 ]; then
		return 0
	else
		return 1
	fi
}

get_proc_tree()
{
	local ppid pid

	ppid=$1

	if [ -z "${ppid}" ]; then
		echo "get_proc_tree ppid"
		exit ${EX_USAGE}
	fi

	for pid in `pgrep -P ${ppid}`; do
		echo ${pid}

		get_proc_tree ${pid}
	done
}

usage()
{
	echo "usage: kill_tree.sh -c config -p pid"
}

main "$@"
