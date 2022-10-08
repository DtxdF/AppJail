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
	local appjail config
	local file
	local opt_init_script opt_template

	opt_init_script=0
	opt_template=0

	while getopts ":ita:c:" _o; do
		case "${_o}" in
			i)
				opt_init_script=1
				;;
			t)
				opt_template=1
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
	
	if [ -z "${config}" -o -z "${appjail}" -o ${opt_init_script} -eq ${opt_template} ]; then
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

	if [ ${opt_template} -eq 1 ]; then
		file="${APPSDIR}/${appjail}/conf/jail.conf"
	else
		file="${APPSDIR}/${appjail}/init"
	fi

	if [ ! -f "${file}" ]; then
		lib_err ${EX_NOINPUT} "${file} does not exists."
	fi

	${EDITOR} "${file}"
}

help()
{
	usage
	
	echo
	echo "  -i                Edit the init script."
	echo "  -t                Edit the template."
	echo "  -a appjail        Name of the appjail."
	echo "  -c config         Path to the appjail configuration."
}

usage()
{
	echo "usage: edit.sh [-i | -t] -a appjail -c config"
}

main $@
