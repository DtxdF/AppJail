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

REGEX=`appjail label get -l "security-group.include-only" -- "${JAIL}" value 2> /dev/null`

if [ -z "${REGEX}" ]; then
    REGEX=".+"
fi

if [ "${STAGE}" = "start" ]; then
    LABELS=`appjail label list -eHIpt -- "${JAIL}" name` || exit $?

    test -n "${LABELS}"  || exit $?

    IPADDRS=`appjail jail get -I -- "${JAIL}" network_ip4 | sed -Ee 's/,/ /g'` || exit $?

    for name in ${LABELS}; do
        case "${name}" in
            security-group.rules.*) ;;
            *) continue ;;
        esac

        rule=`appjail label get -l "${name}" "${JAIL}" value` || exit $?

        test -n "${rule}" || continue

        if [ -z "${IPADDRS}" ]; then
            printf "%s\n" "${rule}" || exit $?
            continue
        fi

        for ipaddr in ${IPADDRS}; do
            if ! printf "%s" "${ipaddr}" | grep -qEe "${REGEX}"; then
                continue
            fi

            rule=`printf "%s" "${rule}" | sed -Ee "s/%i/${ipaddr}/g"` || exit $?

            printf "%s\n" "${rule}" || exit $?
        done
    done | pfctl -a "appjail-filter/jail/${JAIL}" -f - || exit $?
else
    if pfctl -a "appjail-filter/jail/${JAIL}" -sn -P 2> /dev/null; then
        pfctl -a "appjail-filter/jail/${JAIL}" -Frules || exit $?
    fi
fi
