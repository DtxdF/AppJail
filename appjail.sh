#!/bin/sh
#
# Copyright (c) 2022-2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
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

APPJAIL_PROGRAM="%%PREFIX%%/bin/appjail"
CONFIG="%%PREFIX%%/share/appjail/files/config.conf"

main()
{
	. "${CONFIG}"
	. "${LIBDIR}/load"

	# For convenience, these will be loaded.
	lib_load "${LIBDIR}/sysexits"
	lib_load "${LIBDIR}/atexit"
	lib_load "${LIBDIR}/log"
	lib_load "${LIBDIR}/check_func"
	lib_load "${LIBDIR}/zfs"

	# Create the data directory for functions that use it at startup.
	if ! lib_zfs_mkroot; then
		lib_err ${EX_IOERR} "Error creating ${DATADIR}"
	fi

	lib_init_logtime

	if [ `id -u` -ne 0 ]; then
		lib_err ${EX_NOPERM} "AppJail is intended to be run as root. Use a tool such as doas(1), sudo(8) or su(1)."
	fi

	local cmd=$1; shift
	if [ -z "${cmd}" ]; then
		usage
	fi
	
	if [ ! -x "${COMMANDS}/${cmd}" ]; then
		lib_err ${EX_NOINPUT} "Command \"${cmd}\" does not exist."
	fi

	lib_load "${COMMANDS}/${cmd}"
	
	# logging
	if [ "${ENABLE_LOGGING_OUTPUT}" != "0" -a -z "${AJ_LOG_SESSION_ID}" ]; then
		lib_debug "Running: ${SESSION_ID_NAME}"

		local errlevel

		local session_id
		session_id=`sh -c "${SESSION_ID_NAME}"`

		errlevel=$?
		if [ ${errlevel} -ne 0 ]; then
			lib_err ${errlevel} "{SESSION_ID_NAME} exits with a non-zero exit status."
		fi

		if lib_check_ispath "${session_id}"; then
			lib_err ${EX_DATAERR} -- "${session_id}: invalid log name."
		fi

		lib_zfs_mklogdir "commands" "${cmd}" "output"

		exec env \
			AJ_LOG_SESSION_ID="${session_id}" \
			script -a -t "${SCRIPT_TIME}" -- \
				"${LOGDIR}/commands/${cmd}/output/${session_id}" \
				"${APPJAIL_PROGRAM}" \
				"${cmd}" \
				"$@"

		exit 0
	fi

	if ! lib_check_func "${cmd}_main"; then
		lib_err ${EX_SOFTWARE} "${cmd}_main function does not exist in the ${cmd} command."
	fi

	lib_atexit_init

	${cmd}_main "$@"
}

usage()
{
	echo "usage: appjail cmd [args ...]" >&2
	exit 64 # EX_USAGE
}

main "$@"
