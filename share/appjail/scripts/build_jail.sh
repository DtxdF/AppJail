#!/bin/sh
#
# Copyright (c) 2022, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

main()
{
	local _o _c
	local output config init_script
	local jail_name template
	local tempdir
	local dirs

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	while getopts ":d:o:c:i:j:t:" _o; do
		case "${_o}" in
			d)
				dirs="${dirs} ${OPTARG}"
				;;
			o)
				output="${OPTARG}.appjail"
				;;
			c)
				config="${OPTARG}"
				;;
			i)
				init_script="${OPTARG}"
				;;
			j)
				jail_name="${OPTARG}"
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

	if [ -z "${config}" -o -z "${init_script}" -o -z "${jail_name}" -o -z "${template}" ]; then
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

	lib_replace_jaildir

	if [ ! -d "${JAILDIR}/${jail_name}" ]; then
		lib_err ${EX_NOINPUT} "The ${jail_name} jail does not exists."
	fi

	template="${TEMPLATES}/${template}"
	if [ ! -f "${template}" ]; then
		lib_err ${EX_NOINPUT} "The ${template} template does not exists."
	fi

	if lib_jail_exists "${jail_name}"; then
		lib_err ${EX_SOFTWARE} "${jail_name} is currently running."
	fi

	if [ -z "${output}" ]; then
		output="${jail_name}.appjail"
	fi

	. "${LIBDIR}/tempfile"
	. "${LIBDIR}/copy"
	. "${LIBDIR}/atexit"

	set -e
	
	tempdir="`lib_generate_tempdir`"

	mkdir -p "${tempdir}/jail"
	mkdir -p "${tempdir}/conf"
	mkdir -p "${tempdir}/data"

	lib_debug "Mounting ${JAILDIR}/${jail_name} to ${tempdir}/jail"
	mount_nullfs -o ro "${JAILDIR}/${jail_name}" "${tempdir}/jail"

	# To prevent continuing if a error has ocurred
	lib_atexit_init
	lib_atexit_add set -e
	lib_atexit_add umount "${tempdir}/jail"
	lib_atexit_add rm -rf "${tempdir}"

	if [ ! -z "${dirs}" ]; then
		lib_debug "Copying ${dirs} to ${tempdir}/data..."
		lib_rcopy "${tempdir}/data" ${dirs}
	fi

	lib_debug "Copying ${init_script} as ${tempdir}/init"
	cp "${init_script}" "${tempdir}/init"
	chmod +x "${tempdir}/init"
	lib_debug "Copying ${template} as ${tempdir}/conf/jail.conf"
	cp "${template}" "${tempdir}/conf/jail.conf"

	_c="`lib_replace %FILE% \"${output}\" \"${COMPRESS_CMD}\"`"
	_c="`lib_replace %DIRECTORY% \"${tempdir}\" \"${_c}\"`"

	lib_debug "Generating jail installer: ${_c}"

	eval ${_c}

	lib_debug "Jail installer generated: ${output}"
}

help()
{
	usage

	echo
	echo "  -d dir                Copy the directory to the jail environment."
	echo "                        This directory will be an exact copy of its own tree."
	echo "                        This flag may be used multiples times."
	echo "  -o output             Appjail name without the .appjail extension."
	echo "  -c config             Path to appjail.conf."
	echo "  -i init_script        Init script executed when the appjail is started."
	echo "  -j jail_name          The name of the jail used by the appjail application."
	echo "  -t template           Template used by the appjail application."
}

usage()
{
	echo "usage: build [-d dir] [-o output] -c config -i init_script -j jail_name -t template"
}

main $@
