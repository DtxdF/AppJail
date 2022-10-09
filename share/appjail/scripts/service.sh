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
	local config jail_conf appjail
	local opt_start opt_stop

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	opt_start=0
	opt_stop=0

	while getopts ":sSa:c:" _o; do
		case "${_o}" in
			s)
				opt_start=1
				;;
			S)
				opt_stop=1
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

	if [ -z "${config}" -o ${opt_start} -eq ${opt_stop} ]; then
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

	if [ ! -f "${APPSDIR}/${appjail}/conf/jail.conf" ]; then
		lib_err ${EX_NOINPUT} "The template does exists in ${APPSDIR}/${appjail}."
	fi

	if [ ${opt_start} -eq 1 ]; then
		if lib_jail_exists "${appjail}"; then
			lib_err ${EX_SOFTWARE} "The ${appjail} is currently running."
		fi
	else
		if ! lib_jail_exists "${appjail}"; then
			lib_err ${EX_SOFTWARE}  "${appjail} is not running."
		fi
	fi

	lib_debug "Checking for required parameters..."

	if lib_req_jail_params "${APPSDIR}/${appjail}/conf/jail.conf"; then
		lib_err ${EX_USAGE} "There are required parameters. Use \`appjail edit -t -a \"${appjail}\"\` to edit it. See also \`appjail help set\`."
	fi

	lib_debug "Editing template \"${APPSDIR}/${appjail}/conf/jail.conf\""

	jail_conf="`lib_filter_jail \"${appjail}\" \"${APPSDIR}/${appjail}/conf/jail.conf\" \"${APPSDIR}/${appjail}/jail\"`" || exit $?
	lib_atexit_add rm -f "${jail_conf}"

	if [ ${opt_start} -eq 1 ]; then
		lib_create_jail "${jail_conf}" "${appjail}" &&
		/bin/sh "${SCRIPTSDIR}/run_jail.sh" -s -c "${config}" -a "${appjail}" -- $@
	else
		/bin/sh "${SCRIPTSDIR}/run_jail.sh" -S -c "${config}" -a "${appjail}" -- $@
		lib_remove_jail "${jail_conf}" "${appjail}"
	fi
}

help()
{
	usage

	echo
	echo "  -s               Start the from an appjail application."
	echo "  -S               Remove the jail from an appjail application."
	echo "  -c config        Path to the appjail configuration."
	echo "  -a appjail       Name of the appjail application."
}

usage()
{
	echo "usage: service.sh [-s | -S] -c config -a appjail -- [args]"
}

main $@
