#!/bin/sh

main()
{
	local _o
	local config
	local target mountpoint
	local abs_target abs_mountpoint

	while getopts ":c:t:m:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			t)
				target="${OPTARG}"
				;;
			m)
				mountpoint="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
		esac
	done

	if [ -z "${config}" -o -z "${target}" -o -z "${mountpoint}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/replace"
	. "${LIBDIR}/mount"
	. "${LIBDIR}/strlen"

	lib_replace_jaildir

	abs_target="${APPSDIR}/${target}"
	abs_mountpoint="${JAILDIR}/${mountpoint}"

	if [ "`dirname \"${abs_target}\"`" != "${APPSDIR}" -o "`basename \"${abs_target}\"`" != "${target}" ]; then
		lib_err ${EX_DATAERR} "The name of the appjail is invalid."
	fi

	if [ "`dirname \"${abs_mountpoint}\"`" != "${JAILDIR}" -o "`basename \"${abs_mountpoint}\"`" != "${mountpoint}" ]; then
		lib_err ${EX_DATAERR} "The name of the new jail is invalid."
	fi

	if [ ! -d "${abs_target}/jail" ]; then
		lib_err ${EX_NOINPUT} "The jail directory of the ${target} appjail does not exists."
	fi

	if [ ! -d "${abs_mountpoint}" ]; then
		mkdir -p "${abs_mountpoint}"
	fi

	if [ `lib_countfiles "${abs_mountpoint}"` -gt 0 ]; then
		lib_err ${EX_DATAERR} "The directory to be used for the new jail already contains files and cannot be used."
	fi

	if lib_check_mount "${abs_mountpoint}"; then
		lib_err ${EX_SOFTWARE} "${mountpoint} has a node mounted in its root directory."
	fi

	mount_nullfs "${abs_target}/jail" "${abs_mountpoint}"
}

help()
{
	usage

	echo
	echo "  -c config             Path to the appjail configuration."
	echo "  -t target             The name of the appjail to use."
	echo "  -m moountpoint        The name of the new jail."
}

usage()
{
	echo "usage: link.sh -c config -t target -m mountpoint"
}

main $@
