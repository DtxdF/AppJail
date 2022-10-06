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
	local config root_dir
	local old new
	local abs_old abs_new
	local opt_apps opt_jails

	opt_apps=0
	opt_jails=0

	while getopts ":ajc:" _o; do
		case "${_o}" in
			a)
				opt_apps=1
				;;
			j)
				opt_jails=1
				;;
			c)
				config="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done
	shift $((OPTIND-1))

	old="$1"
	new="$2"

	if [ -z "${old}" -o -z "${new}" -o -z "${config}" -o ${opt_apps} -eq ${opt_jails} ]; then
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
	. "${LIBDIR}/replace"
	. "${LIBDIR}/jail"
	. "${LIBDIR}/mount"

	if [ ${opt_apps} -eq 1 ]; then
		root_dir="${APPSDIR}"
	else
		lib_replace_jaildir
		root_dir="${JAILDIR}"
	fi

	abs_old="${root_dir}/${old}"
	abs_new="${root_dir}/${new}"

	if [ "`dirname \"${abs_old}\"`" != "${root_dir}" -o "`basename \"${abs_old}\"`" != "${old}" ]; then
		lib_err ${EX_DATAERR} "The name of the current jail is invalid."
	fi

	if [ "`dirname \"${abs_new}\"`" != "${root_dir}" -o "`basename \"${abs_new}\"`" != "${new}" ]; then
		lib_err ${EX_DATAERR} "The name of the new jail is invalid."
	fi

	if [ ! -d "${abs_old}" ]; then
		lib_err ${EX_NOINPUT} "The ${abs_old} jail directory does not exists."
	fi

	if [ -e "${abs_new}" ]; then
		lib_err ${EX_DATAERR} "The ${abs_new} jail directory already exists."
	fi

	if lib_jail_exists "${old}"; then
		lib_err ${EX_SOFTWARE} "${old} is currently running."
	fi

	if lib_jail_exists "${new}"; then
		lib_err ${EX_SOFTWARE} "${new} is currently running."
	fi

	if lib_check_mount "${abs_old}"; then
		lib_err ${EX_SOFTWARE} "${old} has a node mounted in its root directory."
	fi

	if lib_check_mount "${abs_new}"; then
		lib_err ${EX_SOFTWARE} "${new} has a node mounted in its root directory."
	fi

	if [ ${opt_apps} -eq 1 ]; then
		mv "${abs_old}/.${old}" "${abs_old}/.${new}"
	fi

	mv "${abs_old}" "${abs_new}"
}

help()
{
	usage

	echo
	echo "  -a               Rename an appjail."
	echo "  -j               Rename a jail."
	echo "  -c config        Path to the appjail configuration."
	echo "  old              The current name of the jail."
	echo "  new              The new name of the jail."
}

usage()
{
	echo "usage: rename.sh [-a | -j] -c config old new"
}

main $@
