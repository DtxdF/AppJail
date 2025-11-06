#!/bin/sh

exec >&2

test $# -gt 0 || exit 0

STAGE="$1"; shift

test $# -gt 0 || exit 0

case "${STAGE}" in
    start|stop) ;;
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

appjail label get -l "security-group" -- "${JAIL}" value > /dev/null 2>&1 || exit 0

IPADDRS=`appjail jail get -I -- "${JAIL}" network_ip4 | sed -Ee 's/,/ /g'` || exit $?

test -n "${IPADDRS}" || exit 0

LABELS=`appjail label list -eHIpt -- "${JAIL}" name` || exit $?

test -n "${LABELS}"  || exit $?

REGEX=`appjail label get -l "security-group.include-only" -- "${JAIL}" value 2> /dev/null`

if [ -z "${REGEX}" ]; then
    REGEX=".+"
fi

for name in ${LABELS}; do
    case "${name}" in
        security-group.tables.*) ;;
        *) continue ;;
    esac

    table=`appjail label get -l "${name}" "${JAIL}" value` || exit $?

    test -n "${table}" || continue

    for ipaddr in ${IPADDRS}; do
        if ! printf "%s" "${ipaddr}" | grep -qEe "${REGEX}"; then
            continue
        fi

        if [ "${STAGE}" = "start" ]; then
            pfctl -t "${table}" -T add ${ipaddr} || exit $?
        else
            pfctl -t "${table}" -T delete ${ipaddr} || exit $?
        fi
    done
done
