#!/bin/sh

#
# The dyndns hook is designed to work with dyndnsd, a lightweight web application
# compatible with dyndns.
#
# This hook uses the following labels:
#
# dyndns                   Set to enable the use of this hook.
#
# dyndns.dyn-domain        Host name and dyndnsd port to connect to.
#
# dyndns.https             Set to use https when connecting to dyndnsd. When this label
#                          isn't set, http is used.
#
# dyndns.hostname          Hostname to update.
#
# dyndns.interface         Interface to get the IPv4 address.
#
# dyndns.username          Username.
#
# dyndns.password          Password. When this label isn't set, username will be used.
#
# dyndns.on-failure        Failure policy. Set to "fail" (default) to exit with a
#                          non-zero exit status after all retries have been exhausted.
#                          Set to "continue" to exit with a zero exit status.
#
# dyndns.retry             Number of attempts when fetch(1) fails. Default to 3.
#
#
#
# NOTE: If you do not define a label that does not have a default value, this hook
#       will fail silently. The same occurs when the IPv4 address of the interface
#       you specified cannot be obtained.
#
# In theory, IPv6 support can be added. Feel free to submit a PR with the patch if
# you need it.

exec >&2

test $# -gt 0 || exit 0

STAGE="$1"; shift

test $# -gt 0 || exit 0

case "${STAGE}" in
    start) ;;
    *) exit 0 ;;
esac

while getopts ":" OPT; do
    case "${OPT}" in
        --) break ;;
        *) continue ;;
    esac
done
shift $((OPTIND-1))

test $# -gt 0 || exit 0

JAIL="$1"

appjail label get -l "dyndns" -- "${JAIL}" value > /dev/null 2>&1 || exit 0

DYN_DOMAIN=`appjail label get -l "dyndns.dyn-domain" -- "${JAIL}" value 2> /dev/null`

test -n "${DYN_DOMAIN}" || exit $?

HTTPS=`appjail label get -l "dyndns.https" -- "${JAIL}" value 2> /dev/null`

if [ -n "${HTTPS}" ]; then
    HTTPS=true
else
    HTTPS=false
fi

HOSTNAME=`appjail label get -l "dyndns.hostname" -- "${JAIL}" value 2> /dev/null`

test -n "${HOSTNAME}" || exit $?

INTERFACE=`appjail label get -l "dyndns.interface" -- "${JAIL}" value 2> /dev/null`

test -n "${INTERFACE}" || exit $?

CURRENT_IP=$(ifconfig -- "${INTERFACE}" inet | \
      grep -m 1 -o 'inet.*' | cut -d ' ' -f 2)

test -n "${CURRENT_IP}" || exit $?

USERNAME=`appjail label get -l "dyndns.username" -- "${JAIL}" value 2> /dev/null`

test -n "${USERNAME}" || exit $?

PASSWORD=`appjail label get -l "dyndns.password" -- "${JAIL}" value 2> /dev/null`

if [ -z "${PASSWORD}" ]; then
    PASSWORD="${USERNAME}"
fi

ON_FAILURE=`appjail label get -l "dyndns.on-failure" -- "${JAIL}" value 2> /dev/null`

if [ -z "${ON_FAILURE}" ]; then
    ON_FAILURE="fail"
fi

case "${ON_FAILURE}" in
    fail|continue) ;;
    *) ON_FAILURE="fail"
esac

TOTAL_RETRY=`appjail label get -l "dyndns.retry" -- "${JAIL}" value 2> /dev/null`

if [ -z "${TOTAL_RETRY}" ]; then
    TOTAL_RETRY="3"
fi

if ! printf "%s" "${TOTAL_RETRY}" | grep -qEe '^[0-9]+$'; then
    TOTAL_RETRY="3"
fi

if ${HTTPS}; then
    SCHEME="https"
else
    SCHEME="http"
fi

URL="${SCHEME}://${USERNAME}:${PASSWORD}@${DYN_DOMAIN}/nic/update?hostname=${HOSTNAME}&myip=${CURRENT_IP}"

USER_AGENT="AppJail/`appjail version` dtxdf@disroot.org"

for r in `jot "${TOTAL_RETRY}"`; do
    fetch -qo - --user-agent="${USER_AGENT}" "${URL}" && echo

    if [ $? -eq 0 ]; then
        exit 0
    fi
done

if [ "${ON_FAILURE}" = "continue" ]; then
    exit 0
else
    exit 1
fi
