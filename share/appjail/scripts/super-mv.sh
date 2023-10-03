#!/bin/sh

main()
{
	local _o
	local dst
	local config
	local src

	while getopts ":d:f:s:" _o; do
		case "${_o}" in
			d)
				dst="${OPTARG}"
				;;
			f)
				config="${OPTARG}"
				;;
			s)
				src="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done

	if [ -z "${dst}" -o -z "${config}" -o -z "${src}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/check_func"
	lib_load "${LIBDIR}/jail"
	lib_load "${LIBDIR}/log"

	cd -- "${src}"

	find . -mindepth 1 | cut -c3- | tail -r | while IFS= read -r file; do
		if [ ! -e "${file}" ]; then
			lib_err ${EX_NOINPUT} -- "${file}: No such file or directory."
		fi
		
		src_file="${src}/${file}"
		dst_file="${dst}/${file}"

		if [ ! -e "${dst_file}" ]; then
			lib_debug "Moving ${src_file} -> ${dst_file} ..."

			if printf "%s" "${file}" | grep -qEe '/'; then
				subdir="${file%/*}"
				
				mode=`stat -f "%OLp" -- "${src}/${subdir}"`
				owner_and_group=`stat -f "%u:%g" -- "${src}/${subdir}"`

				rootdir="${dst}/${subdir}"

				mkdir -m "${mode}" -p -- "${rootdir}" || exit $?
				chown -f "${owner_and_group}" "${rootdir}" || exit $?
			fi

			mv "${src_file}" "${dst_file}" || exit $?
		fi
	done || exit $?
}

usage()
{
	echo "usage: super-mv -d dst -f config -s src"
}

main "$@"
