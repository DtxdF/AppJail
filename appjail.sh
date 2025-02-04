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
	set -T

	. "${CONFIG}"

	if [ `id -u` -ne 0 ]; then
		exec "${SCRIPTSDIR}/ajuser.sh" "$@"
	fi

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

	if [ -z "${APPJAIL_KILL_TREE}" ]; then
		# To avoid using kill_tree.sh more times than necessary.
		export APPJAIL_KILL_TREE=1

		local kill_tree_cmd
		kill_tree_cmd=`lib_escape_string "${SCRIPTSDIR}/kill_tree.sh"`

		local config_file
		config_file=`lib_escape_string "${CONFIG}"`

		lib_atexit_add "\"${kill_tree_cmd}\" -c \"${config_file}\" -p $$ > /dev/null 2>&1"
	fi

	if [ -n "${HOOKSDIR}" ] && [ -d "${HOOKSDIR}/pre.d" ]; then
		for hook in "${HOOKSDIR}/pre.d"/*; do
			if [ "${hook}" = "${HOOKSDIR}/pre.d/*" ]; then
				break
			fi

			if [ ! -x "${hook}" ]; then
				lib_debug "Missing execution bit permission for hook '${hook}'"
				continue
			fi

			local errlevel

			env \
				APPJAIL_CONFIG="${CONFIG}" \
				"${hook}" "${cmd}" "$@"

			errlevel=$?

			if [ ${errlevel} -ne 0 ]; then
				lib_err ${errlevel} "Hook '${hook}' exits with a non-zero exit status (pre)"
			fi
		done
	fi

	${cmd}_main "$@" || return $?

	if [ -d "${HOOKSDIR}" ]; then
		for hook in "${HOOKSDIR}/post.d"/*; do
			if [ "${hook}" = "${HOOKSDIR}/post.d/*" ]; then
				break
			fi

			if [ ! -x "${hook}" ]; then
				lib_debug "Missing execution bit permission for hook '${hook}'"
				continue
			fi

			local errlevel

			env \
				APPJAIL_CONFIG="${CONFIG}" \
				"${hook}" "${cmd}" "$@"

			errlevel=$?

			if [ ${errlevel} -ne 0 ]; then
				lib_err ${errlevel} "Hook '${hook}' exits with a non-zero exit status (post)"
			fi
		done
	fi
}

usage()
{
	echo "usage: appjail <command> [<args> ...]" >&2
	exit 64 # EX_USAGE
}

main "$@"
