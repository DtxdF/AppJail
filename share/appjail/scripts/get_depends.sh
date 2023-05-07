#!/bin/sh
#
# Copyright (c) 2022-2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
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
	local config
	local template
	local jail_name
	local escape_resolved
	local escape_seen
	local depend

	if [ $# -eq 0 ]; then
		usage
		exit ${EX_USAGE}
	fi

	while getopts ":c:t:" _o; do
		case "${_o}" in
			c)
				config="${OPTARG}"
				;;
			t)
				template="${OPTARG}"
				;;
			*)
				usage
				exit ${EX_USAGE}
				;;
		esac
	done
	shift $((OPTIND-1))

	jail_name="$1"
	if [ -z "${jail_name}" ]; then
		usage
		exit ${EX_USAGE}
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exist or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi
	
	. "${config}"
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/log"
	lib_load "${LIBDIR}/tempfile"
	lib_load "${LIBDIR}/atexit"
	lib_load "${LIBDIR}/replace"

	if [ ! -d "${JAILDIR}/${jail_name}" ]; then
		lib_err ${EX_NOINPUT} "Cannot find the jail \`${jail_name}\`"
	fi

	if [ ! -f "${template}" ]; then
		lib_warn "Cannot find the template \`${template}\`."
	fi

	lib_atexit_init

	resolved=`lib_generate_tempfile`
	escape_resolved=`lib_escape_string "${resolved}"`

	lib_atexit_add "rm -f \"${escape_resolved}\""

	seen=`lib_generate_tempfile`
	escape_seen=`lib_escape_string "${seen}"`

	lib_atexit_add "rm -f \"${escape_seen}\""

	dep_resolve "${jail_name}" "${resolved}" "${seen}" "${template}"

	while IFS= read -r depend; do
		printf "%s\n" "${depend}"
	done < "${resolved}"
}

dep_resolve()
{
	local jail_depend
	local jail_name="$1"
	local resolved="$2"
	local seen="$3"
	local template="$4"

	if [ -z "${jail_name}" -o -z "${resolved}" -o -z "${seen}" -o -z "${template}" ]; then
		lib_err ${EX_USAGE} "usage: dep_resolve jail_name resolved_file seen_file template"
	fi

	if [ ! -d "${JAILDIR}/${jail_name}" ]; then
		lib_err ${EX_NOINPUT} "Cannot find the jail \`${jail_name}\`"
	fi

	lib_debug "Resolving dependencies for ${jail_name}..."

	if ! printf "%s\n" "${jail_name}" >> "${seen}"; then
		lib_err ${EX_IOERR} "Could not add ${jail_name} jail to \`seen\` list."
	fi

	lib_debug -- "${jail_name} appended to the \`seen\` list."

	if [ -f "${template}" ]; then
		lib_ajconf getColumn -Ppit "${template}" depend | while IFS= read -r jail_depend; do
		    if ! match "${jail_depend}" "${resolved}"; then
			if match "${jail_depend}" "${seen}"; then
			    lib_err ${EX_CONFIG} "${jail_name}: dependency loop: ${jail_depend}"
			fi
			dep_resolve "${jail_depend}" "${resolved}" "${seen}" "${JAILDIR}/${jail_depend}/conf/template.conf"
		    fi
		done
	else
		lib_debug "Missing template.conf for ${jail_name}"
	fi

	if ! printf "%s\n" "${jail_name}" >> "${resolved}"; then
		lib_err ${EX_IOERR} "Could not add ${jail_name} jail to \`resolved\` list."
	fi

	lib_debug -- "${jail_name} appended to the \`resolved\` list."
}

match()
{
	local line
	local text="$1"
	local file="$2"

	if [ -z "${text}" -o -z  "${file}" ]; then
		lib_err ${EX_USAGE} "usage: match text file"
	fi

	while IFS= read -r line; do
		if [ "${line}" = "${text}" ]; then
			return 0
		fi
	done < "${file}"

	return 1
}

usage()
{
	echo "usage: get_depends.sh -c config -t template jail_name"
}

main "$@"
