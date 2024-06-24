#!/bin/sh
#
# Copyright (c) 2024, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
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

main()
{
	local _o
	local opt_force_updates=0
	local config
	local repodir
	local url

	while getopts ":Ff:r:u:" _o; do
		case "${_o}" in
			F)
				opt_force_updates=1
				;;
			f)
				config="${OPTARG}"
				;;
			r)
				repodir="${OPTARG}"
				;;
			u)
				url="${OPTARG}"
				;;
			*)
				usage
				exit 64 # EX_USAGE
				;;
		esac
	done

	if [ -z "${config}" -o -z "${repodir}" -o -z "${url}" ]; then
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

	if [ ! -d "${repodir}" ]; then
		lib_debug "Cloning ${url} as ${repodir} ..."

		git clone -q -o origin -- "${url}" "${repodir}" >&2
	else
		if [ ${opt_force_updates} -eq 1] || [ "${AUTO_GIT_UPDATE}" != 0 ]; then
			lib_debug "Updating ${repodir} ..."

			git -C "${repodir}" fetch -q origin >&2 &&
			git -C "${repodir}" reset -q --hard origin >&2
		else
			lib_warn "Automatic updates are disabled (AUTO_GIT_UPDATE = 0), ${url} (id = ${reponame}) will not be updated."
		fi
	fi

	exit $?
}

usage()
{
	echo "usage: git -f config -r repodir"
}

main "$@"
