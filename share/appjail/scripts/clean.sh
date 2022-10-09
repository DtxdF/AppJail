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
	local config
	local jail dirty_jails

	while getopts ":c:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done

	if [ -z "${config}" ]; then
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

	for jail in `ls ${APPSDIR}`; do
		if [ -f "${APPSDIR}/${jail}/.${jail}" ]; then
			continue
		fi

		dirty_jails="${dirty_jails} ${jail}"
	done

	if [ -n "${dirty_jails}" ]; then
		/bin/sh "${SCRIPTSDIR}/rm.sh" -c "${config}" -r "${APPSDIR}" "${dirty_jails}"
	else
		lib_debug "Nothing to do."
	fi
}

help()
{
	usage

	echo
	echo "  -c config        Path to the appjail configuration."
}

usage()
{
	echo "usage: clean.sh -c config"
}

main $@
