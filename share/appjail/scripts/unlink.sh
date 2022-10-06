#!/bin/sh

main()
{
	local _o _l
	local config
	local abs_node node

	while getopts ":c:n:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			n)
				node="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
		esac
	done

	if [ -z "${config}" -o -z "${node}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/replace"
	. "${LIBDIR}/mount"

	lib_replace_jaildir

	abs_node="${JAILDIR}/${node}"

	if [ "`dirname \"${abs_node}\"`" != "${JAILDIR}" -o "`basename \"${abs_node}\"`" != "${node}" ]; then
		lib_err ${EX_DATAERR} "The name of the jail is invalid."
	fi

	if [ ! -d "${abs_node}" ]; then
		lib_err ${EX_NOINPUT} "The ${abs_node} directory does not exists."
	fi

	set -e

	umount "${abs_node}" 2>&1 |\
	while read _l; do
		if [ -n "${_l}" ]; then
			lib_debug "${_l}"
		fi
	done

	rmdir "${abs_node}"
}

help()
{
	usage

	echo
	echo "  -c config             Path to the appjail configuration."
	echo "  -n node               The name of the jail to be unlinked."
}

usage()
{
	echo "usage: unlink.sh -c config -n node"
}

main $@
