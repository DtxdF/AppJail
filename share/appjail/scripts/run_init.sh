#!/bin/sh
#
# Copyright (c) 2022, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

main()
{
	local _o
	local script config function

	if [ $# -eq 0 ]; then
		usage
		exit 64 # EX_USAGE
	fi

	while getopts ":sSCc:i:" _o; do
		case "${_o}" in
			s)
				function="start"
				;;
			S)
				function="stop"
				;;
			C)
				function="cmd"
				;;
			c)
				config="${OPTARG}"
				;;
			i)
				script="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done
	shift $((OPTIND-1))

	if [ -z "${config}" -o -z "${script}" -o -z "${function}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exists or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"

	run_cmd "${script}" "${function}" $@
}

help()
{
	usage

	echo
	echo "  -s                                 Run the *start functions."
	echo "  -S                                 Run the *stop functions."
	echo "  -C                                 Run the *cmd functions."
	echo "  -c path/to/appjail.conf            Path to the appjail configuration."
	echo "  -i path/to/some/init_script        Path to the init script."
}

usage()
{
	echo "usage: run_init.sh [-s | -S | -C] -c path/to/appjail.conf -i path/to/some/init_script -- args..."
}

run_cmd()
{
	local script

	script="$1"
	func="$2"

	shift 2

	if [ -z "${script}" -o -z "${func}" ]; then
		lib_err ${EX_USAGE} "usage: run_cmd path/to/some/init_script function [args...]"
	fi

	if [ ! -x "${script}" ]; then
		lib_err ${EX_NOINPUT} "You don't have permissions to run \`${script}\` or it does not exists."
	fi

	. "${LIBDIR}/check_func"
	# Paranoid method to not overwrite the run_init.sh functions.
	(
	_ret=0

	cd "`dirname \"${script}\"`"

	. "${script}"

	if lib_check_func "pre${func}"; then
		eval pre${func}
	fi

	_ret=$?

	if [ $? -eq 0 ] && lib_check_func "${func}"; then
		eval ${func} $@
	fi

	# Catch only the non-zero return values
	if [ ${_ret} -eq 0 ]; then
		_ret=$?
	fi

	if lib_check_func "post${func}"; then
		eval post${func}
	fi

	exit ${_ret}
	)

	return $?
}

main $@
