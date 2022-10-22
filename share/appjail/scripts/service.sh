#!/bin/sh
#
# Copyright (c) 2022, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

main()
{
	local _o
	local config jail_conf appjail
	local opt_start opt_stop
	local default_template template parameters
	local opt_template
	local base_jail jail_usetype opt_thinjail

	if [ $# -eq 0 ]; then
		help
		exit 64 # EX_USAGE
	fi

	opt_start=0
	opt_stop=0
	opt_template=0
	opt_thinjail=0

	while getopts ":TsSa:c:b:p:t:" _o; do
		case "${_o}" in
			T)
				opt_thinjail=1
				;;
			s)
				opt_start=1
				;;
			S)
				opt_stop=1
				;;
			a)
				appjail="${OPTARG}"
				;;
			c)
				config="${OPTARG}"
				;;
			b)
				opt_thinjail=1
				base_jail="${OPTARG}"
				;;
			p)
				parameters="${parameters} ${OPTARG}"
				;;
			t)
				template="${OPTARG}"
				opt_template=1
				;;
			*)
				usage
				exit 64 # EX_USAGE
		esac
	done
	shift $((OPTIND-1))

	if [ -z "${config}" -o ${opt_start} -eq ${opt_stop} ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ ! -f "${config}" ]; then
		echo "Configuration file \`${config}\` does not exists or you don't have permission to read it." >&2
		exit 66 # EX_NOINPUT
	fi

	. "${config}"
	. "${LIBDIR}/sysexits"
	. "${LIBDIR}/log"
	. "${LIBDIR}/tempfile"
	. "${LIBDIR}/replace"
	. "${LIBDIR}/atexit"
	. "${LIBDIR}/jail"
	. "${LIBDIR}/sysrc"

	set -e

	lib_atexit_init

	if [ ! -d "${APPSDIR}/${appjail}" ]; then
		lib_err ${EX_NOINPUT} "The ${appjail} appjail does not exists."
	fi

	default_template="${APPSDIR}/${appjail}/conf/jail.conf"
	if [ ${opt_stop} -eq 1 ]; then
		default_template="${default_template}.stop"
	fi

	if [ -z "${template}" ]; then
		template="${default_template}"
	fi

	if [ ! -f "${default_template}" ]; then
		lib_err ${EX_NOINPUT} "The \"${default_template}\" template does exists."
	fi

	if [ ${opt_template} -eq 1 ] && [ ! -f "${template}" ]; then
		lib_err ${EX_NOINPUT} "The \"${template}\" template does exists."
	fi

	if [ ${opt_template} -eq 1 ]; then
		cat "${default_template}" > "${template}"
	fi

	if [ ${opt_start} -eq 1 ]; then
		if lib_jail_exists "${appjail}"; then
			lib_err ${EX_SOFTWARE} "The ${appjail} is currently running."
		fi
	else
		if ! lib_jail_exists "${appjail}"; then
			lib_err ${EX_SOFTWARE}  "${appjail} is not running."
		fi
	fi

	if [ ${opt_template} -eq 1 -a -n "${parameters}" ]; then
		lib_debug "Setting required parameters:${parameters}"

		/bin/sh "${SCRIPTSDIR}/set.sh" -t "${template}" -a "${appjail}" -c "${config}" -- "${parameters}"
	fi

	lib_debug "Checking for required parameters..."

	if lib_req_jail_params "${template}"; then
		lib_err ${EX_USAGE} "There are required parameters. Use \`appjail edit -t -a \"${appjail}\"\` to edit it. See also \`appjail help set\` and \`appjail help start\`."
	fi

	lib_debug "Editing template \"${template}\""

	jail_conf="`lib_filter_jail \"${appjail}\" \"${template}\" \"${APPSDIR}/${appjail}/jail\"`"
	lib_atexit_add rm -f "${jail_conf}"

	lib_replace_jaildir

	jail_usetype="`lib_jail_getusetype \"${APPSDIR}/${appjail}/conf/appjail.conf\"`"

	if [ "${jail_usetype}" = "-" ]; then
		# Backward compatibility
		jail_usetype="${JAIL_tYPE_THICK}"
	fi

	if [ ${opt_stop} -eq 1 -a ${opt_thinjail} -eq 1 -a ${jail_usetype} != "${JAIL_TYPE_THIN}" ]; then
		lib_err ${EX_DATAERR} "You must not use the -T flag when this is not a thinjail."
	elif [ ${opt_stop} -eq 1 -a ${opt_thinjail} -eq 0 -a ${jail_usetype} = "${JAIL_TYPE_THIN}" ]; then
		lib_err ${EX_DATAERR} "You must use the -T flag when this is a thinjail."
	fi
	
	if [ ${opt_start} -eq 1 -a -n "${base_jail}" -a ${jail_usetype} != "${JAIL_TYPE_THIN}" ]; then
		lib_err ${EX_DATAERR} "You must not use the -b flag when this is not a thinjail."
	elif [ ${opt_start} -eq 1 -a -z "${base_jail}" -a ${jail_usetype} = "${JAIL_TYPE_THIN}" ]; then
		lib_err ${EX_DATAERR} "You must use the -b flag when this is a thinjail."
	fi

	if [ ${opt_start} -eq 1 ]; then
		if [ -n "${base_jail}" ] && [ ! -d "${JAILDIR}/${base_jail}" ]; then
			lib_err ${EX_NOINPUT} "The \"${base_jail}\" base jail does not exists. See \`appjail help jail\` to create one."
		fi
		
		if [ -n "${base_jail}" ]; then
			mount -t nullfs -o ro "${JAILDIR}/${base_jail}" "${APPSDIR}/${appjail}/jail/.appjail"
		fi

		lib_create_jail "${jail_conf}" "${appjail}"
		/bin/sh "${SCRIPTSDIR}/run_jail.sh" -s -c "${config}" -a "${appjail}" -- $@
		cp "${template}" "${default_template}.stop"
	else
		/bin/sh "${SCRIPTSDIR}/run_jail.sh" -S -c "${config}" -a "${appjail}" -- $@
		lib_remove_jail "${jail_conf}" "${appjail}"
		rm -f "${default_template}"
		if [ "${opt_thinjail}" -eq 1 ]; then
			umount "${APPSDIR}/${appjail}/jail/.appjail"
		fi
	fi
}

help()
{
	usage

	echo
	echo "  -T                  When this is a thinjail, this flag must be used. -b flag implicitly set this flag."
	echo "  -b base             The base jail to use when this is a thinjail."
	echo "  -p key=value        This flag is useful for setting parameters temporarily. If you need to set them"
	echo "                      permanently, see \`appjail help set\` and if you need a more complex way to edit"
	echo "                      a template, see \`appjail help edit\`. May be used multiples times."
	echo "  -t template         Path to the temporary template."
	echo "  -s                  Start the from an appjail application."
	echo "  -S                  Remove the jail from an appjail application."
	echo "  -c config           Path to the appjail configuration."
	echo "  -a appjail          Name of the appjail application."
}

usage()
{
	echo "usage: service.sh [-T] [-b base] [-p key=value] [-t template] [-s | -S] -c config -a appjail -- [args]"
}

main $@
