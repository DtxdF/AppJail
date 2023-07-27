#!/bin/sh

EX_USAGE=64
EX_DATAERR=65
EX_NOINPUT=66

main()
{
	local algo="/sbin/sha256"
	local interval=60
	local hosts
	local hook

	while getopts ":a:i:h:H:" _o; do
		case "${_o}" in
			a)
				algo="${OPTARG}"
				;;
			i)
				interval="${OPTARG}"
				;;
			h)
				hosts="${OPTARG}"
				;;
			H)
				hook="${OPTARG}"
				;;
			*)
				usage
				exit ${EX_USAGE}
				;;
		esac
	done

	if [ -z "${hosts}" -o -z "${hook}" ]; then
		usage
		exit ${EX_USAGE}
	fi

	if ! which -s "${algo}"; then
		printf "%s\n" "${algo}: algo cannot be found." >&2
		exit ${EX_NOINPUT}
	fi

	if ! printf "%s" "${interval}" | grep -qEe '^[0-9]+$'; then
		printf "%s\n" "${interval}: invalid interval." >&2
		exit ${EX_DATAERR}
	fi

	if [ ! -f "${hosts}" ]; then
		touch -- "${hosts}" || exit $?
	fi

	if [ ! -f "${hook}" ]; then
		printf "%s\n" "${hook}: hook cannot be found." >&2
		exit ${EX_NOINPUT}
	fi

	local current_hosts current_hosts_sum

	while true; do
		current_hosts=`appjail-dns` || exit $?
		current_hosts_sum=`printf "%s\n" "${current_hosts}" | "${algo}"` || exit $?

		if [ `${algo} -q "${hosts}"` != ${current_hosts_sum} ]; then
			printf "%s\n" "${current_hosts}" > "${hosts}" || exit $?
			"${hook}" "${hosts}" || exit $?
		fi

		sleep "${interval}" || exit $?
	done
}

usage()
{
	echo "usage: ajdns.sh [-a algo] [-i interval] -h hosts -H hook" >&2
}

main "$@"
