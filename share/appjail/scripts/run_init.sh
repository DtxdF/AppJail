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

main()
{
	local _o
	local config custom_stage function script

	if [ $# -eq 0 ]; then
		usage
		exit 64 # EX_USAGE
	fi

	while getopts ":ACcSsF:f:" _o; do
		case "${_o}" in
			A)
				function="apply"
				;;
			C)
				function="cmd"
				;;
			c)
				function="create"
				;;
			S)
				function="stop"
				;;
			s)
				function="start"
				;;
			F)
				custom_stage="${OPTARG}"
				;;
			f)
				config="${OPTARG}"
				;;
			*)
				main # usage
				;;
		esac
	done
	shift $((OPTIND-1))

	script="$1"; shift

	if [ -n "${custom_stage}" ]; then
		function="custom:${custom_stage}"
	fi

	if [ -z "${config}" -o -z "${function}" -o -z "${script}" ]; then
		main # usage
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/log"
	lib_load "${LIBDIR}/check_func"

	if [ -n "${custom_stage}" ]; then
		if ! lib_check_stagename "${custom_stage}"; then
			lib_err ${EX_DATAERR} -- "${custom_stage}: Invalid stage name."
		fi
	fi

	run_cmd "${script}" "${function}" "$@"
}

usage()
{
	echo "usage: run_init.sh [[-A | -C | -c | -S | -s] | -F custom_stage] -f config init_script [args ...]"
}

run_cmd()
{
	local __appjail_script__="$1"
	local __appjail_function__="$2"

	shift 2

	if [ -z "${__appjail_script__}" -o -z "${__appjail_function__}" ]; then
		lib_err ${EX_USAGE} "usage: run_cmd init_script function [args...]"
	fi

	if [ ! -x "${__appjail_script__}" ]; then
		lib_err ${EX_NOPERM} "Cannot execute \`${__appjail_script__}\`: No such file exists or it does not have the execute bit."
	fi

	lib_debug "Running initscript \`${__appjail_script__}\` ..."

	(
	__appjail_errlevel__=0

	. "${__appjail_script__}"

	if lib_check_func "pre${__appjail_function__}"; then
		lib_debug "Running pre${__appjail_function__}() ..."

		pre${__appjail_function__} "$@"; __appjail_errlevel__=$?

		lib_debug "pre${__appjail_function__}() exits with status code ${__appjail_errlevel__}"
	fi

	if [ ${__appjail_errlevel__} -ne 0 ]; then
		lib_debug -- "${__appjail_function__}() will not run because pre${__appjail_function__}() exits with a non-zero exit status."
	fi

	if [ ${__appjail_errlevel__} -eq 0 ] && lib_check_func "${__appjail_function__}"; then
		${__appjail_function__} "$@"; __appjail_errlevel__=$?

		lib_debug -- "${__appjail_function__}() exits with status code ${__appjail_errlevel__}"
	fi

	if lib_check_func "post${__appjail_function__}"; then
		post${__appjail_function__} "$@"

		lib_debug "post${__appjail_function__}() exits with status code $?"
	fi

	lib_debug "\`${__appjail_script__}\` exits with status code ${__appjail_errlevel__}"

	exit ${__appjail_errlevel__}
	)

	return $?
}

main "$@"
