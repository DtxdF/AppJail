#!/bin/sh

main()
{
	local _o
	local parent_pid
	local pid

	if [ $# -eq 0 ]; then
		usage
		exit ${EX_USAGE}
	fi

	while getopts ":c:P:p:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			P)
				parent_pid="${OPTARG}"
				;;
			p)
				pid="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done

	if [ -z "${config}" -o -z "${pid}" -o -z "${parent_pid}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi
	
	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/log"
	lib_load "${LIBDIR}/check_func"

	if ! lib_check_number "${parent_pid}"; then
		lib_err ${EX_DATAERR} -- "${parent_pid}: invalid parent PID."
	fi

	if ! lib_check_number "${pid}"; then
		lib_err ${EX_DATAERR} -- "${pid}: invalid PID."
	fi

	local current_parent_pid
	current_parent_pid=`get_ppid "${pid}"`

	if [ -z "${current_parent_pid}" ]; then
		lib_err ${EX_NOINPUT} "Cannot find parent pid of \`${pid}\`"
	fi

	if [ ${current_parent_pid} -eq ${parent_pid} ]; then
		lib_debug "Killing ${pid} ..."

		kill "${pid}"
	fi
}

get_ppid()
{
	local pid="$1"
	if [ -z "${pid}" ]; then
		echo "usage: get_pid pid" >&2
		exit 64 # EX_USAGE
	fi

	ps -p "${pid}" -o ppid | grep -v PPID | awk '{print $1}'
}

usage()
{
	echo "usage: kill_child.sh -c config -P parent_pid -p pid"
}

main "$@"
