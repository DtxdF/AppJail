#!/bin/sh
#
# Copyright (c) 2022, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

CONFIG=etc/appjail/appjail.conf

main()
{
	local cmd _o

	if [ $# -eq 0 ]; then
		usage
	fi

	while getopts ":c:" _o; do
		case "${_o}" in
			c)
				CONFIG="${OPTARG}"
				;;
			*)
				usage
				;;
		esac
	done
	shift $((OPTIND-1))

	if [ ! -f "${CONFIG}" ]; then
		echo "Unable to open configuration file." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${CONFIG}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/atexit"
	. "${LIBDIR}/log"

	lib_atexit_init

	cmd=$1
	if [ -z "${cmd}" ]; then
		usage
	fi

	if [ -x "${COMMANDS}/${cmd}" ]; then
		. "${COMMANDS}/${cmd}"
		. "${LIBDIR}/check_func"

		if ! lib_check_func "${cmd}_main"; then
			lib_err ${EX_SOFTWARE} "${cmd}_main function does not exists in the ${cmd} command."
		fi

		shift && eval ${cmd}_main $@
	else
		lib_err ${EX_NOINPUT} "Command \"${cmd}\" does not exists."
	fi
}

usage()
{
	echo "usage: appjail [-c config] cmd [args...]"

	# The constant is necessary because ${LIBDIR}/sysexits
	# has not been yet loaded.
	exit 64 # EX_USAGE
}

main $@
