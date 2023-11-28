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

EX_USAGE=64
EX_DATAERR=65
EX_NOINPUT=66

SLEEP_PID=

main()
{
	local algo="/sbin/sha256"
	local interval=60
	local hosts
	local hook

	while getopts ":a:i:h:H:" _o; do
		case "${_o}" in
			a)
				algo="${OPTARG}"
				;;
			i)
				interval="${OPTARG}"
				;;
			h)
				hosts="${OPTARG}"
				;;
			H)
				hook="${OPTARG}"
				;;
			*)
				usage
				exit ${EX_USAGE}
				;;
		esac
	done

	if [ -z "${hosts}" -o -z "${hook}" ]; then
		usage
		exit ${EX_USAGE}
	fi

	if ! which -s "${algo}"; then
		printf "%s\n" "${algo}: algo cannot be found." >&2
		exit ${EX_NOINPUT}
	fi

	if ! printf "%s" "${interval}" | grep -qEe '^[0-9]+$'; then
		printf "%s\n" "${interval}: invalid interval." >&2
		exit ${EX_DATAERR}
	fi

	if [ ! -f "${hosts}" ]; then
		touch -- "${hosts}" || exit $?
	fi

	if [ ! -f "${hook}" ]; then
		printf "%s\n" "${hook}: hook cannot be found." >&2
		exit ${EX_NOINPUT}
	fi

	trap "_ERRLEVEL=\$?; atexit; exit \${_ERRLEVEL}" SIGINT SIGQUIT SIGTERM EXIT

	local current_hosts current_hosts_sum

	while true; do
		current_hosts=`appjail-dns` || exit $?
		current_hosts_sum=`printf "%s\n" "${current_hosts}" | "${algo}"` || exit $?

		if [ `${algo} -q "${hosts}"` != ${current_hosts_sum} ]; then
			printf "%s\n" "${current_hosts}" > "${hosts}" || exit $?
			"${hook}" "${hosts}" || exit $?
		fi

		sleep "${interval}" &

		SLEEP_PID=$!

		wait ${SLEEP_PID} || exit $?
	done
}

usage()
{
	echo "usage: ajdns.sh [-a algo] [-i interval] -h hosts -H hook" >&2
}

atexit()
{
	if [ -n "${SLEEP_PID}" ]; then
		kill ${SLEEP_PID}
	fi
}

main "$@"
