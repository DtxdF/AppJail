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
	local config jail root_dir

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	while getopts ":c:r:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			r)
				root_dir="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
		esac
	done
	shift $((OPTIND-1))

	if [ -z "${config}" -o -z "${root_dir}" ]; then
		usage
		exit 64 # EX_NOINPUT
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exists or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/jail"
	. "${LIBDIR}/mount"

	for jail in $@; do
		if [ ! -d "${root_dir}/${jail}" ]; then
			lib_warn "${jail} does not exists. Skipping..."
			continue
		fi

		if lib_jail_exists "${jail}"; then
			lib_warn "${jail} is currently running. Skipping..."
			continue
		fi

		if lib_check_mount "${root_dir}/${jail}"; then
			lib_warn "${jail} has a mountpoint mounted in its root directory. Skipping..."
			continue
		fi

		lib_debug "Removing ${jail}..."

		chflags -R noschg "${root_dir}/${jail}"
		rm -rf "${root_dir}/${jail}"

		lib_debug "${jail} was removed."
	done
}

help()
{
	usage

	echo
	echo "  -c config        Path to the appjail configuration."
	echo "  -r root_dir      Root directory."
	echo "  jail             The jail to remove. May be used multiples times."
}

usage()
{
	echo "usage: rm.sh -c config -r root_dir jail..."
}

main $@
