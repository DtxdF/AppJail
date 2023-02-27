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
	local cmd
	local args
	local custom_stage
	local config
	local initscript
	# For argument parsing
	local args_list arg
	local total_items current_index
	local parameter param_value

	if [ $# -eq 0 ]; then
		usage
		exit 64 # EX_USAGE
	fi

	while getopts ":CcSsa:F:f:" _o; do
		case "${_o}" in
			C|c|S|s)
				cmd="-${_o}"
				;;
			a)
				args="${OPTARG}"
				;;
			F)
				custom_stage="${OPTARG}"
				;;
			f)
				config="${OPTARG}"
				;;
			*)
				main # EX_USAGE
				;;
		esac
	done
	shift $((OPTIND-1))

	initscript="$1"; shift

	if [ -z "${cmd}" -o -z "${config}" -o -z "${initscript}" ]; then
		main # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/check_func"
	lib_load "${LIBDIR}/jail"
	lib_load "${LIBDIR}/log"

	# cleared
	set --
	if ! lib_check_empty "${args}"; then
		args_list=`lib_split_jailparams "${args}"`
		total_items=`printf "%s\n" "${args_list}" | wc -l`
		current_index=0

		while [ ${current_index} -lt ${total_items} ]; do 
			current_index=$((current_index+1))
			arg=`printf "%s\n" "${args_list}" | head -${current_index} | tail -n 1`
			
			parameter=`lib_jailparam_name "${arg}" =`

			if lib_check_empty "${parameter}"; then
				lib_err ${EX_DATAERR} "The parameter (${current_index}) is empty: ${arg}"
			fi

			param_value=`lib_jailparam_value "${arg}" =`

			if lib_check_empty "${param_value}"; then
				lib_err ${EX_DATAERR} "option requires an argument -- ${parameter}"
			fi

			set -- "$@" "--${parameter}" "${param_value}"
		done
	fi

	"${SCRIPTSDIR}/run_init.sh" -f "${config}" ${cmd} -F "${custom_stage}" "${initscript}" "$@"

}

usage()
{
	echo "usage: run_jail.sh [[-C | -c | -S | -s] | -F custom_stage] -f config [-a args] initscript"
}

main "$@"
