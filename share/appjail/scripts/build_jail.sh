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
	local dirs jail_files jail_file jail_files_path
	local opt_huge opt_tiny

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	opt_huge=0
	opt_tiny=0

	while getopts ":HTR:d:o:r:c:i:j:t:" _o; do
		case "${_o}" in
			H)
				opt_huge=1
				;;
			T)
				opt_tiny=1
				;;
			R)
				jail_files="${jail_files} ${OPTARG}"
				;;
			d)
				dirs="${dirs} ${OPTARG}"
				;;
			o)
				output="${OPTARG}.appjail"
				;;
			r)
				jail_files_path="${OPTARG}"
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

	if [ -z "${config}" -o -z "${init_script}" -o -z "${jail_name}" -o -z "${template}" -o ${opt_tiny} -eq ${opt_huge} ]; then
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

	# To prevent continuing if a error has ocurred
	lib_atexit_init
	lib_atexit_add set -e

	if [ ${opt_tiny} -eq 1 ]; then
		lib_debug "Creating a tiny appjail..."
		lib_debug "Marking this appjail as tiny: `sysrc -f \"${tempdir}/conf/appjail.conf\" type=tiny`"

		if [ -z "${jail_files_path}" -a -z "${jail_files}" ]; then
			lib_warn "An appjail without files doesn't make much sense unless you are testing something..."
		fi

		if [ -n "${jail_files}" ]; then
			copy_files "${JAILDIR}/${jail_name}" "${tempdir}/jail" "${jail_files}"
		fi

		if [ -n "${jail_files_path}" ]; then
			if [ ! -f "${jail_files_path}" ]; then
				lib_err ${EX_NOINPUT} "The ${jail_files_path} file does not exists."
			fi

			lib_debug "Reading ${jail_files_path}..."

			while read jail_file; do
				copy_files "${JAILDIR}/${jail_name}" "${tempdir}/jail" "${jail_file}"
			done < "${jail_files_path}"
		fi
	else
		lib_debug "Creating a huge appjail..."
		lib_debug "Mounting ${JAILDIR}/${jail_name} to ${tempdir}/jail"
		mount_nullfs -o ro "${JAILDIR}/${jail_name}" "${tempdir}/jail"
		lib_atexit_add umount "${tempdir}/jail"
	fi

	# Clear
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

copy_files()
{
	local root dst
	local _f

	root="$1"
	dst="$2"

	if [ -z "${root}" -o -z "${dst}" ]; then
		lib_err ${EX_USAGE} "usage: copy_files root dst [file1 file2 ... fileN]"
	fi

	shift 2

	for _f in $@; do
		lib_debug "Copying \"${root}/${_f}\" to \"${dst}\"..."

		lib_copy "${root}" "${_f}" "${dst}"
	done
}

help()
{
	usage

	echo
	echo "  -H                    Create a huge appjail."
	echo "  -T                    Create a tiny appjail."
	echo "  -R path               It is only used if you are creating a tiny appjail."
	echo "                        Copy only this directory or file from jail to appjail's jail."
	echo "                        May be used multiples times."
	echo "                        This flag is ignored if you are creating a huge appjail."
	echo "  -d dir                Copy the directory to the jail environment."
	echo "                        This directory will be an exact copy of its own tree."
	echo "                        This flag may be used multiples times."
	echo "  -o output             Appjail name without the .appjail extension."
	echo "  -r file               It is the same as the -R flag, but instead of specifying file"
	echo "                        by file, -r reads a file line by line with the files or"
	echo "                        directories to copy."
	echo "  -c config             Path to appjail.conf."
	echo "  -i init_script        Init script executed when the appjail is started."
	echo "  -j jail_name          The name of the jail used by the appjail application."
	echo "  -t template           Template used by the appjail application."
}

usage()
{
	echo "usage: build_jail.sh [-R path] [-d dir] [-o output] [-r file] [ -H | -T ] -c config -i init_script -j jail_name -t template"
}

main $@
