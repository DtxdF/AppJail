#!/bin/sh

#
# The dyndns hook is designed to work with dyndnsd, a lightweight web application
# compatible with dyndns.
#
# This hook uses the following labels:
#
# dyndns                   Set to enable the use of this hook.
#
# dyndns.dyn-domain        Space-separated list of host names (with port optionally
#                          separated by ":") of dyndnsd instances where this hook
#                          will update entries.
#                          Each instance is assumed to be a mirror of the others.
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
# dyndns.password          File containing the password. When this label isn't set,
#                          username will be used.
#
# dyndns.on-failure        Failure policy. Set to "fail" to exit with a non-zero exit
#                          status after all retries have been exhausted. Set to
#                          "continue" (default) to exit with a zero exit status.
#                          If you use multiple instances, it is considered a success
#                          when at least one entry is updated correctly, even if the
#                          others fail.
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
    start|jail) ;;
    *) exit 0 ;;
esac

if [ "${STAGE}" = "jail" ]; then
    test $# -gt 0 || exit 0

    STAGE="$1"; shift

    if [ "${STAGE}" != "destroy" ]; then
        exit 0
    fi
fi

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

#
# We should not remove the entry if the jail isn't stopped first.
#
if [ "${STAGE}" = "destroy" ] && appjail status -q -- "${JAIL}"; then
    exit 0
fi

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

#
# Even though we are destroying the jail, it's good to check if the interface exists.
#
CURRENT_IP=$(ifconfig -- "${INTERFACE}" inet | \
      grep -m 1 -o 'inet.*' | cut -d ' ' -f 2)

test -n "${CURRENT_IP}" || exit 0

USERNAME=`appjail label get -l "dyndns.username" -- "${JAIL}" value 2> /dev/null`

test -n "${USERNAME}" || exit $?

PASSWORD=`appjail label get -l "dyndns.password" -- "${JAIL}" value 2> /dev/null`

if [ -z "${PASSWORD}" ]; then
    PASSWORD="${USERNAME}"
else
    PASSWORD=`head -1 -- "${PASSWORD}"` || exit $?
fi

ON_FAILURE=`appjail label get -l "dyndns.on-failure" -- "${JAIL}" value 2> /dev/null`

if [ -z "${ON_FAILURE}" ]; then
    ON_FAILURE="continue"
fi

case "${ON_FAILURE}" in
    fail|continue) ;;
    *) ON_FAILURE="continue"
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

USER_AGENT="AppJail/`appjail version` dtxdf@disroot.org"

success=false

for dyn_domain in ${DYN_DOMAIN}; do
    URL="${SCHEME}://${USERNAME}:${PASSWORD}@${dyn_domain}/nic/update?hostname=${HOSTNAME}"

    if [ "${STAGE}" = "start" ]; then
        URL="${URL}&myip=${CURRENT_IP}"
    else
        URL="${URL}&offline=YES"
    fi

    for r in `jot "${TOTAL_RETRY}"`; do
        fetch -qo - --user-agent="${USER_AGENT}" "${URL}" && echo

        if [ $? -eq 0 ]; then
            success=true
            break
        fi

        WAIT=`jot -r 1 6 10`
        WAIT=$((WAIT+r))

        sleep ${WAIT}
    done
done

if ! ${success} && [ "${ON_FAILURE}" = "fail" ]; then
    exit 1
fi

exit 0
