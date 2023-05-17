#!/bin/sh

CONFIG="%%PREFIX%%/share/appjail/files/config.conf"

. "${CONFIG}"

"${SCRIPTSDIR}/runas.sh" "appjail-config" "$@"
