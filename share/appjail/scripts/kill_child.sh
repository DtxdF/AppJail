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
	local parent_pid
	local pid

	if [ $# -eq 0 ]; then
		usage
		exit ${EX_USAGE}
	fi

	while getopts ":c:P:p:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			P)
				parent_pid="${OPTARG}"
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

	if [ -z "${config}" -o -z "${pid}" -o -z "${parent_pid}" ]; then
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

	if ! lib_check_number "${parent_pid}"; then
		lib_err ${EX_DATAERR} -- "${parent_pid}: invalid parent PID."
	fi

	if ! lib_check_number "${pid}"; then
		lib_err ${EX_DATAERR} -- "${pid}: invalid PID."
	fi

	local current_parent_pid
	current_parent_pid=`get_ppid "${pid}"`

	if [ -z "${current_parent_pid}" ]; then
		lib_err ${EX_NOINPUT} "Cannot find parent pid of \`${pid}\`"
	fi

	if [ ${current_parent_pid} -eq ${parent_pid} ]; then
		lib_debug "Killing ${pid} ..."

		kill "${pid}"
	fi
}

get_ppid()
{
	local pid="$1"
	if [ -z "${pid}" ]; then
		echo "usage: get_pid pid" >&2
		exit 64 # EX_USAGE
	fi

	ps -p "${pid}" -o ppid | grep -v PPID | awk '{print $1}'
}

usage()
{
	echo "usage: kill_child.sh -c config -P parent_pid -p pid"
}

main "$@"
