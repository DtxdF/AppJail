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
	local appjail config jail_name cache_name realpath_name
	local opt_cache

	if [ $# -eq 0 ]; then
		usage
		exit 64 # EX_USAGE
	fi

	opt_cache=1

	while getopts ":Cn:a:c:" _o; do
		case "${_o}" in
			C)
				opt_cache=0
				;;
			a)
				appjail="${OPTARG}"
				;;
			c)
				config="${OPTARG}"
				;;
			n)
				jail_name="${OPTARG}"
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

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exists or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/mksum"
	. "${LIBDIR}/cache"
	. "${LIBDIR}/replace"

	set -e

	mkdir -p "${APPSDIR}"

	# A little optimization
	realpath_name=`realpath "${appjail}"`
	cache_name=`lib_mksum_str "${realpath_name}"`

	if [ -z "${jail_name}" -a $opt_cache -eq 1 -a -f "${CACHEDIR}/apps/${cache_name}" ]; then
		lib_warn "Using cache names is a little optimization, but it is not necessary if you have a computer with a fast CPU and fast storage. Use the -C or -n flag to disallow it."
		jail_name=`head -1 "${CACHEDIR}/apps/${cache_name}"`
	elif [ -z "${jail_name}" ]; then
		lib_debug "Generating checksum..."
		jail_name=`lib_mksum "${appjail}"`

		lib_cache_name "${cache_name}" "${jail_name}"
	fi

	if [ -f "${APPSDIR}/${jail_name}/.${jail_name}" ]; then
		lib_err ${EX_DATAERR} "The `basename \"${appjail}\"` (${jail_name}) appjail is already installed."
	fi

	if [ -d "${APPSDIR}/${jail_name}" ]; then
		lib_warn "${APPSDIR}/${jail_name} is dirty. Removing..."

		/bin/sh "${SCRIPTSDIR}/rm.sh" -c "${config}" -r "${APPSDIR}" "${jail_name}"
	fi

	lib_debug "Installing `basename \"${appjail}\"` to ${APPSDIR}/${jail_name}..."

	mkdir -p "${APPSDIR}/${jail_name}"
	install_appjail "${APPSDIR}/${jail_name}" "${appjail}"

	touch "${APPSDIR}/${jail_name}/.${jail_name}"

	lib_debug "`basename \"${appjail}\"` was installed successfully."
}

install_appjail()
{
	local output_dir appjail
	local _d

	output_dir="$1"
	appjail="$2"

	if [ -z "${appjail}" ]; then
		lib_err ${EX_USAGE} "usage: install_appjail path/to/some/directory path/to/some/appjail"
	fi

	_d="`lib_replace %FILE% \"${appjail}\" \"${DECOMPRESS_CMD}\"`"
	_d="`lib_replace %DIRECTORY% \"${output_dir}\" \"${_d}\"`"

	eval ${_d}
}

help()
{
	usage

	echo
	echo "  -C                             Disallow cache names. This flag is recommendable if you have a fast"
	echo "                                 CPU and a fast storage."
	echo "  -n appjail_name                Appjail name. If this flag is used, -C will do nothing. This flag"
	echo "                                 is better than use -C and better than generating a checksum name."
	echo "  -a appjail                     Path to the appjail application."
	echo "  -c path/to/appjail.conf        Path to the appjail configuration."
}

usage()
{
	echo "usage: install_appjail.sh [-C] [-n appjail_name] -a path/to/some/appjail -c path/to/appjail.conf"
}

main $@
