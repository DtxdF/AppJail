#!/bin/sh

main()
{
	concat_hosts "$@"
}

concat_hosts()
{
	local etchosts

	for etchosts in "$@"; do
		if [ ! -f "${etchosts}" ]; then
			echo "Unable to open \`${etchosts}\`" >&2
			exit 1
		fi

		grep -Ev '^[[:space:]]*#' -- "${etchosts}"
	done

	get_hosts
}

get_hosts()
{
	appjail network list -HIpt name | while IFS= read -r network_name
	do
		appjail network hosts -rHHn "${network_name}"
	done
}

main "$@"
