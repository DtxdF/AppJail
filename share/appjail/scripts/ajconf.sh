#!/bin/sh

CONFIG="%%PREFIX%%/share/appjail/files/config.conf"

. "${CONFIG}"

APPJAIL_CONFIG_JAILDIR="${JAILDIR}" \
	"${UTILDIR}/appjail-config/appjail-config" "$@"
