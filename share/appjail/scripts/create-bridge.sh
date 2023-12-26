#!/bin/sh
#
# Copyright (c) 2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

NETWORK_GENERIC_BRG="bridge"

main()
{
	local _o
	local config

	if [ $# -eq 0 ]; then
		usage
		exit ${EX_USAGE}
	fi

	while getopts ":b:c:" _o; do
		case "${_o}" in
			b)
				bridge="${OPTARG}"
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

	if [ -z "${config}" ]; then
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

	if lib_check_iface "${bridge}"; then
		if ! lib_check_ifacegrp "${bridge}" "${NETWORK_GENERIC_BRG}"; then
			lib_err ${EX_CONFIG} "The ${bridge} bridge exists but is not in the \`${NETWORK_GENERIC_BRG}\` group."
		fi

		lib_debug -- "${bridge}: bridge already created."

		return 0
	fi

	ifconfig bridge create name "${bridge}" || exit $?
	ifconfig -- "${bridge}" up || exit $?

	lib_debug -- "${bridge}: the bridge has been created."
}

usage()
{
	echo "usage: create-bridge.sh -c config -b bridge"
}

main "$@"
