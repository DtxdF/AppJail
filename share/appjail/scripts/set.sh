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
	local key value
	local template

	while getopts ":a:c:t:" _o; do
		case "${_o}" in
			a)
				appjail="${OPTARG}"
				;;
			c)
				config="${OPTARG}"
				;;
			t)
				template="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done
	shift $((OPTIND-1))

	if [ -z "${appjail}" -o -z "${config}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/jail"

	if [ -z "${template}" ]; then
		template="${APPSDIR}/${appjail}/conf/jail.conf"
	fi

	if [ ! -f "${template}" ]; then
		lib_err ${EX_NOINPUT} "The \`${template}\` template does exists or you don't have permissions to read it."
	fi

	for param in $@; do
		key="`echo ${param} | cut -d= -f1`"
		value="`echo ${param} | cut -d= -f2-`"

		lib_set_param "${template}" "${key}" "${value}"
	done
}

help()
{
	usage

	echo
	echo "  -t template       Path to the temporary template."
	echo "  -a appjail        The name of the appjail."
	echo "  -c config         Path to the appjail configuration."
	echo "  keyN=value        The name of the key. Value is the key's value."
	echo "                    May be used multiples times."
}

usage()
{
	echo "usage: set.sh [-t template] -a appjail -c config key1=value key2=value ... keyN=value"
}

main $@
