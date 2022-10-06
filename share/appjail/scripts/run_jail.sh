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
	local jail_conf
	local appjail
	local cmd

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	while getopts ":sSCa:c:" _o; do
		case "${_o}" in
			s|S|C)
				cmd="-${_o}"
				;;
			a)
				appjail="${OPTARG}"
				;;
			c)
				config="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
		esac
	done
	shift $((OPTIND-1))

	if [ -z "${config}" -o -z "${cmd}" -o -z "${appjail}" ]; then
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
	. "${LIBDIR}/tempfile"
	. "${LIBDIR}/replace"
	. "${LIBDIR}/atexit"
	. "${LIBDIR}/jail"

	lib_atexit_init

	if [ ! -d "${APPSDIR}/${appjail}" ]; then
		lib_err ${EX_NOINPUT} "The ${appjail} appjail does not exists."
	fi

	if [ ! -f "${APPSDIR}/${appjail}/.${appjail}" ]; then
		lib_err ${EX_NOINPUT} "The ${appjail} appjail exists, but it seems to have an incomplete installation."
	fi

	if [ ! -f "${APPSDIR}/${appjail}/init" ]; then
		lib_err ${EX_NOINPUT} "The init script does not exists in ${APPSDIR}/${appjail}."
	fi

	if ! lib_jail_exists "${appjail}"; then
		lib_err ${EX_SOFTWARE}  "${appjail} is not running."
	fi

	init_script="${APPSDIR}/${appjail}/init"

	env \
		APPJAIL_ROOTDIR="${APPSDIR}/${appjail}" \
		APPJAIL_JAILDIR="${APPSDIR}/${appjail}/jail" \
		APPJAIL_JAILNAME="${appjail}" \
		/bin/sh "${SCRIPTSDIR}/run_init.sh" ${cmd} -c "${config}" -i "${init_script}" -- $@
}

help()
{
	usage

	echo
	echo "  -s                  Run the *start functions."
	echo "  -S                  Run the *stop functions."
	echo "  -C                  Run the *cmd functions."
	echo "  -c config           Path to the appjail configuration."
	echo "  -a appjail          Name of the appjail application."
}

usage()
{
	echo "usage: run_jail.sh [-s | -S | -C] -c config -a appjail -- [args...]"
}

main $@
