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
				
				mode=`stat -f "%OLp" -- "${src}/${subdir}"` || exit $?
				owner_and_group=`stat -f "%u:%g" -- "${src}/${subdir}"` || exit $?

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
