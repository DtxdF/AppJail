#!/bin/sh

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

appjail label get -l "sysctl" -- "${JAIL}" value > /dev/null 2>&1 || exit 0

LABELS=`appjail label list -eHIpt -- "${JAIL}" name` || exit $?

test -n "${LABELS}"  || exit $?

. /etc/rc.subr

for name in ${LABELS}; do
    case "${name}" in
        sysctl.*) ;;
        *) continue ;;
    esac

    param=`appjail label get -l "${name}" "${JAIL}" value` || exit $?

    "${SYSCTL}" -- "${param}" > /dev/null || exit $?
done

exit 0
